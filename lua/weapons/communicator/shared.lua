if ( SERVER ) then

	AddCSLuaFile( "shared.lua" )
	
	SWEP.HoldType			= "ar2"
	
end

if ( CLIENT ) then

	SWEP.PrintName		= "Communicator"			
	SWEP.Category = "Star Trek"
	SWEP.Author		= "ZeeHtaa"
	SWEP.Slot		= 0
	SWEP.SlotPos		= 4
	SWEP.Description	= "Communicator"
	SWEP.Purpose		= "Transportation"
	SWEP.Instructions = "Left Click to beam 'home'.\n\nRight click to select 'home' Transporter Platform.\n\nSwitch to a different SWEP and you last coordinates will be saved."

	// Inventory Icon
	if(file.Exists("../materials/weapons/communicator_inventory.vmt")) then
		SWEP.WepSelectIcon = surface.GetTextureID("weapons/communicator_inventory");
	end
	// Kill Icon
	if(file.Exists("../materials/weapons/communicator_killicon.vmt")) then
		killicon.Add("weapon_phasert2","weapons/communicator_killicon",Color(255,255,255));
	end
	language.Add("communicator","Communicator");
end

SWEP.Spawnable = true;
SWEP.AdminSpawnable = true;

SWEP.viewModel = "models/weapons/v_smg1.mdl"
SWEP.worldModel = "models/weapons/w_smg1.mdl"
 
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
  
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
