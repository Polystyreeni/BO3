#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\array_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_utility;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_behavior;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\zm\_zm_ai_dogs;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_laststand;
#using scripts\shared\system_shared;
#using scripts\shared\clientfield_shared;
#using scripts\zm\zm_project_e_ee;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\callbacks_shared;
#using scripts\ik\zm_teleporter_pe;

//ENGINEER
#using scripts\bosses\zm_engineer;
//Avogadro
#using scripts\bosses\zm_avogadro;

//7.11.17 ADDED ZOMBIE BLOOD
#using scripts\_NSZ\nsz_powerup_zombie_blood;

#insert scripts\shared\aat_zm.gsh;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using_animtree( "generic" );

#define GHOST_HEALTH				100000
#define GHOST_ATTACK_DAMAGE			80		//Direct attack damage
#define GHOST_SWARM_DAMAGE			20
#define GHOST_SWARM_LIFETIME		8
#define GHOST_SWARM_AMOUNT			10		//How many "projectiles" spawn with the swarm attack
#define GHOST_ATTACK_COOLDOWN		8		//pretty self explanatory

#define GHOST_BLAST_FX	"custom/fx_ghost_blast"
#define GHOST_SWARM_FX	"project_elemental/fx_ritual_black"
#define GHOST_ATTACK_HIT "explosions/fx_exp_grenade_dirt"

//CUTSCENE STUFF
#define M_RICHTOFEN		"germ_body"
#define M_DEMPSEY		"dem_body"
#define M_NIKOLAI		"russian_body"
#define M_TAKEO			"tak_body"
#define M_SCIENTIST     "c_rus_scientist_body"
#define M_SCIENTIST_2 	"c_rus_scientist_body_2"
#define M_SCIENTIST_3 	"c_rus_scientist_body_3"
#define M_SCIENTIST_4 	"c_rus_scientist_body_4"
#define M_SCIENTIST_5 	"c_rus_scientist_body_5"

#precache("model", "c_rus_scientist_body_ghost");
#precache("model", "zm_115_meteor1");
#precache("model", "doom_reverant");

#precache("model", M_RICHTOFEN);
#precache("model", M_DEMPSEY);
#precache("model", M_NIKOLAI);
#precache("model", M_TAKEO);

#precache("model", M_SCIENTIST_3);
#precache("model", M_SCIENTIST_4);
#precache("model", M_SCIENTIST_5);

#precache("fx", GHOST_BLAST_FX);
#precache("fx", GHOST_SWARM_FX);
#precache("fx", GHOST_ATTACK_HIT);
#precache( "fx", "zombie/fx_ee_altar_mist_zod_zmb" );

#namespace zm_hanoi_boss; 

REGISTER_SYSTEM( "zm_hanoi_boss", &init, undefined )

function init()
{
	clientfield::register( "scriptmover", "ghost_boss_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "ghost_charge_fx", VERSION_SHIP, 1, "int" );
	//clientfield::register( "scriptmover", "ghost_blast_fx", VERSION_TU12, 1, "counter" );
	clientfield::register( "scriptmover", "ghost_blast_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "ghost_directattack_fx", VERSION_TU12, 1, "counter" );

	clientfield::register( "scriptmover", "barrier_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "scriptmover", "tele_portal", VERSION_SHIP, 1, "int" );

	clientfield::register( "toplayer", "in_midigc", VERSION_SHIP, 1, "int" );

	level.bw_vision = "zm_bw_vision";

	visionset_mgr::register_info( "visionset", level.bw_vision,VERSION_SHIP, 90, 16, true, &visionset_mgr::ramp_in_out_thread_per_player_death_shutdown, false   );

	// callback::on_spawned(&DebugSpawnPlayers);
}

function DebugSpawnPlayers()
{
	self thread SpawnClones();
}

function SpawnClones()
{
	while(1)
	{
		if(self OffhandSpecialButtonPressed())
		{
			wait(1);
			if(self OffhandSpecialButtonPressed())
			{
				model = SpawnClone( self.origin, GetCharacterModel( self GetCharacterBodyType() ), self.angles, GetRandomAnimation() );
				wait(2);
			}
		}
		wait(.2);
	}
}

function StartMidCutscene()
{
	cam_struct = struct::get("mid_cutscene_camera2", "targetname");
	players = GetPlayers();
	for(j = 0; j < players.size; j++)
	{
		players[j] thread FadeToBlack( 2.5 );
		visionset_mgr::activate( "visionset", level.bw_vision, players[j], 1, 90000, 1 );
		players[j] clientfield::set_to_player("in_midigc", 1);
	}

	level flag::clear("spawn_zombies");
	level CutsceneState2();
}

function StartFight()
{
	spawn = struct::get("hanoi_boss_spawn", "targetname");
	if(!isdefined(spawn))
		return;

	cam_struct = struct::get("hanoi_camera_1", "targetname");
	if(!isdefined(cam_struct))
		return;

	barrriers = struct::get_array("hanoi_barrier", "targetname");
	if(!isdefined(barrriers))
		return;

	level thread CutSceneDialog();

	players = GetPlayers();

	for(j = 0; j < players.size; j++)
	{
		visionset_mgr::deactivate( "visionset", level.bw_vision, players[j] );
		players[j] clientfield::set_to_player("in_midigc", 0);
		//players[j] thread FadeToBlack( 2 );
		players[j] thread HanoiCameraMovement( cam_struct );
		players[j] PlayLocalSound("timewarp_teleport");
		players[j] HanoiSetPlayerState(1);
	}

	level thread HanoiCutscenePlayers();

	wait(22);

	for(j = 0; j < players.size; j++)
	{
		players[j] HanoiSetPlayerState(0);
	}

	PlayFX( level._effect["fx_ee_explo_ritual_zod_zmb"], spawn.origin );
	ghost = util::spawn_model("c_rus_scientist_body_ghost", spawn.origin, spawn.angles);

	if(!isdefined(ghost))
		return;

	ghost UseAnimTree(#animtree);
	ghost AnimScripted("note_notify", ghost.origin, ghost.angles, %ai_t6_avo_idle);
	util::playSoundOnPlayers("beastmode_start_00", undefined);

	wait(2);

	foreach(barrier in barrriers)
	{
		barrier thread BlockFX();
	}

	for(j = 0; j < players.size; j++)
	{
		players[j] CameraActivate( 0 );
	}

	ghost EnableLinkTo();
	WAIT_SERVER_FRAME;
	ghost.aim_model = Spawn("script_model", ghost.origin);
	ghost.aim_model SetModel("tag_origin");
	ghost.aim_model.angles = spawn.angles;
	ghost.aim_model EnableLinkTo();
	ghost LinkTo(ghost.aim_model);
	
	WAIT_SERVER_FRAME;

	ghost thread FindFlesh();
	ghost thread HandleAttack();
	ghost thread TakeDamage();

	ghost clientfield::set("ghost_boss_fx", 1);

	ghost.health = Int( GHOST_HEALTH * level.players.size );
	ghost SetCanDamage(1);
	ghost PlayLoopSound("ghost_loop");

	//Setting up boss specific stuff here
}

function HanoiSetPlayerState( state )
{
	if(state)
	{
		self FreezeControls( true );
		self DisableOffhandWeapons();
		self DisableWeapons();
		util::wait_network_frame();
	}

	else
	{
		self FreezeControls( false );
		self EnableOffhandWeapons();
		self EnableWeapons();
		self DisableInvulnerability();
		self AllowSprint(true);
		util::wait_network_frame();
	}
}


function FadeToBlack( duration, initial_wait = undefined, no_fade = false )
{
	self endon("intermission");
	time = duration;

	if(isdefined(initial_wait))
		wait(initial_wait);

	fadeToWhite = NewClientHudElem( self );
	fadeToWhite.x = 0;
	fadeToWhite.y = 0;
	fadeToWhite.alpha = 0;

	fadeToWhite.horzAlign = "fullscreen";
	fadeToWhite.vertAlign = "fullscreen";
	fadeToWhite.foreground = false;
	fadeToWhite.sort = 50;
	fadeToWhite SetShader( "black", 640, 480 );
	
	if(!no_fade)
	{
		fadeToWhite FadeOverTime( 1 );
	}

	fadeToWhite.alpha = 1;
	wait(time);
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 0;
	wait(1);
	fadeToWhite Destroy();
}

function CutSceneDialog() 	
{
	util::playSoundOnPlayers("vox_cutscene_hanoi_00", undefined);
	wait(2);
	util::playSoundOnPlayers("vox_cutscene_hanoi_01", undefined);
	wait(3.5);
	util::playSoundOnPlayers("vox_cutscene_hanoi_02", undefined);
	wait(2.5);
	util::playSoundOnPlayers("vox_cutscene_hanoi_03", undefined);
	wait(4);

	level thread zm_project_e_ee::SmPlayQuote( "vox_sm_hanoi_boss_start" );

}

function HanoiCameraMovement( camera )
{
	target = struct::get(camera.target, "targetname");
	if(!isdefined(target))
		return;

	cam3 = struct::get(target.target, "targetname");
	if(!isdefined(cam3))
	{
		IPrintLnBold("Camera not found");
	}

	self CameraSetPosition( camera.origin );
	self CameraSetAngles( camera.angles );
	self CameraActivate( 1 );

	wait(3);

	self StartCameraTween(3);
	self CameraSetPosition( target.origin );
	self CameraSetAngles( target.angles );

	wait(5);

	self StartCameraTween(2);
	self CameraSetPosition( cam3.origin );
	self CameraSetAngles( cam3.angles );

	wait(4);
}

function HanoiCutscenePlayers()
{
	spawns = struct::get_array( "hanoi_cutscene_player_spawn", "targetname" );
	if(!isdefined(spawns))
		return;

	target_locations = struct::get_array("hanoi_cutscene_player_spawn_2", "targetname");
	if(!isdefined(target_locations))
		return;

	a_models = [];

	for( i = 0; i < spawns.size; i++)
	{
		util::wait_network_frame();
		a_models[a_models.size] = SpawnClone( spawns[i].origin, GetCharacterModel( i ), spawns[i].angles, %pb_cutscene_walk );
	}

	PlayFX(level._effect["fx_ee_explo_ritual_zod_zmb"], spawns[0].origin);

	wait(2.2);
	for(j = 0; j < a_models.size; j++)
	{
		loc = undefined;
		a_models[j] StopAnimScripted();
		for(z = 0; z < target_locations.size; z++)
		{
			if( isdefined(target_locations[z].script_int) && target_locations[z].script_int == a_models[j].mdlIndex ) 
			{
				loc = target_locations[z];
			}
		}

		if(!isdefined(loc))
		{
			IPrintLnBold("Location not defined!");
			loc = target_locations[j];
		}

		a_models[j].origin = loc.origin;
		a_models[j].angles = loc.angles;

		wait(.05);

		if(isdefined(a_models[j].mdlIndex) && a_models[j].mdlIndex == 0)
			a_models[j] util::delay(1.5, undefined, &setAnimation, "pb_cutscene_talk_aggressive");	// a_models[j] AnimScripted("note_notify", a_models[j].origin, a_models[j].angles, %pb_cutscene_talk_aggressive);
			
		else
			a_models[j] AnimScripted("note_notify", a_models[j].origin, a_models[j].angles, GetRandomAnimation());

	}

	wait(15);

	foreach( model in a_models )
	{
		model Delete();
	}
}

function GetRandomAnimation()
{
	random = RandomInt(4);

	switch(random)
	{
		case 0:
			return %pb_cutscene_stand_ar;

		case 1:
			return %pb_cutscene_stand_gloves;

		case 2:
			return %pb_cutscene_stand_noweapon;

		case 3:
			return %pb_cutscene_stand_pistol;

		default:
			return %pb_cutscene_stand_ar;
	}
}

function CameraMovement( cam_struct, target = undefined, movespeed = undefined )	//self = player
{
	self CameraSetPosition( cam_struct.origin );
	self CameraSetAngles( cam_struct.angles );
	self CameraActivate( 1 );

	if(isdefined(target))
	{
		wait(0.2);
		self StartCameraTween( (movespeed - 1) );
		self CameraSetPosition( target.origin );
		self CameraSetAngles( target.angles );
	}
}

function CutsceneState1()
{
	struct = struct::get("mid_cutscene_scientist_pos1", "targetname");
	if(!isdefined(struct))
	{
		IPrintLnBold("Struct not Defined!");
		return;
	}

	model = SpawnClone( struct.origin, M_SCIENTIST, struct.angles, %pb_t5_cutscene_stand );
	wait(6);

	level CutsceneState2();
}

function CutsceneState2()
{
	struct = struct::get("mid_cutscene_scientist_pos2", "targetname");
	if( !isdefined(struct) )
	{
		IPrintLnBold("Scientist struct not defined!");
		return;
	}

	model = SpawnClone( struct.origin, M_SCIENTIST, struct.angles, %pb_t5_cutscene_stand );
	if( !isdefined(model) )
	{
		IPrintLnBold("Model not defined!");
		return;
	}

	cutscene_spawns = struct::get_array("hanoi_cutscene_room_spawn", "targetname");
	if( !isdefined(cutscene_spawns) )
	{
		IPrintLnBold("Spawns not Defined!");
		return;
	}

	prev_origin = [];

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		prev_origin[i] = players[i].origin + (0, 0, 10);
		players[i] SetOrigin(cutscene_spawns[i].origin);
		players[i] SetPlayerAngles(cutscene_spawns[i].angles);
		players[i] AllowSprint(false);
		players[i] DisableWeapons();
	}

	wait(2);
	//PlaySoundAtPosition("vox_observer_midigc_00", model.origin);

	wait(3);

	lui::screen_flash( 0.2, 0.5, 1.0, 0.8, "white" ); // flash

	level CutsceneState3( model, prev_origin );
}

function CutsceneState3( model, a_plr_origin )
{
	if( !isdefined(model) )
		return;

	struct_tele = struct::get("mid_cutscene_tele_struct", "targetname");
	if(!isdefined(struct_tele))
		return;

	struct = struct::get("mid_cutscene_scientist_pos1", "targetname");
	if(!isdefined(struct))
		return;

	door = GetEnt("mid_cutscene_door", "targetname");
	if(!isdefined(door))
		return;

	//model Delete();
	//model = SpawnClone( struct_tele.origin, M_SCIENTIST, struct_tele.angles, %pb_t5_cutscene_stand );
	
	model StopAnimScripted();
	model.origin = struct_tele.origin;
	model.angles = (0, 90, 0);
	WAIT_SERVER_FRAME;
	model AnimScripted("note_notify", model.origin, model.angles, %pb_t5_cutscene_stand );

	scientist2 = SpawnClone( struct.origin, M_SCIENTIST_2, struct.angles, %pb_t5_cutscene_walk );
	//scientist2 PlaySound("vox_observer_midigc_00");
	if(!isdefined(scientist2))
		return;

	wait(3);
	//scientist2 PlaySound("vox_observer_midigc_01");
	scientist2 AnimScripted("note_notify", scientist2.origin, scientist2.angles, %pb_t5_cutscene_stand );
	wait(2);
	// PlaySoundAtPosition("vox_doctor_midigc_00", model.origin);	//TODO: Add some better quote here ???
	wait(3);

	door PlaySound( "final_tele_door" );
	door MoveZ( 120, 2 );

	PlaySoundAtPosition( "teleporter_warmup", model.origin );
	PlayFX( level._effect["fx_teleporter_beam_factory"], model.origin );

	wait(2);

	fxmodel = util::spawn_model( "tag_origin", struct_tele.origin );
	fxmodel clientfield::set( "tele_portal", 1 );

	model StopAnimScripted();
	WAIT_SERVER_FRAME;
	model AnimScripted("note_notify", model.origin, model.angles, %player_ritual_loop);

	PlaySoundAtPosition( "beastmode_start_00", fxmodel.origin );
	
	WAIT_SERVER_FRAME;
	fxmodel PlayLoopSound( "ghost_loop" );
	
	wait(1);
	PlaySoundAtPosition( "vox_sm_pain_final", fxmodel.origin );
	wait(1);

	PlayFX(level._effect["fx_ee_explo_ritual_zod_zmb"], model.origin);
	WAIT_SERVER_FRAME;
	model Hide();

	lui::screen_flash( 0.2, 0.5, 1.0, 0.8, "white" ); // flash
	level CutsceneState4( model, fxmodel, door, a_plr_origin, scientist2 );
}

function CutsceneState4( model, fxmodel, door, a_plr_origin, scientist2 )
{
	if( !isdefined(model) )
		return;

	if( !isdefined(fxmodel) )
		return;

	a_pos = struct::get_array("mid_cutscene_scientist_generic_position", "targetname");
	if(!isdefined(a_pos))
		return;

	a_characters = [];
	a_characters[a_characters.size] = scientist2;

	for(i = 0; i < a_pos.size; i++)
	{
		animation = a_pos[i].script_noteworthy;
		observer = a_pos[i].script_string;
		if(!isdefined(animation))
			animation = "pb_t5_cutscene_stand";

		if(!isdefined(observer))
			observer = M_SCIENTIST_4;

		character = SpawnClone( a_pos[i].origin, observer, a_pos[i].angles, animation );
		a_characters[a_characters.size] = character;

		if(animation == "pb_t5_cutscene_walk_fast")
		{
			character util::delay(2, undefined, &setAnimation, "pb_t5_cutscene_stand");
		}

		if(animation == "pb_t5_cutscene_stand_armed")
		{
			character util::delay(8, undefined, &setAnimation, "pb_t5_cutscene_stand_armed_aim");
		}
	}

	PlaySoundAtPosition("vox_midigc_viet_generic_00", a_pos[0].origin);

	wait(8);
	PlaySoundAtPosition("tele_power_down", model.origin);

	door MoveZ(-120, 2);
	PlaySoundAtPosition("vox_midigc_viet_generic_01", a_pos[0].origin);

	wait(3);

	door Delete();
	PlayFX( level._effect["fx_elec_teleport_flash_sm"], fxmodel.origin + (0, 0, 20) );
	model Show();
	model SetModel("c_rus_scientist_body_ghost");
	model.origin = fxmodel.origin;

	model PlayLoopSound("portal_loop");
	model AnimScripted( "note_notify", model.origin, model.angles, %ai_t6_avo_idle );

	wait(3);
	model PlaySound( "vox_doctor_midigc_03" );
	wait(4);

	PlaySoundAtPosition("zmb_sam_egg_appear", model.origin);

	rev = util::spawn_model("doom_reverant", model.origin, (0, 90, 0));
	rev UseAnimTree(#animtree);
	rev AnimScripted("note_notify", rev.origin, rev.angles, %ai_zombie_base_walk_ad_v20);
	rev PlaySound("vox_reverant_spawn");
	WAIT_SERVER_FRAME;
	PlayFX(level._effect["fx_ee_explo_ritual_zod_zmb"], rev.origin);

	wait(1);
	PlaySoundAtPosition("vox_midigc_viet_generic_02", a_pos[0].origin);
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] thread zm_teleporter_pe::PlayTeleporterFakeFx( false );
		players[i] PlayLocalSound("teleport_timetravel");
	}

	wait(.6);

	hanoi_room = struct::get("hanoi_room_spawn", "targetname");
	a_target = struct::get_array(hanoi_room.target, "targetname");

	for(i = 0; i < players.size; i++)
	{
		players[i] thread FadeToBlack( 2, 0, true );
		players[i] SetOrigin(a_target[i].origin);
	}

	wait(1);
	
	level thread StartFight();

	WAIT_SERVER_FRAME;
	WAIT_SERVER_FRAME;
	WAIT_SERVER_FRAME;

	model Delete();
	rev Delete();

	for(i = 0; i < a_characters.size; i++)
	{
		a_characters[i] zm_utility::self_delete();
	}

	fxmodel clientfield::set("tele_portal", 0);
	fxmodel util::delay( 0.25, undefined, &zm_utility::self_delete );

}

function setAnimation( animation )
{
	self AnimScripted( "note_notify", self.origin, self.angles, animation );
}

function SpawnClone( position, model, angles, animation )
{
	if(!isdefined(position))
		return undefined;

	if(!isdefined(model))
		model = M_SCIENTIST;

	if(!isdefined(angles))
		angles = (0, 0, 0);


	clone = util::spawn_model(model, position, angles);

	if(isdefined(animation))
	{
		clone UseAnimTree(#animtree);
		clone AnimScripted( "note_notify", clone.origin, clone.angles, animation );
	}

	if(model == M_DEMPSEY)
		clone.mdlIndex = 0;

	if(model == M_RICHTOFEN)
		clone.mdlIndex = 2;

	if(model == M_NIKOLAI)
		clone.mdlIndex = 1;

	if(model == M_TAKEO)
		clone.mdlIndex = 3;


	return clone;
}

function SelectAnimation()
{
	//First the players will walk a few seconds, then stop idle
	
	self AnimScripted("note_notify", self.origin, self.angles, %pb_cutscene_walk);

	wait(3);

	random2 = RandomInt(4);
	switch(random2)
	{
		case 0:
		self AnimScripted( "note_notify", self.origin, self.angles, %pb_cutscene_stand );	
		break;

		case 0:
		self AnimScripted( "note_notify", self.origin, self.angles, %pb_cutscene_stand_pistol );	
		break;

		case 0:
		self AnimScripted( "note_notify", self.origin, self.angles, %pb_cutscene_stand_ar );	
		break;

		case 0:
		self AnimScripted( "note_notify", self.origin, self.angles, %pb_cutscene_stand );	
		break;
		
	}
}

function GetCharacterModel( index )
{
	switch( index )
	{
		case 0:
			return M_RICHTOFEN;

		case 1:
			return M_DEMPSEY;

		case 2:
			return M_NIKOLAI;

		case 3:
			return M_TAKEO;

		case 4:
			return M_SCIENTIST_3;

		case 5:
			return M_SCIENTIST_4;

		case 6:
			return M_SCIENTIST_5;

		default:
			return M_RICHTOFEN;
	}	
}

function FindFlesh()
{
	level endon("end_game");
	level endon("hanoi_completed");
	level endon("intermission");
	self endon("death");

	//self.aim_model = util::spawn_model("tag_origin", self.origin, self.angles);
	//self.aim_model EnableLinkTo();
	self EnableLinkTo();
	//self LinkTo(self.aim_model);

	while(1)
	{
		if(isDefined(self.enemy) && zm_utility::is_player_valid(self.enemy) && isDefined(self.enemy.cyber_track_countdown) && self.enemy.cyber_track_countdown > 0 )	//7.1.17 ADDED ZOMBIE BLOOD
		{
			//IPrintLn("Enemy: " +self.enemy.playername );
			self.enemy.cyber_track_countdown -= 0.05;
			//self.v_zombie_custom_goal_pos = self.cyber_enemy.origin; 
		}
		else
		{
			//IPrintLn("Boss finding new enemy");
			players = GetPlayers();
			targets = array::get_all_closest(self.origin, players);
			for(i = 0; i<targets.size; i++)
			{
				if(zm_utility::is_player_valid(targets[i]) && !targets[i] laststand::player_is_in_laststand())
				{
					self.enemy = targets[i];
					//self.v_zombie_custom_goal_pos = self.cyber_enemy.origin; 

					//cyber_debug("new target selected");
					if( !isDefined(targets[i].cyber_track_countdown) )
						targets[i].cyber_track_countdown = 2; 
					if( isDefined(targets[i].cyber_track_countdown) && targets[i].cyber_track_countdown <= 0 )
						targets[i].cyber_track_countdown = 2; 
					break; 
				}
			}
		}

		self AimAtEnemy( self.enemy );
		wait(0.05);
	}
}

function AimAtEnemy( enemy )
{
	if(!isdefined(enemy))
	{
		enemy = self GetNewEnemy();
	}

	cyber_origin = self.origin;
	enemy_origin = enemy.origin;
	cyber_angles = self GetAngles();

	new_face_direction = VectortoAngles( enemy_origin - cyber_origin );

	self.aim_model RotateTo((cyber_angles[0], new_face_direction[1], cyber_angles[2]), 0.1);
	//IPrintLn(self.aim_model.angles);
	wait(0.1);
}

function GetNewEnemy()
{
	players = GetPlayers();
	targets = array::get_all_closest(self.origin, players);
	for(i = 0; i < targets.size; i++)
	{
		if(zm_utility::is_player_valid(targets[i]) && !targets[i] laststand::player_is_in_laststand())
		{
			self.enemy = targets[i];
			//self.v_zombie_custom_goal_pos = self.cyber_enemy.origin; 

			//cyber_debug("new target selected");
			if( !isDefined(targets[i].cyber_track_countdown) )
				targets[i].cyber_track_countdown = 2; 
			if( isDefined(targets[i].cyber_track_countdown) && targets[i].cyber_track_countdown <= 0 )
				targets[i].cyber_track_countdown = 2; 

			break; 
		}
	}

	return self.enemy;
}

function HandleAttack()	//self = ghost
{
	level endon("hanoi_completed");
	self endon("death");

	while(isdefined(self))
	{
		wait(GHOST_ATTACK_COOLDOWN);
		rand = RandomInt(3);
		//IPrintLnBold("Choosing attack...");
		switch(rand)
		{
			case 0:
				self DirectAttack();
				break;

			case 1:
				self SwarmAttack();
				break;

			case 2:
				self BlastAttack();
				break;

			default:
				self DirectAttack();
				break;

		}
	}
}

function DirectAttack()
{
	targetpos = self.enemy.origin;
	self AnimScripted("note_notify", self.origin, self.angles, %ai_t6_avo_ranged_attack);
	wait(GetAnimLength(%ai_t6_avo_ranged_attack));

	projectile = util::spawn_model("tag_origin", self GetTagOrigin("tag_weapon_right"));
	PlayFXOnTag(GHOST_SWARM_FX, projectile, "tag_origin");

	self PlaySound("ghost_attack");

	self AnimScripted("note_notify", self.origin, self.angles, %ai_t6_avo_ranged_attack_end);

	projectile MoveTo(targetpos, Distance(self.origin, targetpos) / 1000);
	projectile waittill("movedone");

	PlaySoundAtPosition("ghost_attack_impact", projectile.origin);

	projectile clientfield::increment("ghost_directattack_fx");
	WAIT_SERVER_FRAME;
	projectile Ghost();
	RadiusDamage(targetpos, 200, GHOST_ATTACK_DAMAGE, GHOST_ATTACK_DAMAGE);
	projectile util::delay( 0.25, undefined, &zm_utility::self_delete );

	self AnimScripted("note_notify", self.origin, self.angles, %ai_t6_avo_idle);

}

function SwarmAttack()
{
	thread zm_project_e_ee::SmPlayQuote("vox_sm_hanoi_boss_03");

	self MoveZ(-20, 1);
	wait(1);

	//IPrintLnBold("Swarm attack");
	for(i = 0; i < GHOST_SWARM_AMOUNT; i++)
	{
		projectile = util::spawn_model("tag_origin", self.origin, self.angles);
		WAIT_SERVER_FRAME;
		PlayFXOnTag(GHOST_SWARM_FX, projectile, "tag_origin");
		projectile PlayLoopSound("tomahawk_loop");
		projectile thread SwarmProjectileStart( self );
		projectile thread DeleteAfterTime( GHOST_SWARM_LIFETIME );
		wait(.1);
	}

	self MoveZ(20, 0.1);
}

function SwarmProjectileStart( attacker )
{
	self PlaySound("ghost_attack");
	dir = AnglesToForward( attacker.angles );
	
	end_pos = self.origin + (dir[0] * RandomInt(500), dir[1] * RandomInt(500), 500);
	self MoveTo(end_pos, 1.5, 0.5, 0);
	self waittill("movedone");

	v_dir = AnglesToUp( self.angles );
	targetpos = (v_dir[0] * 1000, v_dir[1] * 1000, v_dir[2] * 1000);

	trace = BulletTrace( self.origin, targetpos, false, self );
	target = trace["position"];

	if(!isdefined(target))
	{
		self Delete();
		return;
	}

	self MoveZ( -600, 0.7 );
	//self MoveTo(target.origin, 0.7);
	//self waittill("movedone");
	wait(.7);

	players = GetPlayers();
	players = util::get_array_of_closest(self.origin, players, undefined, undefined, 80);
	if(isdefined(players))
	{
		foreach(player in players)
		{
			player DoDamage( GHOST_SWARM_DAMAGE, target.origin, attacker );	
			player ShellShock( "frag_grenade_mp", 1.0 );
		}
	}

	PlaySoundAtPosition("ghost_attack_impact", self.origin);

	self clientfield::increment("ghost_directattack_fx");
	self util::delay( 0.25, undefined, &zm_utility::self_delete );

}

function ProjectileFindTarget()	//self = projectile
{
	players = GetPlayers();

	if(!isdefined(players))
		return undefined;

	valid_players = [];
	foreach(player in players)
	{
		if( IsAlive(player) && zm_utility::is_player_valid( player ) && !player laststand::player_is_in_laststand() )
		{
			valid_players[valid_players.size] = player;
		}
	}

	if(!isdefined(valid_players))
		return undefined;

	closest = ArrayGetClosest( self.origin, valid_players );

	return closest;
}

function DeleteAfterTime( time )
{
	wait(time);
	if(isdefined(self))
		self Delete();
}

function BlastAttack()
{
	thread zm_project_e_ee::SmPlayQuote( "vox_sm_hanoi_boss_0" + RandomInt(3) );

	self clientfield::set("ghost_charge_fx", 1);

	//self PlaySound("bomb_rampup");
	original_pos = self.origin;
	end_pos = self.origin + (0, 0, 30);

	self.aim_model MoveTo(end_pos, 2);
	wait(4);
	//wait(.5);

	self clientfield::set("ghost_charge_fx", 0);
	
	self clientfield::set("ghost_blast_fx", 1);
	util::playSoundOnPlayers("ghost_blast_attack", undefined);

	players = GetPlayers();
	foreach(player in players)
	{
		player thread BlastDamage( self );
	}

	self.aim_model MoveTo( original_pos, 0.5 );
	wait(.5);
	self clientfield::set("ghost_blast_fx", 0);
	//IPrintLnBold("Blast attack done");

}

function TakeDamage()	//self = ghost
{
	level endon("end_game");

	for(;;)
	{
		self waittill("damage", amount, attacker);
		if(IsPlayer(attacker))
		{
			attacker show_hit_marker();
			self.health -= amount;
			if(self.health <= 0)
			{
				GhostDeath( attacker );
				break;
			}
		}
	}
}

function GhostDeath( attacker )
{
	level notify("hanoi_completed");
	level notify("higher_priority_sound");

	thread zm_project_e_ee::SmPlayQuote("vox_sm_hanoi_boss_death_00");

	self clientfield::set("ghost_boss_fx", 0);

	PlayFX(level._effect["fx_ee_explo_ritual_zod_zmb"], self.origin);
	WAIT_SERVER_FRAME;
	self Ghost();

	PlaySoundAtPosition("zmb_sam_egg_appear", self.origin);

	self util::delay( 0.25, undefined, &zm_utility::self_delete );

}

function BlastDamage( attacker )
{
	if( DistanceSquared(self.origin, attacker.origin) > 10000000 )
		return;

	if( self GetStance() == "prone" || self GetStance() == "crouch" )
		return;

	if( self laststand::player_is_in_laststand() )
		return;

	self DoDamage( Int((self.health / 2) + 30 ), self.origin, attacker );
	self SetElectrified(1.0);
}

function show_hit_marker()  // self = player
{	
	if ( IsDefined( self ) && IsDefined( self.hud_damagefeedback ) )
	{
		self.hud_damagefeedback SetShader( "damage_feedback", 24, 48 );
		self.hud_damagefeedback.alpha = 1;
		self.hud_damagefeedback FadeOverTime(1);
		self.hud_damagefeedback.alpha = 0;
		self PlaySoundToPlayer( "mpl_hit_alert", self );
	}	
}

function BlockFX()
{
	model = util::spawn_model("tag_origin", self.origin, self.angles);
	if(!isdefined(model))
		return;

	model clientfield::set("barrier_fx", 1);

	level waittill("hanoi_completed");
	model clientfield::set("barrier_fx", 0);

	model util::delay( 0.25, undefined, &zm_utility::self_delete );
}

