include('shared.lua')
	    
    function ENT:Draw()
    // self.BaseClass.Draw(self) -- We want to override rendering, so don't call baseclass.
	// Use this when you need to add to the rendering.
		//self:DrawEntityOutline( 0.0 ) // Draw an outline of 1 world unit.
		self.Entity:DrawModel() // Draw the model.

		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 512 ) then
			AddWorldTip(self.Entity:EntIndex(),"Something: "..tostring(self.Entity:GetNetworkedInt("tooltip",0)),0.5,self.Entity:GetPos(),self.Entity)
		end
	end 