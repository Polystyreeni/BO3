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

#namespace zm_project_e_challenges;

REGISTER_SYSTEM("zm_project_e_challenges", &__init__, undefined )

function __init__()
{
	//UI
	RegisterClientField( "toplayer", "specialty_perk_obtained",VERSION_SHIP, 2, "int", &register_perk_image, false );
		
}

//Added for custom lua support
function register_perk_image( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "" +fieldName ), newVal );
}
