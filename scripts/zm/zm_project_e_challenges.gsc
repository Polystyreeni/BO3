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
#using scripts\zm\_zm_equipment;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#precache("material", "t6_specialty_mudresistance");
#precache("material", "t6_specialty_staminup_special");
#precache("model", "iw6_field_order");

#namespace zm_project_e_challenges;

REGISTER_SYSTEM_EX( "zm_project_e_challenges", &init, &main, undefined )

function init()
{
	RegisterClientField( "toplayer", "specialty_perk_obtained",	VERSION_SHIP, 2, "int", undefined, false );

	callback::on_connect( &on_player_spawned );
}

function main()
{
	level thread SkullsInit();
}

function on_player_spawned()
{
	self thread ChallengesInit();
	self thread ChallengeOnDisconnect();
}

function ChallengesInit()
{
	//self.challenge_skull = undefined;
	self.challenge_tier = 1;
	self.current_challenge = undefined;
	self.challenge_active = false;
	self.default_move_speed = 1.0;
	self.mud_resistant = false;
	//self.custom_perk_hud_size = 0;

	WAIT_SERVER_FRAME;
	level flag::wait_till( "initial_blackscreen_passed" );

	skulls = GetEntArray( "challenge_skull", "targetname" );
	if(!isdefined(skulls))
		return;

	for( i = 0; i < skulls.size; i++ )
	{
		if( isdefined(skulls[i].script_int) )
		{
			if( skulls[i].script_int == self GetCharacterBodyType() )
			{
				self.challenge_skull = skulls[i];
				self.challenge_skull thread SpawnChallengeTrigger( self );
			}
		}
	}
}

function SkullsInit()
{
	skulls = GetEntArray("challenge_skull", "targetname");
	if(!isdefined(skulls))
		return;

	foreach(skull in skulls)
	{
		skull thread _Bobbing();
	}
}

function _Bobbing()
{
	self Bobbing( (0,0,1), 2, 1 );
}

function SpawnChallengeTrigger( player )
{
	self endon("disconnect");
	level endon("end_game");

	if(!isdefined(level.CurrentGameMode))
	{
		level waittill("gamemode_chosen");
		if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame" )	//Challenges not active in gungame
		{
			return;
		}
	}
	
	trigger = Spawn( "trigger_radius", self.origin, 0, 32, 32 );
	trigger SetHintString( "" );
	trigger SetCursorHint( "HINT_NOICON" );

	trigger SetInvisibleToAll();
	util::wait_network_frame();
	trigger SetVisibleToPlayer( player );

	should_update_hint = true;

	while(isdefined(trigger))
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);

		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user GetCurrentWeapon() != GetWeapon("minigun") )
		{
			if( !isdefined(user.current_challenge) )
			{
				if( user.challenge_tier > 3 )	//This player has done all challenges and accepted all rewards, delete the trigger
				{
					//IPrintLnBold("Deleting trigger");
					trigger Delete();
					break;
				}

				if(should_update_hint)
				{
					trigger SetHintString( "Hold ^3&&1 ^7To Accept Challenge [ Tier: " +user.challenge_tier + " ]" );
					should_update_hint = false;
					continue;
				}

				if(user UseButtonPressed())
				{
					wait(.2);
					if(user UseButtonPressed())
					{
						user thread SelectRandomChallenge( user.challenge_tier );
						should_update_hint = true;
					}	
				}
			}

			else if( isdefined(user.current_challenge) )	//user has an active challenge, let's see if they are currently doing it or finished it
			{
				if(IS_TRUE(user.challenge_active))	//User has an active challenge so let's not allow him to use this trigger
				{
					if(should_update_hint)
					{
						hint = GetChallengeHint( user.current_challenge );
						trigger SetHintString( "You have an unfinished Challenge: " + hint );
						should_update_hint = false;
					}
					
				}

				else 	//Now we can assume that the user has completed his challenge and is waiting for his reward
				{
					should_update_hint = true;
					if(should_update_hint)
					{
						trigger SetHintString( "Hold ^3&&1 ^7To Accept Reward [ Tier:  " + user.challenge_tier + " ] " );
						should_update_hint = false;
						//continue;
					}

					if(user UseButtonPressed())
					{
						wait(.2);
						if( user UseButtonPressed() )
						{
							user AwardPlayer( user.challenge_tier );
							should_update_hint = true;
							continue;
						}
					}
				}
			}
		}

		else
		{
			//IPrintLnBold("User not valid");
			trigger SetHintString( "" );
			should_update_hint = true;
			continue;
		}
	}
}

function GetChallengeHint( challenge )
{
	if(!isdefined(Challenge))
		return " ";

	switch( challenge )
	{
		case "kills":
			return "Zombie Kills";

		case "spend_points":
			return "Spend Points";

		case "kill_boss":
			return "Kill Boss Zombies";

		case "headshot_kills":
			return "Headshot Kills";

		case "explosive_kills":
			return "Explosive Kills";

		case "pap_kills":
			return "Upgraded Weapon Kills";

		case "trap_kills":
			return "Trap Kills";

		case "gravityspike_kills":
			return "Ragnarok DG-4 Kills";

		case "melee_boss":
			return "Melee Boss Zombie";
	}
}

function SelectRandomChallenge( tier )
{
	if(!isdefined(tier))
		tier = 1;

	challenge = GetRandomChallenge( tier );

	self.current_challenge = challenge;
	self.challenge_active = true;

	hint = undefined;
	str_notify = undefined;
	notify_param = undefined;
	amount = undefined;

	switch(challenge)
	{
		case "kills":
			hint = " [Tier 1] Kill 50 Zombies ";
			str_notify = "zom_kill";
			//notify_param = "zombie";
			amount = 50;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "spend_points":
			hint = " [Tier 1] Spend 10 000 points ";
			str_notify = "spent_points";
			amount = 10000;
			self thread StartChallengePoints( hint, str_notify, amount );	//level notify( "spent_points", self, points );
			break;

		case "kill_boss":
			hint = " [Tier 1] Kill 2 Boss Zombies ";
			str_notify = "boss_zombie_kill";
			amount = 2;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "headshot_kills":
			hint = " [Tier 2] Get 50 Headshot Kills ";
			str_notify = "zom_kill";
			notify_param = "headshot";
			amount = 50;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "explosive_kills":
			hint = " [Tier 2] Kill 40 Zombies with Explosives ";
			str_notify = "zom_kill";
			notify_param = "explosive";
			amount = 40;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "pap_kills":
			hint = " [Tier 2] Kill 80 Zombies with Upgraded Weapons ";
			str_notify = "zom_kill";
			notify_param = "pap";
			amount = 80;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "trap_kills":
			hint = " [Tier 3] Kill 30 Zombies with Traps ";
			str_notify = "trap_kill";
			amount = 30;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "gravityspike_kills":
			hint = " [Tier 3] Kill 30 Zombies with the Ragnarok DG-4 ";
			str_notify = "zom_kill";
			notify_param = "spikes";
			amount = 30;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;

		case "melee_boss":
			hint = " [Tier 3] Kill a Boss Zombie Using a Melee Weapon ";
			str_notify = "boss_zombie_kill_melee";
			amount = 1;
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			break;
	}
}

function StartChallenge( hint, str_notify, notify_param, amount )
{
	self endon("disconnect");
	level endon("end_game");

	self PlaySoundToPlayer( "zmb_challenge_completed", self );

	self thread zm_equipment::show_hint_text( hint, 4 );

	total = 0;

	while(1)
	{
		WAIT_SERVER_FRAME;
		if(isdefined(notify_param))
		{
			if(notify_param == "headshot" || notify_param == "explosive" || notify_param == "pap" || notify_param == "spikes" )
			{
				self waittill( "zom_kill", zombie );
				valid = self CheckForValidChallengeKill( notify_param, zombie );
				if(valid)
				{
					total++;
					//IPrintLn("Progress: " +notify_param);
				}

				if(total >= amount)
				{
					self thread ChallengeCompleted();
					break;
				}

			}
			
		}

		else
		{
			self waittill(str_notify);
			total++;
			//IPrintLn("Progress: " +str_notify);
			if(total >= amount)
			{
				self thread ChallengeCompleted();
				break;
			}
		}

	}
}

function CheckForValidChallengeKill( notify_param, zombie )
{
	if(!isdefined(zombie))
		return false;

	switch(notify_param)
	{
		case "headshot":
			if( zm_utility::is_headshot( zombie.damageweapon, zombie.damagelocation, zombie.damagemod ) )
				return true;

			return false;

		case "explosive":
			if( isdefined(zombie.damagemod) && (zombie.damagemod == "MOD_EXPLOSIVE" || zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" || zombie.damagemod == "MOD_PROJECTILE" || zombie.damagemod == "MOD_PROJECTILE_SPLASH") )
				return true;

			return false;

		case "pap":
			if(isdefined(zombie.damageweapon) && zm_weapons::is_weapon_upgraded(zombie.damageweapon))
				return true;

			return false;

		case "spikes":
			if( isdefined(zombie.damageweapon) && zm_utility::is_hero_weapon( zombie.damageweapon ) )
				return true;

			return false;

		default:
			return false;

	}

	return false;
}

function StartChallengePoints( hint, str_notify, amount )
{
	self endon("disconnect");
	level endon("end_game");

	text = NewClientHudElem(self);
	text.foreground = true;
	text.fontScale = 1.5;
	text.fontType = "default";
	text.sort = 1;
	text.hidewheninmenu = true;
	text.alignX = "center";
	text.alignY = "middle";
	text.horzAlign = "center";
	text.vertAlign = "bottom";
	text.y = -160;
	text.alpha = 1;
	text SetText( hint );
	wait(4);
	text FadeOverTime(0.5);
	text.alpha = 0;
	text Delete();

	total = 0;

	while(1)
	{
		level waittill( "spent_points", player, points );
		if( IsPlayer(player) && player == self )
		total += points;
		if(total >= amount)
		{
			self thread ChallengeCompleted();
			break;
		}
	}
}

function ChallengeCompleted()
{
	self PlaySoundToPlayer( "zmb_challenge_completed", self );
	self.challenge_active = false;	//TODO: Add something here???

	hint = "Tier " + self.challenge_tier + " Challenge Completed";

	self thread zm_equipment::show_hint_text( hint, 4 );
	//self thread AwardPlayer( self.challenge_tier );

}

function AwardPlayer( tier )	//self = player
{
	if(!isdefined(tier))
		tier = 1;

	switch(tier)
	{
		case 1:
		self give_random_weapon(self GetRewardWeapon());
		break;

		case 2:
		self thread CustomGivePerk( "speed" );
		break;

		case 3:
		self thread CustomGivePerk( "mud_resistant" );
		break;

		default:
		self give_random_weapon(self GetRewardWeapon());
		break;

	}

	self.challenge_tier++;
	self.current_challenge = undefined;
}

function GetRandomReward( tier )
{
	rewards = [];
	rewards[rewards.size] = "random_weapon";
	rewards[rewards.size] = "fire_sale";
	rewards[rewards.size] = "minigun";

	if(tier >= 3)
	{
		rewards[rewards.size] = "free_perk";
		rewards[rewards.size] = "free_packapunch";
	}

	else if(tier >= 2)
	{
		rewards[rewards.size] = "full_ammo";
		rewards[rewards.size] = "unique_weapon";
	}

	return rewards[RandomInt(rewards.size)];
}

function give_random_weapon(weapon = undefined)	//self = user
{
	if(self HasWeapon(GetWeapon("minigun")))	//Other weapons here
	{
		return;
	}
		
	if(self laststand::player_is_in_laststand())
	{
		return;
	}
		
	if(self HasWeapon(weapon))
	{
		self SwitchToWeapon(weapon);
		self GiveMaxAmmo(weapon);
	}

	else
	{
		self zm_weapons::weapon_give(weapon, false, false, true, true);
		self SwitchToWeapon(weapon);
	}

	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_weappick_favorite_00";
	self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
}

function GetRewardWeapon()
{
	a_weapons = [];

	a_weapons[0] = GetWeapon("s2_thompsonm1a1");
	a_weapons[1] = GetWeapon("s2_ppsh41_drum");
	a_weapons[2] = GetWeapon("bo3_mp40");
	a_weapons[3] = GetWeapon("s2_type2");

	return a_weapons[self GetCharacterBodyType()];

}

function GetRandomChallenge( tier )
{
	challenges = [];

	switch(tier)
	{
		case 1:
			challenges[challenges.size] = "kills";					//50 kills
			challenges[challenges.size] = "spend_points";			//Spend 10000 points						
			challenges[challenges.size] = "kill_boss";				//Kill 2 Boss zombies						
			break;

		case 2:
			challenges[challenges.size] = "headshot_kills";			//50 headshot kills
			challenges[challenges.size] = "explosive_kills";		//50 explosive kills
			challenges[challenges.size] = "pap_kills";				//100 Pap kills
			break;

		case 3:
			challenges[challenges.size] = "trap_kills";				//Kill 40 Zombies with traps
			challenges[challenges.size] = "gravityspike_kills";		//30 gravityspike kills
			challenges[challenges.size] = "melee_boss";				//Melee kill a boss zombie (not avogadro)
			break;

		default:
			challenges[challenges.size] = "headshot_kills";			//50 headshot kills
			challenges[challenges.size] = "explosive_kills";		//50 explosive kills
			challenges[challenges.size] = "pap_kills";				//100 Pap kills
			break;
	}

	return challenges[RandomInt(challenges.size)];
}


function ChallengeOnDisconnect()
{
	self waittill("disconnect");
	self.challenge_skull = undefined;
	self.challenge_tier = undefined;
	self.current_challenge = undefined;
	self.challenge_active = undefined;
	self.custom_perk_hud_size = undefined;
}

function CustomGivePerk( perk )
{
	icon = undefined;

	if( perk == "speed" )
	{
		new_speed = 1.1;
		self SetMoveSpeedScale(1.1);
		self.default_move_speed = new_speed;
		self clientfield::set_to_player("specialty_perk_obtained", 1);
		
	}

	else if( perk == "mud_resistant" )
	{
		self.mud_resistant = true;
		self clientfield::set_to_player("specialty_perk_obtained", 2);
	}

	self thread CreatePerkHint( perk );
}

function ClearPerkHud()		// Hide perk icons, used for end cutscene
{
	self clientfield::set_to_player("specialty_perk_obtained", 0);
}

function CreatePerkHint( perk )
{
	string = "";
	if( perk == "speed" )
		string = " + 10 Percent Speed Increase ";
	
	else
		string = " Resistant to Mud ";

	text = NewClientHudElem(self);
	text.foreground = true;
	text.fontScale = 1.5;
	text.fontType = "default";
	text.sort = 1;
	text.hidewheninmenu = true;
	text.alignX = "center";
	text.alignY = "middle";
	text.horzAlign = "center";
	text.vertAlign = "bottom";
	text.y = -160;
	text.alpha = 1;
	text SetText( string );
	wait(3);
	text FadeOverTime(0.5);
	text.alpha = 0;
	text Delete();
}
