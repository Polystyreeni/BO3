#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_avogadro;

//#precache ("client_fx", "zombie/fx_elec_gen_tip_zmb"); OLD
#precache ("client_fx", "bosses/avo_fx_loop");

REGISTER_SYSTEM("zm_avogadro", &__init__, undefined )

function __init__()
{
    //// LEVEL EFFECTS //// ##############################################################################

   level._effect[ "fx_avo_loop" ]          = "bosses/avo_fx_loop";

    //// CLIENTFIELDS //// ##############################################################################

    clientfield::register( "scriptmover",    "avo_hidden_fx",          VERSION_SHIP, 1, "int", &avo_hidden_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function avo_hidden_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == avo
{
	if ( IS_TRUE(newVal))
	{
		self.fx_avo_hidden = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.fx_avo_hidden[i] = PlayFXOnTag(i, level._effect[ "fx_avo_loop" ], self, "j_spine4");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.fx_avo_hidden))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.fx_avo_hidden[i] );
		}

		self.fx_avo_hidden = [];
	}

}