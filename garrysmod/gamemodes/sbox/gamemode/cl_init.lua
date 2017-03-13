--[[---------------------------------------------------------

  sbox Gamemode

  This is modification of GMod's default gamemode (Sandbox)

-----------------------------------------------------------]]

include( "shared.lua" )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "sandbox" ) -- Not sure wot is this.. CHECKME.

function GM:HUDPaint()
	BaseClass.PaintWorldTips( self )

	-- Draw all of the default stuff
	BaseClass.HUDPaint( self )
	-- TODO.

	BaseClass.PaintNotes( self )
end

--[[---------------------------------------------------------
	Draws on top of VGUI..
-----------------------------------------------------------]]
function GM:PostRenderVGUI()
	BaseClass.PostRenderVGUI( self )
end
