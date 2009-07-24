AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "dilithiumMine" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/props_wasteland/rockcliff07b.mdl" )
	//EP2  models/Cliffs/rocks_large01_veg.mdl
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.mass = 200
    	self.maxhealth = 600
    	self.health = self.maxhealth

	RD.AddResource(self.Entity, "rawDilithium", 50000)
	 
	RD.SupplyResource(self.Entity, "rawDilithium", 25000)

	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Raw Dilithium" })
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
end

function ENT:Damage()
	return false
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
	local rawDilithium = RD.GetResourceAmount(self, "rawDilithium")
	if (rawDilithium >= 100) then
		RD.ConsumeResource(self, "rawDilithium", 100)
	else
		RD.ConsumeResource(self, "rawDilithium", rawDilithium)
		self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	end
end

function ENT:UpdateMass()
	//change mass
	local mass = self.mass + (RD.GetResourceAmount(self, "rawDilithium")/2) // self.mass = default mass
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
	
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	
	self:UpdateMass()
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local rawDilithium = RD.GetResourceAmount(self, "rawDilithium")
	Wire_TriggerOutput(self.Entity, "Raw Dilithium", rawDilithium)
	self.Entity:SetNetworkedInt("rawDilithium", rawDilithium)
end
