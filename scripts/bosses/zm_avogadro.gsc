/*
Avogadro from Black Ops 2 made by ihmiskeho
Credits:
DTZXPorter (Wraith)
SE2DEV (Seanims)
NateSmithZombies (Brutus base script)
Rayz1235 (maya tools)


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
#using scripts\shared\sound_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\zm\zm_gamemode_gungame;
#using scripts\zm\zm_project_e_ee;

//7.11.17 ADDED ZOMBIE BLOOD
#using scripts\_NSZ\nsz_powerup_zombie_blood;

#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using_animtree( "generic" ); 

#namespace zm_avogadro; 

#precache( "model", "t6_avogadro" );

#define FX_AVO_PROJECTILE									"electric/fx_ability_elec_strike_trail"
#precache( "fx", FX_AVO_PROJECTILE ); 

#define FX_AVO_LOOP					"bosses/avo_fx_loop"
#precache("fx", FX_AVO_LOOP);

REGISTER_SYSTEM_EX( "zm_avogadro", &init, undefined, undefined )

function init()
{
	clientfield::register( "scriptmover", "avo_hidden_fx",	VERSION_SHIP, 1, "int" );

	//=============Avogadro variables===============
	level.avo_debug = false;				//Debug
	level.avo_spawn_debug = false;		//Debug (if used, will spawn avogadro instantly)
	level.AvoMeleeDamage = 60;				//avo melee attack damage
	level.AvoProjectileDamage = 80;			//avo ground slam damage
	level.AvoProjectileSpeed = 400;
	level.AvoShootCooldown = 4;
	level.avo_health = 10000;				//Base health 	
	level.avo_first_round = 50;			//The first round an avogadro is going to spawn
	level.avo_round_add = 4;			//Amount of rounds between spawns
	level.avo_teleport_cooldown = 4;	//Time between possible teleports
	//=============avo variables===============
	level.avo_alive = 0;
	//level.first_avo = true;
	level.octobomb_targets = &remove_avo; 

	thread main();
}

function avo_debug( string )
{
	if(IsDefined(level.avo_debug) && level.avo_debug)
	IPrintLnBold("^1DEBUG: ^7" +string );
	
}

function main()
{
	WAIT_SERVER_FRAME;
	level flag::wait_till("all_players_connected");
	level activate_avo_spawns();
	level thread avo_spawn_logic();

}

function remove_avo( ai )
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

function activate_avo_spawns()
{
	level.avo_spawn_points = struct::get_array("avogadro_spawn_point", "targetname");

	//structs = struct::get_array("avogadro_spawn_point","targetname");

	if(!IsDefined(level.avo_spawn_points) || level.avo_spawn_points.size <= 0)
	{
		avo_debug("Structs don't exist");
		return;
	}

	/*foreach(struct in structs)
	{
		struct thread wait_for_activation();
	}*/
}
function wait_for_activation()
{
	if(self.script_string == "start_zone")
		level.avo_spawn_points[level.avo_spawn_points.size] = self;

	else
	{
		flag = self.script_string;
		level flag::wait_till(flag);
		level.avo_spawn_points[level.avo_spawn_points.size] = self;
	}
}

function avo_spawn_logic()
{
	//ADD: add endon for possible events that may require avos spawn to stop
	level endon("intermission");

	if(IsDefined(level.avo_spawn_debug) && level.avo_spawn_debug)
	{
		level waittill("start_of_round");
		level thread spawn_avo();
	}

	level.next_avo_round = level.avo_first_round;
	avo_debug("avo spawn round:"+level.next_avo_round);
	while(1)
	{
		level waittill("start_of_round");
		if( isdefined(level.round_number) && isdefined(level.next_avo_round) && level.round_number == level.next_avo_round && isdefined(level.CurrentGameMode) && level.CurrentGameMode != "zm_gungame")
		{
			if(isdefined(level.next_dog_round) && level.next_dog_round == level.next_avo_round)
			{
				avo_debug("Dog round in progress, spawn avo next round");
				level.next_avo_round = level.next_avo_round + 1;
				//level waittill("start_of_round");
				//level ();
			}

			else
			{
				sound::play_on_players("avo_prespawn");
				players = GetPlayers();
				player = array::random(players);
				if(isdefined(player))
				{
					player thread zm_project_e_ee::CustomPlayerQuote( "vox_plr_" +player GetCharacterBodyType() + "_avogadro_spawn_00" );
				}
				
				level spawn_avo();
				avo_debug("Spawning avogadro");
				level.next_avo_round = level.round_number + level.avo_round_add;
				avo_debug("Next avo round will be:" +level.next_avo_round);
			}		
		}
	}
}

function spawn_avo( boss_fight_spawn = false, override_wait = false )
{
	level.avos_alive++;
	spawner = GetEnt( "zombie_avogadro","script_noteworthy" );
	if(!IS_TRUE(override_wait))
	{
		wait(RandomIntRange(5,15));
	}

	avo_debug("Spawning Avogadro");

	if(IS_TRUE(boss_fight_spawn))
	{
		valid_spawn = undefined;

		spawn_points = level.avo_spawn_points;
		for(i = 0; i < spawn_points.size; i++)
		{
			if(isdefined(spawn_points[i].script_string) && spawn_points[i].script_string == "zone_boss")
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
		avo_debug("Unable to spawn Avogadro");
		level.avos_alive--;
		return;
	}
	if(level flag::exists("dog_round") && level flag::get("dog_round"))
	{
		avo_debug("Avogadro unable to spawn due to dog round");
		level.avos--;
		level.next_avo_round = level.round_number + 1;
		return;
	}
	//ADD!
	//playerssound("avo_bells");
	wait(5);
	//playerssound("avo_amb_0" +RandomIntRange(0,8));

	//SETTING UP avo STATS
	avo = zombie_utility::spawn_zombie(spawner);
	avo thread zombie_spawn_init();
	avo thread handleAttack();
	avo thread noteTracker();
	avo thread newDeath();
	avo thread watchHealth();
	avo thread zombie_utility::round_spawn_failsafe();
	
	//avo Health Stuff
	avo.health = level.avo_health;
	avo.allowdeath = false;

	avo.death_anim = %ai_t6_avo_exit;
	avo BloodImpact( "none" ); 
	avo.no_damage_points = true; 
	avo.allowpain = false; 
	avo.ignoreall = true; 
	avo.ignoreme = true; 
	avo.allowmelee = false; 
	avo.needs_run_update = true; 
	avo.no_powerups = true; 
	avo.canattack = false; 
	avo DetachAll(); 
	avo.goalRadius = 32; 
	avo.is_on_fire = true; 
	avo.gibbed = true; 
	avo.variant_type = 0; 
	avo.zombie_move_speed = "run"; 
	avo.zombie_arms_position = "down"; 
	avo.ignore_nuke = true; 
	//avo.instakill_func = &avo_anti_instakill; 
	avo.ignore_enemy_count = true; 
	avo PushActors( true );
	avo.lightning_chain_immune = true; 
	avo.tesla_damage_func = &new_tesla_damage_func; 
	avo.thundergun_fling_func = &new_thundergun_fling_func; 
	avo.thundergun_knockdown_func = &new_knockdown_damage; 
	avo.is_boss = true;
	avo.b_immune_to_flogger_trap = true;
	avo.b_ignore_cleanup = true;
	avo.b_immune_to_acid_trap = true;
	avo.ignore_zombie_lift	= 1;

	avo ForceTeleport( spot.origin, spot.angles, 1 ); 
	avo AnimScripted( "note_notify", avo.origin, avo.angles, %ai_t6_avo_pain_long ); 
	//PlayFX( avo_SPAWN_FX, avo.origin ); 
	PlaySoundAtPosition( "avo_spawn", avo.origin);
	//Earthquake( 0.4, 4, avo.origin, 5000 ); 
	wait(GetAnimLength(%ai_t6_avo_pain_long)); 

	avo thread custom_find_flesh();
	avo thread AvoLoopSoundFX();
	avo thread TeleportNearPlayers();
	avo HideAvo();
	//avo thread zm_spawner::zombie_follow_enemy();
	//level thread zm_behavior::zombieFindFleshCode( avo );
	//avo thread watch_near_players();

	avo_debug("avos alive:" +level.avos_alive);
}

function SpawnAvoAtPosition( position )
{
	level.avos_alive++;
	spawner = GetEnt("zombie_avogadro","script_noteworthy");
	
	avo_debug("Spawning Avogadro");

	spot = position;

	if(!isdefined(spot))
	{
		avo_debug("Unable to spawn Avogadro");
		level.avos_alive--;
		return;
	}
	
	avo = zombie_utility::spawn_zombie(spawner);
	avo thread zombie_spawn_init();
	avo thread handleAttack();
	avo thread noteTracker();
	avo thread newDeath();
	avo thread watchHealth();
	avo thread zombie_utility::round_spawn_failsafe();
	
	//avo Health Stuff
	avo.health = level.avo_health;
	avo.allowdeath = false;

	avo.death_anim = %ai_t6_avo_exit;
	avo BloodImpact( "none" ); 
	avo.no_damage_points = true; 
	avo.allowpain = false; 
	avo.ignoreall = true; 
	avo.ignoreme = true; 
	avo.allowmelee = false; 
	avo.needs_run_update = true; 
	avo.no_powerups = true; 
	avo.canattack = false; 
	avo DetachAll(); 
	avo.goalRadius = 32; 
	avo.is_on_fire = true; 
	avo.gibbed = true; 
	avo.variant_type = 0; 
	avo.zombie_move_speed = "run"; 
	avo.zombie_arms_position = "down"; 
	avo.ignore_nuke = true; 
	//avo.instakill_func = &avo_anti_instakill; 
	avo.ignore_enemy_count = true; 
	avo PushActors( true );
	avo.lightning_chain_immune = true; 
	avo.tesla_damage_func = &new_tesla_damage_func; 
	avo.thundergun_fling_func = &new_thundergun_fling_func; 
	avo.thundergun_knockdown_func = &new_knockdown_damage; 
	avo.is_boss = true;
	avo.b_immune_to_flogger_trap = true;
	avo.b_ignore_cleanup = true;
	avo.b_immune_to_acid_trap = true;
	avo.ignore_zombie_lift	= 1;

	avo ForceTeleport( spot.origin, spot.angles, 1 ); 
	avo AnimScripted( "note_notify", avo.origin, avo.angles, %ai_t6_avo_pain_long ); 
	//PlayFX( avo_SPAWN_FX, avo.origin ); 
	PlaySoundAtPosition( "avo_spawn", avo.origin);
	//Earthquake( 0.4, 4, avo.origin, 5000 ); 
	wait(GetAnimLength(%ai_t6_avo_pain_long)); 

	avo thread custom_find_flesh();
	avo thread AvoLoopSoundFX();
	avo thread TeleportNearPlayers();
	avo HideAvo();
	//avo thread zm_spawner::zombie_follow_enemy();
	//level thread zm_behavior::zombieFindFleshCode( avo );
	//avo thread watch_near_players();

	avo_debug("avos alive:" +level.avos_alive);
}

function HideAvo()
{
	//self.allowdeath = false;
	self.avo_take_damage = false;
	self Hide();
	//self clientfield::set( "avo_hidden_fx" , 1 );
	if(!isdefined(self.fxmodel))
	{
		self.fxmodel = Spawn("script_model", self GetTagOrigin("j_spine4"));
		self.fxmodel SetModel("tag_origin");
		self.fxmodel EnableLinkTo();
		self.fxmodel LinkTo(self);
		self.fxmodel clientfield::set("avo_hidden_fx", 1);
		//PlayFXOnTag(FX_AVO_LOOP, self.fxmodel, "tag_origin");
	}

	PlaySoundAtPosition("avo_warp_out", self.origin);
}

function ShowAvo()
{
	if(isdefined(self.fxmodel))
	{
		self.fxmodel clientfield::set("avo_hidden_fx", 1);
		self.fxmodel Delete();
	}

	PlaySoundAtPosition("avo_warp_in", self.origin);

	self Show();
	self.avo_take_damage = true;
	
	//self clientfield::set( "avo_hidden_fx" , 0);
	//self.allowdeath = true;
}

function AvoLoopSoundFX()
{
	self PlayLoopSound("avo_loop");
	PlayFXOnTag(FX_AVO_LOOP, self, "j_spine4");
	self waittill("death");
	self StopLoopSound(1);
}

function favorite_enemy_override()
{
	self endon("death");
	level endon("intermission");

	while(1)
	{
		closest = zombie_utility::get_closest_valid_player( self );
		if(!isdefined(closest))
		{
			continue;
		}

		if(closest != self.favoriteenemy)
		{
			self.favoriteenemy = closest;
		}

		wait(1);
	}
}

function custom_find_flesh()
{
	self endon("death");
	level endon("intermission");

	while(1)
	{
		if(isDefined(self.avo_enemy) && zm_utility::is_player_valid(self.avo_enemy) && isDefined(self.avo_enemy.avo_track_countdown) && self.avo_enemy.avo_track_countdown > 0 && !self.avo_enemy laststand::player_is_in_laststand() )
		{
			self.avo_enemy.avo_track_countdown -=0.05;
			self.v_zombie_custom_goal_pos = self.avo_enemy.origin; 
		}
		else
		{
			WAIT_SERVER_FRAME;
			players = GetPlayers();
			targets = array::get_all_closest(self.origin, players);
			for(i = 0; i < targets.size; i++)
			{
				WAIT_SERVER_FRAME;
				if( zm_utility::is_player_valid(targets[i]) && !IS_TRUE(targets[i].in_afterlife) )
				{
					self.avo_enemy = targets[i];
					self.v_zombie_custom_goal_pos = self.avo_enemy.origin; 

					if( !isDefined(targets[i].avo_track_countdown) )
						targets[i].avo_track_countdown = 2; 
					if( isDefined(targets[i].avo_track_countdown) && targets[i].avo_track_countdown <= 0 )
						targets[i].avo_track_countdown = 2; 
					break; 
				}
			}
		}
		wait(.05);
	}
}

function avo_pathing()
{
	self endon( "death" );
	while ( 1 )
	{
		WAIT_SERVER_FRAME;
		if( IsDefined( self.avo_enemy ) )
		{
			self.ignoreall = false;
			self OrientMode( "face default" );
			self SetGoalPos( self.avo_enemy.origin );
		}

		util::wait_network_frame();
	}
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


function handleAttack()
{
	self endon("death");
	if(!isdefined(self))
		return;

	self.melee_attack = false;
	self.range_attack = false;
		
	while(1)
	{

		if(Distance2D(self.avo_enemy.origin, self.origin) < 550 && BulletTracePassed( self.origin, self.avo_enemy.origin, 0, self ) && !IS_TRUE(self.avo_enemy.has_zombie_blood) && !IS_TRUE(self.avo_enemy.in_afterlife))
		{
			//random = RandomIntRange(1, 99);
			if(!IS_TRUE(self.range_attack) && !IS_TRUE(self.melee_attack))
			{
				self.range_attack = true;
				self AnimScripted( "note_notify", self.origin, self.angles, %ai_t6_avo_ranged_attack );
				self thread SpawnAvoProjectile( self.avo_enemy );
				wait( GetAnimLength(%ai_t6_avo_ranged_attack) );
				self AnimScripted( "note_notify", self.origin, self.angles, %ai_t6_avo_ranged_attack_end );
				wait( GetAnimLength(%ai_t6_avo_ranged_attack_end) + 1);
				self HideAvo();
				wait(level.AvoShootCooldown);
				self.range_attack = false;

			}

			else
			{
				avo_debug("Avo don't shoot");
				wait(RandomIntRange(3,6));
			}
		}

		if(Distance2D(self.avo_enemy.origin, self.origin) < 100 && BulletTracePassed( self.avo_enemy.origin, 0, self.origin, self, self.avo_enemy ) && !self.avo_enemy.has_zombie_blood)	//if(Distance2D(self.avo_enemy.origin, self.origin) < 75 && BulletTracePassed( self.avo_enemy.origin, self.origin, 0, self, self.avo_enemy ))
		{
			if( !IS_TRUE(self.melee_attack) && !IS_TRUE(self.range_attack) )
			{
				self ShowAvo();
				self.melee_attack = true;
				self AnimScripted( "note_notify", self.origin, self.angles, %ai_t6_avo_melee );
				wait(GetAnimLength(%ai_t6_avo_melee) + 1);
				self.melee_attack = false;
				self HideAvo();
			}
			
		}
		wait(0.05);
	}
	
}

function IsFacing(target)	//Some damn high level vector math here, self = avogadro, target = player
{
	avoAngles = self GetAngles();
	forwardVec = AnglesToForward( avoAngles );
	unitForwardVec = VectorNormalize( forwardVec );
	avoPos = self.origin;
	targetPos = target GetOrigin();
	avoToPlayerV = avoPos - targetPos;
	avoToPlayerUnitV = VectorNormalize( avoToPlayerV );
	forwardDot = VectorDot( unitForwardVec, avoToPlayerUnitV );
	angleFromCenter = ACos( forwardDot ); 
	avoFOV = 65;
	FOVBuffer = 0.2;

	avoCanSee = ( angleFromCenter <= ( avoFOV * 0.5 * ( 1 - FOVBuffer ) ) );
	return avoCanSee;
}

function SpawnAvoProjectile( enemy )
{
	if(!isdefined(enemy))
		return;

	self waittill("note_notify", note);

	if(!isdefined(note))
		return;

	if(note == "fire")
	{
		self ShowAvo();
		rand = RandomInt(3);
		self PlaySound("avo_attack_0" + rand);
		
		projectile = Spawn("script_model", self GetTagOrigin("j_wrist_ri"));
		projectile SetModel("tag_origin");
		projectile util::deleteAfterTime( 5 );
		end_pos = enemy GetEye();
		if(!isdefined(end_pos))
		{
			projectile Delete();
			return;
		}
		//v_forward = AnglesToForward(projectile GetAngles());
		//end_pos = (v_forward[0] * level.avo_projectile_dist, v_forward[0] * level.avo_projectile_dist, v_forward[0] * level.avo_projectile_dist);
		PlayFXOnTag(FX_AVO_PROJECTILE, projectile, "tag_origin");
		trace = BulletTrace(projectile.origin, end_pos, false, self);
		projectile_target = trace["position"];

		if(!isdefined(projectile_target))	//Check to see if this fixes random issues with projectiles not disappearing
		{
			projectile Delete();
			return;

		}

		projectile MoveTo( projectile_target, (Distance( projectile.origin, projectile_target ) / level.AvoProjectileSpeed) );
		projectile waittill("movedone");
		projectile WatchNearPlayers( self );
	}
}

function WatchNearPlayers( attacker )
{
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(Distance(self.origin, players[i] GetEye()) < 70 )
		{
			players[i] PlaySound( "wpn_tesla_bounce" );
			players[i] DoDamage( level.AvoProjectileDamage, players[i].origin, attacker );
			players[i] SetElectrified( 1.5 );	
			players[i] ShellShock("electrocution", 1.5);
			//self notify("movedone");
		}
	}

	self Delete();
}

function noteTracker()
{
	self endon("death");

	while(1)
	{
		self waittill("note_notify", note);
		if(!isdefined(note))
			return;
			
		if(note == "fire" && IS_TRUE(self.melee_attack))
		{
			//chance =  RandomIntRange(0,3); 
			//PlaySoundAtPosition( "avo_whoosh", self.origin ); 
			//self PlaySound( "avo_attack_0"+chance); 
			 
			players = GetPlayers(); 
			foreach( player in players )
			{
				if( Distance2D(player.origin, self.origin) < 80 && self.favoriteenemy == player )
				{
					Earthquake( .25, 3, player.origin, 50 ); 
					player SetElectrified( 1.0 );	
					player ShellShock( "electrocution", 1.0 );
					player DoDamage( level.AvoMeleeDamage, player.origin, self ); 
					player PlaySound("avo_attack_00");
				}
			}
		}
	}
}

function newDeath()
{
	self waittill("death");
	level.avos_alive--;
	avo_debug("avo dead");
	if(!IS_TRUE(level.lightning_collected))
	{
		//level.first_avo = false;
		pow_origin = self.origin + (0, 0, 30);
		level thread zm_project_e_ee::SpawnLightningRock( pow_origin );
	}
	
	clone = Spawn("script_model", self.origin);
	clone.angles = self.angles;
	clone SetModel("t6_avogadro");
	self Hide();
	clone UseAnimTree(#animtree);
	clone AnimScripted( "placeholder", clone.origin, clone.angles, %ai_t6_avo_exit );
	clone PlaySound("avo_death");
	wait(GetAnimLength(%ai_t6_avo_exit));
	self Delete();
	clone Delete();
}

function watchHealth()
{
	self endon("death");
	while(1)
	{
		self waittill( "damage", amount, attacker, direction_vec, point, type, tagName, ModelName, Partname, weapon );
		if(IsPlayer(attacker) && type == "MOD_MELEE" && self.avo_take_damage)
		{
			if(!isdefined(self.avodamagetaken))
			{
				self.avodamagetaken = 0;
			}

			melee_weapon = attacker zm_utility::get_player_melee_weapon();

			if(melee_weapon == GetWeapon("bowie_knife") || melee_weapon == GetWeapon("bowie_knife_widows_wine"))
			{
				self.avodamagetaken = self.avodamagetaken + 1;
				WAIT_SERVER_FRAME;
			}

			self.avodamagetaken = self.avodamagetaken + 1;

			attacker show_hit_marker();


			avo_debug("Knifed:" +self.avodamagetaken);
			if(self.avodamagetaken >= 4)
			{
				attacker zm_score::add_to_player_score( 500 );
				attacker thread zm_project_e_ee::CustomPlayerQuote( "vox_plr_" +attacker GetCharacterBodyType() + "_avogadro_kill_00" );
				self.allowdeath = true;
				self DoDamage(self.health + 666, self.origin);
			}

			else
			{
				self PlaySound("avo_pain_0" + RandomInt(3));
			}

			self.avo_take_damage = false;
			
			//self.allowdeath = false;
		}
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
	}	
}


function chooseSpawn( enemy )
{
	if(!isdefined(enemy))
	{
		players = GetPlayers();
		players = array::randomize( players );
		player = players[0];
	}

	else 
	{
		player = enemy;
	}
	
	valid_points = [];
	spawns = level.avo_spawn_points;

	if(!isdefined(spawns))
	{
		avo_debug("No engineer spots are init");
	}

	for(i = 0; i < spawns.size; i++)
	{
		is_valid = zm_utility::check_point_in_enabled_zone( spawns[i].origin );
		if(IS_TRUE(is_valid))
		{
			valid_points[valid_points.size] = spawns[i];
		}
	}

	option = ArrayGetClosest(player.origin, valid_points);
	return option;
}

function TeleportNearPlayers()
{
	self endon("death");
	level endon("intermission");

	while(1)
	{
		WAIT_SERVER_FRAME;
		wait(level.avo_teleport_cooldown);
		enemy = self.avo_enemy;
		if(!isdefined(enemy))
			continue;

		spawn = ChooseSpawn( enemy );

		if(!isdefined(spawn))
			continue;

		if(Distance(self.origin, enemy.origin) > 1000 && Distance(self.origin, enemy.origin) > Distance(enemy.origin, spawn.origin))
		{
			//IPrintLnBold("Teleported avo");
			self ForceTeleport(spawn.origin);
			//self.angles = spawn GetAngles();
		}
	}
}

function playerssound(string)
{
	players = GetPlayers();
	for(i = 0; i<players.size; i++)
	{
		players[i] PlayLocalSound(string);
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

function avo_anti_instakill( player, mod, hit_location )
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