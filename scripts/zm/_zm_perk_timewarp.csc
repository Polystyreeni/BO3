/*#========================================###
###                                                                   							  ###
###                                                                   							  ###
###             																			  	  ###
###                                                                   							  ###
###                                                                   							  ###
###========================================#*/
/*============================================

								CREDITS

=============================================
WillJones1989
alexbgt
NoobForLunch
Symbo
TheIronicTruth
JAMAKINBACONMAN
Sethnorris
Yen466
Lilrifa
Easyskanka
Will Luffey
ProRevenge
DTZxPorter
Zeroy
JBird632
StevieWonder87
BluntStuffy
RedSpace200
thezombieproject
Smasher248
JiffyNoodles
MadGaz
MZSlayer
AndyWhelen
Collie
HitmanVere
ProGamerzFTW
Scobalula
Azsry
GerardS0406
PCModder
IperBreach
TomBMX
Treyarch and Activision
AllModz
TheSkyeLord
===========================================*/
#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_perks;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_TIMEWARP.gsh;

#precache( "client_fx", TIMEWARP_MACHINE_LIGHT_FX );
#precache( "client_fx", "dlc1/castle/fx_castle_electric_cherry_trail" );

#namespace zm_perk_timewarp;

REGISTER_SYSTEM_EX( "zm_perk_timewarp", &__init__, &__main__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------	
function __init__()
{
	if ( IS_TRUE( TIMEWARP_LEVEL_USE_PERK ) )
		enable_TIMEWARP_for_level();
	
}

function __main__()
{
	if ( IS_TRUE( TIMEWARP_LEVEL_USE_PERK ) )
		TIMEWARP_main();
	
}

function enable_TIMEWARP_for_level()
{
	zm_perks::register_perk_clientfields( 		TIMEWARP_PERK, &TIMEWARP_client_field_func, &TIMEWARP_callback_func );
	zm_perks::register_perk_effects( 			TIMEWARP_PERK, TIMEWARP_PERK );
	zm_perks::register_perk_init_thread( 		TIMEWARP_PERK, &TIMEWARP_init );
}

function TIMEWARP_init()
{
	level._effect[ TIMEWARP_PERK ]			= TIMEWARP_MACHINE_LIGHT_FX;
}

function TIMEWARP_client_field_func() 
{
	clientfield::register( "clientuimodel", TIMEWARP_CLIENTFIELD, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function TIMEWARP_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function TIMEWARP_main()
{
	// SELF == LEVEL
	// PERK SETUP STUFF HERE
	clientfield::register( "allplayers", "timewarp_slide_fx",	VERSION_SHIP, 	2, "int", &timewarp_slide_fx, 	!CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function timewarp_slide_fx( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{	
	if ( isDefined( self.timewarp_slide_fx ) )
		StopFX( localClientNum, self.timewarp_slide_fx );			
	
	if ( newVal == 1 )
		self.timewarp_slide_fx = playFXOnTag( localClientNum, level._effect[ "electric_cherry_trail" ], self, "tag_origin" );

	else
	{
		if ( isDefined( self.timewarp_slide_fx ) )
			stopFX( localClientNum, self.timewarp_slide_fx );			
		
		self.timewarp_slide_fx = undefined;
	}
}