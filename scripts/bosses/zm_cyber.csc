#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_cyber;

#precache ("client_fx", "bosses/cyber_shield");
#precache ("client_fx", "explosions/fx_prop_exp");
#precache ("client_fx", "zombie/fx_ritual_gatestone_explosion_zod_zmb");

REGISTER_SYSTEM("zm_cyber", &__init__, undefined )

function __init__()
{
        //// LEVEL EFFECTS //// ##############################################################################

        level._effect[ "fx_cyber_shield" ]          = "bosses/cyber_shield";
	level._effect[ "fx_prop_exp" ]			= "explosions/fx_prop_exp";
	level._effect[ "fx_ritual_gatestone_explosion_zod_zmb" ]			= "zombie/fx_ritual_gatestone_explosion_zod_zmb";

        //// CLIENTFIELDS //// ##############################################################################

        clientfield::register( "scriptmover",    "cyber_shield_fx",          VERSION_SHIP, 1, "int", &cyber_shield_fx,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	clientfield::register( "scriptmover", "cyber_swarm_explode", VERSION_SHIP, 1, "counter", &cyber_swarm_explode, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "scriptmover", "cyber_ground_explode", VERSION_SHIP, 1, "counter", &cyber_ground_explode, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function cyber_shield_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == avo
{
	if ( IS_TRUE(newVal) )
	{
		self.fx_cyber_shield = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.fx_cyber_shield[i] = PlayFXOnTag(i, level._effect[ "fx_cyber_shield" ], self, "j_spine4");
		}
   
	}

	else if(!IS_TRUE(newVal) && isdefined(self.fx_cyber_shield))
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			StopFX(i, self.fx_cyber_shield[i] );
		}

		self.fx_cyber_shield = [];
	}

}

function cyber_swarm_explode( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon( "entityshutdown" );
	for(i = 0; i < GetLocalPlayers().size; i++)
	{
		PlayFx( i, level._effect["fx_prop_exp"], self.origin );
	}
	
}

function cyber_ground_explode( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	self endon( "entityshutdown" );
	PlayFx( localClientNum, level._effect["fx_ritual_gatestone_explosion_zod_zmb"], self.origin );
}

