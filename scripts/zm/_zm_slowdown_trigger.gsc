#using scripts\codescripts\struct;
#using scripts\shared\trigger_shared;
#using scripts\zm\zm_afterlife_pe;

#insert scripts\shared\shared.gsh;

function autoexec init()
{
	//Trigger has to be a trigger_multiple
	triggers = GetEntArray("slowdown_trigger", "targetname");

	stock_slowdown_speed = 0.6; 			//The stock speed that will be set when player is in the trigger
	slowdowntime = 1.0;						//The time that player slowsdown till he reached the slowndown speed
	speeduptime = 0.25;						//The time that player speeds up till he reached the speedup speed

	foreach(trigger in triggers)
	{
		if( !isdefined( trigger.script_float ) )
		{
			//set default value if nothing is set
			trigger.script_float = stock_slowdown_speed;
		}

		trigger.slowdown_time = slowdowntime;
		trigger.slowdown_rate = trigger.script_float / trigger.slowdown_time;
		trigger.speedup_time = speeduptime;
		trigger.speedup_rate = trigger.script_float / trigger.speedup_time;

		trigger thread slowdown_trigger();
	}
	
}


function slowdown_trigger()
{
	while(1)
	{
		self waittill ("trigger", player);
		//NEED THIS LINE: #using scripts\shared\trigger_shared;
		self thread trigger::function_thread( player, &trigger_slow_enter, &trigger_slow_exit );
	}
}

function trigger_slow_enter( player, endon_string )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	player endon("fake_death");
	player endon( endon_string );

	if ( isdefined( player ) && !IS_TRUE(player.in_afterlife) && !IS_TRUE( player.mud_resistant ) )
	{
		prev_time = GetTime();
		player AllowSlide(false);

		if( !isdefined( player.cur_move_speed ) )
		{
			if(isdefined(player.default_move_speed))
				player.cur_move_speed = player.default_move_speed;
		}
		
		while( player.cur_move_speed > self.script_float )
		{
			WAIT_SERVER_FRAME;
			cur_time = GetTime() - prev_time;
			player.cur_move_speed -= ( cur_time / 1000 ) * self.slowdown_rate;
			prev_time = GetTime();
			player SetMoveSpeedScale( player.cur_move_speed );
		}

		player.cur_move_speed = self.script_float;
		player SetMoveSpeedScale( player.cur_move_speed );
		// player AllowSprint(false);	//TODO: Change this if too op
		player AllowJump(false);
		player AllowProne(false);
	}
}

function trigger_slow_exit( player )
{
	player endon ( "death" );
	player endon ( "disconnect" );
	
	if ( isdefined( player ) )
	{
		prev_time = GetTime();

		if(isdefined(player.default_move_speed))
			movespeed = player.default_move_speed;
		
		else
		{
			movespeed = 1.0;
			player.default_move_speed = movespeed;
		}
			
		
		while( player.cur_move_speed < movespeed )
		{
			WAIT_SERVER_FRAME;
			cur_time = GetTime() - prev_time;
			player.cur_move_speed += ( cur_time / 1000 ) * self.speedup_rate;
			prev_time = GetTime();
			player SetMoveSpeedScale( player.cur_move_speed );
		}
		
		player.cur_move_speed = movespeed;
		player SetMoveSpeedScale( player.default_move_speed );
		player AllowJump(true);
		player AllowSprint(true);
		player AllowProne(true);
		player AllowSlide(true);	
	}
}