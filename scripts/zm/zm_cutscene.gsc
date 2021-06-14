/*==========================================
In-game Cutscene Script
By ihmiskeho
Contains the cutscene which will play after completing the easter egg of project elemental

Credits:
JBird632: Hud element
HarryBo21 = Script help 
Abnormal202: Some basic functions and syntax help
Mathfag = Zombie spawn help
NateSmithZombies = Script Help
Symbo = Local power help
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
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_spawner;
#using scripts\shared\ai\zombie_utility;	
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_clone;
#using scripts\zm\_zm_equipment;
#using scripts\zm\_zm_perks;
#using scripts\shared\clientfield_shared;
#using scripts\zm\_zm_power;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\system_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\zm_afterlife_pe;
#using scripts\ik\zm_teleporter_pe;
#using scripts\zm\_zm_ai_dogs;
#using scripts\ik\zm_pregame_room;
#using scripts\zm\_hb21_sym_zm_trap_acid;
#using scripts\shared\math_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\music_shared;
#using scripts\zm\zm_project_e_challenges;
#using scripts\ik\zm_digsite;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_hb21_sym_zm_trap_acid.gsh;

#namespace zm_cutscene;

#using_animtree( "generic" );

#define RICHTOFEN	0
#define DEMPSEY		1
#define NIKOLAI		2
#define TAKEO 		3

#define M_RICHTOFEN		"germ_body"
#define M_DEMPSEY		"dem_body"
#define M_NIKOLAI		"russian_body"
#define M_TAKEO			"tak_body"

#precache("fx", "dlc4/genesis/fx_rune_glow_purple");

#define FX_SUMMONING_KEY_BEAM 	"zombie/fx_ee_keeper_beam_a_success_zod_zmb"
#precache("fx", FX_SUMMONING_KEY_BEAM);

#define FX_BOSS_DEATH "zombie/fx_ee_gateworm_lg_teleport_zod_zmb"
#precache("fx", FX_BOSS_DEATH);

#define FX_RITUAL_DEATH	"zombie/fx_ritual_sacrafice_death_zod_zmb"
#precache("fx", FX_RITUAL_DEATH);

#define FX_TELEPORTER "dlc0/factory/fx_teleporter_beam_factory"
#precache("fx", FX_TELEPORTER);

#define FX_FLAMETHROWER "dlc5/temple/fx_ztem_leak_flame_jet_runner"
#precache("fx", FX_FLAMETHROWER);

#define FX_FIRE "dlc3/stalingrad/fx_fire_smky"
#precache("fx", FX_FIRE);

#define FX_FIRE_LIGHT "light/fx_light_barrel_fire_factory_zmb_strong"
#precache("fx", FX_FIRE_LIGHT);

#define FX_MOLOTOV_BOTTLE	"dlc3/stalingrad/fx_fire_spot_xxsm"
#precache("fx", FX_MOLOTOV_BOTTLE);

#precache("model", M_RICHTOFEN);
#precache("model", M_DEMPSEY);
#precache("model", M_NIKOLAI);
#precache("model", M_TAKEO);
#precache("model", "c_rus_scientist_body");

#precache("model", "p7_fxanim_zm_zod_summoning_key_mod" );
#precache("model", "doom_cyberdemon");
#precache("model", "weapon_molotov_projectile");
#precache( "model", "weapon_molotov_world" );

REGISTER_SYSTEM_EX( "zm_cutscene", &init, &main, undefined )

function init()
{
	
}

function main()
{

}

function CutsceneInit( boss_origin, boss_angles )
{
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] EnableInvulnerability();
	}

	level flag::clear( "spawn_zombies" );
	//SetDvar("ai_DisableSpawn",1);
	// ClearZombies();
	wait(2);
	
	level.musicSystemOverride = 1;
	//music::setmusicstate("zod_ee_shadfight");
	
	key_spawn = struct::get("bossfight_key_spawn", "targetname");
	camera = struct::get("cutscene_camera_1", "targetname");
	
	if(!isdefined(camera) || !isdefined(key_spawn))
	{
		IPrintlnBold("Camera not found");
		return;
	}

	for(i = 0; i < players.size; i++)
	{
		players[i] notify("stop_player_out_of_playable_area_monitor");
		players[i] CutscenePlayerSetup();
		players[i] PlaySoundToPlayer( "mus_cutscene", players[i] );
	}

	// util::playSoundOnPlayers("mus_cutscene", undefined);

	level notify("cutscene_start");

	boss = util::spawn_model( "doom_cyberdemon", boss_origin );
	boss.angles = boss_angles;
	boss UseAnimTree(#animtree);
	key = util::spawn_model("p7_fxanim_zm_zod_summoning_key_mod", key_spawn.origin + (0, 0, 20));

	key.fx = Spawn("script_model", key.origin);
	key.fx SetModel("tag_origin");
	key.fx.angles = (0, 90, 0);
	PlayFXOnTag(FX_SUMMONING_KEY_BEAM, key.fx, "tag_origin");

	for(i = 0; i < players.size; i++)
	{
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
		players[i] CameraActivate( true );
	}

	wait(0.4);
	boss AnimScripted("note_notify", boss.origin, boss.angles, %cyber_cutscene_death);
	util::playSoundOnPlayers("vox_cyber_roar", undefined);
	wait(GetAnimLength(%cyber_cutscene_death));
	PlayFX(FX_BOSS_DEATH, boss.origin);
	boss Delete();
	scientist = util::spawn_model("c_rus_scientist_body", boss_origin + (0, 0, 125));
	scientist UseAnimTree( #animtree );
	scientist.angles = boss_angles;

	util::playSoundOnPlayers("vox_sm_pain_final", undefined);
	scientist AnimScripted("note_notify", scientist.origin, scientist.angles, %player_ritual_loop);
	wait(GetAnimLength(%player_ritual_loop));
	PlayFX(FX_RITUAL_DEATH, scientist.origin);
	PlaySoundAtPosition("cyber_death_explosion", scientist.origin);
	WAIT_SERVER_FRAME;
	scientist Delete();
	wait(4);

	if(isdefined(key.fx))
		key.fx Delete();

	//TODO: Add a key sound done here
	key_fx = util::spawn_model("tag_origin", key.origin);
	key_fx EnableLinkTo();
	key_fx LinkTo(key);
	PlayFXOnTag(level._effect["fx_rune_glow_purple"], key_fx, "tag_origin");
	key MoveZ(-20, 2);

	target = struct::get(camera.target, "targetname");
	if(isdefined(target))
	{
		for(i = 0; i < players.size; i++)
		{
			players[i] StartCameraTween(4);
			players[i] CameraSetPosition( target.origin );
			players[i] CameraSetAngles( target.angles );
		}
	} 

	wait(3);

	util::playSoundOnPlayers("vox_cutscene_1", undefined);

	wait(2);

	level thread CutSceneStateTwo();
}

function CutscenePlayerSetup()	//self = player
{
	self SetCharacterBodyType( 4 );

	//Disable hud
	self SetClientUIVisibilityFlag( "hud_visible", 0 );
	self SetClientUIVisibilityFlag( "weapon_hud_visible", 0 );
	if(isdefined(self.shovelHud))
	{
		self.shovelHud hud::destroyElem();
	}

	if(isdefined(self.afterhud))
	{
		self.afterhud hud::destroyElem();
	}

	if(isdefined(self.afterhudText))
	{
		self.afterhudText hud::destroyElem();
	}

	//Adding this just in case
	self EnableInvulnerability();
	self notify("stop_player_out_of_playable_area_monitor");

	//Disable weapons
	self TakeAllWeapons();
	WAIT_SERVER_FRAME;
	self DisableWeapons();
	self DisableOffhandWeapons();
	self AllowMelee(0);

	//Disable stances
	self SetStance("stand");
	self AllowJump(0);
	self AllowSlide(0);
	self AllowSprint(0);
	self AllowStand(1);
	self AllowCrouch(0);
	self AllowProne(0);
	self FreezeControls( true );
	self HideViewModel();

	self zm_project_e_challenges::ClearPerkHud();
	self zm_digsite::ClearShovelHud();
}

function CutSceneStateTwo()
{
	camera = struct::get( "cutscene_camera_2", "targetname" );
	dem_spawn = struct::get( "cutscene_2_dem", "targetname" );
	ric_spawn = struct::get( "cutscene_2_ric", "targetname" );

	dem = SpawnPlayerCloneAtPosition( M_DEMPSEY, dem_spawn.origin, dem_spawn.angles, %pb_cutscene_closecall );
	ric = SpawnPlayerCloneAtPosition( M_RICHTOFEN, ric_spawn.origin, ric_spawn.angles, %pb_cutscene_talk_hold );

	if(!isdefined(camera))
	{
		IPrintlnBold("Camera not found");
		return;
	}

	wait(.1);	// Small delay for game to load characters
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		//players[i] StartCameraTween(1);
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
	}
	
	wait(4);

	target = struct::get("cutscene_camera_2_target", "targetname");
	for(i = 0; i < players.size; i++)
	{
		players[i] StartCameraTween(2);
		players[i] CameraSetPosition( target.origin );
		players[i] CameraSetAngles( target.angles );
	}

	util::playSoundOnPlayers("vox_cutscene_2", undefined);
	wait(4.5);

	lui::screen_flash( 0.2, 1.0, 1.0, 0.8, "white" ); // flash

	for(i = 0; i < players.size; i++)
	{
		players[i] thread zm_teleporter_pe::PlayTeleporterFakeFx();
	}

	level thread CutSceneStateThree();

	wait(1);
	dem Delete();
	WAIT_SERVER_FRAME;
	ric Delete();
}

function CutSceneStateThree()
{
	camera = struct::get( "cutscene_camera_3", "targetname" );
	a_spots = struct::get_array("cutscene_giant_tele_pos", "targetname");

	if(!isdefined(camera))
	{
		IPrintlnBold("Camera not found");
		return;
	}

	dem_spawn = undefined;
	ric_spawn = undefined;
	nik_spawn = undefined;
	tak_spawn = undefined;

	for(i = 0; i < a_spots.size; i++)
	{
		if(i == DEMPSEY)
		{
			dem_spawn = a_spots[i];
		}

		if(i == RICHTOFEN)
		{
			ric_spawn = a_spots[i];
		}

		if(i == NIKOLAI)
		{
			nik_spawn = a_spots[i];
		}

		if(i == TAKEO)
		{
			tak_spawn = a_spots[i];
		}
	}

	tele_fx_spot = struct::get("cutscene_giant_tele_fx", "targetname");

	wait(.1);	// Small delay for game to load characters
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
	}

	wait(2);

	util::playSoundOnPlayers("teleporter_warmup");
	PlayFX(FX_TELEPORTER, tele_fx_spot.origin);
	
	wait(2);
	util::playSoundOnPlayers("teleporter_beam_fx");
	
	dem = SpawnPlayerCloneAtPosition( M_DEMPSEY, dem_spawn.origin, dem_spawn.angles, "pb_cutscene_talk_3" );
	ric = SpawnPlayerCloneAtPosition( M_RICHTOFEN, ric_spawn.origin, ric_spawn.angles, "pb_cutscene_stand_noweapon" );
	nik = SpawnPlayerCloneAtPosition( M_NIKOLAI, nik_spawn.origin, nik_spawn.angles, "pb_cutscene_stand" );
	tak = SpawnPlayerCloneAtPosition( M_TAKEO, tak_spawn.origin, tak_spawn.angles, "pb_cutscene_stand_ar" );

	wait(1);

	util::playSoundOnPlayers("vox_cutscene_3", undefined);
	wait(3);
	tak AnimScripted("note_notify", tak.origin, tak.angles, "pb_cutscene_talk_1");
	util::playSoundOnPlayers("vox_cutscene_4", undefined);
	wait(6);

	level thread CutSceneStateFour();

	wait(1);
	dem Delete();
	WAIT_SERVER_FRAME;
	ric Delete();
	WAIT_SERVER_FRAME;
	nik Delete();
	WAIT_SERVER_FRAME;
	tak Delete();
}

function CutSceneStateFour()
{
	camera = struct::get( "cutscene_camera_4", "targetname" );
	target = struct::get(camera.target, "targetname");
	a_spots = struct::get_array("cutscene_giant_ft_pos", "targetname");
	dem_spawn = undefined;
	ric_spawn = undefined;
	nik_spawn = undefined;
	tak_spawn = undefined;

	if(!isdefined(camera))
	{
		IPrintlnBold("Camera not found");
		return;
	}

	for(i = 0; i < a_spots.size; i++)
	{
		// Override position if this spot is reserved for richtofen
		if(isdefined(a_spots[i].script_int) && a_spots[i].script_int == RICHTOFEN)
		{
			ric_spawn = a_spots[i];
			continue;
		}

		if(i == DEMPSEY)
		{
			dem_spawn = a_spots[i];
		}

		if(i == NIKOLAI)
		{
			nik_spawn = a_spots[i];
		}

		if(i == TAKEO)
		{
			tak_spawn = a_spots[i];
		}
	}

	dem = SpawnPlayerCloneAtPosition( M_DEMPSEY, dem_spawn.origin, dem_spawn.angles, %pb_cutscene_stand );
	ric = SpawnPlayerCloneAtPosition( M_RICHTOFEN, ric_spawn.origin, ric_spawn.angles, %pb_cutscene_talk_hold );
	nik = SpawnPlayerCloneAtPosition( M_NIKOLAI, nik_spawn.origin, nik_spawn.angles, %pb_cutscene_stand_gloves );
	tak = SpawnPlayerCloneAtPosition( M_TAKEO, tak_spawn.origin, tak_spawn.angles, %pb_cutscene_stand_gloves );

	//dem.weapon = util::spawn_model("weapon_molotov_world", dem GetTagOrigin("tag_weapon_right"), dem.angles);
	//dem.weapon EnableLinkTo();
	//dem.weapon LinkTo(dem, "tag_weapon_right");
	//PlayFXOnTag( FX_MOLOTOV_BOTTLE, dem.weapon, "tag_fx" );

	ric.weapon = util::spawn_model("weapon_molotov_world", ric GetTagOrigin("j_thumb_ri_2"), ric.angles);
	ric.weapon EnableLinkTo();
	ric.weapon LinkTo(ric, "j_thumb_ri_2");
	PlayFXOnTag( FX_MOLOTOV_BOTTLE, ric.weapon, "tag_fx" );

	//nik.weapon = util::spawn_model("weapon_molotov_world", nik GetTagOrigin("tag_weapon_right"), nik.angles);
	//nik.weapon EnableLinkTo();
	//nik.weapon LinkTo(nik, "tag_weapon_right");
	//PlayFXOnTag( FX_MOLOTOV_BOTTLE, nik.weapon, "tag_fx" );

	//tak.weapon = util::spawn_model("weapon_molotov_world", tak GetTagOrigin("tag_weapon_right"), tak.angles);	//weapon_molotov_world
	//tak.weapon EnableLinkTo();
	//tak.weapon LinkTo(tak, "tag_weapon_right");
	//PlayFXOnTag( FX_MOLOTOV_BOTTLE, tak.weapon, "tag_fx" );

	wait(.1);	// Small delay for game to load characters
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
	}

	util::playSoundOnPlayers("vox_cutscene_bonus", undefined);

	wait(4);

	for(i = 0; i < players.size; i++)
	{
		players[i] StartCameraTween( 2 );
		players[i] CameraSetPosition( target.origin );
		players[i] CameraSetAngles( target.angles );
	}

	wait(1.5);

	dem thread CutsceneThrowMolotov();
	wait(2);
	ric thread CutsceneThrowMolotov();
	wait(0.5);
	nik thread CutsceneThrowMolotov();
	wait(1.5);
	tak thread CutsceneThrowMolotov();

	wait(5);

	level thread CutSceneStateFive();
	dem Delete();
	WAIT_SERVER_FRAME;
	ric Delete();
	WAIT_SERVER_FRAME;
	nik Delete();
	WAIT_SERVER_FRAME;
	tak Delete();
}

function CutsceneThrowMolotov()	//self = player
{
	animation = undefined;
	random = RandomInt(2);
	if( random == 0 )
	{
		animation = %pb_cutscene_throw;
	}

	else 
	{
		animation = %pb_cutscene_throw_2;
	}

	self AnimScripted( "note_notify", self.origin, self.angles, animation );
	wait( GetAnimLength(animation) );

	molotov = util::spawn_model("weapon_molotov_world", self GetTagOrigin("tag_weapon_right"), AnglesToForward(self.angles));
	if(!isdefined(molotov))
		return;

	WAIT_SERVER_FRAME;
	PlayFXOnTag(FX_MOLOTOV_BOTTLE, molotov, "tag_origin");
	
	if(isdefined(self.weapon))
		self.weapon Delete();

	angles = AnglesToForward( self.angles );

	molotov RotatePitch(50, 1);
	molotov Launch( (angles[0] * 500, angles[1] * 500, angles[2] * 500) );
	wait(0.8);

	PlaySoundAtPosition( "molotov_explode", molotov.origin );
	PlayFX( level._effect["fx_exp_molotov_lotus"], molotov.origin );
	WAIT_SERVER_FRAME;

	self AnimScripted("note_notify", self.origin, self.angles, GetRandomAnimation());

	molotov Delete();

}

function GetRandomAnimation()
{
	index = RandomInt(4);
	switch( index )
	{
		case 0:
		return %pb_cutscene_stand_gloves;

		case 1:
		return %pb_cutscene_stand;

		case 2:
		return %pb_cutscene_stand_noweapon;

		case 3:
		return %pb_cutscene_stand_ar;

		default:
		return %pb_cutscene_stand_pistol;

	}
}

function CutSceneStateFive()
{
	camera = struct::get( "cutscene_camera_5", "targetname" );
	a_fire = struct::get_array("cutscene_giant_fx_spot", "targetname");

	if(!isdefined(camera))
	{
		IPrintlnBold("Camera not found");
		return;
	}

	for(i = 0; i < a_fire.size; i++)
	{
		PlayFX(FX_FIRE ,a_fire[i].origin);
		PlayFX(FX_FIRE_LIGHT, a_fire[i].origin);
	}

	
	wait(.1);	// Small delay for game to load characters
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
		players[i] PlayLoopSound( "amb_fire_large" );
		//players[i].linkmodel MoveZ(60, 11);
	}

	wait(0.3);
	target = struct::get(camera.target, "targetname");

	for(i = 0; i < players.size; i++)
	{
		players[i] StartCameraTween(8);
		players[i] CameraSetPosition( target.origin );
		players[i] CameraSetAngles( target.angles );
		//players[i] PlayLoopSound("amb_fire_large");
		//players[i].linkmodel MoveZ(60, 11);
	}
	
	wait(9);
	players[i] StopLoopSound(1);
	level thread CutSceneStateSix();

}

function CutSceneStateSix()
{
	camera = struct::get( "cutscene_camera_6", "targetname" );
	target = struct::get( camera.target, "targetname" );
	a_spots = struct::get_array( "cutscene_giant_final_players", "targetname" );
	dem_spawn = undefined;
	ric_spawn = undefined;
	nik_spawn = undefined;
	tak_spawn = undefined;

	if(!isdefined(camera))
	{
		IPrintLnBold( "Camera not found" );
		return;
	}

	for(i = 0; i < a_spots.size; i++)
	{
		if(i == DEMPSEY)
		{
			dem_spawn = a_spots[i];
			continue;
		}

		if(i == RICHTOFEN)
		{
			ric_spawn = a_spots[i];
			continue;
		}

		if(i == NIKOLAI)
		{
			nik_spawn = a_spots[i];
			continue;
		}

		if(i == TAKEO)
		{
			tak_spawn = a_spots[i];
			continue;
		}
	}

	dem = SpawnPlayerCloneAtPosition( M_DEMPSEY, dem_spawn.origin, dem_spawn.angles, %pb_cutscene_stand_gloves );
	ric = SpawnPlayerCloneAtPosition( M_RICHTOFEN, ric_spawn.origin, ric_spawn.angles, %pb_cutscene_stand );
	nik = SpawnPlayerCloneAtPosition( M_NIKOLAI, nik_spawn.origin, nik_spawn.angles, %pb_cutscene_stand_noweapon );
	tak = SpawnPlayerCloneAtPosition( M_TAKEO, tak_spawn.origin, tak_spawn.angles, %pb_cutscene_stand_ar );

	wait(.2);	// Small delay for game to load characters
	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] CameraSetPosition( camera.origin );
		players[i] CameraSetAngles( camera.angles );
	}

	wait(1.5);
	util::playSoundOnPlayers("vox_cutscene_5", undefined);

	for(i = 0; i < players.size; i++)
	{
		players[i] StartCameraTween(30);
		players[i] CameraSetPosition( target.origin - (0, 20, 0) );
		players[i] CameraSetAngles( target.angles );
	}

	wait(2.5);
	util::playSoundOnPlayers("vox_cutscene_6", undefined);
	wait(4);
	util::playSoundOnPlayers("vox_cutscene_7", undefined);
	wait(3);
	util::playSoundOnPlayers("vox_cutscene_8", undefined);
	wait(4);
	util::playSoundOnPlayers("vox_cutscene_9", undefined);
	wait(9);
	util::playSoundOnPlayers("vox_cutscene_10", undefined);
	wait(6);
	util::playSoundOnPlayers("vox_cutscene_11", undefined);
	wait(5);

	for(i = 0; i < players.size; i++)
	{
		players[i] thread FadeToBlack();
	}

	wait(3);
	util::playSoundOnPlayers("vox_cutscene_12", undefined);

	dem util::delay(6, undefined, &zm_utility::self_delete);
	ric util::delay(6, undefined, &zm_utility::self_delete);
	nik util::delay(6, undefined, &zm_utility::self_delete);
	tak util::delay(6, undefined, &zm_utility::self_delete);

	wait(25);

	for(i = 0; i < players.size; i++)
	{
		players[i] StopSounds();
	}

	level notify("end_game");

}

function SetActiveCamera( struct, move_speed )	//move_speed = time in seconds where players move to target
{
	if(!isdefined(struct))
		return;

	if(!isdefined(move_speed))
	{
		move_speed = 1;
	}

	players = GetPlayers();
	for(i = 0; i < players.size; i++)
	{
		players[i] FreezeControls( true );
		WAIT_SERVER_FRAME;
		players[i] StartCameraTween(0.1);
		players[i] CameraSetPosition( struct.origin );
		players[i] CameraSetAngles( struct.angles );
		players[i] CameraActivate( true );

		target = struct::get( struct.target,"targetname" );
		if( isdefined(target) )
		{
			players[i] thread MoveToTarget( target, move_speed );
		}
	}
}

function MoveToTarget( target, move_speed )	//self = player
{
	self StartCameraTween( move_speed );
	self CameraSetPosition( target.origin );
	self CameraSetAngles( target.angles );
}

function SpawnPlayerCloneAtPosition( model, position, angles, animation )
{
	//corpse = zm_clone::spawn_player_clone( self, self.origin, getWeapon( "pistol_standard" ), self GetCharacterBodyModel() );
	model = util::spawn_model(model, position);
	model.angles = angles;
	model UseAnimTree( #animtree );
	model AnimScripted( "note_notify", model.origin, model.angles, animation );
	return model;
}

function FadeToBlack()
{
	self endon("intermission");
	time = 6;
	//wait(5);
	fadeToWhite = NewClientHudElem( self );
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
	wait(2);

	text = NewClientHudElem( self ); 
	text.alignX = "center"; 
	text.alignY = "middle"; 
	text.horzAlign = "center"; 
	text.vertAlign = "bottom"; 
	text.foreground = true; 
	text.font = "default"; 
	text.fontScale = 4; 
	text.alpha = 0; 
	text.color = ( 1.0, 1.0, 1.0 ); 
	text SetText( "The End" );
	text.y = -230;

	text FadeOverTime( 1 ); 
	text.alpha = 1;

	wait(time);

	text FadeOverTime( 1 ); 
	text.alpha = 0;

	wait(3);

	text FadeOverTime( 1 ); 
	text.alpha = 1;

	text SetText( "Project Elemental" );

	wait(4);

	text FadeOverTime( 1 ); 
	text.alpha = 0;

	wait(8);
	
	fadeToWhite FadeOverTime( 1 );
	fadeToWhite.alpha = 0;

	wait(1);
	fadeToWhite Destroy();
	text Destroy();
}

function ClearZombies()
{
	zombies = GetAITeamArray("axis");
	for(i = 0; i < zombies.size; i++)
	{
		if(IS_TRUE(zombies[i].is_boss))
			zombies[i].allowDeath = true;
			
		WAIT_SERVER_FRAME;
		zombies[i] DoDamage(zombies[i].health + 666, zombies[i].origin);
	}
}