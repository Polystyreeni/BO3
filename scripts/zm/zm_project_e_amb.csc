#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\music_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;

#namespace zm_project_e_amb;


function main()
{
	level thread function_bab3ea62();
}


function function_bab3ea62()
{
	level thread function_53b9afad();
	level thread cancel_music();
	level thread reenable_music();
	var_29085ef = GetEntArray(0, "sndMusicTrig", "targetname");
	Array::thread_all(var_29085ef, &function_95d61fc1);
}

function function_95d61fc1()
{
	level endon("cancel_underscore");
	level endon("pe_cancel_music");
	while(1)
	{
		self waittill("trigger", trigPlayer);
		if(trigPlayer isLocalPlayer())
		{
			level notify("hash_51d7bc7c", self.script_sound);
			//IPrintlnBold("User entered area: " + self.script_sound);
			while(isdefined(trigPlayer) && trigPlayer istouching(self))
			{
				wait(0.016);
			}
		}
		else
		{
			wait(0.016);
		}
	}
}

function cancel_music()
{
	while(true)
	{
		level waittill("pe_cancel_music");
		//IPrintlnBold("Canceled Music");

		if(isdefined(level.var_eb526c90))
		{
			level.var_eb526c90 StopAllLoopSounds(1);
			wait(1);
			level.var_eb526c90 Delete();
		}
	}
}

function reenable_music()
{
	music_disabled = true;
	while(music_disabled)
	{
		level waittill("pe_activate_music");
		music_disabled = false;
		//IPrintlnBold("Activate Music");
		function_bab3ea62();
	}
}

function function_53b9afad()
{
	var_b6342abd = "mus_zod_underscore_default";
	var_6d9d81aa = "mus_zod_underscore_default";
	if(!isdefined(level.var_eb526c90))
	{
		level.var_eb526c90 = spawn(0, (0, 0, 0), "script_origin");
	}
	
	level.var_9433cf5a = level.var_eb526c90 PlayLoopSound(var_b6342abd, 2);
	while(1)
	{
		level waittill("hash_51d7bc7c", location);
		var_6d9d81aa = "mus_zod_underscore_" + location;
		if(var_6d9d81aa != var_b6342abd)
		{
			level thread function_51d7bc7c(var_6d9d81aa);
			var_b6342abd = var_6d9d81aa;
		}
	}
}

function function_51d7bc7c(var_6d9d81aa)
{
	level endon("hash_51d7bc7c");
	level endon("pe_cancel_music");

	level.var_eb526c90 StopAllLoopSounds(2);
	wait(1);
	level.var_9433cf5a = level.var_eb526c90 PlayLoopSound(var_6d9d81aa, 2);
}

function cancel_underscore()
{
	level notify("cancel_underscore");

	//IPrintlnBold("Canceled Music");

	if(isdefined(level.var_eb526c90))
	{
		level.var_eb526c90 StopAllLoopSounds(1);
		wait(1);
		level.var_eb526c90 Delete();
	}
	
}

function reenable_underscore()
{
	level thread function_bab3ea62();
}

