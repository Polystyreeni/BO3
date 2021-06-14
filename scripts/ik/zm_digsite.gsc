/*==========================================
DigSite script by ihmiskeho
V1.0
Credits:
JBird632: Hud element
Abnormal202: Some basic functions and syntax help
Mathfag = Zombie spawn help
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

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#define DIGSITE_OPEN									"dirt/fx_dust_drip_impact_redwood"
#precache( "fx", DIGSITE_OPEN ); 

#define SHOVEL_GLOW									"dlc4/genesis/fx_corrupteng_pillar_ember_top"
#precache( "fx", DIGSITE_OPEN ); 


#precache( "model", "zombie_z_money_icon" );
#precache( "material", "shovel_hud" );
#precache( "material", "shovel_hud_gold" );
#precache( "model", "wpn_t7_zmb_perk_bottle_gold" );

#namespace zm_digsite;

function init()
{
	//BEGIN: Can edit these
	level.dig_debug = false;				//Debug for testing (true, false)
	level.digsite_rounds = 2;	//How many rounds it takes before digsites respawn
	level.gold_shovel = 15;		//How many digs for player to get golden shovel
	//END: Can edit these

	RegisterClientField( "toplayer", "shovel_pickup",	VERSION_SHIP, 2, "int", undefined, false );

	callback::on_connect( &setShovelStatus);

	main();
}

function digsite_print( string )
{
	if(isDefined(level.dig_debug) && level.dig_debug)
	{
		IPrintLnBold("DEBUG:" +string);
	}
}

function main()
{
	digsite_trigs = GetEntArray("digsite_trigger", "targetname");
	shovels = GetEntArray("pickup_shovel","targetname");

	if(!isdefined(digsite_trigs) || digsite_trigs.size <= 0 || !isdefined(shovels) || shovels.size <= 0)
	{
		return;
	}

	for(i = 0; i< digsite_trigs.size; i++)
	{
		digsite_trigs[i] thread WatchSiteTrig();
	}

	for(j = 0; j< shovels.size; j++)
	{
		shovels[j] thread WatchShovelTrig();
	}

}

function setShovelStatus()
{
	self.has_shovel = false;
	self.has_gold_shovel = false;
	self.digs = 0;
}


function WatchShovelTrig()
{

	self.trigger = self CreateTrigger();
	old_user = undefined;

	should_update_hint = true;

	while(isdefined(self))
	{
		WAIT_SERVER_FRAME;
		self.trigger waittill("trigger", user);

		if( !isdefined(old_user) || user != old_user )
		{
			should_update_hint = true;
			old_user = user;
		}

		if(IS_TRUE(user.has_shovel))
		{
			if(should_update_hint)
			{
				self.trigger SetHintString("Already have a Shovel");
				should_update_hint = false;
			}
			
			continue;
		}

		if(IS_TRUE(user.in_afterlife))
		{
			continue;
		}

		if( !zm_utility::is_player_valid(user) )
		{
			continue;
		}

		self.trigger SetHintString("Press ^3[{+activate}]^7 to Pick Up Shovel");
		should_update_hint = true;
		
		if(user UseButtonPressed())
		{
			PlaySoundAtPosition("zmb_buildable_piece_add", self.origin);
			user.has_shovel = true;
			self Hide();
			self.trigger Delete();
			//user thread CreateShovelHud();
			user thread WatchShovelRespawn(self);	//Added in case a player disconnects. New joined players can also acquire shovel

			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_pickup_shovel_00";
			user thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
			user clientfield::set_to_player("shovel_pickup", 1);
		}
	}

	/*shovel = GetEnt(self.target, "targetname");
	PlayFXOnTag(SHOVEL_GLOW, shovel, "tag_origin");
	if(!isdefined(shovel))
	{
		digsite_print("Shovel trigger does not have a target!");
		return;
	}

	self SetHintString("Press ^3[{+activate}]^7 to Pick Up Shovel");
	self SetCursorHint("HINT_NOICON");
	while(isDefined(self))
	{
		self waittill("trigger", user);
		if( isdefined(user) && zm_utility::is_player_valid( user ) && !IS_TRUE(user.has_shovel) )
		{
			PlaySoundAtPosition("zmb_buildable_piece_add", shovel.origin);
			user.has_shovel = true;
			shovel Hide();
			self TriggerEnable(false);
			user thread CreateShovelHud();
			user thread WatchShovelRespawn(self, shovel);	//Added in case a player disconnects. New joined players can also acquire shovel
			
			sound_to_play = "vox_plr_" + user GetCharacterBodyType() + "_pickup_shovel_00";
			user thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
		}
		else
		{
			digsite_print("User not valid");
			self SetHintStringForPlayer( user, "Already Have a Shovel");
			user PlayLocalSound("no_purchace");
		}
		wait(0.05);
	}*/
}

function CreateTrigger()
{
	trig = Spawn("trigger_radius", self.origin, 0, 32, 32);
	trig SetCursorHint("HINT_NOICON");
	trig SetHintString( "Press ^3[{+activate}]^7 to Pick Up Shovel" );

	return trig;
}

function WatchShovelRespawn( shovel )
{
	self util::waittill_any("disconnect", "death");

	if(isdefined(self.shovelHud))
	{
		self.shovelHud hud::destroyElem();
		self.has_shovel = 0;
		self.digs = 0;
	}

	if(isdefined(shovel))
	{
		shovel Show();
		shovel thread WatchShovelTrig();
	}	
}


/*function WatchShovelRespawn(trigger, shovel)
{
	self util::waittill_any("disconnect", "death");
	if(isdefined(self.shovelHud))
	{
		self.shovelHud hud::destroyElem();
	}
	
	self.has_shovel = false;
	self.digs = 0;
	//self.shovelHud hud::destroyElem();
	trigger TriggerEnable(true);
	shovel Show();
}*/

function WatchSiteTrig()
{
	geo = GetEnt(self.target,"targetname");
	if(!isdefined(geo))
	{
		IPrintLnBold("ERROR: Digsite trigger does not have a target set!");
		return;
	}
	self SetHintString("Press ^3[{+activate}]^7 to Dig");
	self SetCursorHint("HINT_NOICON");
	while(isDefined(self))
	{
		self waittill("trigger", user);
		if(zm_utility::is_player_valid( user ) && IS_TRUE(user.has_shovel))
		{
			if(isdefined(user.digs) && user.digs < level.gold_shovel)
			{
				user.digs++;
				digsite_print("Digs:" +user.digs);
				if(user.digs == level.gold_shovel)
				{
					user notify("gold_acquired");
					user PlayLocalSound("shovel_upgrade");
					//user thread CreateGoldShovelHud();
					user clientfield::set_to_player("shovel_pickup", 2);
					if(!AnyPlayerHasGold())
					{
						self thread zm_project_e_ee::DigSiteMeteor();
						self.spawned_meteor = true;
					} 

					user.has_gold_shovel = true;
					
				}
			}
			geo Hide();
			PlayFXOnTag(DIGSITE_OPEN, self, "tag_origin");
			self PlaySound("digsite_crumble");
			self SetHintString("");
			if(!IS_TRUE(self.spawned_meteor))
			{
				self GiveRandomThing( user );
			}
			
			self waitForRespawn();
			self.spawned_meteor = false;
			geo Show();
			PlayFXOnTag(DIGSITE_OPEN, self, "tag_origin");
			self SetHintString("Press ^3[{+activate}]^7 to Dig");
		}
		else
		{
			digsite_print("Not valid user");
			self SetHintStringForPlayer( user, "Shovel Required");
			user PlayLocalSound("deny");
			wait(1);
			self SetHintStringForPlayer( user, "Press ^3[{+activate}]^7 to Dig");
		}
		wait(0.05);
	}
}

function AnyPlayerHasGold()
{
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(IS_TRUE(players[i].has_gold_shovel))
		{
			return true;
		}
	}

	return false;
}

function waitForRespawn()
{
	self endon("disconnect");
	i = 0;
	while( i < level.digsite_rounds)
	{
		level waittill("between_round_over");
		i = i + 1;
		wait(5);
	}
}

function GiveRandomThing(player)
{
	//self = trigger
	random = RandomInt(5);
	switch(random)
	{
		case 0:
		//Powerup
		digsite_print("Powerup");
		self thread spawnPwModel(player);
		break;

		case 1:
		digsite_print("Weapon");
		self thread GiveDigWeapon(player);
		break;

		case 2:
		//Spawn Zombie
		digsite_print("Zombie");
		self thread SpawnDigZombie();
		break;

		case 3:
		digsite_print("money");
		self thread BloodMoneyPickup();
		break;

		case 4:
		//Grenade
		digsite_print("BOOM");
		rand = RandomInt(2);
		self MagicGrenadeType( GetWeapon("frag_grenade"), self.origin, (0,0,225));
		if(rand == 1)
		{
			wait(.3);
			self MagicGrenadeType( GetWeapon("frag_grenade"), self.origin, (0,10,230));
		}
		break;
	}
}

function SpawnDigZombie()
{
	//Credit to mathfag (ModMe)
	dig_zombie = SpawnActor( "actor_spawner_zm_shangrila_zombie" ,self.origin,self.angles,"",true,true );	//dig_zombie = SpawnActor( "actor_spawner_zm_shangrila_zombie" ,self.origin,self.angles,"",true,true );

	dig_zombie zm_spawner::zombie_spawn_init( undefined );

	dig_zombie._rise_spot = self;
	dig_zombie.is_boss = 0;
	dig_zombie.gibbed = 1;
	dig_zombie.in_the_ground = 1;
	dig_zombie.ignore_enemy_count = 0;
	dig_zombie.ignore_nuke = 0;
	dig_zombie.no_powerups = 0;
	dig_zombie.no_damage_points = 0;
	dig_zombie.deathpoints_already_given = 0;

	dig_zombie.script_string = "find_flesh";

	dig_zombie zm_spawner::do_zombie_spawn();
}
function PickPowerUp(player)
{
	/*POWERUP MODEL NAMES:
	minigun	zombie_pickup_minigun
	fire_sale	
	bonus_points_player	
	insta_kill			p7_zm_power_up_insta_kill
	full_ammo			p7_zm_power_up_max_ammo
	double_points		p7_zm_power_up_double_points
	carpenter 			p7_zm_power_up_carpenter
	nuke				p7_zm_power_up_nuke
	*/
	model = [];
	model[model.size] = "p7_zm_power_up_double_points";
	model[model.size] = "p7_zm_power_up_carpenter";
	model[model.size] = "p7_zm_power_up_nuke";
	model[model.size] = "zombie_blood";

	if(IS_TRUE(player.has_gold_shovel))
	{
		model[model.size] = "p7_zm_power_up_max_ammo";
		model[model.size] = "zombie_pickup_minigun";
		model[model.size] = "p7_zm_power_up_insta_kill";

		//V2 Edit: Added a rare chance of free perks
		if(RandomInt(100) <= 95)
		{
			model[model.size] = "wpn_t7_zmb_perk_bottle_gold";
		}

	}

	random = RandomInt(model.size);
	model = model[random];
	return model;
}

function spawnPwModel(player)
{
	model = PickPowerUp(player);
	pow_model = Spawn("script_model", self.origin -(0,0,30));
	pow_model SetModel(model);

	pow_model MoveTo(self.origin + (0,0,20), 1);
	pow_model waittill("movedone");
	switch(model)
	{
		case "zombie_pickup_minigun":
		powerup = "minigun";
		break;

		case "p7_zm_power_up_insta_kill":
		powerup = "insta_kill";
		break;

		case "p7_zm_power_up_max_ammo":
		powerup = "full_ammo";
		break;

		case "p7_zm_power_up_double_points":
		powerup = "double_points";
		break;

		case "p7_zm_power_up_carpenter":
		powerup = "carpenter";
		break;

		case "p7_zm_power_up_nuke":
		powerup = "nuke";
		break;

		case "zombie_blood":
		powerup = "zombie_blood";
		break;

		case "wpn_t7_zmb_perk_bottle_gold":
		powerup = "free_perk";
		break;
	}
	
	if(isdefined(powerup))
	{
		zm_powerups::specific_powerup_drop( powerup, self.origin -(0,0,15));
		pow_model Delete();
	}
}



function pickWeapon(player)
{
	weapons = [];
	weapons[weapons.size] = "t7_mosin";		//EDIT: Change weapons here
	weapons[weapons.size] = "t7_m14";		//EDIT: Change weapons here
	weapons[weapons.size] = "iw8_1911";	//EDIT: Change weapons here
	weapons[weapons.size] = "t7_olympia";	//EDIT: Change weapons here

	if(IS_TRUE(player.has_gold_shovel))
	{
		weapons[weapons.size] = "sc2010";		//EDIT: Change weapons here
		weapons[weapons.size] = "t6_spas12";	//EDIT: Change weapons here
		weapons[weapons.size] = "t7_an94";		//EDIT: Change weapons here
		//EDIT: You can also add more weapons simply by copy pasting these lines
	}
	random = RandomInt(weapons.size);
	string = weapons[random];
	digsite_print("weapon:" +string);
	weapon = GetWeapon(string);
	return weapon;
}

function GiveDigWeapon(player)
{
	weapon = pickWeapon(player);
	digsite_print("Chose Weapon: " +weapon.displayname);
	model = Spawn("script_model", self.origin-(0,0,30));
	model SetModel(GetWeaponWorldModel(weapon));
	model MoveZ(60,1);
	model waittill("movedone");
	model thread deletePowerup(15);
	model thread zm_powerups::powerup_wobble();
	self SetHintString("");
	trig = Spawn("trigger_radius", self.origin, 9, 96, 96*2);
	trig SetCursorHint( "HINT_NOICON" );
	trig SetHintString("Press ^3[{+activate}]^7 to Take Weapon");
	trig thread DeleteAfterTime(26);
	while(isdefined(trig))
	{
		trig waittill( "trigger" ,user);
		if( isdefined( user ) && IsPlayer(user) && user IsTouching( trig ) && user UseButtonPressed() && zm_utility::is_player_valid( user ) )
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
			trig Delete();
			model notify("digobject_picked");
			model Delete();
			user PlaySound("zmb_powerup_grabbed");		
		}	
		wait (.05);
	}
}

function DeleteAfterTime(time)
{
	wait(time);
	if(isdefined(self))
	self Delete();
}

function BloodMoneyPickup()
{
	model = Spawn("script_model", self.origin);
	model SetModel("zombie_z_money_icon");
	model MoveZ(30,1);
	model waittill("movedone");
	PlaySoundAtPosition("zmb_spawn_powerup", self.origin);
	model thread zm_powerups::powerup_wobble();
	model thread deletePowerup(15);
	while(isdefined(model))
	{
		players = GetPlayers();
		if(!isdefined(players))
			return;

		for(i = 0; i < players.size; i++)
		{
			if(Distance(players[i].origin,model.origin) < 64)
			{
				random = RandomIntRange(1,20);		//EDIT: Can change points here, this number will be multiplied by 10
				if(players[i].has_gold_shovel)
				{
					random = random * 2;
				}
				
				score = random * 10;
				model notify("digobject_picked");
				model Delete();
				players[i] zm_score::add_to_player_score( score );
				players[i] PlaySound("zmb_powerup_grabbed");
				wait(.3);
					
				players[i] PlayLocalSound("zombie_money_vox");		//ADD: Blood money Quote
				wait(1);
				sound_to_play = "vox_plr_" + players[i] GetCharacterBodyType() + "_powerup_pts_solo_0" + RandomInt(2);
				players[i] thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );			

				
			}
			wait(0.05);
		}
		wait(0.05);
	}
}
function deletePowerup(time)
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
	self Delete();
}

function moveDigPowerups()
{
	self moveZ(-50,10);
	wait(10);
}

function ClearShovelHud()
{
	self clientfield::set_to_player( "shovel_pickup", 0 );
}

function CreateShovelHud( image = "shovel_hud", align_x = 50, align_y = 120, height = 30, width = 30, fade_time = .5 )
{
	self.shovelHud = NewClientHudElem(self);
	self.shovelHud.foreground = true;
    	self.shovelHud.sort = 1;
    	self.shovelHud.hidewheninmenu = true;
    	self.shovelHud.alignX = "right";
    	self.shovelHud.alignY = "bottom";
    	self.shovelHud.horzAlign = "right";
    	self.shovelHud.vertAlign = "bottom";
    	self.shovelHud.x = -align_x;
   	self.shovelHud.y = self.shovelHud.y - align_y;
    	self.shovelHud SetShader( image, width, height );

	//self clientfield::set("shovel_pickup", 1);

	self waittill("gold_acquired");
	self.shovelHud SetShader( "shovel_hud_gold", width, height );
}

function CreateGoldShovelHud( image = "shovel_hud_gold", align_x = 50, align_y = 120, height = 30, width = 30, fade_time = .5)
{
	IPrintLnBold("Create Gold Hud");
	self.shovelHud = NewClientHudElem(self);
	self.shovelHud.foreground = true;
    	self.shovelHud.sort = 1;
    	self.shovelHud.hidewheninmenu = true;
    	self.shovelHud.alignX = "right";
    	self.shovelHud.alignY = "bottom";
    	self.shovelHud.horzAlign = "right";
    	self.shovelHud.vertAlign = "bottom";
    	self.shovelHud.x = -align_x;
    	self.shovelHud.y = self.shovelHud.y - align_y;
    	self.shovelHud SetShader( image, width, height );

	self util::waittill_any( "death", "disconnect");
}