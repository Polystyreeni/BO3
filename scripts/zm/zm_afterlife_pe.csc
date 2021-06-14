#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\filter_shared;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_afterlife_pe;

#precache( "client_fx", "custom/fx_afterlife_loop" );
#precache( "client_fx", "dlc1/castle/fx_keeper_ghost_mist_trail" );
#precache( "client_fx", "zombie/fx_bmode_glow_pwrbox_zod_zmb" );

REGISTER_SYSTEM_EX("zm_afterlife_pe", &__init__, &__main__, undefined )

function __init__()
{
	//// LEVEL EFFECTS //// ##############################################################################
	
	level._effect[ "fx_afterlife_loop" ]          = "custom/fx_afterlife_loop";
	level._effect[ "fx_keeper_ghost_mist_trail" ]          = "dlc1/castle/fx_keeper_ghost_mist_trail";
	level._effect[ "fx_bmode_glow_pwrbox_zod_zmb" ] = "zombie/fx_bmode_glow_pwrbox_zod_zmb";

	//// CLIENTFIELDS //// ##############################################################################

	clientfield::register( "toplayer",    "afterlife_torso_fx",          VERSION_SHIP, 1, "int", &afterlife_torso_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "allplayers",    "afterlife_world_fx",          VERSION_SHIP, 1, "int", &afterlife_world_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer",    "afterlife_shockhints",          VERSION_SHIP, 1, "int", &afterlife_shockhints,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
}
function __main__()
{
	level.afterlife_vision = "zm_afterlife";
	visionset_mgr::register_visionset_info( level.afterlife_vision, 			VERSION_SHIP, 30, undefined, level.afterlife_vision );

	afterlife_main();
}

function afterlife_main()
{
	level.afterlife_hints = [];
	level.afterlife_hints = GetEntArray("afterlife_shockbox", "targetname");
	level.afterlife_hints = ArrayCombine( level.afterlife_hints, struct::get_array("tomahawk_struct","targetname"), true, false );
}

function afterlife_shockhints( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
	if( newVal == 1 )
	{
		//iPrintlnBold("Afterlife Enter");
		self.fx_afterlife_hints = [];
		for(i = 0; i < level.afterlife_hints.size; i++)
		{
			//iPrintlnBold("Playing fx");
			self.fx_afterlife_hints[i] = PlayFXOnTag(localClientNum, level._effect[ "fx_bmode_glow_pwrbox_zod_zmb" ], level.afterlife_hints[i], "tag_origin");
		}
		
	}

	else if( newVal == 0 )
	{
		//iPrintlnBold("Afterlife Leave");
		if (isdefined(localClientNum))
		{
			if(isdefined(self.fx_afterlife_hints))
			{
				for(i = 0; i < level.afterlife_hints.size; i++)
				{
					StopFX(localClientNum, self.fx_afterlife_hints[i] );
					//self.fx_afterlife_hints[i] = PlayFXOnTag(localClientNum, level._effect[ "fx_bmode_glow_pwrbox_zod_zmb" ], level.afterlife_hints[i], "tag_origin");
				}

				self.fx_afterlife_hints = undefined;
			}
			
		}
	}
}

function afterlife_torso_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
	if( newVal == 1 )
	{
		EnableSpeedBlur( localClientNum, .2, .5, 1.0, true, 300, 1, 1, 1 );
		filter::enable_filter_overdrive( self, 3 );
		self.soundEnt = Spawn( localClientNum, self.origin, "script_origin" );
		self.soundEnt playLoopSound( "afterlife_loop", 3 );
		self.afterlife_fx_right = PlayFXOnTag(localClientNum, level._effect[ "fx_afterlife_loop" ], self, "j_index_ri_2");
		//self boost_fx_on_velocity(localClientNum);
	}

	else if( newVal == 0 )
	{
		if (isdefined(localClientNum))
		{
			filter::disable_filter_overdrive( self,3 );
	   		DisableSpeedBlur( localClientNum );
	   		//self notify( "end_overdrive_boost_fx");
			self.soundEnt Delete();
			StopFX(localClientNum, self.afterlife_fx_right );
		}
	}
}

function afterlife_world_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == player
{
	if( newVal == 1 )
	{
		if(isdefined(self.afterlife_torso_fx))
		{
			stop_afterlife_fx();
		}

		else
		{
			self.afterlife_torso_fx = [];
		}

		players = GetLocalPlayers();
		for(i = 0; i < players.size; i++)
		{
			if(!self isLocalPlayer() || self getlocalclientnumber() != localClientNum || IsThirdPerson(localClientNum))
			{
				self.afterlife_torso_fx[i] = PlayFxOnTag(i, level._effect[ "fx_keeper_ghost_mist_trail" ], self, "j_spine4");
			}
		}
	}

	else if( newVal == 0 )
	{
		stop_afterlife_fx();
	}
}

function stop_afterlife_fx()
{
	players = GetLocalPlayers();
	
	for(i = 0; i < players.size; i++)
	{
		if ( isdefined( self.afterlife_torso_fx[i] ) )
		{
			StopFx( i, self.afterlife_torso_fx[i] );
		}
	}
	
	self.afterlife_torso_fx = [];
}







