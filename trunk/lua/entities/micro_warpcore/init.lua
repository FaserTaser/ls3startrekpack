AddCSLuaFile( "cl_init.lua" )

AddCSLuaFile( "shared.lua" )



include('shared.lua')


local Ground = 1 + 0 + 2 + 8 + 32

local Energy_Increment = 500

local Deuterium_Increment = 10

local AntiDeuterium_Increment = 10

local DilithiumCrystal_Increment = 1

local sequence_off = nil

local sequence_on = nil



function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	local ent = ents.Create( "micro_warpcore" )

	ent:SetPos( tr.HitPos )

	ent:Spawn()
	
	ent.Active = 0

	return ent
end

function ENT:Initialize()
	
	self.BaseClass.Initialize(self)

	self.Entity:SetModel( "models/microWarpCore/microwarpcore.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )

	self.Entity:SetSolid( SOLID_VPHYSICS )

	self.snd_MWC_ON = CreateSound(self.Entity, Sound("stpack/mwc_on.wav") )


	self.damaged = 0

	self.mass = 3000

	self.maxhealth = 1250



	sequence_on = self.Entity:LookupSequence("ON")

	sequence_off = self.Entity:LookupSequence("OFF")


	RD.AddResource(self.Entity, "energy", 0)

	RD.AddResource(self.Entity, "deuterium", 0)

	RD.AddResource(self.Entity, "antideuterium", 0)

	RD.AddResource(self.Entity, "dilithiumcrystal", 0)



	if not (WireAddon == nil) then

		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self.Entity, { "On", })

		self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Energy Output", "Deuterium Input", "AntiDeuterium Input", "DilithiumCrystals Input" })
 
	end


end



function ENT:TurnOn()


	if (self.Active == 0) then

		self.Active = 1

		self.Entity:SetSequence(sequence_on)

		self.Entity:SetMaterial( "models/microWarpCore/microWarpCore_on" )

		status = "Active"
		self.Entity:SetNetworkedString("active", "Active")

		self.snd_MWC_ON:Play()

	end

end



function ENT:TurnOff()
	if (self.Active == 1) then

		self.Active = 0

		self.Entity:SetSequence(sequence_off)

		self.Entity:SetMaterial( "models/microWarpCore/microWarpCore_off" )

		self.Entity:SetNetworkedString("active", "Inactive")

		self.snd_MWC_ON:ChangePitch(80)

		self.snd_MWC_ON:FadeOut(3)

	end

end



function ENT:SetActive( value )

	if not (value == nil) then

		if (value != 0 and self.Active == 0 ) then

			self:TurnOn()

		elseif (value == 0 and self.Active == 1 ) then

			self:TurnOff()

		end

	end

end



function ENT:TriggerInput(iname, value)

	if (iname == "On") then

		self:SetActive(value)

	end

end



function ENT:Use(activator, ply)

	if activator:KeyDownLast(IN_USE) then return end
 
	if (not ply:IsPlayer()) then return end
	if (self.Active == 0) then

		self:TurnOn()

	elseif (self.Active == 1) then

		self:TurnOff()

	end

end




function ENT:Damage()

	if (self.damaged == 0) then

		self.damaged = 1

	end
end



function ENT:Repair()

	self.Entity:SetColor( 255, 255, 255, 255 )

	self.health = self.maxhealth

	self.damaged = 0
end

function ENT:Destruct()

	LS_Destruct( self.Entity )
end

function ENT:OnRemove()

	self.snd_MWC_ON:Stop()
end

function ENT:GenEnergy()

	if (self.Active == 1 ) then

		self.deuterium = RD.GetResourceAmount(self, "deuterium")

		self.antideuterium = RD.GetResourceAmount(self, "antideuterium")

		self.dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")

		if (self.deuterium >= Deuterium_Increment) and (self.antideuterium >= AntiDeuterium_Increment) and (self.dilithiumcrystal >= DilithiumCrystal_Increment) then

			RD.ConsumeResource(self, "deuterium", Deuterium_Increment)

			RD.ConsumeResource(self, "antideuterium", AntiDeuterium_Increment)

			RD.ConsumeResource(self, "dilithiumcrystal", DilithiumCrystal_Increment)

			RD.SupplyResource(self.Entity, "energy", Energy_Increment)

		end

	else

		self:TurnOff()

	end

end



function ENT:Think()

	self.BaseClass.Think(self)

	self.dt = RD.GetResourceAmount(self, "deuterium")

	self.atd = RD.GetResourceAmount(self, "antideuterium")

	self.dc = RD.GetResourceAmount(self, "dilithiumcrystal")


	if (self.Active == 1 and self.dt >= 10 and self.atd >= 10 and self.dc >= 1 ) then

		self:GenEnergy()

	else

		self:TurnOff()

		self.Entity:SetNetworkedString("active", "Inactive")

	end


	if not (WireAddon == nil) then

		self:UpdateWireOutput()

	end

	
	self.Entity:NextThink(CurTime() + 1)

	return true
end

function ENT:UpdateWireOutput()

	local energy = RD.GetResourceAmount(self, "energy")

	local deuterium = RD.GetResourceAmount(self, "deuterium")

	local antiDeuterium = RD.GetResourceAmount(self, "antideuterium")

	local dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")

	Wire_TriggerOutput(self.Entity, "Energy Output", energy)

	Wire_TriggerOutput(self.Entity, "Deuterium Input", deuterium)

	Wire_TriggerOutput(self.Entity, "AntiDeuterium Input", antiDeuterium)

	Wire_TriggerOutput(self.Entity, "DilithiumCrystals Input", dilithiumcrystal)

	Wire_TriggerOutput(self.Entity, "On", self.Active)

	if (self.Active == 1) then

		self.Entity:SetNetworkedInt("energy", 500)

	else

		self.Entity:SetNetworkedInt("energy", 0)

	end

end