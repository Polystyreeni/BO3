#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_tomahawk;

#define FX_TOMAHAWK_TRAIL	"dlc1/castle/fx_rune_arrow_reveal_trail_wide"
#precache("client_fx", FX_TOMAHAWK_TRAIL);

#define FX_TOMAHAWK_TRAIL_UG	"player/fx_dni_mesh_trail_clean"
#precache("client_fx", FX_TOMAHAWK_TRAIL_UG);

#define FX_TOMAHAWK_IMPACT	"zombie/fx_sword_projectile_slash_zod_zmb"
#precache("client_fx", FX_TOMAHAWK_IMPACT);

#define FX_TOMAHAWK_PULSE	"custom/fx_tomahawk_pulse"
#precache( "client_fx", FX_TOMAHAWK_PULSE );

#define FX_TOMAHAWK_PULSE_UG	"custom/fx_tomahawk_pulse_ug"
#precache( "client_fx", FX_TOMAHAWK_PULSE_UG );


REGISTER_SYSTEM("zm_weap_tomahawk", &__init__, undefined )

function __init__()
{
        clientfield::register( "scriptmover",    "tomahawk_trail_fx",          VERSION_SHIP, 2, "int", &tomahawk_trail_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer",    "tomahawk_pulse_fx",          VERSION_SHIP, 1, "counter", &tomahawk_pulse_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "toplayer",    "tomahawk_pulse_ug_fx",          VERSION_SHIP, 1, "counter", &tomahawk_pulse_ug_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover",    "tomahawk_zombie_impact",          VERSION_SHIP, 1, "counter", &tomahawk_zombie_impact,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	
	//UI
	RegisterClientField( "world", "tomahawkgrabbed",VERSION_SHIP, 2, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", "spikesgrabbed",VERSION_SHIP, 1, "int", &setSharedInventoryUIModels, false );

}

//Added for custom lua support
function setSharedInventoryUIModels( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "pe_hud" + "_" + fieldName ), newVal );
}

function tomahawk_trail_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == tomahawk model
{
	if ( newVal == 1 )
	{
		if(isdefined(self.trail_fx))
		{
			self stop_trail_fx();
		}

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.trail_fx[i] = PlayFXOnTag(i, FX_TOMAHAWK_TRAIL, self, "tag_origin");
		}
   
	}

	else if(newVal == 2)
	{
		if(isdefined(self.trail_fx))
		{
			self stop_trail_fx();
		}

		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.trail_fx[i] = PlayFXOnTag(i, FX_TOMAHAWK_TRAIL_UG, self, "tag_origin");
		}
	}

	else
	{
		stop_trail_fx();
	}

}

function stop_trail_fx()	// self = tomahawk model
{
	players = GetLocalPlayers();
	
	for(i = 0; i < players.size; i++)
	{
		if ( isdefined( self.trail_fx[i] ) )
		{
			StopFx( i, self.trail_fx[i] );
		}
	}
	
	self.trail_fx = [];
}

function tomahawk_pulse_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )	//self = player
{
	self endon( "entityshutdown" );
	PlayFxOnTag( localClientNum, FX_TOMAHAWK_PULSE, self, "tag_origin" );
}

function tomahawk_pulse_ug_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )	//self = player
{
	self endon( "entityshutdown" );
	PlayFxOnTag( localClientNum, FX_TOMAHAWK_PULSE_UG, self, "tag_origin" );
}


function tomahawk_zombie_impact( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )	//self = model
{
	self endon( "entityshutdown" );
	for(i = 0; i < GetLocalPlayers().size; i++)
	{
		PlayFx( i, FX_TOMAHAWK_IMPACT, self.origin );
	}
}

