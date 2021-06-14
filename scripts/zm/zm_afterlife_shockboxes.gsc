/*==========================================
Afterlife script by ihmiskeho
V1.0
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
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\ik\zm_generators;
#using scripts\ik\zm_digsite;
#using scripts\zm\zm_afterlife_pe;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\shared\version.gsh;

#using_animtree( "shockbox" );

#precache("xanim", "zod_powerbox_start");
#precache("xanim", "zod_powerbox_loop");

#namespace zm_afterlife_shockboxes;

REGISTER_SYSTEM_EX( "zm_afterlife_shockboxes", &init, &__main__, undefined )

function init()
{

}

function __main__()
{

}

function WatchForShock()	//self = model
{
	self SetCanDamage( true );
	self.activated = false;
	while(1)
	{
		self waittill( "damage", n_damage, e_attacker, v_direction, v_point, str_means_of_death, str_tag_name, str_model_name, str_part_name, w_weapon );
		if(IS_TRUE(e_attacker.in_afterlife) && IsPlayer(e_attacker))			//Change afterlife weapon to a public variable
		{
		//	IPrintLnBold("Shocked");
			if(isdefined(self.waypoint))
			{
				self.waypoint hud::destroyElem();
			}

			self notify("shockbox_triggered");
			
			self.activated = true;
			self PlaySound("afterlife_powered");
			self SetModel("p7_zm_zod_power_box_yellow_emissive");
			self UseAnimTree( #animtree );
			self AnimScripted("zod_powerbox_start", self.origin, self.angles, "zod_powerbox_start");

			wait(GetAnimLength("zod_powerbox_start"));
			self AnimScripted("zod_powerbox_loop", self.origin, self.angles, "zod_powerbox_loop");			

			power_zone = undefined;
			if(isdefined(self.script_int))
			{
				power_zone = self.script_int;
				level thread zm_perks::perk_unpause_all_perks( power_zone );
				level zm_power::turn_power_on_and_open_doors( power_zone );
				vending_triggers = GetEntArray("zombie_vending", "targetname");
				foreach(trigger in vending_triggers)
				{
					powered_on = zm_perks::get_perk_machine_start_state(trigger.script_noteworthy);
					powered_perk = zm_power::add_powered_item( &zm_power::perk_power_on, &zm_power::perk_power_off, &zm_power::perk_range, &zm_power::cost_low_if_local, ANY_POWER, powered_on, trigger );
					if(isdefined(trigger.script_int))
					{
						powered_perk thread zm_power::zone_controlled_perk(trigger.script_int);
					}
					if(isdefined(trigger.script_noteworthy))
					{
						level notify(trigger.script_noteworthy +"_on");
						//IPrintLnBold("Perk on:" +trigger.script_noteworthy);
					}
				}

			}

			break;
		}
	}
}