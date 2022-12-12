pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
basket_sprite=1
player_sprite=2
player_x=64
player_y=100

fruits={}
fruit_start=16
fruit_count=6
fruit_interval=16

gravity=1
level=1
points=0

function _init()
	for i=1,level do
		fruit={
			sprite=flr(rnd(fruit_count)+fruit_start),
			x=flr(rnd(120)+5),
			y=i*(-fruit_interval)
		}
		add(fruits,fruit)
	end
end

function _update()
	if btn(0) then player_x-=2 end
	if btn(1) then player_x+=2 end
	
	for fruit in all(fruits) do
		fruit.y+=gravity
		
		if fruit.y+4>player_y-8
		and fruit.y+4<player_y
		and fruit.x+4>player_x
		and fruit.x+4<player_x+8 then
			points+=1
			del(fruits,fruit)
		end
		
		if fruit.y>100 then
			del(fruits,fruit)
		end
	end
	
	if #fruits==0 then
		level+=1
		_init()
	end
end

function _draw()
	cls()
	rectfill(0,108,127,127,3)
	spr(player_sprite,player_x,player_y)
	spr(basket_sprite,player_x,player_y-8)

	for fruit in all(fruits) do
		spr(fruit.sprite,fruit.x,fruit.y)		
	end
	
	print("score="..points)	
end

__gfx__
0000000006666660f055550f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000070000006f0ffff0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070067777775f0ffff0f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700066060605888ff88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000606060d50088880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070066060d0500cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060d0d05500c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000055555500dd00dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055330000000000b0b0b000000b300000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00bb003b0000900000bbb000000b3300000008730099b30000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbb000000a4000f9a9000088338800000807b099b388000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b7bbb000000a400f9a9a40088e888880008887b97a9998800000000000000000000000000000000000000000000000000000000000000000000000000000000
bb7bbb30000a94009a9a49008e7e88820080807b9a99998800000000000000000000000000000000000000000000000000000000000000000000000000000000
b7bbbb3000a94000a9a4940088e88882088887b39999998800000000000000000000000000000000000000000000000000000000000000000000000000000000
3bbbbb30aa9400009a49490008888820b7777b300999988000000000000000000000000000000000000000000000000000000000000000000000000000000000
0333330044400000049490000222220003bbb3000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
