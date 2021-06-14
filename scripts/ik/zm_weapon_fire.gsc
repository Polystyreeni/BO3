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

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

#insert scripts\shared\shared.gsh;

#using_animtree("generic");

#namespace zm_weapon_fire;

//#define FX_FIREPROJECTILE		"Path Here"
//#precache( "fx", FX_FIREPROJECTILE );

REGISTER_SYSTEM_EX( "zm_weapon_fire", &init, undefined, undefined )

function init()
{
	level.FireDuration = 3;			//After projectile impact, how long burn effect lasts (in seconds)
	level.FireBlastRadius = 150;
	level.UgGrenadeAmount = 4;		//How Many "Fire Grenades" spawn when upgraded weapon is shot
	level.FireGunBossDamage = 2000;
	//level.FireGun = GetWeapon("")

	callback::on_connect( &OnConnect );

	zm_spawner::register_zombie_damage_callback( &FireGunDamage );

}

function OnConnect()
{
	self thread WaitForFire();
}

function WaitForFire()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("projectile_impact", weapon, point, radius);
		if( isdefined(weapon) )
		{
			if(weapon == GetWeapon("spell_fire_ug"))
			{
				forward = AnglesToForward(self GetPlayerAngles());
				self thread FireSpellUg(point, forward);
			}
	
		}
		
	}
}

function FireSpellUg( point, forward, should_respawn = true )		//self = player
{
	e_org = Spawn("script_model", point);
	e_org SetModel( "tag_origin" );

	fire1 = e_org MagicGrenadeType( GetWeapon("spell_fire_grenade"), e_org.origin, ( forward[0] * RandomIntRange(30, 50), forward[1] * RandomIntRange(30, 50) ,300) );
	fire2 = e_org MagicGrenadeType( GetWeapon("spell_fire_grenade"), e_org.origin, ( forward[0] * -RandomIntRange(60, 90), forward[1] * -RandomIntRange(60, 90) ,300) );

	util::wait_network_frame();
	e_org Delete();

	fire1 thread DamageOnDetonate( self, forward, should_respawn );
	fire2 thread DamageOnDetonate( self, forward, should_respawn );
}

function DamageOnDetonate( e_player, forward, should_respawn )
{
	self waittill("grenade_bounce" );
	origin = self.origin;
	if(should_respawn)
		e_player thread FireSpellUg( origin, forward, false );


	self Detonate();

	zombies = GetAITeamArray("axis");
	if(!isdefined(zombies))
	{
		return;
	}

	closest = util::get_array_of_closest(origin, zombies, undefined, undefined, 210);
	if(!isdefined(closest))
	{
		return;
	}

	for(i = 0; i < closest.size; i++)
	{
		if(IsAlive(closest[i]))
		{
			if(IS_TRUE(closest[i].is_boss))	//Boss Zombie Damage, add other .variables here if you want
			{
				damage = level.FireGunBossDamage;
			}

			else
			{
				if(isdefined(closest[i].health) && closest[i].health > 0)
				{
					damage = (self.health + 666);
					//closest[i] zm_spawner::dragons_breath_flame_death_fx();
				}
				
			}

			closest[i] DoDamage( damage, closest[i].origin, e_player );
			if(closest[i].health <= 0)
			{
				//e_player.kills++;
				e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
				if(RandomInt(10) == 0)
				{
					sound_to_play = "vox_plr_" + e_player GetCharacterBodyType() + "_kill_fire_0" + RandomInt(3);
					e_player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
				}
			}
		}
	}
}

function FireGunDamage( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	if(IsPlayer(e_player) && w_weapon == GetWeapon("spell_fire") && !IS_TRUE(self.in_the_ground))
	{
		//IPrintLnBold("Damage is good");
		self.marked_for_death = true;
		self.allowDeath = false;
		if( !IS_TRUE(self.isdog) || !IsVehicle(self) )
		{
			PlayFXOnTag( level._effect[ "character_fire_death_sm" ], self, "j_spine4" );
			self AnimScripted( "note_notify", self.origin, self.angles, %ai_zombie_base_taunts_v9 ); 
			wait(GetAnimLength(%ai_zombie_base_taunts_v9));
		}

		snd_origin = self GetTagOrigin("j_spine4");
		
		self.allowDeath = true;
		self thread CreateRadiusBurn( e_player );
		str_sound = "fire_explode_0" + RandomInt(2);
		PlaySoundAtPosition(str_sound, snd_origin);
		return true;

	}

	else 
	{
		return false;
	}
}

function CreateRadiusBurn( e_player )
{
	a_zombie = GetAITeamArray("axis");
	a_closest = util::get_array_of_closest(self.origin, a_zombie, undefined, undefined, 200);
	for(i = 0; i < a_closest.size; i++)
	{
		b_passed = BulletTracePassed(a_closest[i].origin, self.origin, false, undefined);
		if( b_passed )
		{
			//IPrintLnBold("Damage Near Zombies");
			if(a_closest[i] == self)
			{
				self zm_spawner::zombie_explodes_intopieces( true );
			}
			a_closest[i] thread zombie_death::flame_death_fx();
			a_closest[i] DoDamage(a_closest[i].health + 666, a_closest[i].origin, e_player);
			//e_player.kills++;
			e_player zm_score::add_to_player_score( 60 * level.zombie_vars[e_player.team]["zombie_point_scalar"] );
		}
		
	}

}