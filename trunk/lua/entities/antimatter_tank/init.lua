AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "antimatter_tank" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/storage/antimatterpod.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.damaged = 0
	self.mass = 200
    self.maxhealth = 600
    self.health = self.maxhealth

	RD.AddResource(self.Entity, "antimatter", 1000)
	 
	RD.SupplyResource(self.Entity, "antimatter", 200)

	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "antimatter", "Max antimatter" })
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
		self.Entity:EmitSound( "PhysicsCannister.ThrusterLoop" )
	end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.max_health
	self.damaged = 0
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:Leak()
	local antimatter = RD.GetResourceAmount(self, "antimatter")
	if (antimatter >= 100) then
		RD.ConsumeResource(self, "antimatter", 100)
	else
		RD.ConsumeResource(self, "antimatter", antimatter)
		self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	end
end

function ENT:UpdateMass()
	//change mass
	local mass = self.mass + (RD.GetResourceAmount(self, "antimatter")/2) // self.mass = default mass
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		if phys:GetMass() != mass then
			phys:SetMass(mass)
			phys:Wake()
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.damaged == 1) then
		self:Leak()
	end
	
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	
	self:UpdateMass()
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local antimatter = RD.GetResourceAmount(self, "antimatter")
	local maxAntimatter = RD.GetNetworkCapacity(self, "antimatter")
	Wire_TriggerOutput(self.Entity, "antimatter", antimatter)
	Wire_TriggerOutput(self.Entity, "Max antimatter", maxAntiMatter)
	self.Entity:SetNetworkedInt("antimatter",antimatter)
	self.Entity:SetNetworkedInt("maxantimatter",maxAntiMatter)
end
