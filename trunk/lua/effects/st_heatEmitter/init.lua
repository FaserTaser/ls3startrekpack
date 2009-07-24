//st_heatEmitter

function EFFECT:Init(data)
	
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()
	//self.KillTime = CurTime() + 0.65
	self.KillTime = CurTime() + 10.65
	self:SetRenderBoundsWS(self.Position + Vector()*280,self.Position - Vector()*280)
	
	local ang = self.Normal:Angle():Right():Angle() -- D :
	local emitter = ParticleEmitter(self.Position)

	for i=1,2 do
		//local vec = (self.Normal + 1.2*VectorRand()):GetNormalized()
		local velos = Vector(math.Rand(-15, 15),math.Rand(-15, 15),math.Rand(15, 25))
		//local velos = Vector(5,5,10)

		/* DEBUG PURPOSE */

		//local test_var = math.Clamp((math.sin( CurTime() ) * 16),1,16)
		//Msg("SIN: " .. test_var .. "\n")
		//"sprites/heatwave"
		local particle = emitter:Add("sprites/heatwave", self.Position)
		particle:SetVelocity(velos)
		particle:SetDieTime(math.Rand(1.6, 2.1))
		particle:SetStartAlpha(128)
		particle:SetEndAlpha(0)
		//particle:SetStartSize(test_var)
		particle:SetStartSize(math.Rand(13, 16))
		particle:SetEndSize(0)
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(0.1, 1.0))
		//particle:SetStartLength(0)
		//particle:SetEndLength(0)
		//particle:SetColor(255,255,255)
		particle:SetGravity(Vector(0,0,0))
		particle:SetAirResistance(0)
		particle:SetCollide(false)
		particle:SetBounce(0.0)
	end
/*
	for i=1,2 do
		//local vec = (self.Normal + 1.2*VectorRand()):GetNormalized()
		//local velos = Vector(math.Rand(1, 8),math.Rand(1, 8),math.Rand(15, 25))
		local velos = Vector(0,0,0)
		local particle = emitter:Add("effects/water_warp01", self.Position)
		particle:SetVelocity(velos)
		particle:SetDieTime(math.Rand(1.4, 2.3))
		//particle:SetDieTime(10)
		particle:SetStartAlpha(128)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(25, 35))
		particle:SetEndSize(math.Rand(30, 40))
		particle:SetRoll(math.random(0, 360))
		particle:SetRollDelta(math.random(2.5, 3.5))
		//particle:SetStartLength(0)
		//particle:SetEndLength(0)
		//particle:SetColor(255,255,255)
		particle:SetGravity(Vector(0,0,-20))
		//particle:SetAirResistance(5)
		particle:SetCollide(false)
		//particle:SetBounce(0.9)
	end


	for i=1,10 do
		ang:RotateAroundAxis(self.Normal,math.Rand(0,360))
		local vec = ang:Forward()
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
		particle:SetVelocity(math.Rand(600,1200)*vec)
		particle:SetDieTime(math.Rand(2.5,3))
		particle:SetStartAlpha(math.Rand(16,25))
		particle:SetStartSize(math.Rand(40,50))
		particle:SetEndSize(math.Rand(70,80))
		particle:SetColor(255,241,232)
		particle:SetAirResistance(600)
	end

	for i=1,10 do
		local vec = (self.Normal + 0.6*VectorRand()):GetNormalized()
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position + math.Rand(5,20)*vec)
		particle:SetVelocity(math.Rand(1000,1500)*vec)
		particle:SetDieTime(math.Rand(2.5,3))
		particle:SetStartAlpha(math.Rand(16,25))
		particle:SetStartSize(math.Rand(40,60))
		particle:SetEndSize(math.Rand(80,90))
		particle:SetColor(255,241,232)
		particle:SetGravity(Vector(0,0,100))
		particle:SetAirResistance(500)
	end
*/
	emitter:Finish()
	
/* ********** */

	//local dlight = DynamicLight(math.random(125,256)) --This works for some reason.  Don't ask.
	local dlight = DynamicLight(512) --This works for some reason.  Don't ask.
	dlight.Pos = self.Position
	dlight.Size = 25
	//dlight.DieTime = CurTime() + 0.3
	dlight.DieTime = CurTime() + 0.3
	dlight.r = 255
	dlight.g = 128
	dlight.b = 0
	dlight.Brightness = math.random(0.9,1.1)
	dlight.Decay = 200

end


function EFFECT:Think()

	if CurTime() > self.KillTime then return false end

	return true

end


function EFFECT:Render()
	/*
	local invintrplt = (self.KillTime - CurTime())/0.65
	local intrplt = 1 - invintrplt

	local size = 280 + 200*intrplt
	
	self:SetRenderBoundsWS(self.Position + Vector()*size,self.Position - Vector()*size)
	
	matBulge:SetMaterialFloat("$refractamount", math.sin(0.5*invintrplt*math.pi)*0.16)
	render.SetMaterial(matBulge)
	render.UpdateRefractTexture()
	render.DrawSprite(self.Position,size,size,Color(255,255,255,150*invintrplt))
	*/
end
