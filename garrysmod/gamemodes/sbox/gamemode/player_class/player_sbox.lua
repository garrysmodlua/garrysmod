
AddCSLuaFile()
DEFINE_BASECLASS( "player_sandbox" )

local PLAYER = {}

PLAYER.DuckSpeed			= 0.1		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed			= 0.1		-- How fast to go from ducking, to not ducking

--
-- Creates a Taunt Camera
--
PLAYER.TauntCam = TauntCamera()

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.WalkSpeed 			= 200
PLAYER.RunSpeed				= 400

function PLAYER:Loadout()

	self.Player:RemoveAllAmmo()

	if ( cvars.Bool( "sbox_weapons", true ) ) then

		self.Player:GiveAmmo( 256,	"Pistol", 		true )

		self.Player:Give( "weapon_crowbar" )
		self.Player:Give( "weapon_pistol" )
		self.Player:Give( "weapon_physcannon" )

	end

	self.Player:Give( "gmod_tool" )
	self.Player:Give( "weapon_physgun" )

	self.Player:SwitchToDefaultWeapon()

end

--
-- Reproduces the jump boost from HL2 singleplayer
--
local JUMPING

function PLAYER:StartMove( move )

	-- Only apply the jump boost in FinishMove if the player has jumped during this frame
	-- Using a global variable is safe here because nothing else happens between SetupMove and FinishMove
	if bit.band( move:GetButtons(), IN_JUMP ) ~= 0 and bit.band( move:GetOldButtons(), IN_JUMP ) == 0 and self.Player:OnGround() then
		JUMPING = true
	end

end

function PLAYER:FinishMove( move )

	-- If the player has jumped this frame
	if JUMPING then
		-- Get their orientation
		local forward = move:GetAngles()
		forward.p = 0
		forward = forward:Forward()

		-- Compute the speed boost

		-- HL2 normally provides a much weaker jump boost when sprinting
		-- For some reason this never applied to GMod, so we won't perform
		-- this check here to preserve the "authentic" feeling
		local speedBoostPerc = ( ( not self.Player:Crouching() ) and 0.5 ) or 0.1

		local speedAddition = math.abs( move:GetForwardSpeed() * speedBoostPerc )
		local maxSpeed = move:GetMaxSpeed() * ( 1 + speedBoostPerc )
		local newSpeed = speedAddition + move:GetVelocity():Length2D()

		-- Clamp it to make sure they can't bunnyhop to ludicrous speed
		--if newSpeed > maxSpeed then
		--	speedAddition = speedAddition - (newSpeed - maxSpeed)
		--end

		-- Reverse it if the player is running backwards
		if move:GetVelocity():Dot(forward) < 0 then
			speedAddition = -speedAddition
		end

		-- Apply the speed boost
		move:SetVelocity(forward * speedAddition + move:GetVelocity())
	end

	JUMPING = nil

end

player_manager.RegisterClass( "player_sbox", PLAYER, "player_sandbox" )
