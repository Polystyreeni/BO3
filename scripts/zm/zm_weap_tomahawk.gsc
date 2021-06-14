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
#using scripts\zm\zm_afterlife_pe;
#using scripts\zm\zm_project_e_ee;
#using scripts\zm\_zm_weap_gravityspikes;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#precache("model", "wpn_t7_hatchet_world_zombie");
#precache("model", "wpn_t7_hatchet_world_zombie_upgraded");

#namespace zm_weap_tomahawk;

REGISTER_SYSTEM_EX( "zm_weap_tomahawk", &init, &main, undefined )

function init()
{
	callback::on_connect(&TomahawkOnConnect);

	level.tomahawk_weapon = GetWeapon("zombie_tomahawk");
	level.tomahawk_weapon_upgraded = GetWeapon("zombie_tomahawk_upgraded");

	level.tomahawk_boss_damage = 3000;

	level.spike_collectables = [];	//GetEntArray("");
	level.tom_parts_collected = 0;

	level.a_tomahawk_pickup_funcs = [];

	clientfield::register( "scriptmover", "tomahawk_trail_fx", VERSION_SHIP, 2, "int" );
	clientfield::register( "toplayer", "tomahawk_pulse_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "toplayer", "tomahawk_pulse_ug_fx", VERSION_SHIP, 1, "counter" );
	clientfield::register( "scriptmover", "tomahawk_zombie_impact", VERSION_SHIP, 1, "counter" );

	RegisterClientField( "world", "tomahawkgrabbed",	VERSION_SHIP, 2, "int", undefined, false );
	RegisterClientField( "world", "spikesgrabbed",	VERSION_SHIP, 1, "int", undefined, false );

}

function main()
{
	level flag::wait_till("initial_blackscreen_passed");

	level thread TomahawkPickup();	//TODO: Make this so that it doesn't spawn instantly

	level.spike_collectables = GetEntArray( "tom_spike_collectable", "targetname" );
	if(!isdefined(level.spike_collectables))
		return;

	foreach(collectable in level.spike_collectables)
	{
		collectable thread zm_powerups::powerup_wobble();
	}
}

function TomahawkOnConnect()
{
	self waittill("spawned_player");
	self.has_tomahawk = 0;
	self.current_tomahawk_weapon = undefined;

	self thread WatchTomahawkThrow();
	self thread WatchTomahawkCharge();

}

function WatchTomahawkThrow()	//self = player
{
	self endon( "disconnect" );
	self endon( "death" );

	while( true )
	{
		self waittill( "grenade_fire", grenade, weapon );
		if(weapon == level.tomahawk_weapon || weapon == level.tomahawk_weapon_upgraded)
		{
			grenade.use_grenade_special_bookmark = 1;
			grenade.grenade_multiattack_bookmark_count = 1;
			grenade.low_level_instant_kill_charge = 1;
			grenade.owner = self;

			self notify("throwing_tomahawk");

			if ( isdefined( self.tomahawk_cooking_time ) )
				grenade.cookedtime = grenade.birthtime - self.tomahawk_cooking_time;
			else
				grenade.cookedtime = 0;
			
			self thread CheckForTimeOut( grenade );
			self thread TomahawkThrown( grenade );
		}

		WAIT_SERVER_FRAME;
	}
}

function CheckForTimeOut( grenade )
{
	self endon( "disconnect" );
	grenade endon( "death" );
	wait(.5);
	grenade notify( "time_out" );
	//IPrintLnBold("Grenade Timeout");
}

function TomahawkThrown( grenade )	//self = player
{
	self endon("disconnect");

	grenade endon("in_hellhole");
	grenade_owner = undefined;

	if(isdefined(grenade.owner))
		grenade_owner = grenade.owner;

	//PlayFXOnTag("")	TODO: Add fx here

	self.tomahawk_in_use = 2;

	if(!isdefined(grenade))
		IPrintLnBold("Grenade not defined!");

	grenade util::waittill_either("death", "time_out");

	grenade_charge_power = grenade GetGrenadeChargePower( self );
	grenade_origin = grenade.origin;

	//IPrintLn("Grenade origin: " +grenade_origin);

	WAIT_SERVER_FRAME;
	grenade Ghost();
	//TomahawkCleanUp(grenade);

	zombies = GetAISpeciesArray("axis", "all");
	zombies = util::get_array_of_closest( grenade_origin, zombies, undefined, undefined, 200);

	powerups = level.active_powerups;
	powerups = util::get_array_of_closest( grenade_origin, powerups, undefined, undefined, 200 );

	collectables = level.spike_collectables;
	collectables = util::get_array_of_closest( grenade_origin, collectables, undefined, undefined, 250);

	if ( isdefined( level.a_tomahawk_pickup_funcs ) && level.a_tomahawk_pickup_funcs.size > 0 )
	{
		while(isdefined(level.a_tomahawk_pickup_funcs))
		{
			_a243 = level.a_tomahawk_pickup_funcs;
			_k243 = GetFirstArrayKey( _a243 );
			while ( isdefined( _k243 ) )
			{
				tomahawk_func = _a243[ _k243 ];
				if ( [[ tomahawk_func ]]( grenade, grenade_charge_power ) )
				{
					return;
				}
				_k243 = GetNextArrayKey( _a243, _k243 );
			}
		}
	}

	if( isdefined(collectables) && collectables.size > 0 )
	{
		tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
		tomahawk.grenade_charge_power = grenade_charge_power;
		_a256 = collectables;
		_k256 = GetFirstArrayKey( _a256 );
		while ( isDefined( _k256 ) )
		{
			collectable = _a256[ _k256 ];
			collectable.origin = grenade_origin;
			collectable LinkTo( tomahawk );
			tomahawk.part = collectable;
			_k256 = GetNextArrayKey( _a256, _k256 );
		}

		self thread TomahawkReturnPlayer( tomahawk, 0 );
		return;
	}

	if ( isdefined( powerups ) && powerups.size > 0 )
	{
		tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
		tomahawk.grenade_charge_power = grenade_charge_power;
		_a256 = powerups;
		_k256 = GetFirstArrayKey( _a256 );
		while ( isDefined( _k256 ) )
		{
			powerup = _a256[ _k256 ];
			powerup.origin = grenade_origin;
			powerup LinkTo( tomahawk );
			tomahawk.has_powerup = powerups;
			_k256 = GetNextArrayKey( _a256, _k256 );
		}
		self thread TomahawkReturnPlayer( tomahawk, 0 );
		return;
	}

	if ( !isdefined( zombies ) || zombies.size < 1 )
	{
		tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
		tomahawk.grenade_charge_power = grenade_charge_power;
		self thread TomahawkReturnPlayer( tomahawk, 0 );
		return;
	}

	else
	{
		_a276 = zombies;
		_k276 = GetFirstArrayKey( _a276 );
		while ( isdefined( _k276 ) )
		{
			ai_zombie = _a276[ _k276 ];
			ai_zombie.hit_by_tomahawk = 0;
			_k276 = GetNextArrayKey( _a276, _k276 );
		}
	}
	if ( isdefined( zombies[ 0 ] ) && IsAlive( zombies[ 0 ] ) )
	{
		zombiepos = zombies[ 0 ].origin;
		if ( Distance2DSquared( grenade_origin, zombiepos ) <= 4900 )
		{
			grenade clientfield::increment( "tomahawk_zombie_impact" );
			//PlayFXOnTag(FX_TOMAHAWK_IMPACT, zombies[0], "J_Head");
			zombies[ 0 ] PlaySound( "tomahawk_imp_00" );
			tomahawk_damage = CalculateTomahawkDamage( zombies[ 0 ], grenade_charge_power, grenade );
			zombies[ 0 ] DoDamage( tomahawk_damage, grenade_origin, self, grenade );
			zombies[ 0 ].hit_by_tomahawk = 1;
			self zm_score::add_to_player_score( 10 * level.zombie_vars[self.team]["zombie_point_scalar"] );
			self thread TomahawkRicochetAttack( grenade_origin, grenade_charge_power );
		}
		else
		{
			tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
			tomahawk.grenade_charge_power = grenade_charge_power;
			self thread TomahawkReturnPlayer( tomahawk, 0 );
		}
	}
	else
	{
		tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
		tomahawk.grenade_charge_power = grenade_charge_power;
		self thread TomahawkReturnPlayer( tomahawk, 0 );
	}

	TomahawkCleanUp(grenade);
}

function TomahawkRicochetAttack( grenade_origin, grenade_charge_power )
{
	self endon("disconnect");

	zombies = GetAISpeciesArray( "axis", "all" );
	zombies = util::get_array_of_closest( grenade_origin, zombies, undefined, undefined, 300 );
	zombies = array::reverse( zombies );
	if ( !isdefined( zombies ) )
	{
		tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
		tomahawk.grenade_charge_power = grenade_charge_power;
		self thread TomahawkReturnPlayer( tomahawk, 0 );
		return;
	}

	tomahawk = self TomahawkSpawn( grenade_origin, grenade_charge_power );
	tomahawk.grenade_charge_power = grenade_charge_power;
	self thread TomahawkAttackZombies( tomahawk, zombies );

}

function TomahawkAttackZombies( tomahawk, zombies )
{
	self endon("disconnect");

	if(!isdefined(zombies))
	{
		TomahawkReturnPlayer( tomahawk, 0 );
		return;
	}

	if(zombies.size <= 4)
	{
		attack_limit = zombies.size;
	}

	else
	{
		attack_limit = 4;
	}

	i = 0;
	while( i < attack_limit )
	{
		if(isdefined(zombies[i]) && IsAlive(zombies[i]))
		{
			tag = "J_Head";
			if( zombies[i].isdog )
				tag = "J_Spine1";

			if(!IS_TRUE( zombies[i].hit_by_tomahawk ))
			{
				target = zombies[i] GetTagOrigin(tag);
				tomahawk MoveTo( target, .3 );
				tomahawk waittill("movedone");
				if(isdefined(zombies[i]) && IsAlive(zombies[i]))
				{
					//IPrintLnBold("Tomahawk found zombie");
					tomahawk clientfield::increment( "tomahawk_zombie_impact" );

					PlaySoundAtPosition("tomahawk_imp_0" + RandomInt(10), tomahawk.origin);
					damage = CalculateTomahawkDamage( zombies[i], tomahawk.grenade_charge_power, tomahawk );
					zombies[i] DoDamage( damage, tomahawk.origin, self, tomahawk, 0, "MOD_EXPLOSIVE", 0, self.current_tomahawk_weapon );	// damage, zombies[i].origin, self, tomahawk
					zombies[i].hit_by_tomahawk = 1;
					self zm_score::add_to_player_score( 10 * level.zombie_vars[self.team]["zombie_point_scalar"] );

				}
			}
		}

		wait(.25);
		i++;
	}

	self thread TomahawkReturnPlayer( tomahawk, attack_limit );
	
}

function TomahawkSpawn( origin, charged )
{
	tomahawk = util::spawn_model( "wpn_t7_hatchet_world_zombie", origin );
	if(!isdefined(tomahawk))
		IPrintLnBold("Tomahawk not defined");

	tomahawk thread TomahawkSpin();
	tomahawk PlayLoopSound("tomahawk_loop");

	if( self.current_tomahawk_weapon == level.tomahawk_weapon_upgraded )
	{
		tomahawk SetModel("wpn_t7_hatchet_world_zombie_upgraded");
		tomahawk clientfield::set( "tomahawk_trail_fx", 2 );
	}

	else
	{
		tomahawk clientfield::set( "tomahawk_trail_fx", 1 );
	}

	if( isdefined(charged) && charged > 1 )
	{
		//TODO: Add charged fx here
	}

	tomahawk.low_level_instant_kill_charge = 1;
	
	self SetWeaponAmmoClip(self.current_tomahawk_weapon, 0);

	return tomahawk;
}

function TomahawkSpin()
{
	self endon("death");
	while(isdefined(self))
	{
		self RotatePitch(90, .2);
		wait(.15);
	}
}

function TomahawkReturnPlayer( tomahawk, amount_hit )
{
	self endon("disconnect");
	distance = Distance2DSquared( tomahawk.origin, self.origin );
	if(!isdefined(amount_hit))
	{
		amount_hit = 5;
	}

	while( distance > 4096 )
	{
		tomahawk MoveTo( self GetEye(), 0.25 );
		if(amount_hit < 5)
		{
			self TomahawkCheckForZombie( tomahawk );
			amount_hit++;
		}

		wait(.1);
		distance = Distance2DSquared( tomahawk.origin, self GetEye() );
	}

	if(isdefined(tomahawk.has_powerup))
	{
		powerup = tomahawk.has_powerup;
		tomahawk.origin = self.origin;
		tomahawk LinkTo( self );
	}


	if(isdefined(tomahawk.part))
	{
		level.tom_parts_collected++;
		if(level.tom_parts_collected >= 3)
		{
			level thread SpawnReward(self);
		}

		tomahawk.part Delete();
		tomahawk.part = undefined;
		self PlaySound("zmb_perks_vulture_pickup");
	}

	tomahawk clientfield::set( "tomahawk_trail_fx", 0 );

	wait(.1);
	tomahawk Delete();

	self PlaySoundToPlayer( "tomahawk_return", self );
	self SetWeaponAmmoClip(self.current_tomahawk_weapon, 0);

	zombies = GetAISpeciesArray("axis", "all");
	_a490 = zombies;
	_k490 = GetFirstArrayKey( _a490 );
	while ( isDefined( _k490 ) )
	{
		ai_zombie = _a490[ _k490 ];
		ai_zombie.hit_by_tomahawk = 0;
		_k490 = GetNextArrayKey( _a490, _k490 );
	}

	wait(5);
	self PlaySoundToPlayer( "tomahawk_ready", self );
	self GiveMaxAmmo( self.current_tomahawk_weapon );
}

function TomahawkCheckForZombie( tomahawk )
{
	self endon("disconnect");
	tomahawk endon("death");

	zombies = GetAISpeciesArray( "axis" );
	zombies = util::get_array_of_closest( tomahawk.origin, zombies, undefined, undefined, 100 );

	if( isdefined(zombies[0]) )
	{
		if( !IS_TRUE(zombies[0].hit_by_tomahawk) )
		{
			self TomahawkHitZombie( zombies[0], tomahawk );
		}
	}
}

function TomahawkHitZombie( zombie, tomahawk )
{
	self endon("disconnect");

	if(isdefined(zombie) && IsAlive(zombie))
	{
		tag = "J_Head";
		if( zombie.isdog )
			tag = "J_Spine1";

		tomahawk clientfield::increment( "tomahawk_zombie_impact" );

		zombie PlaySound("tomahawk_imp_0" + RandomInt(10));
		damage = CalculateTomahawkDamage( zombie, tomahawk.grenade_charge_power, tomahawk );
		zombie DoDamage( damage, tomahawk.origin, self, tomahawk, 0, "MOD_EXPLOSIVE", 0, self.current_tomahawk_weapon );
		zombie.hit_by_tomahawk = 1;
		self zm_score::add_to_player_score( 10 * level.zombie_vars[self.team]["zombie_point_scalar"] );
	}
}

function TomahawkCleanUp( grenade )
{
	if(isdefined(grenade))
		grenade Delete();
}

function GetGrenadeChargePower( owner )
{
	owner endon("disconnect");
	if(self.cookedtime > 1000 && self.cookedtime < 2000)
	{
		if( owner.current_tomahawk_weapon == level.tomahawk_weapon_upgraded )
			return 4.5;

		return 1.5;
	}

	else
	{
		if ( self.cookedtime > 2000 && self.cookedtime < 3000 )
		{
			if ( owner.current_tomahawk_weapon == level.tomahawk_weapon_upgraded )
			{
				return 6;
			}
			return 2;
		}
		else
		{
			if ( self.cookedtime >= 3000 && owner.current_tomahawk_weapon != level.tomahawk_weapon_upgraded )
			{
				return 2;
			}
			else
			{
				if ( self.cookedtime >= 3000 )
				{
					return 3;
				}
			}
		}
	}
	return 1;
}

function CalculateTomahawkDamage( zombie, grenade_charge_power, tomahawk )
{
	if(IS_TRUE(zombie.is_boss))
	{
		if(grenade_charge_power > 2)
			return Int(level.tomahawk_boss_damage * 3);

		else
			return level.tomahawk_boss_damage;
	}

	if(grenade_charge_power > 2)
	{
		return zombie.health + 1;
	}

	else
	{
		if(level.round_number >= 10 && level.round_number < 13 && tomahawk.low_level_instant_kill_charge <= 3)
		{
			tomahawk.low_level_instant_kill_charge += 1;
			return zombie.health + 1;
		}

		else
		{
			return 1000 * grenade_charge_power;
		}
	}
}

function WatchTomahawkCharge()	//self = player
{
	self endon("disconnect");
	self endon("death");

	while( true )
	{
		self waittill("grenade_pullback", weapon);
		if(weapon != level.tomahawk_weapon && weapon != level.tomahawk_weapon_upgraded)
			continue;

		self thread WatchForGrenadeCancel();
		self thread PlayChargeFX();
		self.tomahawk_cooking_time = GetTime();
		self util::waittill_any("grenade_fire", "grenade_throw_cancelled");
		wait(.1);
		self.tomahawk_cooking_time = undefined;
	}
}

function WatchForGrenadeCancel()
{
	self endon("death");
	self endon("disconnect");
	self endon("grenade_fire");

	WAIT_SERVER_FRAME;

	weapon = "none";
	while( self IsThrowingGrenade() && weapon == "none" )
		self waittill( "weapon_change", weapon );

	self notify("grenade_throw_cancelled");
}

function PlayChargeFX()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "grenade_fire" );

	WAIT_SERVER_FRAME;

	time_to_pulse = 1000;

	while( true )
	{
		time = GetTime() - self.tomahawk_cooking_time;
		tactical_grenade = self zm_utility::get_player_tactical_grenade();
		if( time >= time_to_pulse )
		{
			if(tactical_grenade == level.tomahawk_weapon_upgraded)
			{
				self PlaySoundToPlayer( "tomahawk_pulse", self );
				self clientfield::increment_to_player( "tomahawk_pulse_ug_fx", 1 );
			}

			else
			{
				self PlaySoundToPlayer( "tomahawk_pulse", self );
				self clientfield::increment_to_player( "tomahawk_pulse_fx", 1 );
			}

			time_to_pulse += 1000;
			self PlayRumbleOnEntity("reload_small");
		}

		if( time_to_pulse > 2400 && tactical_grenade != level.tomahawk_weapon_upgraded )
			return;

		else
		{
			if(time_to_pulse > 3400)
				return;

			else
				wait(.05);
		}
	}
}

function TomahawkGrab( upgraded = false )	//self = user
{
	if(upgraded)
	{
		w_tactical = self zm_utility::get_player_tactical_grenade();
		if( isdefined(w_tactical) && w_tactical == level.tomahawk_weapon_upgraded )
			return;
		
		if ( isdefined( w_tactical ) )
		{
			self TakeWeapon( w_tactical );
		}

		weapon = level.tomahawk_weapon_upgraded;
		flourish = GetWeapon("zombie_tomahawk_flourish");
		//self zm_afterlife_pe::override_tomahawk_tactical();
		self PlaySoundToPlayer( "tomahawk_raise", self );

		original_weapon = self GetCurrentWeapon();		

		self GiveWeapon( flourish );
		self SwitchToWeapon( flourish );
		self zm_utility::increment_is_drinking();
		self zm_utility::disable_player_move_states( true );
		
		wait(2);
		
		self TakeWeapon( flourish );
		self SwitchToWeapon( original_weapon );
		self zm_utility::decrement_is_drinking();
		self zm_utility::enable_player_move_states();

		self GiveWeapon( weapon );
		self zm_utility::set_player_tactical_grenade( weapon );
		self.current_tomahawk_weapon = weapon;
		self.current_tactical_grenade = weapon;
		self.has_tomahawk = 2;
		WAIT_SERVER_FRAME;
		self SetWeaponAmmoClip(self.current_tomahawk_weapon, 1);

		level clientfield::set("tomahawkgrabbed", 2);
	}

	else
	{
		w_tactical = self zm_utility::get_player_tactical_grenade();
		if( isdefined(w_tactical) && w_tactical == level.tomahawk_weapon )
		{
			//IPrintLnBold("Player has tomahawk!");
			return;
		}

		weapon = level.tomahawk_weapon;
		flourish = GetWeapon("zombie_tomahawk_flourish");
	
		if ( isdefined( w_tactical ) )
		{
			self TakeWeapon( w_tactical );	
		}

		self PlaySoundToPlayer( "tomahawk_raise", self );

		self GiveWeapon( flourish );
		self SwitchToWeapon( flourish );
		self zm_utility::increment_is_drinking();
		self zm_utility::disable_player_move_states( true );
		
		wait(2);
		
		self TakeWeapon( flourish );
		self SwitchToWeapon( original_weapon );
		self zm_utility::decrement_is_drinking();
		self zm_utility::enable_player_move_states();

		//IPrintLnBold("Got tomahawk");
		self GiveWeapon( weapon );
		self zm_utility::set_player_tactical_grenade( weapon );
		self.current_tomahawk_weapon = weapon;
		self.current_tactical_grenade = weapon;
		self.has_tomahawk = 2;
		WAIT_SERVER_FRAME;
		self SetWeaponAmmoClip(self.current_tomahawk_weapon, 1);

		sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_tom_pickup_0" + RandomInt(2);
		self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );

		level clientfield::set("tomahawkgrabbed", 1);
	}
	
}

//Trigger / pickup stuff is here
function TomahawkPickup()
{
	struct = struct::get("tomahawk_spawn", "targetname");
	if(!isdefined(struct))
		return;

	struct thread WatchTomahawkPickup( false );

	struct_upgraded = struct::get("tomahawk_spawn_upgraded", "targetname");
	if(!isdefined(struct_upgraded))
		return;

	struct_upgraded thread WatchTomahawkPickup( true );
}

function WatchTomahawkPickup( upgraded = false )
{
	level endon("intermission");
	level endon("end_game");

	str_model = "wpn_t7_hatchet_world_zombie";
	weapon = level.tomahawk_weapon;	//TODO: Add fx here
	string = "Hold ^3&&1 ^7To Pick up Hell's Retriever";
	if(upgraded)
	{
		str_model = "wpn_t7_hatchet_world_zombie_upgraded";
		weapon = level.tomahawk_weapon_upgraded;	// Todo: Add fx here
		string = "Hold ^3&&1 ^7To Pick up Hell's Redeemer";
	}

	model = util::spawn_model( str_model, self.origin );
	model PlayLoopSound("tomahawk_looper_close");

	trigger = Spawn("trigger_radius", model.origin, 0, 64, 64);
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( string );

	while(1)
	{	
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			if(user.has_tomahawk == 2)
			{
				if( user.current_tomahawk_weapon == level.tomahawk_weapon_upgraded )
					continue;
			}

			w_tactical = user zm_utility::get_player_tactical_grenade();
			if ( isdefined( w_tactical ) )
			{
				user TakeWeapon( w_tactical );	
			}

			user PlaySoundToPlayer( "tomahawk_raise", user );
			user GiveWeapon( weapon );
			user zm_utility::set_player_tactical_grenade( weapon );
			user.current_tomahawk_weapon = weapon;
			user.current_tactical_grenade = weapon;
			user.has_tomahawk = 2;
			WAIT_SERVER_FRAME;
			user SetWeaponAmmoClip(user.current_tomahawk_weapon, 1);		
		}
	}
}

function SpawnReward( user )
{
	init_loc = GetClosestPointOnNavMesh(user.origin);
	
	location = init_loc + ( 0, 0, 40 );
	
	model = Spawn( "script_model", location );
	model SetModel( GetWeaponWorldModel( GetWeapon( "hero_gravityspikes_melee" ) ) );
	model thread zm_powerups::powerup_wobble();
	
	trigger = Spawn( "trigger_radius_use", location + ( 0, 0, 30 ), 0, 80, 80 );
		
	trigger TriggerIgnoreTeam();
	trigger SetVisibleToAll();
	trigger SetTeamForTrigger( "none" );
	trigger UseTriggerRequireLookAt();
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "Press & hold ^3&&1^7 for Ragnarok DG4" );
	trigger thread DG4_Logic();
}

function dg4_logic()
{
	weapon = GetWeapon("hero_gravityspikes_melee");

	while( 1 )
	{
		self waittill( "trigger", player );
		if ( player HasWeapon( weapon ) )
			continue;

		player give_hero_weapon( weapon );

		sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_dg4_pickup_00";
		player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );

		level clientfield::set("spikesgrabbed", 1);
	}
}

function give_hero_weapon( w_weapon )
{
	self.isSpeaking = true;
 	w_previous = self GetCurrentWeapon();
 	self zm_weapons::weapon_give( w_weapon, 0, 0, 1, 0 );
 	self GadgetPowerSet( 0, 99 );
 	self SwitchToWeapon( w_weapon );
 	self waittill( "weapon_change_complete" );
 	self SetLowReady( 1 ); 
 	self SwitchToWeapon( w_previous );
 	self util::waittill_any_timeout( 1.0, "weapon_change_complete" );
 	self SetLowReady( 0 );
	self GadgetPowerSet( 0, 100 );
	self.isSpeaking = false;
}
