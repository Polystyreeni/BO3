/*==========================================
Project Elemental Easter Egg 
By ihmiskeho
Contains pretty much the entire easter egg of the map

Credits:
JBird632: Hud element
HarryBo21 = Script help 
Abnormal202: Some basic functions and syntax help
Mathfag = Zombie spawn help
NateSmithZombies = Script Help
Symbo = Local power help
============================================*/
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
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\shared\ai\zombie_utility;	
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_power;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\zm_afterlife_pe;
#using scripts\ik\zm_teleporter_pe;
#using scripts\zm\_zm_ai_dogs;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\_hb21_sym_zm_trap_acid;
#using scripts\shared\math_shared;
#using scripts\shared\lui_shared;
#using scripts\zm\zm_project_e_music;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\bosses\zm_ai_reverant;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\bosses\zm_hanoi_boss;
#using scripts\ik\zm_teleporter_pe_main;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\zm\_zm_zonemgr;
#using scripts\ik\zm_weapon_wind;

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

//Boss fight
#using scripts\bosses\zm_cyber;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_acid.gsh;
#insert scripts\zm\_zm_weap_gravityspikes.gsh;


#precache("model", "p6_zm_buildable_sq_meteor_fire");
#precache("model", "p6_zm_buildable_sq_meteor_ice");
#precache("model", "p6_zm_buildable_sq_meteor_lightning");
#precache("model", "p6_zm_buildable_sq_meteor_wind");
#precache( "model", "p6_zm_buildable_sq_meteor_obj" );

#precache("model", "pent_defcon_0");
#precache("model", "pent_defcon_1");
#precache("model", "pent_defcon_2");
#precache("model", "pent_defcon_3");
#precache("model", "pent_defcon_4");
#precache("model", "pent_defcon_5");
#precache("model", "pent_defcon_6");
#precache("model", "pent_defcon_7");
#precache("model", "pent_defcon_8");
#precache("model", "pent_defcon_9");

#precache("model", "p7_board_circuit_03");
#precache("model", "zm_115_meteor_tree");
#precache("model", "zm_115_meteor1");
#precache("model", "p7_sgen_cable_connectors_03b");
#precache("model", "p7_zm_ori_artifact_piece_01");
#precache("model", "pbk_foliage_tree_acacia_01_burnt");
#precache("model", "p7_fxanim_zm_zod_summoning_key_mod");
#precache("model", "satellite_code_00");
#precache("model", "satellite_code_00_emissive");
#precache("model", "satellite_code_01");
#precache("model", "satellite_code_01_emissive");
#precache("model", "satellite_code_02");
#precache("model", "satellite_code_02_emissive");
#precache("model", "p7_zm_zod_skull_fire");	//
#precache("model", "p7_zm_zod_skull_dark");
#precache("model", "p7_chemistry_kit_flask");
#precache("model", "p7_animal_testing_container_broken_b");
#precache("model", "c_rus_scientist_body_ghost");

#precache("fx", "dlc4/genesis/fx_rune_glow_purple");
#precache("fx", "dlc5/zmb_weapon/fx_staff_charge_souls");
#precache("fx", "explosions/fx_exp_molotov_lotus");
#precache("fx", "project_elemental/fx_ritual_black");
#precache("fx", "dlc5/tomb/fx_tomb_elem_reveal_ice_glow");
#precache("fx", "dlc2/island/fx_bucket_115_glow");
#precache("fx", "dlc1/zmb_weapon/fx_bow_storm_trail_zmb");
#precache("fx", "dlc5/tomb/fx_glow_biplane_trail");
#precache("fx", "dlc1/castle/fx_elec_teleport_flash_sm");
#precache("fx", "dlc2/zmb_weapon/fx_skull_quest_cleanse_glow_island");
#precache("fx", "dlc3/stalingrad/fx_fire_spot_xxsm");
#precache("fx", "dlc3/stalingrad/fx_elec_sparks_loop_blue_1x1");
#precache("fx", "dlc5/tomb/fx_115_generator_tesla_kill");	//fx/light/fx_light_flashing_red_factory_zmb

//New
#precache("fx", "dlc3/stalingrad/fx_fire_inferno_tall_1_evb_md_stalingrad");
#precache("fx", "fire/fx_fire_side_lrg");
#precache("fx", "light/fx_light_flashing_red_factory_zmb");	//dlc0/factory/fx_laserbeam_long_factory
#precache("fx", "dlc0/factory/fx_laserbeam_long_factory");	//custom/fx_laserbeam_custom_long
#precache("fx", "custom/fx_laserbeam_custom");
#precache("fx", "custom/fx_laserbeam_custom_long");
#precache("fx", "dlc1/castle/fx_elec_jumppad_amb_ext_ring");
#precache("fx", "dlc5/asylum/fx_power_off_elec_beam_low");
#precache("fx", "dlc1/castle/fx_elec_teleport_flash_lg");
#precache("fx", "fire/fx_fire_barrel_30x30");
#precache("fx", "zombie/fx_ee_explo_ritual_zod_zmb");
#precache("fx", "dlc5/tomb/fx_weather_vortex");
#precache("fx", "custom/fx_satellite_hint");
#precache("fx", "explosions/fx_exp_grenade_water");
#precache("fx", "zombie/fx_ritual_pap_basin_fire_zod_zmb");
#precache("fx", "zombie/fx_ritual_gatestone_explosion_zod_zmb");

#define LIGHTNING_STORM									"dlc1/zmb_weapon/fx_bow_storm_funnel_loop_zmb"
#precache( "fx", LIGHTNING_STORM ); 

#define WIND_PROJ									"custom/fx_wind_tornado"
#precache( "fx", WIND_PROJ ); 

#define FX_RITUAL_EXPLODE	"zombie/fx_ritual_gatestone_explosion_zod_zmb"

#namespace zm_project_e_ee;

#using_animtree( "generic" ); 

REGISTER_SYSTEM_EX( "zm_project_e_ee", &init, &main, undefined )

/*
List of notifies used in this script:
-tele_code_correct. Used on: level
-upgrade_received. Used on normal elemental triggers
-escort_failed. Used on meteor model

*/

function init()
{
	zm_spawner::add_custom_zombie_spawn_logic( &SoulChestZombieDeath );

	//Init vars
	level.fire_collected = false;
	level.ice_collected = false;
	level.wind_collected = false;
	level.lightning_collected = false;

	level.teleporter_parts = 0;
	level.overloads_done = 0;
	level.fire_objects_active = 0;
	level.tele_timer = false;
	level.disable_final_tele = 0;

	level.num1 = RandomIntRange(1,10);
	level.num2 = RandomIntRange(0,10);
	level.num3 = RandomIntRange(0,10);

	level.telecode = "" +level.num1 + "" +level.num2 + "" +level.num3;

	level.telecode_perk = false;
	level.telecode_spawned_bosses = false;
	level.telecode_finished = false;

	level.icepart_spawned = false;
	level.icepart_can_spawn = false;
	level.spawn_fire_zombies = false;

	level.sm_is_speaking = false;

	level.debug_print = false;

	//V2 stone models that can be charged with souls
	level.chargable_meteors = [];

	RegisterClietFields();
	InitFX();

}

function RegisterClietFields()
{
	//UI Clientfields
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_lightning",	VERSION_SHIP, 2, "int", undefined, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_fire",	VERSION_SHIP, 2, "int", undefined, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_wind", VERSION_SHIP, 2, "int", undefined, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_ice", VERSION_SHIP, 2, "int", undefined, false );
	
	//V2: Clientfieds
	clientfield::register( "scriptmover", "tele_charge_hint", VERSION_SHIP, 2, "int" );
	clientfield::register( "scriptmover", "fire_path_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "fire_ritual_fx", VERSION_SHIP, 2, "int" );
	clientfield::register( "scriptmover", "final_tele_portal", VERSION_SHIP, 1, "int" );
}

function InitFX()
{
	//Loading FX Effects
	level._effect["fx_rune_glow_purple"] = "dlc4/genesis/fx_rune_glow_purple";
	level._effect["fx_staff_charge_souls"] = "dlc5/zmb_weapon/fx_staff_charge_souls";
	level._effect["fx_exp_molotov_lotus"] = "explosions/fx_exp_molotov_lotus";
	level._effect["fx_ritual_black"] = "project_elemental/fx_ritual_black";
	level._effect["fx_tomb_elem_reveal_ice_glow"] = "dlc5/tomb/fx_tomb_elem_reveal_ice_glow";
	level._effect["fx_bucket_115_glow"] = "dlc2/island/fx_bucket_115_glow";
	level._effect["fx_bow_storm_trail_zmb"] = "dlc1/zmb_weapon/fx_bow_storm_trail_zmb";
	level._effect["fx_glow_biplane_trail"] = "dlc5/tomb/fx_glow_biplane_trail";
	level._effect["fx_elec_teleport_flash_sm"] = "dlc1/castle/fx_elec_teleport_flash_sm";
	level._effect["fx_skull_quest_cleanse_glow_island"] = "dlc2/zmb_weapon/fx_skull_quest_cleanse_glow_island";
	level._effect["fx_fire_spot_xxsm"] = "dlc3/stalingrad/fx_fire_spot_xxsm";
	level._effect["fx_elec_sparks_loop_blue_1x1"] = "dlc3/stalingrad/fx_elec_sparks_loop_blue_1x1";
	level._effect["fx_115_generator_tesla_kill"] = "dlc5/tomb/fx_115_generator_tesla_kill";

	level._effect["fx_fire_inferno_tall_1_evb_md_stalingrad"] = "dlc3/stalingrad/fx_fire_inferno_tall_1_evb_md_stalingrad";
	level._effect["fx_fire_side_lrg"] = "fire/fx_fire_side_lrg";
	level._effect["fx_light_flashing_red_factory_zmb"] = "light/fx_light_flashing_red_factory_zmb";	//dlc0/factory/fx_laserbeam_long_factory
	level._effect["fx_laserbeam_custom"] = "custom/fx_laserbeam_custom";
	level._effect["fx_laserbeam_custom_long"] = "custom/fx_laserbeam_custom_long";
	level._effect["fx_elec_jumppad_amb_ext_ring"] = "dlc1/castle/fx_elec_jumppad_amb_ext_ring";
	level._effect["fx_power_off_elec_beam_low"] = "dlc5/asylum/fx_power_off_elec_beam_low";
	level._effect["fx_elec_teleport_flash_lg"] = "dlc1/castle/fx_elec_teleport_flash_lg";
	level._effect["fx_fire_barrel_30x30"] = "fire/fx_fire_barrel_30x30";
	level._effect["fx_ee_explo_ritual_zod_zmb"] = "zombie/fx_ee_explo_ritual_zod_zmb";
	level._effect["fx_weather_vortex"] = "dlc5/tomb/fx_weather_vortex";
	level._effect["fx_satellite_hint"] = "custom/fx_satellite_hint";
	level._effect["fx_exp_grenade_water"] = "explosions/fx_exp_grenade_water";
	level._effect["fx_ritual_pap_basin_fire_zod_zmb"] = "zombie/fx_ritual_pap_basin_fire_zod_zmb";
}

function DebugPrint( text )
{
	if(IS_TRUE(level.debug_print))
	{
		IPrintLnBold( text );
	}
}

function main()
{
	WAIT_SERVER_FRAME;
	level flag::init("boss_fight");
	level flag::init("mid_boss_fight");

	callback::on_connect( &SetUpNumbers );
	//callback::on_connect( &SetUpCollectables );

	level flag::wait_till("initial_blackscreen_passed");

	numbers = GetEntArray("afterlife_numbers", "targetname");
	if(!isdefined(numbers))
	{
		DebugPrint("Numbers not found");
		return;
	}

	for(i = 0; i < numbers.size; i++)
	{
		if(i == 0)
		{
			num_to_add = level.num1;
		}

		else if(i == 1)
		{
			num_to_add = level.num2;
		}

		else
		{
			num_to_add = level.num3;
		}
		numbers[i] SetModel( "afterlife_number_" +num_to_add );
		//numbers[i] SetInvisibleToAll();
	}

	level waittill("gamemode_chosen");
	if( isdefined(level.CurrentGameMode) && ( level.CurrentGameMode != "zm_gungame" ) )
	{
		level thread FireMeteor();

		ww_triggers = GetEntArray("spell_trigger" , "targetname");
		if(!isdefined(ww_triggers))
		{
			IPrintLnBold("No ww_triggers FOUND!");
			return;
		}

		for(i = 0; i < ww_triggers.size; i++)
		{
			ww_triggers[i] thread WatchForPlacement();
		}
	}

	else
	{
		level thread DeleteQuestTriggers();
	}

	level thread LavaTrap();
	level thread LaserTrap();
	level thread StoryRadios();
	level thread PermaPowerups();
	level thread AfterlifeCollectables();
	level thread NumberTeleWires( false );

	level thread SpikeDestructibles();

	// Leave these, for Bossbattles gamemode
	level thread HanoiArenaInit();
	level thread BossFightInit();

	level thread SmRoundVox();
	level thread AreaQuotes();

}

function PermaPowerups()
{
	structs = struct::get_array("perma_powerup_struct", "targetname");
	if(!isdefined(structs))
		return;

	for(i = 0; i < structs.size; i++)
	{
		powerup = structs[i].script_string;
		if(isdefined(powerup))
		{
			zm_powerups::specific_powerup_drop( powerup, structs[i].origin - (0, 0, 40), undefined, undefined, undefined, undefined, true );
		}
	}
}

function AreaQuotes()
{
	areas = GetEntArray("quote_area", "targetname");

	if(!isdefined(areas))
		return;

	foreach(area in areas)
	{
		area thread WaitForPlayerEnter();
	}
}

function WaitForPlayerEnter()	//self = area
{
	level endon("end_game");

	string = undefined;

	for(;;)
	{
		self waittill("trigger", user);
		if(IsPlayer(user) && !IS_TRUE(user.in_afterlife))
		{
			string = self.script_string;
			if(isdefined(string))
			{
				sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_location_" + string + "_00";
				user thread CustomPlayerQuote( sound_to_play );
			}

			break;
		}
	}

	self Delete();
}

function StoryRadios()
{
	radios = GetEntArray("radio_trigger","targetname");
	if(!isdefined(radios) || radios.size < 1)
		return;

	for(i = 0; i < radios.size; i++)
	{
		radios[i] thread WatchRadioActivation();
	}
}

function WatchRadioActivation()
{
	self SetCursorHint("HINT_NOICON");

	while(1)
	{
		self waittill("trigger", user);
		if(IsPlayer(user))
			break;
	}

	sound_to_play = self.script_sound;
	if(!isdefined(sound_to_play))
	{
		return;
	}

	PlaySoundAtPosition( sound_to_play, self.origin );
	wait( GetRealPlayBackTime(sound_to_play) );
	self Delete();
}

function GetRealPlayBackTime( sound_to_play )
{
	if(!isdefined(sound_to_play))
		return 0;

	playbackTime = SoundGetPlaybackTime( sound_to_play );
		
	if( !isdefined( playbackTime ) )
		return;
		
	if ( playbackTime >= 0 )
	{
		playbackTime = playbackTime * .001;
	}
	else
	{
		playbackTime = 1;
	}

	return playbackTime;
}

function DeleteQuestTriggers()
{
	ww_triggers = GetEntArray("spell_trigger" , "targetname");
	if(!isdefined(ww_triggers))
	{
		return;
	}

	for(i = 0; i < ww_triggers.size; i++)
	{
		ww_triggers[i] Delete();
	}
}

function SpawnWindRock( origin )
{
	if( IS_TRUE(level.wind_collected) )
		return;

	if(!isdefined(origin))
		return;

	if( isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame" )
		return;

	meteor = Spawn("script_model", origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_wind");
	meteor thread zm_powerups::powerup_wobble();
	meteor.trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	meteor.trigger SetHintString( "Hold ^3&&1 ^7To Pick up Stone of Wind" );
	meteor.trigger SetCursorHint( "HINT_NOICON" );

	while(isdefined(meteor))
	{
		WAIT_SERVER_FRAME;
		meteor.trigger waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() )
		{
			meteor.trigger Delete();
			PlaySoundAtPosition("zmb_perks_vulture_money", meteor.origin);
			PlayFX(level._effect["powerup_grabbed_solo"], meteor.origin);
			WAIT_SERVER_FRAME;
			meteor Delete();
			level.wind_collected = true;
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_0" + RandomInt(2);
			user thread CustomPlayerQuote( sound_to_play );
			clientfield::set( "p6_zm_buildable_sq_meteor_wind", 1 );
		}
	}
}

function SpawnLightningRock( origin )
{
	if(!isdefined(origin))
	{
		return;
	}

	if( isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame" )
		return;

	meteor = Spawn("script_model", origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_lightning");
	meteor thread zm_powerups::powerup_wobble();
	meteor.trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	meteor.trigger SetHintString( "Hold ^3&&1 ^7To Pick up Stone of Lightning" );
	meteor.trigger SetCursorHint( "HINT_NOICON" );

	while(isdefined(meteor))
	{
		WAIT_SERVER_FRAME;
		meteor.trigger waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() )
		{
			meteor.trigger Delete();
			PlaySoundAtPosition("zmb_perks_vulture_money", meteor.origin);
			PlayFX(level._effect["powerup_grabbed_solo"], meteor.origin);
			WAIT_SERVER_FRAME;
			meteor Delete();
			level.lightning_collected = true;
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_0" + RandomInt(2);
			user thread CustomPlayerQuote( sound_to_play );
			clientfield::set( "p6_zm_buildable_sq_meteor_lightning", 1 );
		}
	}
}

function BossFightAreaWatcher()
{
	self endon("disconnect");
	while(1)
	{
		wait(.1);
		if(!self IsInBossRoom())
		{
			target = struct::get("boss_fight_spawn", "targetname");
			if(!isdefined(target))
					return;

			spawns = struct::get_array(target.target, "targetname");
			spawn = array::random(spawns);
			self SetOrigin(spawn.origin);
		}
	}
}

function FireMeteor()
{
	meteor = GetEnt("fire_meteor","targetname");
	if(!isdefined(meteor))
	{
		return;
	}

	meteor SetScale(1.4);

	souls_filled = 0;

	while(souls_filled < 8)	//CHANGE THIS
	{
		level waittill("trap_kill", ai, trap);
		if(Distance(ai.origin, meteor.origin ) < 250)
		{
			soul = Spawn( "script_model", ai GetTagOrigin("j_spine4") );
			if( !isdefined(soul) )
				return;

			soul SetModel("tag_origin");
			WAIT_SERVER_FRAME;
			PlayFXOnTag( level._effect["fx_staff_charge_souls"], soul, "tag_origin" );
			soul MoveTo( meteor.origin, 1 );
			soul waittill( "movedone" );
			soul Delete();
			meteor PlaySound("zmb_perks_vulture_pickup");
			meteor MoveZ(2, 0.5);
			souls_filled++;
		}
	}

	meteor MoveZ(30, 0.2);
	meteor thread zm_powerups::powerup_wobble();

	meteor.trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	meteor.trigger SetHintString( "Hold ^3&&1 ^7To Pick up Stone of Fire" );
	meteor.trigger SetCursorHint( "HINT_NOICON" );
	while(1)
	{
		WAIT_SERVER_FRAME;
		meteor.trigger waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			meteor.trigger Delete();
			PlaySoundAtPosition("zmb_perks_vulture_money", meteor.origin);
			PlayFX(level._effect["powerup_grabbed_solo"], meteor.origin);
			WAIT_SERVER_FRAME;
			meteor Delete();
			level.fire_collected = true;
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_0" + RandomInt(2);
			user thread CustomPlayerQuote( sound_to_play );

			clientfield::set( "p6_zm_buildable_sq_meteor_fire", 1 );
		}
	}
}

function LavaTrap()
{
	trigs = GetEntArray("lava_trigger", "targetname");
	if(!isdefined(trigs))
	{
		return;
	}

	for(i = 0; i < trigs.size; i++)
	{
		trigs[i] thread WatchLavaTrigger();
	}
}

function WatchLavaTrigger()	//EDIT: Add EE stuff here
{
	level endon("end_game");
	self.boss_battle = false;

	while(1)
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", user);
		if(IsPlayer(user) && user IsTouching(self))
		{
			if(level.teleporter_parts >= 7)
			{
				self.boss_battle = true;
				if(IS_TRUE(user.in_afterlife))
				{
					players = GetPlayers();
					target = struct::get("boss_fight_spawn", "targetname");
					if(!isdefined(target))
						return;

					spawns = struct::get_array(target.target, "targetname");
					for(i = 0; i < players.size; i++)
					{
						players[i] thread PlayerEnterFight( i, spawns );		
					}

					return;
				}
			}

			else
			{
				if(self.boss_battle)
				{
					players = GetPlayers();
					target = struct::get("boss_fight_spawn", "targetname");
					if(!isdefined(target))
						return;

					spawns = struct::get_array(target.target, "targetname");
					for(i = 0; i < players.size; i++)
					{
						lui::screen_flash( 0.2, 0.5, 1.0, 0.8, "white" ); // flash
						players[i] SetOrigin(spawns[i].origin);
						wait(.5);
						//players[i] notify("afterlife_done");
					}
				}

				if( !IS_TRUE(user.in_afterlife) && !self.boss_battle )
				{
					user DoDamage(user.health + 666, user.origin);
				}

				target = struct::get(self.target, "targetname");
				if(isdefined(target))
				{
					user SetOrigin(target.origin);
				}
			}
		}
	}
}

function PlayerEnterFight( i, spawns )
{
	self thread FadeToBlack( 0.5, 3 );
	self SetOrigin(spawns[i].origin);
	self SetPlayerAngles(spawns[i].angles);
	wait(.5);
	self notify("afterlife_done");
	self thread BossFightAreaWatcher();
}

function IsInBossRoom()
{
	area = GetEntArray("timewarp_excluded", "targetname");
	for(i = 0; i < area.size; i++)
	{
		if(self IsTouching(area[i]))
			return true;
	}

	return false;
}

function WatchForPlacement()		//self = ww_trigger, self.target = script_struct
{
	level endon("end_game");

	switch(self.script_noteworthy)
	{
		case "spell_ice":
		string = "Stone of Ice";
		//required_meteor = level.ice_collected;
		break;

		case "spell_wind":
		string = "Stone of Wind";
		//required_meteor = level.wind_collected;
		break;

		case "spell_lightning":
		string = "Stone of Lightning";
		//required_meteor = level.lightning_collected;
		break;

		case "spell_fire":
		string = "Stone of Fire";
		//required_meteor = level.fire_collected;
		break;

		default:
		string = "Stone of Ice";
		//required_meteor = level.ice_collected;
		break;
	}

	self SetHintString( "Hold ^3&&1 ^7To Place " + string );
	self SetCursorHint( "HINT_NOICON" );
	struct = struct::get( self.target, "targetname" );
	if(!isdefined(struct))
	{
		IPrintLnBold("No Target Set to ww_trigger");
		return;
	}

	meteor_model = util::spawn_model( "p6_zm_buildable_sq_meteor_obj", struct.origin );

	while(1)
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) )
		{
			required_meteor = CheckIfCurrentMeteor(self.script_noteworthy);
			if(required_meteor)
			{
				switch(self.script_noteworthy)
				{
					case "spell_wind":
					meteor_model SetModel("p6_zm_buildable_sq_meteor_wind");
					break;

					case "spell_lightning":
					meteor_model SetModel("p6_zm_buildable_sq_meteor_lightning");
					break;

					case "spell_ice":
					meteor_model SetModel("p6_zm_buildable_sq_meteor_ice");
					break;

					case "spell_fire":
					meteor_model SetModel("p6_zm_buildable_sq_meteor_fire");
					break;

					default:
					meteor_model SetModel("p6_zm_buildable_sq_meteor_ice");
					break;

				}

				PlayFXOnTag(level._effect["fx_rune_glow_purple"], meteor_model, "tag_origin");	//EDIT: Maybe change the colors of these
				meteor_model thread ModelRotate();
				
				meteor_model.trigger = Spawn("trigger_radius", meteor_model.origin, 0, 32, 32);
				meteor_model.trigger SetCursorHint( "HINT_NOICON" );
				meteor_model.trigger.script_noteworthy = self.script_noteworthy;

				level.chargable_meteors[level.chargable_meteors.size] = meteor_model;

				meteor_model thread WatchForUpgrade( meteor_model.trigger );

				meteor_model.trigger thread WonderWeaponTriggerWatch( string );
				if(level.CurrentGameMode != "zm_classic" && level.CurrentGameMode != "zm_boss" )
				{
					meteor_model.trigger thread WonderWeaponUpgradeInit( self.script_noteworthy );
				}

				WAIT_SERVER_FRAME;
				self Delete();
				
				break;
			}

			else
			{
				self SetHintString( "Missing the Correct Stone" );
				wait(1);
				self SetHintString( "Hold ^3&&1 ^7To Place " + string );
			}
		}
	}
}

function WatchForUpgrade( trigger )
{
	level endon("end_game");

	trigger waittill("upgrade_received");
	ArrayRemoveValue( level.chargable_meteors, self );
	self Delete();
}

function ModelRotate()
{
	level endon("end_game");
	self endon("death");

	while(isdefined(self))
	{
		self RotateYaw(360, 1);
		wait(1);
	}
}

function CheckIfCurrentMeteor( script_noteworthy )
{
	switch(script_noteworthy)
	{
		case "spell_ice":
		//string = "Stone of Ice";
		required_meteor = level.ice_collected;
		break;

		case "spell_wind":
		//string = "Stone of Wind";
		required_meteor = level.wind_collected;
		break;

		case "spell_lightning":
		//string = "Stone of Lightning";
		required_meteor = level.lightning_collected;
		break;

		case "spell_fire":
		//string = "Stone of Fire";
		required_meteor = level.fire_collected;
		break;

		default:
		//string = "Stone of Ice";
		required_meteor = level.ice_collected;
		break;
	}

	if(required_meteor == true)
	{
		return true;
	}

	return false;
}

function WonderWeaponTriggerWatch( string, is_upgraded = false )
{
	level endon("end_game");		//EDIT: Add endons, when players get the ug version

	if(!IS_TRUE(is_upgraded))
	{
		self endon("upgrade_received");
	}
	
	hint = "Hold ^3&&1 ^7To Take " +string;
	
	if( isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss") )	 // Classic Mode doesn't have upgrade quests, so just use the upgraded ones as default
	{
		trigweapon = GetWeapon( self.script_noteworthy +"_ug" );
	}

	else
	{
		trigweapon = GetWeapon( self.script_noteworthy );
	}
	
	should_update_hint = false;
	old_user = undefined;
	self SetHintString(hint);
	self.ammo = 35;			//EDIT: change ammo to its corresponding clip size
	self.maxammo = 35;

	while(1)
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", user);
				
		if(user != old_user)
		{
			should_update_hint = true;
			old_user = user;
		}

		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && !user zm_utility::has_powerup_weapon())
		{
			if(AnyPlayerHasWeapon(trigweapon))
			{
				currentWeapon = user GetCurrentWeapon();
				if(currentWeapon == trigweapon)
				{
					self SetHintString( "Hold ^3&&1 ^7To Return Stone" );
					should_update_hint = true;
					if(user UseButtonPressed())
					{
						//IPrintLnBold("Taking weapon");
						ammo = user GetWeaponAmmoClip(currentWeapon);
						self.ammo = ammo;
						user zm_weapons::weapon_take(trigweapon);
						wait(.5);	// Small delay between using triggers
					}
						
				}

				else
				{
					self SetHintString( "There can be only One..." );
				}
			
			}

			else if( user PlayerHasElemental() )
			{
				if(is_upgraded)
				{
					currentWeapon = user GetCurrentWeapon();
					if(!IsSubStr(currentWeapon.name, "_ug"))
					{
						newWeapname = currentWeapon.name + "_ug";
						newWeapon = GetWeapon(newWeapname);
						if(isdefined(newWeapon))
						{
							if(newWeapon == trigweapon)
							{
								self SetHintString(hint);	// EDIT 20.1.2020, Remove if issues
								if( user UseButtonPressed() )
								{
									user zm_weapons::weapon_take( currentWeapon );
									WAIT_SERVER_FRAME;
									user zm_weapons::weapon_give( trigweapon, false, false, true, true );
									user SetWeaponAmmoClip( trigweapon, self.ammo );
									user thread PlayElementalEffect( self.script_noteworthy );
									self.ammo = 0;
									wait(.5);	// Small delay between using triggers
								}
							}

							else
							{
								self SetHintString( "You can only have One..." );
								should_update_hint = true;
							}
						}
					}

					else
					{
						self SetHintString( "You can only have One..." );
						should_update_hint = true;
					}
				}

				else
				{
					self SetHintString( "You can only have One..." );
					should_update_hint = true;
				}
	
			}

			else
			{
				if( should_update_hint )
				{
					self SetHintString( hint );
					should_update_hint = false;
				}
				
				if( user UseButtonPressed() )
				{
					user zm_weapons::weapon_give( trigweapon, false, false, true, true );
					user SetWeaponAmmoClip( trigweapon, self.ammo );
					user thread PlayElementalEffect( self.script_noteworthy );
					self.ammo = 0;
					if( IS_TRUE(user.first_time_elemental) )
					{
						user.first_time_elemental = false;
						user util::delay(2, undefined, &ShowWeaponInfo);
					}

					wait(.5);	// Small delay between using triggers
				}
				
			}

			wait(0.1);
		}
				
	}
}

function ShowWeaponInfo()	//self = player
{
	hint = "Only one Stone can be carried at a time\nReturn Stones at Any time\nReturn and Refill with souls for Energy";
	self thread zm_equipment::show_hint_text( hint, 5, 1.25, 180 );
}

function PlayElementalEffect( script_noteworthy )		//self = player
{
	switch(script_noteworthy)
	{
		case "spell_ice":
		case "spell_ice_ug":

			self SetBlur( 5, .2 );
			self PlayRumbleOnEntity( "damage_heavy" );

			if(script_noteworthy == "spell_ice_ug")
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_ice_00";
			}

			else
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_0" + RandomInt(2);
			}
			
			//self thread CustomPlayerQuote( sound_to_play );

			self util::delay( 0.25, undefined, &CustomPlayerQuote, sound_to_play );

			self util::waittill_any_timeout( 2, "death", "blur_cleared" );
			self SetBlur( 0, .5 );
			self notify( "blur_cleared" );
			self StopRumble( "damage_heavy" );

			break;

		case "spell_wind":
		case "spell_wind_ug":
			self SetBlur( 5, .2 );
			self PlayRumbleOnEntity( "damage_heavy" );

			if(script_noteworthy == "spell_wind_ug")
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_wind_00";
			}

			else
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_0" + RandomInt(2);
			}

			self util::delay( 0.25, undefined, &CustomPlayerQuote, sound_to_play );

			self util::waittill_any_timeout( 2, "death", "blur_cleared" );
			self SetBlur( 0, .5 );
			self notify( "blur_cleared" );
			self StopRumble( "damage_heavy" );
			

			break;

		case "spell_lightning":
		case "spell_lightning_ug":
			self SetElectrified( 1.5 );	

			if(script_noteworthy == "spell_lightning_ug")
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_lightning_00";
			}

			else
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_0" + RandomInt(2);
			}

			self util::delay( 0.25, undefined, &CustomPlayerQuote, sound_to_play );

			self ShellShock("electrocution", 1.5);
			

			break;

		case "spell_fire":
		case "spell_fire_ug":
			self clientfield::set( "burn", 1  );
			self ShellShock("electrocution", 1.5);

			if(script_noteworthy == "spell_fire_ug")
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_fire00";
			}

			else
			{
				sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_0" + RandomInt(2);
			}

			self util::delay( 0.25, undefined, &CustomPlayerQuote, sound_to_play );

			wait(1.5);
			self clientfield::set( "burn", 0  );


			break;

		default:
			self SetBlur( 5, .2 );
			self PlayRumbleOnEntity( "damage_heavy" );
			self util::waittill_any_timeout( 2, "death", "blur_cleared" );
			self SetBlur( 0, .5 );
			self notify( "blur_cleared" );
			self StopRumble( "damage_heavy" );
			sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_meteor_0" + RandomInt(2);
			self thread CustomPlayerQuote( sound_to_play );

			break;


	}
}

function DigSiteMeteor()	//self = digsite trigger
{
	meteor = Spawn("script_model", self.origin - (0, 0, 36));
	meteor SetModel("p6_zm_buildable_sq_meteor_ice");
	meteor MoveZ(60, 1);
	meteor waittill("movedone");
	meteor thread zm_powerups::powerup_wobble();
	meteor.trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	meteor.trigger SetHintString( "Hold ^3&&1 ^7To Pick up Stone of Ice" );
	meteor.trigger SetCursorHint( "HINT_NOICON" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		meteor.trigger waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			meteor.trigger Delete();
			PlaySoundAtPosition("zmb_perks_vulture_money", meteor.origin);
			PlayFX(level._effect["powerup_grabbed_solo"], meteor.origin);
			WAIT_SERVER_FRAME;
			meteor Delete();
			level.ice_collected = true;
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_0" + RandomInt(2);
			user thread CustomPlayerQuote( sound_to_play );
			level clientfield::set( "p6_zm_buildable_sq_meteor_ice", 1 );
		}
	}
}

function WonderWeaponUpgradeInit( script_noteworthy )	//self = trigger
{
	if(!isdefined(script_noteworthy))
	{
		IPrintLnBold("ERROR: No script noteworthy defined for upgrade");
		return;
	}

	switch(script_noteworthy)
	{
		// Each function here should eventually notify self with "upgrade_received" notify to stop the normal triggers
		case "spell_fire":
		self thread FireUpgradeInit();
		break;

		case "spell_ice":
		self thread IceCaveInit();
		break;

		case "spell_wind":
		self thread WindUpgradeInit();
		break;

		case "spell_lightning":
		self thread LightningUpgradeInit();
		break;

		default:
		break;
	}
}

function IceCaveInit()	//self = trigger
{
	ice_trigger_origin = struct::get("ice_trigger_struct", "targetname");
	if(!isdefined(ice_trigger_origin))
		return;

	ice_cave_origin = struct::get("ice_cave_struct", "targetname");
	if(!isdefined(ice_cave_origin))
		return;

	//ice_trigger.script_noteworthy = "spell_ice_ug";

	meteor = Spawn("script_model", ice_trigger_origin.origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_ice");
	PlayFXOnTag(level._effect["fx_elec_sparks_loop_blue_1x1"], meteor, "tag_origin");

	meteor.trigger = Spawn("trigger_radius", ice_trigger_origin.origin, 0, 32, 32);
	meteor.trigger SetHintString( "Hold ^3&&1 ^7To Upgrade Stone of Ice" );
	meteor.trigger SetCursorHint( "HINT_NOICON" );
	meteor.trigger.script_noteworthy = "spell_ice_ug";

	while(1)
	{
		WAIT_SERVER_FRAME;
		meteor.trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_02";
			user thread CustomPlayerQuote( sound_to_play );

			meteor.trigger SetHintString("");
			wait(1);
			meteor MoveTo(ice_cave_origin.origin, 2, 0.5, 0.5);
			meteor waittill("movedone");
			meteor IceCaveSoulbox( 20 );
			PlayFX(level._effect["powerup_grabbed_solo"], meteor.origin);
			WAIT_SERVER_FRAME;
			meteor.origin = ice_trigger_origin.origin;
			break;

		}

	}

	self notify("upgrade_received");
	self SetHintString("");
	//zm_spawner::deregister_zombie_death_event_callback( &IceSoulBox );
	util::playSoundOnPlayers("step_completed", undefined);

	level.chargable_meteors[level.chargable_meteors.size] = meteor;

	meteor.trigger thread WonderWeaponTriggerWatch( "the Ultimate Stone of Ice", true );

	level clientfield::set( "p6_zm_buildable_sq_meteor_ice", 2 );

	level.icepart_can_spawn = true;
	// level.spawn_fire_zombies = true;

	//level thread SpawnIcePart();
}

function IceCaveSoulbox( required_kills = 20 )
{
	self.kills = 0;
	has_played_quote = false;

	while( self.kills < required_kills )
	{
		wait(.1);
		if(self.kills >= 2 && !has_played_quote)
		{
			has_played_quote = true;
			player = ArrayGetClosest(self.origin, GetPlayers());
			if(isdefined(player))
			{
				sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_soul_chest_00";
				player thread CustomPlayerQuote( sound_to_play );
			}
			
		}

		WAIT_SERVER_FRAME;
		zombies = GetAITeamArray("axis");
		for(i = 0; i < zombies.size; i++)
		{
			WAIT_SERVER_FRAME;
			if(IS_TRUE(zombies[i].registered_ice))
				continue;

			else
			{
				zombies[i].registered_ice = true;
				zombies[i] thread SoulWaitForDeath( self );
			}
		}
	}

	player = ArrayGetClosest(self.origin, GetPlayers());
	if(isdefined(player))
	{
		sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_soul_chest_done_00";
		player thread CustomPlayerQuote( sound_to_play );
	}
}

function SoulWaitForDeath( meteor )
{
	self waittill("death");
	if(!isdefined(meteor))
		return;

	if(IS_TRUE(meteor.soul_chest_done))
		return;

	if(Distance(self.origin, meteor.origin) < 200)
	{
		soul = Spawn("script_model", self GetTagOrigin("j_spine4"));
		soul SetModel("tag_origin");
		soul PlayLoopSound("soul_loop");
		PlayFXOnTag(level._effect["fx_staff_charge_souls"], soul, "tag_origin");
		soul MoveTo(meteor.origin, 0.5);
		soul waittill("movedone");
		sound_to_play = "soul_collect_0" + RandomInt(3);
		PlaySoundAtPosition(sound_to_play, meteor.origin);
		soul Delete();
		meteor.kills++;
		//IPrintLnBold(meteor.kills);
	}
}

function IceCaveZombieKills( meteor )	//self = player
{
	self endon("disconnect");
	level endon("end_game");
	while(1)
	{
		self waittill("killed", ai);
		if(isdefined(ai))
		{
			if(Distance(ai.origin, meteor.origin) < 150)
			{
				soul = Spawn("script_model", ai GetTagOrigin("j_spine4"));
				soul SetModel("tag_origin");
				PlayFXOnTag(level._effect["fx_staff_charge_souls"], soul, "tag_origin");
				soul MoveTo(meteor.origin, 0.5);
				soul waittill("movedone");
				PlaySoundAtPosition("zmb_perks_vulture_pickup", meteor.origin);
				soul Delete();
				meteor.kills++;
			}
		}
	}
}

function WindUpgradeInit()	//self = original wind trigger
{
	wind_upgrade_origin = struct::get("wind_upgrade_struct","targetname");
	if(!isdefined(wind_upgrade_origin))
	{
		IPrintLnBold("ERROR: No wind_upgrade_struct in map");
		return;
	}

	meteor = Spawn("script_model", wind_upgrade_origin.origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_wind");
	meteor SetCanDamage( true );

	PlayFXOnTag(level._effect["fx_glow_biplane_trail"], meteor, "tag_origin");
	meteor.reached_destination = false;

	trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "If only there was something to get this thing moving" );

	while(1)
	{
		level waittill("wind_gun_fired", player);	//V2 Edit: This notify has been added in zm_weapon_wind
		//meteor waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		//EDIT: Remove this
		//IPrintLnBold("Took Damage");

		if(isdefined(player) && Distance2D(meteor.origin, player.origin) < 120)
		{
			sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_meteor_move_0" + RandomInt(2);
			player thread CustomPlayerQuote( sound_to_play );

			trigger Delete();
			meteor StartWindPath();
			wind_upgrade_origin Delete();
			break;
		}
	}

	util::playSoundOnPlayers("step_completed", undefined);

	self notify("upgrade_received");
	self SetHintString("");

	meteor.trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	meteor.trigger SetCursorHint( "HINT_NOICON" );
	meteor.trigger.script_noteworthy = "spell_wind_ug";

	level.chargable_meteors[level.chargable_meteors.size] = meteor;

	meteor.trigger thread WonderWeaponTriggerWatch( "the Ultimate Stone of Wind", true );
	level notify("laser_active");

	level clientfield::set( "p6_zm_buildable_sq_meteor_wind", 2 );

	//zm_spawner::deregister_zombie_death_event_callback( &WindSoulbox );
}

function StartWindPath()	//self = meteor
{
	//IPrintLnBold("Started Path!");
	meteor_path = GetEntArray("wind_path", "script_noteworthy");
	if(!isdefined(meteor_path) || meteor_path.size <= 0)
	{
		IPrintLnBold("ERROR: No meteor_path in map");
		return;
	}

	self MoveTo(meteor_path[0].origin, (Distance(self.origin, meteor_path[0].origin) / 300));
	self waittill("movedone");
	current_location = meteor_path[0];
	while(!self.reached_destination)
	{
		level waittill("wind_gun_fired", player);
		//IPrintLnBold("Damage");
		if(isdefined(player) && Distance2D(self.origin, player.origin) < 120)	//if(w_weapon == GetWeapon("spell_wind") && IsPlayer(e_attacker))
		{
			sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_meteor_move_0" + RandomInt(2);
			player thread CustomPlayerQuote( sound_to_play );
			//IPrintLnBold("Wind Damage");
			next_location = GetEnt(current_location.target, "targetname");
			if(!isdefined(next_location) || next_location.size <= 0)	//Target not defined, so we've reached the end of the path
			{
				//IPrintLnBold("^1 Reached Destination!");
				reached_destination = true;
				break;
			}

			self MoveTo(next_location.origin, (Distance(self.origin, next_location.origin) / 300));
			self waittill("movedone");
			current_location = next_location;
			if(!isdefined(current_location.target))
			{
				reached_destination = true;
				break;
			}
		}
	}

	//level.wind_soulbox = current_location;
	//level.wind_soulbox.kills = 0;
	self WindSoulbox( 15 );

	player = ArrayGetClosest( self.origin, GetPlayers());
	if(isdefined(player))
	{
		sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_soul_chest_done_00";	//vox_plr_0_soul_chest_done_00
		player thread CustomPlayerQuote( sound_to_play );
	}
	

	/*while( self.kills < 15 )
	{
		WAIT_SERVER_FRAME;
	}*/

}

function WindSoulbox( required_kills )
{
	self.kills = 0;
	self.soul_chest_done = false;

	while( self.kills < required_kills )
	{
		WAIT_SERVER_FRAME;
		zombies = GetAITeamArray("axis");
		for(i = 0; i < zombies.size; i++)
		{
			WAIT_SERVER_FRAME;
			if(IS_TRUE(zombies[i].registered_wind))
				continue;

			else
			{
				zombies[i].registered_wind = true;
				zombies[i] thread SoulWaitForDeath( self );
			}	
		}
	}

	self.soul_chest_done = true;
}

function LightningUpgradeInit()	//self = normal lightning trigger
{
	original_trigger = self;
	if(!isdefined(original_trigger))
	{
		IPrintLnBold("What the Fuck");
	}

	lightning_upgrade_origin = struct::get("lightning_upgrade_struct","targetname");
	if(!isdefined(lightning_upgrade_origin))
	{
		IPrintLnBold("ERROR: No lightning_upgrade_struct in map");
		return;
	}

	meteor = Spawn("script_model", lightning_upgrade_origin.origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_lightning");
	meteor.reached_destination = false;
	meteor.escorts_done = 0;

	PlayFXOnTag(level._effect["fx_bow_storm_trail_zmb"], meteor, "tag_origin");

	upgarde_trigger = Spawn("trigger_radius", lightning_upgrade_origin.origin, 0, 32, 32);
	upgarde_trigger SetCursorHint( "HINT_NOICON" );
	upgarde_trigger SetHintString( "Hold ^3&&1 ^7To Upgrade Stone of Lightning" );

	meteor.trigger = Spawn("trigger_radius", lightning_upgrade_origin.origin, 9, 104, 104);	//This trigger will check the distance from players
	meteor.trigger EnableLinkTo();
	meteor.trigger LinkTo(meteor);
	
	while(1)
	{
		WAIT_SERVER_FRAME;
		upgarde_trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_02";
			user thread CustomPlayerQuote( sound_to_play );

			upgarde_trigger Delete();
			PlayFXOnTag(level._effect["fx_115_generator_tesla_kill"], meteor, "tag_origin");
			meteor PlaySound("lightning_fire_ug_npc");
			meteor RotateYaw(360, 0.5);
			wait(0.5);
			meteor LightningStartEscort( original_trigger );
			if(meteor.reached_destination)
			{
				//IPrintLnBold("Upgrade Completed");
				meteor Delete();
				break;
			}
		}
	}

	self notify("upgrade_received");
}

function LightningStartEscort( original_trigger )	//self = meteor
{
	self endon("escort_failed");

	if(!isdefined(self.trigger))
		return;

	lightning_timer = 0;			//This timer starts ticking once no player is touching the entity, if it reaches 10 seconds, escorting will stop
	original_pos = self.origin;		//Needed if the escort fails
	escort_done = false;

	//V2 addition. For those places where you can't reach, create an auto-trigger where the meteor moves by it self
	auto_trigger = GetEntArray("lightning_auto_trigger", "targetname");

	meteor_spawns = GetEntArray("meteor_escort_struct","targetname");
	if(!isdefined(meteor_spawns))
		return;

	for(i = 0; i < meteor_spawns.size; i++)
	{
		//IPrintLnBold("Checking valid spawn. Should find on with index: " + self.escorts_done);
		if(isdefined(meteor_spawns[i].script_int))
		{
			//IPrintLnBold("Found one with script int");
			if( meteor_spawns[i].script_int == self.escorts_done )
			{
				//IPrintLnBold("Found Valid Struct with index: " +meteor_spawns[i].script_int );
				new_spawn = meteor_spawns[i];
			}
		}
	}

	escort_path = GetEntArray("lightning_escort_path", "script_noteworthy");
	if(!isdefined(escort_path) || escort_path.size <= 0)
	{
		IPrintLnBold("No Escort Path Defined");
		return;
	}

	start_origin = ArrayGetClosest(self.origin, escort_path);

	if(!isdefined(start_origin))
	{
		//IPrintLnBold("Could not Find Start Origin");
		return;
	}

	self MoveTo(start_origin.origin, 0.5);

	current_location = start_origin;
	self thread EscortDogSpawner( escort_path );

	while(!IS_TRUE(escort_done))
	{
		wait(0.05);
		if( AnyPlayerTouchingEntity(self.trigger) || self IsInAutoTrigger(auto_trigger) )
		{
			lightning_timer = 0;
			new_location = GetEnt(current_location.target, "targetname");
			if(!isdefined(new_location))	//We've reached the destination
			{
				//ADD: Sounds and FX here, and set the new origin
				self notify("escort_success");
				PlaySoundAtPosition("meteor_teleport", self.origin);
				PlayFX(level._effect["fx_elec_teleport_flash_sm"], self.origin);
				self.escorts_done++;
				if(self.escorts_done >= 3)
				{
					original_trigger notify("upgrade_received");
					original_trigger SetHintString("");
					self.reached_destination = true;
					//self SetOrigin("");
					self SpawnLightningMeteor( original_trigger );
					util::playSoundOnPlayers("step_completed", undefined);

					player = ArrayGetClosest( self.origin, GetPlayers());
					if(isdefined(player))
					{
						sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_meteor_upgraded_0" + RandomInt(2);
						player thread CustomPlayerQuote( sound_to_play );
					}
					
					break;
				}

				escort_done = true;
				WAIT_SERVER_FRAME;
				self.origin = new_spawn.origin;
				self thread RestartEscort( original_trigger );
				break;
			}

			self MoveTo(new_location.origin, Distance(self.origin, new_location.origin) / 100);
			if(Distance(new_location.origin, self.origin) < 5)
			{
				current_location = new_location;
				new_location = GetEnt(current_location.target, "targetname");
			}
		}

		else
		{
			self MoveTo(self.origin, 0.05);
			lightning_timer += 0.05;
			if(lightning_timer >= 10 )
			{
				players = GetPlayers();
				closest = util::get_array_of_closest(self.origin, players, undefined, undefined, 500);
				if(isdefined(closest))
				{
					for(i = 0; i < closest.size; i++)
					{
						closest[i] PlaySoundToPlayer( "escort_fail_2d", closest[i] );
						sound_to_play = "vox_plr_" + closest[i] GetCharacterBodyType() + "_meteor_upgrade_failed_00";
						closest[i] thread CustomPlayerQuote( sound_to_play );
					}
				}
				
				WAIT_SERVER_FRAME;
				self.origin = original_pos;
				self thread RestartEscort( original_trigger );
				self notify("escort_failed");
			}
		}
	}
}

function IsInAutoTrigger( a_trigger )	//self = meteor
{
	for(i = 0; i < a_trigger.size; i++)
	{
		if(self IsTouching(a_trigger[i]))
			return true;
	}

	return false;
}

function SpawnLightningMeteor( original_trigger )	//self = meteor
{
	if(isdefined(original_trigger))
	{
		//IPrintLnBold("Trigger Disabled");	// TODO: Remove
		original_trigger notify("upgrade_received");
		original_trigger SetHintString("");
	}

	else
	{
		IPrintLnBold("Original trigger not defined");
	}

	struct = struct::get("lightning_upgrade_struct","targetname");
	meteor = Spawn("script_model", struct.origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_lightning");
	PlayFXOnTag(level._effect["fx_bow_storm_trail_zmb"], meteor, "tag_origin");

	meteor.trigger = Spawn("trigger_radius", struct.origin, 0, 32, 32);
	meteor.trigger SetCursorHint( "HINT_NOICON" );
	meteor.trigger.script_noteworthy = "spell_lightning_ug";
	meteor.trigger thread WonderWeaponTriggerWatch( "the Ultimate Stone of Lightning", true );

	level.chargable_meteors[level.chargable_meteors.size] = meteor;

	level clientfield::set( "p6_zm_buildable_sq_meteor_lightning", 2 );
	
	level thread ShockTeleporters();

	self Delete();
}

function RestartEscort( original_trigger )	//self = meteor
{
	upgarde_trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	upgarde_trigger SetCursorHint( "HINT_NOICON" );
	upgarde_trigger SetHintString( "Hold ^3&&1 ^7To Upgrade Stone of Lightning" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		upgarde_trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			upgarde_trigger Delete();
			self LightningStartEscort( original_trigger );
			break;
		}
	}
}

// V2 Edit: Spawner now checks dog spawners along the path instead of self.origin distance check
// escort_path = Path origin array (script_origins)
function EscortDogSpawner( escort_path )	//self = meteor
{
	self endon("escort_failed");
	self endon("escort_success");

	//valid_spawns = [];
	valid_spawns = EscortGetValidSpawns( self, escort_path );
	if(!isdefined(valid_spawns) || valid_spawns.size <= 0)
		return;

	min_time = 2;
	max_time = 5;
	
	while(1)
	{
		wait(RandomIntRange(min_time, max_time));
		CustomSpawnDog( valid_spawns[RandomInt(valid_spawns.size)] );
	}
}

function EscortGetValidSpawns( meteor, escort_path )
{
	// Gets the adjacent zones of this location and spawn dogs there
	valid_zones = [];
	valid_spawns = [];

	valid_zones[valid_zones.size] = zm_zonemgr::get_zone_from_position(meteor.origin, false);

	for(i = 0; i < escort_path.size; i++)
	{
		target = GetEnt(escort_path[i].target, "targetname");
		if(!isdefined(target))	// If entity doesn't have a target, it's a path end
		{
			// Check to see if script_matches the current escort
			if( isdefined(escort_path[i].script_int) && isdefined(meteor.escorts_done) && escort_path[i].script_int == (meteor.escorts_done - 1) )
			{
				//IPrintLnBold("Found Valid Spawn with int: " + escort_path[i].script_int);
				valid_zones[valid_zones.size] = zm_zonemgr::get_zone_from_position(escort_path[i].origin, false);
			}
		}
	}

	closest = util::get_array_of_closest( meteor.origin, struct::get_array("dog_location", "script_noteworthy"), undefined, undefined, 2000 );
	for(j = 0; j < closest.size; j++)
	{
		zone = zm_zonemgr::get_zone_from_position(closest[j].origin, false);
		for(k = 0; k < valid_zones.size; k++)
		{
			if(zone == valid_zones[k])
				valid_spawns[valid_spawns.size] = closest[j];
		}
	}

	return valid_spawns;
}

function FireUpgradeInit()
{
	fire_upgrade_origin = struct::get("fire_upgrade_struct","targetname");
	if(!isdefined(fire_upgrade_origin))
	{
		IPrintLnBold("ERROR: No fire_upgrade_struct in map");
		return;
	}

	meteor = Spawn("script_model", fire_upgrade_origin.origin);
	meteor SetModel("p6_zm_buildable_sq_meteor_fire");

	PlayFXOnTag(level._effect["fx_fire_spot_xxsm"], meteor, "tag_origin");

	upgarde_trigger = Spawn("trigger_radius", meteor.origin, 0, 32, 32);
	upgarde_trigger SetCursorHint( "HINT_NOICON" );
	upgarde_trigger SetHintString( "Hold ^3&&1 ^7To Upgrade Stone of Fire" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		upgarde_trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_collect_02";
			user thread CustomPlayerQuote( sound_to_play );
			upgarde_trigger Delete();
			meteor StartFirePath( user, self );
		}
	}

	self notify("upgrade_received");
	meteor Delete();

}

function StartFirePath( user, original_trigger )	//self = meteor
{
	self endon("fire_upgrade_failed");
	self Hide();
	original_pos = self.origin;

	fire_timer = 0;

	current_target = GetEnt("fire_upgrade_target", "targetname");
	next_target = current_target;

	if(!isdefined(next_target) || next_target.size <= 0)
	{
		IPrintLnBold("Could not Find First Target");
		return;
	}

	next_target.fxmodel = Spawn("script_model", next_target.origin);
	next_target.fxmodel SetModel("tag_origin");
	next_target.fxmodel clientfield::set("fire_path_fx", 1);

	while(isdefined(self))
	{
		wait(0.05);
		if(fire_timer >= 11)
		{
			if(isdefined(next_target.fxmodel))
			{
				next_target.fxmodel clientfield::set("fire_path_fx", 0);
				WAIT_SERVER_FRAME;
				next_target.fxmodel Delete();
			}

			user PlaySoundToPlayer( "escort_fail_2d", user );
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_meteor_upgrade_failed_00";
			user thread CustomPlayerQuote( sound_to_play );
			original_trigger thread FireUpgradeInit();
			break;
		}

		if(Distance2D(user.origin, next_target.origin) < 45)	// Player has reached a target
		{
			fire_timer = 0;
			current_target = next_target;
			
			if(isdefined(current_target.fxmodel))
			{
				current_target.fxmodel clientfield::set("fire_path_fx", 0);
				WAIT_SERVER_FRAME;
				current_target.fxmodel Delete();
			}

			self.origin = current_target.origin;
			self Show();
			self RotateYaw(360, 1);
			self PlaySound("fire_checkpoint");
			wait(1);
			PlayFX(level._effect["powerup_grabbed_solo"], self.origin);
			WAIT_SERVER_FRAME;
			self Hide();

			next_target = GetEnt(current_target.target, "targetname");

			if(!isdefined(next_target))	//No target remaining, so we've reached the end of this step, or something is failing miserably
			{
				//Play some fancy fx and stuff here
				self Show();
				self thread SpawnFireWeaponTrigger( original_trigger );
				self thread FireWeaponTrees();
				util::playSoundOnPlayers("step_completed", undefined);
				player = ArrayGetClosest( self.origin, GetPlayers());
				if(isdefined(player))
				{
					sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_meteor_upgraded_0" + RandomInt(2);
					player thread CustomPlayerQuote( sound_to_play );
				}

				break;
			}

			next_target.fxmodel = Spawn("script_model", next_target.origin);
			next_target.fxmodel SetModel("tag_origin");
			next_target.fxmodel clientfield::set("fire_path_fx", 1);
		}

		fire_timer += 0.05;
	}
}

function SpawnFireWeaponTrigger( original_trigger )	//self = meteor
{
	PlayFXOnTag(level._effect["fx_fire_spot_xxsm"], self, "tag_origin");

	level.chargable_meteors[level.chargable_meteors.size] = self;

	self.trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	self.trigger SetCursorHint( "HINT_NOICON" );
	self.trigger.script_noteworthy = "spell_fire_ug";
	self.trigger thread WonderWeaponTriggerWatch( "the Ultimate Stone of Fire", true );

	level clientfield::set( "p6_zm_buildable_sq_meteor_fire", 2 );

	original_trigger notify("upgrade_received");
	original_trigger SetHintString("");
}

/*============================================================

==============PART COLLECTING STEPS HERE======================

==============================================================*/

function FireWeaponTrees()	//V2 edit. Now is a different step: shoot the insulators near pap and start a revenant hell
{
	objects = GetEntArray("fire_stone_model", "targetname");
	if(!isdefined(objects) || objects.size < 1)
		return;

	foreach(object in objects)
	{
		object thread WaitForFireDamage();
	}
}

function WaitForFireDamage()
{
	self SetCanDamage( 1 );
	fxmodel = Spawn("script_model", self.origin + (0, 0, 160));
	fxmodel SetModel("tag_origin");
	fxmodel clientfield::set("fire_ritual_fx", 1);
	
	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		DebugPrint("Damage");
		if(w_weapon == GetWeapon("spell_fire_ug") && IsPlayer(e_attacker))
		{
			if(e_attacker zm_zonemgr::entity_in_zone("zone_pap"))	//Only activate this if player is in the pap area
			{
				sound_to_play = "vox_plr_" + e_attacker GetCharacterBodyType() + "_quest_radio_activate_0" + RandomInt(2);
				e_attacker thread CustomPlayerQuote( sound_to_play );

				level.fire_objects_active++;

				fxmodel clientfield::set("fire_ritual_fx", 2);

				level thread CheckActiveFireObjects();
				break;
			}
		}
	}
}

function CheckActiveFireObjects()
{
	models = GetEntArray("fire_stone_model", "targetname");
	if(!isdefined(models))
		return;

	n_size = models.size;

	if(!isdefined(n_size))
		n_size = 2;

	if( level.fire_objects_active >= n_size )
	{
		StartFireRitual();
	}
}

function StartFireRitual()
{
	level endon ("game_ended");

	//Set up values for this step here
	time = 60;
	spawn_interval = 6;

	floor = GetEntArray( "fire_ritual_floor", "targetname" );
	if(!isdefined(floor))
	{
		IPrintLnBold("Floor not defined");
		return;
	}

	table = GetEnt("fire_ritual_table", "targetname");
	if(!isdefined(table))
	{
		IPrintLnBold("Table not defined");
		return;
	}
		
	table_clip = GetEnt("fire_ritual_table_clip", "targetname");
	if(!isdefined(table_clip))
	{
		IPrintLnBold("Clip not defined");
		return;
	}

	meteor = GetEnt("fire_ritual_meteor", "targetname");
	if(!isdefined(meteor))
	{
		IPrintLnBold("Meteor not defined");
		return;
	}

	door_blockers = GetEntArray("fire_meteor_blockers","targetname");
	if(!isdefined(door_blockers) || door_blockers.size < 1)
	{
		IPrintLnBold("Blockers not defined");
		return;
	}

	for(i = 0; i < door_blockers.size; i++)
	{
		door_blockers[i] MoveZ(100, 0.05);
		wait(.05);
		door_blockers[i].fx = util::spawn_model("tag_origin", door_blockers[i].origin + (0, 0, 50));
		door_blockers[i].fx clientfield::set("fire_ritual_fx", 2);
	}

	while(AnyPlayerTouchingEntity(floor[0]))
	{
		WAIT_SERVER_FRAME;
	}

	meteor EnableLinkTo();
	meteor LinkTo(table);

	PlayFX(FX_RITUAL_EXPLODE, floor[0].origin);
	WAIT_SERVER_FRAME;
	foreach(part in floor)
	{
		part Delete();
	}

	util::playSoundOnPlayers( "fire_explode_00", undefined );
	zm_powerup_nuke::nuke_powerup( self, level.zombie_team );

	table_clip MoveZ(38, 0.05);
	
	wait(3);

	// This step disables zombie spawns
	level flag::clear("spawn_zombies");

	players = GetPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i].has_timewarp = false;
		if( players[i] HasPerk("specialty_fireproof") )
		{
			players[i].has_timewarp = true;
			players[i] notify( "specialty_fireproof" + "_stop" );
		}
	}

	table PlaySound("zmb_origins_magicbox_leave");
	table MoveZ(38, 3);
	wait(3);

	util::playSoundOnPlayers("beastmode_start_00", undefined);
	PlayFXOnTag(level._effect["fx_fire_spot_xxsm"], meteor, "tag_origin");

	meteor thread SpawnRevenants( spawn_interval );

	thread zm_project_e_music::play_music_for_players( "mus_fire_ritual", false );

	meteor Unlink();
	meteor MoveZ(30, time);

	wait(time);

	level notify("fire_step_done");

	for(i = 0; i < door_blockers.size; i++)
	{
		if(isdefined(door_blockers[i].fx))
		{
			door_blockers[i].fx clientfield::set("fire_ritual_fx", 0);
			door_blockers[i].fx Ghost();
			door_blockers[i].fx util::delay( 0.25, undefined, &zm_utility::self_delete );
		}
		
		door_blockers[i] Ghost();
		door_blockers[i] util::delay( 0.25, undefined, &zm_utility::self_delete );
	}

	zm_powerup_nuke::nuke_powerup( self, level.zombie_team );

	for(i = 0; i < players.size; i++)
	{
		if( IS_TRUE(players[i].has_timewarp) )
		{
			players[i] zm_perks::give_perk( "specialty_fireproof" );
			players[i].has_timewarp = undefined;
		}
	}

	meteor thread zm_powerups::powerup_wobble();
	PlaySoundAtPosition("egg_done", meteor.origin);

	util::playSoundOnPlayers("step_completed", undefined);

	trigger = Spawn("trigger_radius", meteor.origin, 0, 48, 48);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Pick up Mutated Sap" );

	// This step disables zombie spawns
	level flag::set("spawn_zombies");

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			trigger Delete();
			meteor Delete();
			user PlaySoundToPlayer( "egg_pickup", user );
			level.teleporter_parts++;
			level thread CheckTeleParts();

			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_part_grab_0" + RandomInt(5);
			user thread CustomPlayerQuote( sound_to_play );

			table PlaySound( "zmb_origins_magicbox_leave" );
			table MoveZ(-38, 3);
			wait(3);
			table_clip Delete();
			break;
		}
	}
}

function SpawnRevenants( interval )	//self = meteor
{
	level endon("end_game");
	level endon("fire_step_done");

	spawners = util::get_array_of_closest( self.origin, level.zm_loc_types[ "sonic_location" ], undefined, undefined, 600 );
	while(1)
	{
		zm_ai_reverant::sonic_zombie_spawn( spawners[RandomInt(spawners.size)] );
		wait(interval);
	}
}

function LaserTrap()
{
	level flag::wait_till("initial_blackscreen_passed");

	satellite = GetEnt("wind_satellite","targetname");
	target = GetEnt(satellite.target, "targetname");

	satellite_trigger = GetEnt("satellite_trigger","targetname");	//level._effect["fx_satellite_hint"]

	satellite_code_triggers = GetEntArray("satellite_code_trigger", "targetname");

	satellite_code_pieces = GetEntArray("satellite_code_piece", "targetname");

	if(!isdefined(target))
		return;

	if(!isdefined(satellite_code_pieces))
		return;

	if(!isdefined(satellite_code_triggers))
		return;

	if(!isdefined(satellite) || satellite.size <= 0 )
	{
		IPrintlnBold("Could not find satellites");
		return;
	}

	satellite EnableLinkTo();
	target EnableLinkTo();

	target LinkTo( satellite );
		
	satellite_trigger SetHintString( "Come Back Later..." );
	satellite_trigger SetCursorHint( "HINT_NOICON" );

	foreach(trigger in satellite_code_triggers)
	{
		trigger SetHintString("");
		trigger UseTriggerRequireLookAt();
		trigger SetCursorHint( "HINT_NOICON" );
	}

	foreach(piece in satellite_code_pieces)
	{
		piece Hide();
	}

	satellite_trigger.satellite = satellite;
	satellite_trigger.code_triggers = satellite_code_triggers;
	satellite_trigger.code_pieces = satellite_code_pieces;

	satellite_trigger thread LaserTrapActivation();

}

function LaserTrapSpin()	//self = trap
{
	self.spinning = true;

	satellite_trigger = GetEnt("satellite_trigger","targetname");
	if(isdefined(satellite_trigger.satellite_active))
		satellite_trigger UpdateSatelliteHintString();

	fxmodel = Spawn("script_model", self.origin);
	fxmodel SetModel("tag_origin");
	PlayFXOnTag(WIND_PROJ, fxmodel, "tag_origin");
	fxmodel PlayLoopSound( "radar_rotate_loop" );

	self RotateYaw(340, 26);
	self waittill("rotatedone");

	fxmodel StopLoopSound(1);
	PlaySoundAtPosition("radar_shutdown", fxmodel.origin);

	self.timing_out = true;
	self RotateYaw(20, 4);
	self waittill("rotatedone");

	fxmodel Delete();

	self.spinning = false;
	self.timing_out = false;

}

function LaserTrapActivation()
{
	level endon("intermission");
	level endon("end_game");

	self SetHintString( "Come back later..." );

	level waittill("laser_active");

	fx = Spawn("script_model", self.origin);
	fx SetModel("tag_origin");
	PlayFXOnTag(level._effect["fx_light_flashing_red_factory_zmb"], fx, "tag_origin");

	fx_satellite = Spawn("script_model", self.satellite.origin);
	fx_satellite SetModel("tag_origin");
	PlayFXOnTag(level._effect["fx_satellite_hint"], fx_satellite, "tag_origin");

	self UpdateSatelliteHintString();

	self.satellite_active = false;
	self.satellite_deactivate = false;
	self.correct_symbols = 0;

	foreach( trigger in self.code_triggers )
	{
		trigger thread SatelliteCodePlacement( self );
	}

	while( !IS_TRUE(self.satellite_deactivate) )
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && !IS_TRUE(self.satellite_active) && IS_TRUE(self.satellite.spinning))
		{
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_radio_activate_0" + RandomInt(2);
			user thread CustomPlayerQuote( sound_to_play );

			fx_satellite Delete();

			sound_origin = Spawn( "script_origin", self.origin );
   			sound_origin PlayLoopSound( "radio_static" );

			self.satellite_active = true;
			self.correct_symbols = 0;

			self UpdateSatelliteHintString();
			foreach( piece in self.code_pieces )
			{
				piece Show();
			}

			while(self.satellite.spinning)
			{
				wait(1);
				self UpdateSatelliteHintString();
			}

			foreach( piece in self.code_pieces )
			{
				piece Hide();
			}

			PlaySoundAtPosition("radio_shutdown", sound_origin.origin);

			self.satellite_active = false;
			WAIT_SERVER_FRAME;

			sound_origin Delete();
			self UpdateSatelliteHintString();
		}
	}

	fx Delete();
	self Delete();
}

function UpdateSatelliteHintString()
{
	if(IS_TRUE(self.satellite.spinning))
	{
		if(IS_TRUE(self.satellite_active))
			self SetHintString( "Receiving Signal..." );

		else if(IS_TRUE(self.satellite.timing_out))
			self SetHintString( "Losing Signal..." );

		else
			self SetHintString( "Hold ^3&&1 ^7To Receive Transmission" );
	}

	else
	{
		self SetHintString( "Signal is too weak, there must be a way to amplify the Signal" );
	}
}

function SatelliteCodePlacement( trigger )
{
	level endon("radar_step_done");
	if(!isdefined(self.script_int))
	{
		DebugPrint("No script int on satellite code!");
		return;
	}

	self.activated = false;

	while(1)
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && !IS_TRUE(trigger.activated) )
		{
			if( trigger.correct_symbols == self.script_int )
			{
				self.activated = true;
				target = GetEnt(self.target, "targetname");
				if(!isdefined(target))
				{
					DebugPrint("No target on satellite code!");
					return;
				}

				target SetModel( self.script_string + "_emissive" );
				trigger.correct_symbols++;

				PlaySoundAtPosition("code_correct", self.origin);

				if(trigger.correct_symbols >= trigger.code_triggers.size )
				{
					util::playSoundOnPlayers( "step_completed", undefined );

					sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_code_correct_00";
					user thread CustomPlayerQuote( sound_to_play );
					level thread LaserMeltTele( self );
					break;
				}
			}

			else
			{
				PlaySoundAtPosition("code_fail", self.origin);

				sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_code_incorrect_00";
				user thread CustomPlayerQuote( sound_to_play );

				foreach( code_trigger in trigger.code_triggers )
				{
					code_trigger NullifySatelliteCode( trigger );
				}

			}
		}
	}

	level notify( "radar_step_done" );
}

function NullifySatelliteCode( trigger )
{
	target = GetEnt(self.target, "targetname");
	if(!isdefined(target))
	{
			DebugPrint("No target on satellite code!");
			return;
	}

	target SetModel( self.script_string );
	self.activated = false;

	trigger.correct_symbols = 0;
}

function LaserMeltTele( trigger )	
{
	// NEW STUFF
	// Originally this was a step where you would target lasers to a certain location in order to destroy an object
	container = GetEnt("computer_container", "targetname");
	if(!isdefined(container))
	{
		level.teleporter_parts++;
		return;
	}

	container_water = GetEnt("container_water", "targetname");
	
	engineer = GetEnt("container_engineer", "targetname");
	if(!isdefined(engineer))
	{
		level.teleporter_parts++;
		return;
	}

	PlayFX(level._effect["powerup_grabbed_solo"], trigger.origin);
	wait(3);
	container SetModel("p7_animal_testing_container_broken_b");
	PlayFX(level._effect["fx_exp_grenade_water"], engineer.origin);
	PlaySoundAtPosition("shatter_00", container.origin);
	container_water Delete();
	thread engineer::SpawnSpecialEngineer();
	engineer Hide();
	WAIT_SERVER_FRAME;
	engineer Delete();

	player = ArrayGetClosest(container.origin, GetPlayers());
	if(isdefined(player))
	{
		sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_engineeer_spawn_super_00";
		player thread CustomPlayerQuote( sound_to_play );
	}
}

function SpawnWindPart( origin )
{
	part = Spawn("script_model", origin );
	part SetModel("p7_chemistry_kit_flask");

	part thread zm_powerups::powerup_wobble();

	part_trigger = Spawn("trigger_radius", part.origin, 0, 64, 64);
	part_trigger SetCursorHint( "HINT_NOICON" );
	part_trigger SetHintString( "Hold ^3&&1 ^7To Pick up Specimen" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		part_trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			part_trigger Delete();
			part Delete();
			user PlaySoundToPlayer( "egg_pickup", user );
			level.teleporter_parts++;
			level thread CheckTeleParts();
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_part_grab_0" + RandomInt(5);
			user thread CustomPlayerQuote( sound_to_play );
		}
	}
}

function ShockTeleporters()
{
	shockboxes = GetEntArray("teleporter_shockable","targetname");

	if( !isdefined(shockboxes) || shockboxes.size <= 0 )
		return;

	for(i = 0; i < shockboxes.size; i++)
	{
		shockboxes[i] thread TeleWaitForShock();
	}
}

function TeleWaitForShock()
{
	self SetCanDamage(1);

	self.fxmodel = util::spawn_model("tag_origin", self.origin);
	if(isdefined(self.fxmodel))
	{
		self.fxmodel clientfield::set("tele_charge_hint", 1);
	}
	
	int = self.script_int;
	if(!isdefined(int))
	{
		IPrintLnBold("No script int on teleporter_shockable");
		return;
	}

	self.target_tele = undefined;

	teleporters = GetEntArray("pe_teleporter_trigger", "targetname");
	for(i = 0; i < teleporters.size; i++)
	{
		if(isdefined(teleporters[i].script_int) && teleporters[i].script_int == int)
		{
			self.target_tele = teleporters[i];
			self.target_tele.tele_overload = undefined;
			//self.target_tele.has_part = has_part;
		}
	}

	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		if( w_weapon == GetWeapon("spell_lightning_ug") && IsPlayer(e_attacker) )
		{
			sound_to_play = "vox_plr_" + e_attacker GetCharacterBodyType() + "_quest_radio_activate_0" + RandomInt(2);
			e_attacker thread CustomPlayerQuote( sound_to_play );

			self.target_tele.tele_overload = true;	//vox_plr_0_quest_radio_activate_00
			DebugPrint("Tele overloaded");

			if(isdefined(self.fxmodel))
			{
				self.fxmodel clientfield::set("tele_charge_hint", 2);
			}

			self.target_tele waittill("overload_over");
			self.target_tele.tele_overload = false;
			if(isdefined(self.fxmodel))
			{
				self.fxmodel clientfield::set("tele_charge_hint", 0);
				self.fxmodel util::delay( 0.25, undefined, &zm_utility::self_delete );
			}

			DebugPrint("Overload passed");
			level.overloads_done++;
			if(level.overloads_done >= teleporters.size)
			{
				level thread SpawnTelePart( self.target_tele.origin + (0, 0, 32) );
				wait(3);

				structs = struct::get_array( self.target_tele.target, "targetname" );
				spawn = structs[0];
				zm_avogadro::SpawnAvoAtPosition( spawn );
				wait(.5);
				zm_avogadro::SpawnAvoAtPosition( spawn );
				wait(.5);
				zm_avogadro::SpawnAvoAtPosition( spawn );
				
			}

			else
			{
				structs = struct::get_array( self.target_tele.target, "targetname" );
				spawn = structs[0];
				zm_avogadro::SpawnAvoAtPosition( spawn );
			}

			break;
		}

	}
}

function SpawnTelePart( origin )
{
	ghost = util::spawn_model( "c_rus_scientist_body_ghost", origin - (0, 0, 32), (0, 60, 0) );

	closest = ArrayGetClosest(ghost.origin, GetPlayers());

	cyber_origin = self.origin;
	enemy_origin = closest.origin;
	cyber_angles = self GetAngles();
	new_face_direction = VectortoAngles( enemy_origin - cyber_origin );
	ghost.angles = ( (cyber_angles[0], new_face_direction[1], cyber_angles[2]) );

	ghost UseAnimTree( #animtree );

	ghost PlaySound("vox_sm_hanoi_boss_death_00");

	ghost AnimScripted( "note_notify", ghost.origin, ghost.angles, %pb_scientist_ghost_idle );
	wait(3);

	PlaySoundAtPosition( "ghost_attack", ghost.origin );
	PlayFX( level._effect["fx_elec_teleport_flash_lg"], ghost.origin );
	ghost Delete();

	part = Spawn( "script_model", origin );
	part SetModel("zm_115_meteor1");
	
	part thread zm_powerups::powerup_wobble();

	trigger = Spawn("trigger_radius", part.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Pick up Charged 115" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			trigger Delete();
			part Delete();
			user PlaySoundToPlayer( "egg_pickup", user );
			level.teleporter_parts++;
			level thread CheckTeleParts();
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_part_grab_0" + RandomInt(5);
			user thread CustomPlayerQuote( sound_to_play );
		}
	}
}

function SpawnIcePart( origin )
{
	if(!IS_TRUE(level.icepart_can_spawn))
		return;

	if(IS_TRUE(level.icepart_spawned))
		return;

	part = Spawn("script_model", origin);
	part SetModel("p7_zm_zod_skull_fire");

	level.icepart_spawned = true;

	is_valid_pos = part CheckInPlayableArea();

	if(!is_valid_pos)
	{
		players = GetPlayers();
		closest = ArrayGetClosest(origin, players);
		if(isdefined(closest))
		{
			part MoveTo( closest.origin + (0, 0, 32), 0.05);
			wait(0.05);
		}
	}

	util::playSoundOnPlayers("egg_place", undefined);

	fxmodel = util::spawn_model("tag_origin", part.origin);
	PlayFXOnTag(level._effect["fx_fire_barrel_30x30"], fxmodel, "tag_origin" );

	part SetCanDamage(1);
	shots = 0;

	while(shots < 1)
	{
		part waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		DebugPrint("Damage");
		if( w_weapon == GetWeapon("spell_ice_ug") && IsPlayer(e_attacker) )
		{
			shots++;
		}
	}

	part PlaySound("egg_done");
	part SetModel("p7_zm_zod_skull_dark");

	fxmodel Delete();
	part thread zm_powerups::powerup_wobble();

	trigger = Spawn("trigger_radius", part.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Pick up Revenant Skull" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			trigger Delete();
			part Delete();
			user PlaySoundToPlayer( "egg_pickup", user );
			level.teleporter_parts++;
			level thread CheckTeleParts();
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_part_grab_0" + RandomInt(5);
			user thread CustomPlayerQuote( sound_to_play );
			level.spawn_fire_zombies = false;
		}
	}
}

function CheckTeleParts()
{
	DebugPrint( "Parts collected:" +level.teleporter_parts );
	if(level.teleporter_parts == 4)		// Hanoi part step initialization
	{

		number_door = GetEnt("code_door", "targetname");

		if(!isdefined(number_door))
		{
			IPrintLnBold("Number door not defined!");
		}

		number_door Delete();	//TODO: Add an anim here???

		level thread teleporter_code_init();
		// level thread SpikeDestructibles();
	}

	if(level.teleporter_parts == 5)		// Afterlife part step setup
	{
		DebugPrint("aftrelife collectables active");
		level notify("afterlife_collectables");
		
		barrier = GetEnt("lockdown_barrier", "targetname");
		if(isdefined(barrier))
		{
			barrier MoveZ(100, 0.05);
			wait(.1);
			barrier.fxmodel = util::spawn_model("tag_origin", barrier.origin);
			PlayFXOnTag(level._effect["fx_elec_jumppad_amb_ext_ring"], barrier.fxmodel, "tag_origin");
		}

		afterlife_hint = struct::get("quest_afterlife_hint", "targetname");
		if(isdefined(afterlife_hint))
		{
			fxmodel = util::spawn_model("tag_origin", afterlife_hint.origin);
			PlayFXOnTag(level._effect["fx_bucket_115_glow"], fxmodel, "tag_origin");
		}

	}

	if(level.teleporter_parts == 6)	// Teleporter buildable setup
	{
		level thread TeleporterBuildable();
		barrier = GetEnt("lockdown_barrier", "targetname");
		if(isdefined(barrier))
		{
			barrier MoveZ(-100, 0.05);
			if(isdefined(barrier.fxmodel))
				barrier.fxmodel Delete();	
		}
	}

	//ADDED AUDIO VOX HERE
	wait(5);
	if( isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_boss")
		return;
		
	str_sound = "vox_sm_ee_progress_0" + level.teleporter_parts;
	SmPlayQuote(str_sound);
	
}

function SetUpNumbers()		//self = player
{
	self.first_time_elemental = true;
	self thread WaitForSpikeUsed();
}

function WaitForSpikeUsed()
{
	self endon("disconnect");

	// self waittill( "spawned_player" );

	for(;;)
	{
		self waittill( "weapon_melee_power", weapon );
		
		if ( weapon == GetWeapon(STR_GRAVITYSPIKES_NAME) )
		{
			level notify( "plate_interaction", self );
		}
	}
}

function SpikeDestructibles()
{
	models = GetEntArray( "spike_destructible", "targetname" );
	if( !isdefined(models) || models.size < 1 )
		return;

	foreach(model in models)
	{
		model thread PlateWaitForDamage();
	}
}

function PlateWaitForDamage()	//self = model
{
	level endon("end_game");
	//self SetCanDamage(1);

	while(1)
	{
		level waittill( "plate_interaction", player );
		//IPrintLn("Interaction");
		if(isdefined(player) && Distance(self.origin, player.origin) < 80)
		{
			PlayFX(level._effect["fx_ritual_gatestone_explosion_zod_zmb"], self.origin);
			WAIT_SERVER_FRAME;
			self Ghost();
			self util::delay( 0.25, undefined, &zm_utility::self_delete );
			player thread GiveBackDG4();
			PlaySoundAtPosition("egg_done", self.origin);
			break;
		}
	}
}

function GiveBackDG4()
{
	self endon( "disconnect" );
	weapon = GetWeapon( STR_GRAVITYSPIKES_NAME );

	self zm_hero_weapon::take_hero_weapon();

	util::wait_network_frame(); // wait for connect function to wait.
	util::wait_network_frame(); // wait for connect function to wait.
	util::wait_network_frame(); // wait for connect function to wait.
		
	self zm_weapons::weapon_give( weapon, false, true );
	self GadgetPowerSet(self GadgetGetSlot(weapon), 100);
	self.hero_power = 100;
	self zm_weap_gravityspikes::update_gravityspikes_state( 2 );
}

function WatchAfterlifeNumbers( numbers )
{
	level endon("end_game");
	self endon("disconnect");

	level waittill("show_afterlife_numbers");
	DebugPrint("Number step initialized");

	while( level.teleporter_parts == 4 )
	{
		self waittill("entered_afterlife");
		foreach( number in numbers )
		{
			util::wait_network_frame();
			number SetInvisibleToPlayer( self, false );
			DebugPrint("Numbers visible");
		}

		self util::waittill_any("afterlife_done", "disconnect");
		foreach( number in numbers )
		{
			util::wait_network_frame();
			number SetInvisibleToPlayer( self, true );
			DebugPrint("Numbers invisible");
		}
	}
}

function NumberTeleWires( b_on = false )
{
	wire_active = GetEntArray("number_tele_wire_on", "targetname");
	wire_off = GetEntArray("number_tele_wire_off", "targetname");

	if(!isdefined(wire_active))
		return;

	if(!isdefined(wire_off))
		return;

	if( b_on )
	{
		foreach(wi in wire_active)
		{
			wi Show();
		}

		foreach(wo in wire_off)
		{
			wo Hide();
		}
	}

	else
	{
		foreach(wi in wire_active)
		{
			wi Hide();
		}

		foreach(wo in wire_off)
		{
			wo Show();
		}
	}
}

function teleporter_code_init()
{
	code_pieces = GetEntArray("tele_code_num","targetname");
	if(!isdefined(code_pieces) || code_pieces.size <= 0)
	{
		IPrintLnBold("No Teleporter code nums found!");
		return;
	}

	for(i = 0; i < code_pieces.size; i++)
	{
		code_pieces[i].codeindex = 0;
		code_pieces[i] SetCanDamage( true );
		code_pieces[i] thread WatchForShock( code_pieces[i].script_int );
	}
}

function WatchForShock( script_int )	//self = code model
{
	//level endon("tele_code_correct");
	if(!isdefined(script_int))
	{
		//IPrintLnBold("No script_int on tele code");
		return;
	}

	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		if( IsPlayer(e_attacker) && IS_TRUE(e_attacker.in_afterlife) && w_weapon == GetWeapon("wpn_afterlife") )
		{
			if(level.tele_timer)
				continue;

			if(!isdefined(self.codeindex))
			{
				self.codeindex = 0;
			}

			self.codeindex++;
			if(self.codeindex > 9)
			{
				self.codeindex = 0;
			}

			model = "pent_defcon_" +self.codeindex;
			self SetModel(model);
			level CheckCorrectCode();
		}
	}
}

function CheckCorrectCode()	//self = level
{
	code_pieces = GetEntArray("tele_code_num","targetname");
	for(i = 0; i < code_pieces.size; i++)
	{
		if(code_pieces[i].script_int == 1)
		{
			code_part_1 = code_pieces[i];
		}

		else if(code_pieces[i].script_int == 2)
		{
			code_part_2 = code_pieces[i];
		}

		else if(code_pieces[i].script_int == 3)
		{
			code_part_3 = code_pieces[i];
		}
	}

	codestring = "" + code_part_1.codeindex + "" + code_part_2.codeindex + "" + code_part_3.codeindex;
	if(codestring == level.telecode)
	{
		if(level.telecode_finished)
		{
			level.tele_timer = true;
			level SpinNumbers( code_part_1, code_part_2, code_part_3 );
			ClearNumbers( code_part_1, code_part_2,code_part_3 );
			level.tele_timer = false;
			return;
		}

		NumberTeleWires( true );

		tele = ArrayGetClosest(code_pieces[0].origin, GetEntArray("pe_teleporter_trigger"));
		fxmodel = util::spawn_model("tag_origin", tele.origin);
		fxmodel clientfield::set("tele_charge_hint", 2);

		level.tele_timer = true;
		level StartTimer( code_part_1, code_part_2, code_part_3 );
		level.tele_timer = false;

		NumberTeleWires( false );

		fxmodel clientfield::set("tele_charge_hint", 0);
		fxmodel util::delay( 0.25, undefined, &zm_utility::self_delete );

	}

	if(codestring == "666")
	{
		if(!IS_TRUE(level.telecode_spawned_bosses))
		{
			level.tele_timer = true;
			level thread zm_avogadro::spawn_avo();
			level thread engineer::spawn_engineer();
			level.telecode_spawned_bosses = true;
			level SpinNumbers( code_part_1, code_part_2, code_part_3 );
			ClearNumbers( code_part_1, code_part_2,code_part_3 );
			level.tele_timer = false;
		}
	}

	if(codestring == "935")
	{
		if(!IS_TRUE(level.telecode_perk))
		{
			level.tele_timer = true;
			struct = struct::get("code_perk_struct", "targetname");
			if(isdefined(struct))
			{
				zm_powerups::specific_powerup_drop( "free_perk", struct.origin);
			}

			level SpinNumbers( code_part_1, code_part_2, code_part_3 );
			ClearNumbers( code_part_1, code_part_2,code_part_3 );
			level.tele_timer = false;
		}
	}
}

function StartTimer( code_part_1, code_part_2, code_part_3 )
{
	SpinNumbers( code_part_1, code_part_2, code_part_3 );
	code_part_1 SetModel("pent_defcon_0");
	code_part_2 SetModel("pent_defcon_6");
	code_part_3 SetModel("pent_defcon_0");

	timer = 61;
	part_2_index = 6;
	part_3_index = 0;

	while(timer >= 0)
	{
		wait(1);
		timer--;
		code_part_2 PlaySound("timer_beep");
		if(timer % 10 == 0)
		{
			code_part_3 SetModel("pent_defcon_0");
			wait(1);
			code_part_2 PlaySound("timer_beep");
			timer--;	//59, 49, 39, 29, 19, 9
			part_2_index--;
			part_3_index = 9;
			code_part_2 SetModel("pent_defcon_" +part_2_index);
			code_part_3 SetModel("pent_defcon_" +part_3_index);

		}

		else
		{
			part_3_index--;
			code_part_3 SetModel("pent_defcon_" +part_3_index);
			//IPrintLnBold(timer);
			code_part_2 PlaySound("timer_beep");
		}
	}

	ClearNumbers( code_part_1, code_part_2, code_part_3 );

}

function ClearNumbers( code_part_1, code_part_2, code_part_3 )
{
	code_part_1 SetModel("pent_defcon_0");
	code_part_2 SetModel("pent_defcon_0");
	code_part_3 SetModel("pent_defcon_0");
	code_part_1.codeindex = 0;
	code_part_2.codeindex = 0;
	code_part_3.codeindex = 0;
}

function SpinNumbers( code_part_1, code_part_2, code_part_3 )
{
	code_part_2 PlaySound("timer_spin");
	for(i = 0; i < 20; i++)
	{
		wait(0.1);
		if( i % 2 )
		{
			code_part_1 SetModel("pent_defcon_0");
			code_part_2 SetModel("pent_defcon_0");
			code_part_3 SetModel("pent_defcon_0");
		}

		else
		{
			code_part_1 SetModel("pent_defcon_" + RandomInt(10));
			code_part_2 SetModel("pent_defcon_" + RandomInt(10));
			code_part_3 SetModel("pent_defcon_" + RandomInt(10));
		}

		i++;
	}
}

//============================================================
//						HANOI STEP
//============================================================

function HanoiArenaInit()
{
	trigger = GetEnt("hanoi_init_trigger", "targetname");
	if(!isdefined(trigger))
		return;

	level flag::set( "start_zone_zone_hanoi" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if( IsPlayer(user) )
		{
			wait(.5);

			level.telecode_finished = true;

			level flag::clear("spawn_zombies");
			level flag::set( "mid_boss_fight" );
			level ClearZombies();

			if(isdefined(level.CurrentGameMode) && level.CurrentGameMode != "zm_boss")
			{
				thread zm_project_e_music::play_music_for_players( "mus_mid_cutscene", false );
				zm_hanoi_boss::StartMidCutscene();
				wait(23);
			}

			else
			{
				zm_hanoi_boss::StartFight();
			}

			Earthquake( 0.4, 4, trigger.origin, 5000 );
			
			wait(1);

			players = GetPlayers();
			player = array::random(players);
			sound_to_play = "vox_plr_" +player GetCharacterBodyType() + "_hanoi_enter_00";
			player thread CustomPlayerQuote( sound_to_play );

			level flag::set("spawn_zombies");
			level thread HanoiFightCompleted();
			zm_powerups::specific_powerup_drop( "full_ammo", trigger.origin - (0, 0, 15));

			thread zm_project_e_music::play_music_for_players( "mus_fight_hanoi", false );	//mus_mid_cutscene
			break;
		}

	}

	trigger Delete();
}

function HanoiFightCompleted()
{
	//level endon("hanoi_completed");

	level thread BossFightDogSpawns();
	level thread SpawnBossFightEnemies();

	level waittill("hanoi_completed");

	level flag::clear("spawn_zombies");
	level flag::clear( "mid_boss_fight" );
	level ClearZombies();
	
	DebugPrint("hanoi completed");
		
	WAIT_SERVER_FRAME;
	
	util::playSoundOnPlayers("step_completed", undefined);

	level.teleporter_parts++;

	level thread CheckTeleParts();
	wait(5);

	level thread TeleportPlayersToSpawn();
	level flag::set("spawn_zombies");
}

function TeleportPlayersToSpawn()
{
	spawn = undefined;
	structs = struct::get_array("player_respawn_point", "targetname");
	for(j = 0; j < structs.size; j++)
	{
		if(isdefined(structs[j].script_noteworthy) && structs[j].script_noteworthy == "start_zone")
		{
			spawn = structs[j];
		}
	}

	target_pos = struct::get_array( spawn.target, "targetname" );

	players = GetPlayers();

	for(i = 0; i < players.size; i++)
	{
		PlaySoundAtPosition( "teleporter_beam_fx", players[i].origin );
		players[i] SetElectrified(2.0);
		players[i] SetOrigin(target_pos[i].origin);
		players[i] SetPlayerAngles(target_pos[i].angles);
		util::wait_network_frame();
	}
}

function BossFightDogSpawns()
{
	level endon("hanoi_completed");
	/*dog_spawns = GetBossFightDogSpawns();
	if(!isdefined(dog_spawns) || dog_spawns.size <= 0)
	{
		IPrintLnBold("No Dog Spawns Found in Boss Arena!");
		return;
	}*/

	while(1)
	{
		level.zombie_total = 24;	//V2 Edit. Use normal zombies instead of dogs, the fight was way too hectic
		wait(1);
	}
}

function CustomDogSpawn( spawn )
{
	if(!isdefined(spawn))
	{
		IPrintLnBold("Spawner not defined");
		return;
	}

	ai = zombie_utility::spawn_zombie( level.dog_spawners[0] );
	if( isdefined( ai ) ) 	
	{
		ai.favoriteenemy = zm_ai_dogs::get_favorite_enemy();
		spawn thread zm_ai_dogs::dog_spawn_fx( ai, spawn );
		level flag::set( "dog_clips" );
	}
}

function SpawnBossFightEnemies()
{
	level endon("hanoi_completed");
	index = 0;
	max_enemies = 5;
	while(index < max_enemies)
	{
		wait( RandomIntRange(8,14) );
		if( math::cointoss() )
		{
			engineer::spawn_engineer( false, true );
		}

		else
		{
			zm_ai_reverant::sonic_zombie_spawn();
			//zm_avogadro::spawn_avo( false, true );
		}

		index++;
	}

}

function GetBossFightDogSpawns()
{
	spawners = [];
	dog_locations = struct::get_array("dog_location", "script_noteworthy");
	for(i = 0; i < dog_locations.size; i++)
	{
		if( isdefined(dog_locations[i].targetname) && dog_locations[i].targetname == "zone_hanoi_spawners" )
		{
			spawners[spawners.size] = dog_locations[i];
		}
	}

	return spawners;
}

function HanoiSetPlayerState( state )
{
	if(state)
	{
		self FreezeControls( true );
		self DisableOffhandWeapons();
		self DisableWeapons();
		util::wait_network_frame();
	}

	else
	{
		self FreezeControls( false );
		self EnableOffhandWeapons();
		self EnableWeapons();
		util::wait_network_frame();
	}
}

//==============================

//AFTERLIFE STEPS HERE

//===============================

function AfterlifeCollectables()
{
	//level.afterlife_collectables = [];
	level.afterlife_collectables = GetEntArray( "afterlife_collectables","targetname" );
	if(!isdefined(level.afterlife_collectables))
		return;

	for(i = 0; i < level.afterlife_collectables.size; i++)
	{
		//level.afterlife_collectables[i] = collectables[i];
		level.afterlife_collectables[i] thread zm_powerups::powerup_wobble();
		level.afterlife_collectables[i] SetInvisibleToAll(  );
		level.afterlife_collectables[i] thread WatchForPickup();
	}
}

function UpdateAfterlifeCollectables()	//self = player
{
	if( level.teleporter_parts != 5 )
		return;

	self PlaySoundToPlayer("vox_sm_player_" + self.characterIndex, self );
	players = GetPlayers();
	if( players.size < 2 )
		self thread zm_project_e_music::play_sound_for_player( self.characterIndex, "mus_afterlife", zm_project_e_music::get_sound_playback_time("mus_afterlife"));

	if(!isdefined(level.afterlife_collectables))
	{
		level.teleporter_parts++;
		level thread CheckTeleParts();
		return;
	}

	for(i = 0; i < level.afterlife_collectables.size; i++)
	{
		level.afterlife_collectables[i] SetInvisibleToPlayer( self, false );
	}

	self waittill("afterlife_done");

	if(!isdefined(level.afterlife_collectables))
	{
		level.teleporter_parts++;
		level thread CheckTeleParts();
		return;
	}

	for(i = 0; i < level.afterlife_collectables.size; i++)
	{
		level.afterlife_collectables[i] SetInvisibleToPlayer( self, true );
	}
}

function WatchForPickup( max )
{
	level endon("intermission");
	level endon("end_game");

	level waittill( "afterlife_collectables" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		closest = ArrayGetClosest(self.origin, players);
		if(Distance(closest.origin, self.origin) < 60 && IS_TRUE(closest.in_afterlife) )
		{
			DebugPrint("Collected");
			PlayFX(level._effect["powerup_grabbed_solo"], closest.origin);
			closest PlaySound("zmb_perks_vulture_pickup");

			WAIT_SERVER_FRAME;
			self Delete();
			closest.aftime = level.afterlife_time / level.afterlife_time;
			//level.afterlife_parts++;
			parts_remaining = GetEntArray( "afterlife_collectables","targetname" );
			if( !isdefined(parts_remaining) || parts_remaining.size <= 0 )
			{
				util::playSoundOnPlayers( "step_completed", undefined );
				level.teleporter_parts++;
				level thread CheckTeleParts();
				closest notify("afterlife_done");
				level notify("higher_priority_sound");
				break;
			}
		}
	}
}

//==============================
//TELEPORTER BUILDABLE STEP HERE
//==============================

function TeleporterBuildable()
{
	struct = struct::get("ee_tele_buildable", "targetname");
	if(!isdefined(struct))
	{
		IPrintLnBold("No Teleporter struct");
		return;
	}

	tele_struct = struct::get( "ee_tele_struct", "targetname" );
	if(!isdefined(tele_struct))
	{
		IPrintLnBold("No Teleporter struct");
		return;
	}

	tele_door = GetEntArray("ee_tele_door","targetname");
	if(!isdefined(tele_door))
	{
		IPrintLnBold("No Teleporter Door");
		return;
	}

	barrier = GetEnt("lockdown_barrier", "targetname");
	if(!isdefined(barrier))
	{
		IPrintLnBold("No teleporter barrier");
		return;
	}

	trigger = Spawn("trigger_radius", struct.origin, 0, 38, 38);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Charge Teleporter" );

	trigger.in_use = false;
	crafting_completed = false;

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() && !IS_TRUE(trigger.in_use) )
		{
			craft_time = 0;
			trigger.in_use = true;
			user BeginCraft();

			user crafting_hud();

			while( zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() && user IsTouching(trigger) )
			{
				wait(0.05);
				craft_time+= 0.05;
				user.useBar hud::UpdateBar( craft_time );
				if(craft_time >= 1)
				{
					crafting_completed = true;
					user.useBar hud::destroyElem();
					user.useBarText Destroy();
					break;
				}

			}

			user EndCraft();
			user.useBar hud::destroyElem();
			user.useBarText Destroy();
			trigger.in_use = false;

			if(crafting_completed)
			{
				level.disable_final_tele = 1;
				util::playSoundOnPlayers("egg_done", undefined);

				a_models = [];
				a_models[0] = util::spawn_model("zm_115_meteor1", struct.origin);
				a_models[1] = util::spawn_model("zm_115_meteor_tree", struct.origin + (2, 2, 0));
				a_models[2] = util::spawn_model("p7_zm_zod_skull_dark", struct.origin + (-2, -3, 5));
	
				tele_trigger = Spawn("trigger_radius", tele_struct.origin, 0, 38, 38);
				tele_trigger SetCursorHint( "HINT_NOICON" );
				tele_trigger SetHintString( "Hold ^3&&1 ^7To Activate Teleporter" );

				tele_trigger thread ActivateFinalTele( tele_door, barrier, a_models );

				trigger Delete();
				break;
			}
		}
	}
}

function ActivateFinalTele( tele_door, barrier, a_models )
{
	demonroom = GetEnt("demonroom_area", "targetname");

	self SetHintString( "Hold ^3&&1 ^7To Activate Teleporter" );
	wait(1);
	while(1)
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() )
		{
			if(!AllPlayersTouchingEntity(demonroom))
			{
				self SetHintString("All players must be in Area!");
				wait(1);
				self SetHintString( "Hold ^3&&1 ^7To Activate Teleporter" );
				continue;
			}

			self SetHintString("");
			while( AnyPlayerTouchingEntity(self) )
			{
				WAIT_SERVER_FRAME;
			}

			if(isdefined(a_models))
			{
				for(m = 0; m < a_models.size; m++)
				{
					a_models[m] Delete();
				}
			}
			
			for(i = 0; i < tele_door.size; i++)
			{
				if( isdefined(tele_door[i].script_string) && tele_door[i].script_string == "clip" )
					tele_door[i] MoveZ(130, 0.05);

					else
					{
						tele_door[i] PlaySound("final_tele_door");
						tele_door[i] MoveZ(130, 1);
					}
			}

			barrier MoveZ(100, 0.05);

			wait(2);

			fxmodel_barrier = Spawn("script_model", barrier.origin);
			fxmodel_barrier SetModel("tag_origin");
			PlayFXOnTag(level._effect["fx_elec_jumppad_amb_ext_ring"], fxmodel_barrier, "tag_origin");

			level ClearZombies();

			players = GetPlayers();
			for(i = 0; i < players.size; i++)
			{
				if(i == 0)
					zm_powerups::specific_powerup_drop( "full_ammo", players[i].origin + (0, 0, 32));
					
				players[i] zm_utility::give_player_all_perks();
			}

			level thread TeleFightSpawnDogs();

			fxmodel = util::spawn_model( "tag_origin", self.origin );	//Spawn("script_model", self.origin);
			//fxmodel SetModel("tag_origin");
			WAIT_SERVER_FRAME;

			PlayFXOnTag(LIGHTNING_STORM, fxmodel, "tag_origin");
			fxmodel clientfield::set("final_tele_portal", 1);

			thread zm_project_e_music::play_music_for_players( "mus_pre_fight", false );

			wait(120);

			PlaySoundAtPosition("tele_power_down", fxmodel.origin);
			WAIT_SERVER_FRAME;

			fxmodel_barrier Delete();

			Earthquake( 0.4, 4, self.origin, 5000 );

			level notify("telefight_done");

			level ClearZombies();

			fxmodel PlayLoopSound("portal_loop");
			key_trigger = Spawn( "trigger_radius", fxmodel.origin, 0, 32, 32 );
			key_trigger TriggerIgnoreTeam();
			key_trigger SetVisibleToAll();
			key_trigger SetTeamForTrigger( "none" );
			key_trigger SetHintString( "Hold ^3&&1 ^7To use Portal" );
			self SetHintString( "Hold ^3&&1 ^7To use Portal" );

			wait(2);
			for(i = 0; i < tele_door.size; i++)
			{
				if( isdefined(tele_door[i].script_int) && tele_door[i].script_string == "clip" )
					tele_door[i] MoveZ(-140, 0.05);

				else
				{
					tele_door[i] PlaySound("final_tele_door");
					tele_door[i] MoveZ(-140, 1);
				}
			}

			barrier MoveZ(-100, 0.05);
			while(1)
			{
				WAIT_SERVER_FRAME;
				key_trigger waittill( "trigger", user );
				if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() )
				{
					if( AllPlayersTouchingEntity(demonroom) )
					{
						self SetHintString( "" );
						break;
					}

					else
					{
						key_trigger SetHintString( "All players must be in Area!" );
						self SetHintString( "All players must be in Area!" );
						wait(1);

						key_trigger SetHintString( "Hold ^3&&1 ^7To use Portal" );
						self SetHintString( "Hold ^3&&1 ^7To use Portal" );
						continue;
					}
				}
			}

			fxmodel clientfield::set("final_tele_portal", 0);
			WAIT_SERVER_FRAME;
			fxmodel Ghost();

			Earthquake( 0.4, 4, self.origin, 5000 );

			SmPlayQuote("vox_sm_ee_kill");

			level.teleporter_parts++;

			wait(4);

			fxmodel Delete();

			ghost = Spawn("script_model", self.origin);
			ghost SetModel("c_rus_scientist_body_ghost");
			ghost.angles = (0, 90, 0);
			PlayFXOnTag(level._effect["fx_ritual_black"], ghost, "j_spine4");

			PlayFX(level._effect["teleport_splash"], self.origin);
			PlayFX(level._effect["teleport_aoe"], self.origin);
			PlaySoundAtPosition( "zmb_sam_egg_appear", self.origin );

			ghost PlayLoopSound("tomahawk_loop");

			ghost UseAnimTree( #animtree );
			ghost AnimScripted("note_notify", ghost.origin, ghost.angles, %pb_scientist_ghost_idle);

			wait(5);

			players = GetPlayers();
			for(i = 0; i < players.size; i++)
			{
				players[i] thread PreFightPlayerKill( ghost );
			}
			
			self Delete();

			break;
		}
	}
}

function TeleFightSpawnDogs()
{
	level endon("telefight_done");
	level endon("intermission");
	level endon("end_game");

	//level thread SpawnRandomBoss();

	while(1)
	{
		level.zombie_total = 24;
		zm_ai_dogs::special_dog_spawn(1, undefined, undefined);
		wait(RandomFloatRange(0.2, 0.4));
	}
}

function SpawnRandomBoss()
{
	level endon("telefight_done");
	level endon("intermission");
	level endon("end_game");

	spawn = struct::get("zone_underground", "script_string");
	if(!isdefined(spawn))
		return;

	while(1)
	{
		zm_avogadro::SpawnAvoAtPosition( spawn );
		wait(RandomIntRange(15, 25));
	}
}

function BeginCraft()
{
	self zm_utility::increment_is_drinking();
	self zm_utility::disable_player_move_states(true);
	primaries = self GetWeaponsListPrimaries();
	original_weapon = self GetCurrentWeapon();
	weapon = GetWeapon("zombie_builder");
	self GiveWeapon(weapon);
	self SwitchToWeapon(weapon);
}

function EndCraft()
{
	self zm_utility::enable_player_move_states();
	weapon = GetWeapon("zombie_builder");

	if(self laststand::player_is_in_laststand() || IS_TRUE(self.intermission))
	{
		self TakeWeapon(weapon);
		return;
	}

	self zm_utility::decrement_is_drinking();
	self TakeWeapon(weapon);
	primaries = self GetWeaponsListPrimaries();
	if(IS_DRINKING(self.is_drinking))
	{
		return;
	}

	else
	{
		self zm_weapons::switch_back_primary_weapon();
	}
}

function crafting_hud()
{
	self.useBar = self hud::createPrimaryProgressBar();
	self.useBarText = self hud::createPrimaryProgressBarText();
	self.useBarText SetText("Charging...");
}

  ///////////////////////////////////////
 //   CRAFTING HUD UPDATE FUNCTION    //
///////////////////////////////////////
function crafting_hud_update(start_time, craft_time, trig, flag){
	self endon("entering_last_stand");
	self endon("death");
	self endon("disconnect");
	self endon("build_canceled");
 
	while(1){
		progress = (GetTime() - start_time) / craft_time;
		dist = Distance(self.origin, trig.origin);
		if(dist > 100 || !self UseButtonPressed() && progress < 1){
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			self notify("build_canceled");
			break;
		}
		if(progress < 0){
			progress = 0;
		}
		if(progress > 1 || GetTime() - start_time > craft_time && self UseButtonPressed()){
			level flag::set(flag);
			foreach(player in GetPlayers()){
				player notify(flag);
			}
			trig.built = true;
			self notify("build_complete");
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			return trig;
			break;
		}
		if(!self UseButtonPressed() && progress < 1){
			self.useBarText hud::destroyElem();
			self.useBar hud::destroyElem();
			self notify("build_canceled");
			break;
		}
		self.useBar hud::UpdateBar(progress);
		WAIT_SERVER_FRAME;
	}
}

function PreFightPlayerKillTest()	//Used for testing, need to remove trigger stuff
{
	trigger = GetEnt("kill_trigger","targetname");
	if(!isdefined(trigger) || trigger.size < 1)
	{
		return;
	}

	trigger SetHintString("Death awaits...");
	trigger SetCursorHint( "HINT_NOICON" );

	while(1)
	{
		trigger waittill("trigger", user);
		if( IsAlive(user) && zm_utility::is_player_valid(user) )
		{
			user thread PreFightPlayerKill();
			break;
		}
	}
}

function PreFightPlayerKill( ghost )
{
	//Revive downed players here
	if(self laststand::player_is_in_laststand() )
	{
		self zm_laststand::auto_revive(self, 0);
	}

	self EnableInvulnerability();
	self zm_utility::increment_ignoreme();

	fx = util::spawn_model("tag_origin", ghost.origin);
	PlayFXOnTag(level._effect["fx_ritual_black"], fx, "tag_origin");
	fx MoveTo( self.origin, 0.5 );
	wait( 0.5 );
	
	fx Delete();
	self notify("stop_player_out_of_playable_area_monitor");
	self DisableWeapons();
	linkmodel = Spawn("script_model", self.origin);
	linkmodel SetModel("tag_origin");

	sound_to_play = "vox_plr_" +self GetCharacterBodyType() + "_pre_fight_death_00";
	self thread CustomPlayerQuote( sound_to_play );

	self thread LinkModelCleanup( linkmodel );

	PlayFXOnTag(level._effect["fx_ritual_black"], linkmodel, "tag_origin");
	linkmodel thread CreateFxModels();
	util::wait_network_frame();

	wait(.1);
	self FreezeControls(true);
	self EnableLinkTo();
	self PlayerLinkTo( linkmodel );
	linkmodel MoveZ(40, 7);
	self thread FadeToBlack();
	linkmodel waittill("movedone");
	self Unlink();
	util::wait_network_frame();
	self zm_utility::decrement_ignoreme();
	self EnableWeapons();
	wait(0.2);
	self thread zm_afterlife_pe::WatchAfterlifeEnter( false, true, true, true );
	linkmodel SetModel(self GetCharacterBodyModel());
	linkmodel UseAnimTree(#animtree);
	linkmodel AnimScripted("note_notify", self.origin, self.angles, %player_ritual_loop);
	level thread zm_cyber::BossFightKillEnemies();
	wait(2);
}

function CreateFxModels()	//self = linkmodel
{
	self.fxmodel = Spawn("script_model", self.origin);
	self.fxmodel SetModel("tag_origin");

	self.fxmodel EnableLinkTo();
	self.fxmodel LinkTo(self);

	self.fxmodel.parents = [];
	self.fxmodel.parents[self.fxmodel.parents.size] = Spawn("script_model", self.origin + (30, 0, 0));
	self.fxmodel.parents[self.fxmodel.parents.size] = Spawn("script_model", self.origin + (0, 30, 0));
	self.fxmodel.parents[self.fxmodel.parents.size] = Spawn("script_model", self.origin + (0, 0, 30));
	for(i = 0; i < self.fxmodel.parents.size; i++)
	{
		self.fxmodel.parents[i] EnableLinkTo();
		self.fxmodel.parents[i] LinkTo(self.fxmodel);
		self.fxmodel.parents[i] SetModel("tag_origin");
		PlayFXOnTag(level._effect["fx_ritual_black"], self.fxmodel.parents[i], "tag_origin");
	}

	self.fxmodel thread RotateLoop();
}

function LinkModelCleanup( linkmodel )
{
	self util::waittill_any("disconnect", "death");
	if(isdefined(linkmodel))
	{
		if(isdefined(linkmodel.fxmodel))
		{
			if(isdefined(linkmodel.fxmodel.parents))
			{
				for(i = 0; i < linkmodel.fxmodel.parents.size; i++)
				{
					linkmodel.fxmodel.parents[i] Delete();
				}
			}

			linkmodel.fxmodel Delete();
		}

		linkmodel Delete();
	}
}

function BossFightInit()
{
	model = GetEnt("boss_fight_artifact", "targetname");
	if(!isdefined(model))
	{
		IPrintLnBold("No artifact found");
		return;
	}

	walls = GetEntArray("boss_fight_wall","targetname");
	if(!isdefined(walls))
	{
		IPrintLnBold("No walls found");
		return;
	}

	trigger = Spawn("trigger_radius", model.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Pick Up Artifact" );

	PlayFXOnTag(level._effect["fx_rune_glow_purple"], model, "tag_origin");

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed() )
		{
			level flag::set("boss_fight");
			util::playSoundOnPlayers( "egg_done_final",undefined );
			PlayFX(level._effect["powerup_grabbed_solo"], model.origin);
			WAIT_SERVER_FRAME;
			trigger Delete();
			model Delete();

			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_quest_part_grab_0" + RandomInt(5);
			user thread CustomPlayerQuote( sound_to_play );

			wait(1.5);

			thread SmPlayQuote("vox_sm_pre_fight_00");
			wait(5);
			//wait(SoundGetPlaybackTime("vox_sm_pre_fight_00"));
			thread SmPlayQuote("vox_sm_pre_fight_01");
			wait(16);
			//wait(SoundGetPlaybackTime("vox_sm_pre_fight_01"));

			wait(0.5);
			util::playSoundOnPlayers( "fire_explode_00", undefined );
			PlayFX( level._effect["fx_exp_molotov_lotus"], walls[0].origin );
			for(i = 0; i < walls.size; i++)
			{
				walls[i] Delete();
			}

			zm_cyber::SpawnCyber();

			players = GetPlayers();
			for(i = 0; i < players.size; i++)
			{
				a_struct = struct::get_array("player_" +(i + 1), "script_noteworthy");
				closest = ArrayGetClosest(players[i].origin, a_struct);
				if(isdefined(closest))
				{
					players[i] SetOrigin(closest.origin);
				}
			}

			wait(0.8);

			player = array::random(players);
			sound_to_play = "vox_plr_" +player GetCharacterBodyType() + "_quest_boss_see_00";
			player thread CustomPlayerQuote( sound_to_play );

			break;
		}
	}
}
//========================================
//=============AUDIO STUFF================
//========================================

function SmRoundVox()
{
	level endon("intermission");
	level endon("end_game");

	sound_index = 0;

	while(1)
	{
		level waittill("start_of_round");

		if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss"))
		{
			return;
		}

		if(level.round_number == 3)
		{
			if(level.sm_is_speaking)
			{
				while(level.sm_is_speaking)
				{
					WAIT_SERVER_FRAME;
				}
			}
			

			level.sm_is_speaking = true;
			util::playSoundOnPlayers( "vox_sm_intro", undefined );
			playbacktime = SoundGetPlaybackTime("vox_sm_intro");
			if(!isdefined(playbacktime))
			{
				level.sm_is_speaking = false;
				return;
			}

			if(playbacktime >= 0)
			{
				playbacktime = playbacktime * .001;
			}

			else
			{
				playbacktime = 1;
			}

			wait(playbacktime);
			level.sm_is_speaking = false;

			wait(2);
			players = GetPlayers();
			player = array::random(players);
			sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_intro_resp_00";
			player thread CustomPlayerQuote( sound_to_play );
		}

		if(level.round_number == 7 || level.round_number == 11 || level.round_number == 15 )
		{
			if(level.sm_is_speaking)
			{
				while(level.sm_is_speaking)
				{
					WAIT_SERVER_FRAME;
				}
			}
			
			level.sm_is_speaking = true;
			str_sound = "vox_sm_round_progress_0" + sound_index;
			util::playSoundOnPlayers(str_sound, undefined);

			playbacktime = SoundGetPlaybackTime( str_sound );
			if(!isdefined(playbacktime))
			{
				level.sm_is_speaking = false;
				sound_index++;
				return;
			}

			if(playbacktime >= 0)
			{
				playbacktime = playbacktime * .001;
			}

			else
			{
				playbacktime = 1;
			}

			wait(playbacktime);
			level.sm_is_speaking = false;
			sound_index++;

			players = GetPlayers();
			player = array::random(players);
			sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_intro_resp_0" + sound_index;
			player thread CustomPlayerQuote( sound_to_play );
		}
	}
}

function SmPlayQuote( str_sound )
{
	if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic" ) )
	{
		return;
	}

	if( level.sm_is_speaking )
	{
		while( level.sm_is_speaking )
		{
			WAIT_SERVER_FRAME;
		}
	}

	level.sm_is_speaking = true;
	util::playSoundOnPlayers(str_sound, undefined);

	playbacktime = SoundGetPlaybackTime( str_sound );
	if(!isdefined(playbacktime))
	{
		level.sm_is_speaking = false;
		return;
	}

	if(playbacktime >= 0)
	{
		playbacktime = playbacktime * .001;
	}

	else
	{
		playbacktime = 1;
	}

	level.sm_is_speaking = false;
}

function CustomPlayerQuote( sound_to_play )		//self = player
{
	if ( !isdefined( self.isSpeaking ) )
	{
		self.isSpeaking = false;
	}

	if ( self.isSpeaking ) 	// If already speaking, cancel the speech.
	{
		return;
	}

	self.speakingLine = sound_to_play;
		
	self.isSpeaking = true;		// TODO: this will eventually be converted to a flag.
				
	if(isPlayer(self))
	{
		self clientfield::set_to_player( "isspeaking",1 ); 
	}

	playbackTime = SoundGetPlaybackTime( sound_to_play );
		
	if( !isdefined( playbackTime ) )
		return;
		
	if ( playbackTime >= 0 )
	{
		playbackTime = playbackTime * .001;
	}
	else
	{
		playbackTime = 1;
	}

	if ( !self IsTestClient() )
	{
		self PlaySoundOnTag( sound_to_play, "J_Head" );
		wait(playbackTime);
	}
		
	if( isPlayer(self) && isDefined(self.last_vo_played_time)  )
	{
		if( GetTime() < ( self.last_vo_played_time + 5000 ) )
		{
			self.last_vo_played_time = GetTime();
			waittime = 7;
		}
	}
		
	wait( waittime );
		
	self.isSpeaking = false;	// TODO: this will eventually be converted to a flag.
				
	if(isPlayer(self))
	{
		self clientfield::set_to_player( "isspeaking",0 ); 
	}
	
}

//====================V2 Stuff==================
//==============================================
//==============================================

function SoulChestZombieDeath()	//V2, for collecting souls to meteors
{
	self endon( "delete" );
	
	self waittill( "death" );

	//IPrintLnBold("Zombie death");
	
	if ( !isdefined( self.attacker ) || !IsPlayer( self.attacker ) )
		return;
	
	//chests = level.chargable_meteors;
	chests = util::get_array_of_closest( self.origin, level.chargable_meteors, undefined, undefined, 275 );
	
	if ( !isdefined( chests ) || chests.size < 1 )
	{
		//IPrintLn("Meteors not found");
		return;
	}

	//IPrintLnBold("Found Chest");
	
	for ( i = 0; i < chests.size; i++ )
	{
		if ( !CanChargeChest( self, chests[ i ] ) )
			continue;
		
		chests[ i ] SoulChestTakeSoul( self );
		break;
	}
}

function CanChargeChest( zombie, model )
{
	if ( !SightTracePassed( zombie.origin, model.origin, 0, zombie ) )
		return 0;

	if( isdefined(model.trigger.ammo) )
	{
		if( model.trigger.ammo >= model.trigger.maxammo )
		{
			//IPrintLnBold("Can't charge");
			return 0;
		}
	}

	if( isdefined(model.trigger.script_noteworthy) )
	{
		weapon = GetWeapon(model.trigger.script_noteworthy);
		if( AnyPlayerHasWeapon(weapon) )
		{
			return 0;
		}
	}
	
	return 1;
}

function SoulChestTakeSoul( zombie )	//self = meteor model
{
	if( !isdefined(zombie) )
		return;

	soul = util::spawn_model("tag_origin", zombie.origin + (0, 0, 32) );
	PlayFXOnTag(level._effect["fx_staff_charge_souls"], soul, "tag_origin");
	soul PlayLoopSound("soul_loop");

	soul MoveTo( self.origin, 1.25, .5, .25 );
	soul waittill("movedone");
	PlaySoundAtPosition("soul_collect_0" + RandomInt(2), soul.origin);

	if( !isdefined(self.trigger.ammo) )
		self.trigger.ammo = 1;

	if( !isdefined(self.trigger.maxammo) )
		self.trigger.maxammo = 35;

	
	if( self.trigger.ammo < self.trigger.maxammo )
	{
		self.trigger.ammo++;
	}

	soul Delete();
}

//============================================================
//================ Utility functions =========================
//============================================================


function RotateLoop()
{
	self endon("death");
	level endon("end_game");
	while(isdefined(self))
	{
		self RotatePitch(360, 0.7);
		wait(0.7);
	}
}

function CustomSpawnDog( e_spawn )
{
	if(!isdefined(e_spawn))
	{
		IPrintLnBold("Spawner not defined");
		return;
	}

	ai = zombie_utility::spawn_zombie( level.dog_spawners[0] );
	if( isdefined( ai ) ) 	
	{
		ai.favoriteenemy = zm_ai_dogs::get_favorite_enemy();
		e_spawn thread zm_ai_dogs::dog_spawn_fx( ai, e_spawn );
		level flag::set( "dog_clips" );
	}

}

function PlayerHasElemental()
{
	weapons = [];
	weapons[weapons.size] = GetWeapon("spell_ice");
	weapons[weapons.size] = GetWeapon("spell_ice_ug");
	weapons[weapons.size] = GetWeapon("spell_wind");
	weapons[weapons.size] = GetWeapon("spell_wind_ug");
	weapons[weapons.size] = GetWeapon("spell_fire");
	weapons[weapons.size] = GetWeapon("spell_fire_ug");
	weapons[weapons.size] = GetWeapon("spell_lightning");
	weapons[weapons.size] = GetWeapon("spell_lightning_ug");

	foreach(weapon in weapons)
	{
		primaries = self GetWeaponsListPrimaries();
		foreach(primary in primaries)
		{
			if(primary == weapon)
			{
				return true;
			}
		}
		
	}

	return false;
}

function AnyPlayerHasWeapon( weapon )	//Check to see if any player has the weapon
{
	if(!isdefined(weapon))
	{
		return;
	}

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		primaries = players[i] GetWeaponsListPrimaries();
		for(j = 0; j < primaries.size; j++)
		{
			if(primaries[j] == weapon)		//Someone has this weapons, return true
			{
				return true;
			}
		}
	}

	return false;
}

function AnyPlayerTouchingEntity( entity )	//Check to see if any player is touching the given entity
{
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] IsTouching(entity))	//Found someone
		return true;
	}

	return false;
}

function FadeToBlack( init_wait_time = 5, time = 3 )
{
	self endon("intermission");
	//time = 3;
	wait(init_wait_time);
	fadeToWhite = NewClientHudElem( self );
	fadeToWhite.x = 0;
	fadeToWhite.y = 0;
	fadeToWhite.alpha = 0;

	fadeToWhite.horzAlign = "fullscreen";
	fadeToWhite.vertAlign = "fullscreen";
	fadeToWhite.foreground = false;
	fadeToWhite.sort = 50;
	fadeToWhite SetShader( "black", 640, 480 );
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 1;
	wait(time);
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 0;
	wait(1);
	fadeToWhite Destroy();
}

function ClearZombies()
{
	zombies = GetAITeamArray("axis");
	for(i = 0; i < zombies.size; i++)
	{
		if(IS_TRUE(zombies[i].is_boss))
			zombies[i].allowDeath = true;
			
		WAIT_SERVER_FRAME;
		zombies[i] DoDamage(zombies[i].health + 666, zombies[i].origin);
	}
}

function CheckInPlayableArea()	//self = entity
{
	playable_area = GetEntArray( "player_volume", "script_noteworthy" );
	for(i = 0; i < playable_area.size; i++)
	{
		if(self IsTouching(playable_area[i]))
		{
			return true;
		}
	}

	return false;
}

function AllPlayersTouchingEntity( entity )
{
	players = GetPlayers();

	touchers = [];

	for(i = 0; i < players.size; i++)
	{
		if( players[i] IsTouching( entity ) && !IS_TRUE(players[i].in_afterlife) )
		{
			touchers[touchers.size] = players[i];
		}
	}

	if(players.size == touchers.size)
		return true;

	return false;
}

