#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weapon_lightning;

#define LIGHTNING_STORM									"dlc1/zmb_weapon/fx_bow_storm_funnel_loop_zmb"
#precache( "client_fx", LIGHTNING_STORM ); 

REGISTER_SYSTEM("zm_weapon_lightning", &__init__, undefined )

function __init__()
{

        //// CLIENTFIELDS //// ##############################################################################

        clientfield::register( "scriptmover",    "lightning_gun_fx",          VERSION_SHIP, 1, "int", &lightning_gun_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function lightning_gun_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( IS_TRUE(newVal) )
	{
		self.lightning_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.lightning_fx[i] = PlayFXOnTag(i, LIGHTNING_STORM, self, "tag_origin");
		}
   
	}

	else
	{
		if( isdefined(self.lightning_fx) )
		{
			for( i = 0; i < GetLocalPlayers().size; i++ )
			{
				StopFX(i, self.lightning_fx[i] );
			}
		}
		
		self.lightning_fx = [];
	}

}