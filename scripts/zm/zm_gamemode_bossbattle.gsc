/*==========================================
Boss Battle gamemode script by ihmiskeho
V1.0
Credits:

============================================*/
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
#using scripts\shared\system_shared;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_perk_random;
#using scripts\zm\_zm_equipment;
#using scripts\ik\zm_pregame_room;
#using scripts\bosses\zm_ai_reverant;
#using scripts\ik\zm_teleporter_pe;
#using scripts\zm\zm_project_e_ee;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perks.gsh;

#precache("material", "gamemode_boss_icon");

#namespace zm_gamemode_bossbattle;

#define BOSS_HINT_STRING	"Hold ^3&&1 ^7To Enter the Fight"

REGISTER_SYSTEM_EX( "zm_gamemode_bossbattle", &init, &main, undefined )

function init()
{
	callback::on_connect(&on_connect);
}

function main()
{
	WAIT_SERVER_FRAME;
	if(!isdefined(level.CurrentGameMode))
	{
		level waittill("gamemode_chosen");
		if(isdefined(level.CurrentGameMode) && level.CurrentGameMode == "zm_boss")
		{
			level thread BossBattlesInit();
			level.perk_purchase_limit = 10;		// No perk limit in boss battles
		}
	}
}

function BossBattlesInit()
{
	struct = struct::get( "ee_tele_struct", "targetname" );
	if( !isdefined(struct) || struct.size <= 0 )
		return;

	trigger = Spawn( "trigger_radius", struct.origin, 0, 24, 24 );
	trigger TriggerIgnoreTeam();
	trigger SetVisibleToAll();
	trigger SetTeamForTrigger( "none" );
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( BOSS_HINT_STRING );

	fight_state = 0;
	for(;;)
	{
		WAIT_SERVER_FRAME;
		trigger waittill("trigger", user);
		if(IsPlayer(user) && zm_utility::is_player_valid( user ) && !user laststand::player_is_in_laststand() && !IS_TRUE(user.in_afterlife) && user UseButtonPressed())
		{
			if(level flag::get( "mid_boss_fight" ))
			{
				wait(.1);
				continue;
			}

			players = GetPlayers();
			if(fight_state < 1)
			{	
				for(i = 0; i < players.size; i++)
					players[i] thread zm_teleporter_pe::PlayTeleporterFakeFx();

				level thread HanoiFightInit(fight_state);
				wait(10);
				fight_state++;
			}

			else
			{
				for(i = 0; i < players.size; i++)
				{
					players[i] thread zm_teleporter_pe::PlayTeleporterFakeFx();
					level thread HanoiFightInit(fight_state);	// boss_fight_spawn
					level flag::clear("spawn_zombies");
					
					for( i = 0; i < players.size; i++ )
					{
						if(isdefined(players[i].bosswaypoint))
							players[i].bosswaypoint hud::destroyElem();

						if(isdefined(players[i].bossTarget))
							players[i].bossTarget Delete();
					}

					wait(10);

					for(i = 0; i < players.size; i++)
					{
						players[i] thread zm_project_e_ee::BossFightAreaWatcher();
					}
				}
			}
		}
	}
}

function HanoiFightInit( fight_state )
{
	if(!isdefined(fight_state))
		fight_state = 0;

	hanoi_room = struct::get("hanoi_room_spawn", "targetname");
	if(!isdefined(hanoi_room))
		return;

	if(fight_state > 0)
		hanoi_room = struct::get("boss_fight_spawn", "targetname");

	target = struct::get_array(hanoi_room.target, "targetname");
	if(!isdefined(target))
		return;

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		if(players[i] laststand::player_is_in_laststand() )
		{
			players[i] zm_laststand::auto_revive(players[i], 0);
		}

		WAIT_SERVER_FRAME;

		if( isdefined(target[i]) )
			players[i] thread SetOriginWithWait( target[i].origin, 1 );
			//players[i] SetOrigin(target[i].origin);
	}
}

function SetOriginWithWait( origin, time )
{
	if(!isdefined(time))
		time = 1;

	if(!isdefined(origin))
		return;

	wait(time);
	self SetOrigin(origin);
}

function on_connect()
{
	self thread BossFightWaypoint();
}

function BossFightWaypoint()
{
	if(isdefined(self.bosswaypoint))
		return;
		
	if(!isdefined(level.CurrentGameMode))
	{
		level waittill("gamemode_chosen");
		if(isdefined(level.CurrentGameMode) && level.CurrentGameMode != "zm_boss")
		{
			return;
		}
	}

	struct = struct::get( "ee_tele_struct", "targetname" );
	self.bossTarget = util::spawn_model("tag_origin", struct.origin);
	if( !isdefined(struct) || struct.size <= 0 )
		return;

	self.bosswaypoint = NewClientHudElem( self );
	self.bosswaypoint SetShader("gamemode_boss_icon", 16, 16);
	self.bosswaypoint SetWayPoint(true, "gamemode_boss_icon");
	self.bosswaypoint.alpha = 0.5;
	self.bosswaypoint SetTargetEnt(self.bossTarget);
}



