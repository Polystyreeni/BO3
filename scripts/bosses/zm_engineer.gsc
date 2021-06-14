/*
Engineer Zombie from Black Ops 1 made by ihmiskeho
Credits:
DTZXPorter (Wraith)
NateSmithZombies (Base script)
Rayz1235 (maya tools)
I Take no credit for the base script, this is basically Nates Brutus script!!! I just added/fixed some stuff from it. 

*/
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_behavior;
#using scripts\zm\zm_project_e_ee;

//7.11.17 ADDED ZOMBIE BLOOD
#using scripts\_NSZ\nsz_powerup_zombie_blood;

#insert scripts\shared\aat_zm.gsh;

#insert scripts\shared\shared.gsh;

#using_animtree( "generic" ); 

#namespace engineer; 

#precache( "model", "t5_engineer_fullbody" );

#define ENGINEER_SPAWN_FX									"bosses/engineer_spawn"
#precache( "fx", ENGINEER_SPAWN_FX ); 

#define ENGINEER_GROUND_FX									"dlc1/castle/fx_dust_impact_ground"
#precache( "fx", ENGINEER_GROUND_FX ); 

#define ENGINEER_LOOP_FX									"custom/fx_afterlife_loop"
#precache( "fx", ENGINEER_LOOP_FX );

#define ENGINEER_GROUND_FX_SUPER							"dlc1/castle/fx_elec_exp_blue"
#precache( "fx", ENGINEER_GROUND_FX_SUPER );

#precache("model", "t5_engineer_fullbody_super");

function init()
{
	//=============Engineer variables===============
	level.engineer_debug = false;			// Debug
	level.engineer_spawn_debug = false;		// Debug
	level.swingDamage = 60;					// Engineer melee attack damage
	level.groundHitDamage = 80;				// Engineer ground slam damage
	level.eng_health = 5000;				// Base health
	level.engineer_health_multiplier = 12;	// Health multiplier when compared to regular zombie
	level.eng_min_round = 5;				// The minimun amount of rounds between spawns
	level.eng_max_round = 6;				// Maximum amount of rounds between spawns
	level.eng_run_distance = 1800;			// From this distance, the engineer will run near players
	//=============Engineer variables===============
	level.engineers_alive = 0;
	//level.engineer_mad = false;
	level.octobomb_targets = &remove_engineer; 

	thread main();
}

function eng_debug( string )
{
	if(IsDefined(level.engineer_debug) && level.engineer_debug)
	IPrintLnBold("^1DEBUG: ^7" +string );
	
}

function main()
{
	level flag::wait_till("all_players_connected");
	level activate_eng_spawns();
	level thread engineer_spawn_logic();
}

function remove_engineer( ai )
{
	if(isdefined(ai))
		return;

	foreach( zom in ai )
	{
		if( isDefined(zom.is_boss) )
			ArrayRemoveValue( ai, zom, false ); 
	}
	return ai; 
}

function activate_eng_spawns()
{
	level.engineer_spawn_points = struct::get_array("engineer_spawn_point","targetname");
	if(!IsDefined(level.engineer_spawn_points) || level.engineer_spawn_points.size == 0)
	{
		eng_debug("Structs don't exist");
		return;
	}
	
}

function wait_for_activation()
{
	if(self.script_string == "start_zone")
		level.engineer_spawn_points[level.engineer_spawn_points.size] = self;

	else
	{
		flag = self.script_string;
		level flag::wait_till(flag);
		level.engineer_spawn_points[level.engineer_spawn_points.size] = self;
	}
}

function engineer_spawn_logic()
{
	//ADD: add endon for possible events that may require engineers spawn to stop
	level endon("intermission");

	if(IsDefined(level.engineer_spawn_debug) && level.engineer_spawn_debug)
	{
		level thread spawn_engineer();
	}

	level.next_engineer_round = RandomIntRange(level.eng_min_round, level.eng_max_round + 1);
	eng_debug("Engineer spawn round:"+level.next_engineer_round);
	while(1)
	{
		level waittill("between_round_over");
		if( isdefined(level.round_number) && isdefined(level.next_engineer_round) && level.round_number == level.next_engineer_round )
		{
			level.next_engineer_round = level.round_number + RandomIntRange(level.eng_min_round, level.eng_max_round + 1);
			if( isdefined(level.next_dog_round) && level.next_dog_round == level.next_engineer_round )
			{
				level.next_engineer_round++;
				continue;
			}

			while( level.engineers_alive < 1 )
			{
				wait(RandomIntRange(1,20));
				if(level.engineers_alive < 1)
				{
					level spawn_engineer();
					break;
				}
			}
		}
	}
}

function spawn_engineer( boss_fight_spawn = false, override_wait = false )
{
	level.engineers_alive++;
	spawner = GetEnt("zombie_engineer","script_noteworthy");
	if( !isdefined(spawner) )
		return;

	if( !IS_TRUE(override_wait) )
	{
		wait(RandomIntRange(5,20));
	}
	
	eng_debug("Spawning Zombie Engineer");

	if( IS_TRUE(boss_fight_spawn) )
	{
		valid_spawn = undefined;

		spawn_points = level.engineer_spawn_points;
		for(i = 0; i < spawn_points.size; i++)
		{
			if( isdefined(spawn_points[i].script_string) && spawn_points[i].script_string == "zone_boss" )
			{
				valid_spawn = spawn_points[i];
			}
		}

		spot = valid_spawn;
	}

	else
	{
		spot = chooseSpawn();
	}
	
	if(!isdefined(spot))
	{
		eng_debug("Unable to spawn Engineer");
		level.engineers_alive--;
		return;
	}

	if( level flag::exists("dog_round") && level flag::get("dog_round") )
	{
		eng_debug("engineer unable to spawn due to dog round");
		level.engineers--;
		level.next_engineer_round = level.round_number + 1;
		return;
	}

	playerssound("engineer_bells");
	wait(2);

	players = GetPlayers();
	player = array::random(players);
	if( isdefined(player) )
	{
		player thread zm_project_e_ee::CustomPlayerQuote( "vox_plr_" +player GetCharacterBodyType() + "_engineeer_spawn_0" + RandomInt(2) );
	}

	wait(3.5);

	//SETTING UP ENGINEER STATS
	engineer = zombie_utility::spawn_zombie(spawner);
	engineer thread zombie_spawn_init();
	engineer thread handleAttack();
	engineer thread noteTracker();
	engineer thread newDeath();
	engineer thread watchHealth();
	engineer thread zombie_utility::round_spawn_failsafe();		//Remove this if issues with engineer dying randomly

	e_health = level.zombie_health * level.engineer_health_multiplier;

	if(e_health < 80000)
	{
		engineer.maxhealth = e_health;
		engineer.health = e_health;

	}
	else
	{
		engineer.maxhealth = 80000;
		engineer.health = 80000;
	}

	engineer.death_anim = %zombeng_death1;
	engineer BloodImpact( "normal" ); 
	engineer.no_damage_points = true; 
	engineer.allowpain = false; 
	engineer.ignoreall = true; 
	engineer.ignoreme = true; 
	engineer.allowmelee = false; 
	engineer.needs_run_update = true; 
	engineer.no_powerups = true; 
	engineer.canattack = false; 
	engineer DetachAll(); 
	engineer.goalRadius = 32; 
	engineer.is_on_fire = true; 
	engineer.gibbed = true; 
	engineer.variant_type = 0; 
	engineer.zombie_move_speed = "walk"; 
	engineer.zombie_arms_position = "down"; 
	engineer.ignore_nuke = true; 
	engineer.instakill_func = &anti_instakill; 
	engineer.ignore_enemy_count = true; 
	engineer PushActors( true );
	engineer.lightning_chain_immune = true; 
	engineer.tesla_damage_func = &new_tesla_damage_func; 
	engineer.thundergun_fling_func = &new_thundergun_fling_func; 
	engineer.thundergun_knockdown_func = &new_knockdown_damage; 
	engineer.is_boss = true; 
	engineer.IsMad = false;
	engineer.occupied = false;
	engineer.b_immune_to_flogger_trap = true;
	engineer.b_ignore_cleanup = true;	//Must have this, otherwise you'll get a connection interrupted/game crash if you walk too far away
	engineer.b_immune_to_acid_trap = true;
	engineer.b_super_engineer = false;
	engineer.fire_damage_func = &engineer_firedamage_func;
	engineer.ignore_zombie_lift	= 1;
	engineer.no_widows_wine = 1;

	PlayFX( level._effect["lightning_dog_spawn"], spot.origin );
	PlaySoundAtPosition( "zmb_hellhound_prespawn", spot.origin );
	wait( 1.5 );
	PlaySoundAtPosition( "zmb_hellhound_bolt", spot.origin );

	engineer ForceTeleport( spot.origin, spot.angles, 1 ); 
	engineer AnimScripted( "note_notify", engineer.origin, engineer.angles, %zombeng_enrage );
	//PlayFX( ENGINEER_SPAWN_FX, engineer.origin ); 
	PlaySoundAtPosition( "wpn_tesla_bounce", engineer.origin);
	Earthquake( 0.4, 4, engineer.origin, 5000 ); 
	wait( GetAnimLength(%zombeng_enrage) ); 

	engineer thread custom_find_flesh();
	
	// V2 EDIT, Engineer runs to closest player, if far away
	engineer thread distance_watcher();

	eng_debug("Engineers alive:" +level.engineers_alive);
}

function SpawnSpecialEngineer(  )
{
	level.engineers_alive++;

	spawner = GetEnt("zombie_engineer","script_noteworthy");
	spot = struct::get("engineer_special_point", "targetname");
	
	if(!isdefined(spot))
	{
		eng_debug("Unable to spawn Engineer");
		level.engineers_alive--;
		return;
	}

	if(level flag::exists("dog_round") && level flag::get("dog_round"))
	{
		eng_debug("engineer unable to spawn due to dog round");
		level.engineers--;
		level.next_engineer_round = level.round_number + 1;
		return;
	}
	//playerssound("engineer_bells");
	//wait(5);
	//playerssound("engineer_amb_0" +RandomIntRange(0,8));

	//SETTING UP ENGINEER STATS
	engineer = zombie_utility::spawn_zombie(spawner);
	engineer thread zombie_spawn_init();
	engineer thread handleAttack();
	engineer thread noteTracker();
	engineer thread newDeath();
	engineer thread watchHealth();
	engineer thread zombie_utility::round_spawn_failsafe();		//Remove this if issues with engineer dying randomly

	players = GetPlayers();
	players_size = players.size;
	e_health = level.zombie_health * level.engineer_health_multiplier * 2;
	//IPrintLnBold("Engineer Health: "+e_health);

	if(e_health < 120000)
	{
		engineer.maxhealth = e_health;
		engineer.health = e_health;

	}
	else
	{
		engineer.maxhealth = 120000;
		engineer.health = 120000;
	}

	engineer.death_anim = %zombeng_death1;
	engineer BloodImpact( "normal" ); 
	engineer.no_damage_points = true; 
	engineer.allowpain = false; 
	engineer.ignoreall = true; 
	engineer.ignoreme = true; 
	engineer.allowmelee = false; 
	engineer.needs_run_update = true; 
	engineer.no_powerups = true; 
	engineer.canattack = false; 
	engineer DetachAll(); 
	engineer.goalRadius = 32; 
	engineer.is_on_fire = true; 
	engineer.gibbed = true; 
	engineer.variant_type = 0; 
	engineer.zombie_move_speed = "run"; 
	engineer.zombie_arms_position = "down"; 
	engineer.ignore_nuke = true; 
	engineer.instakill_func = &anti_instakill; 
	engineer.ignore_enemy_count = true; 
	engineer PushActors( true );
	engineer.lightning_chain_immune = true; 
	engineer.tesla_damage_func = &new_tesla_damage_func; 
	engineer.thundergun_fling_func = &new_thundergun_fling_func; 
	engineer.thundergun_knockdown_func = &new_knockdown_damage; 
	engineer.is_boss = true; 
	engineer.IsMad = true;
	engineer.occupied = false;
	engineer.b_immune_to_flogger_trap = true;
	engineer.b_ignore_cleanup = true;	//Must have this, otherwise you'll get a connection interrupted/game crash if you walk too far away
	engineer.b_immune_to_acid_trap = true;
	engineer.b_super_engineer = true;
	engineer.fire_damage_func = &engineer_firedamage_func;
	engineer.ignore_zombie_lift	= 1;

	engineer SetModel("t5_engineer_fullbody_super");

	/*PlayFX( level._effect["lightning_dog_spawn"], spot.origin );
	PlaySoundAtPosition( "zmb_hellhound_prespawn", spot.origin );
	wait( 1.5 );
	PlaySoundAtPosition( "zmb_hellhound_bolt", spot.origin );*/

	engineer ForceTeleport( spot.origin, spot.angles, 1 ); 
	engineer AnimScripted( "note_notify", engineer.origin, engineer.angles, %zombeng_enrage );
	//PlayFX( ENGINEER_SPAWN_FX, engineer.origin ); 
	//PlaySoundAtPosition( "vox_cyber_roar", engineer.origin);
	Earthquake( 0.4, 4, engineer.origin, 5000 ); 
	wait(GetAnimLength(%zombeng_enrage));

	engineer thread custom_find_flesh();

	engineer thread SpecialEngineerForceField();

	eng_debug("Engineers alive:" +level.engineers_alive);
}

function aat_override()
{
	while( isDefined(self) )
	{
		archetype = self.archetype; 
		self.aat_cooldown_start[ZM_AAT_BLAST_FURNACE_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_DEAD_WIRE_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_FIRE_WORKS_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_THUNDER_WALL_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.aat_cooldown_start[ZM_AAT_TURNED_NAME] = GetTime() ;  // always force the cooldown to be less than current time
		self.no_powerups = true; 
		self.b_octobomb_infected = true; 
		
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_trigger[ self.archetype ] = true;
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_result_direct[ self.archetype ] = true;
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_result_indirect[ self.archetype ] = true;
		
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_trigger[ self.archetype ] = true;
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_result_direct[ self.archetype ] = true;
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_result_indirect[ self.archetype ] = true;
		
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_trigger[ self.archetype ] = true;
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_result_direct[ self.archetype ] = true;
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_result_indirect[ self.archetype ] = true;
		
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_trigger[ self.archetype ] = true;
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_result_direct[ self.archetype ] = true;
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_result_indirect[ self.archetype ] = true;
		
		level.aat[ ZM_AAT_TURNED_NAME ].immune_trigger[ self.archetype ] = true;
		level.aat[ ZM_AAT_TURNED_NAME ].immune_result_direct[ self.archetype ] = true;
		level.aat[ ZM_AAT_TURNED_NAME ].immune_result_indirect[ self.archetype ] = true;
		
		wait(0.05); 
	
	}
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_trigger[ archetype ] = false;
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_result_direct[ archetype ] = false;
		level.aat[ ZM_AAT_FIRE_WORKS_NAME ].immune_result_indirect[ archetype ] = false;
		
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_trigger[ archetype ] = false;
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_result_direct[ archetype ] = false;
		level.aat[ ZM_AAT_BLAST_FURNACE_NAME ].immune_result_indirect[ archetype ] = false;
		
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_trigger[ archetype ] = false;
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_result_direct[ archetype ] = false;
		level.aat[ ZM_AAT_DEAD_WIRE_NAME ].immune_result_indirect[ archetype ] = false;
		
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_trigger[ archetype ] = false;
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_result_direct[ archetype ] = false;
		level.aat[ ZM_AAT_THUNDER_WALL_NAME ].immune_result_indirect[ archetype ] = false;
		
		level.aat[ ZM_AAT_TURNED_NAME ].immune_trigger[ archetype ] = false;
		level.aat[ ZM_AAT_TURNED_NAME ].immune_result_direct[ archetype ] = false;
		level.aat[ ZM_AAT_TURNED_NAME ].immune_result_indirect[ archetype ] = false;
}

function custom_find_flesh()
{
	self endon("death");

	while(1)
	{
		if(isDefined(self.engineer_enemy) && zm_utility::is_player_valid(self.engineer_enemy) && isDefined(self.engineer_enemy.engineer_track_countdown) && self.engineer_enemy.engineer_track_countdown > 0 && !self.engineer_enemy.has_zombie_blood && !self.engineer_enemy laststand::player_is_in_laststand())	//7.1.17 ADDED ZOMBIE BLOOD
		{
			self.engineer_enemy.engineer_track_countdown -= 0.05;
			self.v_zombie_custom_goal_pos = self.engineer_enemy.origin; 
		}
		else
		{
			eng_debug("Engineer Defining new target");
			players = GetPlayers();
			targets = array::get_all_closest(self.origin, players);
			for(i = 0; i < targets.size; i++)
			{
				wait(.05);
				if( zm_utility::is_player_valid(targets[i]) && !targets[i].has_zombie_blood && !targets[i] laststand::player_is_in_laststand() && !IS_TRUE(targets[i].in_afterlife) )
				{
					self.engineer_enemy = targets[i];
					self.v_zombie_custom_goal_pos = self.engineer_enemy.origin; 

					eng_debug("new target selected");
					if( !isDefined(targets[i].engineer_track_countdown) )
						targets[i].engineer_track_countdown = 2; 

					if( isDefined(targets[i].engineer_track_countdown) && targets[i].engineer_track_countdown <= 0 )
						targets[i].engineer_track_countdown = 2; 

					break; 
				}
			}
		}

		wait(0.05);
	}
}

function SpecialEngineerForceField()
{
	fxmodel = util::spawn_model("tag_origin", self.origin);
	if(!isdefined(fxmodel))
		return;

	fxmodel EnableLinkTo();
	fxmodel LinkTo(self);
	PlayFXOnTag(ENGINEER_LOOP_FX, fxmodel, "tag_origin");

	while( isdefined(self) && IsAlive(self) )
	{
		a_closest = util::get_array_of_closest(self.origin, GetPlayers(), undefined, undefined, 150);
		if( isdefined(a_closest) )
		{
			for( i = 0; i < a_closest.size; i++ )
			{
				a_closest[i] thread PlayerBlurScreen();
			}
		}

		wait(2);
	}

}

function PlayerBlurScreen()	//4, 5, .2, "damage_heavy", e_sonic_zombie
{
	self endon( "disconnect" );

	Earthquake( .2, 3, self.origin, 100, self );
	self SetBlur( 2, .2 );
	self PlayRumbleOnEntity( "damage_heavy" );
	self DoDamage( 10, self.origin, self ); 
	
	self util::waittill_any_timeout( 2, "death", "blur_cleared" );

	self setBlur( 0, .5 );
	self notify( "blur_cleared" );
	self StopRumble( "damage_heavy" );
}

function handleFootsteps()
{
	self endon("death");
	while(1)
	{
		self waittill("fly_step_engineer");
		self PlaySound("engineer_step");	
	}
}

function ambSounds()
{
	self endon("death");
	while(1)
	{
		self waittill("zmb_engineer_vocals_amb");
		self PlaySound("engineer_amb_0" +RandomInt(9));
	}
}

function handleAttack()
{
	self endon("death");
	if(!isdefined(self))
		return;
		
	while(1)
	{
		if(Distance(self.engineer_enemy.origin, self.origin) < 75 && BulletTracePassed( self.engineer_enemy.origin, 0, self.origin, self, self.engineer_enemy ) && !self.engineer_enemy.has_zombie_blood && !IS_TRUE(self.occupied) && !IS_TRUE(self.engineer_enemy.in_afterlife))	//if(Distance2D(self.engineer_enemy.origin, self.origin) < 75 && BulletTracePassed( self.engineer_enemy.origin, self.origin, 0, self, self.engineer_enemy ))
		{
			if(self.IsMad)
			{
				end_pos = zombie_utility::getAnimEndPos( %zombeng_run_attack );
				if(BulletTracePassed(self.origin, end_pos, false, self))
				{
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_run_attack ); 
					wait(GetAnimLength(%zombeng_run_attack) + 1);
				}

				else
				{
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_swing ); 
					wait(GetAnimLength(%zombeng_swing));
				}
				
				//wait(1.5);
			}
			else
			{
				random = RandomIntRange(0,3);
				switch(random)
				{
					case 0:
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_swing ); 
					wait(GetAnimLength(%zombeng_swing));
					break;

					case 1:
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_multiswing1 ); 
					wait(GetAnimLength(%zombeng_multiswing1));
					break;

					case 2:
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_multiswing2 ); 
					wait(GetAnimLength(%zombeng_multiswing2));
					break;

					case 3:
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_headbutt ); 
					wait(GetAnimLength(%zombeng_headbutt));
					break;

					default:
					self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_swing ); 
					wait(GetAnimLength(%zombeng_swing));
					break;
				}

			}
		}
		wait(0.05);
	}
	

}

function noteTracker()
{
	self endon("death");

	while(1)
	{
		self waittill("note_notify", note);
		if( !isdefined(note) )
			return;
			
		if( note == "zmb_engineer_whoosh" )
		{
			chance =  RandomIntRange(0,3); 
			PlaySoundAtPosition( "engineer_whoosh", self.origin ); 
			self PlaySound( "engineer_attack_0"+chance); 
			 
			players = util::get_array_of_closest( self.origin, GetPlayers(), undefined, undefined, 150 );
			if(!isdefined(players))
				continue;

			foreach( player in players )
			{
				if( isdefined(self.engineer_enemy) && player != self.engineer_enemy )
					continue;

				if( BulletTracePassed( self.engineer_enemy.origin, 0, self.origin, self, self.engineer_enemy ) && self is_facing(player) )
				{
					Earthquake( .25, 3, player.origin, 50 ); 
					player ShellShock( "frag_grenade_mp", 1.0 );
					player DoDamage( level.swingDamage, player.origin, self ); 
					player playsound("engineer_hit");
				}
			}
		}

		if( note == "zmb_engineer_groundbang" )
		{
			chance =  RandomIntRange(0,3); 
			self PlaySound( "engineer_attack_0" +chance ); 
			PlaySoundAtPosition( "engineer_groundhit", self.origin );
			
			if(IS_TRUE(self.b_super_engineer))
			{
				self thread SuperEngineerAttack();
			}

			else
			{
				PlayFX(ENGINEER_GROUND_FX, self GetTagOrigin("tag_weapon_right"));
				players = GetPlayers(); 
				foreach( player in players )
				{
					if( IS_TRUE(player.in_afterlife) )
						continue;

					if( Distance2D(player.origin, self.origin) < 200 && BulletTracePassed( player.origin, 0, self.origin, self, player ))
					{
						Earthquake( 10, 3, player.origin, 50 ); 
						player ShellShock( "frag_grenade_mp", 1.0 );					
						player DoDamage( level.groundHitDamage, player.origin, self );
					}
				}
			}

			
		}

		if( note == "zmb_engineer_vocals_amb" )
		{
			chance = RandomIntRange(0,9);
			self PlaySound("engineer_amb_0"+chance);
		}

		if( note == "footstep_left_large" || note == "footstep_right_large" )
		{
			self PlaySound("engineer_step");
			Earthquake(0.3, 1, self.origin, 300);
		}

		if( note == "zmb_engineer_vocals_hit" )
		{
			chance = RandomIntRange(0,3);
			self PlaySound("engineer_roar_0"+chance );
		}

		if( note == "zmb_engineer_headbutt" )
		{
			chance =  RandomIntRange(0,3); 
			self PlaySound( "engineer_attack_0"+chance); 
			players = getplayers(); 
			foreach( player in players )
			{
				if( Distance2d(player.origin, self.origin) < 110 && self.engineer_enemy == player )
				{
					player PlaySound("engineer_headbang");
					Earthquake( .25, 3, player.origin, 30 ); 
					player ShellShock( "frag_grenade_mp", 1.0 );
					player DoDamage( level.swingDamage, player.origin, self ); 
				}
			}
			
		}
		if( note == "zmb_engineer_headbang" || note == "headhit")
		{
			self PlaySound("engineer_headbang" );
		}

	}

}

function is_facing( facee, requiredDot = 0.8 )
{
	orientation = self.angles;
	forwardVec = anglesToForward( orientation );
	forwardVec2D = ( forwardVec[0], forwardVec[1], 0 );
	unitForwardVec2D = VectorNormalize( forwardVec2D );
	toFaceeVec = facee.origin - self.origin;
	toFaceeVec2D = ( toFaceeVec[0], toFaceeVec[1], 0 );
	unitToFaceeVec2D = VectorNormalize( toFaceeVec2D );
	
	dotProduct = VectorDot( unitForwardVec2D, unitToFaceeVec2D );
	return ( dotProduct > requiredDot ); // reviver is facing within a ~52-degree cone of the player
}

function SuperEngineerAttack()	//V2 added: made a custom attack for the super engineer
{
	PlayFX(ENGINEER_GROUND_FX_SUPER, self GetTagOrigin("tag_weapon_right"));
	PlaySoundAtPosition("lightning_fire_ug_npc", self.origin);

	range = 300;

	players = GetPlayers();
	players = util::get_array_of_closest(self.origin, players, undefined, undefined, range);

	if(!isdefined(players))
		return;

	for(i = 0; i < players.size; i++)
	{
		Earthquake( 10, 3, players[i].origin, 50 ); 
		players[i] SetElectrified( 1.5 );
		players[i] ShellShock( "frag_grenade_mp", 1.5 );					
		players[i] DoDamage( (level.groundHitDamage * 2), players[i].origin, self );

		wait(0.05);
		if(players[i] laststand::player_is_in_laststand())
			continue;

		velocity = players[i] GetVelocity();
		players[i] SetVelocity( velocity + (RandomInt(30), RandomInt(30), 150) );

	}

}

function newDeath()
{
	self waittill("death");
	level.engineers_alive--;
	if(IS_TRUE(self.b_super_engineer))
	{
		self PlaySound("engineer_death_0"+RandomInt(4));
		eng_debug("engineer dead");
		clone = Spawn("script_model", self.origin);
		clone.angles = self.angles;
		clone SetModel("t5_engineer_fullbody_super");
		self Hide();
		clone UseAnimTree(#animtree);
		clone AnimScripted( "placeholder", clone.origin, clone.angles, %zombeng_death1 );
		wait(GetAnimLength(%zombeng_death1));
		thread zm_project_e_ee::SpawnWindPart( self.origin + (0, 0, 20) );
		//zm_powerups::specific_powerup_drop( undefined, clone.origin +(0,0,10));
		self Delete();
		wait(3);
		PlayFX( ENGINEER_SPAWN_FX, clone.origin ); 
		clone PlaySound( "wpn_tesla_bounce" );
		clone Delete();
	}

	else
	{
		if(isdefined(self.attacker))
		{
			//IPrintLnBold("Boss kill");
			
			if( "MOD_MELEE" == self.damagemod )
			{
				self.attacker notify("boss_zombie_kill_melee");
			}

			self.attacker notify("boss_zombie_kill");
		}

		self PlaySound( "engineer_death_0" +RandomInt(4) );

		players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			players[i] zm_score::add_to_player_score( 500 );
		}

		player = ArrayGetClosest(self.origin, players);
		if(isdefined(player))
		{
			player thread zm_project_e_ee::CustomPlayerQuote( "vox_plr_" +player GetCharacterBodyType() + "_engineeer_kill_0" + RandomInt(2) );
		}

		eng_debug("engineer dead");
		clone = Spawn("script_model", self.origin);
		clone.angles = self.angles;
		clone SetModel("t5_engineer_fullbody");
		self Hide();
		clone UseAnimTree(#animtree);
		clone AnimScripted( "placeholder", clone.origin, clone.angles, %zombeng_death1 );
		wait(GetAnimLength(%zombeng_death1));

		if(self CanDropPowerUp())
			zm_powerups::specific_powerup_drop( undefined, clone.origin +(0,0,10));

		self Delete();
		wait(3);
		PlayFX( ENGINEER_SPAWN_FX, clone.origin ); 
		clone PlaySound( "wpn_tesla_bounce" );
		clone Delete();
	}
	
}

function CanDropPowerUp()
{
	if(!level flag::get( "zombie_drop_powerups" ))
		return false;

	volumes = GetEntArray( "no_powerups", "targetname" );
	if(!isdefined(volumes))
		return true;

	foreach( volume in volumes )
	{
		if ( self IsTouching( volume ) )
		{
			return false;
		}
	}

	return true;
}

function watchHealth()
{
	totalDamage = 0;
	has_enraged = false;

	while(1)
	{
		self waittill("damage", amount, attacker);

		if(IsPlayer(attacker))
		{
			attacker show_hit_marker();
		}

		if( IS_TRUE(self.IsMad) )
		{
			continue;
		}

		if(!has_enraged)
		{
			totalDamage = totalDamage + amount;
			if(totalDamage >= 500)
			{
				has_enraged = true;
				attacker zm_score::add_to_player_score( 400 );
				self.occupied = true;
				self.allowdeath = false;
				self PlaySound("engineer_roar_0"+RandomInt(4));
				self AnimScripted( "note_notify", self.origin, self.angles, %zombeng_enrage ); 
				wait( GetAnimLength(%zombeng_enrage) ); 
				self.IsMad = true;
				eng_debug("engineer is mad");
				self.zombie_move_speed = "run";
				self.allowdeath = true;
				self.occupied = false;
			}
		}
	}
}

function distance_watcher()	//self = engineer
{
	self endon("death");
	interval = 5;

	while(1)
	{
		if(IS_TRUE(self.IsMad))
			break;

		if(!isdefined(self.engineer_enemy))
		{
			wait(1);
			continue;
		}

		distance = Distance2D(self.origin, self.engineer_enemy.origin);

		if( distance > level.eng_run_distance )		// Engineer start running
		{
			self.zombie_move_speed = "run";
		}

		else if( distance < Int(level.eng_run_distance / 3) )
		{
			self.zombie_move_speed = "walk";
		}

		wait(interval);
	}
}

function show_hit_marker()
{
	if ( IsDefined( self ) && IsDefined( self.hud_damagefeedback ) )
	{
		self.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
		self.hud_damagefeedback.alpha = 1;
		self.hud_damagefeedback FadeOverTime(1);
		self.hud_damagefeedback.alpha = 0;
		self PlaySoundToPlayer( "mpl_hit_alert", self );
	}	
}

function chooseSpawn()
{
	players = GetPlayers();
	players = array::randomize( players );
	player = players[0];

	valid_points = [];
	spawns = level.engineer_spawn_points;

	if( !isdefined(spawns) )
	{
		eng_debug("No engineer spots are init");
		return;
	}

	for(i = 0; i < spawns.size; i++)
	{
		is_valid = zm_utility::check_point_in_enabled_zone( spawns[i].origin );
		if( IS_TRUE(is_valid) )
		{
			valid_points[valid_points.size] = spawns[i];
		}
	}

	option = ArrayGetClosest(player.origin, valid_points);
	return option;

	/*if(!isDefined(level.engineer_spawn_points) || level.engineer_spawn_points.size == 0)
		eng_debug("No engineer spots are init");

	option = ArrayGetClosest(player.origin, level.engineer_spawn_points);
	return option;*/
}

function playerssound(string)
{
	if( !isdefined(string) )
		return;

	players = GetPlayers();
	for( i = 0; i < players.size; i++ )
	{
		players[i] PlaySoundToPlayer( string, players[i] );
	}
}

function boss_think()
{
	self endon( "death" ); 
	assert( !self.isdog );
	
	self.ai_state = "zombie_think";
	self.find_flesh_struct_string = "find_flesh";

	self SetGoal( self.origin );
	self PathMode( "move allowed" );
	self.zombie_think_done = true;
}

function anti_instakill( player, mod, hit_location )
{
	return true; 
}

function new_thundergun_fling_func( player )
{
	self DoDamage( 5000, self.origin, player ); 
}

function new_tesla_damage_func( origin, player )
{
	self DoDamage( 4000, self.origin, player ); 
}

function new_knockdown_damage( player, gib )
{
	self DoDamage( 1000, self.origin, player ); 
}

function zombie_spawn_init()
{
	self.targetname = "zombie_boss";
	self.script_noteworthy = undefined;

	//A zombie was spawned - recalculate zombie array
	zm_utility::recalc_zombie_array();
	self.animname = "zombie_boss"; 		
	 
	self.ignoreme = false;
	self.allowdeath = true; 			// allows death during animscripted calls
	self.force_gib = true; 		// needed to make sure this guy does gibs
	self.is_zombie = true; 			// needed for melee.gsc in the animscripts
	self allowedStances( "stand" );
	
	//needed to make sure zombies don't distribute themselves amongst players
	self.attackerCountThreatScale = 0;
	//reduce the amount zombies favor their current enemy
	self.currentEnemyThreatScale = 0;
	//reduce the amount zombies target recent attackers
	self.recentAttackerThreatScale = 0;
	//zombies dont care about whether players are in cover
	self.coverThreatScale = 0;
	//make sure zombies have 360 degree visibility
	self.fovcosine = 0;
	self.fovcosinebusy = 0;
	
	self.zombie_damaged_by_bar_knockdown = false; // This tracks when I can knock down a zombie with a bar

	self.gibbed = false; 
	self.head_gibbed = false;
	
	// might need this so co-op zombie players cant block zombie pathing
//	self PushPlayer( true ); 
//	self.meleeRange = 128; 
//	self.meleeRangeSq = anim.meleeRange * anim.meleeRange; 

	self setPhysParams( 15, 0, 72 );
	self.goalradius = 32;
	
	self.disableArrivals = true; 
	self.disableExits = true; 
	self.grenadeawareness = 0;
	self.badplaceawareness = 0;

	self.ignoreSuppression = true; 	
	self.suppressionThreshold = 1; 
	self.noDodgeMove = true; 
	self.dontShootWhileMoving = true;
	self.pathenemylookahead = 0;


	self.holdfire			= true;	//no firing - performance gain

	self.badplaceawareness = 0;
	self.chatInitialized = false;
	self.missingLegs = false;

	if ( !isdefined( self.zombie_arms_position ) )
	{
		if(randomint( 2 ) == 0)
			self.zombie_arms_position = "up";
		else
			self.zombie_arms_position = "down";
	}
	
	self.a.disablepain = true;
	self zm_utility::disable_react(); // SUMEET - zombies dont use react feature.

	// if ( isdefined( level.zombie_health ) )
	// {
		// self.maxhealth = level.zombie_health; 
		
		// if( IsDefined(level.a_zombie_respawn_health[ self.archetype ] ) && level.a_zombie_respawn_health[ self.archetype ].size > 0 )
		// {
			// self.health = level.a_zombie_respawn_health[ self.archetype ][0];
			// ArrayRemoveValue(level.a_zombie_respawn_health[ self.archetype ], level.a_zombie_respawn_health[ self.archetype ][0]);		
		// }
		// else
		// {
			// self.health = level.zombie_health;
		// }	 
	// }
	// else
	// {
		// self.maxhealth = level.zombie_vars["zombie_health_start"]; 
		// self.health = self.maxhealth; 
	// }

	self.freezegun_damage = 0;

	//setting avoidance parameters for zombies
	self setAvoidanceMask( "avoid none" );

	// wait for zombie to teleport into position before pathing
	self PathMode( "dont move" );

	// level thread zombie_death_event( self );

	// We need more script/code to get this to work properly
//	self add_to_spectate_list();
//	self random_tan(); 
	self zm_utility::init_zombie_run_cycle(); 
	self thread boss_think(); 
	// self thread zombie_utility::zombie_gib_on_damage(); 
	self thread zm_spawner::zombie_damage_failsafe();
	
	self thread zm_spawner::enemy_death_detection();

	if(IsDefined(level._zombie_custom_spawn_logic))
	{
		if(IsArray(level._zombie_custom_spawn_logic))
		{
			for(i = 0; i < level._zombie_custom_spawn_logic.size; i ++)
			{
			self thread [[level._zombie_custom_spawn_logic[i]]]();
			}
		}
		else
		{
			self thread [[level._zombie_custom_spawn_logic]]();
		}
	}
	
	// if ( !isdefined( self.no_eye_glow ) || !self.no_eye_glow )
	// {
		// if ( !IS_TRUE( self.is_inert ) )
		// {
			// self thread zombie_utility::delayed_zombie_eye_glow();	// delayed eye glow for ground crawlers (the eyes floated above the ground before the anim started)
		// }
	// }
	self.deathFunction = &zm_spawner::zombie_death_animscript;
	self.flame_damage_time = 0;

	self.meleeDamage = 60;	// 45
	self.no_powerups = true;
	
	// self zombie_history( "zombie_spawn_init -> Spawned = " + self.origin );

	self.thundergun_knockdown_func = level.basic_zombie_thundergun_knockdown;
	self.tesla_head_gib_func = &zm_spawner::zombie_tesla_head_gib;

	self.team = level.zombie_team;
	
	// No sight update
	self.updateSight = false;

	// self.heroweapon_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;
	// self.sword_kill_power = ZM_ZOMBIE_HERO_WEAPON_KILL_POWER;

	if ( isDefined(level.achievement_monitor_func) )
	{
		self [[level.achievement_monitor_func]]();
	}

	// gamemodule post init
	// if(isdefined(zm_utility::get_gamemode_var("post_init_zombie_spawn_func")))
	// {
		// self [[zm_utility::get_gamemode_var("post_init_zombie_spawn_func")]]();
	// }

	if ( isDefined( level.zombie_init_done ) )
	{
		self [[ level.zombie_init_done ]]();
	}
	self.zombie_init_done = true;

	self notify( "zombie_init_done" );
}

function engineer_firedamage_func( trap )
{
	self DoDamage( ((self.health / 2) + 500), self.origin );
	return true;
}