#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//HARRY
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_vulture_aid;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_random;

//CUSTOM
#using scripts\zm\_zm_perk_timewarp;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\_NSZ\nsz_powerup_zombie_blood;

//AVO
#using scripts\bosses\zm_avogadro;
#using scripts\bosses\zm_cyber;
#using scripts\bosses\zm_hanoi_boss;

//Afterlife
#using scripts\zm\zm_afterlife_pe;

//EE
#using scripts\zm\zm_project_e_ee;

//Traps
#using scripts\zm\_zm_trap_electric;
#using scripts\zm\_zm_trap_fire;
#using scripts\zm\_hb21_sym_zm_trap_acid;

#using scripts\zm\zm_usermap;

//Craftables
#using scripts\zm\craftables\_zm_craft_ims;

#using scripts\zm\_hb21_sym_zm_trap_acid;

//Custom Powerups By ZoekMeMaar
#using scripts\_ZoekMeMaar\custom_powerup_free_packapunch;

#using scripts\bosses\zm_ai_reverant;
#using scripts\ik\zm_teleporter_pe_main;
#using scripts\ik\zm_teleporter_pe;

#using scripts\zm\zm_project_e_amb;
#using scripts\zm\zm_project_e_music;
#using scripts\ik\zm_weapon_wind;
#using scripts\ik\zm_weapon_lightning;
#using scripts\zm\zm_weap_tomahawk;
#using scripts\ik\zm_generators;
#using scripts\zm\zm_weap_crossbow;
//DIGSITE
#using scripts\ik\zm_digsite;

#using scripts\zm\zm_project_e_challenges;

#define RED_EYE_FX    "frost_iceforge/red_zombie_eyes"
#precache( "client_fx", RED_EYE_FX );

function main()
{

	luiLoad( "ui.uieditor.menus.hud.t7hud_zm_custom" );
	
	//Rocket Shield
	clientfield::register( "clientuimodel", "zmInventory.widget_shield_parts", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "clientuimodel", "zmInventory.player_crafted_shield", VERSION_SHIP, 1, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 	

	//clientfield::register("world", "add_elemental_weapons", VERSION_SHIP, 1, "int", &add_elemental_weapons,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );

	clientfield::register("toplayer", "lightning_strike", VERSION_SHIP, 1, "counter", &lightning_strike, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT);

	zm_usermap::main();

	include_weapons();

	thread zm_project_e_amb::main();
	
	util::waitforclient( 0 );
	
	//Frost Iceforge's custom eye color
	set_eye_color();

}

//Added for custom lua support
function setSharedInventoryUIModels( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )  
{
	// shared inventory models should show up even if you're spectating, so that they're there when you respawn.
	SetUIModelValue( CreateUIModel( GetUIModelForController( localClientNum ), fieldName ), newVal );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_project_e_weapons.csv", 1);
}

function lightning_strike(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	SetUkkoScriptIndex(localClientNum, 1, 1);
	playsound(0, "amb_lightning_dist_low", (0, 0, 0));
	wait(0.02);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 1, 1);
	wait(0.1);
	SetUkkoScriptIndex(localClientNum, 4, 1);
	wait(0.1);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.25);
	SetUkkoScriptIndex(localClientNum, 1, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 3, 1);
	wait(0.15);
	SetUkkoScriptIndex(localClientNum, 1, 1);
}

function set_eye_color()
{
	level._override_eye_fx = RED_EYE_FX;//Change "BLUE" to any of the other colors.
}