#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_devgui;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_utility;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\zm\zm_afterlife_pe;

#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_weapons;

//IMS
#using scripts\zm\zm_weap_ims;

#insert scripts\zm\craftables\_zm_craftables.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\craftables\_zm_craft_ims.gsh;

#namespace zm_craft_ims;

REGISTER_SYSTEM_EX( "zm_craft_ims", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	init();
}

function init()
{
	part_0 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_0", 32, 64, 0, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_0, CRAFTABLE_IS_SHARED, "build_zs" );
	part_1 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_1", 48, 15, 25, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_1, CRAFTABLE_IS_SHARED, "build_zs" );
	part_2 = zm_craftables::generate_zombie_craftable_piece( 	CRAFTABLE_NAME, "part_2", 48, 15, 25, 	undefined, &on_pickup_common, &on_drop_common, undefined, undefined, undefined, undefined, CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_2, CRAFTABLE_IS_SHARED, "build_zs" );
	
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_0,	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_1,	VERSION_SHIP, 1, "int", undefined, false );
	RegisterClientField( "world", CLIENTFIELD_CRAFTABLE_PIECE_CRAFTABLE_PART_2, VERSION_SHIP, 1, "int", undefined, false );
	
	craftable_object 				= spawnStruct();
	craftable_object.name 			= CRAFTABLE_NAME;
	craftable_object.weaponname 	= CRAFTABLE_WEAPON;
	craftable_object zm_craftables::add_craftable_piece( part_0 );
	craftable_object zm_craftables::add_craftable_piece( part_1 );
	craftable_object zm_craftables::add_craftable_piece( part_2 );
	craftable_object.onBuyWeapon 	= &on_buy_weapon_craftable;
	craftable_object.triggerThink 	= &template_craftable;
	
	zm_craftables::include_zombie_craftable( craftable_object );
	
	zm_craftables::add_zombie_craftable( CRAFTABLE_NAME, CRAFT_READY_STRING, "ERROR", CRAFT_GRABED_STRING, &on_fully_crafted, CRAFTABLE_NEED_ALL_PIECES );
	zm_craftables::add_zombie_craftable_vox_category( CRAFTABLE_NAME, "build_zs" );
	zm_craftables::make_zombie_craftable_open( CRAFTABLE_NAME, CRAFTABLE_MODEL, ( 0, 0, 0 ), ( 0, 0, CRAFTABLE_OFFSET ) ); // COMMENT THIS OUT IF YOU WANT TO ONLY BUILD IT AT ITS DEDICATED TRIGGER - OTHERWISE PLACE THAT TRIGGER UNDER THE MAP
}

function __main__()
{
}

function template_craftable()
{
	zm_craftables::craftable_trigger_think( CRAFTABLE_NAME + "_craftable_trigger", CRAFTABLE_NAME, CRAFTABLE_WEAPON, CRAFT_GRAB_STRING, DELETE_TRIGGER, PERSISTENT );
}

// self is a WorldPiece
function on_pickup_common( player )
{
	// CallBack When Player Picks Up Craftable Piece
	//----------------------------------------------
	player playSound( "zmb_buildable_piece_add" );	

	clientfield::set("build_" + self.client_field_id, 1);

	self pickup_from_mover();
	self.piece_owner = player;
}

// self is a WorldPiece
function on_drop_common( player )
{
	// CallBack When Player Drops Craftable Piece
	//-------------------------------------------
	self drop_on_mover( player );
	self.piece_owner = undefined;
}

function pickup_from_mover()
{	
	//Setup for override	
}

function on_fully_crafted()
{
	players = level.players;
	foreach ( e_player in players )
	{
		if ( zm_utility::is_player_valid( e_player ) )
		{
			// e_player thread zm_craftables::player_show_craftable_parts_ui( "zmInventory.player_crafted_shield", "zmInventory.widget_shield_parts", true );
			 //e_player thread show_infotext_for_duration( ZMUI_SHIELD_CRAFTED, ZM_CRAFTABLES_FULLY_CRAFTED_UI_DURATION );
		}
	}
	
	return true;
}

function drop_on_mover( player )
{
	//Setup for override
	if ( isDefined( level.craft_shield_drop_override ) )
		[[ level.craft_shield_drop_override ]]();
	
}

function on_buy_weapon_craftable( player )
{
	if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_gungame")
	{
		self SetHintString("IMS Not Available in this Gamemode!");
		return 0;
	}

	//IPrintLnBold("Took Weapon");
	player PlaySound( "zmb_craftable_buy_shield" );
	if(IS_TRUE(player.in_afterlife) && isdefined(player.imskills) && player.imskills >= 20)
	{
		self.upgraded_ims = true;
	}

	if(zm_utility::is_player_valid( player ) )
	{
		equipment = undefined;
		prev_ammo = undefined;
		if(isdefined(player.activeims))
		{
			player.activeims thread zm_weap_ims::ImsDestroy( player );
		}

		if( IS_TRUE(player.hasRiotShield) )
		{
			shield = player.weaponRiotshield;
			if(isdefined(shield))
			{
				equipment = shield;
				prev_ammo = player GetWeaponAmmoClip( shield );
			}
		}

		player zm_utility::set_player_placeable_mine( level.ims_weapon );
		player GiveWeapon(level.ims_weapon);
		player SetActionSlot(4, "weapon", level.ims_weapon);
		player SetWeaponAmmoStock(level.ims_weapon, 1);
		//IPrintLnBold("Gave Weapon");
		player.imsammo = 4;
		player clientfield::set_player_uimodel( "hudItems.showDpadRight", 1 );
	
		WAIT_SERVER_FRAME;
		if(isdefined(equipment))
		{
			if(!IS_TRUE(player.hasRiotShield))
			{
				player zm_weapons::weapon_give(equipment);
				if(isdefined(prev_ammo))
				{
					player SetWeaponAmmoClip(player.weaponRiotshield, prev_ammo);
				}

				else
				{
					player GiveStartAmmo( player.weaponRiotshield );
				}
			}
		}
		
	}

}

