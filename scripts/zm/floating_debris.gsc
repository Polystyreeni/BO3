#using scripts\codescripts\struct; 
#using scripts\shared\system_shared; 
#using scripts\shared\array_shared; 
#using scripts\shared\vehicle_shared; 
#using scripts\zm\_zm_score;
#using scripts\shared\flag_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared; 
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_spawner;
#using scripts\shared\_burnplayer;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai_shared;
#insert scripts\shared\shared.gsh;
#using scripts\zm\_zm_audio;


#using_animtree("generic");

#namespace floating_debris; // HARRY COMMENT

REGISTER_SYSTEM_EX( "floating_debris", &__init__, &__main__, undefined ) // HARRY COMMENT

function __init__()
{
    
}

function __main__()
{
	debris = GetEntArray("floating_debris","targetname");	
	foreach(debri in debris)
		debri thread doors_open();

}

function doors_open()
{
	self useanimtree(#animtree);
	self AnimScripted( "optionalNotify", self.origin , self.angles, %idle_debris_anim);
	origin = self.origin;
	trig = GetEntArray(self.target,"targetname");
	clip = GetEnt(trig[0].target, "targetname");
	if(isdefined(clip.script_noteworthy) && clip.script_noteworthy == "clip")	//EDIT: Clip needs to connect / disconnect paths
	{
		clip DisconnectPaths();
	}
		
	foreach(trigger in trig)
	{
		trigger SetCursorHint("HINT_NOICON");
		trigger SetHintString("Press ^3&&1 ^7 to clear Debris [Cost: "+trigger.zombie_cost + "]");
		trigger thread WaitForActivation( self, clip, trig, origin );
	}	
}

function WaitForActivation( debri, clip, a_trigger, origin )	//self = trigger
{
	level endon("end_game");
	self endon("delete");

	for( ;; )
	{
		self waittill("trigger", player);
		if(isdefined(player.score) && isdefined(self.zombie_cost) && player.score >= self.zombie_cost)
		{
			player zm_score::minus_to_player_score( self.zombie_cost );
			PlaySoundAtPosition(self.script_sound,origin);
			PlayFX( level._effect["poltergeist"], origin );
			debri AnimScripted( "optionalNotify", debri.origin , debri.angles, %rise_debris_anim);
			
			clip ConnectPaths();
			clip Delete();

			level flag::set(self.script_flag);

			foreach( trig in a_trigger )
			{
				trig Delete();
			}

			wait 2;
			debri Delete();
			break;
		}

		else
		{
			player zm_audio::create_and_play_dialog( "general", "outofmoney" );
		}
	}
}