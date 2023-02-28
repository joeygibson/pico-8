pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- lander
-- sort of by joeygibson

function _init()
  game_over=false
  win=false
  g=0.025 -- gravity
  make_player()
  make_ground()
  make_stars()
end

function _update()
  if not game_over then
     move_player()
     check_land()
  else
     if (btn(5)) _init()
  end
end

function _draw()
  cls()
  draw_stars()
  draw_ground()
  draw_player()

  if game_over then
     if win then
        print("you win!",48,48,11)
     else
        print("too bad!",48,48,8)
     end
     print("press ❎ to play again",20,70,5)
  end
end

-->8
function make_player()
  p={}
  p.x=60                       -- position
  p.y=8
  p.dx=0                       -- movement
  p.dy=0
  p.sprite=1
  p.alive=true
  p.thrust=0.075
end

function draw_player()
  spr(p.sprite,p.x,p.y)
  if game_over and win then
     spr(4,p.x,p.y-8) -- flag
  elseif game_over then
     spr(5,p.x,p.y)   -- explosion
  end
end

function move_player()
  p.dy+=g    -- add gravity

  thrust()

  p.x+=p.dx  -- actually move player
  p.y+=p.dy

  stay_on_screen()
end

function thrust()
  -- add thrust to movement
  if (btn(0)) p.dx-=p.thrust
  if (btn(1)) p.dx+=p.thrust
  if (btn(2)) p.dy-=p.thrust

  -- thrust sound
  if (btn(0) or btn(1) or btn(2)) sfx(0)

end

function stay_on_screen()
  if p.x<0 then     -- left side
     p.x=0
     p.dx=0
  end
  if p.x>119 then   -- right side
     p.x=119
     p.dx=0
  end
  if p.y<0 then     -- top side
     p.y=0
     p.dy=0
  end
end

function make_stars()
  -- create a table of random stars
  stars={}
  for i=1,50 do
     star={x=rndb(0,127),y=rndb(0,127),c=rndb(5,7)}
     add(stars, star)
  end
end

function draw_stars()
  for star in all(stars) do
     pset(star.x,star.y,star.c)
  end
end

function make_ground()
  -- create the ground
  gnd={}
  local top=96   -- hightest point
  local btm=120  -- lowest point

  -- set the landing pad
  pad={}
  pad.width=15
  pad.x=rndb(0,126-pad.width)
  pad.y=rndb(top,btm)
  pad.sprite=2

  -- create ground at pad
  for i=pad.x,pad.x+pad.width do
     gnd[i]=pad.y
  end

  -- create ground right of pad
  for i=pad.x+pad.width+1,127 do
     local h=rndb(gnd[i-1]-3,gnd[i-1]+3)
     gnd[i]=mid(top,h,btm)
  end

  -- create ground left of pad
  for i=pad.x-1,0,-1 do
     local h=rndb(gnd[i+1]-3,gnd[i+1]+3)
     gnd[i]=mid(top,h,btm)
  end
end

function draw_ground()
  for i=0,127 do
     line(i,gnd[i],i,127,5)
  end
  spr(pad.sprite,pad.x,pad.y,2,1)
end

function check_land()
  l_x=flr(p.x)     -- left side of ship
  r_x=flr(p.x+7)   -- right side of ship
  b_y=flr(p.y+7)   -- bottom of ship

  over_pad=l_x>=pad.x and r_x<=pad.x+pad.width
  on_pad=b_y>=pad.y-1
  slow=p.dy<1

  if over_pad and on_pad and slow then
     end_game(true)
  elseif over_pad and on_pad then
     end_game(false)
  else
     for i=l_x,r_x do
        if gnd[i]<=b_y then
           end_game(false)
        end
     end
  end
end

function end_game(won)
  game_over=true
  win=won

  if win then
     sfx(1)
  else
     sfx(2)
  end
end

-->8
function rndb(low,high)
  return flr(rnd(high-low+1)+low)
end



__gfx__
0000000000666600761dddddddddd766000000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066c76607666666666666666000000000899998000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070066ccc766007666666666660000000000899aa99800000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700066cccc660000000000000000000b600089aaaa9800000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700066555566000000000000000000bb600089aaaa9800000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000666666000000000000000000bbb6000899aa99800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000050550500000000000000000000060000899998000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000660660660000000000000000000060000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000070000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000700000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000050000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500060000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000007000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000666600000060000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000600000000000066c7660000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000066ccc766000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000066cccc66000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000000000000000066555566000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000006666660000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000005055050000000000000000000000000000000000000000000000000000000006000
00000000000000000000000000000000000000000000000000000000000066066066000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000
00000000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000060000000000000050000000000000000000000000000000000000050000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000060000000000000000000000000000000005000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000005000000000000000000000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000077000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055505
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000055555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555
00000000000000000000000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000005555555555
00000000000050505000000000000000000000000000000000000000000000005000000000050000000000000505000000000000000000000000005555555555
00000000000050505550000000000000000000000000000000000000000000005000000000050000500000005555000000000000000000000000005555555555
00005000505055505550000000000000000000000000000000000000000000005500000005050000500000505555500000000000000000000000055555555555
00005005555555555550000055000000000000000000000000000000000050555500000005555005500005505555500000000000000000000000055555555555
00005055555555555555500055005000000000000000000000000000000050555555505055555005550005555555550000000000000000000000055555555555
0005555555555555555555555500500005500000000000000000000000055055555550505555555555000555555555761dddddddddd766000000555555555555
00055555555555555555555555505000555000000000000000000000000555555555505055555555550055555555557666666666666666005000555555555555
05555555555555555555555555555500555500000000000000000000505555555555555555555555555555555555555576666666666655555550555555555555
05555555555555555555555555555505555500050005005000000000505555555555555555555555555555555555555555555555555555555555555555555555
05555555555555555555555555555555555555550005505000500050505555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555550005505000550055555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555055555500550055555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555055555505555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555

__sfx__
000600001003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001d0701d0301a0701a03016070160301f0701f030000001b0701e0701e030000000000000000140001400000000000000d000000000000000000000000000000000000000000000000000000000000000
000400003f070350602f0502704024040200301d0301a0301702014020110200e0200c01009010070100401002010010100000000000000000000000000000000000000000000000000000000000000000000000
