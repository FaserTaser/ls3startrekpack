AddCSLuaFile( "cl_init.lua" )

AddCSLuaFile( "shared.lua" )

//util.PrecacheSound("borg/borg_amb_loop1.wav")

//util.PrecacheSound("borg/borg_amb_loop2.wav")

//util.PrecacheSound("borg/borg_ambcomputer_2.wav")

//util.PrecacheSound("borg/borg_collective01.wav")

//util.PrecacheSound("borg/borg_collective02.wav")

//util.PrecacheSound("borg/borg_regen.wav")


include('shared.lua')



local Ground = 1 + 0 + 2 + 8 + 32

local Energy_Usage = 1

local maxhealth = 1250




function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return
end
	
local ent = ents.Create( "borg_alcove" )

	ent:SetPos( tr.HitPos )

	ent:Spawn()

	ent.Active = 0

	return ent

end


function ENT:Initialize()

	self.BaseClass.Initialize(self)

	//self.Entity:SetModel( "models/props_wasteland/lighthouse_fresnel_light_base.mdl" )

	self.Entity:SetModel( "models/storage/transporter_platform.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )

	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
 
	phys:SetMass(5000)

	self.damaged = 0

	//self.Origin = self.Entity:GetPos();


	self.snd_Regen = CreateSound(self.Entity, Sound("borg/borg_regen.wav"))


	
	RD.AddResource(self.Entity, "energy", 0)

	RD.SupplyResource(self.Entity, "energy", 500)


	if not (WireAddon == nil) then

		//self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self.Entity, { "On", })

		self.Outputs = Wire_CreateOutputs(self.Entity, { "On", "Energy" })
 
	end

end

function ENT:TurnOn()

	if (self.Active == 0) then

		self.Active = 1

		//self.snd_Regen:Play()

		self.Entity:SetColor( 0, 255, 0, 255)

	end
end

function ENT:TurnOff()

	if (self.Active == 1) then

		self.Active = 0
	
	//self.snd_Regen:Stop()

		self.Entity:SetColor( 255, 0, 0, 255)

	end
end

function ENT:SetActive( value )

	if not (value == nil) then

		local energy = RD.GetResourceAmount(self, "energy")

		if (value != 0 and self.Active == 0 and energy > Energy_Usage ) then

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

	self.snd_Regen:Stop()
end

function ENT:OnRemove()

	self.snd_Regen:Stop()
end

function ENT:Consume_Energy()

	local energy = RD.GetResourceAmount(self, "energy")

	if (self.Active == 1 ) then

		RD.ConsumeResource(self.Entity, "energy", Energy_Usage)
	end
end

function ENT:Touch( hitEnt ) --in the function, hitEnt is the entity touching the SENT.
 
	local energy = RD.GetResourceAmount(self, "energy")

	if ( hitEnt:IsPlayer() and self.Active == 1 and energy > Energy_Usage ) then

	local health = hitEnt:Health()
	local armor = hitEnt:Armor()

		if ( health < 200) then
 
	 		hitEnt:SetHealth( health + 1 )
 
			self:Consume_Energy()

			self.snd_Regen:Play()

			self.snd_Regen:Stop()

		else

			self.snd_Regen:Stop()

		end

		if ( armor < 200) then
 
			hitEnt:SetArmor( armor + 1 )
	
			self:Consume_Energy()

			self.snd_Regen:Play()

			self.snd_Regen:Stop()

		else

			self.snd_Regen:Stop()

		end
	else
		self.snd_Regen:Stop()

	end

end



function ENT:Think()

	self.BaseClass.Think(self)
/*

	if (self.Active == 1 ) then

		//self:GetTargets()

		//self:HealMe()

		//self:ArmorMe()

	else

		self:TurnOff()
	end
 
*/
	if not (WireAddon == nil) then

		self:UpdateWireOutput()
	end


	self.Entity:NextThink(CurTime() + 1)

	return true
end

function ENT:UpdateWireOutput()

	local energy = RD.GetResourceAmount(self, "energy")

	//local maxenergy = RD.GetNetworkCapacity(self, "energy")


	Wire_TriggerOutput(self.Entity, "On", self.Active)

	Wire_TriggerOutput(self.Entity, "Energy", energy)

	//Wire_TriggerOutput(self.Entity, "Max Energy", maxenergy)


	//self.Entity:SetNetworkedInt("energy", energy)
	//self.Entity:SetNetworkedInt("maxenergy", maxenergy)

end