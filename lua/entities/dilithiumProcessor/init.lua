AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local rawDilithium_Increment = 125
local dilithiumcrystal_Increment = 3
local Energy_Increment = 100

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "dilithiumProcessor" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/Gibs/airboat_broken_engine.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.snd_ON = CreateSound(self.Entity, Sound("stpack/runloop.wav"))

	self.damaged = 0
	self.mass = 200
    	self.maxhealth = 600
    	self.health = self.maxhealth

	RD.AddResource(self.Entity, "rawDilithium", 0)

	RD.AddResource(self.Entity, "dilithiumcrystal", 0)
	RD.AddResource(self.Entity, "energy", 0)


	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Energy Input", "Raw Dilithium Input", "Dilithium Crystal Output", "On" })
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self.snd_ON:Play()
		self.Entity:SetColor( 0, 255, 0, 255)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self.snd_ON:ChangePitch(80)
		self.snd_ON:FadeOut(1)
		self.Entity:SetColor( 255, 0, 0, 255)
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
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.max_health
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:OnRemove()
	self.snd_ON:Stop()
end

function ENT:Convert()
	if (self.Active == 1 ) then
		self.energy = RD.GetResourceAmount(self, "energy")
		self.dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")
		self.rawDilithium = RD.GetResourceAmount(self, "rawDilithium")
		if (self.rawDilithium >= rawDilithium_Increment) and (self.energy >= Energy_Increment) then
			RD.ConsumeResource(self, "rawDilithium", rawDilithium_Increment)
			RD.ConsumeResource(self, "energy", Energy_Increment)
			RD.SupplyResource(self.Entity, "dilithiumcrystal", dilithiumcrystal_Increment)
		end
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	self.nrg = RD.GetResourceAmount(self, "energy")

	if (self.Active == 1 and self.nrg >= 50) then
		self:Convert()
	else
		self:TurnOff()
	end
	
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local energy = RD.GetResourceAmount(self, "energy")
	local rawDilithium = RD.GetResourceAmount(self, "rawDilithium")
	local dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")
	Wire_TriggerOutput(self.Entity, "Energy Input", energy)
	Wire_TriggerOutput(self.Entity, "Raw Dilithium Input", rawDilithium)
	Wire_TriggerOutput(self.Entity, "Dilithium Crystal Output", dilithiumcrystal)
	Wire_TriggerOutput(self.Entity, "On", self.Active)
end
