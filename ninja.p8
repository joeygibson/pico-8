pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- variables
function _init()
	player={
		sp=1,
		x=59,
		y=59,
		w=8,
		h=8,
		flp=false,
		dx=0,
		dy=0,
		max_dx=2,
		max_dy=2,
		acc=0.5,
		boost=4,
		anim=0,
		running=false,
		jumping=false,
		falling=false,
		sliding=false,
		landed=false,
	}	
end

function _draw() 
 cls()
 map(0,0)
 spr(player.sp,plauyer.x,player.y,1,1,player.flp)
end

__gfx__
00000000004444400044444000044444000444440004444400044444000444440000000000000000000000000000000000000000000000000000000000000000
0000000000ccccc000ccccc00ccccccc0c0ccccc0ccccccc0c0ccccc00cccccc0444440000000000000000000000000000000000000000000000000000000000
007007000cf72f200cf72f20c00ff72fc0cff72fc00ff72fc0cff72f0c0ff72f0ccccc0000000000000000000000000000000000000000000000000000000000
000770000cfffff00cfffff0000ffffe000ffffe000ffffe000ffffec00ffffecf72f20000000000000000000000000000000000000000000000000000000000
00077000000cc00000cccc000fccc0000fccc0000fccc0000fccc00000ccc000cfffef0000000000000000000000000000000000000000000000000000000000
0070070000cccc000f0cc0f0000cc000000cc000000cc000000cc0000f0cc00000ccccf000000000000000000000000000000000000000000000000000000000
000000000f0cd0f0000cd0000cc0d00000cd00000dd0c00000dc000000dc00000f0ccd0000000000000000000000000000000000000000000000000000000000
0000000000c00d0000c00d000000d00000cd00000000c00000dc00000dc000000000ccdd00000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000
3bbb3bbb3bbb3bbb3b333bb33bbbbbb3bbbbb33b00bbb434434bbb00000000000000000000000000000000000000000000000000000000000000000000000000
33b333433bb33bbb33443bb433bbbb4433bbb3430bbb34444443bbb0000000000000000000000000000000000000000000000000000000000000000000000000
4b3444343bb343b3444443b4444bb44443bb3444bbb3344444433bbb000000000000000000000000000000000000000000000000000000000000000000000000
4b34a4443b342434444444344944b444443b3444bb344444444443bb000000000000000000000000000000000000000000000000000000000000000000000000
4344444443444444444449444444444444434424b34444244244443b000000000000000000000000000000000000000000000000000000000000000000000000
4444442444444d44444444444445444449444444bb344444444443bb000000000000000000000000000000000000000000000000000000000000000000000000
449444444944444444d444f4444444444444e4443344e444444e4433000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444464444444444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444944444444944444944444444a444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444444444444744000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444444444444444b44494444774000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
444446444444444446d4444444447644000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4444444444c44444466d444444776444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4e444444444444444444444444474444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333003bb3003333333300000000333333330039930033333333000000000000000000000000000000000000000000000000000000000000000000000000
bbb3bbbb003bb300bbb3bbbb003bb300999399990039930099939999003993000000000000000000000000000000000000000000000000000000000000000000
bb3bbbbb0033b300bb3bbbbb003bb300993999990033930099399999003993000000000000000000000000000000000000000000000000000000000000000000
33333333003bb3003333333300333300333333330039930033333333003333000000000000000000000000000000000000000000000000000000000000000000
b3bbbb3b003bb300b3bbbb3b003bb300939999390039930093999939003993000000000000000000000000000000000000000000000000000000000000000000
bb3bbb3b003b3300bb3bbb3b003bb300993999390039330099399939003993000000000000000000000000000000000000000000000000000000000000000000
33333333003bb30033333333003bb300333333330039930033333333003993000000000000000000000000000000000000000000000000000000000000000000
00333300003bb30000000000003bb300003333000039930000000000003993000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000003636343436360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000353500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000353500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000032303032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000151600000000313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015232210160000313100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101110111012101210141014101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020212023202121202123202120202200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000