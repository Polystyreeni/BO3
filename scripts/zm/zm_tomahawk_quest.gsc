/*==========================================
Project Elemental Tomahawk Quest
By ihmiskeho
New side quest for Project Elemental V2

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
#using scripts\zm\zm_weap_tomahawk;
#using scripts\zm\zm_project_e_ee;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#define SOUL_CHEST_KILLS	6	//How many souls per chest
#define UPGRADE_KILLS		15	//How many tomahawk kills in a row for the upgrade

#define FX_KEEPER_SPAWN		"zombie/fx_portal_keeper_spawn_os_zod_zmb"
#define FX_KEEPER_LOOP		"zombie/fx_keeper_ambient_torso_zod_zmb"
#define FX_TOTEM_HINT		"custom/fx_rune_glow_blue"	//"dlc1/castle/fx_wolf_arrow_shaft_float_glow"

#precache("fx", "dlc5/zmb_weapon/fx_staff_charge_souls");
#precache("fx", FX_KEEPER_SPAWN);
#precache("fx", FX_KEEPER_LOOP);
#precache("fx", FX_TOTEM_HINT);
#precache("fx", "dlc3/stalingrad/fx_fire_spot_xxsm");
#precache("fx", "custom/fx_rune_glow_blue");

#precache("model", "c_zom_zod_keeper_red_hooded_fb");
#precache("model", "wpn_t7_hatchet_world_zombie");
#precache("model", "wpn_t7_hatchet_world_zombie_upgraded");

#using_animtree( "generic" ); 

#namespace zm_tomahawk_quest;

REGISTER_SYSTEM_EX( "zm_tomahawk_quest", &init, &main, undefined )

function init()
{
	zm_spawner::add_custom_zombie_spawn_logic( &TomahawkCollectSouls );

	callback::on_connect(&SetUpUpgradeQuest);
}

function main()
{
	level flag::wait_till("initial_blackscreen_passed");

	level.tomahawk_chests = [];

	tomahawk_structs = struct::get_array("tomahawk_struct","targetname");

	level.chests_filled = 0;
	level.num_chests = tomahawk_structs.size;

	if(isdefined(tomahawk_structs))
	{
		foreach(struct in tomahawk_structs)
		{
			struct thread TomahawkWaitForActivation();
		}
	}
}

function TomahawkWaitForActivation()	//self = struct
{
	trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Activate Ritual" );

	model = util::spawn_model("tag_origin", self.origin);
	PlayFXOnTag(FX_TOTEM_HINT, model, "tag_origin");

	trigger thread UpdateHintStringVisibility();

	while(1)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if( user UseButtonPressed() )
		{
			if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_normal" || level.CurrentGameMode == "zm_scavenger"))
			{
				if(!IS_TRUE(user.in_afterlife))
				{
					wait(.1);
					continue;
				}
			}

			trigger ActivateTotem();
			WAIT_SERVER_FRAME;
			trigger Delete();
			model Delete();
			break;
		}

	}
}

function UpdateHintStringVisibility()
{
	self endon("delete");
	self endon("death");

	level endon("end_game");

	interval = 0.1;
	while( isdefined(self) )
	{
		wait(interval);
		players = GetPlayers();

		if(isdefined(level.CurrentGameMode) && (level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss") )
		{
			self SetVisibleToAll();
			return;
		}

		for(i = 0; i < players.size; i++)
		{
			if(IS_TRUE(players[i].in_afterlife))
			{
				self SetInvisibleToPlayer(players[i], false);
			}

			else
			{
				self SetInvisibleToPlayer(players[i], true);
			}
		}
		
	}
	
}

function ActivateTotem()	//self = trigger
{
	PlayFX(FX_KEEPER_SPAWN, self.origin);
	keeper = util::spawn_model("c_zom_zod_keeper_red_hooded_fb", self.origin );
	keeper UseAnimTree( #animtree );

	keeper AnimScripted( "note_notify", keeper.origin, keeper.angles, %tom_keeper_idle );
	PlaySoundAtPosition("ghost_attack", keeper.origin);

	//Soul chest stuff
	keeper.chest_active = true;
	keeper.kills = 0;

	keeper.aim_model = util::spawn_model("tag_origin", keeper.origin);
	keeper EnableLinkTo();
	keeper.aim_model EnableLinkTo();
	keeper LinkTo(keeper.aim_model);

	keeper PlayLoopSound("tom_keeper_loop");
	PlayFXOnTag(FX_KEEPER_LOOP, keeper, "j_spine4");

	level.tomahawk_chests[level.tomahawk_chests.size] = keeper;

	keeper thread KeeperTimeOut();
}

function KeeperTimeOut()
{
	self endon("delete");
	level endon("end_game");

	origin = self.origin;

	while( 1 )
	{
		self waittill("tom_soul_acquired");

		if(self.kills == 1)
		{
			closest_player = ArrayGetClosest(self.origin, GetPlayers());
			sound_to_play = "vox_plr_" + closest_player GetCharacterBodyType() + "_tom_keeper_see_00";
			closest_player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
		}

		if( self.kills >= SOUL_CHEST_KILLS )
		{
			level.chests_filled++;

			if(level.chests_filled >= level.num_chests)
			{
				self thread SpawnTomahawkPickup();
			}

			else
			{
				self AnimScripted( "note_notify", self.origin, self.angles, %tom_keeper_exit );
				wait( GetAnimLength(%tom_keeper_exit) );
				PlayFX(FX_KEEPER_SPAWN, self GetTagOrigin("j_spine4"));
				PlaySoundAtPosition("timewarp_teleport", self.origin);

				closest_player = ArrayGetClosest(origin, GetPlayers());
				sound_to_play = "vox_plr_" + closest_player GetCharacterBodyType() + "_tom_keeper_done_00";
				closest_player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );

				WAIT_SERVER_FRAME;
				self Delete();
			}
		}
	}
}

function SpawnTomahawkPickup()
{
	tomahawk_origin = self.origin + (0, 0, 20);

	self AnimScripted( "note_notify", self.origin, self.angles, %tom_keeper_exit );
	wait( GetAnimLength(%tom_keeper_exit) );

	PlayFX(FX_KEEPER_SPAWN, self GetTagOrigin("j_spine4"));
	PlaySoundAtPosition("timewarp_teleport", self.origin);

	WAIT_SERVER_FRAME;
	self Delete();

	wait(1);
	PlayFX(FX_KEEPER_SPAWN, tomahawk_origin);
	PlaySoundAtPosition("egg_pickup", tomahawk_origin);

	tomahawk = util::spawn_model("wpn_t7_hatchet_world_zombie", tomahawk_origin);
	tomahawk thread TomahawkSpin();
	PlayFXOnTag(level._effect["fx_fire_spot_xxsm"], tomahawk, "tag_weapon");

	ug_model = util::spawn_model("wpn_t7_hatchet_world_zombie_upgraded", tomahawk.origin);
	ug_model SetInvisibleToAll();
	ug_model thread TomahawkSpin();

	trigger = Spawn("trigger_radius", tomahawk.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Pick up Hell's Retriever" );

	upgraded_trigger = Spawn("trigger_radius", tomahawk.origin, 0, 32, 32);
	upgraded_trigger SetCursorHint( "HINT_NOICON" );
	upgraded_trigger SetHintString( "Hold ^3&&1 ^7To Pick up Hell's Redeemer" );
	upgraded_trigger SetInvisibleToAll();

	upgraded_trigger thread UpgradedTriggerWatch();

	first_grab = true;
	while( true )
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user))
		{
			if(IS_TRUE(user.tom_upgrade_ready))
			{
				//IPrintLnBold("user has upgraded tomahawk");
				if(IS_TRUE(user.first_upgrade_enter))
				{
					user PlayLocalSound("egg_done");
					tomahawk SetInvisibleToPlayer( user, true );
					ug_model SetVisibleToPlayer(user);
					ug_model.origin = tomahawk.origin;
					upgraded_trigger SetVisibleToPlayer(user);
					trigger SetInvisibleToPlayer( user, true );
					user.first_upgrade_enter = false;
				}

			}

			else if( zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) )
			{
				trigger SetHintStringForPlayer( "Hold ^3&&1 ^7To Pick up Hell's Retriever", user );
				if( user UseButtonPressed() )
				{
					if( IS_TRUE(user.tom_first_grab) )
					{
						sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_tom_pickup_0" + RandomInt(2);
						user thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );

						user.tom_first_grab = false;
						user thread BeginUpgradeQuest();
					}

					user thread zm_weap_tomahawk::TomahawkGrab();
				}
			}
		}
	}
}

function UpgradedTriggerWatch()
{
	level endon("end_game");
	while( true )
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", user);
		if( user UseButtonPressed() && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) )
		{
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_tom_pickup_0" + RandomInt(2);
			user thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
			user thread zm_weap_tomahawk::TomahawkGrab( true );
		}
				
	}
}

function RemoveKeeper( tomahawk )
{
	origin = self.origin + (0, 0, 10);
	self AnimScripted("note_notify", self.origin, self.angles, %tom_keeper_give_item_outro);
	wait(GetAnimLength(%tom_keeper_give_item_outro));
	PlayFX(FX_KEEPER_SPAWN, self GetTagOrigin("j_spine4"));
	WAIT_SERVER_FRAME;
	self Delete();

	tomahawk.origin = origin;
	tomahawk thread TomahawkSpin();
}

function TomahawkSpin()
{
	self endon( "death" );
	while ( 1 )
	{
		self RotateYaw( 90, 1 );
		wait .15;
	}
}

//================Upgrading to Hell's Redeemer================
//
//============================================================

function SetUpUpgradeQuest()	//self = player
{
	self.tom_upgrade_ready = false;
	self.tom_first_grab = true;
	self.first_upgrade_enter = true;
}

function BeginUpgradeQuest()
{
	self endon("disconnect");
	level endon("end_game");

	// Setup
	kills_in_row = 0;

	while(1)
	{
		self waittill("zom_kill", zombie);
		damage_weapon = zombie.damageweapon;
		if( zm_utility::is_tactical_grenade( damage_weapon ) )	//If the damaging weapon is retriever, add a kill to kills in row
		{
			kills_in_row++;
			//IPrintLnBold("Tomahawk kills: " + kills_in_row);
			if(kills_in_row >= UPGRADE_KILLS)
			{
				self PlaySoundToPlayer( "egg_done", self );
				self thread TomahawkHellHole();
				break;
			}
		}

		else
		{
			kills_in_row = 0;
		}
	}
}

function TomahawkHellHole()
{
	self endon("disconnect");
	level endon("end_game");

	while(1)
	{
		self waittill( "grenade_fire", grenade, weapon );
		if( weapon == self.current_tomahawk_weapon && weapon != level.tomahawk_weapon_upgraded )
			grenade thread GrenadeHellHoleWatcher();
	}
}

function GrenadeHellHoleWatcher()	//self = grenade
{
	self endon("death");
	self endon("delete");

	trigs = GetEntArray("lava_trigger","targetname");

	if(!isdefined(trigs))
		return;

	foreach(trigger in trigs)
	{
		trigger thread WatchGrenadeEnter( self );
	}
}

function WatchGrenadeEnter( grenade )
{
	grenade endon("death");
	grenade endon("delete");

	while(1)
	{
		wait(.1);
		if(grenade IsTouching(self))
		{
			grenade notify("in_hellhole");
			//IPrintLnBold("grenade in hellhole");
			if(isdefined(grenade.owner))
			{
				grenade Ghost();
				grenade.owner PlayLocalSound("egg_done");
				grenade.owner.tom_upgrade_ready = true;
				grenade.owner TakeWeapon(level.tomahawk_weapon);
				grenade.owner.current_tomahawk_weapon = undefined;
				grenade.owner.has_tomahawk = 0;
			}

			break;
		}
	}
}

function TomahawkCollectSouls()	//V2, for collecting souls to meteors
{
	self endon( "delete" );
	
	self waittill( "death" );
	
	if ( !isdefined( self.attacker ) || !IsPlayer( self.attacker ) )
		return;
	
	chests = level.tomahawk_chests;
	chests = util::get_array_of_closest( self.origin, chests, undefined, undefined, 250 );
	
	if ( !isdefined( chests ) || chests.size < 1 )
		return;
	
	for ( i = 0; i < chests.size; i++ )
	{
		if ( !CanChargeChest( self, chests[ i ] ) )
			continue;
		
		chests[ i ] SoulChestTakeSoul( self );
		break;
	}
}

function CanChargeChest( zombie, chest )
{
	if ( !SightTracePassed( zombie.origin, chest.origin, 0, zombie ) )
		return 0;

	if(IS_TRUE(chest.taking_soul))
		return 0;

	return 1;
}

function SoulChestTakeSoul( zombie )
{
	if(!isdefined(zombie))
		return;

	self.taking_soul = true;

	wait(1);

	soul = util::spawn_model("tag_origin", zombie.origin );

	self AimAtEnemy( soul );
	self AnimScripted("note_notify", self.origin, self.angles, %tom_keeper_give_item_intro);

	wait(GetAnimLength(%tom_keeper_give_item_intro));

	PlayFXOnTag(level._effect["fx_staff_charge_souls"], soul, "tag_origin");
	soul PlayLoopSound("soul_loop");

	soul MoveTo( self GetTagOrigin("tag_eye"), 1.25, .5, .25 );
	soul waittill("movedone");
	PlaySoundAtPosition("soul_collect_0" + RandomInt(2), soul.origin);
	WAIT_SERVER_FRAME;
	soul Delete();

	self AnimScripted("note_notify", self.origin, self.angles, %tom_keeper_give_item_outro);
	wait(GetAnimLength(%tom_keeper_give_item_outro));

	self AnimScripted( "note_notify", self.origin, self.angles, %tom_keeper_idle );

	if(!isdefined(self.kills))
		self.kills = 0;

	self.kills++;
	self notify("tom_soul_acquired");

	if(self.kills < SOUL_CHEST_KILLS)
		self.taking_soul = false;
}

function AimAtEnemy( soul )
{
	cyber_origin = self.origin;
	enemy_origin = soul.origin;
	cyber_angles = self GetAngles();

	//IPrintLnBold("Original Angles: " +cyber_angles);

	new_face_direction = VectortoAngles( enemy_origin - cyber_origin );

	self.aim_model RotateTo((cyber_angles[0], new_face_direction[1], cyber_angles[2]), 1);
	wait(1);

	//IPrintLnBold("Rotation done, facing: " +new_face_direction);
}