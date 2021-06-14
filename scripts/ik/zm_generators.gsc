/*==========================================
Origins styled generator script by ihmiskeho
Credits:
BluntStuffy: His released script used for assistance


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
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_ai_dogs;
#using scripts\shared\exploder_shared;
#using scripts\zm\zm_afterlife_pe;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\zm_project_e_music;
#using scripts\zm\_util;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;

#define N_GEN_ACT_TIME		15			//How long it takes to activate a generator
#define N_MAX_GEN_ZOM		6			//How many crusaders can be alive at once
#define N_GEN_COST			200			//How much activating the generator costs
#define N_GEN_MAX_DIST		240			//Max distance for player to be in gen active

#precache("fx", "dlc1/castle/fx_elec_gen_idle_sm_castle");

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#precache("model", "p7_zm_zod_power_box_yellow_emissive");

#precache("xanim", "zod_powerbox_start");
#precache("xanim", "zod_powerbox_loop");

#namespace zm_generators;

#using_animtree("shockbox");

REGISTER_SYSTEM_EX( "zm_generators", &init, undefined, undefined )

function init()
{
	//Can be edited
	level.genDebug = false;			//Use debug, (true,false)
	
	//Don't edit below
	level.generators_active = false;
	level.genZomsAlive = 0;
	level.activated_generators = 0;

	level._effect["fx_elec_gen_idle_sm_castle"] = "dlc1/castle/fx_elec_gen_idle_sm_castle";

	//Clientfields
	RegisterClientField( "world", "capture" + "_" + "gen1",	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "capture" + "_" + "gen2",	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "capture" + "_" + "gen3", VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", "capture" + "_" + "gen4", VERSION_SHIP, 1, "int", undefined, false );

	clientfield::register( "scriptmover", "generator_fx", VERSION_SHIP, 2, "int" );

	init_flags();
	
	main();
}

function init_flags()
{
	//level flag::init( "power_on" + 0 );
	flag_size = 10;
	for(i = 0; i < flag_size; i++)
	{
		level flag::init( "power_on" + i );
		util::wait_network_frame();
	}
}

function DebugGen(string)
{
	if(isdefined(string))
	{
		IPrintLnBold("DEBUG:" +string);
	}
}

function main()
{
	gen_trigs = GetEntArray("generator_trigger", "targetname");

	if(!isdefined(gen_trigs))
	{
		return;
	}

	for( i = 0; i < gen_trigs.size; i++ )
	{
		gen_trigs[i] thread WatchGenTrig();
	}

	packa_door = GetEnt("generator_pack_door","targetname");
	if(!isdefined(packa_door))
		return;

	packa_door.fxmodel = util::spawn_model("tag_origin", packa_door.origin, (0, 0, 90));
	packa_door.trigger = Spawn("trigger_radius", packa_door.origin - (0, 0, 16), 0, 48, 48);
	packa_door.trigger SetHintString( "Need to activate the Generators" );
	packa_door.trigger thread DamagePlayer();

	PlayFXOnTag( level._effect["fx_elec_gen_idle_sm_castle"], packa_door.fxmodel, "tag_origin" );
	packa_door PlayLoopSound("avo_loop");
}

function DamagePlayer()		//self = player
{
	self endon("death");
	while(1)
	{
		WAIT_SERVER_FRAME;
		self waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid(user, false, false) && !IS_TRUE(user.in_afterlife) )
		{
			if( IS_TRUE(user.playing_fx) )
			{
				continue;
			}

			user thread PlayElecFx();
		}
	}
}

function PlayElecFx()
{
	time = 1.5;
	self.playing_fx = true;
	self SetElectrified( time );
	self ShellShock( "electrocution", time );
	self DoDamage( 10, self.origin );
	self PlaySound( "wpn_tesla_bounce" );
	wait( time );
	self.playing_fx = undefined;
}

function ShockGenerators()
{
	self endon("shockbox_triggered");
	level endon("end_game");

	self UseAnimTree( #animtree );
	self SetCanDamage( true );

	if(!isdefined(self.script_int))
	{
		return;
	}

	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		//IPrintLnBold("Shocked!!");
		if(IS_TRUE(e_attacker.in_afterlife) && IsPlayer(e_attacker))
		{
			if(isdefined(self.waypoint))
			{
				self.waypoint hud::destroyElem();
			}

			trig = GetEntArray("generator_trigger", "targetname");
			for(i = 0; i < trig.size; i++)
			{
				if( trig[i].script_int == self.script_int )
				{
					trig[i] notify("generator_shocked");
					self.activated = true;
					PlaySoundAtPosition( "afterlife_powered", self.origin );
					self SetModel( "p7_zm_zod_power_box_yellow_emissive" );
					self AnimScripted( "note_notify", self.origin, self.angles, "zod_powerbox_loop" );
					self notify("shockbox_triggered");
					
				}
			}
		}
	}
}

function WatchGenTrig()
{
	self endon("generator_active");
	level endon( "end_game" );

	self SetHintString("Requires Power");
	self SetCursorHint("HINT_NOICON");

	level waittill("gamemode_chosen");

	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode != "zm_gungame" && level.CurrentGameMode != "zm_classic" && level.CurrentGameMode != "zm_boss" )
	{
		//IPrintLnBold("Gamemode is not gungame");
		self waittill("generator_shocked");
	}

	if(isdefined(N_GEN_COST))
	{
		string = "Press ^3[{+activate}]^7 to Activate Generator [Cost: " +N_GEN_COST +"]";
	}

	else
	{
		string = "Press ^3[{+activate}]^7 to Activate Generator";
	}

	self SetHintString( string );
	
	while(1)
	{
		self waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid(user, false, false) && !IS_TRUE(user.in_afterlife) && !IS_TRUE(level.generator_active))
		{
			if(user.score >= N_GEN_COST)
			{
				self SetHintString("");
				user zm_score::minus_to_player_score( N_GEN_COST );
				self thread SpawnGenZombies( self );
				self thread CreateUserProgressBar( self );
				
				model = GetEnt(self.target, "targetname");
				self thread GeneratorActive( user, model );
				if(isdefined(model))
				{
					model clientfield::set( "generator_fx", 1 );
					//PlayFXOnTag(level._effect["fx_generator_progress_loop"], self.fxm, "tag_origin");
				}

				while(level.generator_active)
				{
					WAIT_SERVER_FRAME;
				}

				self SetHintString( string );
				model clientfield::set( "generator_fx", 0 );	
			}

			else 
			{
				user zm_audio::create_and_play_dialog( "general", "outofmoney" );
			}
		}
	}
}

function GeneratorActive( e_activator, m_generator )
{
	level endon("end_game");

	level.generator_active = true;
	level.gen_progress = 0.1;

	generator = GetEnt(self.target, "targetname");
	if(!isdefined(generator))
	{
		IPrintLnBold("ERROR: Generator has no targets set!!!");
		return;
	}

	PlaySoundAtPosition("gen_start", self.origin);

	while(true)
	{
		wait( 0.1 );
		e_gen_players = CheckGeneratorPlayers( generator );

		n_players_near_generator = 0;
		if( isdefined(e_gen_players) )
		{
			n_players_near_generator = e_gen_players.size;
		}

		if( n_players_near_generator > 0 )
		{
			self.newenter = true;
			n_percent = Float( n_players_near_generator / GetPlayers().size );
			level.gen_progress+= Float( ( 0.1/N_GEN_ACT_TIME ) * n_percent);
			if(level.gen_progress >= 1)
			{
				self notify("generator_active");
				self thread PlayActivateSound();
				self GeneratorActivePerks();
				level.activated_generators++;
				level thread CheckAllGeneratorsDone();
				level.generator_active = false;
				players = GetPlayers();
				for(i = 0; i < players.size; i++)
				{
					if(isdefined(players[i].genHud))
					{
						players[i].genHud hud::destroyElem();
					}
					if(isdefined(players[i].genHudtext))
					{
						players[i].genHudtext hud::destroyElem();
					}
				}
				
				PlayFX(level._effect["fx_115_generator_tesla_kill"], self.origin);
				if(isdefined(m_generator))
				{
					m_generator clientfield::set( "generator_fx", 2 );
					m_generator PlayLoopSound("gen_loop");
				}

				if(isdefined(self.script_int))
				{
					clientfield_name = "capture" + "_" + "gen" + (self.script_int + 1);
					level clientfield::set( clientfield_name, 1 );
					//IPrintlnBold("Clientfield set: " + clientfield_name);
				}

				e_activator zm_score::add_to_player_score( N_GEN_COST );

				wait(4);
				sound_to_play = undefined;

				if(IsAllGeneratorsActive())
				{
					sound_to_play = "vox_plr_" + e_activator GetCharacterBodyType() + "_pack_open_00";
				}

				else
				{
					sound_to_play = "vox_plr_" + e_activator GetCharacterBodyType() + "_power_on_0" + RandomInt(2);
				}
				
				e_activator thread CustomPlayerQuote( sound_to_play );
				break;
			}
		}

		else if(n_players_near_generator <= 0)
		{
			if( IS_TRUE(self.newenter) )
			{
				self.newenter = false;
				PlaySoundAtPosition("gen_interrupt", self.origin);
			}

			//IPrintLnBold("No Players Near Generator");
			level.gen_progress-= Float( 0.1/N_GEN_ACT_TIME );
			if(level.gen_progress <= 0)
			{
				level.generator_active = false;
				players = GetPlayers();
				for( i = 0; i < players.size; i++ )
				{
					if( isdefined(players[i].genHud) )
					{
						players[i].genHud hud::destroyElem();
					}

					if( isdefined(players[i].genHudtext) )
					{
						players[i].genHudtext hud::destroyElem();
					}
				}

				str_sound = "gen_shutdown_"+ (self.script_int + 1);
				PlaySoundAtPosition(str_sound, self.origin);

				self notify( "generator_timeout" );
				break;
			}
		}
		
	}

	if( isdefined(e_activator.genHud) )
	{
		e_activator.genHud hud::destroyElem();
	}

	if( isdefined(players[i].genHudtext) )
	{
		players[i].genHudtext hud::destroyElem();
	}
}

function PlayActivateSound()	//self = trigger
{
	PlaySoundAtPosition("gen_complete", self.origin);
	wait(2.4);
	str_sound = "gen_activated_"+ (self.script_int + 1);
	PlaySoundAtPosition(str_sound, self.origin);
	thread zm_project_e_music::play_music_for_players("generator" + (self.script_int + 1), false);
}

function CheckGeneratorPlayers( generator )
{
	players = GetPlayers();
	n_gen_users = [];

	for(i = 0; i < players.size; i++)
	{
		if(DistanceSquared( generator.origin, players[i].origin ) > N_GEN_MAX_DIST * N_GEN_MAX_DIST)
		{
			continue;
		}

		if(players[i] laststand::player_is_in_laststand())
		{
			continue;
		}

		if(IS_TRUE(players[i].in_afterlife))
		{
			continue;
		}

		if(!zm_utility::is_player_valid(players[i]))
		{
			continue;
		}

		n_gen_users[n_gen_users.size] = players[i];
	}

	return n_gen_users;
}

function CreateUserProgressBar( t_generator )
{
	self endon("generator_active");
	self endon("generator_timeout");
	level endon("disconnect");

	generator = GetEnt( self.target, "targetname" );	

	while(1)
	{
		WAIT_SERVER_FRAME;
		players = GetPlayers();
		foreach(player in players)
		{
			if( level.generator_active )
			{
				if(Distance(generator.origin, player.origin) <= N_GEN_MAX_DIST)
				{
					if( !isdefined(player.genHud) )
					{
						player.genHud = player hud::createPrimaryProgressBar();
					}

					if( !isdefined(player.genHudtext) )
					{
						player.genHudtext = player hud::createPrimaryProgressBarText();
						text = "Generator " +(t_generator.script_int + 1);
						player.genHudtext SetText(text);
					}

					player.genHud hud::updateBar(level.gen_progress, 0.0);
					if( level.gen_progress >= 1 )
					{
						player.genHud hud::destroyElem();
						player.genHudtext hud::destroyElem();
					}
				}

				else
				{
					if( isdefined( player.genHud ) )
						player.genHud hud::destroyElem();

					if( isdefined(player.genHudtext) )
						player.genHudtext hud::destroyElem();
				}				
			}
		}
	}
}

function SpawnGenZombies( t_generator )
{
	self endon( "generator_active" );
	self endon( "generator_timeout" );
	level endon( "end_game" );

	if(!isdefined(t_generator))
	{
		return;
	}

	if(!isdefined(level.genZomsAlive))
	{
		level.genZomsAlive = 0;
	}

	a_spawners = GetGenSpawners( t_generator );
	if(!isdefined(a_spawners))
	{
		IPrintLnBold("No Dogs spawns near generator! Check spawners in Radiant!!!");
		return;
	}

	min_time = 1.7;
	max_time = 2.9;

	while(1)
	{
		WAIT_SERVER_FRAME;
		e_spawn = array::random(a_spawners);
		a_alive_dogs = GetAISpeciesArray( "all", "zombie_dog" );

		if( a_alive_dogs.size < N_MAX_GEN_ZOM )
		{
			CustomSpawnDog( e_spawn );
		}

		wait(RandomFloatRange(min_time, max_time));
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

function GetGenSpawners( t_generator )
{
	if(!isdefined(t_generator.script_int))
	{
		IPrintLnBold("No script int set on generator. Check Radiant for KVPs");
		return;
	}

	a_spawners = [];
	a_dog_locations = struct::get_array("dog_location", "script_noteworthy");
	for(i = 0; i < a_dog_locations.size; i++)
	{
		if( isdefined(a_dog_locations[i].script_int) && a_dog_locations[i].script_int == t_generator.script_int )
		{
			a_spawners[a_spawners.size] = a_dog_locations[i];
		}
	}

	return a_spawners;

}

function GetAliveAi()
{
	n_dogs = [];
	a_ai = GetAITeamArray("axis");
	if(!isdefined(a_ai) || a_ai.size <= 0)
	{
		return 0;
	}

	for(i = 0; i < a_ai.size; i++)
	{
		if(IS_TRUE(a_ai[i].isdog))
		{
			n_dogs[n_dogs.size] = a_ai[i];
		}
	}

	return n_dogs.size;
}

function SpawnCrusader( generator )	//self = chosen spawn
{
	//Credit to mathfag (ModMe)
/*	gen_zombie = SpawnActor( "actor_spawner_zm_usermap_zombie" ,self.origin,self.angles,"",true,true );

	gen_zombie zm_spawner::zombie_spawn_init( undefined );

	gen_zombie.magic_bullet_shield = true;
	gen_zombie._rise_spot = self;
	gen_zombie.is_boss = 0;
	gen_zombie.gibbed = 1;
	gen_zombie.in_the_ground = 1;
	gen_zombie.ignore_enemy_count = 0;
	gen_zombie.ignore_nuke = 0;
	gen_zombie.no_powerups = 0;
	gen_zombie.no_damage_points = 0;
	gen_zombie.deathpoints_already_given = 0;

	gen_zombie.script_string = "find_flesh";
	gen_zombie zm_spawner::do_zombie_spawn();
	gen_zombie.zombie_move_speed = "sprint"; 
	gen_zombie clientfield::set( "tesla_shock_eyes_fx", 1 );
	gen_zombie.magic_bullet_shield = false;*/

	
	gen_zombie = SpawnActor( "actor_spawner_zm_usermap_zombie" ,self.origin,self.angles,"",true,true );
	gen_zombie zm_spawner::zombie_spawn_init( undefined );
	gen_zombie._spawn_location = self;		
	gen_zombie.is_boss = 0;
	gen_zombie.gibbed = 1;
	gen_zombie.ignore_enemy_count = 0;
	gen_zombie.ignore_nuke = 0;
	gen_zombie.no_powerups = 0;
	gen_zombie.no_damage_points = 0;
	gen_zombie.deathpoints_already_given = 0;

	gen_zombie.script_string = "find_flesh";

	gen_zombie zm_spawner::do_zombie_spawn();
	gen_zombie.zombie_move_speed = "run"; 
	gen_zombie clientfield::set( "tesla_shock_eyes_fx", 1 );

	gen_zombie thread GeneratorDamageZombies( generator );
	level.genZomsAlive++;
	gen_zombie waittill("death");
	gen_zombie clientfield::set( "tesla_shock_eyes_fx", 0 );
	level.genZomsAlive--;

}

function GeneratorActivePerks()		//self = generator trig
{
	PlaySoundAtPosition("gen_startup", self.origin);		//Do not use PlaySound on triggers (zmb_turn_on)
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
}

function GeneratorDamageZombies( generator )
{
	self endon("death");
	generator waittill("generator_active");
	self DoDamage(self.health +666, self.origin);
	self StartRagdoll();
	self LaunchRagdoll( (RandomIntRange(10, 20), RandomIntRange(10, 20), RandomIntRange(80, 100)) );
}

function ActivatePowerLights()
{
	level endon("end_game");
	// Exploder ON
    exploder::exploder( "power_light_test" );
}

function IsAllGeneratorsActive()
{
	if(!isdefined(level.activated_generators))
	{
		level.activated_generators = 0;
	}

	gen_trigs = GetEntArray("generator_trigger", "targetname");

	if(level.activated_generators >= gen_trigs.size)
	{
		return true;
	}

	return false;
}

function CheckAllGeneratorsDone()
{
	if(IsAllGeneratorsActive())
	{
		level notify("Pack_A_Punch_on");
		packa_door = GetEnt("generator_pack_door","targetname");
		if(!isdefined(packa_door))
			return;

		if(isdefined(packa_door.fxmodel))
			packa_door.fxmodel Delete();

		if(isdefined(packa_door.trigger))
			packa_door.trigger Delete();
			
		packa_door Delete();
		util::playSoundOnPlayers("gen_pap_activate", undefined);	

		if(isdefined( level.CurrentGameMode ) && (level.CurrentGameMode == "zm_gungame" || level.CurrentGameMode == "zm_classic" || level.CurrentGameMode == "zm_boss") )
		{
			i = 4;
			while( i < 10 )
			{
				util::wait_network_frame();
				level flag::set( "power_on" + i );
				i++;
			}
			
		}
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
