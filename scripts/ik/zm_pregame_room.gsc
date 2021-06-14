#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_weapons;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_spawner;
#using scripts\shared\ai\zombie_utility;	
#using scripts\zm\_zm_audio;
#using scripts\shared\scene_shared;
#using scripts\zm\_zm;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\ai\zombie_death;
#using scripts\zm\zm_gamemode_gungame;
#using scripts\zm\zm_project_e_ee;

//Custom Powerups By ZoekMeMaar
#using scripts\_ZoekMeMaar\custom_powerup_free_packapunch;

#insert scripts\shared\shared.gsh;

#namespace zm_pregame_room;

#precache("material", "gamemode_normal_icon");
#precache("material", "gamemode_gungame_icon");
#precache("material", "gamemode_scavenger_icon");
#precache("material", "gamemode_boss_icon");

#using_animtree( "generic" ); 

REGISTER_SYSTEM_EX( "zm_pregame_room", &init, &main, undefined )

function init()
{
	level.zm_gamemodes = [];
	level.zm_gamemodes[0] = "zm_normal";
	level.zm_gamemodes[1] = "zm_classic";
	level.zm_gamemodes[2] = "zm_gungame";
	level.zm_gamemodes[3] = "zm_scavenger";
	level.zm_gamemodes[4] = "zm_boss";

/*	level.zm_gamemodes[0].display = "Normal";
	level.zm_gamemodes[1].display = "Classic";
	level.zm_gamemodes[2].display = "Gungame";
	level.zm_gamemodes[3].display = "Scavenger";
	level.zm_gamemodes[4].display = "Boss Battles";

	level.zm_gamemodes[0].hint = "Unravel the secrets of this undead testing facility";
	level.zm_gamemodes[1].hint = "Back to basics. No objectives, survive the endless horde of zombies";
	level.zm_gamemodes[2].hint = "Gain new weapons by getting points. First to go through all weapons wins";
	level.zm_gamemodes[3].hint = "Zombies drop ammo and weapons. No wall weapons, no mystery box";
	level.zm_gamemodes[4].hint = "Gear up and enter the fight!";*/

	level.selected_gamemode = level.zm_gamemodes[0];

	callback::on_spawned( &CheckForPlayersInRoom );
}

function main()
{
	level.round_prestart_func = &WaitForGamemodeChosen;	

	WAIT_SERVER_FRAME;
	level flag::wait_till("initial_blackscreen_passed");
	triggers = GetEntArray("gamemode_selection_trigger", "targetname");
	if(!isdefined(triggers))
	{
		IPrintLnBold("No Gamemode Select triggers found!");
		return;
	}

	for(i = 0; i < triggers.size; i++)
	{
		//IPrintLnBold("function thread");
		triggers[i] thread WatchGameMode();
	}

	elevator = GetEnt("intro_elevator_trigger","targetname");
	if(!isdefined(elevator))
	{
		IPrintLnBold("No elevator trigger found!");
		return;
	}

	elevator thread WatchPlayerEnter();

	start_area = GetEnt("start_area", "targetname");
	if( isdefined(start_area) )
		start_area thread StartAreaWatcher();
}

function WaitForGamemodeChosen()
{
	WAIT_SERVER_FRAME;
	level waittill("gamemode_chosen");

	n_delay = 2;
		
	if ( IsDefined( level.zombie_round_start_delay ) )
	{
		n_delay = level.zombie_round_start_delay;
	}
		
	wait n_delay;

}

function WatchGameMode()
{
	level endon("intermission");
	int = self.script_int;
	if(!isdefined(int))
	{
		int = 0;
	}

	self.votes = 0;
	string = GetGameModeName(int);	//level.zm_gamemodes[int];

	if(isdefined(string))
	{
		self SetHintString( "Press ^3[{+activate}]^7 to Set Gamemode: "+string );
	}

	self SetCursorHint("HINT_NOICON");

	while(1)
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid(user) )
		{
			//IPrintLnBold("Used Trigger");
			if(user IsHost())
			{
				level.selected_gamemode = level.zm_gamemodes[int];
				IPrintLnBold("Current Gamemode Is: " + GetDisplayName(int));
				user PlayLocalSound("afterlife_enter");
			}

			else 
			{
				if(isdefined(user.gamemode_vote_cast) && user.gamemode_vote_cast <= 0)
				{
					user.gamemode_vote_cast++;
					self.votes++;
					self SetHintString( self.votes + " Votes for " + GetDisplayName(int) );
				}
			}	
		}
	}
}

function GetGameModeName( index )
{
	switch(index)
	{
		case 0:
		return "Normal\nThe full Experience";

		case 1:
		return "Classic\nNo Quests, return to the Roots";

		case 2:
		return "Gun Game\nKill zombies to Earn new Weapons";

		case 3:
		return "Scavenger\nAll weapons dropped by zombies";

		case 4:
		return "Boss Battles\nEnter the boss fights when ready";
	}
}

function GetDisplayName( index )
{
	if(!isdefined(index))
		index = 0;

	switch(index)
	{
		case 0:
		return "Normal";

		case 1:
		return "Classic";

		case 2:
		return "Gun Game";

		case 3:
		return "Scavenger";

		case 4:
		return "Boss Battles";

		default:
		return "Normal";
	}
}

function WatchPlayerEnter()
{
	level endon("intermission");
	self SetHintString("Press ^3[{+activate}]^7 to Start Game");
	self SetCursorHint("HINT_NOICON");

	while(1)
	{
		self waittill("trigger", user);
		if( IsPlayer(user) && zm_utility::is_player_valid(user) )
		{
			if(user IsHost())
			{
				PlaySoundAtPosition("switch_progress", self.origin);
				level thread CreateFadeToWhite();
				wait(1);

				level StartIntroCinematic();

				level TeleportPlayers();

				util::wait_network_frame();
				level notify( "gamemode_chosen" );
				level.CurrentGameMode = level.selected_gamemode;
				if( level.CurrentGameMode != "zm_gungame" && level.CurrentGameMode != "zm_boss" )
				{
					zm_powerups::powerup_remove_from_regular_drops( "free_packapunch" );
				}

				CreateGameModeUI( level.CurrentGameMode );
			}

			else 
			{
				user IPrintLnBold("Only the Host can Start the Game");
			}

		}
	}
}

function StartIntroCinematic()
{
	models = GetEntArray("intro_elevator_part", "targetname");
	
	for(i = 0; i < models.size; i++)
	{
		if(isdefined(models[i].script_noteworthy) && models[i].script_noteworthy == "player_model")
			models[i] SetupCinPlayerModel();

		//models[i] EnableLinkTo();
		//models[i] LinkTo(link);

	}

	camera = struct::get("intro_cinematic_camera", "targetname");
	if(!isdefined(camera))
		return;

	doors = GetEntArray("intro_elevator_door", "targetname");
	if(!isdefined(doors))
		return;

	players = GetPlayers();
	for(j = 0; j < players.size; j++)
	{
		players[j] FreezeControls(1);
		players[j] StartCameraTween(1);
		players[j] CameraSetPosition( camera.origin );
		players[j] CameraSetAngles(camera.angles);
		players[j] CameraActivate( true );
	}

	wait(4);
	
	PlaySoundAtPosition("custom_door_open_small", doors[0].origin);

	for(z = 0; z < doors.size; z++)
	{
		if(isdefined(doors[z].script_vector))
		{
			vector = VectorScale( doors[z].script_vector, 1 );
			doors[z] MoveTo( doors[z].origin + vector, 1 );
		}
	}

	wait(2);
	for(j = 0; j < players.size; j++)
	{
		players[j] CameraActivate( false );
		players[j] FreezeControls(0);
	}

	for(z = 0; z < doors.size; z++)
	{
		if(isdefined(doors[z].script_vector))
		{
			vector = VectorScale( -doors[z].script_vector, 1 );
			doors[z] MoveTo( doors[z].origin + vector, 1 );
		}
	}

	for(i = 0; i < models.size; i++)
	{
		if(isdefined(models[i].script_noteworthy) && models[i].script_noteworthy == "player_model")
			models[i] Delete();

	}

}

function SetupCinPlayerModel()	//self = model
{
	self UseAnimTree( #animtree );
	random = RandomIntRange(0, 4);
	
	switch(random)
	{
		case 0:
		self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_stand_gloves);
		break;

		case 1:
		self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_stand);
		break;

		case 2:
		self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_stand_ar);
		break;

		case 3:	//pb_cutscene_stand_noweapon
		self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_stand_noweapon);
		break;

		default:
		self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_stand_gloves);
		break;
	}	
}

function CreateGameModeUI( gamemode )
{
	switch(gamemode)
	{
		case "zm_normal":
			name = "Normal";
			icon = "gamemode_normal_icon";
			text = "Unravel the secrets of this undead testing facility";
			break;

		case "zm_classic":
			name = "Classic";
			icon = "gamemode_normal_icon";
			text = "Back to basics. No objectives, survive the endless horde of zombies";
			break;

		case "zm_gungame":
			name = "Gun Game";
			icon = "gamemode_gungame_icon";
			text = "Gain new weapons by getting points. First to go through all weapons wins";
			break;

		case "zm_scavenger":
			name = "Scavenger";
			icon = "gamemode_scavenger_icon";
			text = "Zombies drop ammo and weapons. No wall weapons, no mystery box";
			break;

		case "zm_boss":
			name = "Boss Battles";
			icon = "gamemode_boss_icon";
			text = "Gear up and enter the fight when ready!";
			break;

		default:
			name = "Normal";
			icon = "gamemode_normal_icon";
			text = "Unravel the secrets of this undead testing facility";
			break;
	}

	self endon( "death" ); 
	self endon( "disconnect" ); 
	
	
	time = 4;

	GameModeText = NewHudElem(); 
	GameModeText.alignX = "center"; 
	GameModeText.alignY = "middle"; 
	GameModeText.horzAlign = "center"; 
	GameModeText.vertAlign = "top"; 
	GameModeText.foreground = true; 
	GameModeText.font = "default"; 
	GameModeText.fontScale = 1.5; 
	GameModeText.alpha = 0; 
	GameModeText.color = ( 1.0, 1.0, 1.0 ); 
	GameModeText SetText( text );
	
	GameModeText.y = 140; 	
	if( IsSplitScreen() )
	{
		GameModeText.y = 180; 
	}
	
	GameModeText FadeOverTime( 0.1 ); 
	GameModeText.alpha = 1;

	GameModeIcon = NewHudElem();
	GameModeIcon.alignX = "center"; 
	GameModeIcon.alignY = "middle"; 
	GameModeIcon.horzAlign = "center"; 
	GameModeIcon.vertAlign = "top"; 
	GameModeIcon.foreground = true; 
	GameModeIcon.font = "default"; 
	GameModeIcon.fontScale = 1.5; 
	GameModeIcon.alpha = 0; 
	GameModeIcon SetShader( icon, 64, 64 );

	GameModeIcon.y = 70;	
	if( IsSplitScreen() )
	{
		GameModeIcon.y = 110;
	}

	GameModeIcon FadeOverTime( 0.1 );
	GameModeIcon.alpha = 1;

	GameModeName = NewHudElem();
	GameModeName.alignX = "center"; 
	GameModeName.alignY = "middle"; 
	GameModeName.horzAlign = "center"; 
	GameModeName.vertAlign = "top"; 
	GameModeName.foreground = true; 
	GameModeName.font = "default"; 
	GameModeName.fontScale = 1.5; 
	GameModeName.alpha = 0; 
	GameModeName.color = ( 1.0, 1.0, 1.0 ); 
	GameModeName SetText( name );
	
	GameModeName.y = 110;	
	if( IsSplitScreen() )
	{
		GameModeName.y = 150;
	}
	
	GameModeName FadeOverTime( 0.1 );
	GameModeName.alpha = 1;

	wait(time);
	
	GameModeIcon FadeOverTime( 1 );
	GameModeIcon.alpha = 0;

	GameModeText FadeOverTime( 1 );
	GameModeText.alpha = 0;

	GameModeName FadeOverTime( 1 );
	GameModeName.alpha = 0;

	wait(1);
	GameModeIcon Destroy();
	GameModeText Destroy();
	GameModeName Destroy();

}

function CreateFadeToWhite()
{
	self endon("intermission");
	time = 2;
	fadeToWhite = NewHudElem();
	fadeToWhite.x = 0;
	fadeToWhite.y = 0;
	fadeToWhite.alpha = 0;

	fadeToWhite.horzAlign = "fullscreen";
	fadeToWhite.vertAlign = "fullscreen";
	fadeToWhite.foreground = false;
	fadeToWhite.sort = 50;
	fadeToWhite SetShader( "black", 640, 480 );
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 1;
	wait(time);
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 0;
	wait(1);
	fadeToWhite Destroy();
}

function TeleportPlayers()
{
	/*player_respawn_points = struct::get_array("start_zone_spawns","targetname");
	if(!isdefined(player_respawn_points))
	{
		return;
	}*/

	spawn = GetStartZoneRespawns();

	if(!isdefined(spawn))
	{
		return;
	}

	structs = struct::get_array( spawn.target, "targetname" );
	if( !isdefined(structs) )
	{
		return;
	}

	players = GetPlayers();
	rand = RandomInt(players.size);
	for( i = 0; i < players.size; i++ )
	{
		players[i] SetOrigin( structs[i].origin );
		if( i == rand )
			players[i] thread playStartQuote();

		// TODO: Remove
		// IPrintLnBold("Player set to origin: " + structs[i].origin);
	}
}

function TeleportToSpawn()
{
	spawn = GetStartZoneRespawns();

	if(!isdefined(spawn))
	{
		return;
	}

	structs = struct::get_array( spawn.target, "targetname" );
	if(!isdefined(structs))
	{
		return;
	}

	point = undefined;
	for( i = 0; i < structs.size; i++)
	{
		if( !PositionWouldTelefrag(structs[i].origin) )
			point = structs[i];
	}

	if( !isdefined(point) )
		point = array::random( structs );
		
	self SetOrigin( point.origin );
}

function GetStartZoneRespawns()
{
	player_respawn_points = struct::get_array("player_respawn_point","targetname");
	if(!isdefined(player_respawn_points))
	{
		return;
	}

	valid_respawn = undefined;

	for(i = 0; i < player_respawn_points.size; i++)
	{
		if(isdefined(player_respawn_points[i].script_noteworthy) && player_respawn_points[i].script_noteworthy == "start_zone")
		{
			valid_respawn = player_respawn_points[i];
		}
	}

	return valid_respawn;
}

function CheckForPlayersInRoom()
{
	self waittill("spawned_player");

	if( !isdefined(level.CurrentGameMode) )
	{	
		self.gamemode_vote_cast = 0;		
	}

	else
	{
		if( level flag::get("boss_fight") )	//level flag::init("boss_fight");
		{
			self TeleportToFight();
		}

		else
		{
			self TeleportToSpawn();
		}	
	}
}

function TeleportToFight()
{
	spawn = struct::get("boss_fight_powerup_struct", "targetname");
	if(!isdefined(spawn))
	{
		self TeleportToSpawn();
		return;
	}

	self SetOrigin( spawn.origin );
}

function CreateGameModeMenu()
{
	self endon("disconnect");
	gamemode_menu = [];
	for(i = 0; i < level.zm_gamemodes.size; i++)
	{
		gamemode_menu[i] = NewClientHudElem(self);
		gamemode_menu[i].alingX = "center";
		gamemode_menu[i].alingY = "center";
		gamemode_menu[i].horzAlign = "center";
		gamemode_menu[i].vertAlign = "center";
		gamemode_menu[i].hidewheninmenu = true;
		gamemode_menu[i].font = "default";
		ypos = (20 + 10 * i);
		gamemode_menu[i].y = ypos;
		gamemode_menu[i] SetText( level.zm_gamemodes[i] );
		//IPrintLnBold("Created Selection Text");
	}
}

function playStartQuote()
{
	wait(3);
	sound_to_play = "vox_plr_" + self GetCharacterBodyType() + "_enter_level_00";
	self thread zm_project_e_ee::CustomPlayerQuote( sound_to_play );
}

function StartAreaWatcher()
{
	level endon("intermission");

	level waittill( "gamemode_chosen" );

	for(;;)
	{
		self waittill( "trigger", user );
		if( IsPlayer(user) )
		{
			if( isdefined(level.CurrentGameMode) )
			{
				if( level flag::get("boss_fight") )	//level flag::init("boss_fight");
				{
					user TeleportToFight();
				}

				else
				{
					user TeleportToSpawn();
				}	
			}
		}
	}
}




