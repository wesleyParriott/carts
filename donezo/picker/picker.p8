pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main loops--
--
--
--goal: 
-- intro

states={
	-- gamestates
	title=0,
	picker=1,
	titletrans=2,
	instructions=3,

	-- debug
	debug=248
}

types={
	cow=0,
	basket=1,
	berry=2,
	bush=3,
	pie_queue=4,
	pie=5
}

function collided(x0, y0, w0, h0, x1, y1, w1, h1)
	x0max=x0+w0
	y0max=y0+h0

	x1max=x1+w1
	y1max=y1+h1

	test=(x0 < x1max and
	      x0max > x1 and
							y0 < y1max and
							y0max > y1)

	return test
end

function create_cow(x,y)
	local cow={
		x=x,
		y=y,
		sprite=000,
		frame=0,
		frames=3,
		etype=types.cow,
		facing="right",
		animate=function(self)
			self.frame += 1
			if self.frame > self.frames then
				self.frame = 0
			end
		end,
		draw=function(self)
			local doflip = self.facing == "left"
			spr(self.sprite + self.frame, self.x, self.y, 1, 1, doflip)
		end,
		move=function(self, direction)
			if direction == "up" then
				self:animate()
				if self.y > 16 then
					self.y -= 1
				end
			elseif direction == "down" then
				self:animate()
				if self.y < 88 then
					self.y += 1
				end
			elseif direction == "left" then
				self.facing = "left"
				self:animate()
				if self.x > 16 then
					self.x -= 1
				end
			elseif direction == "right" then
				self.facing = "right"
				self:animate()
				if self.x < 104 then
					self.x += 1
				end
			end
		end
	}
	
	add(entities, cow)
end

function create_basket()
	local basket = {
		etype=types.basket,
		x=-128,
		y=-128,
		w=8,
		h=8,
		sprite=016,
		active=0,
		activemax=12,
		picksfx=01,

		draw=function(self)
			if self.active>0 then
				spr(self.sprite, self.x, self.y)
			end
		end,

		update=function(self)

			if self.active > 0 then
				self.active -= 1
				self.y+=1

				for e in all(entities) do
					if e.etype==types.bush then
						local tst=collided(self.x, self.y, self.w, self.h, e.x, e.y, e.w, e.h)
						if tst and (e.berry ~= nil) then
							b=e.berry
							local tst2=collided(self.x, self.y, self.w, self.h, b.x, b.y, b.w, b.h)
							if tst2 then 
								b.active=false
								add(pie_queue.members, b.sprite)
								if count(pie_queue.members) <= 2 then 
									sfx(self.picksfx)
								end
							end
						end
					end
				end

			end
		end,

		set=function(self, x, y, direction)
			self.x=x
			self.y=y
			self.active=self.activemax
		end
	}

	add(entities, basket)
end


function create_berry(x, y)

	local xmod = flr(rnd(2))
	local ymod = flr(rnd(2))
	local x1 = x+xmod*8
	local y1 = y+ymod*8
	local sprs = {032, 033, 034}

	local berry={
		x=x1,
		y=y1,
		w=8,
		h=8,
		sprite=rnd(sprs),
		active=true,
		etype=types.berry,

		draw=function(self)
			if self.active then
				spr(self.sprite, self.x, self.y)
			end
		end
	}

	return berry
end

function create_bush()
	local rx=flr(rnd(104)) 
	local ry=flr(rnd(88))
	if rx < 16 then rx = 16 end
	if ry < 16 then ry = 16 end
	local bush={
		x=rx,
		y=ry,
		w=32,
		h=32,
		-- per https://pico-8.fandom.com/wiki/Spr
		-- the w & h parameters for spr
		-- are how many sprites
		sw=2,
		sh=2,
		sprite=019,
		active=true,
		etype=types.bush,
		createberryat=60,
		createberrytimer=60,
		berry=nil, 

		draw=function(self)
			spr(self.sprite, self.x, self.y, self.sw, self.sh)
			if self.berry ~= nil then
				self.berry:draw()
			end
		end,

		update=function(self)
			if self.createberrytimer >= self.createberryat then
				self.berry=create_berry(self.x, self.y)
				self.createberrytimer=0
			end
			if self.berry ~= nil then
				if self.berry.active == false then
					self.berry=nil
				end
			else 
				self.createberrytimer+=1
			end
		end
	}

	add(entities, bush)
end

function create_pie_queue() 
	pie_queue={
		x=0,
		y=0,
		w=24,
		h=8,
		members={}, -- sprite values 
		sound=02,
		draw=function(self)
			for i, member in ipairs(self.members) do
				x=self.x+i*8
				spr(member, x, self.y)
			end
		end,
		most=function(self)
			local b=0
			local l=0
			local w=0
			for m in all(self.members) do
				if m == 032 then b+=1 end
				if m == 033 then l+=1 end
				if m == 034 then w+=1 end
			end
			if b > l and b > w then
				return "blueberry"
			elseif l > b and l > w then
				return "lemon"
			elseif w > b and w > l then
				return "watermelon"
			else
				return "pumpkin"
			end
		end,
		update=function(self)
			if count(self.members) >= 3 then
					local piename = self:most()
					sfx(self.sound)
					self.members={}

					for e in all(entities) do
						if e.etype == types.pie then
							e.timer=0
							e.piename=piename
						end
					end
			end
		end
	}
	add(entities,pie_queue)
end

function create_pie()
	local pie={
		x=8,
		y=0,
		-- initally set the timer to
		-- the same value as ttl
		-- so that it doesn't get
		-- drawn nor updated
		timer=48,
		ttl  =48,
		etype=types.pie,
		-- sx and sy
		-- indicate where in the sprite
		-- sheet to draw
		sx=40,
		sy=8,
		piename="pumpkin",
		update=function(self)
			if self.timer < self.ttl then
				self.timer+=1
			end
		end,
		draw=function(self)
			if self.timer < self.ttl then
				local mod = 0
				if self.piename=="blueberry" then
					mod = 16
				elseif self.piename=="lemon" then
					mod = 32
				elseif self.piename=="watermelon" then
					mod = 48
				end
				sspr(self.sx+mod,self.sy,16,16,self.x,self.y,self.timer*2,self.timer*2)
				print(self.piename .. " pie", 48, 108)
			end
		end
	}

	add(entities, pie)
end

function create_title_animation() 
	animation={
		x=56,
		y=56,
		sprs={032,033,034},
		ymods={0,1,2},
		timer=0,
		max=48,

		play=function(self)
			n=1
			for s in all(self.sprs) do
				spr(s, self.x+(n-1)*8, self.y+self.ymods[n])
				self.ymods[n]+=1
				if self.ymods[n] > 4 then
					self.ymods[n]=0
				end
				n+=1
			end
			self.timer+=1
		end
	}

	return animation
end

function _init()
	gamestate=states.title
	entities={}
	create_cow(64,64)
	cow=entities[1]
	create_basket()
	basket=entities[2]
	create_bush()
	create_bush()
	create_bush()
	create_bush()
	create_pie_queue()
	create_pie()
	play_music=true
	titleanimation=create_title_animation()
end

function _update()
	if gamestate==states.title then
		if btnp(5)then
			gamestate = states.titletrans
		end

		if btnp(4) then
			gamestate = states.instructions
		end
	elseif gamestate==states.titletrans then
		if play_music then
			sfx(05)
			play_music=false
		end
		if titleanimation.timer > titleanimation.max then
			play_music = true
			gamestate=states.picker
		end
	elseif gamestate==states.instructions then
		if btnp(5) or btnp(4) then
			gamestate = states.titletrans
		end
	elseif gamestate==states.picker then
		if play_music then
			music(0,1000)
			play_music=false
		end
		if btn(⬆️) then
			cow:move("up")
		elseif btn(⬇️) then
			cow:move("down")
		elseif btn(⬅️) then
			cow:move("left")
		elseif btn(➡️) then
			cow:move("right")
		end
		if btnp(❎) then
			local bx = cow.x+8
			local by = cow.y-8
			if cow.facing == "left" then
				bx = cow.x-8
			end
			basket:set(bx, by)
		end
		for e in all(entities) do
			if e.update~=nil then
				e:update()
			end
		end
	end
end

function _draw()
	cls()
	if gamestate==states.title then
		-- glpyhs are wider than normal text
		-- which is why we have the spaces at the 
		-- end of this text
		local title="★★ cow pie ★★   "
		print(title, 64-#title*2, 56)
		print("")
		print("❎ to start the game", 5)
		print("🅾️ for instructions", 5)
	elseif gamestate==states.instructions then
		print("hi cow :3", 0, 16)
		print("im making pies." )
		print("could you please go out")
		print("to the bush garden" )
		print("and pick some fruit for me?" )
		print("after you pick 3 fruits" )
		print("i'll make the pie" )
		print("")
		print("")
		print("⬆️ ⬇️ ⬅️ ➡️ to move")
		print("❎ to collect a fruit")
	elseif gamestate==states.titletrans then
		titleanimation:play()
	elseif gamestate==states.picker then
		map()

		for e in all(entities) do
			if e.etype ~= types.cow or e.etype ~= types.basket then
				e:draw()
			end
		end

		cow:draw()
		basket:draw()
	end

end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07556665075566650755666507556665075566650755666507556665075566650000000000000000000000000000000000000000000000000000000000000000
77765650777656507776565077765650777656507776565077765650777656500000000000000000000000000000000000000000000000000000000000000000
5576eeee557666605576eeee5576eeee5576eeee557666605576eeee5576eeee0000000000000000000000000000000000000000000000000000000000000000
5576e5e55576eeee5576e5e55576e5e55576e5e55576eeee5576e5e55576e5e50000000000000000000000000000000000000000000000000000000000000000
7777eeee7777e5e57777eeee7777eeee7777eeee7777e5e57777eeee7777eeee0000000000000000000000000000000000000000000000000000000000000000
777777007777eeee7777770077777700777777007777eeee77777700777777000000000000000000000000000000000000000000000000000000000000000000
05005000500500000500500050050000050050005005000005005000500550000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000011111000000000009999000000000000999900000000000099990000000000009999000000000000000000000000000000
09900990000000000000000000001333331000000000999999990000000099999999000000009999999900000000999999990000000000000000000000000000
09000090000000000000000000013bbbbb3100000009994499999000000999cc99999000000999aa999990000009998899999000000000000000000000000000
9999999900000000000000000013bbbbbbb3100000994494994499000099cc9c99cc99000099aa9a99aa99000099889899889900000000000000000000000000
484949c90000000000000000013bbbbbbbb3110009994449949499900999ccc99c9c99900999aaa99a9a99900999888998989990000000000000000000000000
949494940000000000000000013bbb3b3bbbb3100994944994499990099c9cc99cc99990099a9aa99aa999900998988998899990000000000000000000000000
494949490000000000000000013bbbb33bbbb310994449944949949999ccc99cc9c99c9999aaa99aa9a99a999988899889899899000000000000000000000000
049494900000000000000000013bbbbbbbbbb3109994499444994999999cc99ccc99c999999aa99aaa99a9999998899888998999000000000000000000000000
0011110000000000000220000113bbb3bbbb3100994994494499499999c99cc9cc99c99999a99aa9aa99a9999989988988998999000000000000000000000000
01cccc10009999000028820000133bb3bbb3b310994994449944949999c99ccc99cc9c9999a99aaa99aa9a999989988899889899000000000000000000000000
1cc1ccc109aaaa9000281200013bb3bb3b3bb31009994944994949900999c9cc99c9c9900999a9aa99a9a9900999898899898990000000000000000000000000
1c111cc19aaaaaa90288882013bbbbbbbbbbbb310994449944944990099ccc99cc9cc990099aaa99aa9aa9900998889988988990000000000000000000000000
1cc1ccc19aaa9aa90281812013bbbbbb3bbbbb3100994499494999000099cc99c9c999000099aa99a9a999000099889989899900000000000000000000000000
1cccccc19aaaa9a913888831013bbb3bb3bbb3100009994499999000000999cc99999000000999aa999990000009998899999000000000000000000000000000
01cccc1009aaaa901333333100133313313331000000999999990000000099999999000000009999999900000000999999990000000000000000000000000000
00111100009999000111111000011101101110000000009999000000000000999900000000000099990000000000009999000000000000000000000000000000
44444444002222000242242000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444024444200224422022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444244224420224422042224422000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444242442420242422024442244000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444242442420242242024422442000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444244224420224242042244224000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444024444200224422022222222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444002222000242422000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222000000000000222200000000000022220000000000002222000000000000222200000000000022220000000000002222000022220000000000
00000000024444202222222202444420222222220244442022222222024444202222222202444420222222220244442022222222024444200244442000000000
00000000244224424222442224422442422244222442244242224422244224424222442224422442422244222442244242224422244224422442244200000000
00000000242442422444224424244242244422442424424224442244242442422444224424244242244422442424424224442244242442422424424200000000
00000000242442422442244224244242244224422424424224422442242442422442244224244242244224422424424224422442242442422424424200000000
00000000244224424224422424422442422442242442244242244224244224424224422424422442422442242442244242244224244224422442244200000000
00000000024444202222222202444420222222220244442022222222024444202222222202444420222222220244442022222222024444200244442000000000
00000000002222000000000000222200000000000022220000000000002222000000000000222200000000000022220000000000002222000022220000000000
00000000024224204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000024224204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000022424204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000002222004444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000024444204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224242000000000
00000000024444204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000002222004444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000024224204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000024224204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000022424204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000002222004444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000024444204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444111111114444440224242000000000
000000000244442044444444444444444444444444444444444444444444444444444444444444444444444444444444133331cccc1444440224422000000000
0000000000222200444444444444444444444444444444444444444444444444444444444444444444444444444444413bbb1cc1ccc144440242422000000000
000000000242242044444444444444411111444444444444444444444444444444444444444444444444444444444413bbbb1c111cc144440022220000000000
00000000022442204444444444444133333144444444444444444444444444444444444444444444444444444444413bbbbb1cc1ccc144440244442000000000
000000000224422044444444444413bbbbb314444444444444444444444444444444444444444444444444444444413bbb3b1cccccc144442442244200000000
00000000024242204444444444413bbbbbbb31444444444444444444444444444444444444444444444444444444413bbbb331cccc1444442424424200000000
0000000002422420444444444413bbbbbbbb31144444444444444444444444444444444444444444444444444444413bbbbbbb11111444442424424200000000
0000000002242420444444444413bbb3b3bbbb3144444444444444444444444444444444444444444444444444444113bbb3bbbb314444442442244200000000
0000000002244220444444444413bbbb33bbbb31444444444444444444444444444444444444444444444444444444133bb3bbb3b31444440244442000000000
0000000002424220444444444413bbbbbbbbbb314444444444444444444444444444444444444444444444444444413bb3bb3b3bb31444440022220000000000
00000000002222004444444444113bbb3bbb2214444444444444444444444444444444444444444444444444444413bbbbbbbbbbbb3144440242242000000000
000000000244442044444444444133bb3bb28821444444444444444444444444444444444444444444444444444413bbbbbb3bbbbb3144440224422000000000
0000000024422442444444444413bb3bb3b281214411111444444444444444444444444444444444444444444444413bbb3bb3bbb31444440224422000000000
000000002424424244444444413bbbbbbb2888821333339999444444444444444444444444444444444444444444441333133133314444440242422000000000
000000002424424244444444413bbbbbb32818121bbbb9aaaa944444444444444444444444444444444444444444444111411411144444440242242000000000
0000000024422442444444444413bbb3b13888831bbb9aaaaaa94444444444444444444444444444444444444444444444444444444444440224242000000000
00000000024444204444444444413331313333331bbb9aaa9aa94444444444444444444444444444444444444444444444444444444444440224422000000000
0000000000222200444444444444111411111111bb3b9aaaa9a94444444444444444444444444444444444444444444444444444444444440242422000000000
000000000242242044444444444444444444413bbbb339aaaa944444444444444444444444444444444444444444444444444444444444440022220000000000
000000000224422044444411111444444444413bbbbbbb9999144444444444444755666544444444444444444444444444444444444444440244442000000000
0000000002244220449999333314444444444113bbb3bbbb31444444444444447776565444444444444444444444444444444444444444442442244200000000
000000000242422049aaaa9bbb314444444444133bb3bbb3b3144444444444445576eeee44444444444444444444444444444444444444442424424200000000
00000000024224209aaaaaa9bbb314444444413bb3bb3b3bb3144444444444445576e5e544444444444444444444444444444444444444442424424200000000
00000000022424209aaa9aa9bbb31144444413bbbbbbbbbbbb314444444444447777eeee44444444444444444444444444444444444444442442244200000000
00000000022442209aaaa9a93bbbb314444413bbbbbb3bbbbb314444444444447777774444444444444444444444444444444444444444440244442000000000
000000000242422049aaaa933bbbb3144444413bbb3bb3bbb3144444444444444544544444444444444444444444444444444444444444440022220000000000
0000000000222200419999bbbbbbb314444444133313313331444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000024444204113bbb3bbbb3144444444411141141114444444444444444444444444444444444444444444444444444444444444440224422000000000
000000002442244244133bb3bbb3b314444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
0000000024244242413bb3bb3b3bb314444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
000000002424424213bbbbbbbbbbbb31444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
000000002442244213bbbbbb3bbbbb31444444444444444444444444444444444444444444444444444444444444444444444444444444440224242000000000
0000000002444420413bbb3bb3bbb314444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000002222004413331331333144444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000024224204441114114111444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000024224204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442424424200000000
00000000022424204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444442442244200000000
00000000022442204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440244442000000000
00000000024242204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440022220000000000
00000000002222004444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000024444204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000242442424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242242000000000
00000000244224424444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224242000000000
00000000024444204444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440224422000000000
00000000002222004444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444440242422000000000
00000000002222000022220000000000002222000000000000222200000000000022220000000000002222000000000000222200000000000022220000000000
00000000024444200244442022222222024444202222222202444420222222220244442022222222024444202222222202444420222222220244442000000000
00000000244224422442244242224422244224424222442224422442422244222442244242224422244224424222442224422442422244222442244200000000
00000000242442422424424224442244242442422444224424244242244422442424424224442244242442422444224424244242244422442424424200000000
00000000242442422424424224422442242442422442244224244242244224422424424224422442242442422442244224244242244224422424424200000000
00000000244224422442244242244224244224424224422424422442422442242442244242244224244224424224422424422442422442242442244200000000
00000000024444200244442022222222024444202222222202444420222222220244442022222222024444202222222202444420222222220244442000000000
00000000002222000022220000000000002222000000000000222200000000000022220000000000002222000000000000222200000000000022220000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03133313331333133313331333131c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03230303030303030303030303031c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03130303030303030303030303032c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03230303030303030303030303031c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03130303030303030303030303032c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03230303030303030303030303031c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03130303030303030303030303032c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03230303030303030303030303031c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03130303030303030303030303032c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03230303030303030303030303031c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03130303030303030303030303032c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c03131333133313331333133313331c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c048484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
4848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848484848
__sfx__
00010000104530c453114531345300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01020000181501c0501f0500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001b35021350183501c35021352213522135200500005000050000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
c91200001d5301d5301d5301d530215302153021530215301d5301d5301d5301d5302253022530225302253021530215302153021530245302453024530245302153021530215302153026530265302653026530
051200000515300000006530000005153006530065300653051530000000653000000515300653006530065309153000000000000653091530000000653006530915300653006530065309153000000065300000
010600001d1301d1301d1301d130211302113021130211301d1301d1301d1301d1302213022130221302213021130211302113021130241302413024130241302113021130211302113026130261302613026130
__music__
02 03044544
