/*==========================================
Lightning gun script by ihmiskeho
V0.9
Part of Project Elemental
Credits:
Matarra: Script Help
HarryBO21: Script Help
Symbo


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
#using scripts\shared\scene_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_weap_tesla;
#using scripts\zm\_zm_lightning_chain;
#using scripts\shared\clientfield_shared;
#using scripts\zm\zm_project_e_ee;
#using scripts\shared\system_shared;

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using_animtree("generic");

#namespace zm_weapon_lightning;

REGISTER_SYSTEM_EX( "zm_weapon_lightning", &init, &main, undefined )

function init()
{
	level.ugLight_distance = 150;
	level.ugLight_time = 6;
	level.light_debug = false;
	level.lightning_weapon = GetWeapon( "spell_lightning" );
	level.lightning_weapon_upgraded = GetWeapon( "spell_lightning_ug" );

	clientfield::register( "scriptmover", "lightning_gun_fx", VERSION_SHIP, 1, "int" );

	//For non-upgraded version so we can have a tesla chain effect
	zm::register_zombie_damage_override_callback( &lightning_damage_zombie );

	callback::on_connect( &setUpLightning );
}

function main()
{
	
}

function DebugPrint(text)
{
	if(isdefined(level.light_debug) && level.light_debug && isdefined(text))
	IPrintLnBold("^1DEBUG: ^7" +text);
}


function setUpLightning()
{
	self.wonderweaponactive = 0;		//Made so that wonderweapons can't be spammed
	self thread watchForWeapon();
}

function watchForWeapon()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("projectile_impact", weapon, point, radius);
		if(weapon == level.lightning_weapon_upgraded)
		{
			DebugPrint("Shot Upgraded");
			self thread UpgradedLight(point);
		}
	}
}

function UpgradedLight(point)
{
	if(self.wonderweaponactive < 5)			// Made so that wonderweapons can't be spammed
	{
		self.wonderweaponactive++;
		projectile = Spawn("script_model", point + ( 0, 0, 20 ));
		projectile SetModel("tag_origin");
		projectile clientfield::set("lightning_gun_fx", 1);
		projectile thread ShockNearZoms(self);
		projectile PlayLoopSound("avo_loop");
		wait(level.ugLight_time);
		projectile StopLoopSound(1);
		projectile clientfield::set("lightning_gun_fx", 0);
		projectile notify("life_over");
		if(isdefined(projectile))
		{
			self.wonderweaponactive--;
			DebugPrint("Projectile was defined, Deleting...");
			projectile Delete();
		}
		else
		{
			DebugPrint("Projectile doesn't exist!!!");
		}
	}
	
}

function ShockNearZoms(player)
{
	self endon("life_over");
	level endon("end_game");

	distanceSq = level.ugLight_distance * level.ugLight_distance;

	self.ignored_enemies = [];

	while(isdefined(self))
	{
		WAIT_SERVER_FRAME;
		ai_array = GetAITeamArray("axis");
		foreach(ai in ai_array)
		{
			if(IS_TRUE(ai.is_boss))
			{
				if(!IsInArray(self.ignored_enemies, ai))
				{
					ai DoDamage((ai.health / 2 + 1000), ai.origin);
					self.ignored_enemies[self.ignored_enemies.size] = ai;
				}
				
				continue;
			}
			if(DistanceSquared(self.origin, ai.origin) <= distanceSq && !isdefined(ai.marked_for_death) && IsAlive(ai) && !IS_TRUE(ai.in_the_ground))
			{
				DebugPrint("Zombies Close");
				ai.marked_for_death = true;
				ai thread DoStormEffect(player);
			}
		}
	}
}

function DoStormEffect(player)
{
	self endon("death");
	PlaySoundAtPosition("elec_hit", self.origin);
	if(IsVehicle(self) || IS_TRUE(self.isdog))
	{
		player zm_score::add_to_player_score( 60 * level.zombie_vars[player.team]["zombie_point_scalar"] );
		//player.kills++;
		self DoDamage(self.health + 666, self.origin, player);
		DebugPrint("Vehicle Damage");
	}

	else
	{
		DebugPrint("Normal Zombie Damage");
		self clientfield::set( "tesla_shock_eyes_fx", 1 );
		self scene::play("cin_zm_dlc3_zombie_dth_deathray_0" + RandomIntRange( 1, 5 ), self);
		util::wait_network_frame();
		//self Ghost();
		self clientfield::set( "tesla_shock_eyes_fx", 0 );
		//player zm_score::add_to_player_score( 60 * level.zombie_vars[player.team]["zombie_point_scalar"] );
		//player.kills++;

		if(RandomInt(10) == 0)
		{
			player thread PlayElementalQuote();
		}

		self DoDamage(self.health + 666, self.origin, player);
		
		
	}
}

function lightning_damage_zombie( willBeKilled, inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, sHitLoc, psOffsetTime, boneIndex, surfaceType )
{
	if( self is_lightning_damage( meansofdeath, weapon ) )
	{
		self thread lightning_damage_init( sHitLoc, vpoint, attacker );
		return true;
	}
	return false;
}

function is_lightning_damage( mod, weapon )
{
	return ( weapon == level.lightning_weapon && (mod == "MOD_PROJECTILE" || mod == "MOD_PROJECTILE_SPLASH" ));
}

function lightning_damage_init( hit_location, hit_origin, player )
{
	player endon( "disconnect" );

	if ( IS_TRUE( player.tesla_firing ) )
	{
		return;
	}

	if( IsDefined( self.zombie_tesla_hit ) && self.zombie_tesla_hit )
	{
		// can happen if an enemy is marked for tesla death and player hits again with the tesla gun
		return;
	}

	zm_utility::debug_print( "TESLA: Player: '" + player.name + "' hit with the tesla gun" );

	//TO DO Add Tesla Kill Dialog thread....
	
	player.tesla_enemies = undefined;
	player.tesla_enemies_hit = 1;
	player.tesla_powerup_dropped = false;
	player.tesla_arc_count = 0;
	player.tesla_firing = 1;
	
	self lightning_chain::arc_damage( self, player, 1, level.tesla_lightning_params );

	player.tesla_enemies_hit = 0;
	player.tesla_firing = 0;
}

function PlayElementalQuote()	//self = player
{
	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_kill_lightning_0" + RandomInt(3);
	self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
}