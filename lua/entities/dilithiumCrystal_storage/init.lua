AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "dilithiumCrystal_storage" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/storage/dilithiumcrystalstorage.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.energy = 0
	self.damaged = 0
	self.maxhealth = 100
	self.mass = 20

	RD.AddResource(self.Entity, "dilithiumcrystal", 2000)
	RD.SupplyResource(self.Entity, "dilithiumcrystal", 1000)

	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Dilithium Crystals", "Max Dilithium Crystals" })
	end
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.Entity:SetColor(255, 255, 255, 255)
	self.health = self.maxhealth
	self.damaged = 0
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct( self.Entity, true )
	end
end

function ENT:Leak()
	local dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")
	if (self.environment.inwater == 0) then
		zapme(self.Entity:GetPos(), 1)
		local tmp = ents.FindInSphere(self.Entity:GetPos(), 600)
		for _, ply in ipairs( tmp ) do
			if (ply:IsPlayer()) then
				if (ply.suit.inwater > 0) then
					zapme(ply:GetPos(), 1)
					ply:TakeDamage( (ply.suit.inwater * dilithiumcrystal / 100), 0 )
				end
			end
		end
		RD.ConsumeResource(self, "dilithiumcrystal", dilithiumcrystal)
	else
		if (math.random(1, 10) < 2) then
			zapme(self.Entity:GetPos(), 1)
			local dec = math.random(200, 2000)
			RD.ConsumeResource(self, "dilithiumcrystal", dec)
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
	
	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local dilithiumcrystal = RD.GetResourceAmount(self, "dilithiumcrystal")
	local maxDilithiumCrystal = RD.GetUnitCapacity(self, "dilithiumcrystal")
	Wire_TriggerOutput(self.Entity, "Dilithium Crystals", dilithiumcrystal)
	Wire_TriggerOutput(self.Entity, "Max Dilithium Crystals", maxDilithiumCrystal)
	self.Entity:SetNetworkedInt("dilithiumcrystal", dilithiumcrystal)
	self.Entity:SetNetworkedInt("maxdilithiumcrystal", maxDilithiumCrystal)
end
