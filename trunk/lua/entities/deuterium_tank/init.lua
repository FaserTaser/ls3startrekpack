AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "deuterium_tank" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/storage/deuteriumtank.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.damaged = 0
	self.mass = 200
    self:SetMaxHealth( 600 )
    self:SetHealth( 600 )

	RD.AddResource(self.Entity, "deuterium", 1000)
	 
	RD.SupplyResource(self.Entity, "deuterium", 200)

	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Deuterium", "Max Deuterium" })
	end
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
end

function ENT:CheckDamage()
	local health = self.Entity:Health()
	local maxhealth = self.Entity:GetMaxHealth()
	
	if (self.health == self.maxhealth) then
		self.damaged = 0
	elseif (self.health < self.maxhealth) then
		self.damaged = 1
	end

	if (self.health == 0) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 10)
		local effectdata = EffectData()

		effectdata:SetOrigin( self.Entity:GetPos() )

 		util.Effect( "Explosion", effectdata, true, true )
		self.Entity:Remove()
	end
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
	local deuterium = RD.GetResourceAmount(self, "deuterium")
	if (deuterium >= 100) then
		RD.ConsumeResource(self, "deuterium", 100)
		self.Entity:EmitSound( "PhysicsCannister.ThrusterLoop" )
	else
		RD.ConsumeResource(self, "deuterium", deuterium)
		self.Entity:StopSound( "PhysicsCannister.ThrusterLoop" )
	end
end

function ENT:UpdateMass()
	//change mass
	local mass = self.mass + (RD.GetResourceAmount(self, "deuterium")/2) // self.mass = default mass
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
	self:CheckDamage()
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local deuterium = RD.GetResourceAmount(self, "deuterium")
	local maxDeuterium = RD.GetNetworkCapacity(self, "deuterium")
	Wire_TriggerOutput(self.Entity, "Deuterium", deuterium)
	Wire_TriggerOutput(self.Entity, "Max Deuterium", maxDeuterium)
	self.Entity:SetNetworkedInt("deuterium",deuterium)
	self.Entity:SetNetworkedInt("maxdeuterium",maxDeuterium)
end
