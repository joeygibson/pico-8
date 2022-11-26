pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- adventure game
-- by joeygibson

-- game loop
function _init()
	map_setup()
	text_setup()
	make_player()
	
	game_win=false
	game_over=false
end

function _update()
	if (not game_over) then
		if (not active_text) then
  	update_map()
	  move_player()	 
	  check_win_lose()
	 end
	else
		if (btn(❎)) extcmd("reset")
	end
end

function _draw()
	cls()
	if (not game_over) then
 	draw_map()
	 draw_player()
	 draw_text()
	 if (btn(❎)) show_inventory()
	else
		draw_win_lose()
	end
end

-->8
-- map code
function map_setup()
 -- timers
 timer=0
 anim_time=30 -- 30 = 1 second
 
 -- map tile settings
	wall={3,17,18,19,35,21,22,27,37}
	key={5}
	door={37}
	anim1={8}
	anim2={9}
	text={27}
	lose={8}
	win={11}
	gold={21}
end

function update_map()
	if (timer<0) then
		toggle_tiles()
		timer=anim_time
	end
	timer-=1
end

function draw_map()
	mapx=flr(p.x/16)*16
	mapy=flr(p.y/16)*16
	camera(mapx*8,mapy*8)
	
	map(0,0,0,0,128,64)
end

function is_tile(tile_type,x,y)
	tile=mget(x,y)
	-- return fget(tile,tile_type)	
	for i=1,#tile_type do
		if (tile==tile_type[i]) return true
	end
	
	return false
end

function can_move(x,y)
	return not is_tile(wall,x,y)
end

function swap_tile(x,y)
	tile=mget(x,y)
	mset(x,y,tile+1)
end

function unswap_tile(x,y)
	tile=mget(x,y)
	mset(x,y,tile-1)
end

function get_key(x,y)
	p.keys+=1
	swap_tile(x,y)
	sfx(1)
end

function open_door(x,y)
	p.keys-=1
	swap_tile(x,y)
	sfx(2)
end

function get_gold(x,y)
	p.gold+=5
	swap_tile(x,y)
	sfx(1)
end
-->8
-- player code
function make_player()
	p={}
	p.x=3
	p.y=2
	p.sprite=49
	p.keys=0
	p.gold=0
end

function draw_player()
	-- map coords need to be 
	-- multiplied by 8
	spr(p.sprite,p.x*8,p.y*8)
end

function move_player()
	newx=p.x
	newy=p.y
	
	if (btnp(⬅️)) newx-=1
	if (btnp(➡️)) newx+=1
	if (btnp(⬆️)) newy-=1
	if (btnp(⬇️)) newy+=1
	
	interact(newx,newy)
	
	if (can_move(newx,newy)) then
		p.x=mid(0,newx,127)
		p.y=mid(0,newy,63)
	else
		sfx(0)
	end
end

function interact(x,y)
	if (is_tile(text,x,y)) then
		active_text=get_text(x,y)
	end
	
	if (is_tile(key,x,y)) then
		get_key(x,y)
	elseif (is_tile(door,x,y) and p.keys>0) then
		open_door(x,y)
	elseif (is_tile(gold,x,y)) then
		get_gold(x,y)
	end
end

-->8
-- inventory code
function show_inventory()
	invx=mapx*8+40
	invy=mapy*8+8
	
	rectfill(invx,invy,invx+48,invy+30,0)
	print("inventory",invx+7,invy+4,7)
	print("keys: "..p.keys,invx+12,invy+14,9)
	print("gold: "..p.gold,invx+12,invy+20,9)
end

-->8
-- animation code
function toggle_tiles()
	for x=mapx,mapx+15 do
		for y=mapy,mapy+15 do
			if (is_tile(anim1,x,y)) then
				swap_tile(x,y)
				sfx(3)
			elseif (is_tile(anim2,x,y)) then
				unswap_tile(x,y)
				sfx(3)
			end
		end
	end
end

-->8
-- win/lose code
function check_win_lose()
	if (is_tile(win,p.x,p.y)) then
		game_win=true
		game_over=true
	elseif(is_tile(lose,p.x,p.y)) then
		game_win=false
		game_over=true
	end
end

function draw_win_lose()
	camera()
	if (game_win) then
		print("★ you win! ★",37,64,7)
	else
		print("game over!",38,64,7)
	end
	print("press ❎ to play again",20,72,5)
end
		
-->8
-- text code
function text_setup()
	texts={}
	add_text(0,11,"first sign!")
	add_text(5,11,"oh, look!\na sign!")
end

function add_text(x,y,message)
	texts[x+y*128]=message
end

function get_text(x,y)
	return texts[x+y*128]
end

function draw_text()
	if (active_text) then
		textx=mapx*8+4
		texty=mapy*8+48
		rectfill(textx,texty,textx+119,texty+31,7)
		print(active_text,textx+4,texty+4,1)
		print("press 🅾️ to close",textx+4,texty+23,6)
	end
	
	if (btnp(🅾️)) active_text=nil
end

__gfx__
00000000333333333333333333111333000000003333333333333333000000003333333333333333000000006688886600000000000000000000000000000000
00000000333333333333333331555133000000009993333333333333000000003633363330333033000000006866668600000000000000000000000000000000
00700700333333333bb3333315575513000000009399999933333333000000000603060303030303000000008668866800000000000000000000000000000000
000770003333333333bb33b315557513000000009a9aa9a933333333000000003033303330333033000000008688886800000000000000000000000000000000
0007700033333333333b3bb3125555510000000099933a3a33333333000000003333333333333333000000008688886800000000000000000000000000000000
007007003333333333333b331255755100000000aaa3333333333333000000003633363330333033000000008668866800000000000000000000000000000000
000000003333333333333b3331225513000000003333333333333333000000000603060303030303000000006866668600000000000000000000000000000000
00000000333333333333333333111133000000003333333333333333000000003033303330333033000000006688886600000000000000000000000000000000
00000000111111111111111111111111000000004a4444a4aaa99aaa000000000000000000000000000000004444444400000000000000000000000000000000
000000001111111111c1c1c111555551000000004a4444a44a4994a4000000000000000000000000000000004ffffff100000000000000000000000000000000
00000000111111111c1c1c1111575751000000004a4444a411111111000000000000000000000000000000004f1ff1f100000000000000000000000000000000
00000000111111111111111111515551000000004a4444a411111111000000000000000000000000000000004f1f1ff100000000000000000000000000000000
0000000011111111111111111551751100000000aaa99aaa11111111000000000000000000000000000000004ffffff100000000000000000000000000000000
000000001111111111c1c1c1c2255511000000001a1991a111111111000000000000000000000000000000004111111100000000000000000000000000000000
00000000111111111c1c1c11cc255111000000004944449449444494000000000000000000000000000000003334133300000000000000000000000000000000
0000000011111111111111111cccc111000000004a4444a44a4444a4000000000000000000000000000000003334100300000000000000000000000000000000
00000000666666666666666666656656000000005555555555555555000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666655555555000000005544445555000055000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666656656665666566000000005444444550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666665666666655555555000000005114444550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666656665666000000005444444550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666665665655555555000000005444464550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666566666666656665000000005114444550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000666666666666666655555555000000005444444550000005000000000000000000000000000000000000000000000000000000000000000000000000
00000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099889900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000909999090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000409999040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a00a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000100020000481000800000000000010101000301000000002100000000000000010005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0101010102010101010101010111131101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101030101010201020103052211010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102020103010115010111112201010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010102010101011211010301020101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0501010322220113111101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0102010122111211111301010215010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0301011122112323232323030102010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0111121122222521212123010101010301010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111010102012321212123010201020101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010101012323232323010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0101010201022323111111120101020101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1b020101011b1111111211111111010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808080808081111121113111211010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0801010108081111111311111111010201010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0809090908081113111211121111010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010b0101010101111111110101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400001103000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000500002907000000360703607036070360603605036030360203601000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0006000012050120501d0502905027000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000a6500d650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
