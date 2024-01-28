pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main loops--

-- ✽ b o x ✽ m o o v e r ✽ --
-- a cute skinned soko-ban --

states={
	-- game states
	title=0,
	instructions=1,
	titletrans=2,
	moover=3,
	changelvl=4,
	win=5,

	-- entity states
	up=6,
	down=7,
	left=8,
	right=9,

	-- misc
	debug=255
}

function startmusic() 
	if not music_playing then
		music(0)
		music_playing = true
	end
end

function stopmusic()
	if music_playing then
		music(-1)
		music_playing = false
	end

end


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

function create_box(x,y)
	assert(x>=0 and x<=128)
	assert(y>=0 and y<=128)
	box={
		-- position
		x=x,
		y=y,
		w=8,
		h=8,
		a=8,

		-- inital position
		ix=x,
		iy=y,

		sprite=033,
		ontarget=false,
		move=function(self, which)
			local canmove=true 

			if which==states.up then

				local nxt = self.y - self.a

				for wall in all(walls) do
					if collided(self.x, nxt, self.w, self.h, wall.x, wall.y, wall.w, wall.h) then
						canmove=false
						break
					end
				end

				for box in all(boxes) do 
					if collided(self.x, nxt, self.w, self.h, box.x, box.y, box.w, box.h) then
						canmove=false
						break
					end
				end

				for trg in all(targets) do 
					if collided(self.x, nxt, self.w, self.h, trg.x, trg.y, trg.w, trg.h) then
						sfx(03)
					end
				end

				if canmove then self.y = nxt end

				return canmove

			elseif which==states.down then

				local nxt = self.y + self.a

				for wall in all(walls) do
					if collided(self.x, nxt, self.w, self.h, wall.x, wall.y, wall.w, wall.h) then
						canmove=false
						break
					end
				end

				for box in all(boxes) do 
					if collided(self.x, nxt, self.w, self.h, box.x, box.y, box.w, box.h) then
						canmove=false
						break
					end
				end

				for trg in all(targets) do 
					if collided(self.x, nxt, self.w, self.h, trg.x, trg.y, trg.w, trg.h) then
						sfx(03)
					end
				end

				if canmove then self.y = nxt end

				return canmove

			elseif which==states.right then

				local nxt = self.x + self.a

				for wall in all(walls) do
					if collided(nxt, self.y, self.w, self.h, wall.x, wall.y, wall.w, wall.h) then
						canmove=false
						break
					end
				end

				for box in all(boxes) do 
					if collided(nxt, self.y, self.w, self.h, box.x, box.y, box.w, box.h) then
						canmove=false
						break
					end
				end

				for trg in all(targets) do 
					if collided(nxt, self.y, self.w, self.h, trg.x, trg.y, trg.w, trg.h) then
						sfx(03)
					end
				end

				if canmove then self.x = nxt end

				return canmove

			elseif which==states.left then

				local nxt = self.x - self.a

				for wall in all(walls) do
					if collided(nxt, self.y, self.w, self.h, wall.x, wall.y, wall.w, wall.h) then
						canmove=false
						break
					end
				end

				for box in all(boxes) do 
					if collided(nxt, self.y, self.w, self.h, box.x, box.y, box.w, box.h) then
						canmove=false
						break
					end
				end

				for trg in all(targets) do 
					if collided(nxt, self.y, self.w, self.h, trg.x, trg.y, trg.w, trg.h) then
						sfx(03)
					end
				end

				if canmove then self.x = nxt end

				return canmove

			end

			return canmove
		end,
		show=function(self)
			self.ontarget=false
			for t in all(targets) do
				self.ontarget=collided(self.x, self.y, self.w, self.h, t.x, t.y, t.w, t.h)
				if self.ontarget then break end
			end
			pal()
			if self.ontarget then
				pal(4,14)
				pal(2,8)
				pal(9,10)
			end
			spr(self.sprite, self.x, self.y)
		end
	}

	add(boxes, box)
end

function create_cow(x,y)
	assert(x>=0 and x<=128)
	assert(y>=0 and y<=128)

	cow={

		-- assets
		sprite=001,
		moosound=00,

		--position
		x=x,
		y=y,
		w=8,
		h=8,
		a=8,

		--inital position
		ix=x,
		iy=y,

		--state
		mootime=20,
		moomax=5,

		--action
		show=function(self)
			spr(self.sprite, self.x, self.y)
		end,
		move=function(self, which)

			boxcanmove=true

			if which==states.up then

				nxt = self.y - self.a

				canmove=true

				for wall in all(walls) do
					if collided(cow.x, nxt, cow.w, cow.h, wall.x, wall.y, wall.w, wall.h) then
						canmove = false
						break
					end
				end

				for box in all(boxes) do
					if collided(cow.x, nxt, cow.w, cow.h, box.x, box.y, box.w, box.h) then
						canmove=box:move(which)
						break
					end
				end

				if canmove then
					self.y = nxt
				end

			elseif which==states.down then
				nxt = self.y + self.a

				canmove=true

				for wall in all(walls) do
					if collided(cow.x, nxt, cow.w, cow.h, wall.x, wall.y, wall.w, wall.h) then
						canmove = false
						break
					end
				end

				for box in all(boxes) do
					if collided(cow.x, nxt, cow.w, cow.h, box.x, box.y, box.w, box.h) then
						canmove=box:move(which)
						break
					end
				end

				if canmove then
					self.y = nxt
				end

			elseif which==states.right then

				nxt = self.x + self.a

				canmove=true

				for wall in all(walls) do
					if collided(nxt, cow.y, cow.w, cow.h, wall.x, wall.y, wall.w, wall.h) then
						canmove = false
						break
					end
				end

				for box in all(boxes) do
					if collided(nxt, cow.y, cow.w, cow.h, box.x, box.y, box.w, box.h) then
						canmove=box:move(which)
						break
					end
				end

				if canmove then
					self.x = nxt
				end

			elseif which==states.left then

				nxt = self.x - self.a

				canmove=true

				for wall in all(walls) do
					if collided(nxt, cow.y, cow.w, cow.h, wall.x, wall.y, wall.w, wall.h) then
						canmove = false
						break
					end
				end

				for box in all(boxes) do
					if collided(nxt, cow.y, cow.w, cow.h, box.x, box.y, box.w, box.h) then
						canmove=box:move(which)
						break
					end
				end

				if canmove then
					self.x = nxt
				end
			end

		end,
		moo=function(self)
			if(self.mootime >= self.moomax) then
				sfx(self.moosound)
				self.mootime=0
			end
		end
	}
end

function create_target(x,y)
	assert(x>=0 and x<=128)
	assert(y>=0 and y<=128)
	target={
		x=x,
		y=y,
		w=8,
		h=8,
		sprite=048
	}

	add(targets, target)
end

function create_wall(x,y,sprite)
	assert(x>=0 and x<=128)
	assert(y>=0 and y<=128)
	wall={
		x=x,
		y=y,
		w=8,
		h=8,
		sprite=sprite
	}

	add(walls,wall)
end

-- load is based on the global
-- value "lvl"
function loadlvl()

	cow={}
	boxes={}
	walls={}
	targets={}

	chunk=16 -- based on pico8 map
	block=8 -- everythings 8x8 
	start=lvl*chunk*block
	final=start+chunk*block

	assert(start <=  (96 * block))
	assert(final <= (128 * block))

	for y=0,128,block do

		for x=start,final,block do

			local chunkx=x/block
			local chunky=y/block

			x1 = x - (128 * lvl)

			sprite=mget(chunkx, chunky)

			if sprite==033 then
				create_box(x1,y)
				mset(chunkx,chunky,003)
			elseif sprite==001 then
				create_cow(x1,y)
				mset(chunkx,chunky,003)
			elseif sprite==017 or sprite==018 then
				create_wall(x1,y,sprite)
				mset(chunkx,chunky,003)
			elseif sprite==048 then
				create_target(x1,y)
				mset(chunkx,chunky,003)
			end

		end

	end

end

function resetlvl()
	cow.x=cow.ix
	cow.y=cow.iy
	for box in all(boxes) do
		box.x=box.ix
		box.y=box.iy
	end
end

function _init()
	gamestate=states.title

	music_playing = false
	
	lvl=0
	maxlvl=4

	loadlvl()
end

function _update()

	if gamestate == states.title then
		startmusic()

		if btnp(5)then
			gamestate = states.titletrans
		end

		if btnp(4) then
			gamestate = states.instructions
		end

	elseif gamestate == states.instructions then
		if btnp(❎) or btnp(5) then
			gamestate = states.titletrans
		end
	elseif gamestate == states.titletrans then
		stopmusic()	
		gamestate = states.moover
	elseif gamestate == states.moover then
		menuitem(1, "reset lvl", function() resetlvl() end)

		if btnp(⬆️) then cow:move(states.up) 
		elseif 
			btnp(⬇️) then cow:move(states.down)
		elseif 
			btnp(⬅️) then cow:move(states.left)
		elseif 
			btnp(➡️) then cow:move(states.right)
		end

		if btnp(❎) then
			cow:moo()
		end

		cow.mootime = mid(0, cow.mootime + 1, cow.moomax)

		local ontarget_count = 0
		for box in all(boxes) do
			if box.ontarget then
				ontarget_count+=1
			end
		end

		if ontarget_count==count(targets) then
			gamestate=states.changelvl
		end

		if lvl > maxlvl then
			gamestate=states.win
		end
	elseif gamestate==states.changelvl then
		lvl += 1
		loadlvl()
		gamestate = states.moover
		if lvl > maxlvl then
			gamestate=states.win
		end
	end


end

function _draw()
 cls()

	if gamestate == states.title then
		print("⌂ b o x ⌂ m o o v e r ⌂", 8, 56, 6)
		print("")
		print("❎ to start the game", 5)
		print("🅾️ for instructions", 5)
	elseif gamestate == states.instructions then
		print("heya cow!", 6)
		print("")
		print("thanks for helping me move :)")
		print("")
		print("boxes go onto the lil targets")
		print("")
		print("⬆️ ⬇️ ⬅️ ➡️ to move")
		print("")
		print("❎ to moo")
	elseif gamestate == states.moover then
		map(lvl*16,0)
		print("lvl " .. lvl)
		for target in all(targets) do
			spr(target.sprite, target.x, target.y)
		end
		for box in all(boxes) do
			box:show()
		end
		pal()
		for wall in all(walls) do
			spr(wall.sprite, wall.x, wall.y)
		end
		cow:show()
	elseif gamestate == states.win then
		print("    ♥ thanks for playing ♥", 0, 58, 6)
	end

end

__gfx__
000000000777700000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007556665500000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007007765656000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005766666000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005766eeee00000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007007777e5e500000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000007777eeee00000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005005000000000000ffffffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226226222622226200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666226222622226200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226226666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226226222226222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226666222226222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000666226226666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226226662622226200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000226226222622226200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000499999940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000922222290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000942442290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000924424290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000944244290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000942442290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000924424290000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000499999940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffeeeeff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
feffffef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
effeeffe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
efeffefe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
efeffefe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
effeeffe000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
feffffef000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffeeeeff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000111212121100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000110103031100000000000000000000000000000000000000000000000000000000000000111212121212110000000000000000000012121212120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001212120000000000000000110321211100121212000000000000000000001112121212121100000000000000000011110303110301110000000000000000001203030303120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001130110000000000000000110321031100113011000000000000000000001103030303031112110000000000000011030303110303110000000000000000120303032103120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001103121212120000000000111212031112113011000000000000000000111121121212030303110000000000000011210321032103110000000000000012030303211203120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012121221032130110000000000001112030303033011000000000000000000110301032103032103110000000000000011032112110303110000000000000012010321031130120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000011300321011212120000000000001103030311030311000000000000000000110330301103210311110000000000111211032103110311110000000000000012030303031230120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000012121212211100000000000000001103030311121212000000000000000000111130301103030311000000000000113030303030030311000000000000000012121212121230120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000011301100000000000000001112121211000000000000000000000000001212121212121212000000000000111212121212121211000000000000000000000000000012120000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000012121200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010700000416204172041550413300100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01180000184321c4221f4121c447184301f4201c420184201c4321f422234121f4471c430234201f4201c4201f43223422264121f4472343026420214201f4201d4201c4201a4201842018411184111841118411
910200001515313153131530f1630d163000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0904000024056280502b0502d05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 01424344

