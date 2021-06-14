/*==========================================
Ice gun script by ihmiskeho
V1.0
Part of Project Elemental
Credits:
JBird632
HarryBo21
Abnormal202
Mathfag
NateSmithZombies
Symbo
BluntStuffy

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
#using scripts\shared\system_shared;
#using scripts\zm\zm_project_e_ee;

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

#insert scripts\shared\shared.gsh;

#precache( "model", "freeze_model" );

#define FX_SHATTER									"dlc5/zmb_weapon/fx_staff_ice_exp"
#precache( "fx", FX_SHATTER ); 

#define FX_ICE_LOOP									"dlc5/zmb_weapon/fx_staff_ice_impact_ug_hit"
#precache( "fx", FX_ICE_LOOP );

#namespace zm_weapon_ice;

#using_animtree("generic");

REGISTER_SYSTEM_EX( "zm_weapon_ice", &init, undefined, undefined )

function init()
{
	level.icegun_distance = 150;							//From how far upgraded version slows zombies, half of explosion radius
	level.icegun_buildup = 5;								//Upgraded version, how long it takes to build up before explosion
	level.icegun = GetWeapon("spell_ice");					//weaponfile
	level.icegun_upgraded = GetWeapon("spell_ice_ug");		//weaponfile
	level.weapon_debug = true;								//true/false

	callback::on_spawned(&setUpIce);

	zm_spawner::register_zombie_damage_callback( &IceGunDamage );

	level thread IceBlockClear();

}

function DebugPrint(string)
{
	if(IS_TRUE(level.weapon_debug) && isdefined(string))
	{
		IPrintLnBold("Debug:" +string);
	}
}

function IceGunDamage( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	if( IsPlayer(e_player) && w_weapon == level.icegun && !IS_TRUE(self.in_the_ground) )
	{
		self thread IceGunNonUpgraded( e_player );
		return true;
	}

	return false;
}

function IceGunNonUpgraded( e_player )
{
	if(IsVehicle(self) || self.isdog)
	{
		self DoDamage(self.health + 666, self.origin);
		e_player.kills++;
	}

	/*else if( self GetEntityAnimRate() == 1 && IsAlive(self) )
	{
		if(!IS_TRUE(self.is_boss))
		{
			sound = "freeze_0" + RandomInt(3);
			self PlaySound(sound);
			self.allowDeath = false;
			interval = 1;
			self ASMSetAnimationRate( 0.75 );
			wait(interval);
			self ASMSetAnimationRate( 0.5 );
			wait(interval);
			self ASMSetAnimationRate( 0.05 );
			wait(interval * 2);
			self ASMSetAnimationRate( 1 );
			PlayFX(FX_SHATTER, self.origin + (0, 0, 32));
			self PlaySound( "shatter_00" );
			util::wait_network_frame();
			self.allowDeath = true;
			self DoDamage(self.health + 666, self.origin, e_player);
			self Ghost();
			e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
			//e_player.kills++;
		}

		else
		{
			self DoDamage( 2000, self.origin );
		}
		
	}*/

	//V2 Changelog: Changed ice stone not to be such a terrible gun non-upgraded

	else if(self GetEntityAnimRate() == 1)
	{
		if(!IsAlive(self))
			return;

		if(IS_TRUE(self.is_boss))
		{
			PlayFX(FX_SHATTER, self.origin + (0, 0, 32));
			self DoDamage( Int((self.health / 3) + 300) , self.origin);
			return;
		}

		sound = "freeze_0" + RandomInt(3);
		self PlaySound(sound);
		self.allowDeath = false;
		self ASMSetAnimationRate(0.05);

		self util::waittill_any_timeout( 3, "death", "damage" );
		PlayFX(FX_SHATTER, self.origin + (0, 0, 32));
		self PlaySound( "shatter_00" );
		util::wait_network_frame();
		self.allowDeath = true;
		self DoDamage(self.health + 666, self.origin, e_player);
		self DamageNearEnemies(self.origin, e_player);
		self Ghost();
		e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
		//e_player.kills++;
		if(RandomInt(10) == 0)
		{
			sound_to_play = "vox_" + e_player GetCharacterBodyType() + "_kill_ice_0" + RandomInt(3);
			e_player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
		}

	}

}

function DamageNearEnemies( origin, e_player )
{
	zombies = GetAITeamArray("axis", "all");
	zombies = util::get_array_of_closest(origin, zombies, undefined, undefined, 200);
	if(!isdefined(zombies))
		return;

	for(i = 0; i < zombies.size; i++)
	{
		if(IS_TRUE(zombies[i].is_boss))
		{
			self DoDamage(2000, self.origin);
			continue;
		}

		PlayFX(FX_SHATTER, self.origin + (0, 0, 32));
		self DoDamage(self.health + 666, self.origin, e_player);
		if(isdefined(e_player))
		{
			e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
			//e_player.kills++;
		}

	}

}

function setUpIce()
{
	//self thread WatchForWeaponFired();
	self thread WatchForWeaponFiredUg();

}

/*function WatchForWeaponFired()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("weapon_fired", weapon);
		if(weapon == level.icegun)
		{
			self thread IceWeaponNonUpgraded();
		}
	}	
}*/

function WatchForWeaponFiredUg()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("projectile_impact", weapon, point, radius);
		if(weapon == level.icegun_upgraded)
		{
			//IPrintLnBold("Upgraded Projectile shot!");
			self thread IceGunUpgraded( point );
		}
	}
}

/*function IceWeaponNonUpgraded()
{
	origin = self GetWeaponMuzzlePoint();
	angles = AnglesToForward( self GetPlayerAngles() );
	fake_bullet = Spawn("script_model", origin);
	fake_bullet SetModel("tag_origin");
	PlayFXOnTag("FX_ICE", model, "tag_origin");

	fake_bullet thread MoveFakeBullet( self, origin );
	fake_bullet thread WatchNearZombies( self );
	fake_bullet PlayLoopSound("ICE_SOUND");

	fake_bullet waittill("movedone");
	if(isdefined(fake_bullet))
	{
		fake_bullet StopLoopSound(1);
		fake_bullet Delete();
		DebugPrint("fake bullet deleted");
	}
}

function MoveFakeBullet( e_player, origin )
{
	n_distance = 500;
	n_speed = 200;			//Can edit these

	vec = AnglesToForward( e_player GetPlayerAngles() )
	end_pos = ( vec[0] * n_distance, vec[1] * n_distance, vec[2] * n_distance );
	trace = BulletTrace( origin, end_pos, false, e_player);
	final_pos = trace["position"];

	self MoveTo(final_pos, Distance(origin, end_pos) / n_speed);
	self waittill("movedone");
	a_ai = GetAITeamArray("axis");
	foreach (ai in a_ai)
	{
		if(isdefined(ai.immunetoice))
		{
			ai.immunetoice = undefined;
		}
	}
}

function WatchNearZombies( e_player )
{
	self endon( "movedone" );
	level endon( "end_game" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		a_ai = GetAITeamArray( "axis" );
		foreach(ai in a_ai)
		{
			if(Distance(ai.origin, self.origin) <= 75)
			{
				if(IS_TRUE(ai.is_boss) && !isdefined(ai.immunetoice))
				{
					ai.immunetoice = true;
					continue;
				}

				if(!isdefined(ai.marked_for_death) && !IS_TRUE(ai.in_the_ground) )
				{
					ai.marked_for_death = true;
					ai thread DoIceEffects( e_player );
				}
			}
		}
	}
}

function DoIceEffects( e_player )
{
	if(IS_TRUE(self.isdog) || IsVehicle(self))
	{
		DebugPrint("Vehicle or dog damage");
		self DoDamage(self.health + 666, self.origin, e_player);
	}

	else
	{
		DebugPrint("Normal Zombie Damage");
		self.ignoreall = true;
		e_block = Spawn("script_model", self.origin +( 0, 0, 36 ) );
		e_block SetModel("freeze_model");
		e_block.targetname = "ice_block";
		n_scale = 0.1;
		e_block SetScale( n_scale );
		e_block thread ModelGrow(n_scale);
		random = RandomIntRange(1,4);
		self AnimScripted( "note_notify", self.origin, self.angles, %freeze_death_anim_+random );
		wait( GetAnimLength(%freeze_death_anim_+random) );
		self.ignoreall = false;
		PlaySoundAtPosition("SND_SHATTER", self.origin);
		PlayFX(FX_SHATTER, e_block.origin);
		util::wait_network_frame();
		e_block Delete();
		self Ghost();
		self DoDamage(self.health + 666, self.origin, e_player);

		//e_player zm_score::add_to_player_score( 60 ) * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
		//e_player.kills++;
		if(RandomInt(10) == 0)
		{
			sound_to_play = "vox_plr_" + e_player GetCharacterBodyType() + "_kill_ice_0" + RandomInt(3);
			e_player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
		}
		
	}
}*/

function ModelGrow(n_scale)
{
	while(n_scale < 0.5)
	{
		WAIT_SERVER_FRAME;
		n_scale += 0.05;
		self SetScale(n_scale); 
	}
}

function IceGunUpgraded( point )
{
	if(!isdefined(point))
	{
		return;
	}

	e_projectile = Spawn("script_model", point);
	e_projectile SetModel("tag_origin");
	if(!isdefined(e_projectile))
	{
		//IPrintLnBold("Projectile model not defined");
		return;
	}
	PlayFXOnTag(FX_ICE_LOOP, e_projectile, "tag_origin");
	//IPrintLnBold("Created Projectile");
	e_projectile thread SlowNearZombs( self );
	//e_projectile PlaySound("bomb_rampup");
	wait( level.icegun_buildup );
	e_projectile notify("buildup_done");
	e_projectile ShatterZombies( self );
	//IPrintLnBold("Shattered Zombies");
	PlayFX(FX_SHATTER, e_projectile.origin);
	util::wait_network_frame();
	if(isdefined(e_projectile))
	{
		//IPrintLnBold("Projectile Deleted");
		e_projectile Delete();
	}
}

function SlowNearZombs( e_player )
{
	self endon("buildup_done");
	e_player endon("disconnect");
	level endon("end_game");
	while(1)
	{
		//IPrintLnBold("Slowing near zombies");
		WAIT_SERVER_FRAME;
		a_ai = GetAITeamArray( "axis" );
		foreach(ai in a_ai)
		{
			WAIT_SERVER_FRAME;
			if( Distance(ai.origin, self.origin) <= level.icegun_distance && !isdefined(ai.slowed_down) && !IS_TRUE(ai.in_the_ground) )
			{
				if(isdefined(self.b_widows_wine_slow))
    				{
        				self DoDamage(self.health + 666, self.origin);
    				}

				if(!isdefined(ai.icemodel))
				{
					ai.icemodel = Spawn("script_model", ai GetTagOrigin("j_spine4"));
					ai.icemodel SetModel("freeze_model");
					//ai.icemodel.targetname = "ice_block";
					ai.icemodel util::deleteAfterTime( 7 );
					ai.icemodel SetScale(0.05);
					ai.icemodel EnableLinkTo();
					ai.icemodel LinkTo( ai );
					ai.icemodel thread ModelGrow( 0.05 );
					ai thread IceModelCleanUp( ai.icemodel );
				}
				
				ai.slowed_down = true;
				ai.normal_speed = ai GetEntityAnimRate();
				ai ASMSetAnimationRate(0.1);
				sound = "freeze_0" + RandomInt(3);
				ai PlaySound(sound);
				//ai zm_custom_util::SetZMAnimationRate(0.1, ai.normal_speed, true);
				//continue;
			}
		}	
	}
}

function IceModelCleanUp( model )
{
	self waittill("death");
	if(isdefined(self))
	{
		if(self GetEntityAnimRate() != 1)
		{
			self ASMSetAnimationRate( 1 );
		}

	}

	if(isdefined(model))
	{
		model Unlink();
		model Delete();
	}
}

function ShatterZombies( e_player )
{
	a_ai = GetAITeamArray( "axis" );
	if(!isdefined(a_ai))
	{
		return;
	}

	foreach(ai in a_ai)
	{
		WAIT_SERVER_FRAME;
		if( IsAlive(ai) && ( Distance(ai.origin, self.origin) <= level.icegun_distance * 2 || IS_TRUE(ai.slowed_down) ) )
		{
			if(IS_TRUE(ai.is_boss))		//Add other possible exceptions here (don't instakill the zombies you don't want to)
			{
				if( isdefined( ai.normal_speed) ) 
				{ 
					ai ASMSetAnimationRate( ai.normal_speed );
				}

				else
				{ 
					ai ASMSetAnimationRate( 1 );
				}
				
				PlayFX(FX_SHATTER, ai.origin + (0, 0, 36));
				ai DoDamage(2000, ai.origin, e_player);
				if(isdefined(ai.icemodel))
				{
					ai.icemodel Unlink();
					ai.icemodel Delete();
				}
				
			}

			else
			{
				if(isdefined(ai.icemodel))
				{
					ai.icemodel Unlink();
					ai.icemodel Delete();
				}

				PlayFX(FX_SHATTER, ai.origin + (0, 0, 36));
				sound = "shatter_0" + RandomInt(4);
				ai PlaySound(sound);
				ai ASMSetAnimationRate( 1 );
				ai Ghost();
				ai DoDamage(ai.health + 666, ai.origin, e_player);
				//e_player.kills++;
				//e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
			}
		}
	}
}

function IceBlockClear()
{
	level endon("intermission");
	level endon("end_game");

	while(1)
	{
		level waittill("start_of_round");
		ents = GetEntArray("ice_block", "targetname");
		if(!isdefined(ents))
			continue;
	
		for(i = 0; i < ents.size; i++)
		{
			ents[i] Delete();
		}
	}
}
