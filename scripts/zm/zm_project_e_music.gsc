//Base script is Jbirds ee sond script. I've added all my music setup here
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_audio;
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_project_e_music;

function init()
{
	clientfield::register( "allplayers", "cancel_ambient_music", VERSION_SHIP, 1, "int" );

	/*	Editable Variables - change the values in here */
	level.easterEggSong = "project_e_song";							// sound alias name for the song
	//level.easterEggTriggerSound = "ee_trigger";				// sound alias name for the sound played when activating a trigger
	//level.easterEggTriggerLoopSound = "ee_loop_trigger";	// sound alias name for the loop sound when you are near a trigger
	/*	End of Editable Variables - don't touch anything below here */
	level.music_playing = false;
	level.ee_song_playing = false;
	setupMusic();
}

function setupMusic()
{
	level.triggersActive = 0;
	triggers = GetEntArray("song_trigger", "targetname");

	foreach(trigger in triggers)
	{
		trigger SetCursorHint("HINT_NOICON");
		trigger UseTriggerRequireLookAt();
		trigger thread registerTriggers(triggers.size);
	}
}

function registerTriggers(numTriggers)
{
	ent = self play_2D_loop_sound( "ee_loop_trigger" );

	self waittill("trigger", user);
	ent delete();
	self PlaySound( "ee_trigger" );
	level.triggersActive++;

	if(level.triggersActive >= numTriggers)
	{
		sound_to_play = "vox_plr" + user GetCharacterBodyType() + "_secret_00";		//vox_plr_0_secret_00
		user thread CustomPlayerQuote( sound_to_play );
		playMusic();
	}
}

function playMusic()
{
	play_2D_sound(level.easterEggSong);
}

function cancel_ambient_music()
{
	util::clientnotify( "pe_cancel_music" );
}

function play_2D_sound(sound)
{
	level notify("higher_priority_sound");
	util::clientnotify( "pe_cancel_music" );
	level.ee_song_playing = true;
	temp_ent = Spawn("script_origin", (0,0,0));
	temp_ent PlaySoundWithNotify( sound, sound + "wait" );
	temp_ent waittill( sound + "wait" );
	wait(0.05);
	temp_ent delete();
	level.ee_song_playing = false;
	util::clientnotify( "pe_activate_music" );
}

function play_2D_loop_sound(sound)
{
	temp_ent = spawn("script_origin", self.origin);
	temp_ent PlayLoopSound(sound);
	return temp_ent;
}

function play_music_for_players( str_sound, higher_priority_sound = false, islooping = false )
{
	if(!isdefined(str_sound))
		return;

	if(IS_TRUE(level.ee_song_playing))
		return;

	if(higher_priority_sound)
	{
		level notify("higher_priority_sound");
	}

	else 
	{
		if(level.music_playing)
			return;
	}

	playbackTime = get_sound_playback_time( str_sound );

	level thread play_music_2d( str_sound, playbackTime );

	/*players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread play_sound_for_player( i, str_sound, playbackTime );
	}*/
}

function get_sound_playback_time( str_sound )
{
	if(!isdefined(str_sound))
		return 1;

	playbackTime = SoundGetPlaybackTime( str_sound );
		
	if( !isdefined( playbackTime ) )
		return 1;
		
	if ( playbackTime >= 0 )
	{
		playbackTime = playbackTime * .001;
	}
	else
	{
		playbackTime = 1;
	}

	return playbackTime;
}

function play_music_2d( str_sound, playbackTime )
{
	if( level.music_playing )
		return;

	util::clientnotify( "pe_cancel_music" );
	sound_ent = Spawn("script_origin", (0,0,0));
	level.music_playing = true;

	sound_ent PlaySound( str_sound );
	level util::waittill_any_timeout( playbackTime, "end_game", "higher_priority_sound", "intermission", "end_of_round", "start_of_round" );

	sound_ent StopSound( str_sound );
	level.music_playing = false;
	util::clientnotify( "pe_activate_music" );

	sound_ent util::delay( 0.25, undefined, &zm_utility::self_delete );
}

function play_sound_for_player( index, str_sound, playbackTime )
{
	if( level.music_playing )
		return;
		
	if( self IsHost() )
		util::clientnotify( "pe_cancel_music" );

	level.music_playing = true;
	self PlayLocalSound(str_sound);
	level util::waittill_any_timeout( playbackTime, "end_game", "higher_priority_sound", "intermission", "end_of_round", "start_of_round" );
	self StopLocalSound( str_sound );
	level.music_playing = false;

	if( self IsHost() )
		util::clientnotify( "pe_activate_music" );
}

function CustomPlayerQuote( sound_to_play )		//self = player
{
	if ( !isdefined( self.isSpeaking ) )
	{
		self.isSpeaking = false;
	}

	if ( self.isSpeaking ) 	// If already speaking, cancel the speech.
	{
		return;
	}

	self.speakingLine = sound_to_play;
		
	self.isSpeaking = true;		// TODO: this will eventually be converted to a flag.
				
	if(isPlayer(self))
	{
		self clientfield::set_to_player( "isspeaking",1 ); 
	}

	playbackTime = SoundGetPlaybackTime( sound_to_play );
		
	if( !isdefined( playbackTime ) )
		return;
		
	if ( playbackTime >= 0 )
	{
		playbackTime = playbackTime * .001;
	}
	else
	{
		playbackTime = 1;
	}

	if ( !self IsTestClient() )
	{
		self PlaySoundOnTag( sound_to_play, "J_Head" );
		wait(playbackTime);
	}
		
	if( isPlayer(self) && isDefined(self.last_vo_played_time)  )
	{
		if( GetTime() < ( self.last_vo_played_time + 5000 ) )
		{
			self.last_vo_played_time = GetTime();
			waittime = 7;
		}
	}
		
	wait( waittime );
		
	self.isSpeaking = false;	// TODO: this will eventually be converted to a flag.
				
	if(isPlayer(self))
	{
		self clientfield::set_to_player( "isspeaking",0 ); 
	}
	
}