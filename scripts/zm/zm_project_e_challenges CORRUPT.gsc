#using scripts\codescripts\struct;
#using scripts\ik\zm_pregame_room;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_utility;	
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\zm_afterlife_pe;
#using scripts\zm\zm_project_e_ee;



							continue;
							continue;
							should_update_hint = true;
							user AwardPlayer( user.challenge_tier );
						continue;
						hint = user GetCurrentChallenge();
						if(!isdefined(hint))
						if(user UseButtonPressed())
						should_update_hint = false;
						should_update_hint = true;
						trigger SetHintString( "You have an unfinished Challenge: " + hint );
						user thread SelectRandomChallenge( user.challenge_tier );
						wait(.1);
						{
						}
					//IPrintLn("Progress: " +notify_param);
					//IPrintLnBold("Deleting trigger");
					break;
					break;
					break;
					continue;
					if(should_update_hint)
					if(user UseButtonPressed())
					if(user UseButtonPressed())
					self GiveMaxAmmo( weapon );
					self SwitchToWeapon( weapon );
					self thread ChallengeCompleted();
					self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
					self zm_weapons::weapon_give(weapon, false, false, true, true);			//_zm_weapons.gsc, line 2603       function weapon_give( weapon, is_upgrade = false, magic_box = false, nosound = false, b_switch_weapon = true )
					should_update_hint = false;
					sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_weappick_favorite_00";
					total++;
					trigger Delete();
					trigger SetHintString( "Hold ^3&&1 ^7To Accept Challenge [ Tier: " +user.challenge_tier + " ]" );
					trigger SetHintString( "Hold ^3&&1 ^7To Accept Reward [ Tier:  " + user.challenge_tier + " ] " );						
					wait(.1);
					{
					{
					{
					}
					}
					}
				break;
				else
				else 	//Now we can assume that the user has completed his challenge and is waiting for his reward
				if( self HasWeapon( weapon ))
				if( self HasWeapon(GetWeapon("minigun") ) || self laststand::player_is_in_laststand() )
				if( should_update_hint )
				if( user.challenge_tier > 3 )	//This player has done all challenges and accepted all rewards, delete the trigger
				if(IS_TRUE(user.challenge_active))	//User has an active challenge so let's not allow him to use this trigger
				if(total >= amount)
				if(user UseButtonPressed())
				if(valid)
				return true;
				return true;
				return true;
				return true;
				return;
				self thread ChallengeCompleted();
				self waittill( "zom_kill", zombie );
				self.challenge_skull = skulls[i];
				self.challenge_skull thread SpawnChallengeTrigger( self );
				valid = self CheckForValidChallengeKill( notify_param, zombie );
				{
				{
				{
				{
				{
				{
				{
				{
				{
				{
				}
				}
				}
				}
				}
				}
				}
				}
				}
				}
			//IPrintLn("Progress: " +str_notify);
			//IPrintLnBold("User not valid");
			//notify_param = "zombie";
			amount = 10000;
			amount = 100;
			amount = 1;
			amount = 2;
			amount = 30;
			amount = 40;
			amount = 50;
			amount = 50;
			amount = 50;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			break;
			challenges[challenges.size] = "explosive_kills";		//50 explosive kills
			challenges[challenges.size] = "explosive_kills";		//50 explosive kills
			challenges[challenges.size] = "gravityspike_kills";		//30 gravityspike kills
			challenges[challenges.size] = "headshot_kills";			//50 headshot kills
			challenges[challenges.size] = "headshot_kills";			//50 headshot kills
			challenges[challenges.size] = "kill_boss";				//Kill 2 Boss zombies						
			challenges[challenges.size] = "kills";					//50 kills
			challenges[challenges.size] = "melee_boss";				//Melee kill a boss zombie (not avogadro)
			challenges[challenges.size] = "pap_kills";				//100 Pap kills
			challenges[challenges.size] = "pap_kills";				//100 Pap kills
			challenges[challenges.size] = "spend_points";			//Spend 10000 points						
			challenges[challenges.size] = "trap_kills";				//Kill 40 Zombies with traps
			continue;
			else if( isdefined(user.current_challenge) )	//user has an active challenge, let's see if they are currently doing it or finished it
			hint = " [ Tier 1 ] Kill 2 Boss Zombies ";
			hint = " [ Tier 1 ] Kill 50 Zombies ";
			hint = " [ Tier 1 ] Spend 10 000 points ";
			hint = " [ Tier 2 ] Get 50 Headshot Kills ";
			hint = " [ Tier 2 ] Kill 100 Zombies with Upgraded Weapons ";
			hint = " [ Tier 2 ] Kill 50 Zombies with Explosives ";
			hint = " [ Tier 3 ] Kill 30 Zombies with the Ragnarok DG-4 ";
			hint = " [ Tier 3 ] Kill 40 Zombies with Traps ";
			hint = " [ Tier 3 ] Kill a Boss Zombie Using a Melee Weapon ";
			if( isdefined(zombie.damagemod) && (zombie.damagemod == "MOD_EXPLOSIVE" || zombie.damagemod == "MOD_GRENADE" || zombie.damagemod == "MOD_GRENADE_SPLASH" || zombie.damagemod == "MOD_PROJECTILE" || zombie.damagemod == "MOD_PROJECTILE_SPLASH") )
			if( isdefined(zombie.damageweapon) && zm_utility::is_hero_weapon( zombie.damageweapon ) )
			if( zm_utility::is_headshot( zombie.damageweapon, zombie.damagelocation, zombie.damagemod ) )
			if(!isdefined(user.current_challenge))
			if(isdefined(weapon))
			if(isdefined(zombie.damageweapon) && zm_weapons::is_weapon_upgraded(zombie.damageweapon))
			if(notify_param == "headshot" || notify_param == "explosive" || notify_param == "pap" || notify_param == "spikes" )
			if(skulls[i].script_int == self GetCharacterBodyType())
			if(total >= amount)
			notify_param = "explosive";
			notify_param = "headshot";
			notify_param = "pap";
			notify_param = "spikes";
			return false;
			return false;
			return false;
			return false;
			return false;
			return;
			self thread ChallengeCompleted();
			self thread CustomGivePerk( "mud_resistant" );
			self thread CustomGivePerk( "speed" );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallenge( hint, str_notify, notify_param, amount );
			self thread StartChallengePoints( hint, str_notify, amount );	//level notify( "spent_points", self, points );
			self waittill(str_notify);
			str_notify = "boss_zombie_kill";
			str_notify = "boss_zombie_kill_melee";
			str_notify = "spent_points";
			str_notify = "trap_kill";
			str_notify = "zom_kill";
			str_notify = "zom_kill";
			str_notify = "zom_kill";
			str_notify = "zom_kill";
			str_notify = "zom_kill";
			total++;
			trigger SetHintString( "" );
			valid_drop = true;
			weapon = self GetRewardWeapon();
			{
			{
			{
			{
			{
			{
			}
			}
			}
			}
			}
			}
		case "explosive":
		case "explosive_kills":
		case "explosive_kills":
		case "gravityspike_kills":
		case "gravityspike_kills":
		case "headshot":
		case "headshot_kills":
		case "headshot_kills":
		case "kill_boss":
		case "kill_boss":
		case "kills":
		case "kills":
		case "melee_boss":
		case "melee_boss":
		case "pap":
		case "pap_kills":
		case "pap_kills":
		case "spend_points":
		case "spend_points":
		case "spikes":
		case "trap_kills":
		case "trap_kills":
		case 1:
		case 1:		//Tier 1 reward is a character favorite weapon, Dem = Thompson, Nik = PPSh, Ric = MP40, Tak = Nambu II
		case 2:
		case 2: 		//Tier 2 reward is longer sprint time
		case 3:
		case 3:			//Tier 3 reward is mud resistance
		default:
		default:
		else
		else
		icon = "t6_specialty_mudresistance";
		icon = "t6_specialty_staminup_special";
		if (self istouching(playable_area[i]))
		if( IsPlayer(player) && player == self )
		if( IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user GetCurrentWeapon() != GetWeapon("minigun") )
		if(!self check_powerup_valid_position())
		if(isdefined(notify_param))
		if(isdefined(skulls[i].script_int))
		if(total >= amount)
		level waittill( "spent_points", player, points );
		level waittill("between_round_over");
		level waittill("gamemode_chosen");
		level.order_drop_this_round = 0;
		new_speed = 1.1;
		powerup Delete();
		return "100 Upgraded Weapon Kills";
		return "2 Boss Kills";
		return "30 Ragnarok DG-4 Kills";
		return "40 Trap Kills";
		return "50 Explosive Kills";
		return "50 Headshots";
		return "50 Zombie Kills";
		return "Melee Boss";
		return "Spend Points";
		return false;
		return;
		return;
		return;
		return;
		return;
		return;
		self SetMoveSpeedScale(1.1);
		self.custom_perk_hud_size = 1;
		self.default_move_speed = new_speed;
		self.mud_resistant = true;
		skulls[i] thread _Bobbing();	
		string = " + 10 Percent Speed Increase ";
		string = " Resistant to Mud ";
		tier = 1;
		tier = 1;
		total += points;
		trigger waittill("trigger", user);
		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
		{
		{
		{
		{
		{
		{
		{
		}
		}
		}
		}
		}
		}
		}
	/*skulls = GetEntArray("challenge_skull","targetname");
	/*text = NewClientHudElem(self);
	//chris_p - fixed bug where you could not have more than 1 playable area trigger for the whole map
	//level thread ServerInitChallenges();
	//returns a string indicating the current challenge
	a_weapons = [];
	a_weapons[0] = GetWeapon("s2_thompsonm1a1");
	a_weapons[1] = GetWeapon("s2_ppsh41_drum");
	a_weapons[2] = GetWeapon("bo3_mp40");
	a_weapons[3] = GetWeapon("s2_type2");
	amount = undefined;
	callback::on_spawned( &on_player_spawned );
	challenge = GetRandomChallenge( tier );
	challenges = [];
	else
	else if( perk == "mud_resistant" )
	for (i = 0; i < playable_area.size; i++)
	for(;;)
	for(i = 0; i < skulls.size; i++)
	for(i = 0; i < skulls.size; i++)
	hint = "Tier " + self.challenge_tier + " Challenge Completed";
	hint = undefined;
	hud = NewClientHudElem( self );
	hud FadeOverTime( .5 );
	hud ScaleOverTime( .5, 24, 24 );
	hud SetShader( icon, 48, 48 );
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.alpha = 0;
	hud.alpha = 1;
	hud.foreground = 1;
	hud.hidewheninmenu = 0;
	hud.horzAlign = "left";
	hud.sort = 1;
	hud.vertAlign = "bottom";
	hud.x = 90 + ( self.custom_perk_hud_size * 30 );
	hud.y = hud.y - 60;
	icon = undefined;
	if ( !isdefined( self.attacker ) || !IsPlayer( self.attacker ) )
	if( perk == "speed" )
	if(!isdefined(level.CurrentGameMode))
	if(!isdefined(self.current_challenge))
	if(!isdefined(self.custom_perk_hud_size))
	if(!isdefined(skulls))
	if(!isdefined(skulls))
	if(!isdefined(tier))
	if(!isdefined(tier))
	if(!isdefined(zombie))
	if(!valid_drop)
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame" )	//Gungame doens't allow challenges
	if(perk == "speed")
	if(RandomInt(100) <= ZOMBIE_DROP_CHANCE)
	level endon("end_game");
	level endon("end_game");
	level endon("end_game");
	level endon("end_game");
	level thread round_watcher();
	level.order_drop_this_round = 0;
	notify_param = undefined;
	playable_area = GetEntArray("player_volume","script_noteworthy");
	return a_weapons[self GetCharacterBodyType()];
	return challenges[RandomInt(challenges.size)];
	return false;
	self Bobbing( (0,0,1), 2, 1 );
	self endon( "delete" );
	self endon("disconnect");
	self endon("disconnect");
	self endon("disconnect");
	self PlayLocalSound("zmb_challenge_completed");
	self PlayLocalSound("zmb_challenge_completed");
	self thread ChallengeOnDisconnect();
	self thread ChallengesInit();
	self thread CreatePerkHint( perk );
	self thread zm_equipment::show_hint_text( hint, 4 );
	self thread zm_equipment::show_hint_text( hint, 4 );
	self waittill( "death" );
	self waittill("disconnect");
	self.challenge_active = false;
	self.challenge_active = false;	//TODO: Add something here???
	self.challenge_active = true;
	self.challenge_active = undefined;
	self.challenge_skull = undefined;
	self.challenge_skull = undefined;
	self.challenge_tier = 1;
	self.challenge_tier = undefined;
	self.challenge_tier++;
	self.current_challenge = challenge;
	self.current_challenge = undefined;
	self.current_challenge = undefined;
	self.current_challenge = undefined;
	self.custom_perk_hud_size = 0;
	self.custom_perk_hud_size = undefined;
	self.custom_perk_hud_size++;
	self.default_move_speed = 1.0;
	self.mud_resistant = false;
	should_update_hint = true;
	skulls = GetEntArray("challenge_skull","targetname");
	str_notify = undefined;
	string = "";
	switch(challenge)
	switch(notify_param)
	switch(self.current_challenge)
	switch(tier)
	switch(tier)
	text = NewClientHudElem(self);
	text = NewClientHudElem(self);
	text Delete();
	text Delete();
	text Delete();*/
	text FadeOverTime(0.5);
	text FadeOverTime(0.5);
	text FadeOverTime(0.5);
	text SetText( hint );
	text SetText( hint );
	text SetText( string );
	text.alignX = "center";
	text.alignX = "center";
	text.alignX = "center";
	text.alignY = "middle";
	text.alignY = "middle";
	text.alignY = "middle";
	text.alpha = 0;
	text.alpha = 0;
	text.alpha = 0;
	text.alpha = 1;
	text.alpha = 1;
	text.alpha = 1;
	text.fontScale = 1.5;
	text.fontScale = 1.5;
	text.fontScale = 1.5;
	text.fontType = "default";
	text.fontType = "default";
	text.fontType = "default";
	text.foreground = true;
	text.foreground = true;
	text.foreground = true;
	text.hidewheninmenu = true;
	text.hidewheninmenu = true;
	text.hidewheninmenu = true;
	text.horzAlign = "center";
	text.horzAlign = "center";
	text.horzAlign = "center";
	text.sort = 1;
	text.sort = 1;
	text.sort = 1;
	text.vertAlign = "bottom";
	text.vertAlign = "bottom";
	text.vertAlign = "bottom";
	text.y = -160;
	text.y = -160;
	text.y = -160;
	total = 0;
	total = 0;
	trigger = Spawn( "trigger_radius", self.origin, 0, 32, 32 );
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "" );
	trigger SetInvisibleToAll();
	trigger SetVisibleToPlayer( player );
	util::wait_network_frame();
	valid_drop = false;
	wait(3);
	wait(3);
	wait(4);
	while(1)
	while(1)
	while(isdefined(trigger))
	zm_spawner::add_custom_zombie_spawn_logic( &zombie_drop_challenge );
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	{
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}
	}*/
#define ZOMBIE_DROP_CHANCE	5		//The percentage chance of field order dropping
#define ZOMBIE_DROP_MAX		2		//Max drops per round
#insert scripts\shared\shared.gsh;
#namespace zm_project_e_challenges;
#precache("material", "t6_specialty_mudresistance");
#precache("material", "t6_specialty_staminup_special");

function _Bobbing()
function AwardPlayer( tier )	//self = player
function ChallengeCompleted()
function ChallengeOnDisconnect()
function ChallengesInit()
function check_powerup_valid_position()	//self = zombie
function CheckForValidChallengeKill( notify_param, zombie )
function CreatePerkHint( perk )
function CustomGivePerk( perk )
function GetCurrentChallenge()	//self = player
function GetRandomChallenge( tier )
function GetRewardWeapon()
function init()
function on_player_spawned()
function round_watcher()
function SelectRandomChallenge( tier )
function ServerInitChallenges()
function SpawnChallengeTrigger( player )
function StartChallenge( hint, str_notify, notify_param, amount )
function StartChallengePoints( hint, str_notify, amount )
function zombie_drop_challenge()
REGISTER_SYSTEM( "zm_project_e_challenges", &init, undefined )
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
{
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}
}