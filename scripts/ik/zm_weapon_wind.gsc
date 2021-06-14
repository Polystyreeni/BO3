/*==========================================
Wind gun script by ihmiskeho
V1.0
Part of Project Elemental
Credits:
Matarra: Script Help
AllMods: Script Help
HarryBO21: Script Help
Treyarch: Thundergun script


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
#using scripts\zm\zm_project_e_ee;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#define WIND_PROJ									"custom/fx_wind_tornado"
#precache( "fx", WIND_PROJ );

#using_animtree( "generic" ); 

REGISTER_SYSTEM_EX( "zm_weapon_wind", &init, &main, undefined )

function init()
{
	level.windGun = GetWeapon("spell_wind");		//Weaponfile name
	level.windGunUg = GetWeapon("spell_wind_ug");	//Upgraded weapon
	level.WindDistance = 150;			//
	level.WindCylinderRadius = 180;
	level.UgWindTime = 10;				//Tornado life time

	clientfield::register( "scriptmover", "wind_fx", VERSION_SHIP, 1, "int" );
	callback::on_connect( &setUpWind );
}

function main()
{
	level.ee_satellite = GetEntArray("wind_satellite","targetname");
}

function setUpWind()
{
	self thread ShotCheck();
}

function ShotCheck()
{
	self endon("disconnect");
	while(1)
	{
		self waittill("weapon_fired",weapon);
		if(!isdefined(weapon))
			return;

		if( isdefined(weapon) && weapon == level.windGun )
		{
			PlayFX( level._effect["thundergun_smoke_cloud"], self GetWeaponMuzzlePoint());
			level notify("wind_gun_fired", self);	//V2 Edit: Adding this notify here, to 
			self thread NotUgWind();
		}

		else if( isdefined(weapon) && weapon == level.windGunUg )
		{
			PlayFX( level._effect["thundergun_smoke_cloud"], self GetWeaponMuzzlePoint());
			self thread CreateStorm();
		}
	}
}

function NotUgWind()
{
	if(!isdefined(level.fling_enemies))
	{
		level.fling_enemies = [];
		level.fling_vecs = [];
	}
	level.windgun_network_choke_count = 0;
	self getEnemiesInRange();

	for(i = 0; i < level.fling_enemies.size; i++)
	{
		level.fling_enemies[i] thread flingZombies(self, level.fling_vecs[i], i);
	}
	//IPrintLnBold("Got Enemies");
	level.fling_enemies = [];
	level.fling_vecs = [];
}

function getEnemiesInRange()
{
	//IPrintLnBold("getEnemiesInRange");
	view_pos = self GetWeaponMuzzlePoint();
	zombies = util::get_array_of_closest( view_pos, GetAISpeciesArray( "axis", "all" ), undefined, undefined, level.WindDistance );
	if(!isdefined(zombies))
	{
		return;
	}
	fling_range_squared = level.WindDistance * level.WindDistance;
	cylinder_radius_squared = level.WindCylinderRadius * level.WindCylinderRadius;
	forward_view_angles = self GetWeaponForwardDir();
	end_pos = view_pos + VectorScale( forward_view_angles, level.WindDistance );

	for(i = 0; i < zombies.size; i++)
	{
		if(!isdefined(zombies[i]) || !IsAlive(zombies[i]))
		{
			continue;
		}

		test_origin = zombies[i] GetCentroid();
		test_range_squared = DistanceSquared( view_pos, test_origin );
		radial_origin = PointOnSegmentNearestToPoint( view_pos, end_pos, test_origin );

		normal = VectorNormalize( test_origin - view_pos );
		dot = VectorDot( forward_view_angles, normal );
		if ( 0 > dot )
		{
			//IPrintLnBold("Behind");
			// guy's behind us
			continue;
		}

		if ( DistanceSquared( test_origin, radial_origin ) > cylinder_radius_squared )
		{
			//IPrintLnBold("outside cylinder");
			// guy's outside the range of the cylinder of effect
			continue;
		}

		if ( 0 == zombies[i] DamageConeTrace( view_pos, self ) )
		{
			//IPrintLnBold("Not valid");
			// guy can't actually be hit from where we are
			continue;
		}

		if ( test_range_squared < fling_range_squared )
		{
			//IPrintLnBold("Enemies in radius");
			level.fling_enemies[level.fling_enemies.size] = zombies[i];
			
			dist_mult = (fling_range_squared - test_range_squared) / fling_range_squared;
			fling_vec = VectorNormalize( test_origin - view_pos );
			
			if ( 5000 < test_range_squared )
			{
				fling_vec = fling_vec + VectorNormalize( test_origin - radial_origin );
			}
			fling_vec = (fling_vec[0], fling_vec[1], Abs( fling_vec[2] ));
			fling_vec = VectorScale( fling_vec, 100 + 100 * dist_mult );
			level.fling_vecs[level.fling_vecs.size] = fling_vec;
		}
	}
}

function flingZombies(player, fling_vec, index)
{
	if( !isdefined( self ) || !IsAlive( self ) )
	{
		return;
	}
	//IPrintLnBold("Should Fling");
	self DoDamage(self.health + 666, player.origin, player);
	if(self.health <= 0)
	{
		player zm_score::add_to_player_score( 60 * level.zombie_vars[player.team]["zombie_point_scalar"] );
		self StartRagdoll();
		self LaunchRagdoll(fling_vec);
	}
}

function weapon_network_choke()
{
	level.windgun_network_choke_count++;
	
	if ( !(level.windgun_network_choke_count % 10) )
	{
		util::wait_network_frame();
		util::wait_network_frame();
		util::wait_network_frame();
	}
}

function CreateStorm()
{
	ang = AnglesToForward( self GetPlayerAngles() );
	proj = Spawn("script_model", self GetWeaponMuzzlePoint() + (ang[0] * 10, ang[1] * 10, ang[2] * 10) );
	if( !isdefined(proj) )
		return;

	proj SetModel("tag_origin");
	proj.angles = self GetPlayerAngles();
	proj.active = true;
	proj clientfield::set("wind_fx", 1);
	//PlayFXOnTag(WIND_PROJ, proj, "tag_origin");
	proj thread MoveStorm( self );
	proj thread WatchZomNear( self );
	proj thread timeOut( level.UgWindTime );
	proj PlayLoopSound( "wind_projectile_loop" );
	proj util::waittill_any( "storm_timeout" , "movedone" );
	proj StopLoopSound(1);
	proj clientfield::set("wind_fx", 0);
	wait(.1);
	proj Delete();
}

function MoveStorm( user )
{
	//IPrintLnBold("MoveStorm");
	dist = 700;
	speed = 200;
	vec = AnglesToForward( user GetPlayerAngles() );
	p_origin = user GetWeaponMuzzlePoint();
	end_pos = (( vec[0] * dist, vec[1] * dist, vec[2] * dist ) + p_origin );
	trace = BulletTrace(p_origin, end_pos, false, user);
	final_pos = trace["position"];
	if( !isdefined(final_pos) )
		return;

	self MoveTo(final_pos, ( Distance( self.origin, final_pos ) / speed ));
	self waittill("movedone");
}

function WatchZomNear(player)
{
	if(!isdefined(self))
		return;

	while(isdefined(self))
	{
		zombies = GetAiTeamArray("axis");
		zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 200);
		if(!isdefined(zombies))
		{
			return;		//Stop function if "zombies" array is not defined
		}
		for(i = 0; i < zombies.size; i++)
		{
			if(!isdefined(zombies[i]) || !IsAlive(zombies[i]))
			{
				continue;
			}
			if(!IS_TRUE(zombies[i].marked_for_death) && !IS_TRUE(zombies[i].is_boss) && BulletTracePassed(zombies[i].origin, self.origin, false, undefined) && !IS_TRUE(zombies[i].in_the_ground))
			{
				zombies[i].marked_for_death = true;
				//IPrintLnBold("zombie marked for death");
				zombies[i] thread DoStormEffects(player, self);
			}
			else if(IsAlive(zombies[i]) && IS_TRUE(zombies[i].is_boss) && !IS_TRUE(self.has_damaged))
			{
				self.has_damaged = true;
				zombies[i] DoDamage(2000, zombies[i].origin, player);
				
			}

			wait(.1);
		}

		satellite = ArrayGetClosest(self.origin, level.ee_satellite, 245);
		if(isdefined(satellite) && !IS_TRUE(satellite.spinning))
		{
			if(BulletTracePassed(self.origin, satellite.origin, false, self, satellite))
				satellite thread zm_project_e_ee::LaserTrapSpin();
		}

		wait(.05);
	}	
}

function DoStormEffects(player, projectile)
{
	//self = zombie
	if(isdefined(projectile))
	{
		if(IsVehicle(self) || IS_TRUE(self.isdog))
		{
			player zm_score::add_to_player_score( 60 );
			player.kills++;
			self DoDamage(self.health + 666, self.origin);
		}

		else
		{
			end_pos = projectile.origin;
			model = Spawn("script_model", self.origin + ( 0,0,36 ));
			if(!isdefined(model))
				return;

			model SetModel("tag_origin");
			model thread DeleteFailSafe(10);
			self EnableLinkTo();
			self LinkTo(model);
			self AnimScripted( "note_notify", self.origin, self.angles, %ai_zombie_base_dth_b_id_gun );
			model MoveTo(end_pos, 0.5);
			wait(.5);
			self PlaySound("zombie_flesh");
			self Unlink();
			//self Ghost();
			self DoDamage(self.health + 666, self.origin, player);
			model Delete();
			self StartRagdoll();
			self LaunchRagdoll( (RandomIntRange(50, 70), RandomIntRange(50, 70), RandomIntRange(80, 100)) );
			if(IsPlayer(player))
			{
				player zm_score::add_to_player_score( 60 * level.zombie_vars[player.team]["zombie_point_scalar"]);
				//player.kills++;

				if(RandomInt(10) == 0)
				{
					sound_to_play = "vox_plr_" + player GetCharacterBodyType() + "_kill_wind_0" + RandomInt(3);
					player thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
				}
			}
			//zm_audio::create_and_play_dialog( category, subcategory, force_variant )
		}

		
	}
	else
	{
		self DoDamage(self.health + 666, self.origin);
	}
}

function DeleteFailSafe(time)
{
	wait(time);
	if(isdefined(self))
	{
		self Delete();
	}
}
function timeOut(time)
{
	wait(time);
	self notify("movedone");
	self notify("storm_timeout");
}
