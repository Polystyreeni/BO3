#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_score;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
//HARRY
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_vulture_aid;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_random;

//CUSTOM
#using scripts\zm\_zm_perk_timewarp;
#using scripts\shared\abilities\gadgets\_gadget_flashback;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;


//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;
#using scripts\zm\_zm_trap_fire;

#using scripts\zm\zm_usermap;
//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

//ZOMBLOOD
#using scripts\_NSZ\nsz_powerup_zombie_blood;
//ELECTROSHIELD
//#using scripts\ik\powerup_electricity_shield;

//Elemental Weapons
#using scripts\ik\zm_weapon_wind;
#using scripts\ik\zm_weapon_lightning;
#using scripts\ik\zm_weapon_fire;
#using scripts\ik\zm_weapon_ice;

//Afterlife
#using scripts\zm\zm_afterlife_pe;
#using scripts\zm\zm_afterlife_shockboxes;

#using scripts\zm\_zm_spawner;

#using scripts\zm\zm_usermap;

//Generator
#using scripts\ik\zm_generators;

//DIGSITE
#using scripts\ik\zm_digsite;

//Symbos score share
#using scripts\zm\give_money;

//Gamemodes
#using scripts\zm\zm_gamemode_gungame;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\zm_gamemode_scavenger;
#using scripts\zm\zm_gamemode_bossbattle;

//IMS
#using scripts\zm\craftables\_zm_craft_ims;
#using scripts\zm\zm_weap_ims;

#using scripts\zm\zm_project_e_ee;

//Boss fight
#using scripts\bosses\zm_cyber;

//Fire Zombie
#using scripts\bosses\zm_fire_zombie;

//Teleporter
#using scripts\ik\zm_teleporter_pe;

#using scripts\zm\_hb21_sym_zm_trap_acid;
#using scripts\zm\_hb21_zm_trap_flogger;

//Custom Powerups By ZoekMeMaar
#using scripts\_ZoekMeMaar\custom_powerup_free_packapunch;

//Origins mud
#using scripts\zm\_zm_slowdown_trigger;

//Cleanup script
#using scripts\zm\zm_project_e_cleanup_mgr;

//Cutscene
#using scripts\zm\zm_cutscene;

#using scripts\zm\zm_project_e_music;

//V2 Scripts
#using scripts\zm\zm_weap_tomahawk;
#using scripts\zm\zm_tomahawk_quest;
#using scripts\bosses\zm_ai_reverant;
#using scripts\zm\zm_weap_crossbow;
#using scripts\bosses\zm_hanoi_boss;
#using scripts\zm\zm_project_e_challenges;
#using scripts\ik\zm_teleporter_pe_main;
#using scripts\zm\_zm_weap_gravityspikes;

#using scripts\zm\floating_debris;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	//Clientfield debug
	//SetDvar( "com_clientfieldsdebug", "1" );
	// ENGINEER
	engineer::init();
	zm_cyber::init();
	zm_project_e_music::init();

	//Rocket Shield
	clientfield::register( "clientuimodel", "zmInventory.widget_shield_parts", VERSION_SHIP, 1, "int" );
	clientfield::register( "clientuimodel", "zmInventory.player_crafted_shield", VERSION_SHIP, 1, "int" );

	//clientfield::register("world", "add_elemental_weapons",	VERSION_SHIP, 1, "int" );

	clientfield::register("toplayer", "lightning_strike", VERSION_SHIP, 1, "counter");

	level.lightningstrike_delay = 45; // You can change this value to suit


	//WINDGUN and Lightning
	//level thread zm_weapon_wind::init();
	//level thread zm_weapon_lightning::init();
 
	//DIGSITES
	zm_digsite::init();

	//REMOVE IF ISSUES WITH GEN
	level.dog_rounds_allowed = 0;
	level.use_powerup_volumes = true;
	level.random_pandora_box_start = 1;

	zm_usermap::main();

	level.pack_a_punch_camo_index = 26;
	level.perk_purchase_limit = 5;

	level.default_laststandpistol 		= GetWeapon( "iw8_1911" );
	level.default_solo_laststandpistol	= GetWeapon( "iw8_1911_rdw_up" );

	// V2 Addons: Remove if gameplay gets too fast
	zombie_utility::set_zombie_var( "zombie_new_runner_interval", 		 8,	false );		//	Interval between changing walkers who are too far away into runners 
	zombie_utility::set_zombie_var( "zombie_move_speed_multiplier", 	  5,	false );	//	Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint
	zombie_utility::set_zombie_var( "zombie_move_speed_multiplier_easy",  3,	false );	//	Multiply by the round number to give the base speed value.  0-40 = walk, 41-70 = run, 71+ = sprint

	// ADD THIS TO PROJECT ELEMENTAL
	level thread CustomMaxAmmo();
	level thread AllowCheats();
	level thread setApocalypse();
	level thread add_zm_vox();

	zm_spawner::register_zombie_death_event_callback( &check_hades_death );

	callback::on_connect(&ReloadQuotes);
	callback::on_spawned( &on_player_spawned );

	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;

	init_zones[0] = "start_zone";
	init_zones[1] = "zone_boss";
	init_zones[2] = "zone_hanoi";

	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	zm_utility::register_tactical_grenade_for_level("zombie_tomahawk");
	zm_utility::register_tactical_grenade_for_level("zombie_tomahawk_upgraded");

	level.pistol_values = [];
	level.pistol_values[ level.pistol_values.size ] = level.default_laststandpistol;
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "m9a1" );
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "nambu" );
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "s2_p38" );
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "t6_makarov" );
	level.pistol_value_solo_replace_below = level.pistol_values.size - 1;  // EO: anything scoring lower than this should be replaced
	level.pistol_values[ level.pistol_values.size ] = level.default_solo_laststandpistol;
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "44magnum" );
	level.pistol_values[ level.pistol_values.size ] = GetWeapon( "44magnum_rdw" );
}

function usermap_test_zone_init()
{
	//Start zone
	zm_zonemgr::add_adjacent_zone( "start_zone",		"zone_right_bottom",		"start_zone_zone_left_low" );
	zm_zonemgr::add_adjacent_zone( "start_zone",		"zone_water",		"start_zone_zone_water" );

	//Zone water
	zm_zonemgr::add_adjacent_zone( "zone_water",		"zone_factory",		"zone_water_zone_factory" );

	//Zone factory
	zm_zonemgr::add_adjacent_zone( "zone_factory",		"zone_chem",		"zone_factory_zone_chem" );

	//Zone chem
	zm_zonemgr::add_adjacent_zone( "zone_chem",		"zone_dam",		"zone_chem_zone_dam" );

	//Zone dam
	zm_zonemgr::add_adjacent_zone( "zone_dam",		"zone_road_bottom",		"zone_dam_zone_road_bottom" );
	zm_zonemgr::add_adjacent_zone( "zone_dam",		"zone_gen_top",		"zone_dam_zone_gen_top" );
	zm_zonemgr::add_adjacent_zone( "zone_dam",		"zone_radiation",		"zone_dam_zone_radiation" );
	zm_zonemgr::add_adjacent_zone( "zone_dam",		"zone_biolab",		"zone_dam_zone_biolab" );

	//Zone radiation
	zm_zonemgr::add_adjacent_zone( "zone_radiation",		"zone_mine_enter",		"zone_radiation_zone_mine_enter" );
	
	//Zone mine enter
	zm_zonemgr::add_adjacent_zone( "zone_mine_enter",		"zone_mine",		"zone_mine_enter_zone_mine" );

	//Zone gen top
	zm_zonemgr::add_adjacent_zone( "zone_mine",		"zone_gen_top",		"zone_mine_zone_gen_top" );

	//Zone teleporter
	zm_zonemgr::add_adjacent_zone( "zone_teleporter",		"zone_top",		"zone_teleporter_zone_top" );

	//Zone top
	zm_zonemgr::add_adjacent_zone( "zone_top",		"zone_hang",		"zone_top_zone_hang" );
	zm_zonemgr::add_adjacent_zone( "zone_top",		"zone_prison",		"zone_top_zone_prison" );

	//Zone hang
	zm_zonemgr::add_adjacent_zone( "zone_hang",		"zone_prison",		"zone_hang_zone_prison" );
	zm_zonemgr::add_adjacent_zone( "zone_hang",		"zone_hut",		"zone_hang_zone_hut" );
	zm_zonemgr::add_adjacent_zone( "zone_hang",		"zone_right_gen",		"zone_hang_zone_right_gen" );
	zm_zonemgr::add_adjacent_zone( "zone_hang",		"zone_vat",		"zone_hang_zone_vat" );

	//Zone road bottom
	zm_zonemgr::add_adjacent_zone( "zone_road_bottom",		"zone_vat",		"zone_road_bottom_zone_vat" );
	zm_zonemgr::add_adjacent_zone( "zone_road_bottom",		"zone_laboratory_enter",		"zone_road_bottom_zone_laboratory_enter" );
	zm_zonemgr::add_adjacent_zone( "zone_road_bottom",		"zone_hang",		"zone_road_bottom_zone_hang" );

	//Zone vat
	zm_zonemgr::add_adjacent_zone( "zone_vat",		"zone_pap",		"zone_vat_zone_pap" );

	//Zone biolab
	zm_zonemgr::add_adjacent_zone( "zone_biolab",		"zone_armory",		"zone_biolab_zone_armory" );

	//Zone armory
	zm_zonemgr::add_adjacent_zone( "zone_armory",		"zone_pap",		"zone_armory_zone_pap" );

	//zone pap
	zm_zonemgr::add_adjacent_zone( "zone_pap",		"zone_underground",		"zone_pap_zone_underground" );

	//Zone underground
	zm_zonemgr::add_adjacent_zone( "zone_underground",		"zone_underground_lab",		"zone_underground_zone_underground_lab" );

	//Zone underground lab
	//zm_zonemgr::add_adjacent_zone( "zone_underground_lab",		"zone_dam",		"zone_underground_lab_zone_dam" );
	
	//Zone right bottom
	zm_zonemgr::add_adjacent_zone( "zone_right_bottom",		"zone_hell",		"zone_right_bottom_zone_hell" );

	//Zone hell
	zm_zonemgr::add_adjacent_zone( "zone_hell",		"zone_road_bottom",		"zone_hell_zone_road_bottom" );

	//Zone gen top
	zm_zonemgr::add_adjacent_zone( "zone_gen_top",		"zone_teleporter",		"zone_gen_top_zone_teleporter" );
	zm_zonemgr::add_adjacent_zone( "zone_gen_top",		"zone_hang",		"zone_gen_top_zone_hang" );
	zm_zonemgr::add_adjacent_zone( "zone_gen_top",		"zone_mine_enter",		"zone_gen_top_zone_mine_enter" );

	//Zone tank bottom
	//zm_zonemgr::add_adjacent_zone( "zone_tank_bottom",		"zone_laboratory",		"zone_tank_bottom_zone_laboratory" );
	
	//Zone laboratory enter
	//zm_zonemgr::add_adjacent_zone( "zone_gen_ti",		"zone_laboratory",		"zone_laboratory_enter_zone_laboratory" );
}

function setApocalypse()	//TESTING, REMOVE LATER
{
	wait(2);
	level util::set_lighting_state(2);
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_project_e_weapons.csv", 1);
}

function add_zm_vox()
{
	zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_zc_vox.csv");
}

function CustomMaxAmmo()
{
	level endon("end_game");
	while(1)
	{
		level waittill("zmb_max_ammo_level");
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			primaries = players[i] GetWeaponsListPrimaries();
			for(j = 0; j < primaries.size; j++)
			{
				weapon = GetWeapon(primaries[j].name);
				players[i] SetWeaponAmmoClip(primaries[j], weapon.clipSize);
			}
		}
	}
}

function AllowCheats()
{
	level flag::wait_till( "initial_blackscreen_passed" );

	//TODO: Remove this, uncomment below
	//SetDvar("sv_cheats", "1");

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i].playername == "ihmiskeho" || players[i].playername == "Polystyreeni" || players[i].playername == "MdMaxx")
		{
			SetDvar("sv_cheats","1");
		}
	}
}

function ReloadQuotes()
{
	self thread ReloadWatcher();
}

function ReloadWatcher()
{
	self endon("disconnect");
	level endon("end_game");

	cooldown_time = 75;
	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_reload";

	while(1)
	{
		self waittill("reload_start");
		self thread CustomPlayerQuote( sound_to_play );
		wait(cooldown_time);
	}
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

function on_player_spawned()
{
	level endon("game_ended");
	self endon("death");
	self endon("disconnect");

	self thread lightning_strike_player();
}

function lightning_strike_player()
{
	self endon("disconnect");

	util::wait_network_frame();

	while(1)
	{
		if(isdefined(self) && IsPlayer(self))
		{
			self notify("lightning_strike");
			self clientfield::increment_to_player("lightning_strike", 1);
			//IPrintLn("Strike");
		}

		wait(level.lightningstrike_delay);
	}
}

function check_hades_death( attacker )
{
	if ( isdefined( self.damageweapon ) && !( self.damageweapon === level.weaponNone ))
	{
		if ( IS_EQUAL( self.damageweapon, GetWeapon("t7_olympia_upgraded") ) )
		{
			self zm_spawner::dragons_breath_flame_death_fx();
		}
	}
}
