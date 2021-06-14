/*================================================
"Five" teleporter script made by ihmiskeho
Original script by Treyarch
CREDITS:
-NateSmithZombies
-ihmiskeho
BE SURE TO GIVE CREDIT TO EVERYONE MENTIONED HERE!
*/
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_timer;
#using scripts\zm\_zm_utility;

function init()
{
	wait 5;
	iPrintlnBold("HELLO");
	//thread teleport_pad_init();
}
function teleport_pad_init()
{
	level.portal_trig = GetEntArray( "portal_trigs", "targetname" );
	for ( i = 0; i < level.portal_trig.size; i++ )
	{
		level.portal_trig[i].active = true;
		level.portal_trig[i].portal_used =[];
		level.portal_trig[i] thread player_teleporting();
	}
}

function player_teleporting()
{
	user = undefined;
	while(true)
	{
		self waittill( "trigger", user );
		
		player_used = false;
		if(IsDefined(self.portal_used))
		{
			for (i = 0; i < self.portal_used.size; i++)
			{
				if(self.portal_used[i] == user)
				{
					player_used = true;
				}	
			}	
		}
				
		util::wait_network_frame();
		
		if(player_used == true)
		{
			continue;
		}	
		
		else if ( zm_utility::is_player_valid( user ) )
		{	
			self thread teleport_player(user);
		}
	}
}

function teleport_player(user)
{
	prone_offset = (0, 0, 49);
	crouch_offset = (0, 0, 20);
	stand_offset = (0, 0, 0);
	destination = undefined;
	dest_trig = 0;		
	i(IsDefined(user.teleporting) && user.teleporting == true)f
	{
		return;
	}
	user.teleporting = true;
	user FreezeControls( true );
	user disableOffhandWeapons();
	user disableweapons();
		
	dest_trig = RandomIntRange(0,level.portal_trig.size);
			
	if(!IsDefined(dest_trig))
	{
		while(!IsDefined(dest_trig))
		{
			dest_trig = RandomIntRange(0,level.portal_trig.size);
			break;
			util::wait_network_frame();
		}	
	}	

	player_destination = struct::get_array(level.portal_trig[dest_trig].target, "targetname");
	if(IsDefined(player_destination))
	{
		for ( i = 0; i < player_destination.size; i++ )
		{
			if(IsDefined(player_destination[i].script_noteworthy) && player_destination[i].script_noteworthy == "player_pos")
			{
				destination = player_destination[i];
			}
		}
	}
	
	if(!IsDefined(destination))
	{
		destination = level.portal_trig[dest_trig].origin;
	}
		
	
	//level.portal_trig[dest_trig] thread cooldown_portal_timer(user);
				
	if( user getstance() == "prone" )
	{
		desired_origin = destination.origin + prone_offset;
	}
	else if( user getstance() == "crouch" )
	{
		desired_origin = destination.origin + crouch_offset;
	}
	else
	{
		desired_origin = destination.origin + stand_offset;
	}			
			
	util::wait_network_frame();
	PlayFX(level._effect["transporter_start"], user.origin);
	playsoundatposition( "evt_teleporter_out", user.origin );
	
	players = getplayers();
	for ( i = 0; i < players.size; i++ )
	{	
		if(players[i] == user)
		{
			continue;
		}
		
		if(Distance(players[i].origin, desired_origin) < 18)
		{
			desired_origin = desired_origin + (AnglesToForward(destination.angles) * -32);
		}	
	}
	
		
	
	user SetOrigin( desired_origin );
	user SetPlayerAngles( destination.angles );
	//DEBUG
	iPrintlnBold("i_DEBUG: Teleported");
	//playsoundatposition( "evt_teleporter_go", user.origin );
	wait(0.5);
	user enableweapons();
	user enableoffhandweapons();
	user FreezeControls( false );
	user.teleporting = false;	
}

/*function find_portal_destination(orig_trig)
{	
		dest_trig = RandomIntRange(0,level.portal_trig.size);	
		if(level.portal_trig[dest_trig] == orig_trig )
		{
			portals = level.portal_trig;
				
			for( i = 0; i < level.portal_trig.size; i ++)
			{
				level.portal_trig[i].index = i;
				
				if(level.portal_trig[i] == orig_trig )
				{
					//portals = array_remove( portals, level.portal_trig[i] );
				}
			}
			rand = RandomIntRange(0, portals.size);
			dest_trig = portals[rand].index;
		}
		return dest_trig;
}

function cooldown_portal_timer(player)
{
	
	self.portal_used = ARRAY_ADD(self.portal_used, player);
	
	time = 0;
	while( time < 20 )
	{
		wait(1);
		time++;
	}	
	
	self.portal_used = array_remove(self.portal_used, player);
}	


//level flag::wait_till( "power_on" );*/