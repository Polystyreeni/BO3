#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#insert scripts\shared\duplicaterender.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_weap_crossbow;

#precache("client_fx", "custom/fx_crossbow_bolt_green");
#precache("client_fx", "custom/fx_crossbow_bolt_red");

REGISTER_SYSTEM("zm_weap_crossbow", &__init__, undefined )

function __init__()
{

	level._effect["fx_crossbow_bolt_green"] = "custom/fx_crossbow_bolt_green";
	level._effect["fx_crossbow_bolt_red"] = "custom/fx_crossbow_bolt_red";
	
	clientfield::register( "missile",    "crossbow_green",          VERSION_SHIP, 1, "counter", &crossbow_green,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "missile",    "crossbow_red",          VERSION_SHIP, 1, "counter", &crossbow_red,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function crossbow_green( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )	//self = model
{
	self endon( "entityshutdown" );
	//IprintLnBold("Green FX");
	for(i = 0; i < GetLocalPlayers().size; i++)
	{
		PlayFxOnTag( i, level._effect["fx_crossbow_bolt_green"], self, "tag_fx" );
	}
}

function crossbow_red( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )	//self = model
{
	self endon( "entityshutdown" );
	//IprintLnBold("Red FX");
	for(i = 0; i < GetLocalPlayers().size; i++)
	{
		PlayFxOnTag( i, level._effect["fx_crossbow_bolt_red"], self, "tag_fx" );
	}
}