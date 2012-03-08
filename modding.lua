--modding.lua, written by ZenX2 for Maurice's wonderful Mari0.

modobjects = {}
modspecialdraws = {}
modspecialdraws["below"] = {}
modspecialdraws["above"] = {}

function try(f, ef)

	local s, e = pcall(f)
	if not s then
		if ef then
			ef(e)
		else
			print(debug.traceback("Error: " .. e, 4):gsub("\t", "    "))
		end
	end

	return e

end

local olr = require
function require(f)

	if string.sub(f, -4, -1) == ".lua" then
	
		return olr(string.sub(f, 1, -5))
		
	else
	
		return olr(f)
		
	end

end

function requiredir(dir, ex) --spacesaver 9000

	for k, v in pairs(love.filesystem.enumerate(dir)) do
		if love.filesystem.isFile(dir.."/"..v) then
			if v ~= ex then
				require(dir.."/"..v)
			end
		end
	end

end

function LoadMods()

	for k, v in pairs(love.filesystem.enumerate("mods")) do
		if love.filesystem.isDirectory("mods/"..v) then
			CurrentMod = v
			EntityCount = 0
			requiredir("mods/"..v, "modmain.lua")
			require("mods/"..v.."/modmain") --entity registrations go in modmain.lua
			LoadEntityQuadsFromFile("mods/"..v.."/graphics/entities.png", EntityCount)
			EntityCount = nil
			CurrentMod = nil
		end
	end

	EmptyEntityImg = love.graphics.newImage("graphics/noentity.png")

end

function NewObject(entname, ent)

	if objects[entname] == nil then objects[entname] = {} end
	table.insert(objects[entname], ent)
	ent.__entitytype = entname

end

function GetModIndex(entname)

	return tonumber(modobjects[entname].indx)

end

function RegisterObject(class, entname, const, input, output, enemy, jumpitem, specialdraw, description)

	if modobjects[entname] then return end --don't allow these shenanigans
	modobjects[entname] = {}
	
	if enemy == true then modobjects[entname].enemy = true end
	if jumpitem == true then modobjects[entname].jumpitem = true end
	modobjects[entname].const = {class, const}
	if specialdraw ~= nil then table.insert(modspecialdraws[specialdraw], entname) end

	table.insert(entitylist, entname)
	modobjects[entname].indx = #entitylist
	table.insert(entitydescriptions, description)

	if input == true then modobjects[entname].input = modobjects[entname].indx end
	if output == true then modobjects[entname].output = modobjects[entname].indx end

	print("Registered mod object: "..entname.." at index "..modobjects[entname].indx) --TODO: Figure out how to get mods to always load correctly. A possible solution is setting the index like they are currently, but if there is a save file it can override what index goes to what entity

	EntityCount = EntityCount + 1

end

function LoadEntityQuadsFromFile(path, amt)

	local img = love.graphics.newImage(path)
	local imgwidth, imgheight = img:getWidth(), img:getHeight()
	local width = math.floor(imgwidth/17)
	local height = math.floor(imgheight/17)

	local count = 0
	for y = 1, height do
		for x = 1, width do --this should load entities in the same order they're registered. I hope.

			if count < amt then 

				count = count + 1

				table.insert(entityquads, entity:new(img, x, y, imgwidth, imgheight))
				entityquads[#entityquads]:sett(#entityquads)
			
			end
		end
	end
	entitiescount = entitiescount + count--(width * height)

end

function EmptyEntityQuad()

	local eeq = entity:new(EmptyEntityImg, 1, 1, 17, 17)
	eeq.t = ""
	return eeq

end

function LoadModEntityQuads()

	for k, v in pairs(love.filesystem.enumerate("mods")) do
		if love.filesystem.isDirectory("mods/"..v) and love.filesystem.exists("mods/"..v.."/graphics/entities.png") then
			LoadEntityQuadsFromFile("mods/"..v.."/graphics/entities.png", v)
		end
	end

	EmptyEntityImg = love.graphics.newImage("graphics/noentity.png")

end

function LoadModImage(path)

	return love.graphics.newImage("mods/"..CurrentMod.."/graphics/"..path)

end

function CreateQuad(x, y, w, h, i)

	return love.graphics.newQuad(x, y, w, h, i:getWidth(), i:getHeight())

end

ModStomps = {}

function NewModStomp(e, f)

	ModStomps[e] = f

end

MarioModRightCollide = {}

function NewMarioModRightCollide(e, f)

	MarioModRightCollide[e] = f

end

MarioModLeftCollide = {}

function NewMarioModLeftCollide(e, f)

	MarioModLeftCollide[e] = f

end

MarioModCeilCollide = {}

function NewMarioModCeilCollide(e, f)

	MarioModCeilCollide[e] = f

end

function FirePoints(entname, v)

	firepoints[entname] = v

end