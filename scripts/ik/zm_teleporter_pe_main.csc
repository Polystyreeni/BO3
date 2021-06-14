#using scripts\codescripts\struct;
#using scripts\shared\animation_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_teleporter_pe_main;

#precache("client_fx", "dlc5/theater/fx_teleport_flashback_kino_beam_move_lg");

function autoexec __init__sytem__()
{
	system::register("zm_teleporter_pe_main", &__init__, undefined, undefined);
}

function __init__()
{
	visionset_mgr::register_overlay_info_style_postfx_bundle( "zm_factory_teleport", VERSION_SHIP, 1, "pstfx_zm_der_teleport" );

	clientfield::register("toplayer", "player_teleporter_fx", 1, 1, "int", &player_teleporter_fx, 0, 0);

	level._effect["fx_teleport_flashback_kino_beam_move_lg"] = "dlc5/theater/fx_teleport_flashback_kino_beam_move_lg";
}

function player_teleporter_fx(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	//self notify("hash_2396c469");
	//self endon("hash_2396c469");
	if(newVal == 1)
	{
		if(IsDemoPlaying() && DemoIsAnyFreeMoveCamera())
		{
			return;
		}

		if(!isdefined(self.tele_fx))
			self.tele_fx = PlayFxOnTag(localClientNum, level._effect["fx_teleport_flashback_kino_beam_move_lg"], self, "tag_eye");

		self thread function_e7a8756e(localClientNum);
		self thread postfx::playPostfxBundle("pstfx_zm_wormhole");
	}

	else
	{
		StopFx(localClientNum, self.tele_fx);
		self.tele_fx = undefined;
	}
		
	
}

function function_e7a8756e( localClientNum )
{
	self util::waittill_any("player_teleporter_fx", "player_portal_complete");
	self postfx::exitPostfxBundle();
}