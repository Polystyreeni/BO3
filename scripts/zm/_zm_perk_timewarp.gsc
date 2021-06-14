/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###             																			  	  ###
###                                                                   							  ###
###                                                                   							  ###
###========================================#*/
/*============================================

								CREDITS

=============================================
WillJones1989
alexbgt
NoobForLunch
Symbo
TheIronicTruth
JAMAKINBACONMAN
Sethnorris
Yen466
Lilrifa
Easyskanka
Will Luffey
ProRevenge
DTZxPorter
Zeroy
JBird632
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MadGaz
MZSlayer
AndyWhelen
Collie
HitmanVere
ProGamerzFTW
Scobalula
Azsry
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
TheSkyeLord
===========================================*/
#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\shared\hud_util_shared;
#using scripts\shared\abilities\gadgets\_gadget_flashback;
#using scripts\zm\_zm_score;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_unitrigger;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_perk_timewarp.gsh;

#precache( "fx", 		"dlc1/castle/fx_castle_electric_cherry_trail" );
#precache( "fx", 		TIMEWARP_MACHINE_LIGHT_FX );
#precache("fx", "dlc1/castle/fx_elec_teleport_flash_sm");

#namespace zm_perk_timewarp;

REGISTER_SYSTEM_EX( "zm_perk_timewarp", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( IS_TRUE( TIMEWARP_LEVEL_USE_PERK ) )
		enable_timewarp_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( TIMEWARP_LEVEL_USE_PERK ) )
		timewarp_main();
	
}


function enable_timewarp_for_level()
{	
	zm_perks::register_perk_basic_info( 								TIMEWARP_PERK, TIMEWARP_ALIAS, 									TIMEWARP_PERK_COST, 				"Hold ^3[{+activate}]^7 for Glitch Gin [Cost: &&1]", getWeapon( TIMEWARP_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 						TIMEWARP_PERK, &timewarp_precache );
	zm_perks::register_perk_clientfields( 								TIMEWARP_PERK, &timewarp_register_clientfield, 					&timewarp_set_clientfield );
	zm_perks::register_perk_machine( 									TIMEWARP_PERK, &timewarp_machine_setup );
	zm_perks::register_perk_threads( 									TIMEWARP_PERK, &timewarp_give_perk, 								&timewarp_take_perk );
	zm_perks::register_perk_host_migration_params( 			TIMEWARP_PERK, TIMEWARP_RADIANT_MACHINE_NAME, 	TIMEWARP_PERK );
	// zm_perks::register_perk_machine_power_override( 	TIMEWARP_PERK, &timewarp_host_migration_func );
}

function timewarp_precache()
{
	level._effect[ TIMEWARP_PERK ]									= TIMEWARP_MACHINE_LIGHT_FX;
	
	level.machine_assets[ TIMEWARP_PERK ] 					= spawnStruct();
	level.machine_assets[ TIMEWARP_PERK ].weapon 		= getWeapon( TIMEWARP_BOTTLE_WEAPON );
	level.machine_assets[ TIMEWARP_PERK ].off_model 	= TIMEWARP_MACHINE_DISABLED_MODEL;
	level.machine_assets[ TIMEWARP_PERK ].on_model 	= TIMEWARP_MACHINE_ACTIVE_MODEL;	
}

function timewarp_register_clientfield() 
{
	clientfield::register( "clientuimodel", TIMEWARP_CLIENTFIELD, VERSION_SHIP, 2, "int" );
}

function timewarp_set_clientfield( state ) 
{
	self clientfield::set_player_uimodel( TIMEWARP_CLIENTFIELD, state );
}

function timewarp_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound 						= TIMEWARP_JINGLE;
	use_trigger.script_string 						= TIMEWARP_SCRIPT_STRING;
	use_trigger.script_label 							= TIMEWARP_STING;
	use_trigger.target 								= TIMEWARP_RADIANT_MACHINE_NAME;
	perk_machine.script_string 					= TIMEWARP_SCRIPT_STRING;
	perk_machine.targetname 					= TIMEWARP_RADIANT_MACHINE_NAME;
	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string 				= TIMEWARP_SCRIPT_STRING;
	
}

function timewarp_give_perk( b_pause, str_perk, str_result )
{
	// SELF == PLAYER
	// GIVE PERK STUFF HERE
	if ( level zm_perk_utility::is_perk_paused( TIMEWARP_PERK ) )
		self zm_perk_utility::player_pause_perk( TIMEWARP_PERK );
	
	if ( self zm_perk_utility::is_perk_paused( TIMEWARP_PERK ) )
		return;
	
	self timewarp_enabled( 1 );
}

function timewarp_take_perk( b_pause, str_perk, str_result )
{
	// SELF == PLAYER
	// LOSE PERK STUFF HERE
	self timewarp_enabled( 0 );
	if(isdefined(self.timewarpProgressBar))
	{
		self.timewarpProgressBar hud::destroyElem();
	}

	if(isdefined(self.timewarpProgressBarText))
	{
		self.timewarpProgressBarText hud::destroyElem();
	}

	self UnSetPerk("specialty_sprintfire");
}

function timewarp_host_migration_func()
{
	a_custom_perk_machines = GetEntArray( TIMEWARP_RADIANT_MACHINE_NAME, "targetname" );
	
	foreach ( perk_machine in a_custom_perk_machines )
	{
		if ( isDefined( perk_machine.model ) && perk_machine.model == TIMEWARP_MACHINE_ACTIVE_MODEL )
		{
			perk_machine zm_perks::perk_fx( undefined, 1 );
			perk_machine thread zm_perks::perk_fx( TIMEWARP_ALIAS );
		}
	}
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function timewarp_main()
{
	// SELF == LEVEL
	// PERK SETUP STUFF HERE
	//level._effect[ "electric_cherry_trail" ] = "dlc1/castle/fx_castle_electric_cherry_trail";
	clientfield::register( "allplayers", 	"timewarp_slide_fx", 		VERSION_SHIP, 	2, "int" );
	
}

function timewarp_enabled( enabled )
{
	//self = player
	if ( IS_TRUE( enabled ) )
	{
		if(!isdefined(self.has_used_perk))
		{
			self thread CreatePerkHint();
			self.has_used_perk = true;
		}

		self thread timewarp_setup();
		self thread timewarp_slide();
		self SetPerk("specialty_sprintfire");
	}
		
	else
		self notify( "stop_timewarp" );
}

function CreatePerkHint()
{
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
	text SetText("Prone and Hold ^3[{+activate}]^7 to save location, Hold ^3[{+activate}]^7 To Teleport to Location (Cooldown after use)" );
	wait(3);
	text FadeOverTime(0.5);
	text.alpha = 0;
	text Delete();
}

function timewarp_setup()
{
	//self = player
	self endon("disconnect");
	self endon("death");
	self endon("stop_timewarp");

	self thread watchOrigin();
	self thread ClearTimewarpHud();
	for(;;)
	{
		if( self UseButtonPressed() && !isdefined(self.timewarp_inactive) && self CanUseTimewarp() )
		{
			wait(.3);
			if(self UseButtonPressed() && self CanUseTimewarp() )
			{
				if(self GetStance() == "prone")
				{
					text = "Saving Location...";
				}

				else
				{
					text = "Activating Timewarp...";
				}

				time = 0;
				
				self.timewarpProgressBar = self hud::createPrimaryProgressBar();
				self.timewarpProgressBarText = self hud::createPrimaryProgressBarText();
				self.timewarpProgressBarText SetText(text);
				while(self UseButtonPressed() && self CanUseTimewarp() )
				{
					time = time + 0.2;
					self.timewarpProgressBar hud::updateBar( (time / 2), 0.0 );
					if(time >= 2)
					{
						//Destroy HUD
						self.timewarpProgressBar hud::destroyElem();
						self.timewarpProgressBarText hud::destroyElem();
						self.timewarpProgressBar Destroy();
						self.timewarpProgressBarText Destroy();
						if(self GetStance() == "prone")
						{
							self SaveLocation();
						}

						else
						{
							self DoTimeWarpTele();
						}
						
				
					}
					wait(.1);
				}

				self.timewarpProgressBar hud::destroyElem();
				self.timewarpProgressBarText hud::destroyElem();
				self.timewarpProgressBar Destroy();
				self.timewarpProgressBarText Destroy();
			}
			
		}

		WAIT_SERVER_FRAME;
	}
}

function ClearTimewarpHud()
{
	self util::waittill_any( "fake_death", "death", "disconnect", "stop_timewarp" );
	
	if(isdefined(self.timewarpProgressBar))
	{
		self.timewarpProgressBar hud::destroyElem();
	}

	if(isdefined(self.timewarpProgressBarText))
	{
		self.timewarpProgressBarText hud::destroyElem();
	}
	
}

function SaveLocation()
{
	self.saved_position = self.origin + (0, 0, 10);
	self.saved_angles = self GetAngles();
	self PlaySound("zmb_bgb_abh_teleport_in");
	PlayFX(level._effect["fx_elec_teleport_flash_sm"], self.saved_position);

}

function timewarp_slide()
{
	//self = player
	self endon("disconnect");
	self endon("death");
	self endon("stop_timewarp");

	clientfield_active = false;

	while(1)
	{
		if( self IsOnSlide() )
		{
			if(!clientfield_active)
			{
				clientfield_active = true;
				self clientfield::set("timewarp_slide_fx", 1);
			}

			forward = AnglesToForward(self GetPlayerAngles());
			self thread timewarp_slide_speed( forward );
			if(!isdefined(self.timewarp_slide_cooldown))
			{
				self thread timewarp_stun_slide();
				self thread timewarp_slide_cooldown();
				//self.timewarp_model = Spawn("script_model", self GetTagOrigin("j_spine4"));
				//self.timewarp_model SetModel("tag_origin");
				//self.timewarp_model LinkTo(self);
				//PlayFXOnTag(level._effect[ "electric_cherry_trail" ], self.timewarp_model, "tag_origin");
			}
		}

		if(clientfield_active)
		{
			clientfield_active = false;
			self clientfield::set("timewarp_slide_fx", 0);
			
		}

		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
		WAIT_SERVER_FRAME;
	}
}

function timewarp_slide_speed( forward )		//Credit to madgaz, harry, nate (banana colada script)
{
	//angles = self GetPlayerAngles();
	//angles_forward = forward;
	//push = VectorScale( angles_forward, 400 );
	if ( self IsOnSlide() )
	{
		v = ( self GetVelocity() * 1.1 );
        self SetVelocity( v );
        wait .05;
	}
}

function timewarp_slide_cooldown()
{
	self.timewarp_slide_cooldown = true;
	wait( TIMEWARP_SLIDE_COOLDOWN );	//Placeholder, change later
	self.timewarp_slide_cooldown = undefined;
}

function timewarp_stun_slide()
{
	kill_slide = RandomInt(100) < TIMEWARP_SLIDE_KILL_PERCENT;
	if( kill_slide )
	{
		self PlayLocalSound("timewarp_slide_kill");
	}

	else
	{
		self PlayLocalSound("timewarp_slide_0" + RandomInt(3));
	}

	while(self IsSliding())
	{
		zombies = GetAITeamArray("axis");
		zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 100);

		for(i = 0; i < zombies.size; i++)
		{
			if(IsAlive(zombies[i]) && !IS_TRUE(zombies[i].timewarp_stunned))
			{
				if(IS_TRUE(zombies[i].isdog))
				{
					zombies[i] DoDamage( Int(zombies[i].health / 2 + 200), zombies[i].origin, self );
					continue;
				}

				if(!kill_slide)
				{
					zombies[i] thread StunZombie( 2, 4, self );
				}

				else
				{
					zombies[i] thread TimewarpLaunchZombie( self );
				}
				
			}
		}

		WAIT_SERVER_FRAME;
	}
}

function StunZombie( min_time, max_time, owner )
{
	if(!isdefined(min_time))
		min_time = 2;

	if(!isdefined(min_time))
		min_time = 4;

	if(!isdefined(owner))
		return;

	self.ignoreall = true;
	self.timewarp_stunned = true;
	self clientfield::set( "tesla_shock_eyes_fx", 1 );
	self PlaySound( "zmb_elec_jib_zombie" );

	self thread StopAndStunZombie();

	wait( RandomIntRange( min_time, max_time ) );

	if( isdefined(self) && IsAlive(self) )
	{
		self.ignoreall = false;
		self.timewarp_stunned = false;
		self clientfield::set( "tesla_shock_eyes_fx", 0 );
	}
}

function TimewarpLaunchZombie( owner )
{
	if(IS_TRUE(self.is_boss))
	{
		self thread StunZombie( 2, 4 );
		return;
	}
	//self PlaySound( "timewarp_slide_kill" );
	self.timewarp_stunned = true;
	self clientfield::set( "tesla_shock_eyes_fx", 1 );
	self PlaySound( "zmb_elec_jib_zombie" );
	WAIT_SERVER_FRAME;
	self DoDamage( self.health +666, self.origin );
	self StartRagdoll();
	launch_vec = (RandomIntRange(20,50), RandomIntRange(20,50), RandomIntRange(80,150));
	self LaunchRagdoll( launch_vec );

	owner zm_score::add_to_player_score( 60 * level.zombie_vars[owner.team]["zombie_point_scalar"] );
	owner.kills++;

}

function StopAndStunZombie()
{
	self endon("death");

	self notify( "stun_zombie" );
	self endon( "stun_zombie" );

	if ( self.health <= 0 )
		return;
	
	if ( self.ai_state !== "zombie_think" )
		return;	
	
	self.zombie_tesla_hit = 1;		
	self.ignoreall = 1;

	wait 2;

	if ( isDefined( self ) )
	{	
		self.zombie_tesla_hit = 0;		
		self.ignoreall = 0;
		self notify( "stun_fx_end" );	
	}
}
	
function DoTimeWarpTele()
{
	old_pos = self.origin;

	self.timewarp_inactive = true;
	self thread StunNearZombies();
	//IPrintLnBold("Set New Origin");
	self PlayLocalSound("timewarp_teleport");
		//
	if(isdefined(self.saved_position))
	{
		self SetOrigin(self.saved_position);
		self SetPlayerAngles(self.saved_angles);
	}

	else
	{
		self SetOrigin(self.stored_pos);
		self SetPlayerAngles(self.stored_ang);
	}

	util::wait_network_frame();
	self thread StunNearZombies();
	PlayFX(level._effect["fx_elec_teleport_flash_sm"], self.origin);
	PlayFX(level._effect["teleport_splash"], self.origin);
	PlayFX(level._effect["teleport_aoe"], self.origin);

	//self thread flashback::flashbackTrailFx( 1, self GetCurrentWeapon(), old_pos, self.stored_pos );

	wait( TIMEWARP_TELE_COOLDOWN );

	self.timewarp_inactive = undefined;
}

function watchOrigin()
{
	self endon("death");
	self endon("disconnect");
	self endon("stop_timewarp");

	//self.saved_position = undefined;
	//self.saved_angles = undefined;

	self.stored_pos = self.origin;
	self.stored_ang = self GetPlayerAngles();

	//CHANGE!!! Define in gsh
	interval = 10;

	while(1)
	{
		wait(interval);
		if(Distance(self.stored_pos, self.origin) >= 400)
		{
			if(isdefined(self.saved_position))
			{
				continue;
			}

			self.stored_pos = self.origin;
			self.stored_ang = self GetPlayerAngles();
		}	
	}
}

function StunNearZombies()
{
	//self = player
	zombies = GetAITeamArray("axis");
	zombies = util::get_array_of_closest(self.origin, zombies, undefined, undefined, 300);
	if(!isdefined(zombies))
		return;
	for(i = 0; i < zombies.size; i++)
	{
		if(IsAlive(zombies[i]))
		{
			zombies[i] StopAndStunZombie();
		}
	}
}

function CanUseTimewarp()
{
	if(self laststand::player_is_in_laststand())	//player is in laststand
	{
		//IPrintlnBold("In laststand");
		return false;
	}

	if( !zm_utility::is_player_valid( self ) )
	{
		//IPrintlnBold("player is not valid");
		return false;
	}

	if( self GetCurrentWeapon() == level.weaponReviveTool || self GetCurrentWeapon() == self.weaponReviveTool )		//player is reviving someone
	{
		//IPrintlnBold("Reviving");
		return false;
	}

	illegal_triggers = GetEntArray( "timewarp_excluded", "targetname" );	//Illegal areas, add trigger_multiples with this kvp
	if(isdefined(illegal_triggers))
	{
		foreach( trig in illegal_triggers )
		{
			if(self IsTouching(trig))
			{
				//IPrintlnBold("Illegal trigger");
				return false;
			}
		}
	}

	demonroom_area = GetEnt("demonroom", "script_string");
	if(isDefined(demonroom_area))
	{
		if(self IsTouching(demonroom_area))
			return false;
	}

	if( self check_if_touching_illegal_trigger() )
	{
		//IPrintlnBold("Illegal trigger");
		return false;
	}
		

	return true;

}

function check_if_touching_illegal_trigger()
{
	trigs = [];
	
	ARRAY_ADD( trigs, GetEntArray( "trigger_use", "classname" ) );
	ARRAY_ADD( trigs, GetEntArray( "trigger_radius", "classname" ) );
	ARRAY_ADD( trigs, GetEntArray( "trigger_use_touch", "classname" ) );
	
	foreach(trigArr in trigs)
	{
		foreach(trig in trigArr)
		{
			if(isSubStr(trig.classname, "use") || isSubStr(trig.classname, "exterior_goal") || (isDefined(trig.iUseTrigger) && trig.iUseTrigger))	
			{
				if(self isTouching(trig))
					return true;
			}
		}
	}
	
	zbarriers = struct::get_array( "exterior_goal", "targetname" );
		
	foreach(z in zbarriers)
	{
		if(Distance(self.origin, z.origin) < 100)
			return true;
	}

	if(isdefined(self.useBar) || isdefined(self.useBarText) )	//Don't allow teleporting if the user is crafting
	{
		return true;
	}

	return false;
}
