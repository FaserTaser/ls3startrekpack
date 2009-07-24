//phaserStun

function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	self.KillTime = CurTime() + 30
	self:SetRenderBoundsWS(self.Position + Vector()*280,self.Position - Vector()*280)
	
	local ang = self.Normal:Angle():Right():Angle() -- D :
	local emitter = ParticleEmitter(self.Position)
	/*
	for i=1,50 do
		//local vec = (self.Normal + 1.2*VectorRand()):GetNormalized()
		local velos = Vector(math.Rand(-15, 15),math.Rand(-15, 15),math.Rand(25, 35))
		//local velos = Vector(0,0,50)
		local particle = emitter:Add("sprites/yellowflare", self.Position)
		particle:SetVelocity(velos)
		particle:SetDieTime(math.Rand(2.0, 3.0))
		//particle:SetDieTime(10)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(128)
		particle:SetStartSize(math.Rand(9, 6))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(2.5, 3.5))
		//particle:SetStartLength(0)
		//particle:SetEndLength(0)
		particle:SetColor(150,200,250)
		particle:SetGravity(Vector(0,0,15))
		//particle:SetAirResistance(5)
		particle:SetCollide(false)
		//particle:SetBounce(0.9)
	end
	*/
	for i=1,5 do
		ang:RotateAroundAxis(self.Normal,math.Rand(0,360))
		local vec = ang:Forward()
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
		particle:SetVelocity(math.Rand(200,350)*vec)
		//particle:SetVelocity(velos)
		particle:SetDieTime(math.Rand(2.5,3))
		particle:SetStartAlpha(math.Rand(16,25))
		particle:SetStartSize(math.Rand(40,50))
		particle:SetEndSize(math.Rand(70,80))
		particle:SetColor(255,241,232)
		particle:SetAirResistance(600)
	end

	emitter:Finish()
	
end


function EFFECT:Think()

	if CurTime() > self.KillTime then return false end
	return true
	
end


function EFFECT:Render()

end
