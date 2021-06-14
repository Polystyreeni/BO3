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

#insert scripts\shared\shared.gsh;

#namespace zm_weap_ims;

#precache("model", "iw6_ims_body");
#precache("model", "iw6_ims_body_valid");
#precache("model", "iw6_ims_body_nonvalid");
#precache("model", "iw6_ims_explosive");

#precache("model", "iw6_ims_explosive_afterlife");
#precache("model", "iw6_ims_explosive_bundle_afterlife");

#precache("xanim","iw6_ims_door_1");
#precache("xanim","iw6_ims_door_2");
#precache("xanim","iw6_ims_door_3");
#precache("xanim","iw6_ims_door_4");
#precache("xanim","iw6_ims_idle_1");
#precache("xanim","iw6_ims_idle_2");
#precache("xanim","iw6_ims_idle_3");

#define FX_IMS_EXP 			 "weapon/fx_betty_exp"
#precache("fx", FX_IMS_EXP);

#define FX_IMS_EXP_UG		"zombie/fx_sword_slam_elec_1p_zod_zmb"
#precache("fx", FX_IMS_EXP_UG);

#define FX_IMS_TIMEOUT		"killstreaks/fx_emp_explosion_equip"
#precache("fx", FX_IMS_TIMEOUT);

#using_animtree( "iw6_ims" ); 

//#define FX_FIREPROJECTILE		"Path Here"
//#precache( "fx", FX_FIREPROJECTILE );

REGISTER_SYSTEM_EX( "zm_weap_ims", &init, &main, undefined )

function init()
{
	level.ims_weapon = GetWeapon("iw6_ims_equipment");	//Weapon file name

	callback::on_connect(&ImsOnConnect);
}

function main()		//For now this is a placeholder function for testing
{
	/*trigger = GetEnt("ims_purchase_trigger","targetname");
	if(!isdefined(trigger) || trigger.size <= 0)
	{
		IPrintLnBold("No Trigger Found");
		return;
	}

	trigger SetHintString("IMS");
	trigger SetCursorHint("HINT_NOICON");

	while(1)
	{
		trigger waittill("trigger", user);
		if(IsPlayer(user))
		{
			IPrintLnBold("Hit Trigger");
			user GiveWeapon(level.ims_weapon);
			user SetActionSlot(4, "weapon", level.ims_weapon);
			user SetWeaponAmmoStock(level.ims_weapon, 1);
		}
	}*/
}

function ImsOnConnect()
{
	self.activeims = undefined;
	self.imskills = 0;
	self.upgraded_ims = false;
	self thread WatchForImsWeapon();
}

function WatchForImsWeapon()
{
	self endon("disconnect");
	level endon("intermission");

	while(1)
	{
		self waittill("weapon_change");
		//IPrintLnBold("weapon Change");
		weapon = self GetCurrentWeapon();
		if( isdefined(weapon) && weapon == level.ims_weapon )
		{
			//IPrintLnBold("Is holding ims weapon");
			self thread ShowImsModel();
			self thread ImsPlacement();
		}
	}
}

function ShowImsModel()
{
	self endon("weapon_change");
	self endon("death");
	self endon("fake_death");
	self endon("disconnect");

	origin = CheckNavMeshDirection(self.origin, AnglesToForward(self.angles), 15);
	if(isdefined(origin))
	{
		self.imsmodel = Spawn("script_model", origin);
		self.imsmodel SetModel("iw6_ims_body");
		self.imsmodel SetOrigin(origin);
	}

	self thread ImsModelCleanUp();
	self thread UpdateImsPosition( self.imsmodel );

}

function UpdateImsPosition( model )
{
	self endon("weapon_change");
	self endon("death");
	self endon("disconnect");

	if(!isdefined(model))
	{
		return;
	}

	while(1)
	{
		WAIT_SERVER_FRAME;
		placement = self CanPlayerPlaceTurret();
		model.origin = placement["origin"];
		model.angles = placement["angles"];
		model.canBePlaced = placement["result"];
		if(!model.canBePlaced)
		{
			model SetModel("iw6_ims_body_nonvalid");
		}

		else
		{
			model SetModel("iw6_ims_body_valid");
		}

		//model.origin = origin;
		//model.agnles = angles;
	}
}

function ImsModelCleanUp()
{
	self util::waittill_any("weapon_change", "death", "fake_death", "disconnect", "ims_placed");
	if(isdefined(self.imsmodel))
	{
		//IPrintLnBold("Deleting model");
		self.imsmodel Delete();
	}
	
}

function ImsPlacement()
{
	self endon("weapon_change");
	self endon("death");
	self endon("fake_death");
	self endon("disconnect");

	while(1)
	{
		WAIT_SERVER_FRAME;
		self waittill("weapon_fired", weapon);
		if(!isdefined(weapon))
		{
			continue;
		}

		if(weapon == level.ims_weapon)
		{
			valid_pos = self CheckImsValidPosition();
			if(valid_pos)
			{
				WAIT_SERVER_FRAME;
				self zm_weapons::weapon_take(level.ims_weapon);
				self notify("ims_placed");
				if(isdefined(self.activeims))
				{
					self.activeims thread ImsDestroy( self );
				}

				self SpawnIms( self.imsmodel.origin, self.imsmodel.angles );
			}
		}
	}
}

function CheckImsValidPosition()
{
	model = self.imsmodel;
	if(!isdefined(model))
	{
		return;
	}

	//origin = CheckNavMeshDirection(self.origin, AnglesToForward(self.angles), 15);
	/*placement = self CanPlayerPlaceTurret();

	model.origin = placement["origin"];
	model.angles = placement["angles"];

	model.canBePlaced = placement["result"];*/
	if(IS_TRUE(model.canBePlaced))
	{
		return true;
	}

	else 
	{
		return false;
	}
}

function SpawnIms( origin, angles )
{
	model = Spawn("script_model", origin);
	model SetModel("iw6_ims_body");
	model.angles = angles;
	model UseAnimTree(#animtree);
	model PlaySound("ims_plant");

	//IMS specific stuff
	model.owner = self;
	if(isdefined(self.imsammo))
	{
		//IPrintLnBold("set IMS ammo To:" +self.imsammo);
		model.ammo = self.imsammo;
	}

	else
	{
		model.ammo = 4;
		self.imsammo = model.ammo;
	}

	//IPrintLnBold("User Placed IMS with ammo of:" +self.imsammo);
	index = model GetAmmoIndex();

	if(index > 1)
	{
		animation = "iw6_ims_idle_" +(index - 1);
		model AnimScripted( animation, model.origin, model.angles, animation );
		//IPrintLnBold("Anim Set to:" +animation);
	}

	self.activeims = model;
	model.imslaunching = false;

	//ADDED: Upgrade functionality
	model.is_upgraded = self.upgraded_ims;

	model thread WatchForGrab();
	model thread ImsFunctionality();
	model thread ImsCleanup();
	self thread ImsDisconnect( model );
}

function ImsDisconnect( model )
{
	model endon("ims_collected");
	model endon("ims_ammo_out");
	self util::waittill_any("death", "disconnect");
	if(isdefined(model))
	{
		if(isdefined(model.trigger))
		{
			model.trigger Delete();
		}

		if(isdefined(model.damagetrigger))
		{
			model.damagetrigger Delete();
		}

		model Delete();
	}
}

function WatchForGrab()
{
	self.trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	self.trigger SetHintString( "Hold ^3&&1 ^7To Pick Up IMS" );
	self.trigger SetCursorHint( "HINT_NOICON" );
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] != self.owner)
		{
			self.trigger SetInvisibleToPlayer(players[i]);
		}
	}

	self.trigger SetVisibleToPlayer(self.owner);

	while(1)
	{
		self.trigger waittill("trigger", user);
		if(IsPlayer(user) && user UseButtonPressed() && user == self.owner && zm_utility::is_player_valid( user ) && self.ammo > 0 && self.owner.activeims == self && !IS_TRUE(self.imslaunching))
		{
			user GiveWeapon(level.ims_weapon);
			user SetActionSlot(4, "weapon", level.ims_weapon);
			user SetWeaponAmmoStock(level.ims_weapon, 1);
			self notify("ims_collected");
		}
	}
}

function ImsFunctionality()
{
	level endon("end_game");
	self endon("ims_ammo_out");
	self endon("ims_collected");
	while(isdefined(self))
	{
		WAIT_SERVER_FRAME;
		zombies = GetAITeamArray("axis");
		closest = ArrayGetClosest(self.origin, zombies);
		if(isdefined(closest) && Distance(closest.origin, self.origin) < 120 && SightTracePassed( closest.origin + (0, 0, 32), self.origin + (0, 0, 32), false, self) )
		{
			self.imslaunching = true;
			self PlaySound("ims_activate");
			//IPrintLnBold("Do Damage");
			self LaunchProjectile();
			wait(2);
			if(isdefined(self))
			{
				self.imslaunching = false;
			}
			
		}
	}
}

function GetAmmoIndex()	//self = ims model
{
	ammo = self.ammo;

	if(!isdefined(self.ammo))
	{
		self.ammo = 4;
	}

	switch(ammo)
	{
		case 1:
			index = 4;
			break;

		case 2:
			index = 3;
			break;

		case 3:
			index = 2;
			break;

		case 4:
			index = 1;
			break;

		default:
			index = 1;
			break;

	}

	return index;
}

function LaunchProjectile()
{
	index = self GetAmmoIndex();
	animation = "iw6_ims_door_" + index;
	tag = "tag_explosive" + index;
	exp_origin = self GetTagOrigin(tag);
	if(!isdefined(exp_origin))
	{
		exp_origin = self.origin;
	}

	//Debug
	//IPrintLnBold("Anim:" +animation);
	//IPrintLnBold("Tag:" +tag);

	model = Spawn("script_model", exp_origin);
	model SetModel("iw6_ims_explosive");

	self AnimScripted( "note_notify", self.origin, self.angles, animation );
	wait( GetAnimLength( animation ) + 0.8 );

	self HidePart(tag);
	self HidePart(tag + "_attach");

	self PlaySound("ims_launch");
	model MoveZ(70, 0.4);
	model waittill("movedone");

	self thread CreateExplosionDamage( model.origin, self.is_upgraded );

	if(!IS_TRUE(self.is_upgraded))
		PlayFX( FX_IMS_EXP, model.origin );

	else
	{
		PlayFX(FX_IMS_EXP_UG, model.origin);
		PlaySoundAtPosition("timewarp_slide_kill", model.origin);
	}


	model Delete();
	self.ammo--;
	if(isdefined(self.owner))
	{
		self.owner.imsammo = self.ammo;
	}

	if(self.ammo <= 0)
	{
		wait(2);
		self thread ImsDestroy( self.owner );
		self notify("ims_ammo_out");
	}

	else
	{
		new_anim = "iw6_ims_idle_" + index;
		self AnimScripted( "note_notify", self.origin, self.angles, new_anim );
	}

}

function CreateExplosionDamage( origin, is_upgraded )
{
	Earthquake(0.22, 0.5, origin, 200);
	zombies = GetAITeamArray("axis");
	if(IS_TRUE(is_upgraded))
	{
		radius = 325;
	}

	else
	{
		radius = 230;
	}

	closest = util::get_array_of_closest(origin, zombies, undefined, undefined, radius);
	for(i = 0; i < closest.size; i++)
	{
		WAIT_SERVER_FRAME;
		if( IsAlive(closest[i]) && BulletTracePassed( origin, 0, closest[i].origin, self ))
		{
			if( IS_TRUE(closest[i].is_boss) )
			{
				if(IS_TRUE(is_upgraded))
				{
					closest[i] DoDamage( 5000, closest[i].origin );
				}

				else
				{
					closest[i] DoDamage( 2000, closest[i].origin );
				}
				
			}

			else
			{
				if(IS_TRUE(is_upgraded))
				{
					closest[i] clientfield::set( "tesla_shock_eyes_fx", 1 );
					closest[i] PlaySound( "zmb_elec_jib_zombie" );
					WAIT_SERVER_FRAME;
					closest[i] DoDamage( closest[i].health +666, closest[i].origin );
					launch_vec = (RandomIntRange(20,50), RandomIntRange(20,50), RandomIntRange(80,150));
					closest[i] StartRagdoll();
					closest[i] LaunchRagdoll( launch_vec );
				}

				else
				{
					self zm_spawner::zombie_explodes_intopieces( true );
					closest[i] DoDamage(closest[i].health + 666, closest[i].origin);
					if(isdefined(self.owner))
					{
						self.owner.imskills++;
						if(self.owner.imskills == 20)
						{
							self.owner PlayLocalSound("afterlife_spawn");
							self.owner thread SpawnImsShockable();
							//self.owner thread ImsUpgradeShockable();
						}
					}
				}
				
			}
			
		}
	}
}

function ImsCleanup()
{
	self waittill( "ims_collected" );
	if(isdefined(self.ammo) && self.ammo <= 0 && isdefined(self.owner) && isdefined(self.owner.imsammo))
	{
		self.owner.imsammo = undefined;
	}

	if(isdefined(self.trigger))
	{
		self.trigger Delete();
	}

	if(isdefined(self.damagetrigger))
	{
		self.damagetrigger Delete();
	}

	if(isdefined(self.owner))
	{
		if(isdefined(self.owner.activeims))
		{
			self.owner.activeims = undefined;
		}
	}

	//PlayFX(FX_IMS_TIMEOUT, self.origin);
	//wait(1.5);
	self Delete();
}

function ImsDestroy( owner )
{
	//IPrintLnBold("Destroying IMS");
	if(isdefined(self.ammo) && self.ammo <= 0 && isdefined(self.owner) && isdefined(self.owner.imsammo))
	{
		self.owner.imsammo = undefined;
	}

	if(isdefined(self.trigger))
	{
		self.trigger Delete();
	}

	if(isdefined(self.damagetrigger))
	{
		self.damagetrigger Delete();
	}

	if(isdefined(self.owner))
	{
		if(isdefined(self.owner.activeims))
		{
			self.owner.activeims = undefined;
		}
	}

	PlayFX(FX_IMS_TIMEOUT, self.origin);
	self PlaySound("ims_destroy");
	wait(1.5);
	self Delete();
}

function SpawnImsShockable()	//self = ims owner
{
	spawn = struct::get("ims_buildable_struct","targetname");
	model = util::spawn_model("tag_origin", spawn.origin + (0, -2, 2));

	//trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	//trigger SetHintString( "Hold ^3&&1 ^7For Upgraded IMS" );
	//trigger SetCursorHint( "HINT_NOICON" );

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		model SetInvisibleToPlayer(players[i]);
		//trigger SetInvisibleToPlayer(players[i]);
	}

	while(1)
	{
		
		model waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		if(IsPlayer(e_attacker) && IS_TRUE(e_attacker.in_afterlife))
		{
			PlayFX(FX_IMS_EXP_UG, model.origin);
			WAIT_SERVER_FRAME;
			self.upgraded_ims = true;
			model Delete();
			//trigger Delete();
			self PlayLocalSound("afterlife_spawn");
			break;
		}
	
	}
}
