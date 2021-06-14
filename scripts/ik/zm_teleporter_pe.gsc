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
#using scripts\ik\zm_teleporter_pe_main;
#using scripts\zm\_zm_unitrigger;
#using scripts\shared\visionset_mgr_shared;
#using scripts\bosses\zm_hanoi_boss;
//Generator
#using scripts\ik\zm_generators;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_teleporter_pe;

#define TELEPORTER_COST				250		//Teleporter cost
#define TELEPORTER_COOLDOWN			30		//How long until one can use teleporter again
#define TELEPORTER_SPECIAL_PLACE	true 	//Used in Project Elemental, part of the easter egg, true/false
#define TELEPORTER_USE_SPAWNROOM	true 	//Only for Project Elemental, SET THIS TO false otherwise!!!

#precache("fx", "dlc0/factory/fx_teleporter_beam_factory");

#precache("fx", "dlc1/castle/fx_ee_rocket_beam_src_b");

#precache("fx", "dlc0/factory/fx_teleporter_elec_strike" );

//V2 Version. Now players have the ability to change the location where they want to teleport. 

REGISTER_SYSTEM_EX( "zm_teleporter_pe", &init, &main, undefined )

function init()
{
	level._effect["fx_teleporter_beam_factory"] = "dlc0/factory/fx_teleporter_beam_factory";	//fx_ee_rocket_beam_src_bv
	level._effect["fx_ee_rocket_beam_src_b"] = "dlc1/castle/fx_ee_rocket_beam_src_b";	
	level._effect["fx_teleporter_elec_strike"] = "dlc0/factory/fx_teleporter_elec_strike";	

	clientfield::register( "toplayer", "player_teleporter_pe_fx", 1, 1, "int" );
	visionset_mgr::register_info( "overlay", "zm_factory_teleport", 1, 61, 1, true );

	//TeleporterInit();
}

function main()
{
	//Initial setup for teleporters
	level.tele_locations = [];
	respawn_points = struct::get_array("player_respawn_point", "targetname");
	if( !isdefined(respawn_points) )
		return;

	foreach(struct in respawn_points)
	{
		if(isdefined(struct.script_noteworthy) && struct.script_noteworthy == "start_zone" )
			level.tele_locations["spawn"] = struct;
	}

	level.tele_current_location = level.tele_locations["spawn"];
	level.tele_locations["dam"] = undefined;
	level.tele_locations["tele"] = undefined;
	level.tele_locations["prison"] = undefined;

	level.tele_triggers = GetEntArray( "pe_teleporter_trigger", "targetname" );
	if(!isdefined(level.tele_triggers) || level.tele_triggers.size <= 0)
	{
		IPrintLnBold("No Teleporter Triggers Found!");
		return;
	}

	for(i = 0; i < level.tele_triggers.size; i++)
	{
		level.tele_triggers[i].hasBeenUsed = false;
		level.tele_triggers[i].current_location = 0;
		level.tele_triggers[i] thread WatchTeleTrigger();
	}

	level.loc_needle = GetEntArray( "tele_loc_needle", "targetname" );
	if(!isdefined(level.loc_needle))
		return;

	for(i = 0; i < level.loc_needle.size; i++)
	{
		level.loc_needle[i].defaultpos = level.loc_needle[i].angles;
	}
}

function WatchTeleTrigger()		//self = teleporter trigger
{
	level endon("end_game");
	//ADD possible endons here

	self SetHintString( &"ZOMBIE_NEED_POWER" );
	self SetCursorHint( "HINT_NOICON" );

	//Need These so that player can't teleport to places where teleporter is not active
	self.powered = false;
	self.cooldown = false;

	self WaitForPower();

	self CreateLocUnitrigger();

	self.powered = true;
	fxmodel = Spawn("script_model", self.origin);
	fxmodel SetModel("tag_origin");
	PlayFXOnTag(level._effect["fx_teleporter_elec_strike"], fxmodel, "tag_origin");

	cost = TELEPORTER_COST;
	if(isdefined(self.script_noteworthy) && self.script_noteworthy == "main_tele" )
	{
		cost = 0;
	}

	if(isdefined(cost) && cost > 0)
	{
		string = "Hold ^3&&1 ^7To Teleport [Cost: " +cost+ "]";
	}	

	else 
	{
		string = "Hold ^3&&1 ^7To Teleport";
	}

	self SetHintString( string );

	while(1)
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(self.cooldown))
		{
				
			if(isdefined(user.score) && user.score >= cost)
			{
				user zm_score::minus_to_player_score( cost );
				util::wait_network_frame();
				self SetHintString( "Teleporting in Progress..." );
				self thread teleport_nuke( 6, 150 );
				if( IS_TRUE(level.tele_timer) )
				{
					hanoi_room = struct::get("hanoi_room_spawn", "targetname");
					if(isdefined(hanoi_room))
					{
						end_pos = hanoi_room;
					}
				}

				else
				{
					end_pos = self GetTeleporterTarget();
				}

					
				if(!isdefined(end_pos))
				{
					IPrintLnBold("Could Not Set Teleport Location");
					continue;
				}

				util::wait_network_frame();

				if(!IS_TRUE(self.hasBeenUsed))
				{
					self.hasBeenUsed = true;

					str_old_exp = "tele_" + self.script_int + "_red";
					str_new_exp = "tele_" + self.script_int + "_green";
					exploder::kill_exploder( str_old_exp );
					exploder::exploder( str_new_exp );

					num_used = CheckUsedTeleporters();
					if( num_used >= level.tele_triggers.size )
					{
						user PlaySound("tele_power_down");
						WAIT_SERVER_FRAME;
						PlaySoundAtPosition( "egg_done", self.origin );
						level thread zm_project_e_ee::SpawnLightningRock(self.origin + (0, 0, 32));
						zm_powerup_nuke::nuke_powerup( user, level.zombie_team );
						self SetHintString( string );
						continue;
					}

					else
					{
						self DoTeleport( user, end_pos );
					}
				}

				else if( IS_TRUE(self.tele_overload) && !IS_TRUE(level.tele_timer) )
				{
					self DoFakeTeleport( user );
				}

				else
				{
					self DoTeleport( user, end_pos );
				}

				if(IS_TRUE(TELEPORTER_COOLDOWN))
				{
					self thread TeleporterWaitForCoolDown();
					if(end_pos.classname != "script_struct")
					{
						//IPrintLnBold("End Pos deactivated");
						end_pos thread TeleporterWaitForCoolDown();
					}

				}

				if(end_pos.targetname == "wind_room_spawn")
				{
					user thread TempRoomExit( self );
				}
			}

			else
			{
				user zm_audio::create_and_play_dialog( "general", "outofmoney" );
			}
		}

		//self SetHintString( string );
	}
	
}

function CreateLocUnitrigger()	//self = trigger
{
	loc_struct = ArrayGetClosest(self.origin, struct::get_array( "teleporter_location_select", "targetname" ) );
	if(!isdefined(loc_struct))
	{
		IPrintLnBold("locator not found");
		return;
	}

	width = 72;
	height = 72;
	length = 72;
	loc_struct.unitrigger_stub = SpawnStruct();
	loc_struct.unitrigger_stub.origin = loc_struct.origin;
	loc_struct.unitrigger_stub.angles = loc_struct.angles;
	loc_struct.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	loc_struct.unitrigger_stub.cursor_hint = "HINT_NOICON";
	loc_struct.unitrigger_stub.script_width = width;
	loc_struct.unitrigger_stub.script_height = height;
	loc_struct.unitrigger_stub.script_length = length;
	loc_struct.unitrigger_stub.require_look_at = 0;
	loc_struct.unitrigger_stub.prompt_and_visibility_func = &locator_visibility;
	zm_unitrigger::register_static_unitrigger(loc_struct.unitrigger_stub, &locator_use);
}

function locator_visibility( player )
{
	level endon("end_game");
	level endon("end_final_tele");

	if( !IS_TRUE(player.in_afterlife) && !player laststand::player_is_in_laststand() )
	{
		self SetHintString( "Hold ^3&&1 ^7to Change teleport Location" );
		b_is_invis = 0;
	}
	else
	{
		b_is_invis = 1;
	}

	self SetInvisibleToPlayer(player, b_is_invis);
	return !b_is_invis;
}

function locator_use()
{
	self.teleporter = ArrayGetClosest(self.origin, level.tele_triggers);
	self.teleporter.needle = ArrayGetClosest(self.origin, level.loc_needle);

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

		//PlaySoundAtPosition("zmb_8bit_button_0", self.origin);
		self change_active_location( player );

	}
}

function change_active_location( player )
{
	needle = ArrayGetClosest(self.origin, level.loc_needle );
	teleporter = ArrayGetClosest(self.origin, level.tele_triggers );

	teleporter.current_location++; 	//level.tele_current_index++;

	WAIT_SERVER_FRAME;

	if(teleporter.current_location > 3)
		teleporter.current_location = 0;

	if(!isdefined(needle))
		return;

	PlaySoundAtPosition("zmb_8bit_button_0", player.origin);

	needle RotatePitch(-90, 0.6);
	wait(0.6);

	//IPrintLn(teleporter.current_location);
}

function TempRoomExit( old_pos )
{
	time = 10;

	SpawnRandomPowerup();

	wait(time);
	area_trig = GetEntArray("wind_room_area","targetname");
	if(!isdefined(area_trig))
	{
		IPrintLnBold("NO AREA TRIG DEFINED");
		return;
	}

	end_pos = old_pos GetTeleporterTarget( true );

	if(!isdefined(end_pos))
		end_pos = old_pos;

	foreach(trig in area_trig)
	{
		trig thread DoTeleport( self, end_pos );
	}
		
}

function SpawnRandomPowerup()
{
	structs = struct::get_array("teleporter_powerup_struct");
	if(!isdefined(structs))
		return;

	struct = array::random(structs);
	if(isdefined(struct))
	{
		if(isdefined(struct.script_string))
		{
			zm_powerups::specific_powerup_drop( struct.script_string, struct.origin );
		}
	}

}

function TeleporterWaitForCoolDown()
{
	self SetHintString( "Teleporter Cooling Down" );
	self.cooldown = true;
	wait(TELEPORTER_COOLDOWN);
	self.cooldown = false;
	if(isdefined(TELEPORTER_COST) && TELEPORTER_COST > 0)
	{
		string = "Hold ^3&&1 ^7To Teleport [Cost: " +TELEPORTER_COST+ "]";
	}	

	else 
	{
		string = "Hold ^3&&1 ^7To Teleport";
	}

	self SetHintString( string );

}

function teleport_nuke( max_zombies, range )
{
	zombies = GetAISpeciesArray( level.zombie_team );
	zombies = util::get_array_of_closest( self.origin, zombies, undefined, max_zombies, range );

	for (i = 0; i < zombies.size; i++)
	{
		wait (randomfloatrange(0.2, 0.3));
		if( !IsDefined( zombies[i] ) )
		{
			continue;
		}

		if( zm_utility::is_magic_bullet_shield_enabled( zombies[i] ) )
		{
			continue;
		}

		if(IS_TRUE(zombies[i].is_boss))
		{
			continue;
		}

		if( !( zombies[i].isdog ) )
		{
			zombies[i] zombie_utility::zombie_head_gib();
		}

		zombies[i] DoDamage( zombies[i].health + 666, zombies[i].origin );
		PlaySoundAtPosition( "nuked", zombies[i].origin );
	}
}

function WaitForPower()
{
	if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic"))
	{
		wait(1);
	}

	else if( IsDefined( self.script_int ) )
	{
		level flag::wait_till( "power_on" + self.script_int );
		
		if( !zm_utility::check_point_in_enabled_zone( self.origin ) )
		{
			while( !zm_utility::check_point_in_enabled_zone( self.origin ) )
			{
				WAIT_SERVER_FRAME;
			}
		}

		add_teleporter_location( self );
		zm_teleporter_pe_main::add_teleporter_location( self );

		string_exp = "tele_" + self.script_int + "_red";
		exploder::exploder( string_exp );
	
	}

	else
	{	
		level flag::wait_till( "power_on" );
	}
}

function DoTeleport( user, end_pos )
{
	target_loc = struct::get_array( end_pos.target, "targetname" );
	temp_room = struct::get_array( "teleporter_temp_struct", "targetname" );

	b_time_travel = false;

	PlayFX( level._effect["fx_teleporter_beam_factory"], self.origin );
	PlaySoundAtPosition("teleporter_warmup", self.origin);
	teleporter_lag = 2.0;

	players = self GetPlayersTouchingTele();
	if(players.size == GetPlayers().size)
	{
		if(IS_TRUE(level.tele_timer))
		{
			level notify("all_player_teleport");
			for(i = 0; i < players.size; i++)
			{
				players[i] EnableInvulnerability();
				players[i] FreezeControls( true );
				players[i] thread zm_hanoi_boss::FadeToBlack( 4, 1.5 );
				level notify("tele_code_correct");
				level.tele_timer = false;
				b_time_travel = true;
			}
		}
		
	}

	for(i = 0; i < players.size; i++)
	{
		players[i] SetElectrified( teleporter_lag );
		
	}

	wait( teleporter_lag );

	players = self GetPlayersTouchingTele();
	for(i = 0; i < players.size; i++)
	{
		if( self player_near_pad( players[i] ) )
		{
			players[i] thread do_player_teleport( target_loc, temp_room[ i ], i, b_time_travel );

		}
	}	
}

function do_player_teleport( target_loc, temp_room, index, b_time_travel = false )	//self = player
{
	target = target_loc[index];
	if(!isdefined(target))
	{
		//IPrintLnBold("target not defined with index: " +index );
		return;
	}

	visionset_mgr::activate( "overlay", "zm_factory_teleport", self );

	self clientfield::set_to_player( "player_teleporter_pe_fx", 1 );
	if(b_time_travel)
		self PlayLocalSound("teleport_timetravel");

	else
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
	
	self clientfield::set_to_player( "player_teleporter_pe_fx", 0 );
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
	target thread teleport_nuke( 6, 150);

	WAIT_SERVER_FRAME;

	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_teleport_0" + RandomInt(3);
	self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
}

function PlayTeleporterFakeFx( b_playSound = true )	//used for cutscenes, self = player
{
	visionset_mgr::activate( "overlay", "zm_factory_teleport", self );

	self clientfield::set_to_player( "player_teleporter_pe_fx", 1 );

	if(b_playSound)
		self PlayLocalSound("teleport_loop");

	wait(2);

	self clientfield::set_to_player( "player_teleporter_pe_fx", 0 );
	PlayFX(level._effect["portal_3p"], self.origin);

	if(b_playSound)
		PlaySoundAtPosition( "teleporter_beam_fx", self.origin );
		
	visionset_mgr::deactivate( "overlay", "zm_factory_teleport", self ); // turn off the mid-teleport stargate effects
}

function DoFakeTeleport( user )
{
	teleporter_lag = 2.0;
	teleporter_overload_time = 6.0;

	fxmodel = Spawn("script_model", self.origin);
	fxmodel SetModel("tag_origin");
	fxmodel.angles = ( 270, 0, 0 );
	PlayFXOnTag( level._effect["fx_ee_rocket_beam_src_b"], fxmodel, "tag_origin" );
	self thread FakeTeleportMonitorPlayers();

	PlaySoundAtPosition("teleporter_warmup", self.origin);

	wait( teleporter_lag );
	PlaySoundAtPosition("tele_overload", self.origin);

	wait(teleporter_overload_time);
	PlaySoundAtPosition("tele_power_down", self.origin);

	structs = struct::get_array(self.target,"targetname");
	spawn = structs[0];

	fxmodel Delete();
	self notify("overload_over");

}

function FakeTeleportMonitorPlayers()
{
	self endon("overload_over");
	while(1)
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			if(players[i] IsTouching(self) && !IS_TRUE(players[i].playing_fx))
			{
				players[i] thread PlayerTeleOverloadEffects();
			}
		}
	}
}

function PlayerTeleOverloadEffects()
{
	time = 1.5;
	self.playing_fx = true;
	self SetElectrified( time );
	self ShellShock( "electrocution", time );
	self DoDamage( 20, self.origin );
	self PlaySound( "wpn_tesla_bounce" );
	wait( time );
	self.playing_fx = undefined;
}


function GetTeleporterTarget( exclude_temp_room = false )
{
	//If we have temp room active, check if this should be a temp room teleportation
	if(IS_TRUE(TELEPORTER_SPECIAL_PLACE))
	{
		if(!exclude_temp_room)
		{
			temp_room = struct::get("wind_room_spawn", "targetname");
			rand = RandomInt(4);
			if(rand == 0)
			{
				return temp_room;
			}
		}	
	}

	if(level.tele_timer) 		//If the teleporter code has been activated, teleport the players to Hanoi
	{
		hanoi_room = struct::get("hanoi_room_spawn", "targetname");
		if(isdefined(hanoi_room))
		{
			//IPrintLnBold("Teleporting to hanoi room");
			return hanoi_room;
		}
	}

	index = self.current_location;

	switch(index)
	{
		case 0:
		targetpos = level.tele_locations[ "spawn" ];
		//IPrintLn("Target: Spawn");
		break;

		case 1:
		targetpos = level.tele_locations[ "dam" ];
		//IPrintLn("Target: Dam");
		break;

		case 2:
		targetpos = level.tele_locations[ "tele" ];
		//IPrintLn("Target: Tele");
		break;

		case 3:
		targetpos = level.tele_locations[ "prison" ];
		//IPrintLn("Target: Prison");
		break;

		default:
		targetpos = level.tele_locations[ "spawn" ];
		break;
	}

	if( !isdefined(targetpos) || (isdefined(targetpos) && targetpos == self) )	//if the user is trying to teleport to an inactive / current teleporter, teleport him to spawn instead
	{
		//IPrintLnBold("Target pos: Start room");
		needle = ArrayGetClosest( self.origin, level.loc_needle );
		needle.angles = needle.defaultpos;
		self.current_location = 0;
		return level.tele_locations["spawn"]; 		//This is predefined in init()
	}

	else
	{
		return targetpos;
	}

}

function GetPlayersTouchingTele()
{
	touching = [];

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		WAIT_SERVER_FRAME;
		if( self player_near_pad( players[i] ) || players[i] IsTouching(self) || players[i] InWindArea() )
		{
			if(!IS_TRUE(players[i].in_afterlife))
				touching[touching.size] = players[i];
		}
	}

	return touching;
}

function InWindArea()	//self = player
{
	wind_room_area = GetEntArray("wind_room_area", "targetname");
	foreach(area in wind_room_area)
	{
		if(self IsTouching( area ))
			return true;
	}

	return false;
}

function player_near_pad( player )
{
	radius = 80;
	scale_factor = 2;

	dist = Distance2D( player.origin, self.origin );
	dist_touching = radius * scale_factor;

	//IPrintLnBold("dist : " +dist);
	//IPrintLnBold("dist tocuhing: " + dist_touching);

	if ( dist < dist_touching )
	{
		if(!IS_TRUE(player.in_afterlife))
		{
			return true;
		}
	}

	if( player InWindArea() )
	{
		return true;
	}

	return false;
}

function CheckUsedTeleporters()
{
	used = 0;

	for(i = 0; i < level.tele_triggers.size; i++)
	{
		if(IS_TRUE(level.tele_triggers[i].hasBeenUsed))
			used++;
	}

	return used;

}

function add_teleporter_location( location )
{
	if(!isdefined(level.tele_locations))
	{
		level.tele_locations = [];
		respawn_points = struct::get_array("player_respawn_point", "targetname");
		foreach(struct in respawn_points)
		{
			if(isdefined(struct.script_noteworthy) && struct.script_noteworthy == "start_zone" )
				level.tele_locations["spawn"] = struct;
		}

	}

	if(!isdefined(location.script_int))
		return;

	switch( location.script_int )
	{
		case 8:		//Dtap teleporter
		level.tele_locations["dam"] = location;
		break;

		case 7:	//Middle teleporter
		level.tele_locations["tele"] = location;
		break;

		case 9:		//Prison teleporter
		level.tele_locations["prison"] = location;
		break;
	}
	
}

