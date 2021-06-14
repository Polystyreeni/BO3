#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#using scripts\shared\postfx_shared;

#namespace zm_hanoi_boss;

#precache ("client_fx", "zombie/fx_ee_altar_mist_zod_zmb" );
#precache ("client_fx", "custom/fx_ghost_blast");
#precache ("client_fx", "explosions/fx_exp_grenade_dirt");
#precache ("client_fx", "dlc4/genesis/fx_sophia_elec_charge_teleporter");
#precache ("client_fx", "zombie/fx_bmode_glow_door_zod_zmb" );

REGISTER_SYSTEM("zm_hanoi_boss", &__init__, undefined )

function __init__()
{
        //// LEVEL EFFECTS //// ##############################################################################

        level._effect[ "fx_ghost_boss_loop" ]          = "zombie/fx_ee_altar_mist_zod_zmb";
	level._effect[ "fx_ghost_blast" ]			= "custom/fx_ghost_blast";
	level._effect[ "fx_exp_grenade_dirt" ]			= "explosions/fx_exp_grenade_dirt";
	level._effect[ "fx_sophia_elec_charge_teleporter" ]			= "dlc4/genesis/fx_sophia_elec_charge_teleporter";
	level._effect[ "fx_bmode_glow_door_zod_zmb" ]			= "zombie/fx_bmode_glow_door_zod_zmb";

        //// CLIENTFIELDS //// ##############################################################################

        clientfield::register( "scriptmover",    "ghost_boss_fx",          VERSION_SHIP, 1, "int", &ghost_boss_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "ghost_charge_fx",          VERSION_SHIP, 1, "int", &ghost_charge_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
        clientfield::register( "scriptmover",    "ghost_blast_fx",          VERSION_SHIP, 1, "int", &ghost_blast_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	clientfield::register( "scriptmover",    "barrier_fx",          VERSION_SHIP, 1, "int", &barrier_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	clientfield::register( "scriptmover", "ghost_directattack_fx", VERSION_SHIP, 1, "counter", &ghost_directattack_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "tele_portal",          VERSION_SHIP, 1, "int", &tele_portal,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	// self thread postfx::playPostfxBundle( "pstfx_zm_screen_warp" );
	clientfield::register( "toplayer",    "in_midigc",          VERSION_SHIP, 1, "int", &migigc_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	level.bw_vision = "zm_bw_vision";
	visionset_mgr::register_visionset_info( level.bw_vision, 			VERSION_SHIP, 30, undefined, level.bw_vision );
}

function ghost_boss_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == avo
{
	if ( IS_TRUE(newVal) )
	{
		self.ghost_boss_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.ghost_boss_fx[i] = PlayFXOnTag(i, level._effect[ "fx_ghost_boss_loop" ], self, "j_spine4");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.ghost_boss_fx))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.ghost_boss_fx[i] );
		}

		self.ghost_boss_fx = [];
	}

}

function ghost_blast_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon( "entityshutdown" );

	if(newVal == 1)
	{
		if(!isdefined(self.blast_fx))
			self.blast_fx = [];

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.blast_fx[i] = PlayFx( i, level._effect[ "fx_ghost_blast" ], self.origin );
		}
		
	}

	else if(newVal == 0)
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.blast_fx[i] );
		}

		self.blast_fx = [];
		
	}
	
}

function ghost_directattack_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon( "entityshutdown" );
	PlayFx( localClientNum, level._effect[ "fx_exp_grenade_dirt" ], self.origin );
}

function ghost_charge_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == avo
{
	if ( IS_TRUE(newVal) )
	{
		self.ghost_charge_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.ghost_charge_fx[i] = PlayFXOnTag(i, level._effect[ "fx_sophia_elec_charge_teleporter" ], self, "j_spine4");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.ghost_charge_fx))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.ghost_charge_fx[i] );
		}

		self.ghost_charge_fx = [];
	}

}

function barrier_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal) )
	{
		self.barrier_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.barrier_fx[i] = PlayFXOnTag(i, level._effect[ "fx_bmode_glow_door_zod_zmb" ], self, "tag_origin");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.barrier_fx))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.barrier_fx[i] );
		}

		self.barrier_fx = [];
	}

}

function tele_portal( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal))
	{
		self.portal_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.portal_fx[i] = PlayFXOnTag(i, level._effect["fx_portal_buffed_spawn_zod_zmb"], self, "tag_origin");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.portal_fx))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.portal_fx[i] );
		}

		self.portal_fx = [];
	}

}

function migigc_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal))
	{
		self thread postfx::playPostfxBundle( "pstfx_zm_screen_warp" );
		self.soundEnt = Spawn( localClientNum, self.origin, "script_origin" );
		self.soundEnt playLoopSound( "afterlife_loop", 3 );
	}

	else
	{
		self thread postfx::stopPlayingPostfxBundle();
		if(isdefined(self.soundEnt))
			self.soundEnt Delete();
	}
	
}

