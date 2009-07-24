include('shared.lua')
	    
    function ENT:Draw()
    // self.BaseClass.Draw(self) -- We want to override rendering, so don't call baseclass.
	// Use this when you need to add to the rendering.
		//self:DrawEntityOutline( 0.0 ) // Draw an outline of 1 world unit.
		self.Entity:DrawModel() // Draw the model.

	end 