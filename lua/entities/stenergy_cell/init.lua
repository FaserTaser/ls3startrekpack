AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32
local sequence_000 = nil
local sequence_025 = nil
local sequence_050 = nil
local sequence_075 = nil
local sequence_100 = nil

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "stenergy_cell" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/storage/stenergycell.mdl" )
	self.Entity:SetMaterial( "models/storage/energycell_000" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.energy = 0
	self.damaged = 0
	self.maxhealth = 100
	self.mass = 20

	sequence_000 = self.Entity:LookupSequence("0")

	sequence_025 = self.Entity:LookupSequence("25")

	sequence_050 = self.Entity:LookupSequence("50")

	sequence_075 = self.Entity:LookupSequence("75")

	sequence_100 = self.Entity:LookupSequence("100")

	RD.AddResource(self.Entity, "energy", 25000)
	 
	RD.SupplyResource(self.Entity, "energy", 0)


	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self.Entity, { "Energy", "Max Energy" })
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
	local energy = RD.GetResourceAmount(self, "energy")
	if (self.environment.inwater == 0) then
		zapme(self.Entity:GetPos(), 1)
		local tmp = ents.FindInSphere(self.Entity:GetPos(), 600)
		for _, ply in ipairs( tmp ) do
			if (ply:IsPlayer()) then
				if (ply.suit.inwater > 0) then
					zapme(ply:GetPos(), 1)
					ply:TakeDamage( (ply.suit.inwater * energy / 100), 0 )
				end
			end
		end
		RD.ConsumeResource(self, "energy", energy)
	else
		if (math.random(1, 10) < 2) then
			zapme(self.Entity:GetPos(), 1)
			local dec = math.random(200, 2000)
			RD.ConsumeResource(self, "energy", dec)
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if ((self.damaged == 1) and (self.energy > 0)) then
		self:Leak()
	end
	
	if not (WireAddon == nil) then
		self:UpdateWireOutput()
	end
	
	self:UpdateSkin()

	self.Entity:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateSkin()
	self.energy = RD.GetResourceAmount(self, "energy")
	self.maxenergy = RD.GetUnitCapacity(self, "energy")
	self.percent = ( self.energy / self.maxenergy ) * 100

	if (self.percent <= 24) then
		self.Entity:SetSequence(sequence_000)
		self.Entity:SetMaterial( "models/storage/energycell_000" )
	elseif (self.percent >= 25 && self.percent <=49 ) then
		self.Entity:SetSequence(sequence_025)
		self.Entity:SetMaterial( "models/storage/energycell_025" )
	elseif (self.percent >= 50 && self.percent <=74 ) then
		self.Entity:SetSequence(sequence_050)
		self.Entity:SetMaterial( "models/storage/energycell_050" )
	elseif (self.percent >= 75 && self.percent <=99 ) then
		self.Entity:SetSequence(sequence_075)
		self.Entity:SetMaterial( "models/storage/energycell_075" )
	elseif (self.percent >= 100 ) then
		self.Entity:SetSequence(sequence_100)
		self.Entity:SetMaterial( "models/storage/energycell_100" )
	end
end

function ENT:UpdateWireOutput()
	local energy = RD.GetResourceAmount(self, "energy")
	local maxenergy = RD.GetNetworkCapacity(self, "energy")
	Wire_TriggerOutput(self.Entity, "Energy", energy)
	Wire_TriggerOutput(self.Entity, "Max Energy", maxenergy)
	self.Entity:SetNetworkedInt("energy", energy)
	self.Entity:SetNetworkedInt("maxenergy", maxenergy)
end
