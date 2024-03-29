pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
function _init()
	t=0
	dpal={0,1,1,2,1,13,6,4,4,9,3,13,1,13,14}
	dir_x={-1,1,0,0,1,1,-1,-1}
	dir_y={0,0,-1,1,-1,1,1,-1}

	mob_ani={240,192}
	mob_atk={1,1}
	mob_hp={5,2}
	mob_los={4,4}
	itm_name={"broad sword","leather armor","red bean paste","ninja star","rusty sword"}
	itm_type={"wep","arm","fud","thr","wep"}
	itm_stat1={2,0,1,1,1}
	itm_stat2={0,2,0,0,0}

	crv_sig={0b11111111,0b11010110,0b01111100,0b10110011,0b11101001}
	crv_msk={0,0b00001001,0b00000011,0b00001100,0b00000110}

	debug={}
	start_game()
end

function _update60()
	t+=1
	_upd()
	do_floats()
	do_hp_win()
end

function _draw()
	_drw()
	draw_wind()
	-- fadeperc=0
	check_fade() 
	cursor(4,4)
	color(8)
	for txt in all(debug) do
		print(txt)
	end
end

function start_game()
	fadeperc=1
	butt_buf=-1
	skip_ai=false
	win=false
	win_floor=9
	mob={}
	dmob={}
	p_mob=add_mob(1,1,1)
	p_t=0

	inv,eqp={},{}
	-- inv[1-6] == inventory
	-- eqp[1] == weapon, eqp[2] == armor
	-- take_item(1)
	
	wind={}
	float={}
	talk_wind=nil
	fog=blankmap(0) -- 1 == fog, 0 == clear
	hp_wind=add_wind(5,5,28,13,{})
	thr_dx,thr_dy=0,-1

	_upd=update_game
	_drw=draw_game

	gen_floor(0)
	unfog()
end

-->8
-- updates
function update_game()
	if talk_wind then
		if get_butt()==5 then
			talk_wind.dur=0
			talk_wind=nil
		end
	else
		do_butt_buff()
		do_butt(butt_buf)
		butt_buf=-1
	end
end

function update_inv()
	move_mnu(cur_wind)
	if btnp(4) then
		if cur_wind==inv_wind then
			_upd=update_game
			inv_wind.dur=0
			stat_wind.dur=0
		elseif cur_wind==use_wind then
			use_wind.dur=0
			cur_wind=inv_wind
		end
	elseif btnp(5) then
		if cur_wind==inv_wind and inv_wind.cur!=3 then
			show_use()
		elseif cur_wind==use_wind then
			trig_use()
		end
	end
end

function update_throw()
	local b=get_butt()
	if b>=0 and b<=3 then
		thr_dx=dir_x[b+1]
		thr_dy=dir_y[b+1]
	end
	if b==4 then
		-- cancel
		_upd=update_game
	elseif b==5 then
		-- actually throw
		throw()
	end
end

function move_mnu(wnd)
	if btnp(2) then
		wnd.cur-=1
	elseif btnp(3) then
		wnd.cur+=1
	end
	wnd.cur=(wnd.cur-1)%#wnd.txt+1
end

function update_pturn()
	do_butt_buff()
	p_t=min(p_t+0.125,1)

	if p_mob.mov then
		p_mob:mov()
	end

	if p_t==1 then
		_upd=update_game

		local tle=mget(p_mob.x, p_mob.y)
		if trig_step() then return end

		if check_end() and not skip_ai then
			do_ai()
		end

		skip_ai=false
	end
end

function update_aiturn()
	do_butt_buff()
	p_t=min(p_t+0.125,1)
	for m in all(mob) do
		if m!=p_mob and m.mov then
			m:mov()
		end
	end

	if p_t==1 then
		_upd=update_game
		check_end()
	end
end

function update_gover()
	if btnp(❎) then
		fadeout()
		start_game()
	end
end

function do_butt_buff()
	if butt_buf==-1 then
		butt_buf=get_butt()
	end
end

function get_butt()
	for i=0,5 do
		if btnp(i) then
			return i
		end
	end

	return -1
end

function do_butt(butt)
	if (butt<0) then return end
	if butt<4 then
		move_player(dir_x[butt+1], dir_y[butt+1])
	elseif butt==5 then
		show_inv()
	elseif butt==4 then
		map_gen()
	end
	-- menu button
end

-->8
-- draws
function draw_game()
	cls()

	if fadeperc==1 then return end

	map()

	for m in all(dmob) do
		if sin(time()*8)>0 then
			draw_mob(m)
		end
		
		m.dur-=1
		if m.dur<=0 then
			del(dmob,m)
		end
	end

	for i=#mob,1,-1 do
		draw_mob(mob[i])
	end

	-- throwing UI
	if _upd==update_throw then
		local tx,ty=throw_tile()
		local lx1,ly1=p_mob.x*8+3+thr_dx*4,p_mob.y*8+3+thr_dy*4
		local lx2,ly2=mid(0,tx*8+3,127),mid(0,ty*8+3,127)
		
		rectfill(lx1+thr_dy,ly1+thr_dx,lx2-thr_dy,ly2-thr_dx,0)
		
		local thr_ani,mb=flr(t/7%2)==0,get_mob(tx,ty)
		if thr_ani then
			fillp(0b1010010110100101)
		else
			fillp(0b0101101001011010)
		end
		line(lx1,ly1,lx2,ly2,7)
		fillp()
		oprint8("+",lx2-1,ly2-2,7,0)

		if mb and thr_ani then
			mb.flash=1
		end
	end

	for x=0,15 do
		for y=0,15 do
			if fog[x][y]==1 then
				rectfill2(x*8,y*8,8,8,0)
			end
		end
	end

	for f in all(float) do
		oprint8(f.txt,f.x,f.y,f.c,0)
	end

	-- overlay dist_map onto map
	-- for x=0,15 do
	-- 	for y=0,15 do
	-- 		if dist_map[x][y]>=0 then
	-- 			print(dist_map[x][y], x*8,y*8,8)
	-- 		end
	-- 	end
	-- end
end

function draw_mob(m)
	local col=10
	if m.flash>0 then
		m.flash-=1
		col=7
	end
	
	draw_spr(get_frame(m.ani),m.x*8+m.ox,m.y*8+m.oy,col,m.flp)
end

function draw_gover()
	cls(2)
	print("you ded",50,50,7)
end

function draw_win()
	cls(2)
	print("you win",50,50,7)
end

-->8
-- tools
function get_frame(ani)
	return ani[flr(t/15)%#ani+1]
end

function draw_spr(_spr,_x,_y,_c,_flip)
	palt(0,false) -- make black opaque
	pal(6,_c)	-- make grey into yellow
	spr(_spr,_x,_y,1,1,_flip)
	pal() -- switch palette back
end

function rectfill2(x,y,w,h,c)
	rectfill(x,y,x+max(w-1,0),y+max(h-1,0),c)
end

function oprint8(_t,_x,_y,_c,_c2)
	for i=1,8 do
		print(_t,_x+dir_x[i],_y+dir_y[i],_c2)
	end
	print(_t,_x,_y,_c)
end

function dist(fx,fy,tx,ty)
	local dx,dy=fx-tx,fy-ty
	return sqrt(dx*dx+dy*dy)
end

function do_fade()
	local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
	for j=1,15 do
		col=j
		kmax=flr((p+j*1.46)/22)
		for k=1,kmax do
			col=dpal[col]
		end
		pal(j,col,1)
	end
end

function check_fade()
	if fadeperc>0 then
		fadeperc=max(fadeperc-0.04,0)
		do_fade()
	end
end

function wait(_wait)
	repeat
		_wait-=1
		flip()
	until _wait<0
end

function blankmap(_dflt)
	local ret={}
	if (not _dflt) _dflt=0

	for x=0,15 do
		ret[x]={}
		for y=0,15 do
			ret[x][y]=_dflt
		end
	end

	return ret
end

function get_rnd(arr)
	return arr[1+flr(rnd(#arr))]
end

function copy_map(x,y)
	local tle
	for _x=0,15 do
		for _y=0,15 do
			tle=mget(_x+x,_y+y)
			mset(_x,_y,tle)
			if tle==15 then
				p_mob.x,p_mob.y=_x,_y
			end
		end
	end
end

function fadeout(spd,_wait)
	if (spd==nil) spd=0.04
	if (_wait==nil) _wait=0
	repeat
		fadeperc=min(fadeperc+spd,1)
		do_fade()
		flip()
	until fadeperc==1
	wait(_wait)
end

-->8
-- gameplay
function move_player(dx,dy)
	local dest_x,dest_y=p_mob.x+dx,p_mob.y+dy
	local tle=mget(dest_x,dest_y) -- get the map tile at that coordinate

	if is_walkable(dest_x,dest_y,"check_mobs") then
		sfx(63)
		mob_walk(p_mob,dx,dy)	
		p_t=0
		_upd=update_pturn
	else		
		-- not walkable
		mob_bump(p_mob,dx,dy)
		p_t=0
		_upd=update_pturn

		local mb=get_mob(dest_x,dest_y)
		if mb then
			sfx(58)
			hit_mob(p_mob,mb)
		else
			if fget(tle,1) then
				trig_bump(tle,dest_x,dest_y)
			else
				skip_ai=true
			end
		end
	end

	unfog(p_mob.x,p_mob.y)
end

function get_mob(x,y)
	for m in all(mob) do
		if m.x==x and m.y==y then
			return m
		end
	end

	return false
end

function is_walkable(x,y,mode)
	-- "sight" is a mode
	if in_bounds(x,y) then
		local tle=mget(x,y)
		if mode=="sight" then
			return not fget(tle,2)
		else
			if not fget(tle,0) then
				if mode=="check_mobs" then
					return not get_mob(x,y)
				end
				return true
			end
		end
	end

	return false
end

function in_bounds(x,y)
	return not (x<0 or y<0 or	x>15 or y>15)
end

function hit_mob(atkm,defm,raw_dmg)
	local dmg=atkm and atkm.atk or raw_dmg
	local def=defm.def_min+flr(rnd(defm.def_max-defm.def_min+1))
	dmg-=min(def,dmg)
	defm.hp-=dmg 	-- do damage to defender
	defm.flash=10

	add_float("-"..dmg,defm.x*8,defm.y*8,9)

	if defm.hp<=0 then
		add(dmob,defm)
		del(mob,defm)
		defm.dur=10
	end
end

function heal_mob(mb,hp)
	hp=min(mb.hp_max-mb.hp,hp)
	mb.hp+=hp
	mb.flash=10

	add_float("+"..hp,mb.x*8,mb.y*8,7)
end

function check_end()
	if win then
		wind={}
		_upd=update_gover
		_drw=draw_win
		fadeout(0.02)
		
		return false
	elseif p_mob.hp<=0 then
		wind={}
		_upd=update_gover
		_drw=draw_gover
		fadeout(0.02)
		
		return false
	end

	return true
end

function trig_bump(tle,dest_x,dest_y)
	if tle==7 or tle==8 then
		-- vase
		sfx(59)
		mset(dest_x,dest_y,1)	-- replace tile with empty tile

		if rnd(4)<1 then
			local itm=flr(rnd(#itm_name))+1
			take_item(itm)
			show_msg(itm_name[itm],60)
		end
	elseif tle==10 or tle==12 then
		-- chest
		sfx(61)
		mset(dest_x,dest_y,tle-1)
		local itm=flr(rnd(#itm_name))+1
		take_item(itm)
		show_msg(itm_name[itm],60)
	elseif tle==13 then
		-- door
		sfx(62)
		mset(dest_x,dest_y,1)
	elseif tle==6 then
		-- stone tablet
		if floor==0 then
			show_talk({" welcome to porklike",""," climb this sausage"," tower to obtain the"," ultimate power of"," the golden kielbasa",""})
		elseif floor==win_floor then
			win=true
		end
	end
end

function trig_step()
	local tle=mget(p_mob.x, p_mob.y)
	if tle==14 then
		fadeout()
		gen_floor(floor+1)
		floor_msg()
		return true
	end

	return false
end

function los(x1,y1,x2,y2)
	local frst,sx,sy,dx,dy=true
	if dist(x1,y1,x2,y2)==1 then return true end
	if x1<x2 then
		sx,dx=1,x2-x1
	else
		sx,dx=-1,x1-x2
	end
	
	if y1<y2 then
		sy,dy=1,y2-y1		
	else
		sy,dy=-1,y1-y2
	end

	local err,e2=dx-dy
	
	while not (x1==x2 and y1==y2) do
		if not frst and is_walkable(x1,y1,"sight")==false then return false end
		frst,e2=false,err+err
		if e2>-dy then
			err-=dy
			x1+=sx
		end
		if e2<dx then
			err+=dx
			y1+=sy
		end
	end
	return true
end

function unfog()
	local px,py=p_mob.x,p_mob.y
	for x=0,15 do
		for y=0,15 do
			if fog[x][y]==1 and dist(px,py,x,y)<=p_mob.los and los(px,py,x,y) then
				unfog_tile(x,y)
			end
		end
	end
end

function unfog_tile(x,y)
	fog[x][y]=0

	if is_walkable(x,y,"sight") then
		for i=1,4 do
			local tx,ty=x+dir_x[i],y+dir_y[i]
			if not is_walkable(tx,ty,"sight") then
				fog[tx][ty]=0
			end
		end
	end
end

function calc_dist(tx,ty)
	local cand,step,cand_new={},0
	dist_map=blankmap(-1)

	add(cand,{x=tx,y=ty})
	dist_map[tx][ty]=step
	repeat
		step+=1
		cand_new={}

		for c in all(cand) do
			for d=1,4 do
				local dx=c.x+dir_x[d]
				local dy=c.y+dir_y[d]

				if in_bounds(dx,dy) and dist_map[dx][dy]==-1 then
					dist_map[dx][dy]=step

					if is_walkable(dx,dy) then
						add(cand_new,{x=dx,y=dy})
					end
				end
			end
		end

		cand=cand_new
	until #cand==0
end

function update_stats()
	local atk,dmin,dmax=1,0,0

	if eqp[1] then
		atk+=itm_stat1[eqp[1]]
	end

	if eqp[2] then
		dmin+=itm_stat1[eqp[2]]
		dmax+=itm_stat2[eqp[2]]
	end

	p_mob.atk=atk
	p_mob.def_min=dmin
	p_mob.def_max=dmax
end

function eat(itm,mb)
	local effect=itm_stat1[itm]

	if effect==1 then
		heal_mob(mb, 1)
	end	
end

function throw()
	local itm,tx,ty=inv[thr_slt],throw_tile()

	if in_bounds(tx,ty) then
		local mb=get_mob(tx,ty)
		if mb then
			if itm_type[itm]=="fud" then
				eat(itm,mb)
			else
				hit_mob(nil,mb,itm_stat1[itm])
				sfx(58)
			end
		end
	end
	mob_bump(p_mob,thr_dx,thr_dy)
	inv[thr_slt]=nil
	p_t=0
	_upd=update_pturn
end

function throw_tile()
	local tx,ty=p_mob.x,p_mob.y
	repeat
		tx+=thr_dx
		ty+=thr_dy
	until not is_walkable(tx,ty,"check_mobs")
	return tx,ty
end

-->8
-- ui
function add_wind(_x,_y,_w,_h,_txt)
	local w={x=_x,y=_y,w=_w,h=_h,txt=_txt}
	add(wind,w)
	return w
end

function draw_wind()
	for w in all(wind) do
		local wx,wy,ww,wh=w.x,w.y,w.w,w.h
		rectfill2(wx,wy,ww,wh,0)	-- black rectangle
		rect(wx+1,wy+1,wx+ww-2,wy+wh-2,6)
		wx+=4
		wy+=4
		clip(wx,wy,ww-8,wh-8)

		if w.cur then
			wx+=6
		end

		for i=1,#w.txt do
			local txt,c=w.txt[i],6
			if w.col and w.col[i] then
				c=w.col[i]
			end
			print(txt,wx,wy,c)
			if i==w.cur then
				spr(255,wx-5+sin(time()),wy)
			end
			wy+=6
		end

		clip()

		if w.dur then
			w.dur-=1
			if w.dur<=0 then
				-- animate closing of window
				local dif=wh/4
				wh-=dif
				w.y+=dif/2
				w.h=wh
				if wh<3 then
					del(wind,w)
				end
			end
		else
			if w.butt then
				oprint8("❎",wx+ww-15,wy-1+sin(time()),6,0)
			end	
		end
	end
end

function show_msg(txt,dur)
	local wid=(#txt+2)*4+7
	local w=add_wind(63-wid/2,50,wid,13,{" "..txt.." "})
	w.dur=dur
end

function show_talk(txt)	
	talk_wind=add_wind(16,50,94,#txt*6+7,txt)
	talk_wind.butt=true
end

function add_float(_txt,_x,_y,_c)
	add(float,{txt=_txt,x=_x,y=_y,c=_c,ty=_y-10,t=0})
end

function do_floats()
	for f in all(float) do
		f.y+=(f.ty-f.y)/10
		f.t+=1
		if f.t>70 then
			del(float,f)
		end
	end
end

function do_hp_win()
	hp_wind.txt[1]="♥"..p_mob.hp.."/"..p_mob.hp_max
	local hpy=5
	if p_mob.y<8 then
		hpy=110
	end
	hp_wind.y+=(hpy-hp_wind.y)/5
end

function show_inv()
	local txt,col,itm,eqt={},{}
	_upd=update_inv

	for i=1,2 do
		itm=eqp[i]
		if itm then
			eqt=itm_name[itm]
			add(col,6)
		else
			eqt=i==1 and "[weapon]" or "[armor]"
			add(col,5)
		end
		add(txt,eqt)
	end
	add(txt,"……………………")
	add(col,6)
	for i=1,6 do
		itm=inv[i]
		if itm then
			eqt=itm_name[itm]
			add(col,6)
		else
			eqt="..."
			add(col,5)
		end
		add(txt,eqt)
	end
	
	inv_wind=add_wind(5,17,84,62,txt)
	inv_wind.cur=3
	inv_wind.col=col

	stat_wind=add_wind(5,5,84,13,{"atk: "..p_mob.atk.." def: "..p_mob.def_min.."-"..p_mob.def_max})
	cur_wind=inv_wind
end

function show_use()
	local itm=inv_wind.cur<3 and eqp[inv_wind.cur] or inv[inv_wind.cur-3]
	if not itm then return end
	local typ,txt=itm_type[itm],{}
	if (typ=="wep" or typ=="arm") and inv_wind.cur>3 then
		add(txt,"equip")
	end
	if typ=="fud" then
		add(txt,"eat")
	end
	if typ=="thr" or typ=="fud" then
		add(txt,"throw")
	end
	add(txt,"trash")

	use_wind=add_wind(84,inv_wind.cur*6+11,36,7+#txt*6,txt)
	use_wind.cur=1
	cur_wind=use_wind
end

function trig_use()
	local verb,i,back=use_wind.txt[use_wind.cur],inv_wind.cur,true
	local itm=i<3 and eqp[i] or inv[i-3]
	if verb=="trash" then
		if i<3 then
			eqp[i]=nil
		else
			inv[i-3]=nil
		end
	elseif verb=="equip" then
		local slot=2
		if itm_type[itm]=="wep" then
			slot=1
		end
		inv[i-3]=eqp[slot]
		eqp[slot]=itm
	elseif verb=="eat" then
		eat(itm,p_mob)
		_upd,inv[i-3],p_mob.mov,p_t,back=update_pturn,nil,nil,0,false
	elseif verb=="throw" then
		_upd,thr_slt,back=update_throw,i-3,false
	end

	update_stats()
	use_wind.dur=0

	if back then		
		del(wind,inv_wind)
		del(wind,stat_wind)
		show_inv()
		inv_wind.cur=i
	else
		inv_wind.dur=0
		stat_wind.dur=0
	end
end

function floor_msg()
	show_msg("floor "..floor,120)
end

-->8
-- mobs and items
function add_mob(typ,mx,my)
	local m={
		x=mx,
		y=my,
		ox=0,
		oy=0,
		flp=false,
		ani={},
		flash=0,
		hp=mob_hp[typ],
		hp_max=mob_hp[typ],
		atk=mob_atk[typ],
		def_min=0,
		def_max=0,
		los=mob_los[typ],
		task=ai_wait
	}

	for i=0,3 do
		add(m.ani,mob_ani[typ]+i)
	end

	add(mob,m)

	return m
end

function mob_walk(mb,dx,dy)
	mb.x+=dx
	mb.y+=dy

	mob_flip(mb,dx)
	mb.sox,mb.soy=-dx*8,-dy*8
	mb.ox,mb.oy=mb.sox,mb.soy
	mb.mov=mov_walk	
end

function mob_bump(mb,dx,dy)
	mob_flip(mob,dx)
	mb.sox,mb.soy=dx*8,dy*8
	mb.ox,mb.oy=0,0
	mb.mov=mov_bump
end

function mob_flip(mb,dx)
	-- if dx is 0, keep existing mb.flp
	-- otherwise, adjust for left or right
	mb.flp=dx==0 and mb.flp or dx<0
end

function mov_walk(self)
	local tme=1-p_t
	self.ox=self.sox*tme
	self.oy=self.soy*tme
end

function mov_bump(self)
	local tme=p_t>0.5 and 1-p_t or p_t

	self.ox=self.sox*tme
	self.oy=self.soy*tme
end

function do_ai()
	local moving=false

	for m in all(mob) do
		if m!=p_mob then
			m.mov=nil
			if m.task(m) then
				moving=true
			end
		end
	end

	if moving then
		_upd=update_aiturn
		p_t=0
	end
end

function ai_wait(m)
	if can_see(m,p_mob) then
		-- aggro the mob
		m.task=ai_attac
		m.tx,m.ty=p_mob.x,p_mob.y
		add_float("!",m.x*8+2,m.y*8,10)
		return true
	end

	return false
end

function can_see(m1,m2)
	return dist(m1.x,m1.y,m2.x,m2.y)<=m1.los and los(m1.x,m1.y,m2.x,m2.y)
end

function spawn_mobs()
	local min_mons=3
	local placed,r_pot=0,{}
	
	for r in all(rooms) do
		add(r_pot,r)
	end

	repeat
		local r=get_rnd(r_pot)
		placed+=infest_room(r)

		del(r_pot,r)		
	until #r_pot==0 or placed > min_mons
end

function infest_room(r)
	local target=2+flr(rnd(3))
	local x,y

	for i=1,target do
		repeat
			x=r.x+flr(rnd(r.w))
			y=r.y+flr(rnd(r.h))
		until is_walkable(x,y,"check_mobs")

		add_mob(2,x,y)
	end

	return target
end

function ai_attac(m)
	if dist(m.x,m.y,p_mob.x,p_mob.y)==1 then -- adjacent
		-- attack player
		dx,dy=p_mob.x-m.x,p_mob.y-m.y
		mob_bump(m,dx,dy)
		hit_mob(m,p_mob)
		sfx(57)
		return true
	else
		--move toward player
		if can_see(m,p_mob) then
			m.tx,m.ty=p_mob.x,p_mob.y
		end

		if m.x==m.tx and m.y==m.ty then
			-- de-aggro
			m.task=ai_wait
			add_float("?",m.x*8+2,m.y*8,10)
		else
			local bdst,cand=999,{}
			calc_dist(m.tx,m.ty)
			for i=1,4 do
				local dx,dy=dir_x[i],dir_y[i]
				local tx,ty=m.x+dx,m.y+dy
				if is_walkable(tx,ty,"check_mobs") then
					local dst=dist_map[tx][ty]
					if dst<bdst then
						cand={}
						bdst=dst
					end
					if dst==bdst then
						add(cand,i)
					end
				end
			end

			if #cand>0 then
				local c=get_rnd(cand)
				mob_walk(m,dir_x[c],dir_y[c])
				return true
			end
		end
	end

	return false
end

--------------------
-- items
--------------------
function take_item(itm)
	local i=free_inv_slot()
	if i==0 then
		return false
	end

	inv[i]=itm
	return true
end

function free_inv_slot()
	for i=1,6 do
		if not inv[i] then
			return i
		end
	end
	return 0
end

-->8
-- gen
function gen_floor(f)
	floor=f
	mob={}
	add(mob,p_mob)
	if floor==0 then
		copy_map(16,0)
	elseif floor==win_floor then
		copy_map(32,0)
	else
		map_gen()
	end
end

function map_gen()
	copy_map(48,0)
	
	rooms={}
	room_map=blankmap(0)
	doors={}
	gen_rooms()
	maze_worm()
	place_flags()
	carve_doors()
	carve_scuts()
	start_end()
	fill_ends()
	install_doors()
	spawn_mobs()
end

function snapshot()
	cls()
	map()
	-- for i=0,1 do
	-- 	flip()
	-- end
end

---------------------
-- rooms
---------------------
function gen_rooms()
	local f_max,r_max=5,4	-- failure_max, room_max
	local mw,mh=6,6
	repeat
		local r = rnd_room(mw,mh)

		if place_room(r) then
			r_max-=1
			snapshot()
		else
			f_max-=1
			if r.w>r.h then
				mw=max(mw-1,3)
			else
				mh=max(mh-1,3)
			end
		end
	until f_max<=0 or r_max<=0
end

function rnd_room(mw,mh)
	local _w=3+flr(rnd(mw-2))
	mh=mid(35/_w,3,mh)
	local _h=3+flr(rnd(mh-2))

	return {
		x=0,
		y=0,
		w=_w,
		h=_h,
	}
end

function place_room(r)
	local cand={}

	for _x=0,16-r.w do
		for _y=0,16-r.h do
			if does_room_fit(r,_x,_y) then
				add(cand,{x=_x,y=_y})
			end
		end
	end

	if #cand==0 then
		return false
	else
		c=get_rnd(cand)
		r.x,r.y=c.x,c.y
		add(rooms,r)

		for _x=0,r.w-1 do
			for _y=0,r.h-1 do
				mset(_x+r.x,_y+r.y,1)

				room_map[_x+r.x][_y+r.y]=#rooms
			end
		end
	end

	return true
end

function does_room_fit(r,x,y)
	for _x=-1,r.w do
		for _y=-1,r.h do
			if is_walkable(_x+x,_y+y) then
				return false
			end
		end
	end

	return true
end

---------------------
-- maze
---------------------
function maze_worm()
	repeat
		local cand={}
		for x=0,15 do
			for y=0,15 do
				if can_carve(x,y,false) and not next_to_room(x,y) then
					add(cand,{x=x,y=y})
				end
			end
		end

		if #cand>0 then
			local c=get_rnd(cand)
			dig_worm(c.x,c.y)
			snapshot()
		end
	until #cand<=1
end

function dig_worm(x,y)
	local dr,step=1+flr(rnd(4)),0

	repeat
		mset(x,y,1)
		snapshot()
		if not can_carve(x+dir_x[dr],y+dir_y[dr],false) or (rnd()<0.5 and step>2) then
			step=0
			local cand={}

			for i=1,4 do
				if can_carve(x+dir_x[i],y+dir_y[i],false) then
					add(cand,i)
				end
			end

			if #cand==0 then
				dr=8
			else
				dr=get_rnd(cand)
			end
		end
		x+=dir_x[dr]
		y+=dir_y[dr]
		step+=1
	until dr==8
end

function can_carve(x,y,walk)
	if not in_bounds(x,y) then return false end

	local walk=walk==nil and is_walkable(x,y) or walk

	if is_walkable(x,y)==walk then
		local sig=get_sig(x,y)

		for i=1,#crv_sig do
			if b_comp(sig,crv_sig[i],crv_msk[i]) then
				return true
			end
		end
	end

	return false
end

function b_comp(sig,match,mask)
	local mask=mask or 0
	return bor(sig,mask)==bor(match,mask)
end

function get_sig(x,y)
	local sig=0
	for i=1,8 do
		local dx,dy=x+dir_x[i],y+dir_y[i]
		if not is_walkable(dx,dy) then
			sig=bor(sig,shl(1,8-i))
		end
	end

	return sig
end

---------------------
-- doorways
---------------------
function place_flags()
	local curf=1
	flags=blankmap(0)

	for x=0,15 do
		for y=0,15 do
			if is_walkable(x,y) and flags[x][y]== 0 then
				grow_flag(x,y,curf)
				curf+=1
			end
		end
	end
end

function grow_flag(x,y,flg)
	local cand,cand_new={{x=x,y=y}}
	flags[x][y]=flg
	repeat
		cand_new={}
		for c in all(cand) do
			for d=1,4 do
				local dx,dy=c.x+dir_x[d],c.y+dir_y[d]
				if is_walkable(dx,dy) and flags[dx][dy]!=flg then
					flags[dx][dy]=flg
					add(cand_new,{x=dx,y=dy})
				end
			end
		end
		cand=cand_new
	until #cand==0
end

function carve_doors()
	local x1,y1,x2,y2,found,flg1,flg2,drs=1,1,1,1
	repeat
		drs={}
		for x=0,15 do
			for y=0,15 do
				if not is_walkable(x,y) then
					local sig=get_sig(x,y)
					found=false

					if b_comp(sig,0b11000000,0b00001111) then
						x1,y1,x2,y2,found=x,y-1,x,y+1,true
					elseif b_comp(sig,0b00110000,0b00001111) then
						x1,y1,x2,y2,found=x-1,y,x+1,y,true
					end

					f1=flags[x1][y1]
					f2=flags[x2][y2]
					if found and f1!=f2 then
						add(drs,{x=x,y=y,f=f1})
					end
				end
			end
		end
		
		if #drs!=0 then
			local d=get_rnd(drs)
			add(doors,d)
			mset(d.x,d.y,1)
			grow_flag(d.x,d.y,d.f)
		end
	until #drs==0
end

function carve_scuts()
	local x1,y1,x2,y2,cut,found,drs=1,1,1,1,0
	repeat
		drs={}
		for x=0,15 do
			for y=0,15 do
				if not is_walkable(x,y) then
					local sig=get_sig(x,y)
					found=false

					if b_comp(sig,0b11000000,0b00001111) then
						x1,y1,x2,y2,found=x,y-1,x,y+1,true
					elseif b_comp(sig,0b00110000,0b00001111) then
						x1,y1,x2,y2,found=x-1,y,x+1,y,true
					end

					if found then
						calc_dist(x1,y1)
						if dist_map[x2][y2]>20 then
							add(drs,{x=x,y=y})
						end
					end
				end
			end
		end

		if #drs!=0 then
			local d=get_rnd(drs)
			add(doors,d)
			mset(d.x,d.y,1)
			cut+=1
		end
	until #drs==0 or cut>=3
end

function fill_ends()
	local filled,tle
	repeat 
		filled=false
		for x=0,15 do
			for y=0,15 do
				tle=mget(x,y)
				if can_carve(x,y,true) and tle!=14 and tle!=15 then
					filled=true
					mset(x,y,2)
					snapshot()
				end
			end
		end
	until not filled
end

function is_door(x,y)
	local sig=get_sig(x,y)
	if b_comp(sig,0b11000000,0b00001111) or b_comp(sig,0b00110000,0b00001111) then
		return next_to_room(x,y)
	end

	return false
end

function next_to_room(x,y)
	for i=1,4 do
		if in_bounds(x+dir_x[i],y+dir_y[i]) and 
			 room_map[x+dir_x[i]][y+dir_y[i]]!=0 then
			return true
		end
	end

	return false
end

function install_doors()
	for d in all(doors) do
		if mget(d.x,d.y)==1 and is_door(d.x,d.y) then
			mset(d.x,d.y,13)
		end
	end
end

---------------------
-- decoration
---------------------
function start_end()
	local high,low,px,py,ex,ey=0,9999
	repeat 
		px,py=flr(rnd(16)),flr(rnd(16))
	until is_walkable(px,py)
	
	calc_dist(px,py)

	for x=0,15 do
		for y=0,15 do
			local tmp=dist_map[x][y]
			if tmp>high and can_carve(x,y,false) then
				px,py=x,y
				high=tmp
			end
		end
	end

	calc_dist(px,py)

	high=0
	for x=0,15 do
		for y=0,15 do
			local tmp=dist_map[x][y]
			if tmp>high and can_carve(x,y) then
				ex,ey,high=x,y,tmp
			end
		end
	end

	mset(ex,ey,14)

	for x=0,15 do
		for y=0,15 do
			local tmp=dist_map[x][y]
			if tmp>=0 and tmp<low and can_carve(x,y) then
				px,py,low=x,y,tmp
			end
		end
	end

	mset(px,py,15)
	p_mob.x=px
	p_mob.y=py	
end

__gfx__
000000000000000060666060d0ddd0d0f0fff0f000000000aaaaaaaa00aaa00000aaa00000000000000000000000000000aaa000a0aaa0a0a000000055555550
000000000000000000000000000000000000000000000000aaaaaaaa0a000a000a000a00066666600aaaaaa066666660a0aaa0a000000000a0aa000000000000
007007000000000066606660ddd0ddd0fff0fff000000000a000000a0a000a000a000a00060000600a0000a060000060a00000a0a0aaa0a0a0aa0aa055000000
00077000000000000000000000000000000000000000000000aa0a0000aaa000a0aaa0a0060000600a0aa0a060000060a00a00a000aaa00000aa0aa055055000
000770000000000060666060d0ddd0d0f0fff0f000000000a000000a0a00aa00aa00aaa0066666600aaaaaa066666660aaa0aaa0a0aaa0a0a0000aa055055050
007007000005000000000000000000000000000000000000a0a0aa0a0aaaaa000aaaaa000000000000000000000000000000000000aaa000a0aa000055055050
000000000000000066606660ddd0ddd0fff0fff000000000a000000a00aaa00000aaa000066666600aaaaaa066666660aaaaaaa0a0aaa0a0a0aa0aa055055050
000000000000000000000000000000000000000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000008000000090000000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00666000060666000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06066600060666000606660006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60666660066666006066666060066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660066666006666666066666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000006060000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
00060600066660000006060000666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
00666600006066600066660000060666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077700000
00060666006666600006066600066666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077000000
06066666060000000006666606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000070000000
66000000660660000660000066066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66066606660660000660660066066606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600600006600000060060000066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000050505000303030103010307020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020f080802080101070802c0c0c00e0200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010d0101010107020d0202020200000000000000020202000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010108020101c00101020101c0010200000000000000020e02000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02010108020701010101020202020d0200000000020202020102020202000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020106010208070101c001020101c00200000000020101010101010102000000000000000002020202020200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02c001070202020202020d020106010200000000020101010101010102000000000000000002010101010200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02020d0202020202020201020101010200000000020101010601010102000000000000000002010601010200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101c00dc00701070101020d02020200000000020101010101010102000000000000000002010101010200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020101010202020d020202020101010200000000020701010101010702000000000000000002010101010200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010102020201020202020101010200000000020807010101080802000000000000000002020201020200000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010102010101010101020101010200000000020202020102020202000000000000000000020f01020000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201c001020101c00101010d0106c00200000000000000020f02000000000000000000000000020202020000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02c00ac002010c0101c001020101010200000000000000020202000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201c001020101010101010201c0c00200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000211102114015140271300f6300f6101c610196001761016600156100f6000c61009600076000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100001b61006540065401963018630116100e6100c610096100861000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000205302b5302e5302e5300000000000000002751027510285102a5102a5000000000000275102951029510295000000000000000001f5101f5101f5102151023510245000000000000000000000000000
000100001b0201b020130201302028220242201d21019210172101421013210112100f2100e2100c2100921008210082100821008210082100821008210082100821008210082100721000200002000020000200
000100001d0301d03016030160303201032010350102b0102b0102b01029010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002302028020260302402014020110100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000e720147200d7100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
