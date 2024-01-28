pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--main loops--

-- ★★★★ s h o o t e r ★★★★

states={
	title=0,
	shooter=1,
	gameover=2,
	win=3,
	debug=3
}

connical_row_value=16
connical_col_value=8

max_enemies=8

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

function create_enemy(row,col)
	assert(row<=8 and row>=0)
	assert(col<=8 and col>=0)

	enemy={
		inital_sprite=sprite,
		sprite=032,
		frames=4,
		frame=rnd(5)-1,
		x=row*connical_row_value,
		y=(col*connical_col_value),
		w=8,
		h=8,
		wait=24,
		waiting=0,
		move=function(self)
			if self.waiting >= self.wait then
				self.y += 1
				if self.y > 120 then 
					self.y = 0
				end
			else 
				self.waiting += 1
			end
		end,
 	fly=function(self)
 		if self.frame > self.frames then
 			self.frame = 0
 		end
 		spr(self.sprite+self.frame, self.x, self.y)
 		self.frame += 1
 	end,
		hit=function(self)
			for p in all(projectiles) do
				if collided(self.x, self.y, self.w, self.h, p.x, p.y, p.w, p.h) then
					create_explosion(self.x+4, self.y+4, 9)
					sfx(02)
					del(projectiles, p)
					del(enemies, self)
				end
			end
		end
		
	}

	add(enemies, enemy)
end

-- based loosely on this 
-- https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
-- returns a sequence of numbers
-- shuffled based on the 
-- give last_value
-- so if you were to input
-- it would give a shuffled sequence 
-- of 0 1 2 3 4 5
function fisher_yates_shuf(last_value)
	assert(last_value>0)
	initial_sequence={}
	final_sequence={}
	for i=0,number_of_enemies-1 do add(initial_sequence, i) end
	while(count(initial_sequence) > 1) do
		index=flr(rnd(count(initial_sequence)))
		n=initial_sequence[index]
		add(final_sequence,n)
		del(initial_sequence,n)
	end
	add(final_sequence, initial_sequence[1])
	return final_sequence
end

function create_enemies() 
	number_of_enemies=flr(rnd(max_enemies))+1
	x_seq=fisher_yates_shuf(number_of_enemies)
	y_seq=fisher_yates_shuf(number_of_enemies)
 assert(count(x_seq) == number_of_enemies)
	assert(count(y_seq) == number_of_enemies)
	for n=1, number_of_enemies do
		create_enemy(x_seq[n], y_seq[n])
	end
end

function create_projectile(x,y,sprite)
	projectile={
		x=x,
		y=y,
		vel=2.5,
		sprite=sprite,
		w=8,
		h=8
	}

	add(projectiles, projectile)

end

function create_explosion(x,y)
	explosion={
		x=x,
		y=y,
		r=4,
		col=blinkcolor.c,
		frame=1,
		frames=4,
		go=true,
		update=function(self)
			if self.frame > self.frames then
				self.go=false
				return
			end
			if self.frame % 3 then 
				self.r+=2
			end
			self.frame += 1
			self.col=blinkcolor.c
		end
	}

	add(explosions, explosion)
end

function _init()

 gamestate=states.title
 
 projectiles={}
 
 pl = {
 	initalsprite=001,
 	sprite=001,
 	frames=4,
 	frame=0,

		w=8,
		h=8,
 
 	x=64,
 	-- y never changes
 	y=120,
 	shootsfx=1,
 
 
 	shoot=function(self)
 		sfx(self.shootsfx)
 		--create a new projectile
 		create_projectile(self.x, self.y, 016)
 	end,
 
 	fly=function(self)
 		-- animation
 		if self.frame > self.frames then
 			self.frame = 0
 		end
 		spr(self.sprite+self.frame, self.x, self.y)
 		self.frame += 1
 	end,
 
 	move=function(self, where)
 		if where == "left" then
 			self.x = mid(0, self.x - 8, 120)
 		end
 		if where == "right" then
 			self.x = mid(0, self.x + 8, 120)
 		end
 	end,

		hit=function(self)
			for e in all(enemies) do
				if collided(self.x, self.y, self.w, self.h, e.x, e.y, e.w, e.h) then
					create_explosion(self.x+4, self.y+4, 9)
					del(projectiles, p)
					gamestate=states.gameover
					play_music=true
				end
			end
		end
 }

	enemies={}

	create_enemies()

	explosions={}

 play_music=true
 
 blinkcolor={
 	c=10,
 	c1=10,
 	c2=9,
 	timetochange=15,
 	timer=0,
 	change=function(self)
 		if self.timer > self.timetochange then
 
 			if self.c == self.c1 then 
 				self.c = self.c2
 			elseif self.c == self.c2 then
 				self.c = self.c1
 			end
 
 			self.timer=0
 
 			return
 		end
 
 		self.timer += 1
 	end
 }
end

function _update()
	-- used in text and
	-- in explosions
	blinkcolor:change()

	if gamestate==states.title then

		if btnp(4) or btnp(5) then
			gamestate=states.shooter
		end

	elseif gamestate==states.shooter then
		if count(enemies) == 0 then
			play_music=true
			gamestate=states.win
		else

			if play_music then
				music(0, 1000, 1)
				play_music=false
			end

			for projectile in all(projectiles) do
				projectile.y -= projectile.vel
				if(projectile.y < 0) then
					del(projectiles, projectile)
				end
			end

			if btnp(⬅️) then pl:move("left") end
			if btnp(➡️) then pl:move("right") end
			print("")
			print(" to move left")

			if btnp(4) or btnp(5) then
				pl:shoot()
			end

			for enemy in all(enemies) do 
				enemy:move()
				enemy:hit()
			end

			pl:hit()

			for exp in all(explosions) do
				exp:update()
			end
		end

	elseif gamestate==states.gameover then
		if play_music then
			music(01, 1)
			play_music=false
		end

		if btnp(4) or btnp(5) then
			_init()
			gamestate=states.shooter
		end

	elseif gamestate==states.win then
		if play_music then
			music(02, 1)
			play_music=false
		end

		if btnp(4) or btnp(5) then
			_init()
			gamestate=states.shooter
		end

	end


end

function _draw()

 cls()

	if gamestate==states.title then

		print("")
		print("")
		print("")
		print("     ★ s h o o t e r ★", 10)
		print("")
		print("g o a l :", 6)
		print("")
		print("shoot all of the stars")
		print("")
		print("c o n t r o l s :")
		print("")
		print("⬅️ to move left")
		print("➡️ to move right")
		print("x/c to shoot a projectile")
		print("")
		print("    ★ press x/c to play ★", blinkcolor.c)

	elseif gamestate==states.shooter then
		
		for projectile in all(projectiles) do
			spr(projectile.sprite, projectile.x, projectile.y)
		end

		pl:fly()

		for enemy in all(enemies) do 
			enemy:fly()
		end

		for e in all(explosions) do
			if e.go then
				circfill(e.x, e.y, e.r, e.col)
			end
		end

	elseif gamestate==states.gameover then

		print("")
		print("")
		print("")
		print("")
		print("")
		print("")
		print("    ★ g a m e  o v e r ★", 10)
		print("")
		print("sorry you died :[",5)
		print("you did a good job tho")
		print("*pats head*")
		print("")
		print(" ★ press x/c to play again ★", blinkcolor.c)

	elseif gamestate==states.win then

		print(" ★ w i n ★", 32, 0, blinkcolor.c)
		print(" ♥ you deserve a pizza ♥ ", 8, 54, 5)
		spr(037, 56, 64)
		print(" ★ press x/c to play again ★", 0, 120, 5)

	elseif gamestate==states.debug then

	end
 
end

__gfx__
00000000000330000003300000033000000330000003300000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000003333000033330000333300003333000033330000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700033bb330033bb330033bb330033bb330033bb33000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700033baab3333baab3333baab3333baab3333baab3300000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700033baab3333baab3333baab3333baab3333baab3300000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700330bb033330bb033330bb033330bb033330bb03300000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000080000000800000000e0000000e000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008000000e8000000e0000000e000000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e0000008e0000008e000000000000000000000080999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000000e80000000000000000000000ee000000e99a8a8a900000000000000000000000000000000000000000000000000000000000000000000000000000000
990aa099990aa099990aa099990aa099990aa0999a884a8900000000000000000000000000000000000000000000000000000000000000000000000000000000
99abba9999abba9999abba9999abba9999abba9998a4884900000000000000000000000000000000000000000000000000000000000000000000000000000000
99abba9999abba9999abba9999abba9999abba999a88a8a900000000000000000000000000000000000000000000000000000000000000000000000000000000
099aa990099aa990099aa990099aa990099aa990984a848900000000000000000000000000000000000000000000000000000000000000000000000000000000
009999000099990000999900009999000099990099a84a9900000000000000000000000000000000000000000000000000000000000000000000000000000000
00099000000990000009900000099000000990000999999000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
351000000215302153091730716302153021530517304163021530215309173071630215302153051730416302153021530917307163021530215305173041630215302153091730716302153021530517304163
000100002d0502d0502c0502c0502b0502b0502a0502905028050250502405023050220502205021050210501f0501f0501d0501c0501b0501b0501a050190501805017050140501105010050100500d0500c050
5f0100000065001650026500465007650086500b6500d6500f6501065010650116501265012650126501265013650146501465015650116500f6500d6500b6500965008650066500465000650006500065006650
011000001d4561c4001f4561c4001c4001a4561c4001c40014400144001440014400144001440014400144000e4000e4000e4000e4000e4000e4000e4000e4000000000000000000000000000000000000000000
331000001705213052150521705217052170521705017050170501705017050170500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
02 00424344
04 03424344
00 04424344

