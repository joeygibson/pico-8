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

   gravity=0.3
   friction=0.85
   
   -- simple camera
   cam_x=0
   
   -- map limits
   map_start=0
   map_end=1024
   
   --- test --------------
   x1r=0 y1r=0 x2r=0 y2r=0
   collide_l="no"
   collide_r="no"
   collide_u="no"
   collide_d="no"
   -----------------------
end



-->8
-- update and draw
function _update()
   player_update()
   player_animate()
   
   -- simple camera
   cam_x=player.x-64+(player.w/2)
   if cam_x<map_start then
   	cam_x=map_start
   end
   if cam_x>map_end-128 then
   	cam_x=map_end-128
   end
   camera(cam_x,0)
end

function _draw()
cls()
 map(0,0)
 spr(player.sp,player.x,player.y,1,1,player.flp)
	
 -- test ---------------
 rect(x1r,y1r,x2r,y2r,7)
 print("⬅️= "..collide_l,player.x,player.y-10)
 print("➡️= "..collide_r,player.x,player.y-16)
 print("⬆️= "..collide_u,player.x,player.y-22)
 print("⬇️= "..collide_d,player.x,player.y-28)
 -- test ---------------
end

-->8
-- collisions

function collide_map(obj,aim,flag)
   -- obj=table needs x,y,w,h
   local x=obj.x local y=obj.y
   local w=obj.w local h=obj.h

   local x1=0 local y1=0
   local x2=0 local y2=0

   if aim=="left" then
      x1=x-1    y1=y
      x2=x      y2=y+h-1
   elseif aim=="right" then
      x1=x+w-1    y1=y
      x2=x+w      y2=y+h-1
   elseif aim=="up" then
      x1=x+2    y1=y-1
      x2=x+w-3  y2=y
   else
      x1=x+2      y1=y+h
      x2=x+w-3    y2=y+h
   end

   --- test ----
   x1r=x1 y1r=y1 
   x2r=x2 y2r=y2
   -------------

   -- pixels to tiles
   x1/=8      y1/=8
   x2/=8      y2/=8

   if fget(mget(x1,y1), flag)
      or fget(mget(x1,y2), flag)
      or fget(mget(x2,y1), flag)
      or fget(mget(x2,y2), flag) then
      return true
   else
      return false
   end
end

-->8
-- player
function player_update()
   -- physics
   player.dy+=gravity
   player.dx*=friction
   
   if btn(⬅️) then
   	player.dx-=player.acc
   	player.running=true
   	player.flp=true
   end
   if btn(➡️) then
   	player.dx+=player.acc
   	player.running=true
   	player.flp=false
   end
   
   -- slide
   if player.running
   	and not btn(⬅️)
   	and not btn(➡️)
   	and not player.falling
   	and not player.jumping then
   		player.running=false
   		player.sliding=true
   end
   
   -- jump
   if btnp(❎)
   	and player.landed then
   	player.dy-=player.boost
   	player.landed=false
   end

			-- check collision up and down
			if player.dy>0 then
				player.falling=true
				player.landed=false
				player.jumping=false
				
				player.dy=limit_speed(player.dy,player.max_dy)
				
				if collide_map(player,"down",0) then
					player.landed=true
					player.falling=false
					player.dy=0
					player.y-=((player.y+player.h+1)%8)-1

     --- test -----------
     collide_d="yes"
    else
     collide_d="no"
     --------------------
				end
			elseif player.dy<0 then
				player.jumping=true
				if collide_map(player, "up", 1) then
					player.dy=0
     --- test -----------
     collide_u="yes"
    else
     collide_u="no"
     --------------------
				end
			end
			
			-- check collision left and right
			if player.dx<0 then
				player.dx=limit_speed(player.dx,player.max_dx)
				
				if collide_map(player, "left", 1) then
					player.dx=0
     --- test -----------
     collide_l="yes"
    else
     collide_l="no"
     --------------------
				end
		 elseif player.dx>0 then
		 	player.dx=limit_speed(player.dx,player.max_dx)
		 	
		 	if collide_map(player,"right", 1) then
		 		player.dx=0

     --- test -----------
     collide_r="yes"
    else
     collide_r="no"
     --------------------
		 	end
		 end
		
		 -- stop sliding
		 if player.sliding then
		 	if abs(player.dx)<.2
		 	or player.running then
		 		player.dx=0
		 		player.sliding=false
		 	end
		 end
		 
   player.x+=player.dx
   player.y+=player.dy
   
   -- limit player to map
   if player.x<map_start then
   	player.x=map_start
   end
   if player.x>map_end-player.w then
   	player.x=map_end-player.w
   end
end

function player_animate()
	if player.jumping then
		player.sp=7
	elseif player.falling then
		player.sp=8
	elseif player.sliding then
		player.sp=9
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=1
			if player.sp>6 then
				player.sp=3
			end
		end
	else -- player idle
		if time()-player.anim>.3 then
			player.anim=time()
			player.sp+=1
			if player.sp>2 then
				player.sp=1
			end
		end
	end
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)	
end





__gfx__
00000000004444400044444000044444000444440004444400044444c0044444c004444400000000000000000000000000000000000000000000000000000000
0000000000ccccc000ccccc00ccccccc0c0ccccc0ccccccc0c0ccccc0cccccccc0cccccc04444400000000000000000000000000000000000000000000000000
007007000cf72f200cf72f20c00ff72fc0cff72fc00ff72fc0cff72f000ff72f0c0ff72f0ccccc00000000000000000000000000000000000000000000000000
000770000cfffff00cfffff0000ffffe000ffffe000ffffe000ffffe000ffffe000ffffecf72f200000000000000000000000000000000000000000000000000
00077000000cc00000cccc000fccc0000fccc0000fccc0000fccc0000000ccc000ccc000cfffef00000000000000000000000000000000000000000000000000
0070070000cccc000f0cc0f0000cc000000cc000000cc000000cc0000000cc0f0f0cccf000ccccf0000000000000000000000000000000000000000000000000
000000000f0cd0f0000cd0000cc0d00000cd00000dd0c00000dc000000000cd0000dcc000f0ccd00000000000000000000000000000000000000000000000000
0000000000c00d0000c00d000000d00000cd00000000c00000dc0000000000cd0000ddc00000ccdd000000000000000000000000000000000000000000000000
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
__gff__
0000000000000000000000000000000003030303030303000000000000000000030303030000000000000000000000000100010001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000003032300000000000000000000000000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000003100310000000000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000003032300000000000000000000000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000003100310000000000000000000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000003032300000000000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000015121412141600000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000003100310000000000000000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0031310000000000000000000000000000000000000000000000000000000000000000003032300000000000000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0031310000000000000000000000000000000000000000000000000000000000000000003100310000000000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000015160000000000000000000000000000000000000000000000000000
0031310000000000003636343436360000000000000000000000000000000000000000003032300000000000000000000000000000000000303000000000000000000000000000000000000000000000000000000000000000000000000000000000000022101010160000000000000000000000000000000000000000000000
0031310000000000000000353500000000000000000000000000000000000000000000003100310000000000000000000000000000000030300000000000000000000000000000000000000000000000000000000000000000000000000000000000000022222222221016000000000000000000000000000000000000000000
0031310000343634000000353500000000000000000000000000000000000000000000003032300000000000000000000000000000003030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222000000000000000000000000000000000000000000
0031310000350035000032303032000000000000000000000000000032003030003200003100310000000000000030300000000000303000000000000000303000003232000032323200003200003030000000323232000032323200000030300000000000000000000000000000303000000000000000000000000000003030
0031310000151635000000313100000000000000000000000000000000003131000000003032300000000000000031310000000030300000000000000000313100000000000000000000000000003131000000000000000000000000000031310000000000000000000000000000313100000000000000000000000000003131
0031310015232210160000313100000015131313131316000000000000003131000000003100310000000000000031310000003030000000000000000000313100000000000000000000000000003131000000000000000000000000000031310000000000000000000000000000313100000000000000000000000000003131
1010101110111012101210141014101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
2020212023202121202123202120202221202020202020202020202020202020212020202020202020202020202020202120202020202020202020202020202021202020202020202020202020202020212020202020202020202020202020202120202020202020202020202020202021202020202020202020202020202020
