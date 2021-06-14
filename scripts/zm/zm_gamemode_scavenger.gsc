/*==========================================
Gun Game script by ihmiskeho
V1.0
Credits:

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
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_perks;
//#using scripts\zm\zm_gamemode_gungame;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\zm_afterlife_pe;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#precache("model", "p6_zm_perk_vulture_ammo");
#precache("model", "p7_ammo_pouch_k98");
#precache("model", "p7_crate_ammo_metal_small");

#define CHANCE_OF_DROP	8		//Chance of weapon/ammo drop, percentage
#define POWERUP_TIME	10

#namespace zm_gamemode_scavenger;

REGISTER_SYSTEM_EX( "zm_gamemode_scavenger", &init, &main, undefined )


function init()
{
	level.ScavDebug = false;
	level.scav_weapons = [];

	//Pistols
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("iw8_1911");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("m9a1");

	//Snipers
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_mosin");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("l115");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_xpr50");

	//ARs
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_m14");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("ak12");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("maverick");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_galil");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_m16");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("iw8_ak47");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("iw8_aug_ar");

	//SMGs
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("vepr");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_ak74");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t6_mp5");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("cbj_ms");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_sten");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("iw8_fennec");

	//Shotguns
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_olympia");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t6_spas12");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("h1_kam12");

	//Other
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("t7_china_lake");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("h1_rpg7");
	level.scav_weapons[level.scav_weapons.size] = GetWeapon("ray_gun");

	callback::on_connect( &OnConnect);

}

function main()
{
	level waittill("gamemode_chosen");
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_scavenger")
	{
		level thread GameModeDisableTriggers();
		zm_spawner::add_custom_zombie_spawn_logic( &ScavengerZombieDrops );
	}
}

function DebugPrint( string )
{
	if(!isdefined(level.GunGameDebug) || !level.GunGameDebug)
	{
		return;
	}

	IPrintLnBold("DEBUG: " +string);
}

function OnConnect()
{
	self waittill("spawned_player");
	//DebugPrint("Got Here");
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_scavenger")
	{
		self thread ScavengerStartWeapon();
		self.check_override_wallbuy_purchase = &ScavengerDisableWeapons;
		//self thread WatchLastStand();
	}

	else
	{
		level waittill("gamemode_chosen");
		//DebugPrint("GG: Gamemode Chosen");
		if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_scavenger")
		{
			DebugPrint("Scavenger");
			self thread ScavengerStartWeapon();
			self.check_override_wallbuy_purchase = &ScavengerDisableWeapons;
			//self thread WatchLastStand();
		}
	}
	
}

function ScavengerDisableWeapons( weapon, trigger )
{
	trigger SetHintString("Wall Weapons are Disabled in this Gamemode");
	wait(1);
	return true;
}

function GameModeDisableTriggers()
{
	wait(1);
	//DisableTrigger("afterlife_trigger");
	//DisableTrigger("digsite_trigger");
	//DisableTrigger("shovel_trigger");
	//DisableTrigger("weapon_upgrade");

	//Add triggers you don't want players to use in current gamemode
	/*DisabledTriggers = [];
	DisabledTriggers[DisabledTriggers.size] = GetEnt("weapon_upgrade","targetname");
	DisabledTriggers[DisabledTriggers.size] = GetEntArray("afterlife_trigger","targetname");
	DisabledTriggers[DisabledTriggers.size] = GetEntArray("digsite_trigger","targetname");
	DisabledTriggers[DisabledTriggers.size] = GetEntArray("shovel_trigger","targetname");
	DisabledTriggers[DisabledTriggers.size] = level.pack_a_punch.triggers;*/

	/*for(i = 0; i < DisabledTriggers.size; i++)
	{
		if(isdefined(DisabledTriggers[i]))
		{
			DisabledTriggers TriggerEnable( false );
		}
	}*/

	//Disable mystery box
	
	foreach( chest in level.chests )
	{
		chest.unitrigger_stub.prompt_and_visibility_func = &boxtrigger_update_prompt;
	}

	//DisabledPerks = [];
	//DisabledPerks[DisabledPerks.size] = "specialty_additionalprimaryweapon";
	//DisabledPerks[DisabledPerks.size] = "specialty_quickrevive";
	//DisabledPerks[DisabledPerks.size] = "specialty_widowswine";

	//for(i = 0; i < DisabledPerks.size; i++)
	//{
		//zm_perk_utility::global_pause_perk( DisabledPerks[i] );
		/*machine = (DisabledPerks[i], "script_noteworthy");
		if(isdefined(machine))
		{
			machine.bump triggerEnable( 0 );
			machine triggerEnable( 0 );
			machine.machine hide();
			machine zm_perks::perk_fx( undefined, 1 );
			PlayFX( level._effect[ "poltergeist" ], machine.origin );
			PlaySoundAtPosition( "zmb_box_poof", machine.origin );
		}*/
	//}
}

function DisableTrigger( targetname )
{
	trigs = GetEntArray(targetname,"targetname");
	foreach( trigger in trigs )
	{
		trigger TriggerEnable( false );
	}
}

function boxtrigger_update_prompt( player )
{
	can_use = self zm_magicbox::boxstub_update_prompt( player ) && !(level.CurrentGameMode == "zm_scavenger");
	if(isdefined(self.hint_string))
	{
		if (IsDefined(self.hint_parm1))
			self SetHintString( self.hint_string, self.hint_parm1 );
		else
			self SetHintString( self.hint_string );
	}
	if( !can_use && isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_scavenger")
		self SetHintString( "The Box is Disabled in This Gamemode" );
	return can_use;
}

function ScavengerStartWeapon()	//self = player
{
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_scavenger")
	{
		self TakeAllWeapons();
		WAIT_SERVER_FRAME;
		self zm_weapons::weapon_give( GetWeapon("m9a1"), 0, 0, 1, 1 );
		self zm_weapons::weapon_give( self zm_utility::get_player_melee_weapon() );
	}
}

function ScavengerZombieDrops()
{
	if(RandomInt(100) > CHANCE_OF_DROP)
	{
		return;
	}

	//Adding 50/50 change to drop either weapon, or ammo
	random = RandomInt(2);

	if(random > 0)	//Drop weapon here
	{
		weapon = ChooseScavengerWeapon();
		if(!isdefined(weapon))
		{
			return;
		}

		worldmodel = GetWeaponWorldModel( weapon );
		if(!isdefined(worldmodel))
		{
			return;
		}

		self Attach(worldmodel, "j_spine4");
		self.no_powerups = true; 
		self thread WeaponDropOnDeath( weapon, worldmodel );
	}

	else 	//Drop ammo here
	{
		ammo = GetAmmoType();
		switch(ammo)
		{
			case "clip":
			model = "p6_zm_perk_vulture_ammo";
			//model.type = "clip";
			break;

			case "half":
			model = "p7_ammo_pouch_k98";
			//model.type = "half";
			break;

			case "full":
			model = "p7_crate_ammo_metal_small";
			//model.type = "full";
			break;

			default:
			model = "p7_ammo_pouch_k98";
			//model.type = "half";
			break;
		}

		self.no_powerups = true; 
		self thread AmmoDropOnDeath( model );

	}
}

function WeaponDropOnDeath( weapon, worldmodel )
{
	if(!isdefined(weapon))
	{
		return;
	}

	if(!isdefined(worldmodel))
	{
		return;
	}

	self waittill("death");
	self Detach(worldmodel, "");
	origin = CheckNavMeshDirection( self.origin, AnglesToForward( self.angles ), 10, 20 ) + ( 0, 0, 35 );
	drop = Spawn("script_model", origin);
	isvalid = drop CheckPlayableArea();
	if(!isvalid)
	{
		drop Delete();
		return;
	}

	drop SetModel(worldmodel);
	drop thread zm_powerups::powerup_wobble();
	drop thread DeletePowerup( POWERUP_TIME );
	drop.trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	drop.trigger SetHintString( "Press ^3[{+activate}]^7 to Take Weapon" );
	drop.trigger SetCursorHint( "HINT_NOICON" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		drop.trigger waittill("trigger", user);
		if( isdefined( user ) && IsPlayer(user) && user IsTouching( drop.trigger ) && user UseButtonPressed() && zm_utility::is_player_valid( user ) )
		{
			if(user HasWeapon(GetWeapon("minigun")))	//Other weapons here
			{
				continue;
			}
		
			if(user laststand::player_is_in_laststand())
			{
				continue;
			}
		
			if(user HasWeapon(weapon))
			{
				user SwitchToWeapon(weapon);
				user GiveMaxAmmo(weapon);
			}

			else
			{
				user zm_weapons::weapon_give(weapon, false, false, true, true);
				user SwitchToWeapon(weapon);
			}

			drop.trigger Delete();
			drop Delete();
			user PlaySound("zmb_powerup_grabbed");		
		}	
	}
}

function AmmoDropOnDeath( model )
{
	if(!isdefined(model))
	{
		return;
	}

	if(!isdefined(model.type))
	{
		model.type = "half";
	}

	self waittill("death");
	origin = CheckNavMeshDirection( self.origin, AnglesToForward( self.angles ), 10, 20 ) + ( 0, 0, 35 );
	drop = Spawn("script_model", origin);
	isvalid = drop CheckPlayableArea();
	if(!isvalid)
	{
		drop Delete();
		return;
	}

	drop SetModel( model );
	drop thread zm_powerups::powerup_wobble();
	drop thread DeletePowerup( POWERUP_TIME );
	drop.trigger = Spawn("trigger_radius", self.origin, 0, 32, 32);
	drop.trigger SetHintString( "Press ^3[{+activate}]^7 to Take Ammo" );
	drop.trigger SetCursorHint( "HINT_NOICON" );

	while(1)
	{
		WAIT_SERVER_FRAME;
		drop.trigger waittill("trigger", user);
		if( isdefined( user ) && IsPlayer(user) && user IsTouching( drop.trigger ) && user UseButtonPressed() && zm_utility::is_player_valid( user ) )
		{
			if(user HasWeapon(GetWeapon("minigun")))	//Other weapons here
			{
				continue;
			}
		
			if(user laststand::player_is_in_laststand())
			{
				continue;
			}

			if(IS_TRUE(user.in_afterlife))
			{
				continue;
			}

			currentweapon = user GetCurrentWeapon();
			ammo_clip = currentweapon.clipSize;
			ammo_stock = user GetWeaponAmmoStock( currentweapon );

			if(IS_TRUE( currentweapon.isClipOnly ))
			{
				ammotogive = ammo_clip;
			}

			else
			{
				switch(model)
				{
					case "p6_zm_perk_vulture_ammo":
					ammotogive = ammo_clip;
					break;

					case "p7_ammo_pouch_k98":
					ammotogive = Int(ammo_clip * 2);
					break;

					case "p7_crate_ammo_metal_small":
					ammotogive = currentweapon.maxAmmo;
					break;

					default:
					ammotogive = Int(ammo_stock / 2);
					break;
				}
			}

			//IPrintLnBold("Ammo to Give: "+ammotogive);

			newammo = Int(ammo_stock + ammotogive);
			if(newammo >= currentweapon.maxAmmo)
			{
				user GiveMaxAmmo(currentweapon);
			} 

			else
			{
				user SetWeaponAmmoStock( currentweapon, newammo);
			}

			
			drop.trigger Delete();
			drop Delete();
			user PlaySound("zmb_powerup_grabbed");		
		}	
	}
}

function ChooseScavengerWeapon()	//Add all weapons here, can add as many as you like
{
	random = RandomInt(level.scav_weapons.size);
	return level.scav_weapons[ random ];
}

function GetAmmoType()		//This handles what kind of ammo drop this is. Can be clip, medium or full ammo
{
	ammo_types = [];
	ammo_types[ammo_types.size] = "clip";
	ammo_types[ammo_types.size] = "half";
	ammo_types[ammo_types.size] = "full";

	//Adding some bias here so that full clip is less rare
	random = RandomInt(100);
	if(random >= 0 && random < 50 )
		return ammo_types[0];

	else if(random >= 50 && random < 80)
		return ammo_types[1];

	else
		return ammo_types[2];

}

function CheckPlayableArea()	//self = drop model
{
	playable_area = GetEntArray( "player_volume", "script_noteworthy" );
	for(i = 0; i < playable_area.size; i++)
	{
		if(self IsTouching(playable_area[i]))
		{
			return true;
		}
	}

	return false;
}

function DeletePowerup( time )
{
	self endon("death");
	self endon("digobject_picked");
	if(!isdefined(time))
	{
		time = 15;
	}
	wait(time);
	for ( i = 0; i < 40; i++ )
	{
		// hide and show
		if ( i % 2 )
		{
			self zm_powerups::powerup_show( false );
		}
		else
		{
			self zm_powerups::powerup_show( true );
		}

		if ( i < 15 )
		{
			wait( 0.5 );
		}
		else if ( i < 25 )
		{
			wait( 0.25 );
		}
		else
		{
			wait( 0.1 );
		}
	}
	
	if(isdefined(self.trigger))
	{
		self.trigger Delete();
	}

	if(isdefined(self))
	{
		self Delete();
	}

}
