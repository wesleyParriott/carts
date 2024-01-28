pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main loops--
-- -- todo -- -- 
-- product moves around towers
-- win 
-- 	-- destory all product 
-- 	-- which bankrupts factory
-- 	-- factory explosion
-- lose
--  -- products get to the store
--  -- you lose moral
--  -- crying cows?
-- levels?
-- when products hit a tower
-- 	they try to go left,right,upmdown
-- product ideas
-- -- carton (least health)
-- -- jug (least health)
-- -- cheese (fast)
-- -- cottage cheese (explodes damaging other products)
-- -- heart (gives you health)
-- tower ideas (cows)
-- -- $ regular cow (one target normal damage)
-- -- $$ ranger cow (slows with net)
-- -- $$$ wizard cow (explosion)
-- pixel art 
-- music
-- sounds
-- improvements
-- 	-- projectile instead of line
-- 	-- why line get so stretchy?
-- 	-- tower shoots after target dies


-- all of the entities
-- put a update function to update it 
-- put a draw function to draw it 
_entities  = {}
_gamestate = "cow_td"
_gold = 20000
_frame = 0 

function printd(msg)
	printh("[" .. _frame .. "] " .. msg)
end

function lerp(v0, v1, tm)
	local ret = (1 - tm) * v0 + tm * v1
	return ret
end

function collided(a,b)
	assert(a.w ~= nil)
	assert(a.h ~= nil)
	assert(a.x ~= nil)
	assert(a.y ~= nil)
	assert(b.w ~= nil)
	assert(b.h ~= nil)
	assert(b.x ~= nil)
	assert(b.y ~= nil)

	local x0=a.x
	local y0=a.y
	local w0=a.w
	local h0=a.h
	local x1=b.x
	local y1=b.y
	local w1=b.w
	local h1=b.h

	local x0max=x0+w0
	local y0max=y0+h0

	local x1max=x1+w1
	local y1max=y1+h1

	local test=(x0 < x1max and
	      x0max > x1 and
							y0 < y1max and
							y0max > y1)

	return test	
end

function collided_cvr(circle, rectangle)
	assert(circle.x ~= nil)
	assert(circle.y ~= nil)
	assert(circle.r ~= nil)
	assert(rectangle.w ~= nil)
	assert(rectangle.h ~= nil)
	assert(rectangle.x ~= nil)
	assert(rectangle.y ~= nil)

	local tx = circle.x
	local ty = circle.y

	if circle.x < rectangle.x then
		tx = rectangle.x
	elseif circle.x > rectangle.x+rectangle.w then
		tx = rectangle.x+rectangle.w
	end
	
	if circle.y < rectangle.y then
		ty = circle.x
	elseif circle.y > rectangle.y+rectangle.h then
		ty = rectangle.y+rectangle.h
	end

	local dx = circle.x-tx
	local dy = circle.y-ty
	local d  = sqrt((dx*dx)+(dy*dy))

	if d <= circle.r then
		return true
	end

	return false
end

-- point vs rectangle
function collided_pvr(point, rectangle)
	assert(point.x ~= nil)
	assert(point.y ~= nil)
	assert(rectangle.x ~= nil)
	assert(rectangle.y ~= nil)
	assert(rectangle.w ~= nil)
	assert(rectangle.h ~= nil)

	local px = point.x
	local py = point.y
	local rx = rectangle.x
	local ry = rectangle.y
	local rmaxx = rectangle.x + rectangle.w
	local rmaxy = rectangle.y + rectangle.h

	local tst = (px >= rx and px <= rmaxx) and
	(py >= ry and py <= rmaxy)

	return tst
end

function _init()
	create_gold_counter()
	create_lifebar()
	create_cursor()
	create_factory({"jug"})
	-- create_product(64,0,"jug")
	create_cowtower(64,64)
end

function create_gold_counter()
	local gold_counter={
		x=88,
		y=0,
		clr=10,
		ticker=0,
		ticker_max=60,
		ticker_value=1,
		update=function(self)
			if self.ticker >= self.ticker_max then
				_gold += self.ticker_value
				self.ticker=0
			end
			self.ticker += 1
		end,
		draw=function(self)
			print("gold " .. _gold, self.x, self.y, self.clr)
		end
	}
	add(_entities, gold_counter)
end

function create_cowtower(x,y)
	local cowtower = {
		type="tower",
		state="find",
		x=x,
		y=y,
		w=8,
		h=8,
		-- the radius of the circle
		-- when something passes thru
		-- this circle
		-- the tower will hit
		r=16,
		xoffset=2,
		yoffset=4,
		spr=000,
		product=nil,
		line_color=11,
		aim_ticker=0,
		aim_ticker_max=30,
		shoot_ticker=0,
		shoot_ticker_max=10,
		projectile=nil,
		find_target=function(self)
			for e in all(_entities) do
				if e.type == "product" then
					tst = collided_cvr(self,e)
					if self.product == nil and tst then
						self.product = e	
						self.state="aim"
					end
				end
			end
		end,
		aim=function(self)
			if self.state == "aim" then
				self.aim_ticker +=1
				if self.aim_ticker > self.aim_ticker_max then
					self.line_color = 08 
					self.aim_ticker = 0
					self.state = "shoot"
				end
			end
		end,
		shoot=function(self)
			if self.state == "shoot" then

				self.shoot_ticker += 1

				if self.shoot_ticker > self.shoot_ticker_max then
					self.line_color = 11
					self.shoot_ticker = 0
					self.product.life -= 1
					self.product = nil
					self.state = "find"
				end

			end
		end,
		update=function(self)
			self:find_target()
			self:aim()
			self:shoot()
		end,
		draw=function(self)
			spr(self.spr,self.x,self.y)

			local cx=self.x+self.xoffset
			local cy=self.y+self.yoffset
			circ(cx,cy,self.r,08)

			if self.product ~= nil then
				local x0 = self.x + (self.w/2)
				local y0 = self.y + (self.h/2)
				local x1 = self.product.x + (self.product.w/2)
				local y1 = self.product.y + (self.product.h/2)
				line(x0,y0,x1,y1,self.line_color)
			end
		end
	}

	add(_entities,cowtower)
end

function create_cursor()
	local crsr = {
		type="cursor",
		x=64,
		y=64,
		w=8,
		h=8,
		clr=09,
		price=10,
		update=function(self)
			if btnp(➡️) then 
				if self.x < (128 - self.w) then
					self.x+=self.w
				end
			end
			if btnp(⬅️) then 
				if self.x > 0 then
					self.x-=self.w
				end
			end
			if btnp(⬇️) then
				if self.y < (128 - self.h) then
					self.y+=self.h
				end
			end
			if btnp(⬆️) then
				if self.y > 0 then
					self.y-=self.h
				end
			end
			if btnp(❎) and 
			_gold >= self.price
			then
				_gold -= self.price
				create_cowtower(self.x,self.y)
			end
		end,
		draw=function(self)
			rect(self.x,self.y,self.x+self.w,self.y+self.h,self.clr)
		end
	}
	add(_entities, crsr)
end

function create_lifebar()
	local lifebar = {
		type="lifebar",
		x=0,
		y=0,
		hearts=3,
		heart_spr=032,
		unlife=function(self)
			self.hearts-=1
			if self.hearts < 0 then
				_gamestate="lose"
			end
		end,
		draw=function(self)
			local i = 0 
			while i < self.hearts do
				local x = self.x + (i*9)
				local y = self.y
				spr(self.heart_spr,x,y)
				i += 1
			end
		end
	}

	add(_entities, lifebar)
end

function create_product(x,y,product)
	local general_move = function(self)
		assert(self.target ~= nil)
		if self.target.x ~= self.x then
			local target_diff = self.target.x-self.x
			local sign = target_diff < 0 and -1 or 1
			local move=self.movement_speed*sign
			self.x+=self.movement_speed*sign
		end
		if self.target.y ~= self.y then
			local target_diff = self.target.y-self.y
			local sign = target_diff < 0 and -1 or 1
			local move=self.movement_speed*sign
			self.y+=self.movement_speed*sign
		end
		if flr(self.x) == self.target.x and
		flr(self.y) == self.target.y then
			future.target.y += 8
			-- check if tower is there
			for e in all(_entities) do 
				if e.type == "tower" then
					printd("found ourselves a tower")
					local tst = collided_pvr(self.target, e)
					if tst then 
						printd("so the world may be mended")
					end
				end
			end
			-- move target if needed
			-- priority
			-- right >  up > left
		end
	end

	if product == "heart" then
		create_product_heart(x,y,general_move)
	elseif product == "jug" then
		create_product_jug(x,y,general_move)
	else 
		printd("unknown product type " .. product)
		assert(false)
	end
end

function create_product_heart(x,y,move)
	local heart={
		type="product",
		x=x,
		y=y,
		w=8,
		h=8,
		spr=032,
		life=1,
		movement_speed=.01,
		move=move,
		die_if_dead=function(self)
			if self.y > 128 then
				del(_entities, self)
			end
		end,
		update=function(self)
			if self.life < 1 then
				del(_entities, self)
				for e in all(_entities) do
					if e.type == "lifebar" then
						if e.hearts < 3 then
							e.hearts+=1
						end
					end
				end
			end 
			self:move()
			self:die_if_dead()
		end,
		draw=function(self)
			spr(self.spr,self.x,self.y)
		end
	}
	add(_entities, heart)
end

function create_product_jug(x,y,move)
	local jug={
		type="product",
		state="down",
		x=x,
		y=y,
		max_y=128,
		w=8,
		h=8,
		spr=016,
		life=1000,
		movement_speed=.1,
		move=move,
		target={
			x=64,
			y=8
		},
		die_if_dead=function(self)
			if self.y > self.max_y then
				for e in all(_entities) do
					if e.type == "lifebar" then
						e:unlife()
					end
				end

				del(_entities, self)
			end
		end,
		update=function(self)
			if self.life < 1 then
				del(_entities, self)
			end 
			self:move()
			self:die_if_dead()
		end,
		draw=function(self)
			spr(self.spr,self.x,self.y)
			line(self.x,self.y,self.target.x,self.target.y,09)
		end
	}
	add(_entities, jug)
end

function create_factory(products)
	assert(products ~= nil)

	local factory = {
		type="factory",
		x=64,
		y=0,
		ticker=0,
		ticker_max=2*60,
		inital_ticker=0,
		inital_ticker_max=30*60,
		products=products,
		product_max=count(products),
		product_now=1,
		update=function(self)
			if self.ticker >= self.ticker_max then
				create_product(self.x,self.y,self.products[self.product_now])
				self.ticker=0
				self.product_now += 1
				if self.product_now > self.product_max then
					self:blowup()
				end
			end
			self.ticker+=1
		end,
		blowup=function(self)
			del(_entities, self)
		end
	}

	add(_entities, factory)
end

function _update60()

	_frame += 1

	if _gamestate == "cow_td" then

		for e in all(_entities) do 
			if e.update ~= nil then
				e:update()
			end
		end

	end

end

function _draw()
 cls()
	print(_frame,40,0,09)

	if _gamestate == "cow_td" then

		for e in all(_entities) do
			if e.draw ~= nil then
				e:draw()
			end
		end

	end

end

__gfx__
00777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07556665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77765650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5576eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5576e5e5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
71176660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08800880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888e88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888eee8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888e88000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
