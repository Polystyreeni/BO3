#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weapon_wind;

#define WIND_PROJ									"custom/fx_wind_tornado"
#precache( "client_fx", WIND_PROJ );

REGISTER_SYSTEM("zm_weapon_wind", &__init__, undefined )

function __init__()
{

        //// CLIENTFIELDS //// ##############################################################################

        clientfield::register( "scriptmover",    "wind_fx",          VERSION_SHIP, 1, "int", &wind_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function wind_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal))
	{
		self.wind_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.wind_fx = PlayFXOnTag(i, WIND_PROJ, self, "tag_origin");
		}
   
	}

	else
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			if( isdefined(self.wind_fx[i]) )
				StopFX( i, self.wind_fx[i] );
		}

		self.wind_fx = [];
	}
}