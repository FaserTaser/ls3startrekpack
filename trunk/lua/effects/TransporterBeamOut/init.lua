//Based on the CDS_Disintegrate effect
//All credits go to the CDS team !!!
// BEAM FADE OUT
function EFFECT:Init(data)
	self.entity = data:GetEntity()
	if(!self.entity:IsValid()) then return end
	self.mag = math.Clamp(self.entity:BoundingRadius()/8,1,9999999) //Amount of Particles
	self.dur = data:GetScale()+CurTime()
	self.emitter = ParticleEmitter(self.entity:GetPos())
	self.amp = 255/data:GetScale()
end

function EFFECT:Think()
	if not self.entity:IsValid() then return false end
	local t = CurTime()
	local vOffset = self.entity:GetPos()
	local Low, High = self.entity:WorldSpaceAABB() //Size based on BoundingBox
	for i=1, self.mag do --don't fuck with this or you FPS dies
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		local particle = self.emitter:Add("effects/strider_muzzle", vPos)
		if (particle) then
			//particle:SetColor(255,128,128,255)
			particle:SetVelocity(Vector(0,0,0))
			particle:SetLifeTime(0)
			particle:SetDieTime(.5)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(3)
			particle:SetEndSize(0)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetBounce(0.3)
		end
		// BEAM FADE OUT
		local particle2 = self.emitter:Add("effects/beamRefract", vPos)
		if (particle2) then
			particle2:SetColor(255,255,255,128)
			particle2:SetVelocity(Vector(0,0,0))
			particle2:SetLifeTime(0)
			particle2:SetDieTime(.5)
			particle2:SetStartAlpha(172)
			particle2:SetEndAlpha(0)
			particle2:SetStartSize(3)
			particle2:SetEndSize(0)
			particle2:SetRoll(math.random(0, 360))
			particle2:SetRollDelta(0)
			particle2:SetAirResistance(100)
			particle2:SetGravity(Vector(0, 0, 0))
			particle2:SetBounce(0.3)
		end
		//Msg("Bounding Radius: " .. self.mag .. "\n");
	end
	local tmp2 = math.Clamp(self.amp*((self.dur-t)),0,255)
	self.entity:SetColor(tmp2,tmp2,tmp2,tmp2)
	
	if not (t < self.dur) then
		self.emitter:Finish()
	end
	return t < self.dur
/*
	Msg( t .. " < " .. self.dur2 .. "\n")
	Msg("Scale: " .. self.dur2 .. " Time: " .. CurTime() .. "\n")
	Msg("Curtime: " .. CurTime() .. "Func: " .. t < self.dur .. "\n")
*/
end

function EFFECT:Render()
end
