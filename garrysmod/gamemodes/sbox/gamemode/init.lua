--[[---------------------------------------------------------

  sbox Gamemode

  This is modification of GMod's default gamemode (Sandbox)

-----------------------------------------------------------]]

-- These files get sent to the client

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "sandbox" ) -- Not sure wot is this.. CHECKME.

local sbox_godmode = GetConVar( "sbox_godmode" )
local sbox_playershurtplayers = GetConVar( "sbox_playershurtplayers" )

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawn( )
   Desc: Called when a player spawns
-----------------------------------------------------------]]
function GM:PlayerSpawn( pl )
	player_manager.SetPlayerClass( pl, "player_sbox" )
	BaseClass.PlayerSpawn( self, pl )
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerShouldTakeDamage
   Return true if this player should take damage from this attacker
   Note: This is a shared function - the client will think they can 
	 damage the players even though they can't. This just means the 
	 prediction will show blood.
-----------------------------------------------------------]]
function GM:PlayerShouldTakeDamage( ply, attacker )
	-- Global godmode, players can't be damaged in any way
	if ( sbox_godmode:GetBool() ) then return false end

	-- No player vs player damage
	if ( attacker:IsValid() and attacker:IsPlayer() ) then
		return sbox_playershurtplayers:GetBool() -- Should be false..
	end

	-- Default, don't let the player be hurt, for now
	return false
end

--[[---------------------------------------------------------
   Desc: A ragdoll of an entity has been created
-----------------------------------------------------------]]
function GM:CreateEntityRagdoll( entity, ragdoll )
	BaseClass.CreateEntityRagdoll( self, entity, ragdoll )
	-- No ragdolls
	ragdoll:Remove()
end

--
-- Who can edit variables?
-- If you're writing prop protection or something, you'll
-- probably want to hook or override this function.
--
function GM:CanEditVariable( ent, ply, key, val, editor )
	-- Only allow admins to edit admin only variables!
	if ( not IsValid( ply ) ) then return true end

	if ( editor.AdminOnly ) then
		return ply:IsAdmin()
	end

	-- This entity decides who can edit its variables
	if ( ent.CanEditVariables ) then
		return ent:CanEditVariables( ply )
	end

	-- Default in sbox is to allow anyone to edit anything - for now.
	return true
end
