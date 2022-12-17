pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
function _init()
	intensity = 0
	shake_control = 5
end

function _update()
	-- run shake when intensity is high
	if intensity > 0 then shake() end

	-- up, increase shake
	if btnp(⬆️)
	and shake_control < 10 then
		shake_control += 1
	end

	-- down, decrease speed
	if btnp(⬇️)
	and shake_control > 0 then
		shake_control -= 1
	end

	if btnp(❎) then intensity += shake_control end

	-- change face based on shake intensity
	eye_size = 7 + intensity / 2
	mouth_size = 2 + intensity / 2
end

function _draw()
	cls(12)
	circfill(63, 63, 40, 6)

	-- below unaffected by shake
	-- after we reset the camera
	camera()

	-- show demo controls
	print("intensity", 2, 2, 7)
	print(intensity, 10, 9, 7)
	print("shake", 47, 2, 0)
	print("❎", 53, 9, 0)
	print("shake_control", 75, 2, 7)
	print("⬆️/⬇️ = "..shake_control, 85, 9, 7)
end

function shake()
	local shake_x = rnd(intensity) - (intensity / 2)
	local shake_y = rnd(intensity) - (intensity / 2)

	-- offset the camera
	camera(shake_x, shake_y)

	-- ease shake and return to normal
	intensity *= 0.9
	if intensity < 0.3 then intensity = 0 end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
