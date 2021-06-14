CoD.Zombie.CommonHudRequire()
CoD.CustomPerkIcons = InheritFrom(LUI.UIElement)

function CoD.CustomPerkIcons.return_array()
    local array =
	{
		quick_revive 						= "i_t6_specialty_quickrevive",
		doubletap2 							= "i_t6_specialty_doubletap2",
		juggernaut 							= "i_t6_specialty_armorvest",
		sleight_of_hand 					= "i_t6_specialty_fastreload",
		dead_shot 							= "i_t6_specialty_deadshot",
		phdflopper 							= "i_t6_specialty_phdflopper",
		marathon 							= "i_t6_specialty_staminup",
		additional_primary_weapon 	= "i_t6_specialty_additionalprimaryweapon",
		tombstone 							= "i_t6_specialty_tombstone",
		whoswho 								= "i_t6_specialty_whoswho",
		electric_cherry 						= "i_t6_specialty_electriccherry",
       		vultureaid 								= "i_t6_specialty_vultureaid",
		widows_wine 						= "i_t6_specialty_widowswine",
		timewarp						= "i_t6_specialty_timewarp"
	}
	return array
end