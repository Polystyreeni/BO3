/*==========================================
Afterlife script by ihmiskeho
V1.0
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
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\ik\zm_generators;
#using scripts\ik\zm_digsite;
#using scripts\zm\zm_afterlife_shockboxes;
#using scripts\zm\zm_weap_tomahawk;
#using scripts\zm\_zm_weap_gravityspikes;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\zm_project_e_ee;
#using scripts\zm\_zm_unitrigger;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#precache("material", "afterlife_on");
#precache("material", "afterlife_off");
#precache("material", "afterlife_shockbox_hint");

#precache("model", "p7_zm_zod_power_box_yellow_emissive");

#define AFTERLIFE_TRAIL		"electric/fx_ability_elec_strike_trail" //"player/fx_dni_mesh_trail_clean"
#precache( "fx", AFTERLIFE_TRAIL );
#precache( "fx", "dlc1/castle/fx_plyr_screen_115_liquid");
#precache( "fx", "zombie/fx_bmode_glow_pwrbox_zod_zmb" );

#using_animtree( "all_player" );

#namespace zm_afterlife_pe;

REGISTER_SYSTEM_EX( "zm_afterlife_pe", &init, &__main__, undefined )

function init()
{
	//Global Variables
	level.afterlife_time = 30;		//Afterlife base time
	level.AfterlifeDebug = false;	//Debug
	level.afterlife_vision = "zm_afterlife";
	//Leave This

	//Clientfields:
	clientfield::register( "toplayer", "afterlife_torso_fx",	VERSION_SHIP, 1, "int" );
	clientfield::register( "allplayers", "afterlife_world_fx",	VERSION_SHIP, 1, "int" );
	clientfield::register( "toplayer", "afterlife_shockhints",	VERSION_SHIP, 1, "int" );

	//clientfield::register( "clientuimodel", "afterlifeMana", 1, 8, "float" );

	//Callbacks
	zm_spawner::register_zombie_damage_callback( &AfterLifeStunZombies );

}

function __main__()
{
	//level.playerlaststand_func  	= &afterlife_laststand;		//level.playerlaststand_func

	level.is_player_valid_override = &afterlife_player_valid_func;

	level.powerup_grab_get_players_override = &AfterlifeDisablePowerUps;

	//level.get_closest_valid_player_override = &AfterlifeClosestValidOverrinde;

	level.custom_door_buy_check = &AfterlifeDisableDoors;		//This is to fix a random issue where players can open all doors in afterlife, even though they have no money

	visionset_mgr::register_info( "visionset", level.afterlife_vision,VERSION_SHIP, 90, 16, true, &visionset_mgr::ramp_in_out_thread_per_player_death_shutdown, false );

	callback::on_connect( &setAfterlife );

	thread main();
}

function afterlife_player_valid_func( player )
{
	if(IS_TRUE(player.in_afterlife))
	{
		return false;
	}
	
	return true;
}

function AfterlifeClosestValidOverrinde()
{
	valid_players = [];
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(!IS_TRUE(players[i].in_afterlife))
		{
			valid_players[valid_players.size] = players[i];
		}
	}

	return valid_players;
}

function AfterlifeDisablePowerUps()
{
	grabbers = [];
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(!IS_TRUE(players[i].in_afterlife))
		{
			grabbers[grabbers.size] = players[i];
		}
	}

	return grabbers;
}

function AfterlifeDisableDoors( door )
{
	if(IS_TRUE(self.in_afterlife))
	{
		return false;
	}

	return true;
}

function AfterlifePrint(string)
{
	if(isdefined(string) && isdefined(level.AfterlifeDebug) && level.AfterlifeDebug)
		IPrintLnBold("AF DEBUG:" +string);
}

function main()
{
	level flag::wait_till( "initial_blackscreen_passed" );
	a_trig = GetEntArray("afterlife_trigger", "targetname");

	if(!isdefined(a_trig) || a_trig.size <= 0)
	{
		AfterlifePrint("No afterlife triggers found!!!");
		return;
	}
	else 
	{
		AfterlifePrint("Trigger defined");
	}
	for(i = 0; i < a_trig.size; i++)
	{
		a_trig[i] thread WatchAfterlifeTrigger();
	}



	a_shockbox = GetEntArray("afterlife_shockbox", "targetname");		//These are models
	if(!isdefined(a_shockbox) || a_shockbox.size <= 0)
	{
		AfterlifePrint("No afterlife shockboxes found!!!");
		return;
	}

	for(i = 0; i < a_shockbox.size; i++)
	{
		if(isdefined(a_shockbox[i]).script_string && a_shockbox[i].script_string == "generator_shockbox")
		{
			a_shockbox[i] thread zm_generators::ShockGenerators();
		}

		else
		{
			a_shockbox[i] thread zm_afterlife_shockboxes::WatchForShock();
		}
	}
}

function WatchAfterlifeTrigger()
{
	self endon("disconnect");
	if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss") )
	{
		self SetHintString("Afterlife is Disabled in this Gamemode!");
		return;
	}

	self SetHintString("Press ^3[{+activate}]^7 to Enter Afterlife");
	self SetCursorHint("HINT_NOICON");
	while(1)
	{
		self waittill("trigger", user);

		if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss") )
		{
			self SetHintString("Afterlife is Disabled in this Gamemode!");
			return;
		}
		if( IsPlayer(user) && !IS_TRUE(user.in_afterlife) && zm_utility::is_player_valid( user ) && user.afterlifes > 0 && !user HasWeapon(GetWeapon("minigun")))//if(!IS_TRUE(user.in_afterlife) && isdefined(user.afterlifes) && user.afterlifes >= 1 && IsPlayer(user) && zm_utility::is_player_valid( user ))
		{
			if(user GetCurrentWeapon() == GetWeapon("hero_gravityspikes_melee"))
				continue;
				
			user thread zm_audio::playerExert( "hitlrg" );
			user thread WatchAfterlifeEnter(false);
			self SetHintString( "" );
			self TriggerEnable(false);
			user util::waittill_any("afterlife_done", "afterlife_timeout", "disconnect", "death");
			wait(2);	//For debug
			AfterlifePrint("Trigger enabled");
			self TriggerEnable(true);
			self SetHintString("Press ^3[{+activate}]^7 to Enter Afterlife");
		}	

		else
		{
			if(user.afterlifes <= 0)
			{
				self SetHintStringForPlayer( user, "Afterlife Not Available" );
				wait(1);
				self SetHintStringForPlayer( user, "Press ^3[{+activate}]^7 to Enter Afterlife" );
			}

			user PlaySound("zmb_deny");
			AfterlifePrint("Not Valid");
		}
	}
}

function afterlife_laststand()
{
	//self endon("death");
	self endon( "player_suicide" );
	self endon( "disconnect" );

	if(isdefined(self.afterlifes) && self.afterlifes >= 1)
	{
		IPrintLnBold("Laststand override ran");
		zm_laststand::increment_downed_stat();
		self.ignore_insta_kill = 1;
		self.health = 1; 

		level notify( "fake_death" );
		self notify( "fake_death" );
		self WatchAfterlifeEnter(true);

		self.ignore_insta_kill = undefined;
		self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );

		return true;
	}

	else
	{
		return false;
	}
}

function WatchAfterlifeEnter(is_death, savelocation = false, spawncorpse = true, infinite_afterlife = false )
{
	self endon("disconnect");
	self AllowStand( 0 );
	self AllowCrouch( 0 );
	self AllowProne( 1 ); 
	self AllowSlide( 0 );
	self AllowMelee( 0 );
	self SetStance("prone");
	wait(.1);
	self EnableInvulnerability();
	self FreezeControls(true);
	wait(.1);
	//self.ignoreme = true;
	self zm_utility::increment_ignoreme();	//Test
	
	if(!IS_TRUE(is_death))
	{
		self thread CreateFadeToWhite();
	}
	
	self AfterlifeSaveLoadout();
	self zm_score::minus_to_player_score( self.loadout.score );
	perks = self zm_perks::get_perk_array();

	i = 0;
	while ( i < perks.size )
	{
		self notify( perks[ i ] + "_stop" );
		i++;
	}
	self PlaySoundToPlayer( "afterlife_enter", self );
	wait(2);

	self TakeAllWeapons();

	//Clone stuff, needed for revive trigger etc

	clone = self CreatePlayerClone( infinite_afterlife );
	self thread DeleteCorpse(clone);
	self thread WatchForFakeRevive(clone);
	
	//self thread AfterlifeWatchDeath();
	self thread EnterAfterlife( savelocation, infinite_afterlife );
	self thread CreateAfterlifeBody();
	self thread ClearGrenades();

	self notify("entered_afterlife");	//Added for numbers

	self waittill( "afterlife_done" );
	WAIT_SERVER_FRAME;
	self PlaySoundToPlayer( "afterlife_over", self );
	self zm_score::add_to_player_score( self.loadout.score );

	self AfterlifeGiveWeapons(is_death);
	self zm_utility::decrement_ignoreme();

	self ClearPlayerGravity();
	self DisableInvulnerability();
	self AllowSlide( 1 );
	self AllowMelee( 1 );
	self AllowCrouch( 1 );
	self AllowProne( 1 );

	self UpdateAfterlifeHud();

	self util::delay(2, undefined, &PlayAfterlifeQuote);
	//self notify("ready_for_downing");
}

function PlayAfterlifeQuote()
{
	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_afterlife_over_0" + RandomInt(3);
	self thread CustomPlayerQuote( sound_to_play );
}

function ClearGrenades()	//Temp fix, until something better comes up
{
	self endon( "afterlife_done" );
	self endon("disconnect");

	while(1)
	{
		level waittill("start_of_round");
		lethal_grenade = self zm_utility::get_player_lethal_grenade();
		if ( self HasWeapon( lethal_grenade ) )
		{
			self SetWeaponAmmoClip( lethal_grenade, 0 );
		}
	}
	
}

function AfterlifeSaveLoadout()
{
	//Credit to HarryBo21
	primaries = self getWeaponsListPrimaries();
	
	currentweapon = self GetCurrentWeapon();
	self.loadout = spawnStruct();
	self.loadout.player = self;
	self.loadout.weapons = [];
	self.loadout.score = self.score;
	self.loadout.current_weapon = -1;
	_a366 = primaries;
	index = GetFirstArrayKey( _a366 );
	while ( isDefined( index ) )
	{
		weapon = _a366[ index ];

		if(weapon == getWeapon("hero_gravityspikes_melee"))
			continue;
		
		self.loadout.weapons[ index ] = zm_weapons::get_player_weapondata( self, weapon );
		
		if ( !isdefined( weapon ) )
			weapon = level.weaponNone;
		
		if ( isdefined( weapon ) && weapon == currentweapon )
			self.loadout.current_weapon = index;
	 	
		index = GetNextArrayKey( _a366, index );
	}
	self.loadout.equipment = self zm_equipment::get_player_equipment();
	if ( isDefined( self.loadout.equipment ) )
		self zm_equipment::take( self.loadout.equipment );
	
	self.loadout save_melee_weapon( self );
	if ( self HasWeapon( GetWeapon( "iw6_ims_equipment" ) ) )
	{
		self.loadout.hasclaymore = 1;
		self.loadout.claymoreclip = self GetWeaponAmmoClip( GetWeapon( "iw6_ims_equipment" ) );
	}
	self.loadout.perks = self zm_perks::get_perk_array();// self.active_perks; // self zm_perks::get_perk_array();
	self save_grenades();

	//V2 edit: Added hero weapon logic
	self.loadout.heroweapon = self zm_utility::get_player_hero_weapon();
	if(isdefined(self.loadout.heroweapon))
	{
		self.loadout.heropower = self GadgetPowerGet( self GadgetGetSlot( self.loadout.heroweapon ) );
		if(self.loadout.heroweapon == GetWeapon("hero_gravityspikes_melee"))
		{
       		self.loadout.heroGravitySpikesClip = self GetWeaponAmmoClip(self.loadout.heroweapon);
		}

		if(IS_TRUE(self.b_gravity_trap_spikes_in_ground))
		{
			self notify("gravity_trap_spikes_retrieved");
			if(isdefined(self.gravity_trap_unitrigger_stub))
			{
				zm_unitrigger::unregister_unitrigger( self.gravity_trap_unitrigger_stub );
				self.gravity_trap_unitrigger_stub = undefined;
			}

			for(i = 0; i < self.mdl_gravity_trap_spikes.size; i++)
			{
				self.mdl_gravity_trap_spikes[i] Delete();
			}
		}

		self zm_hero_weapon::take_hero_weapon();
	}
}

function save_melee_weapon(player)
{
	self.meleewpn = player zm_utility::get_player_melee_weapon();
}

function restore_melee_weapon(player)
{
	player zm_weapons::weapon_give( self.meleewpn );
	player zm_utility::set_player_melee_weapon( self.meleewpn );
	self.meleewpn = undefined;
}

function override_tomahawk_tactical()	//V2 edit. This makes it possible to obtain the hell's redeemer while in afterlife
{
	self.loadout.tactical_grenade = GetWeapon("zombie_tomahawk_upgraded");
	self.current_tomahawk_weapon = self.loadout.tactical_grenade;
	self.loadout.tomahawk = self.loadout.tactical_grenade;

	self.tom_override = 1;
}

function save_grenades()
{
	lethal_grenade = self zm_utility::get_player_lethal_grenade();
	if ( self HasWeapon( lethal_grenade ) )
	{
		self.loadout.lethal_grenade = lethal_grenade;
		self.loadout.lethal_grenade_count = self getweaponammoclip( lethal_grenade );
	}
	else
	{
		self.loadout.lethal_grenade = undefined;
	}
	tactical_grenade = self zm_utility::get_player_tactical_grenade();
	if ( self HasWeapon( tactical_grenade ) )
	{
		self.loadout.tactical_grenade = tactical_grenade;
		self.loadout.tactical_grenade_count = self GetWeaponAmmoClip( tactical_grenade );
	}
	else
	{
		self.loadout.tactical_grenade = undefined;
	}
	tomahawk = self.current_tomahawk_weapon;
	if ( isDefined( tomahawk ) )
		self.loadout.tomahawk = tomahawk;
}

function AfterlifeGiveWeapons(is_death)
{
	self TakeAllWeapons();
	loadout = self.loadout;
	primaries = self getweaponslistprimaries();
	if ( loadout.weapons.size > 1 || primaries.size > 1 )
	{
		_a449 = primaries;
		_k449 = getFirstArrayKey( _a449 );
		while ( isDefined( _k449 ) )
		{
			weapon = _a449[ _k449 ];
			self takeweapon( weapon );
			_k449 = getNextArrayKey( _a449, _k449 );
		}
	}
	
	perk_array = zm_perks::get_perk_array();
	
	i = 0;
	while ( i < perk_array.size )
	{
		self notify( perk_array[ i ] + "_stop" );
		i++;
	}
	WAIT_SERVER_FRAME;
	
	i = 0;
	current_weapon = undefined;
	while ( i < loadout.weapons.size )
	{
		if ( !isDefined( loadout.weapons[ i ] ) )
		{
			i++;
			continue;
		}
		else
		{
			weapon = loadout.weapons[ i ];
			if ( zm_utility::is_hero_weapon(weapon) )
			{
				i++;
				continue;
			}

			self zm_weapons::weapondata_give( loadout.weapons[ i ] );
			if ( i == loadout.current_weapon )
			{
				current_weapon = weapon;
				self SwitchToWeapon( weapon );
			}
		}

		i++;
	}
	self zm_equipment::give( self.loadout.equipment );
	loadout restore_melee_weapon( self );
	self.score = loadout.score;
	self.pers[ "score" ] = loadout.score;
	
	if ( isdefined( loadout.perks ) && loadout.perks.size > 0 && !IS_TRUE(is_death) )
	{
		i = 0;
		while ( i < loadout.perks.size )
		{
			if ( self HasPerk( loadout.perks[ i ] ) )
			{
				i++;
				continue;
			}

			if ( loadout.perks[i] == "specialty_quickrevive" && GetPlayers().size <= 1)	// && level flag::exists( "solo_game" ) && level flag::exists( "solo_revive" ) && level flag::get( "solo_game" ) && level flag::get( "solo_revive" )
			{
				level.solo_game_free_player_quickrevive = 1;
			}

			if ( loadout.perks[ i ] == "specialty_whoswho" )
			{
				i++;
				continue;
			}
			else
				zm_perks::give_perk( loadout.perks[i] );
			
			i++;
		}
	}

	self restore_grenades();

	// V2 added hero weapon functionality
	if(isdefined(self.loadout.heroweapon) && self.loadout.heroweapon != level.weaponNone)
	{
		self zm_weap_gravityspikes::update_gravityspikes_state( 0 );

		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;

		w_gravityspike = self.loadout.heroweapon;
		util::wait_network_frame(); // wait for connect function to wait.
		
		self zm_weapons::weapon_give( w_gravityspike, false, true, true );

		// IPrintLnBold("Hero Power: " +self.loadout.heropower);
		// IPrintLnBold("Hero Clip: " +self.loadout.heroGravitySpikesClip );

		if(isdefined(self.loadout.heropower) && self.loadout.heropower < 100)
		{
			self.hero_power = self.loadout.heropower;
			self GadgetPowerSet( self GadgetGetSlot(w_gravityspike), 0 );
        	wait(.05);
        	self GadgetPowerSet( self GadgetGetSlot(w_gravityspike), self.loadout.heropower );
			self GiveMaxAmmo( w_gravityspike );
			self SetWeaponAmmoClip( w_gravityspike, self.loadout.heroGravitySpikesClip );
			self.loadout.heropower = undefined;
			self.loadout.heroGravitySpikesClip = undefined;
		}

		else 	// Set max ammo for gravity spikes
		{
			self.hero_power = 100;
			self GadgetPowerSet( self GadgetGetSlot(w_gravityspike), 0 );
        	wait(.05);
        	self GadgetPowerSet( self GadgetGetSlot(w_gravityspike), 100 );
			self GiveMaxAmmo( w_gravityspike );
			self SetWeaponAmmoClip( w_gravityspike, self GetWeaponAmmoClip(w_gravityspike) );
			self.loadout.heropower = undefined;
			self.loadout.heroGravitySpikesClip = undefined;
		}

		self zm_hero_weapon::default_give( w_gravityspike );
		self thread zm_hero_weapon::watch_hero_power( w_gravityspike );
	}
	
}

function restore_grenades()
{
	if ( isDefined( self.loadout.lethal_grenade ) )
	{
		self zm_utility::set_player_lethal_grenade( self.loadout.lethal_grenade );
		self giveweapon( self.loadout.lethal_grenade );
		self setweaponammoclip( self.loadout.lethal_grenade, self.loadout.lethal_grenade_count );
	}
	if ( isDefined( self.loadout.tactical_grenade ) && self.loadout.tactical_grenade )
	{
		self zm_utility::set_player_tactical_grenade( self.loadout.tactical_grenade );
		self GiveWeapon( self.loadout.tactical_grenade );
		self SetWeaponAmmoClip( self.loadout.tactical_grenade, self.loadout.tactical_grenade_count );
	}
	if ( isDefined( self.loadout.tomahawk ) )
	{
		self.current_tomahawk_weapon = self.loadout.tomahawk;
		self SetWeaponAmmoClip(self.current_tomahawk_weapon, 1);
	}
		
	if(IS_TRUE(self.loadout.hasclaymore))
	{
		self GiveWeapon(GetWeapon("iw6_ims_equipment"));
	}

	if(IS_TRUE(self.tom_override))
	{
		weapon = level.tomahawk_weapon_upgraded;
		self GiveWeapon( weapon );
		self zm_utility::set_player_tactical_grenade( weapon );
		self.current_tomahawk_weapon = weapon;
		self.current_tactical_grenade = weapon;
		self.has_tomahawk = 2;
		self.tom_override = 0;
	}
}


function AfterlifeWatchDeath()
{
	self waittill("afterlife_timeout");
	AfterlifePrint( "player not revived on time" );
	self waittill("ready_for_downing");
	WAIT_SERVER_FRAME;
	self DoDamage(self.health + 666, self.origin);
	AfterlifePrint("Downed player");
}

function WatchForFakeRevive(clone)
{
	self endon("disconnect");
	self endon("death");
	self endon("afterlife_done");
	self endon("afterlife_timeout");

	radius = GetDvarInt( "revive_trigger_radius" );
	self.afrevivetrigger = Spawn("trigger_radius", clone.origin, 0, radius, radius );
	self.afrevivetrigger SetCursorHint( "HINT_NOICON" );
	self.afrevivetrigger SetHintString( "" );
	self.afrevivetrigger SetMovingPlatformEnabled( true );
	self thread WatchAfterlifeRevive(clone);
	self thread LastStandCleanup();
	AfterlifePrint( "Created Revive Trigger" );
}

function LastStandCleanup()
{
	self util::waittill_any("afterlife_done", "afterlife_timeout", "disconnect", "death", "alrevive_success");
	if(isdefined(self.afrevivetrigger))
	{
		self.afrevivetrigger Delete();
		self.afrevivetrigger = undefined;
	}
}


function WatchAfterlifeRevive( clone ) 
{
	self endon("disconnect");
	self endon("death");
	//self endon("afterlife_done");
	self endon("afterlife_timeout");
	self endon("alrevive_success");
	level endon("end_game");

	self.beenrevived = 0;

	while( true )
	{
		WAIT_SERVER_FRAME;
		self.afrevivetrigger SetHintString( "" );
		for(i = 0; i < level.players.size; i++)
		{
			if(level.players[i] CanRevive(self, clone) && level.players[i] IsTouching(self.afrevivetrigger))	//if(level.players[i] IsTouching(self.afrevivetrigger))			
			{
				AfterlifePrint("Reviver in area");
				self.afrevivetrigger SetHintString( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
				break;
			}
		}

		for(i = 0; i < level.players.size; i++)
		{
			reviver = level.players[i];
			if(!reviver is_reviving(self, self.afrevivetrigger, clone))
			{
				continue;
			}
				
			w_revive_tool = level.weaponReviveTool;
			if(isdefined(reviver.weaponReviveTool))
			{
				w_revive_tool = reviver.weaponReviveTool;
			}

			w_reviver = reviver GetCurrentWeapon();
			if(w_reviver == reviver.weaponReviveTool)
			{
				//Already reviving someone
				continue;
			}

			reviver GiveWeapon(w_revive_tool);
			reviver SwitchToWeapon(w_revive_tool);
			reviver SetWeaponAmmoStock( w_revive_tool, 1 );
			reviver thread GiveBackWeaponsWhenDone(w_reviver, w_revive_tool, self);

			b_revive_successful = reviver AfterlifeDoRevive(self, w_reviver, w_revive_tool, clone);
			reviver thread AfterlifeReviveCleanUp();
			reviver notify("revivedone");
				
			if(b_revive_successful)
			{
				self notify("alrevive_success");
				return;
			}			
		}
	}
}

function is_reviving(revivee, t_revive, clone)
{
	return ( self UseButtonPressed() && CanRevive( revivee, clone ) );
}

function GiveBackWeaponsWhenDone(w_reviver, w_revive_tool, revivee)
{
	GiveBackWeaponWait(self, revivee);

	self zm_laststand::revive_give_back_weapons(w_reviver, w_revive_tool);
}

function GiveBackWeaponWait(reviver, revivee)
{
	revivee endon ( "disconnect" );
	revivee endon ( "zombified" );
	revivee endon ( "alrevive_success" );
	revivee endon ( "afterlife_done" );
	revivee endon ( "afterlife_timeout" );
	level endon("end_game");
	revivee endon( "death" );
	
	reviver waittill("revivedone");
}


function AfterlifeDoRevive(revivee, w_reviver, w_revive_tool, clone)
{
	revive_time = 3;
	if(self HasPerk( PERK_QUICK_REVIVE ) || self == revivee )
	{
		revive_time = revive_time / 2;
	}
	timer = 0;
	revivee.beenrevived = 0;

	revivee.beingRevived = 1;
	revivee.afrevivetrigger SetHintString( "" );

	if(!isdefined(self.revivehud))
	{
		self.revivehud = hud::createPrimaryProgressBar();
	}

	if(!isdefined(self.revivehudtext))
	{
		self.revivehudtext = NewClientHudElem( self );
	}

	if(isdefined(self.revivehud))
	{
		self.revivehud hud::updateBar( 0.01, 1 / revive_time );
	}

	self.revivehudtext.alignX = "center";
	self.revivehudtext.alignY = "middle";
	self.revivehudtext.horzAlign = "center";
	self.revivehudtext.vertAlign = "bottom";
	self.revivehudtext.y = -113;
	if ( self IsSplitScreen() )
	{
		self.revivehudtext.y = -347;
	}
	self.revivehudtext.foreground = true;
	self.revivehudtext.font = "default";
	self.revivehudtext.fontScale = 1.8;
	self.revivehudtext.alpha = 1;
	self.revivehudtext.color = ( 1.0, 1.0, 1.0 );
	self.revivehudtext.hidewheninmenu = true;
	self.revivehudtext SetText( &"ZOMBIE_REVIVING" );

	while(self CanRevive(revivee, clone) && self UseButtonPressed() && self IsTouching(revivee.afrevivetrigger))
	{
		WAIT_SERVER_FRAME;
		timer += 0.05;

		if ( self laststand::player_is_in_laststand() && !IS_TRUE(self.in_afterlife))
		{
			break;
		}

		if( timer >= revive_time)
		{
			//IPrintLnBold("^1 Player Revived!");
			revivee.beenrevived = 1;
			//revivee notify("afterlife_done");
			break;
		}
	}

	if( isdefined( self.revivehud ) )
	{
		//IPrintLnBold("Hud Defined");
		self.revivehud hud::destroyElem();
	}
	
	if( isdefined( self.revivehudtext ) )
	{
		self.revivehudtext Destroy();
	}
	revivee.afrevivetrigger SetHintString( &"ZOMBIE_BUTTON_TO_REVIVE_PLAYER" );
	revivee.beingrevived = 0;

	return revivee.beenrevived;

}

function AfterlifeReviveCleanUp()
{
	//IPrintLnBold("Destroying Revive Hud");
	self util::waittill_any("revivedone", "death", "disconnect", "afterlife_done");
	if(isdefined(self.revivehud))
	{
		self.revivehud hud::destroyElem();	//Destroy();
	}

	if(isdefined(self.revivehudtext))
		self.revivehudtext Destroy();
}


function CreateFadeToWhite()
{
	self endon("disconnect");
	time = 2;
	fadeToWhite = NewClientHudElem(self);
	fadeToWhite.x = 0;
	fadeToWhite.y = 0;
	fadeToWhite.alpha = 0;

	fadeToWhite.horzAlign = "fullscreen";
	fadeToWhite.vertAlign = "fullscreen";
	fadeToWhite.foreground = false;
	fadeToWhite.sort = 50;
	fadeToWhite SetShader( "white", 640, 480 );
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 1;
	wait(time);
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 0;
	wait(1);
	fadeToWhite Destroy();
}

function EnterAfterlife( savelocation, infinite_afterlife )
{
	//Give Weapon
	//level notify( "fake_revive" );
	//self notify( "fake_revive" );

	self notify("stop_player_out_of_playable_area_monitor");	// Person in afterlife can access all areas freely
	self notify( "stop_player_too_many_weapons_monitor" );		// A fucking terrible fix, but don't care

	//Test for HUD
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 0 );

	if(isdefined(self.shovelHud))
	{
		self.shovelHud.alpha = 0;
	}

	weapon = GetWeapon("wpn_afterlife");
	self zm_weapons::weapon_give( weapon, 0, 0, 1, 1 );
	WAIT_SERVER_FRAME;

	self.in_afterlife = true;
	self.isSpeaking = true;		//For player quotes
	self.weaponReviveTool = GetWeapon( "wpn_afterlife_revive" );	//reviver.revivetool
	self clientfield::set_to_player( "isspeaking",1 );
	self AllowStand( 1 );
	self AllowProne( 0 );

	origin = self.origin;
	original_angles = self.angles;
	self thread AfterlifeTimeWatcher( infinite_afterlife );
	self thread AfterLifeJump();
	self thread ShowShockBoxHint();
	self thread zm_project_e_ee::UpdateAfterlifeCollectables();

	if(!savelocation)
	{
		spawn = CheckClosestValidSpawn( self.origin );
	}

	else
	{
		spawn = self.origin;
	}
	
	/*a_spawn = struct::get_array( "afterlife_spawn", "targetname" );
	if(!isdefined(a_spawn))	
	{
		AfterlifePrint("Warning: No afterlife structs found!");
		return;
	}
	closest = ArrayGetClosest(self.origin, a_spawn);		//array::get_closest( self.origin, a_spawn, undefined );*/
	if(!isdefined(spawn))
	{	
		AfterlifePrint("Can't Set Player Origin. Setting origin to player.origin");
		spawn = self.origin;
	}

	angles = spawn.angles;
	if(!isdefined(angles))
		angles = (0,0,0);

	self SetStance("stand");
	self SetOrigin(spawn.origin);
	self SetPlayerAngles(angles);
	util::wait_network_frame();
	self FreezeControls(false);
	self PlaySoundToPlayer( "afterlife_spawn", self );

	self clientfield::set_to_player("afterlife_torso_fx", 1);
	self clientfield::set("afterlife_world_fx", 1);

	self waittill("afterlife_done");

	//self StopLoopSound(1);
	//Test for HUD
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 1 );

	self clientfield::set_to_player("afterlife_torso_fx", 0);
	// self clientfield::set_to_player("afterlife_shockhints", 0);
	self clientfield::set("afterlife_world_fx", 0);

	if(!savelocation)
	{
		self SetOrigin(origin);
		self SetPlayerAngles(original_angles);
	}

	else
	{
		self SetOrigin(self.origin);
	}

	self.in_afterlife = false;
	self.isSpeaking = false;		//For player quotes
	self clientfield::set_to_player( "isspeaking",0 );
	self.afterlifes = self.afterlifes - 1;
	self.weaponReviveTool = undefined;

	if(isdefined(self.fxmodel))
	{
		AfterlifePrint("Deleting Fx model");
		self.fxmodel Delete();
	}

	if(isdefined(self.revivehud))
	{
		self.revivehud hud::destroyElem();
	}

	if(isdefined(self.revivehudtext))
	{
		self.revivehudtext Destroy();
	}

	if(isdefined(self.shovelHud))
	{
		self.shovelHud.alpha = 1;
	}

	self thread zm::player_out_of_playable_area_monitor();
	self util::delay(2, undefined, &zm::player_too_many_weapons_monitor);	// Re-enable weapon monitoring
}

function ShowShockBoxHint()
{
	models = GetEntArray("afterlife_shockbox", "targetname");
	if(!isdefined(models))
	{
		return;
	}

	//self thread SetClosestHint( models );	//4.1 Added new logic here to prevent issues in coop

	foreach(model in models)
	{
		if(!IS_TRUE(model.activated))
		{
			model thread CreateWayPoint( self );
		}
	}
}

function CreateWayPoint( player )
{
	if(isdefined(self.waypoint))
	{
		return;
	}

	self.waypoint = NewClientHudElem( player );
	self.waypoint SetShader("afterlife_shockbox_hint", 64, 64);
	self.waypoint SetWayPoint(true, "afterlife_shockbox_hint");
	self.waypoint.alpha = 0.8;
	self.waypoint SetTargetEnt(self);

	self thread CheckDistance( player );

	player util::waittill_any("afterlife_done", "afterlife_timeout", "death", "disconnect");
	if(isdefined(self.waypoint))
	{
		self.waypoint hud::destroyElem();
	}

}

function SetClosestHint( models )
{
	self.shockwaypoint = [];

	self thread ClearShockWaypoints();

	for(i = 0; i < models.size; i++)
	{
		if(IS_TRUE(models[i].activated))
			continue;

		self.shockwaypoint[i] = NewClientHudElem( self );
		self.shockwaypoint[i] SetShader( "afterlife_shockbox_hint", 64, 64 );
		self.shockwaypoint[i] SetWayPoint(true, "afterlife_shockbox_hint");
		self.shockwaypoint[i].alpha = 0.8;
		self.shockwaypoint[i] SetTargetEnt( models[i] );

		self thread CheckWaypointDistance( models[i], i );

	}
		
}

function ClearShockWaypoints()
{
	self util::waittill_any("afterlife_done", "afterlife_timeout", "death", "disconnect");
	if(isdefined(self.shockwaypoint))
	{
		foreach(waypoint in self.shockwaypoint)
		{
			ArrayRemoveValue(self.shockwaypoint, waypoint);
			waypoint hud::destroyElem();
		}
	}
}

function CheckWaypointDistance( model, i )
{
	self endon("afterlife_done");
	self endon("afterlife_timeout");
	self endon("death");
	self endon("disconnect");

	model endon("shockbox_triggered");

	model thread waitForShock( self, i );

	while(1)
	{
		wait(.1);
		if(isdefined(self.shockwaypoint[i]))
		{
			if(Distance(self.origin, model.origin) < 600)
			{
				self.shockwaypoint[i].alpha = 0.8;
			}

			else
			{
				self.shockwaypoint[i].alpha = 0;
			}
		}
	}
}

function WaitForShock( player, i )
{
	player endon("afterlife_done");
	player endon("afterlife_timeout");
	player endon("death");
	player endon("disconnect");

	self waittill("shockbox_triggered");
	if(isdefined(player.shockwaypoint[i]))
	{
		player.shockwaypoint[i] hud::destroyElem();
		ArrayRemoveValue(player.shockwaypoint, self);
	}
}

function CheckDistance( player )
{
	player endon("afterlife_done");
	player endon("afterlife_timeout");
	player endon("death");
	player endon("disconnect");
	self endon("shockbox_triggered");

	if(!isdefined(self.waypoint))
	{
		return;
	}

	if(IS_TRUE(self.activated))
	{
		self.waypoint hud::destroyElem();
	}

	if(!isdefined(self.waypoint.alpha))
	{
		self.waypoint.alpha = 0;
	}

	while( true )
	{
		wait(.1);
		if(!isdefined(self.waypoint))
			return;

		if(Distance(self.origin, player.origin) < 600)
		{
			self.waypoint.alpha = 0.8;
		}

		else
		{
			self.waypoint.alpha = 0;
		}
	}
}
	
function AfterLifeJump()
{
	//self endon("afterlife_done");
	self endon("disconnect");
	self endon("death");
	old_gravity = self GetPlayerGravity();
	new_gravity = 150;
	//self SetPlayerGravity(new_gravity);
	//self SetPerk("specialty_lowgravity");
	self.isinjump = undefined;
	//self SetPlayerGravity(new_gravity);
	self SetPlayerGravity(new_gravity);
	while(self.in_afterlife)
	{
		WAIT_SERVER_FRAME;
		if(self JumpButtonPressed() && !self IsOnGround() && !isdefined(self.isinjump))
		{
			AfterlifePrint("Jumping");
			self.isinjump = true;
			self SetVelocity(self GetVelocity() + ( 0, 0, 150 ));
			while(!IS_TRUE(self IsOnGround()))
			{
				WAIT_SERVER_FRAME;
			}
			self.isinjump = undefined;
		}
	}

}


function AfterlifeTimeWatcher( infinite_afterlife )
{
	self endon("afterlife_done");
	self endon("disconnect");
	self endon("death");

	self.beingRevived = false;

	if(!isdefined(level.afterlife_time))
		level.afterlife_time = 30;

	self.aftime = level.afterlife_time / level.afterlife_time;
	interval = 0.1;
	AfterlifePrint("time:" +self.aftime);
	self.bar = self hud::createBar((0,60,1), level.primaryProgressBarWidth, level.primaryProgressBarHeight);	//		// self hud::createPrimaryProgressBar();

	if ( level.splitScreen )
		self.bar hud::setPoint("TOP", undefined, level.primaryProgressBarX, level.primaryProgressBarY);
	else
		self.bar hud::setPoint("BOTTOM", undefined, level.primaryProgressBarX, level.primaryProgressBarY);

	self.bar hud::updateBar(self.aftime, 0.0);			//function updateBar( barFrac, rateOfChange )
	self.bar hud::showElem();
	self thread ClearProgressBar();
	while(self.aftime >= 0)
	{
		if( infinite_afterlife )
		{
			while( infinite_afterlife )
			{
				WAIT_SERVER_FRAME;
			}
		}

		if(IS_TRUE(self.beingRevived))
		{
			while(self.beingRevived)
			{
				//AfterlifePrint("Being Revived");
				WAIT_SERVER_FRAME;
			}
		}

		//person in afterlife has been revived
		if( self.beenrevived )
		{
			self notify("afterlife_done");
			AfterlifePrint("Player Has Been Revived Succesfully");
			self.bar hud::destroyElem();
			return 1;
		}

		wait(interval);
		if(!self IsOnGround())
		{
			self.aftime-= Float( ( 2 * interval ) / level.afterlife_time );
		}
		else
		{
			self.aftime-= Float(interval/level.afterlife_time);
		}
		
		self.bar hud::updateBar(self.aftime, 0.0);


	}
	AfterlifePrint("time over");
	self.bar hud::destroyElem();
	self notify("afterlife_timeout");
	self notify("afterlife_done");
	
}

function ClearProgressBar()
{
	self util::waittill_any("afterlife_done", "afterlife_timeout", "death", "disconnect");
	if(isdefined(self.bar))
		self.bar hud::destroyElem();
}

function DeleteCorpse(corpse)
{
	self util::waittill_any("afterlife_done", "afterlife_timeout" ,"disconnect", "death");
	if(isdefined(corpse.waypoint))
	{
		corpse.waypoint Destroy();
	}

	if(isdefined(corpse))
	{
		corpse Delete();
		AfterlifePrint("Deleted corpse");
	}
		
}

function CreatePlayerClone( infinite_afterlife )
{
	//CREDIT TO HARRY (WHOS WHO)
	if(infinite_afterlife)
	{
		struct = struct::get_array("boss_fight_spawn","targetname");	//target = struct::get("boss_fight_spawn", "targetname");
		if(isdefined(struct))
		{
			spawn = struct[0];
			corpse = zm_clone::spawn_player_clone( self, spawn.origin, GetWeapon("s2_m1911"), self GetCharacterBodyModel() );
			corpse SetInvisibleToAll();
		}
	}

	else
	{
		corpse = zm_clone::spawn_player_clone( self, self.origin, GetWeapon("s2_m1911"), self GetCharacterBodyModel() );

		//corpse = zm_clone::spawn_player_clone( self, self.origin, getWeapon( "pistol_standard" ), self GetCharacterBodyModel() );
		corpse.angles = self.angles -(0, 180, 0);
		corpse UseAnimTree( #animtree );
		corpse AnimScripted( "pb_laststand_idle", self.origin , self.angles, %pb_laststand_idle );

		corpse.waypoint = NewHudElem();
		corpse.waypoint SetShader("afterlife_on", 64, 16);
		corpse.waypoint SetWayPoint(true, "afterlife_on");
		corpse.waypoint.alpha = 0.8;
		corpse.waypoint SetTargetEnt(corpse);
	}

	return corpse;
}

function AfterLifeStunZombies( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	self endon("delete");
	self endon("death");
	//IPrintLnBold("Damage");

	if( IsPlayer(e_player) && w_weapon == GetWeapon("wpn_afterlife") && IS_TRUE(e_player.in_afterlife))
	{
		if( IsAlive(self) && !IS_TRUE(self.in_the_ground) )
		{
			self.shocked = true;
			self thread DoAfterlifeTeleport( self.origin );
			return true;
		}
	}
	else
	{
		return false;
	}
}

function DoAfterlifeTeleport(point)
{
	self endon("death");

	self notify( "stun_zombie" );
	self endon( "stun_zombie" );

	if ( self.health <= 0 )
		return;
	
	if ( self.ai_state !== "zombie_think" )
		return;	

	zombie_spawn = CheckClosestZombieSpawn( point );
	if(!isdefined(zombie_spawn))
		return;

	angles = zombie_spawn.angles;
	if(!IsVehicle(self))
	{	
		self clientfield::set( "tesla_shock_eyes_fx", 1 );
		//self AnimScripted("note_notify", self.origin, self.angles, %ai_zm_dlc5_zombie_afterlife_stun_b);
	}
	else
	{
		self clientfield::set( "tesla_shock_eyes_fx_veh", 1 );
	}

	self PlaySound( "zmb_elec_jib_zombie" );
	self.zombie_tesla_hit = 1;		
	self.ignoreall = 1;

	wait 2;

	if ( isDefined( self ) )
	{	
		self.zombie_tesla_hit = 0;		
		self.ignoreall = 0;
		self notify( "stun_fx_end" );	
	}

	//wait(GetAnimLength(%ai_zm_dlc5_zombie_afterlife_stun_b));
	if(IsAlive(self))
	{
		if(!IsVehicle(self))
		{
			self clientfield::set( "tesla_shock_eyes_fx", 0 );
		}
		
		else
		{
			self clientfield::set( "tesla_shock_eyes_fx_veh", 0 );
		}
				
		self ForceTeleport(zombie_spawn.origin, angles);
		self.ignoreall = 0;
		util::wait_network_frame();
		AfterlifePrint("Shot Zombies");
		self.shocked = undefined;
	}
}

function setAfterlife()
{
	//ADD: Gamemodes
	self.afterlifes = 1;
	self.in_afterlife = false;
	self.tom_override = 0;

	self thread AfterLifeHud();
	self thread giveAfterlife();
	self thread AfterlifeShockRevive();
}

function giveAfterlife()
{
	self endon("disconnect");

	level waittill("start_of_round");	// This has the issue of showing 1 afterlife in solo for first round, should find a notify that runs when round 1 starts

	if( GetPlayers().size <= 1 )
	{
		self.afterlifes = 3;
	}

	while(1)
	{
		level waittill( "between_round_over" );
		AfterlifePrint("Giving Afterlife");
		if(GetPlayers().size <= 1)
		{
			if(self.afterlifes < 3)
			{
				self.afterlifes = self.afterlifes + 1;
			}

			else
			{
				self.afterlifes = 3;
			}

		}

		else
		{
			if(self.afterlifes <= 0 && !IS_TRUE(self.in_afterlife))
			{
				self.afterlifes = 1;
			}
		}
		
		AfterlifePrint( "Number of afterlifes:" + self.afterlifes );
		self UpdateAfterlifeHud();
	}
}

function AfterlifeHud( image = "afterlife_on", align_x = 50, align_y = 120, height = 18, width = 36, fade_time = .5 )
{
	self.afterhud = NewClientHudElem( self );
	self.afterhud.foreground = true;
	self.afterhud.sort = 1;
	self.afterhud.hidewheninmenu = true;
	self.afterhud.alignX = "right";
	self.afterhud.alignY = "bottom";
	self.afterhud.horzAlign = "right";
	self.afterhud.vertAlign = "bottom";
	self.afterhud.x = -50;
	self.afterhud.y = self.afterhud.y - 150;
	self.afterhud SetShader( image, width, height );
	self.afterhud FadeOverTime( .5 );

	self.afterhudText = NewClientHudElem( self );
	self.afterhudText.foreground = true;
	self.afterhudText.sort = 1;
	self.afterhudText.hidewheninmenu = true;
	self.afterhudText.alignX = "right";
	self.afterhudText.alignY = "bottom";
	self.afterhudText.horzAlign = "right";
	self.afterhudText.vertAlign = "bottom";
	self.afterhudText.x = -45;
	self.afterhudText.y = self.afterhudText.y - 150;
	self.afterhudText SetText( self.afterlifes );
}

function UpdateAfterlifeHud()
{
	if( !isdefined(self.afterhud) )
		return;

	if( !isdefined(self.afterhudText) )
		return;

	if( isdefined(self.afterlifes) && self.afterlifes >= 1 )
	{
		self.afterhud SetShader("afterlife_on", 36, 18);
		self.afterhudText SetText( self.afterlifes );
	}

	else
	{
		self.afterhud SetShader("afterlife_off", 36, 18);
		self.afterhudText SetText( 0 );
	}
}

function CanRevive(e_revivee, body)
{
	//self = reviver
	//Reference: zm_laststand.gsc, function can_revive( e_revivee, ignore_sight_checks = false, ignore_touch_checks = false )
	if ( !isdefined( e_revivee.afrevivetrigger ) )
	{
		return false;
	}

	if ( !IsAlive( self ) )
	{
		return false;
	}

	if ( self laststand::player_is_in_laststand() )
	{
		if(!IS_TRUE(self.in_afterlife))
		{
			return false;
		}
	}

	if( self.team != e_revivee.team ) 
	{
		return false;
	}

	if ( IS_TRUE( self.is_zombie ) )
	{
		return false;
	}

	if ( self zm_utility::has_powerup_weapon() )
	{
		return false;
	}

	if ( self zm_utility::has_hero_weapon() )
	{
		return false;
	}

	if ( !self IsTouching( e_revivee.afrevivetrigger ) )
	{
		return false;
	}
	

	if ( !self laststand::is_facing( body ) )
	{
		return false;
	}

	if ( !SightTracePassed( self.origin + ( 0, 0, 50 ), body.origin + ( 0, 0, 30 ), false, undefined ) )				
	{
		return false;
	}

	if ( !BulletTracePassed( self.origin + (0, 0, 50), body.origin + (0, 0, 30), false, undefined ) )
	{
		return false;
	}	

	return true;
}

function WatchForShock()	// self = model
{
	self SetCanDamage( true );
	self.activated = false;
	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		if(IS_TRUE(e_attacker.in_afterlife) && IsPlayer(e_attacker))			// Change afterlife weapon to a public variable
		{
			if(isdefined(self.waypoint))
			{
				self.waypoint hud::destroyElem();
			}

			self notify("shockbox_triggered");
			
			self.activated = true;
			self PlaySound("afterlife_powered");
			self SetModel("p7_zm_zod_power_box_yellow_emissive");
			self UseAnimTree("shockbox");
			self AnimScripted("zod_powerbox_loop", self.origin, self.angles, "zod_powerbox_loop");

			power_zone = undefined;
			if(isdefined(self.script_int))
			{
				power_zone = self.script_int;
				level thread zm_perks::perk_unpause_all_perks( power_zone );
				level zm_power::turn_power_on_and_open_doors( power_zone );
				vending_triggers = GetEntArray("zombie_vending", "targetname");
				foreach(trigger in vending_triggers)
				{
					powered_on = zm_perks::get_perk_machine_start_state(trigger.script_noteworthy);
					powered_perk = zm_power::add_powered_item( &zm_power::perk_power_on, &zm_power::perk_power_off, &zm_power::perk_range, &zm_power::cost_low_if_local, ANY_POWER, powered_on, trigger );
					if(isdefined(trigger.script_int))
					{
						powered_perk thread zm_power::zone_controlled_perk(trigger.script_int);
					}
					if(isdefined(trigger.script_noteworthy))
					{
						level notify(trigger.script_noteworthy +"_on");
					}
				}

			}

			break;
		}
	}
}

function CreateAfterlifeBody()
{
	old_body = self GetCharacterBodyType();

	// Replace with afterlife ghost here
	self SetCharacterBodyType( 4 ); 
	self.afterlife_vision = true;
	visionset_mgr::activate( "visionset", level.afterlife_vision, self, 1, 90000, 1 );
	self util::waittill_any("afterlife_done", "death", "afterlife_timeout");
	self.afterlife_vision = false;
	self SetCharacterBodyType(old_body);
	visionset_mgr::deactivate( "visionset", level.afterlife_vision, self );
}

function AfterlifeLoopVision()
{
	self endon("afterlife_done");
	self endon("death");
	self endon("afterlife_timeout");
	self endon("disconnect");
	level endon("end_game");

	while(IS_TRUE(self.afterlife_vision))
	{
		// IPrintLnBold("Afterlife Vision");
		WAIT_SERVER_FRAME;
	}
}

function AfterlifeShockRevive()
{
	self endon("death");
	level endon("end_game");
	
	while(1)
	{
		self waittill("projectile_impact", weapon, point, radius);
		if(!IS_TRUE(self.in_afterlife))
			continue;

		players = GetPlayers();
		closest = ArrayGetClosest(point, players);
		if(!isdefined(closest))
			return;

		if(Distance(closest.origin, point) <= 50)
		{
			if(closest laststand::player_is_in_laststand())
			{
				closest thread zm_laststand::remote_revive( self );
			}
		}
	}
}

function CheckClosestValidSpawn( origin )
{
	if(!isdefined(origin))
	{
		return;
	}

	valid_spawns = [];
	structs = struct::get_array( "afterlife_spawn", "targetname" );
	for(i = 0; i < structs.size; i++)
	{
		isvalid = zm_utility::check_point_in_enabled_zone( structs[i].origin );
		if(IS_TRUE(isvalid))
		{
			valid_spawns[valid_spawns.size] = structs[i];
		}
	}

	closest = ArrayGetClosest( origin, valid_spawns);
	if(isdefined(closest))
	{
		return closest;
	}
	
	else
	{
		return undefined;
	}
}

function CheckClosestZombieSpawn( origin )
{
	if(!isdefined(origin))
	{
		return;
	}

	valid_spawns = [];
	zombie_spawn = struct::get_array("afterlife_zomspawn","targetname");
	for(i = 0; i < zombie_spawn.size; i++)
	{
		isvalid = zm_utility::check_point_in_enabled_zone( zombie_spawn[i].origin );
		if(IS_TRUE(isvalid))
		{
			valid_spawns[valid_spawns.size] = zombie_spawn[i];
		}
	}

	closest = ArrayGetClosest( origin, valid_spawns);
	if(isdefined(closest))
		return closest;
	
	return undefined;
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

