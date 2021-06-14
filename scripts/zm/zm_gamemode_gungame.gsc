/*==========================================
Gun Game script by ihmiskeho
V1.0
Credits:

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
#using scripts\zm\_zm_spawner;
#using scripts\shared\ai\zombie_utility;	
#using scripts\zm\_zm_audio;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_random;
#using scripts\zm\_zm_equipment;
#using scripts\ik\zm_pregame_room;
#using scripts\bosses\zm_ai_reverant;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#define N_BASE_SCORE	6	// Amount of kills required for the first weapon spin
#define N_SCORE_ADD		1	// Amount of kills that will be added
#define N_SCORE_CAP		25	// Cap the max kills

#namespace zm_gamemode_gungame;

REGISTER_SYSTEM_EX( "zm_gamemode_gungame", &init, &main, undefined )

function init()
{
	level.GunGameDebug = false;
	level.spawned_bosses = false;

	// Weapons list:
	level.GunGameWeapons = [];
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw8_1911");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("m9a1");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw6_mp443_rdw");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("44magnum");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("h1_mac10");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_ak74");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_msmc");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw8_fennec");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("k7");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("cbj_ms");	
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("vepr");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_sten");	
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw5_fmg9_rdw");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_mosin");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("l115");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_xpr50");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("vks");	
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_m14");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("ia2");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw8_ak47");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("msbs");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("maverick");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw8_asval");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw8_aug_ar");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_galil");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_m16");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("sc2010");	
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("remington_r5");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("ak12");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_an94");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("smg_honeybadger");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t7_olympia");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t6_spas12");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("uts");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("h1_kam12");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("t6_crossbow");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("h1_rpg7");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("iw6_mk32");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("ameli");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("lsat");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("h1_rpd");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("h1_pkm");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("ray_gun");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("bo3_mark2");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("spell_fire_ug");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("spell_wind_ug");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("spell_ice_ug");
	level.GunGameWeapons[level.GunGameWeapons.size] = GetWeapon("spell_lightning_ug");
	callback::on_connect( &OnConnect);
}

function main()
{
	level waittill("gamemode_chosen");
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
	{
		level thread GameModeDisableTriggers();
		zombie_utility::set_zombie_var( "zombie_spawn_delay", 				0.5,	true );		// Time to wait between spawning zombies. This is modified based on the round number.
		zombie_utility::set_zombie_var( "zombie_new_runner_interval", 		 8,	false );		// Interval between changing walkers who are too far away into runners 
		zombie_utility::set_zombie_var( "zombie_move_speed_multiplier", 	  8,	false );	// Multiply by the round number to give the base speed value. 0-40 = walk, 41-70 = run, 71+ = sprint
		zombie_utility::set_zombie_var( "zombie_move_speed_multiplier_easy",  6,	false );	// Multiply by the round number to give the base speed value. 0-40 = walk, 41-70 = run, 71+ = sprint
		zombie_utility::set_zombie_var( "zombie_between_round_time", 		7 );				// How long to pause after the round ends
		zombie_utility::set_zombie_var( "zombie_powerup_drop_increment",		1400 );			// 2000, lower this to make drop happen more often
		zombie_utility::set_zombie_var( "zombie_powerup_drop_max_per_round",	8 );			// 4, raise this to make drop happen more often
		zombie_utility::set_zombie_var( "zombie_health_increase", 80,	false );				// Decreasing zombie health in gungame since weapons are not upgradable
		zombie_utility::set_zombie_var( "zombie_health_increase_multiplier", 0.06, true );		// Decreasing zombie health in gungame since weapons are not upgradable (for high rounds)

		level.perk_purchase_limit = 10;															// No perk limit in gungame
		level._allow_melee_weapon_switching = false;											// No bowie knife allowed in gungame
		zm_powerups::powerup_remove_from_regular_drops( "minigun" );							// No minigun in zombies
		level thread GunGameMaxAmmo();
	}
}

function WatchLastStand()
{
	self endon("disconnect");
	level endon("intermission");

	while(1)
	{
		self waittill("player_downed");
		players = GetPlayers();
		if(players.size > 1)
		{
			WAIT_SERVER_FRAME;
			self thread zm_laststand::remote_revive( self );
			WAIT_SERVER_FRAME;

			// Shield needs special take functionality
			if(isdefined(self.weaponRiotshield))
			{
				self zm_equipment::take(self.weaponRiotshield);
				self.hasRiotShield = false;
				self.hasRiotShieldEquipped = false;
			}

			self TakeAllWeapons();
			self EnableInvulnerability();
			respawn = GetRespawnPoint();

			WAIT_SERVER_FRAME;
			WAIT_SERVER_FRAME;
			WAIT_SERVER_FRAME;

  			self SetNewWeapon( true );
  			
  			self.gungamekills = 0;
  			self UpdateScoreHud( self.score_required - self.gungamekills );
  			self UpdateGunHud( self.currentlevel );
  			
  			self CreateFadeToWhite();
  			self SetOrigin(respawn.origin);
			self.ignore_insta_kill = undefined;
			self DisableInvulnerability();
		}
	}
}

function GetRespawnPoint()
{
	valid_points = [];
	structs = struct::get_array("player_respawn_point", "targetname");
	foreach(struct in structs)
	{
		if(zm_utility::check_point_in_enabled_zone( struct.origin ))
		{
			if(isdefined(struct.script_noteworthy) && struct.script_noteworthy == "zone_boss")
				continue;

			valid_points[valid_points.size] = struct;
			continue;
		}
	}

	if(isdefined(valid_points))
	{
		point = array::random(valid_points);
		spawn = struct::get_array(point.target, "targetname");	// Respawn points have 4 targets
		return spawn[0];
	}
}

function gungame_laststand()
{
	self endon( "player_suicide" );
	self endon( "disconnect" );

	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
	{
		//IPrintLnBold("Laststand override ran");
		zm_laststand::increment_downed_stat();
		self.ignore_insta_kill = 1;
		self.health = 1; 

		level notify( "fake_death" );
		self notify( "fake_death" );
		self SetPenaltyWeapons();

		self.ignore_insta_kill = undefined;
		self zm_perks::perk_set_max_health_if_jugg( "health_reboot", 1, 0 );

		return true;
	}
		
	else
	{
		return false;
	}
}

function SetPenaltyWeapons()
{
	self AllowStand( 0 );
	self AllowCrouch( 0 );
	self AllowProne( 1 );
	self.ignoreme = 1;
	self EnableInvulnerability();
	wait .1;
	self FreezeControls( 1 );
	wait .9;
	if(!isdefined(self.currentlevel))
	{
		self.currentlevel = 1;
	}

	if(self.currentlevel >= 2)
	{
		self.currentlevel = self.currentlevel - 1;
	}

	else
	{
		self.currentlevel = 1;
	}

	WAIT_SERVER_FRAME;
	structs = struct::get_array("initial_spawn_points","targetname");
	structs = array::randomize(structs);
  	respawn = structs[0];

  	self.gungamekills = 0;
  	self UpdateScoreHud( self.score_required - self.gungamekills );
  	self UpdateGunHud( self.currentlevel );
  	self SetNewWeapon( true );

  	WAIT_SERVER_FRAME;

  	self SetOrigin(respawn.origin);
  	self thread zm_laststand::remote_revive( self );
  	self AllowStand( 1 );
	self AllowCrouch( 1 );
	self AllowProne( 1 );
	self DisableInvulnerability();
	self.ignoreme = 0;
	self FreezeControls( 0 );

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

function DebugPrint( string )
{
	if(!isdefined(level.GunGameDebug) || !level.GunGameDebug)
	{
		return;
	}

	IPrintLnBold("DEBUG: " +string);
}

function OnConnect()
{
	// self waittill("spawned_player");
	WAIT_SERVER_FRAME;

	self.refill_ammo_on_fire = false;

	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
	{
		self thread GunGameSetup();
		self thread WatchLastStand();
		self.check_override_wallbuy_purchase = &GunGameDisableWeapons;
	}

	else
	{
		level waittill("gamemode_chosen");
		DebugPrint("GG: Gamemode Chosen");

		if(!isdefined(level.CurrentGameMode))
		{
			DebugPrint("GG: No Gamemode Set");
		}

		if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
		{
			DebugPrint("Gun Game!");
			self thread GunGameSetup();
			self thread WatchLastStand();
			self.check_override_wallbuy_purchase = &GunGameDisableWeapons;
		}
	}
}

function GunGameDisableWeapons( weapon, trigger )
{
	trigger SetHintString("Wall Weapons are Disabled in this Gamemode");
	wait(1);
	return true;
}

function SetGameMode()
{
	level endon("gamemode_chosen");
	for(;;)
	{
		if(self MeleeButtonPressed())
		{
			level.gungame = 1;
			level thread GameModeDisableTriggers();
			level notify("host_gamemode_chosen");
		}

		WAIT_SERVER_FRAME;
	}
}

function GameModeDisableTriggers()
{
	wait(1);
	DisableTrigger("afterlife_trigger");
	DisableTrigger("digsite_trigger");
	DisableTrigger("shovel_trigger");
	DisableTrigger("weapon_upgrade");

	//Disable mystery box
	foreach( chest in level.chests )
	{
		chest.unitrigger_stub.prompt_and_visibility_func = &boxtrigger_update_prompt;
	}

	triggers = GetEntArray( "zombie_vending", "targetname" );		
	foreach ( trigger in triggers )
	{
		if ( !isDefined( trigger.script_noteworthy ) )
			continue;
			
		if ( trigger.script_noteworthy == "specialty_additionalprimaryweapon" || trigger.script_noteworthy == "specialty_quickrevive" || trigger.script_noteworthy == "specialty_widowswine" )
		{
			trigger TriggerEnable( 0 );
			zm_perk_random::remove_perk_from_random_rotation( trigger.script_noteworthy );	//Custom added function for zm_perk_random
		}
			
	}	

	/*DisabledPerks = [];
	DisabledPerks[DisabledPerks.size] = "specialty_additionalprimaryweapon";
	DisabledPerks[DisabledPerks.size] = "specialty_quickrevive";
	DisabledPerks[DisabledPerks.size] = "specialty_widowswine";

	for(i = 0; i < DisabledPerks.size; i++)
	{
		zm_perk_utility::global_pause_perk( DisabledPerks[i] );
		machine = (DisabledPerks[i], "script_noteworthy");
		if(isdefined(machine))
		{
			machine.bump triggerEnable( 0 );
			machine triggerEnable( 0 );
			machine.machine hide();
			machine zm_perks::perk_fx( undefined, 1 );
			PlayFX( level._effect[ "poltergeist" ], machine.origin );
			PlaySoundAtPosition( "zmb_box_poof", machine.origin );
		}
	}*/
}

function DisableTrigger( targetname )
{
	trigs = GetEntArray(targetname,"targetname");
	foreach( trigger in trigs )
	{
		trigger TriggerEnable( false );
	}
}

function boxtrigger_update_prompt( player )
{
	can_use = self zm_magicbox::boxstub_update_prompt( player ) && !(level.CurrentGameMode == "zm_gungame");
	if(isdefined(self.hint_string))
	{
		if (IsDefined(self.hint_parm1))
			self SetHintString( self.hint_string, self.hint_parm1 );
		else
			self SetHintString( self.hint_string );
	}
	if( !can_use && isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
		self SetHintString( "The Box is Disabled in This Gamemode" );
	return can_use;
}

function GunGameSetup()	//self = player
{
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
	{
		self.currentlevel = 1;
		self.gungamekills = 0;

		DebugPrint("Gamemode is Gungame");
		self CreateGunGameUI();
		self TakeAllWeapons();
		WAIT_SERVER_FRAME;
		self zm_weapons::weapon_give( level.GunGameWeapons[0], 0, 0, 1, 1 );	//self GiveWeapon(level.GunGameWeapons[0]);
		self AllowMelee( 0 );
		self thread WatchForKills();
		self thread GunGameAmmo();
		self thread GunGameGrenades();
	}
}

function GunGameGrenades()
{
	level endon("end_game");
	level endon("intermission");

	while(1)
	{
		level util::waittill_any("start_of_round", "zmb_max_ammo_level");
		lethal_grenade = self zm_utility::get_player_lethal_grenade();
		if ( self HasWeapon( lethal_grenade ) )
		{
			self TakeWeapon(lethal_grenade);
		}
	}
}

function CreateGunGameUI()
{
	self endon("disconnet");

	self.GunHudCurrent = NewClientHudElem(self);
	self.GunHudCurrent.alingX = "center";
	self.GunHudCurrent.alingY = "top";
	self.GunHudCurrent.horzAlign = "center";
	self.GunHudCurrent.vertAlign = "top";
	self.GunHudCurrent.hidewheninmenu = true;
	self.GunHudCurrent.font = "default";
	self.GunHudNext.x = -20;
	//self.GunHudCurrent.y = -20;
	self.GunHudCurrent SetText("Current Weapon: "+self.currentlevel+ "/"+level.GunGameWeapons.size);

	self.GunHudNext = NewClientHudElem(self);
	self.GunHudNext.alingX = "center";
	self.GunHudNext.alingY = "top";
	self.GunHudNext.horzAlign = "center";
	self.GunHudNext.vertAlign = "top";
	self.GunHudNext.y = 10;
	//self.GunHudNext.x = -10;
	self.GunHudNext.hidewheninmenu = true;
	self.GunHudNext.font = "default";
	self.GunHudNext SetText("Kills Required: " + N_BASE_SCORE );

	/*self.GunHudNextNum = NewClientHudElem(self);
	self.GunHudNextNum.alingX = "center";
	self.GunHudNextNum.alingY = "top";
	self.GunHudNextNum.horzAlign = "center";
	self.GunHudNextNum.vertAlign = "top";
	self.GunHudNextNum.y = 10;
	self.GunHudNextNum.x = 40;
	self.GunHudNextNum.hidewheninmenu = true;
	self.GunHudNextNum.font = "default";
	self.GunHudNextNum SetText( N_BASE_SCORE );*/

}

function WatchForKills()
{
	level endon("end_game");
	self.score_required = N_BASE_SCORE;

	while(self.currentlevel < (level.GunGameWeapons.size + 1))
	{
		self waittill("zom_kill");
		//IPrintLnBold("zom kill");
		if(!self laststand::player_is_in_laststand() && !IS_DRINKING(self))
		{
			if(level.zombie_vars[self.team]["zombie_point_scalar"] == 2)
			{
				self.gungamekills++;	
			}

			self.gungamekills++;

			text = (self.score_required - self.gungamekills);
			self thread UpdateScoreHud( text );
		
			if(self.gungamekills >= self.score_required)
			{
				self IncreaseLevel();
			}
		}
	}

	level notify("end_game");

}

function IncreaseLevel()
{
	self SetNewWeapon( false );
	self UpdateGunHud( self.currentlevel );
	self UpdateScoreHud( self.score_required );
	self.gungamekills = 0;
}

function UpdateScoreHud( text )
{
	if(isdefined(self.GunHudNext))
	{
		self.GunHudNext SetText( "Kills Required: " + text  );
	}
	
}

function UpdateGunHud( text )
{
	if(isdefined(self.GunHudCurrent))
	{
		self.GunHudCurrent SetText("Current Weapon: "+self.currentlevel+ "/"+level.GunGameWeapons.size);
		//self.GunHudCurrentNum SetText( text );
	}
}

function SetNewWeapon( is_death = false )
{
	old_weapon = self GetCurrentWeapon();
	currentWeapon = level.GunGameWeapons[self.currentlevel -1];

	take_old_weapon = !is_death;

	if( !is_death )
	{
		self.currentlevel++;
	}

	else
	{
		self.currentlevel--;
		if(self.currentlevel < 1)
			self.currentlevel = 1;
	}

	if( self.currentlevel >= level.GunGameWeapons.size - 5 )
	{
		// Someone has reached wonder weapons, raise hell
		if(!level.spawned_bosses)
		{
			level thread GunGameSpawnBosses();
			level.spawned_bosses = true;
		}
	}

	if( self.currentlevel >= level.GunGameWeapons.size - 3 )
		self thread FillAmmoOnFire();

	newWeapon = level.GunGameWeapons[self.currentlevel - 1];
	if(!isdefined(newWeapon))
	{
		if(isdefined(self.playername))
		{
			IPrintLnBold("The Winner is: " +self.playername);
		}

		return;
	}

	if( self HasWeapon( newWeapon ) != true )
	{
		if( !is_death )
		{
			if( self IsCurrentWeaponIllegal( old_weapon ) )
			{
				for(;;)
				{
					self util::waittill_any("weapon_change_complete", "perk_abort_drinking");
					if( self IsCurrentWeaponIllegal(self GetCurrentWeapon()) )
						continue;

					if(isdefined(self.weaponRiotshield) && old_weapon == self.weaponRiotshield)
					{
						take_old_weapon = false;
					}

					break;
				}
			}
		}

		self zm_weapons::weapon_give( newWeapon, 0, 0, 1, 1 );
		if(take_old_weapon)	// Checking to see if the player has the shield. Don't take the shield if player used it previously
		{
			if(old_weapon != level.weaponNone)
				self TakeWeapon(old_weapon);
		}
		
		if(self HasWeapon(currentWeapon) && currentWeapon != newWeapon)
		{
			//IPrintLnBold("Taking weapon: " +currentWeapon.displayName);
			self TakeWeapon(currentWeapon);
		}
	}

	else
	{
		self GiveMaxAmmo(newWeapon);
		self SwitchToWeapon(newWeapon);
	}

	if(self.score_required >= N_SCORE_CAP)
	{
		self.score_required = N_SCORE_CAP;
	}

	else
	{
		self.score_required = Int(self.score_required + N_SCORE_ADD);
	}

	DebugPrint("Score Required " +self.score_required);
}

function GunGameAmmo()
{
	level endon("end_game");
	self endon("disconnect");

	while(1)
	{
		self util::waittill_any( "reload", "weapon_change_complete" );
		weapon = self GetCurrentWeapon();
		self GiveMaxAmmo(weapon);
	}
}

function GunGameSpawnBosses()
{
	num_to_spawn = 6;
	for(i = 0; i < num_to_spawn; i++)
	{
		zm_ai_reverant::sonic_zombie_spawn();
		WAIT_SERVER_FRAME;
	}
}

function IsCurrentWeaponIllegal( currentWeapon )	//self = player
{
	illegals = [];
	illegals[illegals.size] = GetWeapon("hero_gravityspikes_melee");
	illegals[illegals.size] = GetWeapon("frag_grenade_mp");
	illegals[illegals.size] = GetWeapon("minigun");
	illegals[illegals.size] = level.weaponReviveTool;

	foreach(weapon in illegals)
	{
		if(currentWeapon == weapon)
			return true;
	}

	if( isdefined(self.weaponRiotshield) && currentWeapon == self.weaponRiotshield)
		return true;

	if( IS_DRINKING(self.is_drinking) )
		return true;

	if( zm_utility::is_melee_weapon( currentWeapon ) )
		return true;

	return false;
}

function GunGameMaxAmmo()	// In gungame, half the score requirement if someone get's a max ammo
{
	level endon("end_game");
	while(1)
	{
		level waittill("zmb_max_ammo_level");
		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			if( isdefined(players[i].score_required) )
			{
				players[i].gungamekills = Int(players[i].gungamekills * 2);
				hint = "Bonus Score";
				players[i] thread zm_equipment::show_hint_text( hint, 3 );

				if( players[i].gungamekills >= players[i].score_required )
					players[i] IncreaseLevel();

				else
					players[i] UpdateScoreHud( players[i].score_required - players[i].gungamekills );
			}
		}
	}
}

function FillAmmoOnFire()	//self = player
{
	level endon("end_game");
	self endon("death");
	self endon("disconnect");

	if( IS_TRUE(self.refill_ammo_on_fire) )
		return;

	self.refill_ammo_on_fire = true;

	while(1)
	{
		self waittill( "weapon_fired", weapon );
		if( isdefined(weapon) )
		{
			self GiveMaxAmmo( weapon );
		}
	}
}