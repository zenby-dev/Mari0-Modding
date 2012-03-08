bluekoopa = class:new()

--combo: 500, 800, 1000, 2000, 4000, 5000

function bluekoopa:init(x, y, t)
	--PHYSICS STUFF
	self.x = x-6/16
	self.y = y-11/16
	self.speedy = 0
	self.speedx = -koopaspeed
	self.width = 12/16
	self.height = 12/16
	self.static = false
	self.active = true
	self.category = 5
	
	self.mask = {	true, 
					false, false, false, false, true,
					false, true, false, true, false,
					false, false, true, false, false,
					true, true, false, false, true,
					false, true, true, false, false,
					true, false, true, true, true}
	
	self.autodelete = true
	self.t = t
	self.flying = false
	self.startx = self.x
	self.starty = self.y
	self.quad = bluekoopaquad[1]
	self.combo = 1
	
	--IMAGE STUFF
	self.drawable = true

	self.graphic = bluekoopaimg

	self.offsetX = 6
	self.offsetY = 0
	self.quadcenterX = 8
	self.quadcenterY = 19
	
	self.rotation = 0
	self.direction = "left"
	self.animationdirection = "right"
	self.animationtimer = 0
	
	self.falling = false
	
	self.small = false
	self.moving = true
	
	self.shot = false
end	

function bluekoopa:func(i) -- 0-1 in please
	return (-math.cos(i*math.pi*2)+1)/2
end

function bluekoopa:update(dt)
	--rotate back to 0 (portals)
	self.rotation = math.mod(self.rotation, math.pi*2)
	if self.rotation > 0 then
		self.rotation = self.rotation - portalrotationalignmentspeed*dt
		if self.rotation < 0 then
			self.rotation = 0
		end
	elseif self.rotation < 0 then
		self.rotation = self.rotation + portalrotationalignmentspeed*dt
		if self.rotation > 0 then
			self.rotation = 0
		end
	end
	
	if self.shot then
		self.speedy = self.speedy + shotgravity*dt
		
		self.x = self.x+self.speedx*dt
		self.y = self.y+self.speedy*dt
		
		return false
		
	else
		if self.speedx > 0 then
			self.animationdirection = "left"
		else
			self.animationdirection = "right"
		end
	
		if self.small == false then
			self.animationtimer = self.animationtimer + dt
			while self.animationtimer > koopaanimationspeed do
				self.animationtimer = self.animationtimer - koopaanimationspeed
				if self.quad == bluekoopaquad[1] then
					self.quad = bluekoopaquad[2]
				else
					self.quad = bluekoopaquad[1]
				end
			end

			if table.maxn(objects["player"]) > 0 then

				local closest = 1

				for i = 1, table.maxn(objects["player"]) do

					if math.abs(objects["player"][i].x - self.x) > math.abs(objects["player"][closest].x - self.x) then closest = i end

				end

				local closest = objects["player"][closest].x
				if closest > self.x then
					self.speedx = -koopaspeed
				else
					self.speedx = koopaspeed
				end

			end

		end
		
		return false
	end
end

function bluekoopa:stomp(x, b)
	if self.small == false then
		self.quadcenterY = 19
		self.offsetY = 0
		self.quad = bluekoopaquad[3]
		self.small = true
		self.mask = {false, false, false, false, false, true, false, false, false, true}
		self.speedx = 0
	elseif self.speedx == 0 then
		if self.x > x then
			self.speedx = koopasmallspeed
			self.x = x+12/16+koopasmallspeed*gdt
		else
			self.speedx = -koopasmallspeed
			self.x = x-self.width-koopasmallspeed*gdt
		end
	else
		self.speedx = 0
		self.combo = 1
	end
end

function bluekoopa:shotted(dir) --fireball, star, turtle
	playsound(shotsound)
	self.shot = true
	self.speedy = -shotjumpforce
	self.direction = dir or "right"
	self.active = false
	self.gravity = shotgravity
	if self.direction == "left" then
		self.speedx = -shotspeedx
	else
		self.speedx = shotspeedx
	end
end

function bluekoopa:leftcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
	
	if a == "tile" or a == "portalwall" or a == "spring" then		
		if self.small then
			self.speedx = -self.speedx
			local x, y = b.cox, b.coy
			if a == "tile" then
				hitblock(x, y, objects["player"][1])
			else
				playsound(blockhitsound)
			end
		end
	end
	
	if a ~= "tile" and a ~= "portalwall" and a ~= "platform" and self.small and self.speedx ~= 0 and a ~= "player" and a ~= "spring" then
		if b.shotted then
			if self.combo < #koopacombo then
				self.combo = self.combo + 1
				addpoints(koopacombo[self.combo] * 2, b.x, b.y)
			else
				for i = 1, players do
					mariolives[i] = mariolives[i]+1
					respawnplayers()
				end
				table.insert(scrollingscores, scrollingscore:new("1up", b.x, b.y))
				playsound(oneupsound)
			end
			b:shotted("left")
		end
	end

	if self.small == false then
		--self.animationdirection = "left" --do not reverse direction
		--self.speedx = -self.speedx
	else
		return false
	end
end

function bluekoopa:rightcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end	
	if a == "tile" or a == "portalwall" or a == "spring" then		
		if self.small then
			self.speedx = -self.speedx
			local x, y = b.cox, b.coy
			if a == "tile" then
				hitblock(x, y, objects["player"][1])
			else
				playsound(blockhitsound)
			end
		end
	end
	
	if a ~= "tile" and a ~= "portalwall" and a ~= "platform" and self.small and self.speedx ~= 0 and a ~= "player" and a ~= "spring" then
		if b.shotted then
			if self.combo < #koopacombo then
				self.combo = self.combo + 1
				addpoints(koopacombo[self.combo] * 2, b.x, b.y)
			else
				for i = 1, players do
					mariolives[i] = mariolives[i]+1
					respawnplayers()
				end
				table.insert(scrollingscores, scrollingscore:new("1up", b.x, b.y))
				playsound(oneupsound)
			end
			b:shotted("right")
		end
	end

	if self.small == false then
		--self.animationdirection = "right"
		--self.speedx = -self.speedx
	else
		return false
	end
end

function bluekoopa:passivecollide(a, b)
	if self.speedx > 0 then
		self:rightcollide(a, b)
	else
		self:leftcollide(a, b)
	end
end

function bluekoopa:globalcollide(a, b)
	if a == "bulletbill" then
		if b.killstuff ~= false then
			return true
		end
	end
	if a == "fireball" or a == "player" then
		return true
	end
end

function bluekoopa:emancipate(a) --3644
	self:shotted()
end

function bluekoopa:floorcollide(a, b)

end

function bluekoopa:ceilcollide(a, b)
	if self:globalcollide(a, b) then
		return false
	end
end

function bluekoopa:laser()
	self:shotted()
end

FirePoints("bluekoopa", 400)

NewModStomp(
	"bluekoopa",
	function(self, b)
		if b.small then	
			playsound(shotsound)
			if b.speedx == 0 then
				addpoints(500, b.x, b.y)
				self.combo = 1
			end
		else
			playsound(stompsound)
		end
		
		b:stomp(self.x, self)
		
		if b.speedx == 0 or ((b.t == "redflying" or b.t == "flying") and b.small == false) then
			addpoints(mariocombo[self.combo], self.x, self.y)
			if self.combo < #mariocombo then
				self.combo = self.combo + 1
			end
		
			local grav = self.gravity or yacceleration
			
			local bouncespeed = math.sqrt(2*grav*bounceheight)
			
			self.speedy = -bouncespeed
			
			self.falling = true
			self.animationstate = "jumping"
			self:setquad()
			self.y = b.y - self.height-1/16
			return false
		elseif b.x > self.x then
			b.x = self.x + b.width + self.speedx*gdt + 0.05
			return false
		else
			b.x = self.x - b.width + self.speedx*gdt - 0.05
			return false
		end
	end)

NewMarioModRightCollide(
	"bluekoopa",
	function(self, b)
		if self.invincible then
			if b.small and b.speedx == 0 then
				b:stomp(self.x)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
			end
			return false
		else
			if b.small and b.speedx == 0 then
				b:stomp(self.x)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
				return false
			end
			
			self:die("Enemy (rightcollide)")
			return false
		end
	end)

NewMarioModLeftCollide(
	"bluekoopa",
	function(self, b)
		if self.invincible then
			if b.small and b.speedx == 0 then
				b:stomp(self.x)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
			end
			return false
		else
			if b.small and b.speedx == 0 then
				b:stomp(self.x)
				playsound(shotsound)
				addpoints(500, b.x, b.y)
				return false
			end
			
			self:die("Enemy (leftcollide)")
			return false
		end
	end)