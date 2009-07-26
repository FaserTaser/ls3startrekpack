AddCSLuaFile("cl_init.lua")

AddCSLuaFile("shared.lua")


include("shared.lua")

util.PrecacheSound("stpack/transporterBeam.wav")



function ENT:Initialize()

	self.Entity:SetModel("models/storage/transporter_platform.mdl");

	self.Entity:PhysicsInit(SOLID_VPHYSICS);

	self.Entity:SetMoveType(MOVETYPE_VPHYSICS);

	self.Entity:SetSolid(SOLID_VPHYSICS);

	self.snd_ON = CreateSound(self.Entity, Sound("stpack/runloop.wav"))

	self.snd_beamLanding = CreateSound(self.Entity, Sound("stpack/transporterBeam.wav"))

	
	//self.Receiver = self.Entity


	self.targets = {destination={},origin={}};
 // to "the new location", back to origin

	self.Origin = self.Entity:GetPos();

	self.Destination = self.Entity:GetPos();

	self.DestSRC = Vector( 0, 0, 0);

	self.energy = 1;

	self.mode = 1;

	self.comBadge = 1;

	self.AddResource(self.Entity, "energy", 0)


	if not (WireAddon == nil) then

		self.WireDebugName = self.PrintName

		self.Inputs = Wire_CreateInputs(self.Entity, { "On","DestX","DestY","DestZ","Mode","Send","Retrieve","ComBadge"  })

		self.Outputs = Wire_CreateOutputs(self.Entity, { "Active","Send Targets","Retrieval Targets","Mode","ComBadge","DestX","DestY","DestZ" })

	end


	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then

		phys:Wake()

	end
end

function ENT:SpawnFunction(p,t)

	if (not t.Hit) then return end

	local e = ents.Create("transporter_platform")

	e:SetPos( t.HitPos );

	e:Spawn();

	e:Activate();

	return e;
end

function ENT:UpdateTransmitState()
 
	return TRANSMIT_ALWAYS
end

function ENT:GetTargets()

	if (self.mode == 1) then

		self.targets.origin = self:FindPlayers(self.Origin);

		self.targets.destination = self:FindPlayers(self.Destination);

	elseif(self.mode == 2) then

		self.targets.origin = self:FindObjects(self.Origin);

		self.targets.destination = self:FindObjects(self.Destination);

	elseif(self.mode == 3) then

		self.targets.origin = self:FindNPC(self.Origin);

		self.targets.destination = self:FindNPC(self.Destination);

	end
end

function ENT:FindPlayers(pos)

	local player = {}
	for _,p in pairs(ents.FindInSphere(pos,30)) do

		if p:IsPlayer() then

			table.insert(player,p);

		end

	end

	return player;
end

function ENT:FindObjects(pos)

	local objects = {}

	for _,e in pairs(ents.FindInSphere(pos,30)) do

		if(e:IsValid()) then

			local c = e:GetClass()

			local mdl = e:GetModel() or "";

			if(not (c:find("func_") or mdl:find("*") or e:IsPlayer() or e:IsNPC() or e:GetClass()=="transporter_platform")) then // No map objects, NPCs, Players or self !

				table.insert(objects,e);

			end

		end

	end

	return objects;
end

function ENT:FindNPC(pos)

	local npc = {}
	for _,n in pairs(ents.FindInSphere(pos,30)) do

		if n:IsNPC() then

			table.insert(npc,n);

		end

	end

	return npc;
end

function ENT:WeldCheck()

	return true;
end

function ENT:AcceptInput(name,activator,caller)

	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then

		if (self.status == 0 ) then

			self.status = 1

		else

			self.status = 0

		end

		Wire_TriggerOutput(self.Entity, "Active", self.status);

	end
end

function ENT:TriggerInput(k,v)

	if(k == "On") then

		self.status = 0

		if(v == 1) then

			self.status = 1

		end

	/*
	elseif(k == "OriginX") then

		self.Origin.x = v

	elseif(k == "OriginY") then

		self.Origin.y = v

	elseif(k == "OriginZ") then

		self.Origin.z = v

	*/
	elseif(k == "DestX") then

		self.Destination.x = v
	elseif(k == "DestY") then

		self.Destination.y = v
	elseif(k == "DestZ") then

		self.Destination.z = (v + 2)

	elseif(k == "Send")  then

		if(v==1) then

			self:GetTargets();

			self:Teleport(self.targets.origin,self.Origin,self.Destination);

		end

	elseif(k == "Retrieve") then

		if(v==1) then

			self:GetTargets();

			self:Teleport(self.targets.destination,self.Destination,self.Origin);

		end

	// 1=Player(D) 2=ENT 3=NPC

	elseif (k == "Mode") then

		self.mode = v;
	// 0=off 1=on(D)

	elseif (k == "ComBadge") then

		self.comBadge = v;

	end

	Wire_TriggerOutput(self.Entity, "Active", self.status);
	Wire_TriggerOutput(self.Entity, "Mode", self.mode);
end

function ENT:Teleport(ent,from,to)

	if (self.status == 1) and (#ent >= 1) then

		local neededthistime = #self.targets * 1200;

		local energy = self:GetResourceAmount(self, "energy")

		if(energy >= neededthistime) then

			self:ConsumeResource(self, "energy", neededthistime)

			local beamSndOffset = math.Rand(93, 100);

			WorldSound( "stpack/transporterBeam.wav", self.Origin, 100, beamSndOffset )

		
			for _,v in pairs(ent) do

				//local start = v:GetPos();

				local start = from

				local dest = to

				//local dest = to-from+start

				//Before teleportation

				Msg("\n**** Initiating Transport ****\n")

				if (self.mode == 1) then

					local player = v

					player:Freeze(true)

					Msg(" >> Freezing: " .. player:GetName() .."\n")

				end

				local fx = EffectData()

				fx:SetEntity(v)

				fx:SetOrigin(start)

				util.Effect("TransporterBeamOut",fx, true, true );

				//After a random delay between 0.6 and 1.5 sec the transport finishes !

				local beamDelay = math.Rand(0.6, 1.5);

				timer.Simple(beamDelay,

					function()

						v:SetPos(dest);

						local fx = EffectData()

						fx:SetEntity(v)

						fx:SetOrigin(dest)

						WorldSound( "stpack/transporterBeam.wav", self.Destination, 100, beamSndOffset )

						util.Effect("TransporterBeamIn",fx,true,true);

						if (self.mode == 1) then

							local player = v

							player:Freeze(false)

							Msg(" >> Un-Freezing: " .. player:GetName() .."\n")

						elseif (self.mode == 2) then

							local physobj = v:GetPhysicsObject()

								if ( physobj:IsValid() ) then

									physobj:EnableMotion( true )

									Msg(" >> Found PhysObj - Un-Freezing\n")

								else

									Msg(" >> No PhysObj - Nothing Done\n")

								end

						end

						Msg("\n >> Time Spend: " .. beamDelay .. " Sec.\n**** Transport Complete! ****\n")

					end

				);

			end

		end

	end

end


function ENT:Think()

	//Set Origin

    local TransporterPos = self.Entity:GetPos()
	self.Origin = Vector( math.Round(TransporterPos.x*1000)/1000, math.Round(TransporterPos.y*1000)/1000, ((math.Round(TransporterPos.z*1000)/1000)+18.3) )


	//Check if linked with Communicator if true then get Values from it.

	self.comActive = self.Entity:GetNetworkedInt("comActive", 0)


	if (self.comActive == 1 and self.comBadge == 1) then

		self.DestSRC = self.Entity:GetNetworkedVector("DestSRC", 0)

		self.Destination.x = self.DestSRC.x

		self.Destination.y = self.DestSRC.y

		self.Destination.z = self.DestSRC.z + 15

	end


	//Beam Me Home

	self.retrieve = self.Entity:GetNetworkedVector("Receive", 0)


	if (self.retrieve == 1) then

		self:GetTargets();

		self:Teleport(self.targets.destination,self.Destination,self.Origin);

		//Msg("*** Retrive: " .. self.retrieve )

		//Msg("-- Beaming ! ***\n")

		self.retrieve = 0;

	end


	if (self.status == 1) then

		self:GetTargets();

	end

	
	local numberfound = 0

	local location = self.Entity:GetPos() //work out where the core is


	//self.DestSRC = Vector( self.Destination.x, self.Destination.y, self.Destination.z )


	if not (WireAddon == nil) then

		self:UpdateWireOutput()

	end


	self.Entity:NextThink(CurTime()+0.3);

	return true;

end


function ENT:UpdateWireOutput()

	//Wire_TriggerOutput(self.Entity, "Origin Distance", location:Distance(self.Origin));

	//Wire_TriggerOutput(self.Entity, "Destination Distance", location:Distance(self.Destination));

	Wire_TriggerOutput(self.Entity, "Send Targets", #self.targets.origin);

	Wire_TriggerOutput(self.Entity, "Retrieval Targets", #self.targets.destination);

	Wire_TriggerOutput(self.Entity, "ComBadge", self.comBadge);


	//self.Entity:SetNetworkedVector("DestSRC", self.DestSRC)


    Wire_TriggerOutput(self.Entity, "DestX", self.Destination.x)

    Wire_TriggerOutput(self.Entity, "DestY", self.Destination.y)

    Wire_TriggerOutput(self.Entity, "DestZ", self.Destination.z)


end