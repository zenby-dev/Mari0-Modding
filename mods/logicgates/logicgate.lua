logicgate = class:new()

function logicgate:init(x, y, r, ef)
	self.x = x
	self.y = y
	self.cox = x
	self.coy = y
	self.r = r
	self.ef = ef --evaluation function
	
	self.outtable = {}
	self.state = "off"
	self.state1 = {"off"}
	self.state2 = {"off"}
	self.initial = true
end

function logicgate:link()
	if #self.r > 3 then
		for j, w in pairs(outputs) do
			for i, v in pairs(objects[w]) do
				local haslink = false
				for indx = 1, #self.r do
					if self.r[indx] == "link" and tonumber(self.r[indx+1]) == v.cox and tonumber(self.r[indx+2]) == v.coy then
						haslink = true
					end
				end
				if haslink then
					v:addoutput(self) --adds this entity as an output to v.
				end
			end
		end
	end
end

function logicgate:addoutput(a)
	table.insert(self.outtable, a)
end

function logicgate:update(dt)
	if self.initial then
		self.initial = false
		--[[if self.state1 == "on" and self.state2 == "on" then
			self:input("on")
		else
			self:input("off")
		end]]
	end
end

function logicgate:draw(entname)
	love.graphics.setColor(255, 255, 255)

	--print(entname.." is index "..GetModIndex(entname))
	local quad = entityquads[GetModIndex(entname)]
	
	love.graphics.drawq(quad.image, quad.quad, math.floor((self.x-1-xscroll)*16*scale), ((self.y-1)*16-8)*scale, 0, scale, scale)
end

function logicgate:out(t)
	for i = 1, #self.outtable do
		if self.outtable[i].input then
			self.outtable[i]:input(t, tostring(self))
		end
	end
end

function logicgate:input(t, e)
	--print("[ANDGATE] Signal received: "..t..", "..e)
	if self.state1[2] == nil then

		--print("[ANDGATE] Connection 1 assigned to "..e)
		self.state1 = {t, e}

	elseif self.state2[2] == nil and (self.state1[2] ~= nil and e ~= self.state1[2]) then

		--print("[ANDGATE] Connection 2 assigned to "..e)
		self.state2 = {t, e}

	end

	if e == self.state1[2] then --Signal for state1

		if t == "on" then
			self.state1[1] = "on"
		elseif t == "off" then
			self.state1[1] = "off"
		else
			if self.state1[1] == "off" then
				self.state1[1] = "on"
			else
				self.state1[1] = "off"
			end
		end
		--print("State 1 is now "..self.state1[1])

	elseif e == self.state2[2] then --Signal for state2

		if t == "on" then
			self.state2[1] = "on"
		elseif t == "off" then
			self.state2[1] = "off"
		else
			if self.state2[1] == "off" then
				self.state2[1] = "on"
			else
				self.state2[1] = "off"
			end
		end
		--print("State 2 is now "..self.state2[1])

	end

	if (self.state1 ~= nil and self.state2 ~= nil) and self.ef(self.state1[1] == "on", self.state2[1] == "on") == true then

		--print("Both are on! I AM ON")
		self:out("on")

	else

		--print("I'm off :C")
		self:out("off")

	end
end