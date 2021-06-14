#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\_zm_utility;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craft_ims.gsh;
	
#namespace zm_craft_ims;

REGISTER_SYSTEM( "zm_craft_ims", &__init__, undefined )

function __init__()
{
	zm_craftables::include_zombie_craftable( CRAFTABLE_NAME );
	zm_craftables::add_zombie_craftable( CRAFTABLE_NAME );
	
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_0,	VERSION_SHIP, 1, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_1, VERSION_SHIP, 1, "int", &setSharedInventoryUIModels, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_2,	VERSION_SHIP, 1, "int", &setSharedInventoryUIModels, false );
}

function setSharedInventoryUIModels( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), "build_" + fieldName ), newVal );
}
