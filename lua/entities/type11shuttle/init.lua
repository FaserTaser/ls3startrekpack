AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound("mwc/mwc_on.wav")

include('shared.lua')

/*
local Ground = 1 + 0 + 2 + 8 + 32
local Energy_Increment = 500
local maxhealth = 1250
local sequence_off = nil
local sequence_on = nil
local inc = Energy_Increment
*/

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "type11shuttle" )
	ent:SetPos( tr.HitPos )
	ent:Spawn()
	ent.Active = 0
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Entity:SetModel( "models/type11shuttle/type11shuttle.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.damaged = 0
	self.Entity:SetNetworkedInt("tooltip","Type 11 Shuttle")
/*
	sequence_on = self.Entity:LookupSequence("ON")
	sequence_off = self.Entity:LookupSequence("OFF")
	

	LS_RegisterEnt(self.Entity, "Generator")
	RD_AddResource(self.Entity, "energy", inc)
	
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self.Entity, { "On", })
		self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Output" }) 
	end
*/
end
/*
function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self.Entity:SetSequence(sequence_on)
		self.Entity:SetMaterial( "models/microWarpCore/microWarpCore_on" )
		self.Entity:EmitSound( "mwc/mwc_on.wav", 115, 100)
		self:SetOverlayText( "MicroWarpCore\n(ON)\n Energy: 'inc'" )
		
		if not (WireAddon == nil) then
			Wire_TriggerOutput(self.Entity, "Output", inc)
			Wire_TriggerOutput(self.Entity, "On", self.Active)
 		end
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self.Entity:SetSequence(sequence_off)
		self.Entity:SetMaterial( "models/microWarpCore/microWarpCore_off" )

		if not (WireAddon == nil) then
			Wire_TriggerOutput(self.Entity, "Output", inc)
			Wire_TriggerOutput(self.Entity, "On", self.Active)
 		end
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

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
		self.Entity:SetColor( 255, 0, 0, 255 )
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

function ENT:Extract_Energy()
	if (self.Active == 1 ) then
		RD_SupplyResource(self.Entity, "energy", inc)
	end
	if not (WireAddon == nil) then
		Wire_TriggerOutput(self.Entity, "Output", inc)
	end
end

function ENT:GenEnergy()
	self:Extract_Energy()
end
*/

function ENT:Think()
	self.BaseClass.Think(self)
	/*
	self:Extract_Energy()
	*/
	self.Entity:NextThink(CurTime() + 1)
	return true
end
