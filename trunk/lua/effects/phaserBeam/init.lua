
EFFECT.Material1 = Material( "effects/phaseBeam" );
EFFECT.Material2 = Material( "effects/phaseBeam" );
EFFECT.Material3 = Material( "sprites/phaserMuzzle" );
EFFECT.matRefraction = Material( "sprites/phaser_refract" )


/*
//BACKUP
EFFECT.Material1 = Material( "generic_laser" );
EFFECT.Material2 = Material( "generic_laser" );
EFFECT.Material3 = Material( "sprites/phaserMuzzle" );
EFFECT.matRefraction = Material( "egon_ringbeam" )
*/

function EFFECT:Init(data)
	local e = data:GetEntity();
	if(not (e and e:IsValid())) then return end;
	if(e:IsNPC()) then return end; // NPC currently not supported due to limitations (Lua state of some necessary functions - I asked garry to make them shared next update)
	if(e.HandBeam and e.HandBeam:IsValid()) then return end; // No double beams

	self.Parent = LocalPlayer()

	self.mode = 1;
	self.Alpha = 255;
	self.texcoord = math.Rand( 0, 20 )/3

	e.HandBeam = self.Entity;
	self.Entity:SetParent(e);
	self.IsSpectating = util.tobool(data:GetScale()); // Are we specting out self? If yes, render the effect differently

	local ply = LocalPlayer()
    self.VM = ply:GetViewModel()
    local attachmentIndex = self.VM:LookupAttachment("muzzle")
    if attachmentIndex == 0 then
		attachmentIndex = self.VM:LookupAttachment("1")
	end
	self.Attach = attachmentIndex

	self.Start = self.VM:GetAttachment(self.Attach).Pos
	self.End = LocalPlayer():GetEyeTrace().HitPos
	self.Parent = e;
	self.Draw = true;

end

function EFFECT:Think()
	if (self.Draw) then 
		self.Entity:SetRenderBoundsWS(self.Start,self.End) 

		self.Alpha = math.Clamp(self.Alpha - 250 * FrameTime(),1,255)
		//Msg("Alph:" .. self.Alpha .. "\n");

		if (self.Alpha < 0) then
			return false
		end

	end;

	return self.Draw;
end

function EFFECT:Render()
	if(not (self.Parent and self.Parent:IsValid())) then 
		self.Draw = nil;
	else
		local is_me = (self.Parent == LocalPlayer());
		local shooting = self.Parent:GetNetworkedInt( "shooting" )
		self.mode = self.Parent:GetNetworkedInt( "mode" )
		
		//Msg("NW: " .. shooting .. " Mode:" .. self.mode .."\n")

		if (is_me and shooting == 1 ) then
			//Nothing
		else
			self.Draw = nil;
			self.Parent.HandBeam = nil;
			self.Entity:Remove();
		end		
	end
	if(not self.Draw) then return end

	// Draw the beam
	local time = CurTime();
	local sin = math.sin(time*math.pi*2);
	local dist = (self.Start - self.End):Length();
	local tex1 = time*2;
	local tex2 = tex1 - dist/128;

	local target = LocalPlayer():GetEyeTrace().HitPos
	local targetNorm = LocalPlayer():GetEyeTrace().HitNormal
	
	self.Length = (self.Start - self.End):Length()
	local texcoord = self.texcoord
	local tex1_r = texcoord
	local tex2_r = texcoord + self.Length / 256

	beamCol = Color(0,0,0,0);
	beamCol2 = Color(0,0,0,0);
	width = 4
	width2 = 0

	if ( self.mode == 1 ) then
		width = math.Rand(3.2,3.6)
		width2 = 0

		beamCol.r = 255
		beamCol.g = 126
		beamCol.b = 0
		beamCol.a = math.Rand(185,215)
	end
		
	if ( self.mode == 2 ) then
		width = math.Rand(3.6,4.4)
		width2 = 0

		beamCol.r = 255
		beamCol.g = 126
		beamCol.b = 0
		beamCol.a = math.Rand(225,255)
	end

	if ( self.mode == 3 ) then
		width = math.Rand(4.0,4.8)
		width2 = math.Rand(0.55,1.3)

		beamCol.r = 220
		beamCol.g = 75
		beamCol.b = 0
		//beamCol.a = math.Rand(180,200)
		beamCol.a = 128

		beamCol2.r = 255
		beamCol2.g = 0
		beamCol2.b = 0
		beamCol2.a = 255
	end
	//Msg("Color: " .. beamCol .. " Mode: " .. self.mode .. "\n")
	//Function Description 
	//render.DrawBeam( Vector StartPos, Vector EndPos, Number Width, Number TextureStart, Number TextureEnd, Color Colour )

	//Beam
	render.SetMaterial(self.Material1);
		render.DrawBeam(self.VM:GetAttachment(self.Attach).Pos,	target, width, tex1, tex2, beamCol );

	//Beam 2
		render.SetMaterial(self.Material2);
			render.DrawBeam(self.VM:GetAttachment(self.Attach).Pos,	target, width2, tex1, tex2, beamCol2 );

	/*
	//Beam Refraction
	render.SetMaterial( self.matRefraction )
	self.matRefraction:SetMaterialFloat( "$refractamount", 0.1 )
	render.UpdateRefractTexture()

	render.DrawBeam( self.VM:GetAttachment(self.Attach).Pos,	// Start
					 LocalPlayer():GetEyeTrace().HitPos,		// End
					 0 + (1-(self.Alpha/255))*8,				// Width
					 tex1_r,									// Start tex coord
					 tex2_r,									// End tex coord
					 Color( 255, 255, 255, self.Alpha ) )		// Color (optional)
	*/
	
	// Muzzle Glow
	render.SetMaterial(self.Material3);
	//self.Material3:SetMaterialFloat( "$refractamount", 3 )
	self.Material3:SetMaterialInt("$nocull", 1)
	//render.UpdateRefractTexture()

		// Glow at the start of the Beam
		render.DrawSprite(self.VM:GetAttachment(self.Attach).Pos,24,12,Color(beamCol.r,beamCol.g,beamCol.b,200 + 55*sin));
		// Glow at the end of the Beam
		render.DrawSprite(target,64,64,Color(beamCol.r,beamCol.g,beamCol.b,200 + 75*sin));

	//util.Decal("impactFlash", target + targetNorm, target - targetNorm )
	util.Decal("egonburn", target + targetNorm, target - targetNorm )
end

