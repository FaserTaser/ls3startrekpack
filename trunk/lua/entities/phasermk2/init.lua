
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "sound/weps/galaxy_phaser_a.wav" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	self.infire = false
	self.Entity:SetModel( "models/props_lab/lab_flourescentlight002b.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
	end 
	self.ID = math.random(1000);
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire", "X", "Y", "Z"} )
	self.Outputs = Wire_CreateOutputs(self.Entity, { "Charge" })
	self.PhaserTarget = SpawnPhaserTarget(self.Entity, self.distance, self.ID)
	self.PhaserEnt = SpawnPhaser(self.Entity, self.BeamTarget, self.ID)
	self.PhaserEnt:Fire("turnoff","",0)
	self.charge = 100
	self.fireSound = "weps/galaxy_phaser_a.wav"
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "phasermk2" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end


function ENT:Think()
if FIELDS == nil and COMBATDAMAGEENGINE == nil then return end
	if self.inFire then 
		self.inacc = self.inacc
	else
		self.inacc = Vector(math.Rand(-30,30), math.Rand(-30,30), math.Rand(-30,30))
	end
	self.Target = (Vector(self.XCo, self.YCo, self.ZCo) + self.inacc)
	self.PhaserTarget:SetPos(self.Target)
	self.Location = self.Entity:GetPos()
	if (self.inFire && self.charge > 0) then
			local targetVec = (self.Target - self.Entity:GetPos()):GetNormal()
			local angle = math.acos(self.Entity:GetForward():DotProduct(targetVec))
			local nerfer = self.Location:Distance(self.Target)
     
			if(math.Rad2Deg(angle) < 40 && nerfer <= 10000) then
			
				local trace = {}
				trace.start = self.Entity:GetPos() + (self.Entity:GetForward() * 5)
				trace.endpos = self.Target 
				trace.filter = self.Entity 
				local tr = util.TraceLine( trace )
				if tr.Hit then
					if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC() || tr.HitSky) then
			
					else
					cbt_dealnrghit(tr.Entity, 75, 8, tr.HitPos, tr.HitPos)
					
					end
				end
				
				self.Entity:EmitSound( self.fireSound, 500, 100 )
				self.PhaserEnt:Fire("turnon","",0)
				self.charge = self.charge - 6
			elseif (math.Rad2Deg(angle) < 40 or !self.inFire or self.charge <= 0) then
				self.PhaserEnt:Fire("turnoff","",0)
			else
				self.PhaserEnt:Fire("turnoff","",0)
			end
		
	elseif (!self.inFire or self.charge <= 0) then 
		self.PhaserEnt:Fire("turnoff","",0)
	end
	
	if (self.charge < 100 && !self.inFire) then
		self.charge = self.charge + 2.5
	end
	
		self.Entity:NextThink(CurTime())
		Wire_TriggerOutput(self.Entity, "Charge", self.charge)
end


 function ENT:TriggerInput(k, v)
	if(k=="Fire") then
		if((v or 0) >= 1) then
			self.inFire = true
		else
			self.inFire = false
		end
	
	elseif (k == "X") then
		self.XCo = v
	
	elseif (k== "Y") then
		self.YCo = v
	
	elseif (k == "Z") then
		self.ZCo = v
	end
end
 
 function SpawnPhaserTarget( ent, length, id )
  local  BeamTarget = ents.Create("info_target")
    BeamTarget:SetKeyValue("targetname", "glortho_"..id)
	BeamTarget:SetPos(ent:GetPos() + ent:GetForward() * 2000)
	BeamTarget:SetAngles(ent:GetAngles())
    BeamTarget:Spawn()

	return BeamTarget
end

function SpawnPhaser( ent, target, id )
  local  Beam = ents.Create("env_laser")
	Beam:SetPos(ent:GetPos() + (ent:GetForward() * 5) )
	Beam:SetAngles(ent:GetAngles())
    Beam:SetKeyValue("renderamt", "255")
    Beam:SetKeyValue("rendercolor", "255 255 255")
	Beam:SetKeyValue("renderfx", 14)
    Beam:SetKeyValue("texture", "materials/effects/phaser9.vmt")
    Beam:SetKeyValue("TextureScroll", -70)
    Beam:SetKeyValue("damage", 100)
	Beam:SetKeyValue("NoiseAmplitude", 0)
    Beam:SetKeyValue("width", 4 )
    Beam:SetKeyValue("dissolvetype", 0)
    Beam:SetKeyValue("LaserTarget", "glortho_"..id)
    Beam:Spawn()
	Beam:SetParent(ent)
	
	return Beam
end
