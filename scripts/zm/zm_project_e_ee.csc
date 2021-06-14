#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_project_e_ee;

#precache ("client_fx", "dlc5/asylum/fx_power_off_elec_beam_low" );
#precache ("client_fx", "dlc1/castle/fx_elec_jumppad_amb_ext_ring" );	//"dlc2/island/fx_bucket_115_glow"
#precache ("client_fx", "dlc2/island/fx_bucket_115_glow" );
#precache ("client_fx", "custom/fx_fire_ritual_plinth");
#precache ("client_fx", "dlc1/castle/fx_rune_fireplace_embers");
#precache ("client_fx", "zombie/fx_portal_buffed_spawn_zod_zmb");

REGISTER_SYSTEM("zm_project_e_ee", &__init__, undefined )

function __init__()
{
        //// LEVEL EFFECTS //// ##############################################################################

        level._effect["fx_power_off_elec_beam_low"] = "dlc5/asylum/fx_power_off_elec_beam_low";
	level._effect["fx_elec_jumppad_amb_ext_ring"] = "dlc1/castle/fx_elec_jumppad_amb_ext_ring";
	level._effect["fx_bucket_115_glow"] = "dlc2/island/fx_bucket_115_glow";		//custom/fx_fire_ritual_plinth
	level._effect["fx_fire_ritual_plinth"] = "custom/fx_fire_ritual_plinth";
	level._effect["fx_rune_fireplace_embers"] = "dlc1/castle/fx_rune_fireplace_embers";
	level._effect["fx_portal_buffed_spawn_zod_zmb"] = "zombie/fx_portal_buffed_spawn_zod_zmb";	

        //// CLIENTFIELDS //// ##############################################################################
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_lightning",VERSION_SHIP, 2, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_fire", VERSION_SHIP, 2, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_wind",	VERSION_SHIP, 2, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", "p6_zm_buildable_sq_meteor_ice",	VERSION_SHIP, 2, "int", &setSharedInventoryUIModels, false );

        clientfield::register( "scriptmover",    "tele_charge_hint",          VERSION_SHIP, 2, "int", &tele_charge_hint,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "fire_path_fx",          VERSION_SHIP, 1, "int", &fire_path_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "fire_ritual_fx",          VERSION_SHIP, 2, "int", &fire_ritual_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "final_tele_portal",          VERSION_SHIP, 1, "int", &final_tele_portal,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	
}

//Added for custom lua support
function setSharedInventoryUIModels( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "pe_hud_" + fieldName ), newVal );
}

function tele_charge_hint( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( newVal == 1 )
	{
		if(!isdefined(self.charge_hint_fx))
			self.charge_hint_fx = [];

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.charge_hint_fx[i] = PlayFXOnTag(i, level._effect["fx_power_off_elec_beam_low"], self, "tag_origin");
		}
   
	}

	else if(newVal == 2)
	{
		if(isdefined(self.charge_hint_fx))
		{
			for(i = 0; i < GetLocalPlayers().size; i++)
			{
				StopFX(i, self.charge_hint_fx[i] );
			}
		}

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.charge_hint_fx[i] = PlayFXOnTag(i, level._effect["fx_elec_jumppad_amb_ext_ring"], self, "tag_origin");
		}
	}

	else
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.charge_hint_fx[i] );
		}

		self.charge_hint_fx = [];
	}

}

function fire_path_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal) )
	{
		self.firepath_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.firepath_fx[i] = PlayFXOnTag(i, level._effect["fx_bucket_115_glow"], self, "tag_origin");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.firepath_fx))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.firepath_fx[i] );
		}

		self.firepath_fx = [];
	}

}

function fire_ritual_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( newVal == 1 )
	{
		if(!isdefined(self.fire_ritual_fx))
			self.fire_ritual_fx = [];

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.fire_ritual_fx[i] = PlayFXOnTag(i, level._effect["fx_rune_fireplace_embers"], self, "tag_origin");
		}
   
	}

	else if(newVal == 2)
	{
		if(isdefined(self.fire_ritual_fx))
		{
			for(i = 0; i < GetLocalPlayers().size; i++)
			{
				StopFX(i, self.fire_ritual_fx[i] );
			}
		}

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.fire_ritual_fx[i] = PlayFXOnTag(i, level._effect["fx_fire_ritual_plinth"], self, "tag_origin");
		}
	}

	else
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.fire_ritual_fx );
		}

		self.fire_ritual_fx = [];
	}

}

function final_tele_portal( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal) )
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
