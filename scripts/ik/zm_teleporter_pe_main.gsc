#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_spawner;
#using scripts\shared\ai\zombie_utility;	
#using scripts\zm\_zm_audio;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_death;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\zm_project_e_ee;
#using scripts\bosses\zm_avogadro;	//SpawnAvoAtPosition
#using scripts\ik\zm_pregame_room;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\shared\exploder_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\shared\visionset_mgr_shared;
#using scripts\ik\zm_pregame_room;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#precache("fx", "dlc0/factory/fx_teleporter_beam_factory");

#namespace zm_teleporter_pe_main;

function autoexec __init__sytem__()
{
	system::register("zm_teleporter_pe_main", &__init__, &__main__, undefined);
}

function __init__()
{
	clientfield::register( "toplayer", "player_teleporter_fx", 1, 1, "int" );

	visionset_mgr::register_info( "overlay", "zm_factory_teleport", VERSION_SHIP, 61, 1, true );
}

function __main__()
{
	MainTele();
}

function MainTele()
{
	level.loc_needle_main = GetEnt("tele_loc_needle_main", "targetname");
	level.loc_needle_main.defaultpos = self.angles;
	level.tele_locations_main = [];

	respawn_points = struct::get_array("player_respawn_point", "targetname");
	foreach(struct in respawn_points)
	{
		if(isdefined(struct.script_noteworthy) && struct.script_noteworthy == "start_zone" )
			level.tele_locations_main[0] = struct;
	}

	level.tele_current_location_main = level.tele_locations_main[0];
	level.tele_locations_main[1] = undefined;
	level.tele_locations_main[2] = undefined;
	level.tele_locations_main[3] = undefined;

	level.tele_current_index_main = 0;

	struct = struct::get("ee_tele_struct", "targetname");
	loc_struct = struct::get( "underground_tele_loc_select", "targetname" );

	width = 72;
	height = 72;
	length = 72;

	/*struct.unitrigger_stub = SpawnStruct();
	struct.unitrigger_stub.origin = struct.origin;
	struct.unitrigger_stub.angles = struct.angles;
	struct.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	struct.unitrigger_stub.cursor_hint = "HINT_NOICON";
	struct.unitrigger_stub.script_width = width;
	struct.unitrigger_stub.script_height = height;
	struct.unitrigger_stub.script_length = length;
	struct.unitrigger_stub.require_look_at = 0;
	struct.unitrigger_stub.prompt_and_visibility_func = &tele_trigger_visibility;
	zm_unitrigger::register_static_unitrigger(struct.unitrigger_stub, &teleporter_trigger_use);*/

	trigger = Spawn("trigger_radius", struct.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7to Teleport" );

	trigger thread CheckGameMode();

	trigger thread teleporter_trigger_use();

	loc_struct.unitrigger_stub = SpawnStruct();
	loc_struct.unitrigger_stub.origin = loc_struct.origin;
	loc_struct.unitrigger_stub.angles = loc_struct.angles;
	loc_struct.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	loc_struct.unitrigger_stub.cursor_hint = "HINT_NOICON";
	loc_struct.unitrigger_stub.script_width = width;
	loc_struct.unitrigger_stub.script_height = height;
	loc_struct.unitrigger_stub.script_length = length;
	loc_struct.unitrigger_stub.require_look_at = 0;
	loc_struct.unitrigger_stub.prompt_and_visibility_func = &loc_trigger_visibility;
	zm_unitrigger::register_static_unitrigger(loc_struct.unitrigger_stub, &location_trigger_use);

}

function tele_trigger_visibility(player)
{
	level endon("end_game");
	level endon("end_final_tele");

	if( !IS_TRUE(player.in_afterlife) && !player laststand::player_is_in_laststand() )
	{
		if(isdefined(player.teleporting))
		{
			b_is_invis = 1;
		}

		self SetHintString( "Hold ^3&&1 ^7to Teleport" );
		b_is_invis = 0;
	}
	else
	{
		b_is_invis = 1;
	}

	if( isdefined(level.CurrentGameMode && level.CurrentGameMode == "zm_boss") )
		b_is_invis = 1;

	self SetInvisibleToPlayer(player, b_is_invis);
	return !b_is_invis;
}

function loc_trigger_visibility(player)
{
	level endon("end_game");
	level endon("end_final_tele");

	if( !IS_TRUE(player.in_afterlife) && !player laststand::player_is_in_laststand() )
	{
		self SetHintString( "Hold ^3&&1 ^7to Change Location" );
		b_is_invis = 0;
	}
	else
	{
		b_is_invis = 1;
	}

	self SetInvisibleToPlayer(player, b_is_invis);
	return !b_is_invis;
}

function teleporter_trigger_use()
{
	level endon("end_final_tele");
	level endon("end_game");

	while( isdefined(self) )
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", player);
		if(player zm_utility::in_revive_trigger())
		{
			continue;
		}

		if(!zm_utility::is_player_valid(player))
		{
			continue;
		}

		if( IS_TRUE(player.in_afterlife) )
		{
			continue;
		}

		if( isdefined(self.teleporter_active) )
		{
			continue;
		}

		if( level.disable_final_tele )
		{
			self Delete();
			break;
			//zm_unitrigger::cleanup_trigger( self, player );
		}

		if( player UseButtonPressed() )
		{
			self thread start_teleportation();
		}

	}
}

// self = trigger
function CheckGameMode()
{
	level endon("intermission");
	while(1)
	{
		if(!isdefined(level.CurrentGameMode))
		{
			level waittill("gamemode_chosen");
			if( isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_boss" )
			{
				self Delete();
				break;
			}
		}

		else
		{
			WAIT_SERVER_FRAME;
			if( isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_boss" )
			{
				self Delete();
				break;
			}
		}
	}
}

function location_trigger_use()
{
	while(1)
	{
		self waittill("trigger", player);
		if(player zm_utility::in_revive_trigger())
		{
			continue;
		}

		if(!zm_utility::is_player_valid(player))
		{
			continue;
		}

		if( IS_TRUE(player.in_afterlife) )
		{
			continue;
		}

		self change_active_location();

	}
}

function change_active_location()
{
	level.tele_current_index_main++;
	if(level.tele_current_index_main > 3)
		level.tele_current_index_main = 0;

	PlaySoundAtPosition("zmb_8bit_button_0", self.origin);

	locations = level.tele_locations_main;
	if(!isdefined(locations))
		return;

	level.loc_needle_main RotatePitch(-90, 1);
	wait(1);
	
	//IPrintLn( level.tele_current_index_main );

}

function start_teleportation()
{
	self.teleporter_active = true;

	target_loc = level.tele_locations_main[level.tele_current_index_main];
	if(!isdefined(target_loc))
	{
		target_loc = level.tele_locations_main[0];
		level.loc_needle_main.angles = level.loc_needle_main.defaultpos;
		level.tele_current_index_main = 0;
	}

	temp_room = struct::get_array( "teleporter_temp_struct", "targetname" );

	teleporter_lag = 2.0;
	PlayFX( level._effect["fx_teleporter_beam_factory"], self.origin );
	PlaySoundAtPosition("teleporter_warmup", self.origin);

	players = GetPlayers();
	foreach(player in players)
	{
		if( player_is_near_pad( player ) )
		{
			player SetElectrified( teleporter_lag );
			player.teleporting = true;
		}
	}

	wait( teleporter_lag );

	for( i = 0; i < players.size; i++ )
	{
		if( player_is_near_pad( players[i] ) )
		{
			players[i] thread do_player_teleport( target_loc, temp_room[ i ], i );
		}

		players[i].teleporting = undefined;
		
	}

	self.teleporter_active = undefined;
}

function player_is_near_pad( player )
{
	radius = 88;
	scale_factor = 2;

	dist = Distance2D( player.origin, self.origin );
	dist_touching = radius * scale_factor;

	if ( dist < dist_touching )
	{
		return true;
	}

	return false;
}

function do_player_teleport( target_loc, temp_room, index )	//self = player
{
	targets = struct::get_array( target_loc.target, "targetname" );
	if(!isdefined(targets))
	{
		//IPrintLnBold("Targets not defined");
		return;
	}

	target = targets[index];
	if(!isdefined(target))
	{
		//IPrintLnBold("target not defined");
		return;
	}

	visionset_mgr::activate( "overlay", "zm_factory_teleport", self );

	self clientfield::set_to_player( "player_teleporter_fx", 1 );
	self PlayLocalSound("teleport_loop");

	self DisableOffhandWeapons();
	self DisableWeapons();
	self SetStance("stand");
	self FreezeControls( 1 );

	self.teleport_origin = Spawn("script_model", self.origin);
	self.teleport_origin SetModel("tag_origin");
	self.teleport_origin.angles = self.angles;
	self PlayerLinkToAbsolute(self.teleport_origin, "tag_origin");

	self.teleport_origin.origin = temp_room.origin;
	self.teleport_origin.angles = temp_room.angles;
	util::wait_network_frame();
	self.teleport_origin.angles = temp_room.angles;
	wait(2);
	
	self clientfield::set_to_player( "player_teleporter_fx", 0 );
	PlayFX(level._effect["portal_3p"], target.origin);
	self Unlink();
	PlaySoundAtPosition( "teleporter_beam_fx", target.origin );

	if(isdefined(self.teleport_origin))
	{
		self.teleport_origin Delete();
		self.teleport_origin = undefined;
	}

	self SetOrigin(target.origin);
	self SetPlayerAngles(target.angles);
	self EnableWeapons();
	self EnableOffhandWeapons();
	self FreezeControls( 0 );

	visionset_mgr::deactivate( "overlay", "zm_factory_teleport", self ); // turn off the mid-teleport stargate effects

}

function add_teleporter_location( location )
{
	if(!isdefined(level.tele_locations_main))
	{
		level.tele_locations_main = [];
		respawn_points = struct::get_array("player_respawn_point", "targetname");
		foreach(struct in respawn_points)
		{
			if(isdefined(struct.script_noteworthy) && struct.script_noteworthy == "start_zone" )
				level.tele_locations_main[0] = struct;
		}

	}

	if(!isdefined(location.script_int))
		return;

	switch( location.script_int )
	{
		case 8:		//Dtap teleporter
		level.tele_locations_main[1] = location;
		break;

		case 7:	//Middle teleporter
		level.tele_locations_main[2] = location;
		break;

		case 9:		//Prison teleporter
		level.tele_locations_main[3] = location;
		break;
	}
	
}

