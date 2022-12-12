pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- init
function _init()
	-- colors
	black = 0
	dblue = 1
	purple = 2
	dgreen = 3
	brown = 4
	dgray = 5
	gray = 6
	white = 7
	red = 8
	orange = 9
	yellow = 10
	green = 11
	blue = 12
	indigo = 13
	pink = 14
	peach = 15
	
	-- player table
	player={
		x=60,
		y=60,
		c=green,
		c2=dgreen,
		r=2,
		dx=0,
		dy=0,
		speed=0.08,
		eat=0
	}
	
	-- game settings
	enemies={}
	max_enemies=15
	max_enemy_size=10
	enemy_speed=0.6
	win_amount=500
end

function _update()
	-- player controls
	if btn(⬅️) then player.dx-=player.speed end
	if btn(➡️) then player.dx+=player.speed end
	if btn(⬆️) then player.dy-=player.speed end
	if btn(⬇️) then player.dy+=player.speed end

	-- player movement
	player.x+=player.dx
	player.y+=player.dy

	-- flip sides
	if player.x>127 then player.x=1 end
	if player.x<0 then player.x=126 end
	if player.y>127 then player.y=1 end
	if player.y<0 then player.y=126 end

	-- enemy update
	create_enemies()

	for enemy in all(enemies) do
		-- movement
		enemy.x+=enemy.dx
		enemy.y+=enemy.dy

		-- outside screen
		if enemy.x>137
		or enemy.x< -10
		or enemy.y< -10
		or enemy.y>137 then
			del(enemies,enemy)
		end

		-- collide with player
		if circ_collision(player.x,player.y,player.r,enemy.x,enemy.y,enemy.r) then
			-- compare size
			if flr(player.r)>enemy.r then
				player.eat+=1
				player.r+=.2
				sfx(0)
				del(enemies,enemy)
			else
				sfx(1)
				_init()
			end
		end
	end
end

function _draw()
	cls()

	-- player
	circfill(player.x,player.y,player.r,player.c)
	circ(player.x,player.y,player.r+1,player.c2)

	-- enemies
	for enemy in all(enemies) do
		circfill(enemy.x,enemy.y,enemy.r,enemy.c)
		circ(enemy.x,enemy.y,enemy.r+1,enemy.c2)
	end

	-- score
	rectfill(0,3,20,10,black)
	print(".="..player.eat,0,5,white)

	-- win
	if player.eat>win_amount then
		rectfill(0,55,127,75,dgray)
		print("congratulations!!!",28,56,blue)
		print("you became",43,63,blue)
		print("a multicelled organism",20,70,blue)
	end
end

function circ_collision(x1,y1,r1,x2,y2,r2)
	distsq=(x1-x2)*(x1-x2)+(y1-y2)*(y1-y2)
	rsumsq=(r1+r2)*(r1+r2)

	if distsq==rsumsq then
		-- circles touch
		return false
	elseif distsq>rsumsq then
		-- circles do not touch
		return false
	else
		-- circles overlap
		return true
	end
end

function create_enemies()
	if #enemies<max_enemies then
		-- local variables
		local x = 0		local y = 0
		local dx = 0  local dy = 0
		local r = flr(rnd((max_enemy_size+player.r)/2))+1
		local c = 0 	local c2 = 0

		-- random start position
		place = flr(rnd(4))
		if place == 0 then
			--left
			x = flr(rnd(8)-16)
			y = flr(rnd(128))
			dx = rnd(enemy_speed)
			dy = rnd(enemy_speed*2) - enemy_speed
		elseif place==1 then
			--right
			x = flr(rnd(8)+128)
			y = flr(rnd(128))
			dx = -rnd(enemy_speed) - enemy_speed
			dy = rnd(enemy_speed*2) - enemy_speed
		elseif place==2 then
			--top
			x = flr(rnd(128))
			y = flr(rnd(8)-16)
			dx = rnd(enemy_speed*2) - enemy_speed
			dy = rnd(enemy_speed)
		elseif place==3 then
				--bottom
			x = flr(rnd(128))
			y = flr(rnd(8)+128)
			dx = rnd(enemy_speed*2) - enemy_speed
			dy = rnd(enemy_speed) - enemy_speed
		end

		-- size determines color
		if r==1 then
			c = yellow c2 = orange
		elseif r == 2 then
			c = gray c2 = white
		elseif r == 3 then
			c = orange c2 = brown
		elseif r == 4 then
			c = pink c2 = brown
		elseif r == 5 then
			c = purple c2 = dblue
		elseif r == 6 then
			c = red c2 = purple
		elseif r == 7 then
			c = white c2 = gray
		elseif r == 8 then
			c = blue c2 = dblue
		elseif r == 9 then
			c = dblue c2 = blue
		elseif r == 10 then
			c = dgreen c2 = green
		else
			c = red c2 = blue
		end

		-- make enemy table
		local enemy = {
			x = x,
			y = y,
			dx = dx,
			dy = dy,
			r = r,
			c = c,
			c2 = c2
		}
		
		--add it to enemies table
		add(enemies,enemy)
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000300000050010530005000b5400050005550005000b540005001855000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
00040000000001555015550145500000000000000000e5500d5500e55000000000000755006550065500000006520065300554005550065500655004550025500055000550000000000000000000000000000000
