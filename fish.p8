pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
	-- player table
	player = {
		x = 60,
		y = 60,
		w = 0,
		h = 0,
		size = 2,
		sx = 0,
		sy = 0,
		dx = 0,
		dy = 0,
		speed = 0.08,
		flp = false
	}

	player = set_sprite(player)

	-- game settings
	enemies = {}
	max_enemies = 15
	max_enemy_size = 10
	max_enemy_speed = 1
	win_size = 10
	weeds = {
		{x1=4,y1=120,x2=2,y2=101},
		{x1=6,y1=123,x2=8,y2=103},
		{x1=110,y1=125,x2=109,y2=102},
		{x1=121,y1=122,x2=120,y2=104},
		{x1=123,y1=122,x2=125,y2=102},
	}
end

function _update()
	-- player controls
	if btn(⬅️) then player.dx -= player.speed player.flp = true end
	if btn(➡️) then player.dx += player.speed player.flp = false end
	if btn(⬆️) then player.dy -= player.speed end
	if btn(⬇️) then player.dy += player.speed end

	-- player movement
	player.x += player.dx
	player.y += player.dy

	-- screen edges
	if player.x > 127 then player.x = 1 end
	if player.x < 0 then player.x = 126 end
	if player.y + player.h > 120 then
		player.y = 120 - player.h
		player.dy = 0
	end
	if player.y < 0 then
		player.y = 0
		player.dy = 0
	end
	-- enemy update
	create_enemies()

	for enemy in all(enemies) do
		-- movement
		enemy.x += enemy.dx

		-- delete enemies
		if enemy.x > 200
		or enemy.x < -70 then
			del(enemies, enemy)
		end

		-- collide with player
		if collide_obj(player, enemy) then
			-- compare size
			if flr(player.size) > enemy.size then
				-- add to player based on size
				player.size += flr((enemy.size / 2) + .5)/(player.size * 2)

				-- set sprite based on size
				player = set_sprite(player)

				sfx(0)
				del(enemies, enemy)
			else
				sfx(1)
				_init()
			end
		end
	end

	-- win
	if player.size > win_size then
		if btn(4) or btn(5) then _init() end -- reset
	end
end

function _draw()
	cls(12)	-- light blue

	-- sand
	rectfill(0, 120, 127, 127, 15)

	-- seaweed
	for weed in all(weeds) do
		line(weed.x1, weed.y1, weed.x2, weed.y2, 3)
		line(weed.x1 + 1, weed.y1 + 1, weed.x2 + 1, weed.y2 + 1, 11)
	end

	-- rocks
	circfill(8, 120, 5, 13)
	circfill(5, 123, 3, 5)
	circfill(100,122,4,13)
	circfill(122,118,6,6)
	circfill(116,120,3,5)

	-- player
	sspr(player.sx, player.sy, player.w, player.h, player.x, player.y, player.w, player.h, player.flp)
	
	-- enemies
	for enemy in all(enemies) do
		pal(9, enemy.c)
		sspr(enemy.sx, enemy.sy, enemy.w, enemy.h, enemy.x, enemy.y, enemy.w, enemy.h, enemy.flp)
	end
	pal()

	-- player size
	rectfill(2, 3, 22, 10, 0)
	rectfill(2,4,2+(player.size-flr(player.size))*20,9,8)

	-- win
	if player.size > win_size then
		rectfill(0, 55, 127, 75, 10)
		print("congratlations!!!", 28, 56, 1)
		print("you became", 43, 63, 1)
		print("the biggest fish!", 20, 70, 1)
	end
end

function collide_obj(obj, other)
	if other.x + other.w > obj.x
	and other.y + other.h > obj.y
	and other.x < obj.x + obj.w
	and other.y < obj.y + obj.h then
		return true
	end
end

function create_enemies()
	if #enemies < max_enemies then
		-- local variables
		local x = 0		local y = 0
		local dx = 0
		local size = flr(rnd((max_enemy_size+player.size)/2))+1
		local flip = false
		local c = flr(rnd(7)) + 1

		-- random start position
		place = flr(rnd(2))
		if place == 0 then
			-- left
			x = flr(rnd(16) - 64)
			y = flr(rnd(115))
			dx = rnd(max_enemy_speed) + 0.25
			flp = false
		elseif place == 1 then
			-- right
			x = flr(rnd(48) + 128)
			y = flr(rnd(115))
			dx = -rnd(max_enemy_speed) - 0.25
			flp = true
		end

		-- make enemy table
		enemy = {
			sx = 0,
			sy = 0,
			x = x,
			y = y,
			w = 0,
			h = 0,
			c = c,
			dx = dx,
			size = size,
			flp = flp
		}

		-- set sprite based on size
		enemy = set_sprite(enemy)


		-- add it to enemies table
		add(enemies, enemy)
	end
end

function set_sprite(obj)
	if flr(obj.size) <= 1 then
		obj.sx = 0 obj.sy = 0 obj.w = 4  obj.h = 3
	elseif flr(obj.size) == 2 then
			obj.sx = 5 obj.sy = 0 obj.w = 4  obj.h = 4
	elseif flr(obj.size) == 3 then
			obj.sx = 9 obj.sy = 0 obj.w = 6  obj.h = 5
	elseif flr(obj.size) == 4 then
			obj.sx = 15 obj.sy = 0 obj.w = 9   obj.h = 7
	elseif flr(obj.size) == 5 then
			obj.sx = 24 obj.sy = 0 obj.w = 14  obj.h = 9
	elseif flr(obj.size) == 6 then
			obj.sx = 38 obj.sy = 0 obj.w = 14  obj.h = 10
	elseif flr(obj.size) == 7 then
			obj.sx = 52 obj.sy = 0 obj.w = 16  obj.h = 12
	elseif flr(obj.size) == 8 then
			obj.sx = 68 obj.sy = 0 obj.w = 15  obj.h = 15
	elseif flr(obj.size) == 9 then
			obj.sx = 83 obj.sy = 0 obj.w = 19  obj.h = 16
	elseif flr(obj.size) == 10 then
			obj.sx = 102 obj.sy = 0 obj.w = 26  obj.h = 17
	else
			obj.sx = 102 obj.sy = 0 obj.w = 26  obj.h = 17
	end

	return obj
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
