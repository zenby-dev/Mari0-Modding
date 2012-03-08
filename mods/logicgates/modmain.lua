--modmain.lua

RegisterObject(
	logicgate,
	"andgate",
	function(c, x, y, r)
		NewObject("andgate", c:new(x, y, r, 
			function(a, b)
				return a and b
			end)) 
	end,
	true, --input
	true, --output
	false, --enemy
	false, --jumpitem
	"below", --specialdraw
	"logical 'and' gate")

RegisterObject(
	logicgate,
	"orgate",
	function(c, x, y, r)
		NewObject("orgate", c:new(x, y, r, 
			function(a, b)
				return a or b
			end)) 
	end,
	true, --input
	true, --output
	false, --enemy
	false, --jumpitem
	"below", --specialdraw
	"logical 'or' gate")

RegisterObject(
	logicgate,
	"xorgate",
	function(c, x, y, r)
		NewObject("xorgate", c:new(x, y, r, 
			function(a, b)
				return a ~= b
			end)) 
	end,
	true, --input
	true, --output
	false, --enemy
	false, --jumpitem
	"below", --specialdraw
	"logical 'xor' gate")