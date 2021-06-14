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
#using scripts\zm\zm_project_e_ee;

#insert scripts\shared\shared.gsh;

#precache("xmodel", "zom_body");
#precache("xmodel", "zom_head1");

#define FX_FIRE_ZOMBIE_EXP									"zombie/fx_dog_explosion_zmb"
#precache( "fx", FX_FIRE_ZOMBIE_EXP ); 

#define FX_FIRE_ZOMBIE_LOOP									"dlc1/castle/fx_ee_keeper_dog_fire_trail"
#precache( "fx", FX_FIRE_ZOMBIE_LOOP ); 

#define FX_FIRE_ZOMBIE_CHARGE									"dlc1/castle/fx_ee_keeper_runeprison_fire"
#precache( "fx", FX_FIRE_ZOMBIE_CHARGE ); 

#precache( "model", "c_viet_zombie_sonic_fb" );

//Fire Zombie Vars
#define FIRE_ZOMBIE_DAMAGE 				50
#define FIRE_ZOMBIE_FIRST_ROUND 		8
#define FIRE_ZOMBIE_HEALTH_MULTIPLIER 	0.8
#define FIRE_ZOMBIE_CHANCE				5
#define FIRE_ZOMBIE_MAX_PER_ROUND		3

#using_animtree("generic");

#namespace zm_fire_zombie;


REGISTER_SYSTEM_EX( "zm_fire_zombie", &init, &main, undefined )

function init()
{
	/*level.fire_zombie_damage = 50;				//Explosion damage
	level.fire_zombie_first_round = 2;			//First round fire zombies can start spawning
	level.fire_zombie_health_multiplier = 1.2;	//How much health more fire zombie has compared to reqular zombie
	level.fire_zombie_max = 4;					//Maximum number of zombies per round
	level.fire_zombie_min = 1;					//Minimum number of zombies per round*/

}

function main()
{
	//level thread FireZombieSpawn();
	zm_spawner::add_custom_zombie_spawn_logic( &SetupFireZombie );

	level.fire_zombie_this_round = 0;

	thread RoundWatcher();
}

/*function FireZombieSpawn()
{
	level endon("intermission");
	level WaitForFirstRound();

	//IPrintLnBold("Not Waiting Spawning Any more!");
	
	while(1)
	{
		level waittill("start_of_round");
		IPrintLnBold("In Spawn Loop");
		fire_zombies_spawned = 0;
		round_fire_zombies = RandomIntRange(FIRE_ZOMBIE_MIN, FIRE_ZOMBIE_MAX );	//How many fire zombies spawn this round
		IPrintLnBold(round_fire_zombies);
		while(fire_zombies_spawned <= round_fire_zombies)
		{
			min_wait = (level.round_number / 4);
			max_wait = (level.round_number * 2);
			wait(RandomIntRange(min_wait, max_wait));
			zombies_alive = GetAITeamArray("axis");
			if(zombies_alive.size >= 6)
			{
				//IPrintLnBold("Spawning Fire Zombie");
				fire_zombies_spawned++;
				//From Matarra
				spawn_point = array::random( level.zm_loc_types["zombie_location"] );
				spawner = array::random(level.zombie_spawners);
				ai = zombie_utility::spawn_zombie(spawner, spawner.targetname, spawn_point);
				ai thread SetupFireZombie();
				
			}

			WAIT_SERVER_FRAME;
		}

	}
}*/

function RoundWatcher()
{
	level endon("end_game");

	while(1)
	{
		level waittill("between_round_over");
		level.fire_zombie_this_round = 0;
	}
	

}

function SetupFireZombie()	//self = ai
{
	if(!IS_TRUE(level.spawn_fire_zombies))
	{
		return;
	}

	if(level.round_number < FIRE_ZOMBIE_FIRST_ROUND)
	{
		return;
	}

	if(RandomInt(100) >= FIRE_ZOMBIE_CHANCE)
	{
		return;
	}

	if( level.fire_zombie_this_round > FIRE_ZOMBIE_MAX_PER_ROUND )
	{
		return;
	}

	if( IS_TRUE(self.is_boss) || self.archetype != "zombie" )	//So that we can't have engineer/avogadro fire zombies
	{
		return;
	}

	level.fire_zombie_this_round++;
	
	self endon( "death" );
	self.is_fire_zombie = true;
	self.force_gib = false;
	self.gibbed = true; 
	self.maxhealth = Int( self.maxhealth * FIRE_ZOMBIE_HEALTH_MULTIPLIER );
	self.health = Int( self.health * FIRE_ZOMBIE_HEALTH_MULTIPLIER );
	self.is_on_fire = true;
	self.no_gib = 1;
	self.head_gibbed = true;
	self.needs_run_update = true;
	self.allowpain = false;
	self.ignore_nuke = true;
	self.is_boss = true;
	self.b_ignore_cleanup = true;

	//self detach( self.headModel, "" ); 
	//self detach( self.hatModel, "" ); 
	 
	//self SetModel( "c_viet_zombie_sonic_fb" );
	if(IS_TRUE(self.in_the_ground))
	{
		while(IS_TRUE(self.in_the_ground))
		{
			WAIT_SERVER_FRAME;
		}
	}
	
	self.fxtag = Spawn("script_model", self GetTagOrigin("j_spine4"));
	if(isdefined(self.fxtag))
	{
		self.fxtag SetModel("tag_origin");
		self.fxtag EnableLinkTo();
		self.fxtag LinkTo(self);
		PlayFXOnTag( FX_FIRE_ZOMBIE_LOOP, self.fxtag, "tag_origin" );
	}
	
	/*headmodel = Spawn("script_model", self GetTagOrigin("j_head"));
	if(isdefined(headmodel))
	{
		headmodel SetModel("zom_head3");
		headmodel Attach("zom_head1","j_neck");
		headmodel LinkTo(self);
	}*/

	self zombie_utility::set_zombie_run_cycle_override_value( "sprint" );	//walk, run, sprint are your options
	self thread WatchForDeath();
	self thread CheckNearPlayers();

}

function WatchForDeath()
{
	self waittill("death");
	self thread FireZombieExplosion();
} 

function CheckNearPlayers()
{
	self endon("death");
	self endon("fire_zombie_shutdown");
	while(!IS_TRUE(self.marked_for_death))
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		closest = ArrayGetClosest(self.origin, players);
		if(Distance(closest.origin, self.origin) < 75 && SightTracePassed(closest.origin + (0, 0, 40), self.origin + (0,0,40), false, self) && zm_utility::is_player_valid(closest))
		{
			self.marked_for_death = true;
			self.allowDeath = false;
			PlayFX(FX_FIRE_ZOMBIE_CHARGE, self GetTagOrigin("j_spine4"));
			self AnimScripted( "note_notify", self.origin, self.angles, %ai_zombie_base_taunts_v3 ); 
			wait(GetAnimLength(%ai_zombie_base_taunts_v3));
			self.allowDeath = true;
			self FireZombieExplosion();
		}
	}
}

function FireZombieExplosion()
{
	if(!isdefined(self))
	{
		return;
	}

	if(self.health > 0)
	{
		self DoDamage(self.health + 666, self.origin);
	}

	if(isdefined(self.fxtag))
	{
		self.fxtag Delete();
	}

	if(!IS_TRUE(level.icepart_spawned) && IS_TRUE(level.icepart_can_spawn))
	{
		rand = RandomInt(3);
		if(rand == 1)
		{
			players = GetPlayers();
			closest = ArrayGetClosest( self.origin, players );

			if(isdefined(closest) && Distance(closest.origin, self.origin) < 600)
			{
				zm_project_e_ee::SpawnIcePart( self.origin + (0, 0, 32) );
				level.spawn_fire_zombies = false;
			}
		}

	}

	PlayFXOnTag(FX_FIRE_ZOMBIE_EXP, self, "tag_origin");
	self PlaySound("fire_explode_00");
	WAIT_SERVER_FRAME;
	self Ghost();
	players = GetPlayers();
	closest = util::get_array_of_closest(self.origin, players, undefined, undefined, 150);
	if(isdefined(closest))
	{
		for(i = 0; i < closest.size; i++)
		{
			closest[i] DoDamage(FIRE_ZOMBIE_DAMAGE,closest[i].origin, self);
			closest[i] ShellShock( "weapon_butt", 1.0 );
		}
	}

	zombies = GetAITeamArray("axis");
	zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 150);
	if(isdefined(zombies))
	{
		for(j = 0; j < zombies.size; j++)
		{
			if(IS_TRUE(zombies[j].is_boss))
			{
				zombies[j] DoDamage( 1000, zombies[j].origin );
			}

			else 
			{
				zombies[j] DoDamage(zombies[j].health + 666, zombies[j].origin);
				zombies[j] zm_spawner::zombie_explodes_intopieces( true );
			}

		}
	}
	
}

function WaitForFirstRound()
{
	level endon("intermission");
	if(!isdefined(FIRE_ZOMBIE_FIRST_ROUND))
	{
		IPrintLnBold("NO FIRST ROUND SET");
		//FIRE_ZOMBIE_FIRST_ROUND = 5;
		return;
	}

	while(level.round_number < FIRE_ZOMBIE_FIRST_ROUND)
	{
		level waittill("start_of_round");
		IPrintLnBold("Still Waiting...");
	}
}

