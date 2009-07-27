if ( SERVER ) then
	AddCSLuaFile( "shared.lua" )
	SWEP.HoldType			= "pistol"
	sleeping = {}
end

if ( CLIENT ) then
	SWEP.PrintName		= "Phaser TypeII"			
	SWEP.Category = "Star Trek"
	SWEP.Author		= "ZeeHtaa"
	SWEP.Slot		= 1
	SWEP.SlotPos		= 3
	SWEP.Description	= "Phaser TypeII"
	SWEP.Purpose		= "Self Defense"
	SWEP.Instructions	= "Pri. Fire: Shoot!\nSec. Fire: Select Mode\nSec. Fire + USE: Select 2nd Mode\n\nStun:\nMakes your target unable to move and act for a period.\n\nKill:\nHurts your target, killing it over time.\nEmits Heat, which damages props!\n\nEvaporate:\nDisintegrates your target, leaving nothing behind.\n\n"

	// Inventory Icon
	if(file.Exists("../materials/weapons/phaserT2_inventory.vmt")) then
		SWEP.WepSelectIcon = surface.GetTextureID("weapons/phaserT2_inventory");
	end
	// Kill Icon
	if(file.Exists("../materials/weapons/phaserT2_killicon.vmt")) then
		killicon.Add("weapon_phasert2","weapons/phaserT2_killicon",Color(255,255,255));
	end
	//language.Add("GaussEnergy_ammo","Power Cell");
	language.Add("weapon_phasert2","Phaser TypeII");
end

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.viewModel = "models/weapons/v_pistol.mdl";
SWEP.worldModel = "models/weapons/w_pistol.mdl";

SWEP.Weight			= 5
SWEP.Timed          = true  // default mode, if false then sleep is permanent
SWEP.NPC            = true   // works on NPC's
SWEP.PLY            = true   // works on players

SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.Primary.Recoil		= 2
SWEP.Primary.Damage		= 0
SWEP.Primary.NumShots		= 0
SWEP.Primary.Cone		= 0
SWEP.Primary.ClipSize		= -1
SWEP.Primary.Delay		= 0.2 //0.1
SWEP.Primary.DefaultClip	= 100
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "AR2AltFire"
SWEP.Primary.MaxAmmo 	= 100;

SWEP.Secondary.Delay		= 0.1
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		= "none"


/*---------------------------------------------------------
   Primary Attack
---------------------------------------------------------*/
local Right = 3.5
local Forward = 14
local Up = -3.2
local Up2 = -3
local mode = 1
local pang = false
local phaserStun_time = 5
local phaserKill_dmg = 5
local phaserEvap_dmg = 5
//Ammo Consumption at each Mode
local ammoConsumpM1 = math.Rand(14,16)
local ammoConsumpM2 = math.Rand(15,17)
local ammoConsumpM3 = math.Rand(24,26)

util.PrecacheSound("weps/phaser02_A.wav")
util.PrecacheSound("weps/phaser02_B.wav")
util.PrecacheSound("weps/swep_switchmode.wav")
util.PrecacheSound("weps/phaser_stunned.wav")
util.PrecacheSound("weps/phaser_dissolve.wav")
util.PrecacheSound("weps/phaser_dissolve2.wav")
util.PrecacheSound("weps/phaser_stun.wav")
util.PrecacheSound("weps/phaser_stunned.wav")
util.PrecacheSound("weps/sniperPhaser.wav")
util.PrecacheSound("weps/noammo.wav")
util.PrecacheSound("console/denied01.wav")

function SWEP:Initialize()
	self.Weapon:SetNetworkedBool( "mode2", false )
	self.Weapon:SetNetworkedBool( "mode3", false )
	self.Weapon:SetNetworkedBool( "mode1", true )
	self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 5 )
	self.Weapon:SetNetworkedInt( "phaserKill_dmg", 5 )
	self.Weapon:SetNetworkedInt( "phaserStun_time", 5 )
	//self.Owner:SetNetworkedInt( "shooting", 0 )
	//self.Owner:SetNetworkedInt( "mode", 1 )
	
	mode = 1
	self.Weapon:SetClip1(100);
	//self.snd_dissolveEnt = CreateSound(self.Entity, Sound("weps/phaser_dissolve.wav"));
	//self.snd_dissolveEnt2 = CreateSound(self.Entity, Sound("weps/phaser_dissolve2.wav"));
	//self.snd_stunEnt = CreateSound(self.Entity, Sound("weps/phaser_stunned.wav"));

	//self.snd_mode = CreateSound(self.Entity, Sound("weps/swep_switchmode.wav"));
	//self.snd_prefire = CreateSound(self.Entity, Sound("weps/phaser02_A.wav"));
	//self.snd_fire = CreateSound(self.Entity, Sound("weps/phaser02_B.wav"));

	//self.snd_stun = CreateSound(self.Entity, Sound("weps/phaser02_B.wav"));
	//self.snd_stun = ChangePitch( 86 )
	//self.snd_kill = CreateSound(self.Entity, Sound("weps/phaser02_B.wav"));
	//self.snd_kill = ChangePitch( 93 )
	//self.snd_evap = CreateSound(self.Entity, Sound("weps/phaser02_B.wav"));

	return true;
end

function SWEP:PrimaryAttack()
	// Make sure we can shoot first

	if ( !self:CanPrimaryAttack() ) then
		return
	end
	
	// Check for Ammo
	if ( self.Weapon:Clip1() >= 10 ) then
		if ( mode == 1 ) then
			if ( self.Weapon:Clip1() >= ammoConsumpM1 ) then
				local ShotTime = 0.5 //Sec.

				self:TakePrimaryAmmo( ammoConsumpM1 ) // x from 100
				self.Weapon:phaserBeam()
				self:Stun()
				//self.Owner:EmitSound("weps/phaser02_A.wav", 100, (100 + 7 - 1 * 7))
				self.Owner:EmitSound("weps/phaser_stun.wav", 100, 100)
	
				self.Weapon:SetNextPrimaryFire( CurTime() + (ShotTime + 0.7))

				self.Owner:SetNetworkedInt( "shooting", 1 )

				timer.Simple(ShotTime,
					function()
						self.Owner:SetNetworkedInt( "shooting", 0 )
						//Msg("Beam Off!\n")
					end);
				//Msg("T: 12.0 \n")
			else
				//self.Owner:EmitSound("console/denied01.wav", 100, 100)
			end
		end
		//------------------------------------------------------
		if ( mode == 2 ) then
			if ( self.Weapon:Clip1() >= ammoConsumpM2 ) then
				local ShotTime = 0.4 //Sec.

				self:TakePrimaryAmmo( ammoConsumpM2 ) // x from 100
				self.Weapon:phaserBeam()
				self:Kill()
				self.Owner:EmitSound("weps/phaser02_B.wav", 100, (100 + 7 - 2 * 7))

				self.Weapon:SetNextPrimaryFire( CurTime() + (ShotTime))

				self.Owner:SetNetworkedInt( "shooting", 1 )

				timer.Simple(ShotTime,
					function()
						self.Owner:SetNetworkedInt( "shooting", 0 )
						//Msg("Beam Off!\n")
					end);

				//Msg("T: 9.5 \n")
			else
				//self.Owner:EmitSound("console/denied01.wav", 100, 100)
			end
		end
		//------------------------------------------------------
		if ( mode == 3 ) then
			if ( self.Weapon:Clip1() >= ammoConsumpM3 ) then
				local ShotTime = 0.5 //Sec.

				self:TakePrimaryAmmo( ammoConsumpM3 ) // x from 100
				self.Weapon:phaserBeam()
				self:Evaporate()
				self.Owner:EmitSound("weps/phaser02_A.wav", 100, (100 + 7 - 3 * 7))

				self.Weapon:SetNextPrimaryFire( CurTime() + (ShotTime + 0.7))

				self.Owner:SetNetworkedInt( "shooting", 1 )

				timer.Simple(ShotTime,
					function()
						self.Owner:SetNetworkedInt( "shooting", 0 )
						//Msg("Beam Off!\n")
					end);
	
				//Msg("T: 9.5 \n")
			else
				//self.Owner:EmitSound("console/denied01.wav", 100, 100)
			end
		end
		//------------------------------------------------------
	end
end

function SWEP:CanPrimaryAttack()

	if ( self.Weapon:Clip1() <= 10  ) then
		//self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		self.Owner:SetNetworkedInt( "shooting", 0 )
		//Msg("NO AMMO!\n")
		self.Weapon:SetNextPrimaryFire( CurTime() + 1.5 )
	return false
	end

	return true
end 

function SWEP:phaserBeam()
	local gunown = self.Owner

	if self.Owner.SENT then
		local gunown = self.Owner.SENT.Entity
	end

	local MuzzlePos = gunown:GetShootPos() + (gunown:GetRight() * Right) + (gunown:GetUp() * Up2) + (gunown:GetForward() * Forward)
	local tr = gunown:GetEyeTrace()
	local norm = tr.Normal
	local newpos = tr.HitPos

	// Here's the tricky bit
	local MuzzlePos2 = gunown:GetShootPos() + (gunown:GetRight() * Right) + (gunown:GetUp() * Up) + (gunown:GetForward() * Forward)
	local norm2 = (MuzzlePos2 - newpos):Normalize()     
	local length = newpos:Distance(MuzzlePos2)   
	local spacer = length / 175

	for i = 1, 175 do     
		local vec1 = newpos + ( norm2 * spacer * i ) 
		local effect = {}
		local effectdata4 = EffectData()
		effectdata4:SetOrigin( vec1 )
		effectdata4:SetEntity( gunown )
		effectdata4:SetNormal( norm )
		effectdata4:SetMagnitude(mode * 51 - 50)
		util.Effect( "phaserBeam", effectdata4 )
	end
	//Msg("Beam!\n")
	util.Decal("RedGlowFade", newpos + norm, newpos - norm )
	util.Decal("FadingScorch", newpos + norm, newpos - norm )
end

/* ******** STUN ********* */
function SWEP:Stun(target)

	local gunown = self.Owner
	local tr = gunown:GetEyeTrace()

	if self.Owner.SENT then
		local gunown = self.Owner.SENT.Entity
	end

	//gunown:EmitSound("sniperPhaser.wav", 100, 100)

	if(!SERVER) then
		return
	end
        
    // Nothing to stun ? - quit!
	/*
	if ( tr.HitWorld ) then
		return
	end
	*/

	if(gcombat) then
		//emitheat( position, radius, temp, own)
		cbt_emitheat( tr.HitPos, 15, 10, 0)
	end	
    
     // Stun NPC/Player
	if ( tr.Entity:IsPlayer() and self.PLY ) then
		if self.Timed then
			self.Weapon:tranqPlayer(tr.Entity, phaserStun_time)
		else
			self.Weapon:tranqPlayer(tr.Entity, nil)
		end
	elseif ( tr.Entity:IsNPC() and self.NPC ) then
		if self.Timed then
            self.Weapon:tranqNPC(tr.Entity, phaserStun_time)
		else
			self.Weapon:tranqNPC(tr.Entity, nil)
		end
	end

end

/* ******** KILL ********* */
function SWEP:Kill(target)
	self.Primary.Delay = 0.2
	local gunown = self.Owner
	if self.Owner.SENT then
		local gunown = self.Owner.SENT.Entity
	end

	//self.snd_kill:PlayEx(1, 93)

	local tr = gunown:GetEyeTrace()
	local norm = tr.Normal
	local newpos = tr.HitPos
	local splodepos = tr.HitPos + tr.HitNormal

	// setup the damageifno
	// 5,10,20,40,60

	local dmg = phaserKill_dmg
	local dmgHeat = (phaserKill_dmg * 1.5) - (((phaserKill_dmg * 2 ) / 100 ) * 20 ) //Heat Things up with dmg * 2 - 20%
	local radiusHeat = 30

	local dmginfo = DamageInfo();
		dmginfo:SetDamage( dmg );
		dmginfo:SetAttacker( self.Owner );
		dmginfo:SetInflictor( self.Weapon );
		dmginfo:SetDamageForce( tr.Normal * 1 );
		if( dmginfo.SetDamageType ) then
			dmginfo:SetDamagePosition( tr.HitPos );
			dmginfo:SetDamageType( DMG_ENERGYBEAM );
		end

	// dispatch
	tr.Entity:DispatchTraceAttack( dmginfo, tr.StartPos, tr.HitPos );

	if(gcombat) then
		//emitheat( position, radius, temp, own)
		cbt_emitheat( tr.HitPos, radiusHeat, dmgHeat, 0)
	end	

	local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		//effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
	util.Effect( "st_heatEmitter", effectdata )

	/* DO NOT ACTIVATE THIS - Crashes the game ! 
	local heat = ents.Create( "heat_emitter" )
		heat:SetPos( tr.HitPos, 0)
		heat:SetKeyValue( "radiusHeat", "radiusHeat" ) //radius in which things get damaged
		heat:SetKeyValue( "duration", "0.5" ) //duration of the effect for x seconds
		heat:SetKeyValue( "gcHeatDmg", "50" ) //amount of gCombat Heat to emit
		heat:Spawn()
		heat:Fire( "EmitHeat", "", 0.5)
	*/
	util.Decal("phaserHeat", newpos + norm, newpos - norm )
end

/* ******** EVAPORATE ********* */
function SWEP:Evaporate(target)
	self.Primary.Delay = 0.2
	local gunown = self.Owner

	if self.Owner.SENT then
		local gunown = self.Owner.SENT.Entity
	end

	local tr = gunown:GetEyeTrace()
	local norm = tr.Normal
	local newpos = tr.HitPos
	
	local PlayerPos = self.Owner:GetShootPos() 
	local dist = (tr.HitPos - PlayerPos):Length()
	local radius = tr.HitPos + tr.HitNormal

	timer.Simple(0,self.DissolveEnts,self,radius,1)
	//self.DissolveEnts(newpos,radius),1

	// 5,10,20,40,60
	local dmgHeat = (phaserEvap_dmg * 3) - (((phaserEvap_dmg * 2 ) / 100 ) * 1 ) //Heat Things up with dmg * 3 - 1%
	local radiusHeat = 70

	if(gcombat) then
		//emitheat( position, radius, temp, own)
		cbt_emitheat( tr.HitPos, radiusHeat, dmgHeat, 0)
	end	

	local effectdata = EffectData()
		effectdata:SetOrigin( tr.HitPos )
		//effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
	util.Effect( "st_heatEmitter", effectdata )
end

function SWEP:DissolveEnts(pos,radius)

	if CLIENT then return end

	local targname = "dissolveme"..self:EntIndex()
	for k,ent in pairs(ents.FindInSphere(pos,radius)) do
		/*
		MOVETYPE_NONE = 0 // Never moves.
		MOVETYPE_ISOMETRIC = 1 // For players, in TF2 commander view, etc.
		>> MOVETYPE_WALK = 2 // Player only, moving on the ground.
		>> MOVETYPE_STEP = 3 // Monster/NPC movement.
		>> MOVETYPE_FLY = 4 // Like no clip movement, but with collision.
		>> MOVETYPE_FLYGRAVITY = 5 // Flying but also affected by gravity.
		MOVETYPE_VPHYSICS = 6 // Uses VPHYSICS for simulation.
		MOVETYPE_PUSH = 7 // No clip to world, but pushes and crushes things.
		MOVETYPE_NOCLIP = 8 // No clip mode movement.
		>> MOVETYPE_LADDER = 9 // For players, when moving on a ladder.
		MOVETYPE_OBSERVER = 10 // For players, when in observer mode.
		MOVETYPE_CUSTOM = 11 // Allows the entity to describe its own physics
		*/
		if ( ent:GetMoveType() == 6 or ent:GetMoveType() == 3 or ent:GetMoveType() == 2 or ent:GetMoveType() == 9 or ent:GetMoveType() == 4 or ent:GetMoveType() == 5 ) then
			ent:SetKeyValue("targetname",targname)
			
			local numbones = ent:GetPhysicsObjectCount()
			for bone = 0, numbones - 1 do 

				local PhysObj = ent:GetPhysicsObjectNum(bone)
				if PhysObj:IsValid()then
					//PhysObj:SetVelocity(PhysObj:GetVelocity()*0.001)
					PhysObj:SetVelocity(Vector(0,0,0.1))
					//PhysObj:EnableGravity(false)
					//PhysObj:EnableMotion(false)
					WorldSound( "weps/phaser_dissolve2.wav", pos, 125, math.Rand(95, 105) )

					local effectdata = EffectData()
						effectdata:SetOrigin(pos)
						effectdata:SetScale(2)
						//effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
						util.Effect( "st_heatEmitter", effectdata )
					local effectdata2 = EffectData()
						//effectdata2:SetOrigin(npc:GetPos())
						effectdata2:SetOrigin( pos )
						//effectdata2:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
						util.Effect( "phaserDisintegrate", effectdata2 )

				end

			end
			
		end

	end

	local dissolver = ents.Create("env_entity_dissolver")
	dissolver:SetKeyValue("dissolvetype",3)
	dissolver:SetKeyValue("magnitude",5)
	dissolver:SetPos(pos)
	dissolver:SetKeyValue("target",targname)
	dissolver:Spawn()
	dissolver:Fire("Dissolve",targname,0)
	dissolver:Fire("kill","",0.05)

end

//Tranq NPC, mostly taken from crate maker
function SWEP:tranqNPC(npc, t)
	//get info about npc
	local skin = npc:GetSkin()
	local wep = ""
	local hasWeapon = "0"
	local possibleWep = ents.FindInSphere(npc:GetPos(),0.01) // find anything in the center basically

	for k, v in pairs(possibleWep) do
		if string.find(v:GetClass(),"weapon_") == 1 then
        	wep = v:GetClass()
			hasWeapon = 1
		else
			hasWeapon = 0
		end
	end

	local citType = "" // citizen type
	local citMed = 0 // is it a medic? assume no

	if npc:GetClass() == "npc_citizen" then
		citType = string.sub(npc:GetModel(),21,21) // get group number (e.g. models/humans/group0#/whatever)
		if string.sub(npc:GetModel(),22,22) == "m" then //medic skins have an "m" after the number
			citMed = 1
		end 
	end

	//make ragdoll now that all info is gathered   
	local rag = ents.Create( "prop_ragdoll" )
	if not rag:IsValid() then
		return
	end

	// build rag
	rag:SetModel( npc:GetModel() )
	rag:SetKeyValue( "origin", npc:GetPos().x .. " " .. npc:GetPos().y .. " " .. npc:GetPos().z )
	rag:SetAngles(npc:GetAngles())

	self.Weapon.targetMaxHealth = npc:GetMaxHealth()
	self.Weapon.targetHealth = npc:Health()

	self.Weapon:SetNetworkedInt( "health", self.Weapon.targetHealth )
	self.Weapon:SetNetworkedInt( "maxH", self.Weapon.targetMaxHealth )

	rag:SetMaxHealth(self.Weapon.targetMaxHealth)
	rag:SetHealth(self.Weapon.targetHealth)

	//If the NPC has a weapon there is a 50/50 chance he drops it.
	if ( hasWeapon == 1) then
		local wepLotto = math.Rand(0, 6);
		if (wepLotto > 3.5) then
			local weapon = ents.Create( wep )
			weapon:SetPos( npc:GetPos() )
			weapon:Spawn()
	
			rag.npcWep = ""
		else
			rag.npcWep = wep
		end
	else
		rag.npcWep = ""
	end

	// npc vars
	rag.wasNPC = true
	rag.npcType = npc:GetClass()
	rag.npcCitType = citType
	rag.npcCitMed = citMed
	rag.npcSkin = skin
	//finalize
	rag:Spawn()
	rag:Activate()

	// make ragdoll fall
	//rag:GetPhysicsObject():SetVelocity(8*npc:GetVelocity())

	//remove npc
	npc:Remove()

	//local tr = SWEP.Owner:GetEyeTrace()

	local effectdata = EffectData()
		//effectdata:SetOrigin(npc:GetPos())
		effectdata:SetOrigin( npc:GetPos() )
		//effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
	util.Effect( "phaserStun", effectdata )

	//self.Weapon:EmitSound("weps/phaser_stunned.wav", 125, math.Rand(93, 100) )
	WorldSound( "weps/phaser_stunned.wav", npc:GetPos(), 150, math.Rand(93, 100) )

	// sleep
	if t then
		local key = (t + CurTime())
		sleeping[key] = rag
	end

	return rag
end


// Tranq a player, taken from ragdoll gun
function SWEP:tranqPlayer(ply, t)
	//create ragdoll
	local rag = ents.Create( "prop_ragdoll" )
	if not rag:IsValid() then
		return
	end

	// build rag
	rag:SetModel( ply:GetModel() )
	rag:SetKeyValue( "origin", ply:GetPos().x .. " " .. ply:GetPos().y .. " " .. ply:GetPos().z )
	rag:SetAngles(ply:GetAngles())

	// player vars
	rag.ply = ply

	// "remove" player
	ply:StripWeapons()
	ply:DrawViewModel(false)
	ply:DrawWorldModel(false)
	ply:Spectate(OBS_MODE_CHASE)
	ply:SpectateEntity(rag)

	//finalize ragdoll
	rag:Spawn()
	rag:Activate()

	// make ragdoll fall
	rag:GetPhysicsObject():SetVelocity(4*ply:GetVelocity())

	// if timed, make sleep
	if t then
		local key = (t + CurTime())
		sleeping[key] = rag
	end
    
	return rag
end

function SWEP:revive(ent)
	// revive player
	if !ent then return end
	
	if ent.ply then
		local phy = ent:GetPhysicsObject()
		phy:EnableMotion(false)
		ent:SetSolid(SOLID_NONE)
		ent.ply:DrawViewModel(true)
		ent.ply:DrawWorldModel(true)
		ent.ply:Spawn()
		ent.ply:SetPos(ent:GetPos())
		ent.ply:SetVelocity(ent:GetPhysicsObject():GetVelocity())
	
	// revive npc
	elseif ent.wasNPC then
		//self.Weapon.targetMaxHealth = npc:GetMaxHealth()
		//self.Weapon.targetHealth = npc:Health()

		local npc = ents.Create(ent.npcType) // create the entity

		util.PrecacheModel(ent:GetModel()) // precache the model
		npc:SetModel(ent:GetModel()) // and set it
		local spawnPos = ent:GetPos()+Vector(0,0,0) // position to spawn it
		
		npc:SetPos(spawnPos) // position
		npc:SetSkin(ent.npcSkin)
		npc:SetAngles(Angle(0,ent:GetAngles().y,0))

		if ( ent.npcWep != "" ) then // if it's an NPC and we found a weapon for it when it was spawned, then
			npc:SetKeyValue("additionalequipment",ent.npcWep) // give it the weapon
		end

		if ent.entType == "npc_citizen" then
			npc:SetKeyValue("citizentype",ent.npcCitType) // set the citizen type - rebel, refugee, etc.
			if ent.npcCitType == "3" && ent.npcCitMed==1 then // if it's a rebel, then it might be a medic, so check that
				npc:SetKeyValue("spawnflags","131072") // set medic spawn flag
			end
		end
		
		npc:Spawn()
		// make sure health before/after stun is the same.
		npc:SetMaxHealth(self.Weapon.targetMaxHealth);
		npc:SetHealth(self.Weapon.targetHealth);
		//Msg("Health: " .. self.Weapon.targetHealth .. " / " .. self.Weapon.targetHealth .. "\n")

		npc:Activate()
		
	// don't deal with other ents
	else 
		return
	end
	
	// remove ragdoll
	ent:Remove()
end

/* ******** SWITCH MODE ********* */
function SWEP:SecondaryAttack()
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )

	self.Weapon:EmitSound("weps/swep_switchmode.wav", 125, math.Rand(93, 100) )
	//self.snd_mode:Play()

	if( self.Owner:KeyDown( IN_USE ) ) then
		if ( mode == 1 ) then
			// Stun Times in Sec. = 5, 10, 20, 30, 60, 90, 120
			//Msg("Stun - " .. phaserStun_time .. "\n")
		
			if ( phaserStun_time >= 4 and phaserStun_time <= 7 ) then
					phaserStun_time = math.Clamp(math.Rand(8, 12),8,12);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 10 )
			elseif (phaserStun_time >= 8 and phaserStun_time <=12) then
					phaserStun_time = math.Clamp(math.Rand(18, 22),18,22);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 20 )
			elseif (phaserStun_time >=18 and phaserStun_time <=22) then
					phaserStun_time = math.Clamp(math.Rand(28, 32),28,32);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 30 )
			elseif (phaserStun_time >=28 and phaserStun_time <=32) then
					phaserStun_time = math.Clamp(math.Rand(58, 62),58,62);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 60 )
			elseif (phaserStun_time >=58 and phaserStun_time <=62) then
					phaserStun_time = math.Clamp(math.Rand(88, 92),88,92);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 90 )
			elseif (phaserStun_time >=88 and phaserStun_time <=92) then
					phaserStun_time = math.Clamp(math.Rand(118, 122),118,122);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 120 )
			elseif (phaserStun_time >=118 and phaserStun_time <=122) then
					phaserStun_time = math.Clamp(math.Rand(4, 7),4,7);
					self.Weapon:SetNetworkedInt( "phaserStun_time", 5 )
			end
		elseif ( mode == 2 ) then
			// Kill Dmg = 5,10,20,40,60
			//Msg("Kill - " .. phaserKill_dmg .. "\n")
	
			if (phaserKill_dmg >=4 and phaserKill_dmg <=6) then
					phaserKill_dmg = math.Clamp(math.Rand(8, 12),8,12);
					self.Weapon:SetNetworkedInt( "phaserKill_dmg", 10 )
			elseif (phaserKill_dmg >=8 and phaserKill_dmg <=12) then
					phaserKill_dmg = math.Clamp(math.Rand(17, 22),17,22);
					self.Weapon:SetNetworkedInt( "phaserKill_dmg", 20 )
			elseif (phaserKill_dmg >=17 and phaserKill_dmg <=22) then
					phaserKill_dmg = math.Clamp(math.Rand(37, 42),37,42);
					self.Weapon:SetNetworkedInt( "phaserKill_dmg", 40 )
			elseif (phaserKill_dmg >=37 and phaserKill_dmg <=42) then
					phaserKill_dmg = math.Clamp(math.Rand(57, 62),57,62);
					self.Weapon:SetNetworkedInt( "phaserKill_dmg", 60 )
			elseif (phaserKill_dmg >=57 and phaserKill_dmg <=62) then
					phaserKill_dmg = math.Clamp(math.Rand(4, 6),4,6);
					self.Weapon:SetNetworkedInt( "phaserKill_dmg", 5 )
			end
		elseif ( mode == 3 ) then
			// Kill Dmg = 5,10,20,40,60
			//Msg("Evaporate - " .. phaserEvap_dmg .. "\n")
	
			if (phaserEvap_dmg >=4 and phaserEvap_dmg <=6) then
					phaserEvap_dmg = math.Clamp(math.Rand(8, 12),8,12);
					self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 10 )
			elseif (phaserEvap_dmg >=8 and phaserEvap_dmg <=12) then
					phaserEvap_dmg = math.Clamp(math.Rand(17, 22),17,22);
					self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 20 )
			elseif (phaserEvap_dmg >=17 and phaserEvap_dmg <=22) then
					phaserEvap_dmg = math.Clamp(math.Rand(37, 42),37,42);
					self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 40 )
			elseif (phaserEvap_dmg >=37 and phaserEvap_dmg <=42) then
					phaserEvap_dmg = math.Clamp(math.Rand(57, 62),57,62);
					self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 60 )
			elseif (phaserEvap_dmg >=57 and phaserEvap_dmg <=62) then
					phaserEvap_dmg = math.Clamp(math.Rand(4, 6),4,6);
					self.Weapon:SetNetworkedInt( "phaserEvap_dmg", 5 )
			end
		end
	else
		if mode == 1 then
			self.Weapon:SetNetworkedBool( "mode2", true )
			self.Weapon:SetNetworkedBool( "mode3", false )
			self.Weapon:SetNetworkedBool( "mode1", false )
			self.Owner:SetNetworkedInt( "mode", 2 )
			mode = 2
		elseif mode == 2 then
			self.Weapon:SetNetworkedBool( "mode3", true )
			self.Weapon:SetNetworkedBool( "mode2", false )
			self.Weapon:SetNetworkedBool( "mode1", false )
			self.Owner:SetNetworkedInt( "mode", 3 )
			mode = 3
		elseif mode == 3 then
			self.Weapon:SetNetworkedBool( "mode1", true )
			self.Weapon:SetNetworkedBool( "mode2", false )
			self.Weapon:SetNetworkedBool( "mode3", false )
			self.Owner:SetNetworkedInt( "mode", 1 )
			mode = 1
		end
	end
end

function SWEP:TakePrimaryAmmo(num)

	// Doesn't use clips
	if ( self.Weapon:Clip1() <= 0 ) then
		if ( self:Ammo1() <= 0 ) then
			return
		end
		self.Owner:RemoveAmmo( num, self.Weapon:GetPrimaryAmmoType() )
		return
	end
	self.Weapon:SetClip1( self.Weapon:Clip1() - num )
end 

function SWEP:Deploy()
	//self.Owner:EmitSound("weps/deploy.wav", 50, 100)
	return true;
end

function SWEP:Holster()
	//self.Owner:EmitSound("weps/holster.wav", 50, 100)
	return true;
end

//function SWEP:Reload()
	/* DEBUG ONLY FEATURE!*/
/*	self.Weapon:EmitSound("weps/swep_switchmode.wav", 125, 100 )
	
	local ammo = self.Weapon:Clip1();
	local set = math.Clamp(ammo+1,0,self.Primary.MaxAmmo);
	self.Weapon:SetClip1(set);
	/* DEBUG ONLY FEATURE!*/

//	return
//end

function SWEP:DrawHUD()
	//Show Current Mode
  	surface.CreateFont( "coolvetica", 20, 500, true, false, "STphaser_modes" )
	surface.CreateFont( "coolvetica", 16, 400, true, false, "ammo_level" )

	local stunTime = self.Weapon:GetNetworkedInt( "phaserStun_time" )
	local killDmg = self.Weapon:GetNetworkedInt( "phaserKill_dmg" )
	local evapDmg = self.Weapon:GetNetworkedInt( "phaserEvap_dmg" )
	local health = self.Weapon:GetNetworkedInt( "health" )
	local maxH = self.Weapon:GetNetworkedInt( "maxH" )
 	local ammo = self.Weapon:Clip1();
	local height = 65
	local ammoPrcnt = (ammo * (height / self.Primary.MaxAmmo)) //percentage, counting up !
	local ammoPrcnt2 = ((height / self.Primary.MaxAmmo)*(ammo-(ammo*2))+height) //reversed percentage, counting down !

	local colorM1 = Color(0, 255, 0, 255);
	local colorM2 = Color(255, 255, 0, 255);
	local colorM3 = Color(255, 200, 0, 255);
	local bgCol = Color(70, 50, 50, 80);
	//----AMMO----------------------------------------------------------------------
	draw.RoundedBox( 0, ScrW()/1.17, ScrH()/1.105, 16, 65, Color(0, 255, 0, 120) )
	draw.RoundedBox( 0, ScrW()/1.17, ScrH()/1.105, 16, ammoPrcnt2, Color(70, 50, 50, 200) )
	//----MODE 1--------------------------------------------------------------------
	if self.Weapon:GetNetworkedBool( "mode1" ) == true then
		if ( ammo >= ammoConsumpM1 ) then
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(0, 255, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(0,255,0,120), Color(0,255,0,0) )
		else
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(255, 0, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(255,0,0,120), colorM2 )
		end
		
		draw.SimpleText("Setting: Stun", "STphaser_modes", ScrW()/1.23, ScrH()/1.15, colorM1, 0, 0)
		//draw.SimpleText(health .." / ".. maxH, "STphaser_modes", ScrW()/1.125, ScrH()/1.20, colorM1, 0, 0)
		draw.SimpleText("Time: " .. stunTime .. " Sec.", "STphaser_modes", ScrW()/1.125, ScrH()/1.15, colorM1, 0, 0)
		draw.RoundedBox( 8, ScrW()/1.244, ScrH()/1.16, 210, 30, bgCol )
	end
	//----MODE 2--------------------------------------------------------------------
	if self.Weapon:GetNetworkedBool( "mode2" ) == true then
		if ( ammo >= ammoConsumpM2 ) then
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(0, 255, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(0,255,0,120), Color(0,255,0,0) )
		else
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(255, 0, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(255,0,0,120), colorM2 )
		end
		draw.SimpleText("Setting: Kill", "STphaser_modes", ScrW()/1.23, ScrH()/1.15, colorM2, 0, 0)
		//draw.SimpleText(health .." / ".. maxH, "STphaser_modes", ScrW()/1.125, ScrH()/1.20, colorM2, 0, 0)
		draw.SimpleText("Damage: " .. killDmg , "STphaser_modes", ScrW()/1.125, ScrH()/1.15, colorM2, 0, 0)
		draw.RoundedBox( 8, ScrW()/1.244, ScrH()/1.16, 210, 30, bgCol )
	end
	//----MODE 3--------------------------------------------------------------------
	if self.Weapon:GetNetworkedBool( "mode3" ) == true then
		if ( ammo >= ammoConsumpM3 ) then
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(0, 255, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(0,255,0,120), Color(0,255,0,0) )
		else
			//draw.RoundedBox( 8, ScrW()/1.219, ScrH()/1.105, 30, 30, Color(255, 0, 0, 120) )
			draw.WordBox( 8, ScrW()/1.219, ScrH()/1.105, "LOW", "ammo_level", Color(255,0,0,120), colorM2 )
		end
		draw.SimpleText("Setting: Evaporate", "STphaser_modes", ScrW()/1.23, ScrH()/1.15, colorM3, 0, 0)
		//draw.SimpleText(health .." / ".. maxH, "STphaser_modes", ScrW()/1.125, ScrH()/1.20, colorM3, 0, 0)
		//draw.SimpleText("Damage: " .. evapDmg , "STphaser_modes", ScrW()/1.125, ScrH()/1.15, colorM3, 0, 0)
		//draw.SimpleText("     " .. evapDmg , "STphaser_modes", ScrW()/1.125, ScrH()/1.15, colorM3, 0, 0)
		draw.RoundedBox( 8, ScrW()/1.244, ScrH()/1.16, 210, 30, bgCol )
	end
end

// Watch for temporary revives
function SWEP:CheckSleeping()
	if not(sleeping == nil) then
		for t, ent in pairs(sleeping) do
			if CurTime() > t then
				self.Weapon:revive(ent)
				sleeping[t] = nil
			end
		end
	end
end 

function SWEP:Think()
	self.Weapon:CheckSleeping()

	// autoreload primary ammo
	local time = CurTime();
	local reserve = 10 // how much ammo is needed, before it stops slowing reload.
	local offset = 0.08 // higher is slower.
	
	if((self.LastThink or 0) + offset < time) then
		self.LastThink = time;
		//keep ammo reserver
		local ammo = self.Owner:GetAmmoCount(self.Primary.Ammo);
		if(ammo > reserve) then
			self.Owner:RemoveAmmo(ammo-reserve,self.Primary.Ammo);
		end

		//primary ammo
		local ammo = self.Weapon:Clip1();
		local set = math.Clamp(ammo+1,0,self.Primary.MaxAmmo);
		self.Weapon:SetClip1(set);
	end

	self.Weapon:NextThink(CurTime() + 1)
	return true
end