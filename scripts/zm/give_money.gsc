#using scripts\codescripts\struct; // HARRY COMMENT
#using scripts\shared\system_shared; // HARRY COMMENT
#using scripts\shared\array_shared; // HARRY COMMENT
#using scripts\shared\vehicle_shared; // HARRY COMMENT
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; // HARRY COMMENT
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#insert scripts\shared\shared.gsh;
#using scripts\zm\_zm_powerups;

#precache( "fx", "Symbo/fx_vulture_money" );
#precache( "model", "dollar" );
#precache( "material", 		"dollar" );
//#precache ("material", "vinyle");

#define HOW_MUCH          200
#define CAN_USE_AMOUNT    5

#namespace give_money; // HARRY COMMENT

REGISTER_SYSTEM_EX( "give_money", &__init__, &__main__, undefined ) // HARRY COMMENT

function __init__()
{
	callback::on_spawned( &on_player_spawned );
	callback::on_spawned( &ScoreShareRoundLogic);
}

function __main__()
{

}

function ScoreShareRoundLogic()
{
	self endon("disconnect");
	wait 0.05;
	level flag::wait_till( "initial_blackscreen_passed" );

	while(1)
	{
		level waittill("between_round_over");
		if( !isdefined(self.moneyshared) || self.moneyshared >= 0 )
		{
			self.moneyshared = 0;
		}
	}
}

function on_player_spawned()
{

	self endon( "disconnect" );
	wait 0.05;
	level flag::wait_till( "initial_blackscreen_passed" );
	//self thread dollar_image_hud( "dollar", 50, 100, 15, 15 );

	self.moneyshared = 0; 

	while( 1 )
	{
		if( self ActionSlotOneButtonPressed() ) //ActionSlotThreeButtonPressed();
		{
			if( self.moneyshared < CAN_USE_AMOUNT )
			{
				self.moneyshared++;
				self thread give_money();
			}

			else
			{
				self PlaySound( "evt_perk_deny" );
			}

		}
		
		wait( 0.2 ); // Small wait to allow players to open inventory without delay
	}

}

function give_money()
{
    if ( self.score >= HOW_MUCH )
    {
        self zm_score::minus_to_player_score( HOW_MUCH );
        zm_utility::play_sound_at_pos( "purchase", self.origin );
        self spawn_model();
    }
    else
        self playSoundToPlayer( "error2", self );
   
}
 
function spawn_model()
{
    distance_ahead = 90;
    origin = CheckNavMeshDirection(self.origin,anglesToForward( self.angles ),90, 20);
    e_model = util::spawn_model( "dollar", ( origin + ( 0, 0, 35 ) ) );
    e_model.angles = ( 0, 0, 90 );
    playFXOnTag( "Symbo/fx_vulture_money", e_model, "tag_origin" );
    e_model thread SpinMe();
    e_model thread wait_to_disa();
    e_model thread take_money();
}
 
function take_money()
{
    self endon( "timeout" );
   
    while ( isDefined( self ) )
    {
        wait 0.05;
        a_players = getPlayers();
       
        if ( !isDefined( a_players.size ) || a_players.size < 1 )
            continue;
       
        for ( i = 0; i < a_players.size; i++ )
        {
            if ( distance( a_players[ i ].origin, self.origin ) <= 50 )
            {
                a_players[ i ] zm_score::add_to_player_score( HOW_MUCH );
                zm_utility::play_sound_at_pos( "purchase", self.origin );
                self notify( "grabbed" );
                self delete();
            }
        }
    }
}
 
function wait_to_disa()
{
    self endon( "grabbed" );
    wait 5;
    for ( i = 0; i < 5; i++ )
    {
        self hide();
        wait .5;
        self show();
        wait .5;
    }
   
    for ( i = 0; i < 2; i++ )
    {
        self hide();
        wait .2;
        self show();
        wait .2;
    }
   
    self hide();
    wait .1;
    self show();
    wait .1;
 
    self notify( "timeout" );
    self delete();
}
 
function SpinMe()
{
    self endon( "grabbed" );
    self endon( "timeout" );
    while( isdefined( self ) )
    {
        self rotateYaw( 360, 2 );
     wait 0.05;
    }
}

function dollar_image_hud( image = "dollar", align_x = 50, align_y = 100, height = 15, width = 15, fade_time = .5 )
{
	if ( isDefined( self.h_gaz_hud ) && isDefined( self.h_gaz_hud.h_gaz_text_hud ) )
	{
		self.h_gaz_hud.h_gaz_text_hud setText( self.gaz );
		return;
	}
	
	if ( IS_TRUE( self isSplitscreen() ) )
		align_y = 70;
	
    h_hud = newClientHudElem( self );
    h_hud.foreground = true;
    h_hud.sort = 1;
    h_hud.hidewheninmenu = true;
    h_hud.alignX = "right";
    h_hud.alignY = "bottom";
    h_hud.horzAlign = "right";
    h_hud.vertAlign = "bottom";
    h_hud.x = -align_x;
    h_hud.y = h_hud.y - align_y;
    h_hud setShader( image, width, height );
	
	h_hud_text = newClientHudElem( self );
	h_hud_text.foreground = true;
    h_hud_text.sort = 1;
    h_hud_text.hidewheninmenu = true;
    h_hud_text.alignX = "right";
    h_hud_text.alignY = "bottom";
    h_hud_text.horzAlign = "right";
    h_hud_text.vertAlign = "bottom";
    h_hud_text.x = -align_x;
    h_hud_text.y = h_hud_text.y - align_y;	
	h_hud_text setText( self.gaz );
	
	h_hud.h_gaz_text_hud = h_hud_text;
	self.h_gaz_hud = h_hud;
	
	if ( isDefined( fade_time ) && fade_time > 0 )
	{
		h_hud.alpha = 0;
		h_hud fadeOverTime( fade_time );
		h_hud.alpha = 1;
    }
	

}