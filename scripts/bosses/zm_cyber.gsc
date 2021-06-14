/*
Cyberdemon from Doom 2016 (also the boss fight of Project Elemental)
Script made by ihmiskeho

Credits:
DTZxPorter = Tools like Wraith, Kronos, and Wraith Reverant, L3ak Mod for lua
HarryBO21 = A lot of Script Help, perks, weapon porting tuts
Abnormal202 = Random Script Help
Collie = Conversion Rig
(EmpGeneral = Origins Announcer)
Verk0 = Radiant Help
MakeCents = Script stuff
Deanford = Radiant Help
NINJAMAN829 = PPSh & Mark3 sounds
Matarra = Script Help
DuaLVII = tools & script help
Erthrock = Character and Zombie models
Mathfag = Script help
TheSkyeLord = PKM weapon
Scobalula = Dual Render scopes and useful tools/tuts
Jr Rizzo = Shadowman vox (DLC4)
BluntStuffy = A lot of script help since WaW days
Idogftw = Afterlife help
DrLilRobot = Script Help
Cornrow Wallace = Useful streams, Radiant Help
Ducky = Random Starting weapon
Ardivee = Mud script, tutorials
The Black Death = Weapon sound template
DarkS0uls54 = Announcer sound aliases from his release https://aviacreations.com/modme/index.php?view=topic&tid=1483#
Symbo = Script Help, Point share script
Speedy= T7-T7 rig used in some BO3 weapons

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
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\zm\zm_cutscene;
#using scripts\shared\clientfield_shared;
#using scripts\bosses\zm_ai_reverant;
#using scripts\zm\zm_project_e_music;

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

//7.11.17 ADDED ZOMBIE BLOOD
#using scripts\_NSZ\nsz_powerup_zombie_blood;

#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using_animtree( "generic" ); 

#namespace zm_cyber; 

#precache( "model", "zm_zod_magic_circle_vis_glow" );
#precache( "model", "p7_fxanim_zm_zod_summoning_key_mod_obj" );
#precache("model", "p7_fxanim_zm_zod_summoning_key_mod" );

#define FX_SWARM_PROJECTILE									"fire/fx_fire_trail_destruct_sm"
#precache( "fx", FX_SWARM_PROJECTILE ); 
#precache( "fx", "explosions/fx_prop_exp");
#precache( "fx", "bosses/cyber_glow");
#precache( "fx", "zombie/fx_ritual_gatestone_explosion_zod_zmb");
#precache( "fx", "bosses/cyber_shield");
#precache( "fx", "weapon/fx_trail_rocket_md");
#precache("fx", "zombie/fx_ee_keeper_beam_a_success_zod_zmb");

#define CYBER_HEALTH 			200000
#define CYBER_FIGHT_SEGMENTS	4
#define CYBER_SWARM_DAMAGE		100
#define CYBER_SHIELD_DURATION	60

#define FX_EXP_GRENADE_EXP  			"explosions/fx_prop_exp"
#define FX_CYBER_GLOW				"bosses/cyber_glow"
#define FX_RITUAL_GATESTONE_EXPLOSION_ZOD_ZMB	"zombie/fx_ritual_gatestone_explosion_zod_zmb"
#define FX_CYBER_SHIELD				"bosses/cyber_shield"
#define FX_TRAIL_ROCKET_MD			"weapon/fx_trail_rocket_md"
#define FX_SUMMONING_KEY_BEAM		"zombie/fx_ee_keeper_beam_a_success_zod_zmb"

function init()
{
	//=============Cyber variables===============
	level.cyber_debug = false;				// Debug
	level.cyber_spawn_debug = false;		// Debug
	level.cybergroundHitDamage = 80;		// Cyber ground slam damage
	//=============Cyber variables===============

	level.cyber_alive = 0;
	level.octobomb_targets = &remove_cyber;
	level.key_chest = [];

	level.boss_music_ent = undefined;
	level.current_song = undefined;

	clientfield::register( "scriptmover", "cyber_shield_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "cyber_swarm_explode", VERSION_TU12, 1, "counter" );
	clientfield::register( "scriptmover", "cyber_ground_explode", VERSION_TU12, 1, "counter" );

	zm_spawner::add_custom_zombie_spawn_logic( &BossSoulChest );	

	thread main();
}

function cyber_debug( string )
{
	if(IsDefined(level.cyber_debug) && level.cyber_debug)
	IPrintLnBold("^1DEBUG: ^7" +string );
	
}

function main()
{
	WAIT_SERVER_FRAME;
	level flag::wait_till("all_players_connected");

	level.damageOverrideWeapons = [];
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("iw6_mk32_up");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("iw8_1911_rdw_up");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("iw8_1911_ldw_up");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("bo3_mark2");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("bo3_mark2_upgraded");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("h1_rpg7_up");
	level.damageOverrideWeapons[level.damageOverrideWeapons.size] = GetWeapon("t6_makarov_upgraded");
}

function BossFightKillEnemies()
{
	lui::screen_flash( 0.2, 0.5, 1.0, 0.8, "white" ); // flash

	zombies = GetAITeamArray("axis");
	for(i = 0; i < zombies.size; i++)
	{
		wait(RandomFloatRange(0.3, 0.6));
		if(IS_TRUE(zombies[i].is_boss))
			zombies[i].allowDeath = true;

		zombies[i] DoDamage(zombies[i].health + 666, zombies[i].origin);
	}

	level flag::clear( "spawn_zombies" );
	level flag::clear( "zombie_drop_powerups" );

	// TODO: Could find a better way for an unlimited round
	level.zombie_vars["zombie_between_round_time"] = 0; 	// remove the delay at the end of each round 
	level.zombie_round_start_delay = 0;						// remove the delay before zombies start to spawn
}

function remove_cyber( ai )
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

function SpawnCyber()
{
	spot = GetEnt("cyber_spawn_point","targetname");
	if(!isdefined(spot))
	{
		IPrintLnBold("Spot not defined!!!");
		return;
	}

	level.cyber_spawn_point = Spawn("script_model", spot.origin);
	level.cyber_spawn_point SetModel("tag_origin");
	//level.cyber_spawn_point.angles = spot.angles;

	cyber = Spawn("script_model", spot.origin);
	cyber SetModel("doom_cyberdemon");
	cyber.angles = spot.angles;
	cyber EnableLinkTo();
	cyber UseAnimTree(#animtree);

	cyber.aim_model = Spawn("script_model", cyber.origin);
	cyber.aim_model SetModel("tag_origin");
	cyber.aim_model.angles = spot.angles;
	cyber.aim_model EnableLinkTo();
	cyber LinkTo(cyber.aim_model);

	//Cyber Health
	players = GetPlayers();
	players_size = players.size;
	cyber.health = CYBER_HEALTH * players.size;
	cyber.can_attack = true;
	cyber Solid();

	util::playSoundOnPlayers("vox_cyber_roar", undefined);

	cyber AnimScripted( "note_notify", cyber.origin, cyber.angles, %cyber_pain );
	Earthquake( 0.4, 4, cyber.origin, 5000 ); 
	wait(GetAnimLength(%cyber_pain)); 

	cyber SetCanDamage(1);
	PlayFXOnTag(FX_CYBER_GLOW, cyber, "j_spine4");

	//Threads
	cyber thread custom_find_flesh();
	
	cyber thread newDeath( spot );
	cyber thread watchHealth();
	level thread SpawnMaxAmmo();

	for(i = 0; i < players.size; i++)
	{
		players[i] thread KeepPlayerPerks();
	} 

	wait(2);
	cyber thread handleAttack();

	level flag::clear( "zombie_drop_powerups" );
	level.musicSystemOverride = 1;
	zm_project_e_music::cancel_ambient_music();	// Cancel underscore

	self thread MusicSetNonLooping( "mus_bossfight_intro" );
}

function custom_find_flesh()
{
	level endon("end_game");
	self endon("cyber_shield");
	origin = self.aim_model.origin;

	initial_wait = 2;
	wait(initial_wait);

	while(1)
	{
		if(isDefined(self.cyber_enemy) && zm_utility::is_player_valid(self.cyber_enemy) && isDefined(self.cyber_enemy.cyber_track_countdown) && self.cyber_enemy.cyber_track_countdown > 0 )	//7.1.17 ADDED ZOMBIE BLOOD
		{
			self.cyber_enemy.cyber_track_countdown -= 0.05;
			//self.v_zombie_custom_goal_pos = self.cyber_enemy.origin; 
		}
		else
		{
			//cyber_debug("Cyber Defining new target");
			players = GetPlayers();
			targets = array::get_all_closest(self.origin, players);
			for( i = 0; i < targets.size; i++ )
			{
				if( zm_utility::is_player_valid(targets[i]) && !(targets[i] laststand::player_is_in_laststand()) )
				{
					self.cyber_enemy = targets[i];
					//self.v_zombie_custom_goal_pos = self.cyber_enemy.origin; 

					//cyber_debug("new target selected");
					if( !isDefined(targets[i].cyber_track_countdown) )
						targets[i].cyber_track_countdown = 2; 
					if( isDefined(targets[i].cyber_track_countdown) && targets[i].cyber_track_countdown <= 0 )
						targets[i].cyber_track_countdown = 2; 
					break; 
				}
			}

			if( !isdefined(self.cyber_enemy) )
			{
				WAIT_SERVER_FRAME;
				continue;
			}
		}

		self AimAtEnemy( self.cyber_enemy );
		self.aim_model MoveTo(origin, 0.05);
		wait(0.05);
	}
	
}

function GetNewEnemy()
{
	players = GetPlayers();
	targets = array::get_all_closest(self.origin, players);
	for(i = 0; i < targets.size; i++)
	{
		if(zm_utility::is_player_valid(targets[i]) && !targets[i].has_zombie_blood && !targets[i] laststand::player_is_in_laststand())
		{
			self.cyber_enemy = targets[i];

			if( !isDefined(targets[i].cyber_track_countdown) )
				targets[i].cyber_track_countdown = 2; 
			if( isDefined(targets[i].cyber_track_countdown) && targets[i].cyber_track_countdown <= 0 )
				targets[i].cyber_track_countdown = 2; 

			break; 
		}
	}

	return self.cyber_enemy;
}

function SpawnMaxAmmo()
{
	level endon("end_game");
	level endon("cutscene_start");

	struct = struct::get("boss_fight_powerup_struct", "targetname");
	if(!isdefined(struct) || struct.size <= 0)
	{
		return;
	}

	while(1)
	{
		zm_powerups::specific_powerup_drop( "full_ammo", struct.origin - (0, 0, 10));
		wait(RandomIntRange(80, 100));
	}

}

function KeepPlayerPerks()
{
	level endon("end_game"); //endon("");
	self endon("disconnect");

	self zm_utility::give_player_all_perks();

	while(1)
	{
		self util::waittill_any( "player_revived", "spawned_player");	//self waittill( "spawned_player" );
		if( isdefined(self) && IsAlive(self) )
		{
			self zm_utility::give_player_all_perks( true );
		}
	}
}

function AimAtEnemy( enemy )
{
	if(!isdefined(enemy))
	{
		enemy = self GetNewEnemy();
	}

	cyber_origin = self.origin;
	enemy_origin = enemy.origin;
	cyber_angles = self GetAngles();

	new_face_direction = VectortoAngles( enemy_origin - cyber_origin );

	self.aim_model RotateTo((cyber_angles[0], new_face_direction[1], cyber_angles[2]), 0.1);
	wait(0.1);
}

function degree_from_player( player )
{
	if(!isdefined(player))
	{
		player = self GetNewEnemy();
	}

	cyber_angles = self GetAngles();
	cyber_forward_vec = AnglesToForward(cyber_angles);
	cyber_forward_unitvec = VectorNormalize(cyber_forward_vec);

	cyber_pos = self.origin;
	player_pos = player.origin;
	cyber_to_player_vec = player_pos - cyber_pos;
	cyber_to_player_unitvec = VectorNormalize(cyber_to_player_vec);

	forward_dot_cyber = VectorDot( cyber_forward_unitvec, cyber_to_player_unitvec );
	angle_from_center = ACos(forward_dot_cyber);

	//IPrintLn("Cyber is " +angle_from_center + "degrees from straight ahead");

	return angle_from_center;
}

function handleAttack()
{
	if(!isdefined(self))
		return;
		
	prev_index = 0;

	// Don't attack instanty on sight
	init_wait = 2;
	wait( init_wait );
		
	for(;;)
	{
		WAIT_SERVER_FRAME;
		if( !isdefined(self.cyber_enemy) )
			continue;

		if( !self.cyber_enemy.has_zombie_blood && !IS_TRUE(self.shield_enabled) && IS_TRUE(self.can_attack) )	// if(Distance2D(self.cyber_enemy.origin, self.origin) < 75 && BulletTracePassed( self.cyber_enemy.origin, self.origin, 0, self, self.cyber_enemy ))
		{
			PlaySoundAtPosition("vox_cyber_amb", self.origin);
			random = RandomIntRange(0, 3);
			if( random == prev_index )	// V2 Edit: Don't repeat attacks
				continue;

			switch(random)
			{
				case 0:
					self RocketAttack();
					prev_index = 0;
					break;

				case 1:
					self SwarmAttack();
					prev_index = 1;
					break;

				case 2:
					self GroundSlamAttack();
					prev_index = 2;
					break;

				default:
					self RocketAttack();
					prev_index = 0;
					break;
			}

			// Attempt to fix misalingment of the boss due to anims, forcing the boss teleport to the spawn point
			if(isdefined(level.cyber_spawn_point))
			{
				self.aim_model MoveTo(level.cyber_spawn_point.origin, 0.3);
				self.aim_model waittill("movedone");
				self AnimScripted("note_notify", self.origin, self.angles, %cyber_idle);
				self.can_attack = true;
			}
			wait(5);

		}
	}
}

function RocketAttack()
{
	self.can_attack = false;	// Disabling anims
	rand = RandomIntRange(2,5);

	self AnimScripted("note_notify", self.origin, self.angles, %cyber_aim_in);
	wait(GetAnimLength(%cyber_aim_in));

	for(i = 0; i < rand; i++)
	{
		WAIT_SERVER_FRAME;
		self AnimScripted( "note_notify", self.origin, self.angles, %cyber_bfb_fire );
		self thread FireRocket( self.cyber_enemy );
		self PlaySound("cyber_rocket_fire");
		wait(GetAnimLength(%cyber_bfb_fire));
	}
	
	self AnimScripted("note_notify", self.origin, self.angles, %cyber_aim_out);
	wait(GetAnimLength(%cyber_aim_out));
	// self.can_attack = true;
}

function BladeAttack()	// Obsolete
{
	self.can_attack = false;

	self AnimScripted("note_notify", self.origin, self.angles, %cyber_scythe_fire);

	self thread SpawnBladeProjectile();

	wait(GetAnimLength(%cyber_scythe_fire));

	// self.can_attack = true;
}

function GroundSlamAttack()
{
	self.can_attack = false;
	self AnimScripted("note_notify", self.origin, self.angles, %cyber_slam);
	enemy = self.cyber_enemy;
	if(!isdefined(enemy))
	{
		return;
	}

	origin = enemy.origin + ( 0, 0, 2 );
	fxmodel = Spawn("script_model", origin);
	fxmodel SetModel("zm_zod_magic_circle_vis_glow");
	fxmodel SetScale(1.2);
	fxmodel RotateYaw(1080, 3);
	wait(GetAnimLength(%cyber_slam));

	self AnimScripted("note_notify", self.origin, self.angles, %cyber_slam_out);
	model = Spawn("script_model", origin);
	model SetModel("tag_origin");
	Earthquake( 0.4, 4, origin, 5000 );
	model DamageNearPlayers( 190, 100, self );

	PlaySoundAtPosition("cyber_ground_slam_explosion", origin);
	model clientfield::increment("cyber_ground_explode");

	WAIT_SERVER_FRAME;
	model Ghost();
	fxmodel Delete();

	grenade1 = self MagicGrenadeType( GetWeapon("cyber_grenade"), model.origin, (130,0,450));
	grenade2 = self MagicGrenadeType( GetWeapon("cyber_grenade"), model.origin, (0,100,450));
	grenade2 = self MagicGrenadeType( GetWeapon("cyber_grenade"), model.origin, (-130,0,450));

	grenade1 thread DamageOnDetonate( self );
	grenade2 thread DamageOnDetonate( self );
	grenade2 thread DamageOnDetonate( self );

	wait(GetAnimLength(%cyber_slam_out));
	if(isdefined(model))
		model Delete();

	// self.can_attack = true;
}

function DamageOnDetonate( attacker )	//self = grenade
{
	origin = undefined;
	self waittill("grenade_bounce" );

	origin = self.origin;
	if(isdefined(origin))
	{
		self Detonate();
		players = GetPlayers();
		foreach( player in players )
		{
			WAIT_SERVER_FRAME;
			if(Distance(origin, player.origin) < 80)
			{
				player DoDamage( 20, player.origin, attacker );
				player thread BurnScreen( 1.5 );
			}
		}	
	}	
}

function BurnScreen( time )
{
	if(!isdefined(time))
		return;

	self clientfield::set( "burn", 1  );	//on
	wait(time);
	self clientfield::set( "burn", 0  );	//on
}

function SwarmAttack()
{
	self.can_attack = false;
	self AnimScripted("note_notify", self.origin, self.angles, %cyber_swarm_in);
	wait(GetAnimLength(%cyber_swarm_in));

	//Spawn fx and other stuff here
	points = struct::get_array("cyber_swarm_point","targetname");
	if(!isdefined(points))
	{
		IPrintLnBold("NO SWARM POINTS FOUND!");
		return;
	}

	foreach(point in points)
	{
		point thread SpawnSwarmFx();
		self PlaySound("cyber_swarm_projectile");
	}

	wait(2);
	self AnimScripted("note_notify", self.origin, self.angles, %cyber_swarm_loop);
	foreach (point in points)
	{
		WAIT_SERVER_FRAME;
		self thread SpawnSwarmProjectile( point.origin );
	}

	wait(GetAnimLength(%cyber_swarm_loop));
	self AnimScripted("note_notify", self.origin, self.angles, %cyber_swarm_out);
	wait(GetAnimLength(%cyber_swarm_out));
	foreach(point in points)
	{
		if(isdefined(point.fxmodel))
		{
			point.fxmodel Delete();
		}
	}

	// self.can_attack = true;
}

function SpawnBladeProjectile()
{
	projectile = util::spawn_model("zm_zod_magic_circle_vis_glow", self GetTagOrigin("tag_weapon_right"));
	if(!isdefined(projectile))
		return;

	targetpos = self.cyber_enemy.origin;
	if(!isdefined(targetpos))
	{
		projectile Delete();
		return;
	}

	dir = targetpos - projectile.origin;
	max_pos = (dir[0] * 800, dir[1] * 800, dir[2] * 800);

	projectile thread PlayerImpactWatch();
	projectile MoveTo(max_pos, 2);
	projectile waittill("movedone");

	if(isdefined(projectile))
		projectile Delete();
}

function PlayerImpactWatch()
{
	self endon("death");
	self endon("delete");

	while(isdefined(self))
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		foreach(player in players)
		{
			if(player IsTouching(self))
			{
				self DamageNearPlayers( Int(player.health / 2), 100, self);
				return;
			}
		}
	}
}

function FireRocket( enemy )
{
	rocket_origin = self GetTagOrigin("j_index_le_2");
	rocket = Spawn("script_model", rocket_origin);
	if(!isdefined(rocket))
		return;

	if(!isdefined(enemy))
		enemy = ArrayGetClosest(self.origin, GetPlayers());

	rocket SetModel("cyber_rocket");
	WAIT_SERVER_FRAME;
	PlayFXOnTag(FX_TRAIL_ROCKET_MD, rocket, "tag_fx");
	vec = enemy GetEye() - rocket_origin;
	rocket_angles = VectortoAngles(vec);
	rocket.angles = rocket_angles;
	max_pos = (vec[0] * 10000, vec[1] * 10000, vec[2] * 10000);

	trace = BulletTrace(rocket_origin, max_pos, false, self);
	targetpos = trace["position"];
	rocket thread RocketImpactWatch( self );

	rocket MoveTo(targetpos, Distance(rocket.origin, targetpos) / 1200);
	rocket waittill("movedone");
	PlaySoundAtPosition("fire_explode_00", rocket.origin);
	rocket clientfield::increment("cyber_swarm_explode");
	WAIT_SERVER_FRAME;
	rocket Ghost();
	rocket util::delay( 0.25, undefined, &zm_utility::self_delete );
}

function RocketImpactWatch( attacker )
{
	self endon("death");

	while(isdefined(self))
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		closest = ArrayGetClosest(self.origin, players);
		if(Distance(closest GetEyeApprox(), self.origin) < 55)
		{
			damage_to_apply = (Int(closest.health / 2) + 30);
			closest DoDamage( damage_to_apply, closest.origin, attacker );
			self MoveTo(self.origin, 0.05);
			wait(0.05);
			break;
		}
	}
}

function SpawnSwarmProjectile( goalpos )	// Credit to redspace200 for this!
{
	if(!isdefined(goalpos))
	{
		return;
	}

	projectile = Spawn("script_model", self GetTagOrigin("j_spine4"));
	projectile util::deleteAfterTime( 5 );	// Failsafe to remove projectile
	projectile SetModel("tag_origin");
	WAIT_SERVER_FRAME;
	PlayFXOnTag(FX_SWARM_PROJECTILE, projectile, "tag_origin");

	startX = projectile.origin[0];
	startY = projectile.origin[1];
	startZ = projectile.origin[2];

	endX = goalpos[0];
	endY = goalpos[1];
	endZ = goalpos[2];

	byX = endX - startX;
	byY = endY - startY;
	byZ = endZ - startZ;

	time = 2;
	current_time = 0;

	anim_progress = 0;
	anim_max_progress = 100;

	anim_z_peak = 75;
	anim_z_offset = 300;

	increments = 0.065;

	for(i = 0; i < time; i+= increments)
	{
		anim_progress = map(i, 0, time, 0, anim_max_progress);

		dx = Linear(anim_progress, 0, byX, anim_max_progress + 1);
		dy = Linear(anim_progress, 0, byY, anim_max_progress + 1);
		dz = Linear(anim_progress, 0, byZ, anim_max_progress + 1);

		addZ = 0;

		if(anim_progress < anim_z_peak)
		{
			addZ = easeOutSine(anim_progress,0,anim_z_offset,anim_max_progress - (anim_max_progress - anim_z_peak) );
		}

		else
		{
			addZ = anim_z_offset - easeInSine(anim_progress-anim_z_peak,0,anim_z_offset,anim_max_progress-anim_z_peak);
		}

		x = startX + dx;
		y = startY + dy;
		z = startZ + dz + addZ;
		
		projectile MoveTo( (x,y,z), increments, 0, 0 );
	
		wait increments;
	}

	projectile PlaySound("fire_explode_00");
	projectile clientfield::increment("cyber_swarm_explode");
	WAIT_SERVER_FRAME;
	projectile Ghost();
	projectile DamageNearPlayers( CYBER_SWARM_DAMAGE, 100, self );
	projectile util::delay( 0.25, undefined, &zm_utility::self_delete );
}

function Linear( t, b, c, d )
{
	return c * t / (d - 1) + b;
}

function easeInSine(t, b, c, d) 
{
	return -c * cos(toRadian(t/d * (Math_PI()/2) ) ) + c + b;
}

function easeOutSine(t, b, c, d)
{
	return c * sin(toRadian(t/d * (Math_PI()/2) ) ) + b;
}

function Math_PI()
{
	return 3.14159265359;
}

function toRadian(degree)
{
	return degree * (180 / Math_PI() );
}

function map(input,lower1,upper1,lower2,upper2)
{
	return ( (input-lower1)*(upper2-lower2) ) / (upper1-lower1) + lower2;
}

function DamageNearPlayers( damage, distance = 50, attacker )
{
	if(!isdefined(damage))
	{
		damage = 100;
	}

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		WAIT_SERVER_FRAME;
		if(Distance(self.origin, players[i].origin) < distance)
		{
			players[i] DoDamage( damage, players[i].origin, attacker );
		}
	}
}

function SpawnSwarmFx()
{
	self.fxmodel = Spawn("script_model", self.origin);
	self.fxmodel SetModel("zm_zod_magic_circle_vis_glow");

	while(isdefined(self.fxmodel))
	{
		self.fxmodel RotateYaw(360, 1);
		wait(1);
	}
}

function newDeath( spot )
{
	self waittill("cyber_death");
	self.can_attack = false;
	level.cyber_alive--;
	level thread BossFightKillEnemies();
	
	level thread zm::spectators_respawn();
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] laststand::player_is_in_laststand() )
		{
			players[i] zm_laststand::auto_revive(players[i], 0);
		}

		WAIT_SERVER_FRAME;
		players[i] EnableInvulnerability();
		players[i] zm_utility::increment_ignoreme();
		players[i] thread FadeToBlack();
	}

	cyber_debug("cyber dead");
	self AnimScripted( "note_notify", self.origin, self.angles, %cyber_pain );
	wait(GetAnimLength(%cyber_pain));
	thread zm_cutscene::CutsceneInit( spot.origin, self.angles );
	wait(0.2);
	self Delete();
}

function watchHealth()
{
	players = GetPlayers();
	cyber_full_health = self.health;
	DamageInterval = cyber_full_health / CYBER_FIGHT_SEGMENTS;

	totalDamage = 0;
	threat_level = 1;
	while(1)
	{
		//self waittill("damage", amount, attacker);
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );

		// Reduce damage if it's a powerfull weapon, like mark2, rpg7
		if( IsDamageOverrideWeapon(w_weapon) )
		{
			totalDamage = totalDamage + Int(n_damage / 3);
			add = cyber_full_health - totalDamage;
			self.health = self.health + add;
		}

		else
		{
			totalDamage = totalDamage + n_damage;
		}

		// Plays the hitmarker for the attacker
		e_attacker show_hit_marker();

		if(totalDamage >= DamageInterval)
		{
			if(!IS_TRUE(self.can_attack))
			{
				while(!IS_TRUE(self.can_attack))
				{
					WAIT_SERVER_FRAME;
				}
			}

			if(IS_TRUE(self.key_used))
			{
				self notify("cyber_death");
				StopMusicForPlayers("mus_bossfight_loop_final", true, 1);
				return 0;
			}

			self.health = CYBER_HEALTH;
			self.shield_enabled = true;
			self PlaySound("vox_cyber_roar");
			self AnimScripted( "note_notify", self.origin, self.angles, %cyber_pain ); 
			wait( GetAnimLength(%cyber_pain) ); 
			cyber_debug("shield enabled");
			totalDamage = 0;
			self thread SpawnBossFightEnemies( threat_level );
			self CyberShield();
			self.shield_enabled = false;
			level BossFightKillEnemies();
			//zm_powerup_nuke::nuke_powerup( self, level.zombie_team );
			level SkipRound();

			threat_level++;

			StopMusicForPlayers(level.current_song, true, 2);
			if(threat_level < 4)
			{
				self thread MusicSetNonLooping( "mus_bossfight_" + (threat_level - 1) );
			}

			if(threat_level == 3)
			{
				self thread BossFightDogSpawns();
			}

			else if(threat_level == 4)
			{
				self thread SummoningKeySpawn();
				PlayMusicForPlayers("mus_bossfight_loop_final", true);
			}
		}
	}
}

function SummoningKeySpawn()		//self = cyber
{
	level endon("end_game");
	//level endon("cutscene_start");

	struct = struct::get("bossfight_key_spawn", "targetname");
	if(!isdefined(struct))
		return;

	model = Spawn("script_model", struct.origin);
	model SetModel("p7_fxanim_zm_zod_summoning_key_mod_obj");

	model.charged = false;

	model thread KeyRotate();
	level flag::set("spawn_zombies");

	self SetCanDamage(false);
	self clientfield::set("cyber_shield_fx", 1);

	trigger = Spawn("trigger_radius", model.origin, 0, 32, 32);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Hold ^3&&1 ^7To Place Artifact" );

	while(1)
	{
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			model SetModel( "p7_fxanim_zm_zod_summoning_key_mod" );
			PlayFXOnTag(level._effect["fx_tomb_elem_reveal_ice_glow"], model, "tag_origin");
			wait(1);
			self thread SpawnBossFightEnemies( 4 );
			break;
		}
	}

	trigger Delete();

	model Soulbox( 40 );

	model MoveZ(20, 1);
	model.charged = true;

	util::playSoundOnPlayers("egg_done_final", undefined);

	self clientfield::set("cyber_shield_fx", 0);

	model.fx = Spawn("script_model", model.origin + (0, 0, 25));
	model.fx SetModel("tag_origin");
	model.fx.angles = (0, 90, 0);

	WAIT_SERVER_FRAME;
	PlayFXOnTag(FX_SUMMONING_KEY_BEAM, model.fx, "tag_origin");

	model PlayLoopSound("tomahawk_loop");

	self SetCanDamage(true);
	self.key_used = true;
	self.health = CYBER_HEALTH / CYBER_FIGHT_SEGMENTS;

	level waittill("cutscene_start");

	if(isdefined(model))
		model Delete();

	if(isdefined(model.fx))
		model.fx Delete();

}

function KeyRotate()
{
	rotate_time = 1;
	while(isdefined(self))
	{
		if(IS_TRUE(self.charged))
			rotate_time = 0.5;

		self RotateYaw(360, rotate_time);
		wait(rotate_time);
	}
}

function Soulbox( required_kills )
{
	level.key_chest[level.key_chest.size] = self;

	self.kills = 0;
	self.max_kills = required_kills;
	self.soul_chest_done = false;

	while( !self.soul_chest_done )
	{
		WAIT_SERVER_FRAME;
	}

	self.soul_chest_done = true;
	ArrayRemoveValue(level.key_chest, self);
}

function SoulWaitForDeath( meteor )
{
	self waittill("death");
	if(!isdefined(meteor))
		return;

	if(IS_TRUE(meteor.soul_chest_done))
		return;

	if(Distance(self.origin, meteor.origin) < 600)
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
	}
}

function show_hit_marker()  // self = player
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

function SkipRound()
{
	level.zombie_total = 0;
	zombie_utility::ai_calculate_health( level.round_number + 1 );
	level notify("kill_round");
	level flag::clear( "spawn_zombies" );
}

function CyberShield()
{
	self notify("cyber_shield");
	self SetCanDamage(false);
	self clientfield::set("cyber_shield_fx", 1);

	wait(CYBER_SHIELD_DURATION);

	cyber_debug("shield disabled");
	self SetCanDamage(true);
	self clientfield::set("cyber_shield_fx", 0);
	self thread custom_find_flesh();
	Earthquake( 0.4, 4, self.origin, 5000 );
	lui::screen_flash( 0.2, 0.5, 1.0, 0.8, "white" ); // flash
	util::playSoundOnPlayers("zmb_bgb_abh_teleport_in", undefined);
}

function BossFightDogSpawns()
{
	self endon("cyber_death");
	self endon("cyber_shield");

	dog_spawns = GetBossFightDogSpawns();
	if(!isdefined(dog_spawns) || dog_spawns.size <= 0)
	{
		IPrintLnBold("No Dog Spawns Found in Boss Arena!");
		return;
	}

	while(!IS_TRUE(self.shield_enabled))
	{
		wait(RandomIntRange(3,6));
		CustomDogSpawn( array::random(dog_spawns) );
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

function SpawnBossFightEnemies( threat_level )
{
	self endon("cyber_death");
	
	spawn_bosses = false;

	level flag::set( "spawn_zombies" );

	if(threat_level >= 3)
	{
		spawn_bosses = true;
		if(threat_level >= 4)
		{
			level thread InfiniteSpawning();
		}
	}
		
	if(spawn_bosses)
	{
		index = 0;
		while(index < threat_level + 2)
		{
			wait(RandomIntRange(8,13));
			rand = RandomInt(3);
			switch(rand)
			{
				case 0:
					engineer::spawn_engineer( true, true );
					break;

				case 1:
					if(math::cointoss())
						zm_avogadro::spawn_avo( true, true );

					else
						zm_ai_reverant::sonic_zombie_spawn();
					break;

				case 2:
					zm_ai_reverant::sonic_zombie_spawn();
					break;

				default:
					engineer::spawn_engineer( true, true );
					break;
			}
			
			index++;
		}
	}
}

function InfiniteSpawning()
{
	level endon("cutscene_start");
	level endon("end_game");
	level endon("intermission");

	level flag::set( "spawn_zombies" );
	while( true )
	{
		level.zombie_total = 24;
		wait(.1);
	}
}

function GetBossFightDogSpawns()
{
	spawners = [];
	dog_locations = struct::get_array("dog_location", "script_noteworthy");
	for(i = 0; i < dog_locations.size; i++)
	{
		if( isdefined(dog_locations[i].targetname) && dog_locations[i].targetname == "zone_boss_spawners" )
		{
			spawners[spawners.size] = dog_locations[i];
		}
	}

	return spawners;
}

function FadeToBlack()
{
	self endon("intermission");
	time = 3;
	wait(1);
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

function BossSoulChest()	//V2, for collecting souls to meteors
{
	self endon( "delete" );
	self waittill( "death" );

	if( !isdefined(level.key_chest) )
		return;
	
	if ( !isdefined( self.attacker ) )
		return;
	
	chests = util::get_array_of_closest( self.origin, level.key_chest, undefined, undefined, 750 );
	
	if ( !isdefined( chests ) || chests.size < 1 )
		return;

	for ( i = 0; i < chests.size; i++ )
	{
		if(!IS_TRUE(self.soul_chest_done))
		{
			chests[ i ] SoulChestTakeSoul( self );
			break;
		}
	}
}

function SoulChestTakeSoul( zombie )	//self = meteor model
{
	if(!isdefined(zombie))
		return;

	soul = util::spawn_model("tag_origin", zombie.origin + (0, 0, 32) );
	WAIT_SERVER_FRAME;
	PlayFXOnTag(level._effect["fx_staff_charge_souls"], soul, "tag_origin");
	soul PlayLoopSound("soul_loop");

	soul MoveTo( self.origin, 1.25, .5, .25 );
	soul waittill("movedone");
	PlaySoundAtPosition("soul_collect_0" + RandomInt(2), soul.origin);

	if( !isdefined(self.max_kills) )
		self.max_kills = 40;

	if( isdefined(self.kills) )
	{
		self.kills++;
		if(self.kills >= self.max_kills)
		{
			self.soul_chest_done = true;
		}
	}

	else
	{
		self.kills = 1;
	}

	soul Delete();
}

// Check to see if this weapon needs it's damage reduced
function IsDamageOverrideWeapon( w_weapon )	// w_weapon = weapon object, the attackers current weapon
{
	if( !isdefined(w_weapon) )
		return false;

	if( !isdefined(level.damageOverrideWeapons) || level.damageOverrideWeapons.size < 1 )
		return false;

	for( i = 0; i < level.damageOverrideWeapons.size; i++ )
	{
		if( level.damageOverrideWeapons[i] == w_weapon )
		{
			return true;
		}
	}

	return false;
}

// Music stuff added in v2
function MusicSetNonLooping( str_sound )
{
	playBackTime = MusicGetPlaybackTime( str_sound );
	PlayMusicForPlayers( str_sound, false );
	self util::waittill_any_timeout( playBackTime, "cyber_shield" );
	StopMusicForPlayers( level.current_song, false );
	PlayMusicForPlayers( "mus_bossfight_loop", true );
}

function MusicGetPlaybackTime( str_sound )
{
	switch(str_sound)
	{
		case "mus_bossfight_intro":
			return 78;

		case "mus_bossfight_1":
			return 89;

		case "mus_bossfight_2":
			return 50;

		default:
			return 50;
	}
}

function PlayMusicForPlayers( str_sound, b_is_looping = false )
{
	if(!isdefined(str_sound))
		return;

	if(isdefined(level.boss_music_ent))
	{
		while(isdefined(level.boss_music_ent))
		{
			WAIT_SERVER_FRAME;
		}
	}

	level.boss_music_ent = Spawn( "script_origin", (0, 0, 0) );
	if(!isdefined(level.boss_music_ent))
		return;

	if(b_is_looping)
	{
		level.boss_music_ent PlayLoopSound( str_sound );
		/*players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			players[i] PlayLoopSound(str_sound);
		}*/
	}

	else
	{
		/*players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			players[i] PlayLocalSound(str_sound);
		}*/

		level.boss_music_ent PlaySound( str_sound );
	}

	level.current_song = str_sound;
}

function StopMusicForPlayers( str_sound, b_is_looping = false, n_fade = 1 )
{
	if(!isdefined(str_sound))
		return;

	if(!isdefined(level.boss_music_ent))
		return;

	if(b_is_looping)
	{
		/*players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			players[i] StopLoopSound( n_fade );
		}*/

		level.boss_music_ent StopLoopSound( n_fade );
		level.boss_music_ent util::delay( n_fade + 0.25, undefined, &zm_utility::self_delete );

	}

	else
	{
		/*players = GetPlayers();
		for(i = 0; i < players.size; i++)
		{
			players[i] StopSound(str_sound);
		}*/

		level.boss_music_ent StopSound( str_sound );
		level.boss_music_ent util::delay( 0.25, undefined, &zm_utility::self_delete );
	}

	level.current_song = undefined;
}