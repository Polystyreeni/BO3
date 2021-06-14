#using scripts\codescripts\struct;
#using scripts\shared\animation_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\postfx_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache("client_fx", "custom/fx_generator_progress_loop");	//dlc0/factory/fx_steam_vat_factory
#precache("client_fx", "dlc0/factory/fx_steam_vat_factory");

#namespace zm_generators;

REGISTER_SYSTEM("zm_generators", &__init__, undefined )

function __init__()
{
	//Effects
	level._effect["fx_generator_progress_loop"] = "custom/fx_generator_progress_loop";
	level._effect["fx_steam_vat_factory"] = "dlc0/factory/fx_steam_vat_factory";

	//UI
	RegisterClientField( "world", "capture" + "_" + "gen1",VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", "capture" + "_" + "gen2", VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", "capture" + "_" + "gen3",	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );
	RegisterClientField( "world", "capture" + "_" + "gen4",	VERSION_SHIP, 1, "int", &zm_utility::setSharedInventoryUIModels, false );

	clientfield::register( "scriptmover", "generator_fx", VERSION_SHIP, 2, "int", &generator_fx, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
		
}

//Added for custom lua support
function setSharedInventoryUIModels( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "pe_hud_" + fieldName ), newVal );
}

function generator_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if ( newVal == 1 )	// Charging fx
	{
		self.charge_hint_fx = [];
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			self.charge_hint_fx[i] = PlayFXOnTag(i, level._effect["fx_generator_progress_loop"], self, "tag_origin");
		}
   
	}

	else if(newVal == 2)	// Gen complete, add a steam / running fx
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
			self.charge_hint_fx[i] = PlayFXOnTag(i, level._effect["fx_steam_vat_factory"], self, "tag_origin");
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
