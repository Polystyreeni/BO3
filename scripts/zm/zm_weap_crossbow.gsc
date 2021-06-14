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
#using scripts\shared\math_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_crossbow;

#define CROSSBOW_DETONATION_TIME		5
#define CROSSBOW_DETONATION_TIME_UG		8

#define CROSSBOW_WEAPON 				GetWeapon("t6_crossbow")		
#define CROSSBOW_WEAPON_UG 				GetWeapon("t6_crossbow_upgraded")

//FX
#define CROSSBOW_FX						"crossbow_green"
#define CROSSBOW_UG_FX						"crossbow_red"

#precache("model", "t5_crossbow_bolt");

#precache( "fx", "dlc3/stalingrad/fx_glow_blink_green_20_doorbuy");
#precache( "fx", "light/fx_glow_blink_red_10");
#precache( "fx", "explosions/fx_exp_grenade_default");

REGISTER_SYSTEM( "zm_weap_crossbow", &init, undefined )

function init()
{
	clientfield::register( "missile", "crossbow_green", VERSION_SHIP, 1, "counter" );
	clientfield::register( "missile", "crossbow_red", VERSION_SHIP, 1, "counter" );

	callback::on_connect(&CrossbowOnConnect);
}

function CrossbowOnConnect()	//self = player
{
	self thread WatchCrossbowFire();
}

function WatchCrossbowFire()
{
	self endon("disconnect");
	level endon("end_game");

	self waittill( "spawned_player" );

	for(;;)
	{
		self waittill("projectile_impact", weapon, point, radius, projectile);
		if(weapon == CROSSBOW_WEAPON)
		{
			//IPrintLnBold("Fired crossbow");
			self thread CrossbowImpact( false, point, projectile );
		}

		else if(weapon == CROSSBOW_WEAPON_UG)
		{
			self thread CrossbowImpact( true, point, projectile );
		}
	}
}

function CrossbowImpact( isUpgraded, point, projectile )
{
	forward = AnglesToForward(projectile.angles);
	attract_model = undefined;
	detonation_time = 1.5;
	fx = CROSSBOW_FX;
	radius = 256;
	weapon = GetWeapon("t6_explosive_bolt");

	if(isUpgraded)
	{
		detonation_time = 4;
		fx = CROSSBOW_UG_FX;
		weapon = GetWeapon("t6_explosive_bolt_upgraded");
		attract_model = util::spawn_model("tag_origin", point);
		attract_model thread AttractZombies();
	}

	grenade = self MagicGrenadeType(weapon, point, forward);
	if(!isdefined(grenade))
	{
		if(isdefined(attract_model))
			attract_model Delete();
			
		return;
	}

	grenade.angles = projectile.angles;
	grenade thread PlayBeepSounds( detonation_time, fx );

	//grenade = self MagicGrenadeType(weapon, point, (0, 0, 0));
	
	//projectile thread PlayBeepSounds( detonation_time, fx );
	wait(detonation_time);

	grenade Detonate();

	if(isdefined(attract_model))
		attract_model Delete();


}

function FakeLinkTo( linkable )
{
	self endon("death");
	linkable endon("death");
	while( true )
	{
		WAIT_SERVER_FRAME;
		self.origin = linkable.origin;
		self.angles = linkable.angles;
	}
}

function CheckForZombieDeath( zombie )
{
	self endon("death");
	self endon("delete");

	while(isdefined(self))
	{
		zombie waittill("death");
		if(isdefined(self))
		{
			self Unlink();
		}
	}
}

function PlayBeepSounds( detonation_time, fx )	//self = model
{
	self endon("death");
	self endon("delete");

	interval = 0.3;

	for(;;)
	{
		self clientfield::increment( fx );
		self PlaySound("semtex_alert");
		wait(interval);
		interval = math::clamp( ( interval / 1.2 ), 0.08, 0.3 );
	}
}

function AttractZombies()
{
	self endon("death");

	//level thread BoltCleanUp( self );

	attract_dist_diff = 45;
	num_attractors = 96;
	max_attract_dist = 1536;

	valid_poi = zm_utility::check_point_in_enabled_zone( self.origin, undefined, undefined );

	if(valid_poi)
	{
		self zm_utility::create_zombie_point_of_interest( max_attract_dist, num_attractors, 10000 );
		self thread zm_utility::create_zombie_point_of_interest_attractor_positions( 4, attract_dist_diff );
		self thread zm_utility::wait_for_attractor_positions_complete();
	}
}
