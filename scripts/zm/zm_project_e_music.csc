#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\music_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;
#using scripts\zm\zm_project_e_amb;
#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#namespace zm_project_e_music;

REGISTER_SYSTEM("zm_project_e_music", &__init__, undefined )

function __init__()
{
        clientfield::register( "allplayers",    "cancel_ambient_music",          VERSION_SHIP, 1, "int", &cancel_ambient_music,       !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function cancel_ambient_music( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump ) // self == model
{
	if(newVal == 1)
	{
		for(i = 0; i < GetLocalPlayers().size; i++)
		{
			zm_project_e_amb::cancel_underscore();
		}

	}

	else
	{
		zm_project_e_amb::reenable_underscore();
	}
	
}

function function_51d7bc7c(var_6d9d81aa)
{
	level endon("hash_51d7bc7c");
	level.var_eb526c90 StopAllLoopSounds(2);
	wait(1);
	level.var_9433cf5a = level.var_eb526c90 PlayLoopSound(var_6d9d81aa, 2);
}

