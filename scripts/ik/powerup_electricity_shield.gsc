#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_death;

#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;

#using scripts\shared\array_shared;
//TEST
#using scripts\bosses\zm_engineer;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", "zombietron_lightning_bolt" );
#precache( "fx", "zombie/fx_tesla_shock_zmb" );
#precache( "material", "electricity_shield");

#using_animtree( "generic" ); 

REGISTER_SYSTEM( "zm_powerup_electricity_shield", &__init__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	level._effect[ "tesla_death_cherry" ]		= "zombie/fx_tesla_shock_zmb";
	zm_powerups::register_powerup( "electricity_shield", &grab_electricity_shield );
	if( ToLower( GetDvarString( "g_gametype" ) ) != "zcleansed" )
	{
		zm_powerups::add_zombie_powerup( "electricity_shield", "zombietron_lightning_bolt", "", &func_should_drop_electricity_shield, POWERUP_ONLY_AFFECTS_GRABBER, !POWERUP_ANY_TEAM, !POWERUP_ZOMBIE_GRABBABLE );
	}

}

function func_should_drop_electricity_shield()
{
	return true;
}

function grab_electricity_shield( player )		
{
	if(!level.zmAnnouncerTalking)
	{
		player PlayLocalSound( "vox_ann_tesla" ); 
	}
	player.electro_shield = true;
	skip = player add_powerup_hud( "electricity_shield", N_POWERUP_DEFAULT_TIME ); 
	if( skip )
		return; 
	player thread WatchZomDist();
}

function WatchZomDist()				//SELF = PLAYER
{
	self endon("electroshield_expired");
	while(self.electro_shield)
	{
		zombies = GetAISpeciesArray( "axis" );
		zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 100);
		foreach(zombie in zombies)
		{
			if(self.electro_shield && zombie.health > 0 && !zombie.is_boss)
			{
				IPrintLnBold("Zombie Near");
				zombie thread electro_shield_kill();
				self zm_score::add_to_player_score( 50 );
			}
		}
		wait(.1);
	}
}

function electro_shield_kill()		//SELF = ZOMBIE
{
	self DoDamage(self.health + 666, self.origin);
	PlayFXOnTag(level._effect[ "tesla_death_cherry" ], self, "j_spine4");
	if(self.missingLegs)
	{
		self AnimScripted( "note_notify", self.origin, self.angles, %ai_zombie_zod_stunned_electrobolt_a );
		wait(GetAnimLength(%ai_zombie_zod_stunned_electrobolt_a));
	}
	else
	{
		self AnimScripted( "note_notify", self.origin, self.angles, %ai_zombie_zod_stunned_electrobolt_a );
		wait(GetAnimLength(%ai_zombie_zod_stunned_electrobolt_a));
	}
	
}

function wait_til_timeout( player, hud )
{
	while( hud.time > 0 )
	{
		wait(1);
		hud.time--; 		
	}
	player.electro_shield = undefined; 
	player notify("electroshield_expired");
	player remove_powerup_hud( "electricity_shield" ); 
	player PlayLocalSound("zmb_insta_kill_loop_off");
}

function add_powerup_hud( powerup, timer )
{
	if ( !isDefined( self.powerup_hud ) )
		self.powerup_hud = [];
	
	if( isDefined( self.powerup_hud[powerup] ) )
	{
		self.powerup_hud[powerup].time = timer; 
		return true; // tells to skip because powerup is already active 
	}
	
	self endon( "disconnect" );
	hud = NewClientHudElem( self );
	hud.powerup = powerup;
	hud.foreground = true;
	hud.hidewheninmenu = false;
	hud.alignX = "center";
	hud.alignY = "bottom";
	hud.horzAlign = "center";
	hud.vertAlign = "bottom";
	hud.x = hud.x;
	hud.y = hud.y - 50;
	hud.alpha = 1;
	hud SetShader( powerup , 64, 64 );
	hud scaleOverTime( .5, 32, 32 );
	hud.time = timer;
	hud thread harrybo21_blink_powerup_hud();
	thread wait_til_timeout( self, hud ); 
	
	self.powerup_hud[ powerup ] = hud;
	
	a_keys = GetArrayKeys( self.powerup_hud );
	for ( i = 0; i < a_keys.size; i++ )
	 	self.powerup_hud[ a_keys[i] ] thread move_hud( .5, 0 - ( 24 * ( self.powerup_hud.size ) ) + ( i * 37.5 ) + 25, self.powerup_hud[ a_keys[i] ].y );
	
	return false; // powerup is not already active
}

function move_hud( time, x, y )
{
	self moveOverTime( time );
	self.x = x;
	self.y = y;
}

function harrybo21_blink_powerup_hud()
{
	self endon( "delete" );
	self endon( "stop_fade" );
	while( isDefined( self ) )
	{
		if ( self.time >= 20 )
		{
			self.alpha = 1; 
			wait .1;
			continue;
		}
		fade_time = 1;
		if ( self.time < 10 )
			fade_time = .5;
		if ( self.time < 5 )
			fade_time = .25;
			
		self fadeOverTime( fade_time );
		self.alpha = !self.alpha;
		
		wait( fade_time );
	}
}

function remove_powerup_hud( powerup )
{
	self.powerup_hud[ powerup ] destroy();
	self.powerup_hud[ powerup ] notify( "stop_fade" );
	self.powerup_hud[ powerup ] fadeOverTime( .2 );
	self.alpha = 0;
	wait .2;
	self.powerup_hud[ powerup ] delete();
	self.powerup_hud[ powerup ] = undefined;
	self.powerup_hud = array::remove_index( self.powerup_hud, self.powerup_hud[ powerup ], true );
	
	a_keys = GetArrayKeys( self.powerup_hud );
	for ( i = 0; i < a_keys.size; i++ )
	 	self.powerup_hud[ a_keys[i] ] thread move_hud( .5, 0 - ( 24 * ( self.powerup_hud.size ) ) + ( i * 37.5 ) + 25, self.powerup_hud[ a_keys[i] ].y );
}