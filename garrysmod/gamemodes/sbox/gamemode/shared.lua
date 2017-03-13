--[[---------------------------------------------------------

  sbox Gamemode

  This is modification of GMod's default gamemode (Sandbox)

-----------------------------------------------------------]]

DeriveGamemode( "sandbox" )

include( "player_class/player_sbox.lua" )

--
-- Make BaseClass available
--
DEFINE_BASECLASS( "sandbox" ) -- Not sure wot is this.. CHECKME.

GM.Name 	= "sbox"
GM.Author 	= "CaptainPRICE"
GM.Email 	= "captainprice@programmer.net"
GM.Website 	= "www.captainprice.tk"

--[[
 Note: This is so that in addons you can do stuff like
 if ( !GAMEMODE.IsSandboxDerived ) then return end
--]]

GM.IsSandboxDerived = true

local sbox_noclip = GetConVar( "sbox_noclip" )
local sbox_bonemanip_npc = GetConVar( "sbox_bonemanip_npc" )
local sbox_bonemanip_player = GetConVar( "sbox_bonemanip_player" )
local sbox_bonemanip_misc = GetConVar( "sbox_bonemanip_misc" )

--[[---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
-----------------------------------------------------------]]
function GM:PlayerNoClip( pl, on )
	print( ">> GM:PlayerNoClip", pl, on )

	-- Don't allow if player is in vehicle
	if ( not IsValid( pl ) or pl:InVehicle() or not pl:Alive() ) then return false end

	-- Always allow to turn off noclip, and in single player
	if ( not on ) then return true end

	return sbox_noclip:GetBool()
end

--[[---------------------------------------------------------
   Name: gamemode:CanDrive( pl, ent )
   Desc: Return true to let the entity drive.
-----------------------------------------------------------]]
function GM:CanDrive( pl, ent )
	print( ">> GM:CanDrive", pl, ent )
	return false
end

--[[---------------------------------------------------------
   Name: gamemode:CanProperty( pl, property, ent )
   Desc: Can the player do this property, to this entity?
-----------------------------------------------------------]]
function GM:CanProperty( pl, property, ent )
	print( ">> GM:CanProperty", pl, property, ent )

	--
	-- Always a chance some bastard got through
	--
	if ( not IsValid( ent ) ) then return false end

	--
	-- If we have a toolsallowed table, check to make sure the toolmode is in it
	-- This is used by things like map entities
	--
	if ( ent.m_tblToolsAllowed and not ent.m_tblToolsAllowed[property] ) then
		return false
	end

	--
	-- Who can who bone manipulate?
	--
	if ( property == "bonemanipulate" ) then
		if ( ent:IsNPC() ) then return sbox_bonemanip_npc:GetBool() end -- Should be false..
		if ( ent:IsPlayer() ) then return sbox_bonemanip_player:GetBool() end -- Should be false..
		return sbox_bonemanip_misc:GetBool() -- Should be false..
	end

	--
	-- Weapons can only be property'd if nobody is holding them
	--
	if ( ent:IsWeapon() and IsValid( ent:GetOwner() ) ) then
		return false
	end

	-- Give the entity a chance to decide
	if ( ent.CanProperty ) then
		return ent:CanProperty( pl, property )
	end

	return true
end

--[[---------------------------------------------------------
   Name: gamemode:CanTool( ply, trace, mode )
   Return true if the player is allowed to use this tool
-----------------------------------------------------------]]
function GM:CanTool( ply, trace, mode )
	local ent = trace.Entity
	print( ">> GM:CanTool", ply, ent, mode )

	-- The jeep spazzes out when applying something
	-- todo: Find out what it's reacting badly to and change it in _physprops
	if ( mode == "physprop" and ent:IsValid() and ent:GetClass() == "prop_vehicle_jeep" ) then
		return false
	end

	-- If we have a toolsallowed table, check to make sure the toolmode is in it
	if ( ent.m_tblToolsAllowed and not ent.m_tblToolsAllowed[mode] ) then
		return false
	end

	-- Give the entity a chance to decide
	if ( ent.CanTool ) then
		return ent:CanTool( ply, trace, mode )
	end

	return true -- TODO
end
