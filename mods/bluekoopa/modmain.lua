--modmain.lua

bluekoopaimg = LoadModImage("bluekoopa.png")

bluekoopaquad = {}

for x = 1, 3 do
	bluekoopaquad[x] = CreateQuad((x-1)*16, 0, 16, 24, bluekoopaimg)
end

RegisterObject(
	bluekoopa,
	"bluekoopa",
	function(c, x, y, r)
		NewObject("bluekoopa", c:new(x-0.5, y-1/16))
	end,
	false, --input
	false, --output
	true, --enemy
	false, --jumpitem
	nil, --specialdraw
	"runs away from mario")