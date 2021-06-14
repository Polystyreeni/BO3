-- The Giant Hud Base, Rebuilt from the ground up by the D3V Team

-- require("ui.uieditor.widgets.HUD.ZM_Perks.ZMPerksContainerFactory") --This was the stock perk container thing
require("ui.uieditor.widgets.HUD.ZM_RoundWidget.ZmRndContainer")
require("ui.uieditor.widgets.HUD.ZM_AmmoWidgetFactory.ZmAmmoContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_Score.ZMScr")
require("ui.uieditor.widgets.DynamicContainerWidget")
require("ui.uieditor.widgets.Notifications.Notification")
require("ui.uieditor.widgets.HUD.ZM_NotifFactory.ZmNotifBGB_ContainerFactory")
require("ui.uieditor.widgets.HUD.ZM_CursorHint.ZMCursorHint")
require("ui.uieditor.widgets.HUD.CenterConsole.CenterConsole")
require("ui.uieditor.widgets.HUD.DeadSpectate.DeadSpectate")
require("ui.uieditor.widgets.MPHudWidgets.ScorePopup.MPScr")
require("ui.uieditor.widgets.HUD.ZM_PrematchCountdown.ZM_PrematchCountdown")
require("ui.uieditor.widgets.Scoreboard.CP.ScoreboardWidgetCP")
require("ui.uieditor.widgets.HUD.ZM_TimeBar.ZM_BeastmodeTimeBarWidget")
require("ui.uieditor.widgets.ZMInventory.RocketShieldBluePrint.RocketShieldBlueprintWidget")
require("ui.uieditor.widgets.Chat.inGame.IngameChatClientContainer")
require("ui.uieditor.widgets.BubbleGumBuffs.BubbleGumPackInGame")
require("ui.zns.zns_inventory")

CoD.Zombie.CommonHudRequire()

local function PreLoadCallback(HudRef, InstanceRef)
    CoD.Zombie.CommonPreLoadHud(HudRef, InstanceRef)
end

local function PostLoadCallback(HudRef, InstanceRef)
    CoD.Zombie.CommonPostLoadHud(HudRef, InstanceRef)
end

function LUI.createMenu.T7Hud_zm_factory(InstanceRef)
    local HudRef = CoD.Menu.NewForUIEditor("T7Hud_zm_factory")
    
    if PreLoadCallback then
        PreLoadCallback(HudRef, InstanceRef)
    end

      -- Make sure that the list was not already setup, we must include the stock perks as well!
      if not CoD.ZMPerksFactory then
        -- Add our perks (hudItems.perks.key = imageName) (sync with csc clientuimodel)
        CoD.ZMPerksFactory =
        {
		quick_revive 					= "i_t6_specialty_quickrevive",
		doubletap2 						= "i_t6_specialty_doubletap2",
		juggernaut 						= "i_t6_specialty_armorvest",
		sleight_of_hand 				= "i_t6_specialty_fastreload",
		dead_shot 						= "i_t6_specialty_deadshot",
		phdflopper 						= "i_t6_specialty_phdflopper",
		marathon 						= "i_t6_specialty_staminup",
		additional_primary_weapon 		= "i_t6_specialty_additionalprimaryweapon",
		tombstone 						= "i_t6_specialty_tombstone",
		whoswho 						= "i_t6_specialty_whoswho",
		electric_cherry 				= "i_t6_specialty_electriccherry",
       	vultureaid 					    = "i_t6_specialty_vultureaid",
		widows_wine 					= "i_t6_specialty_widowswine",
		timewarp						= "i_t6_specialty_timewarp"
		
        }
    end
    
    -- Include the new perk container, and resume normal widget usage!
    require("ui.uieditor.widgets.hud.customperksfactory")
    
    HudRef.soundSet = "HUD"
    HudRef:setOwner(InstanceRef)
    HudRef:setLeftRight(true, true, 0, 0)
    HudRef:setTopBottom(true, true, 0, 0)
    HudRef:playSound("menu_open", InstanceRef)
    
    HudRef.buttonModel = Engine.CreateModel(Engine.GetModelForController(InstanceRef), "T7Hud_zm_factory.buttonPrompts")
    HudRef.anyChildUsesUpdateState = true
    
    local PerksWidget = CoD.ZMPerksContainerFactory.new(HudRef, InstanceRef)
    PerksWidget:setLeftRight(true, false, 130.000000, 281.000000)
    PerksWidget:setTopBottom(false, true, -62.000000, -26.000000)
    
    HudRef:addElement(PerksWidget)
    HudRef.ZMPerksContainerFactory = PerksWidget
    
    local RoundCounter = CoD.ZmRndContainer.new(HudRef, InstanceRef)
    RoundCounter:setLeftRight(true, false, -32.000000, 192.000000)      -- AnchorLeft, AnchorRight, Left, Right
    RoundCounter:setTopBottom(false, true, -174.000000, 18.000000)   -- AnchorTop, AnchorBottom, Top, Bottom
    RoundCounter:setScale(0.8)  -- Scale (Of 1.0)
    
    HudRef:addElement(RoundCounter)
    HudRef.Rounds = RoundCounter

	local Inventory = CoD.ZMIslandInventory.new(HudRef, InstanceRef)
	Inventory:setLeftRight(true, true, 0, 0)
    Inventory:setTopBottom(true, true, 0, 0)
	HudRef:addElement(Inventory)

    --Shovel Hud (Moved to lua in V2)
    --clientfield: shovel_pickup (Values 0, 1 (normal), 2 (Gold))

	local ShovelHud = LUI.UIImage.new(HudRef, InstanceRef)
	ShovelHud:setLeftRight(false, true, -116, -77)
	ShovelHud:setTopBottom(false, true, -223, -179)
    local null_image = RegisterImage("blacktransparent")
    local main_image = RegisterImage("shovel_hud_c")
    local gold_image = RegisterImage("shovel_hud_gold_c")
	ShovelHud:setImage(null_image)

    local ShowShovelHud = Engine.CreateModel( Engine.GetModelForController(InstanceRef), "shovel_pickup" )
    Engine.SetModelValue( ShowShovelHud, 0 )
    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) or not Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) then
            ShovelHud:setAlpha(0)
        else
            ShovelHud:setAlpha(1)  
        end
    end

    ShovelHud:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})

    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(ShovelHud, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function ImageScoreBoardClientField(ModelRef)
        local rState = Engine.GetModelValue(ModelRef)

        if rState == 1 then
            ShovelHud:setImage(main_image)
            HudRef:updateElementState(ShovelHud, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "shovel_pickup"})
        elseif rState == 2 then
            ShovelHud:setImage(gold_image)
            HudRef:updateElementState(ShovelHud, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "shovel_pickup"})
        elseif rState == 3 then
            ShovelHud:setImage(gold_image)
            HudRef:updateElementState(ShovelHud, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "shovel_pickup"})
        else
            ShovelHud:setImage(null_image)
            HudRef:updateElementState(ShovelHud, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "shovel_pickup"})
        end
    end
	
    ShovelHud:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)
    ShovelHud:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "shovel_pickup"), ImageScoreBoardClientField)

    HudRef:addElement(ShovelHud)

    local SpecialPerksStamina = LUI.UIImage.new(HudRef, InstanceRef)
    SpecialPerksStamina:setLeftRight(true, false, 129, 164)
    SpecialPerksStamina:setTopBottom(false, true, -100, -65)

    local SpecialPerksRevive = LUI.UIImage.new(HudRef, InstanceRef)
    SpecialPerksRevive:setLeftRight(true, false, 169, 204)
    SpecialPerksRevive:setTopBottom(false, true, -100, -65)

    local null_image = RegisterImage("blacktransparent")
    local stamin_image = RegisterImage("i_t6_specialty_staminup_special")
    local revive_image = RegisterImage("i_t6_specialty_mudresistance")

    SpecialPerksStamina:setImage(null_image)
    SpecialPerksRevive:setImage(null_image)

    local ShowPerks = Engine.CreateModel( Engine.GetModelForController(InstanceRef), "specialty_perk_obtained" )
    Engine.SetModelValue( ShowPerks, 0 )
    local function PerkScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) or not Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) then
            SpecialPerksStamina:setAlpha(0)
            SpecialPerksRevive:setAlpha(0)
        else
            SpecialPerksStamina:setAlpha(1)
            SpecialPerksRevive:setAlpha(1)
        end
    end

    SpecialPerksStamina:mergeStateConditions({{stateName = "Scoreboard", condition = PerkScoreBoardCallback}})
    SpecialPerksRevive:mergeStateConditions({{stateName = "Scoreboard", condition = PerkScoreBoardCallback}})

    local function InventoryOpen(ModelRef)
        HudRef:updateElementState(SpecialPerksStamina, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})

        HudRef:updateElementState(SpecialPerksRevive, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function PerkScoreBoardClientField(ModelRef)
        local rState = Engine.GetModelValue(ModelRef)

        if rState == 1 then
            SpecialPerksStamina:setImage(stamin_image)
            HudRef:updateElementState(SpecialPerksStamina, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "specialty_perk_obtained"})
        elseif rState == 2 then
            SpecialPerksRevive:setImage(revive_image)
            HudRef:updateElementState(SpecialPerksRevive, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "specialty_perk_obtained"})
        else
            SpecialPerksStamina:setImage(null_image)
            SpecialPerksRevive:setImage(null_image)
            HudRef:updateElementState(SpecialPerksStamina, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "specialty_perk_obtained"})
            HudRef:updateElementState(SpecialPerksRevive, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = "specialty_perk_obtained"})
        end
    end
    
    SpecialPerksStamina:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), InventoryOpen)
    SpecialPerksStamina:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "specialty_perk_obtained"), PerkScoreBoardClientField)

    SpecialPerksRevive:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), InventoryOpen)
    SpecialPerksRevive:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "specialty_perk_obtained"), PerkScoreBoardClientField)

    HudRef:addElement(SpecialPerksStamina)
    HudRef:addElement(SpecialPerksRevive)


	-- AFTERLIFE TEST

--	local AfterLifeBarImage = LUI.UIImage.new()
--    AfterLifeBarImage:setLeftRight(false, false, -64, 64)
--    AfterLifeBarImage:setTopBottom(false, true, 0, -64)

--    AfterLifeBarImage:setAlpha(0.80)
--    AfterLifeBarImage:setImage(RegisterImage("afterlife_on"))
    
--    AfterLifeBarImage:setMaterial(RegisterMaterial("uie_wipe"))
    
--    AfterLifeBarImage:setShaderVector(1, 0.5, 0, 0, 0)
--    AfterLifeBarImage:setShaderVector(2, 0.5, 0, 0, 0)
--    AfterLifeBarImage:setShaderVector(3, 0.5, 0, 0, 0)
    
--    HudRef:addElement(AfterLifeBarImage)
--    HudRef.AfterLifeBar = AfterLifeBarImage
      
--    AfterLifeBarImage:subscribeToGlobalModel(InstanceRef, "PerController", "zmhud.afterlifeMana", function(ModelRef)
--    local modelValue = Engine.GetModelValue(ModelRef) -- should be percentage
--      if modelValue then
--          local shaderW = Cod.GetVectorComponentFromString(modelValue, 1)
--          local shaderX = Cod.GetVectorComponentFromString(modelValue, 2)
--          local shaderY = Cod.GetVectorComponentFromString(modelValue, 3)
--            local shaderZ = Cod.GetVectorComponentFromString(modelValue, 4)
          
--          AfterLifeBarImage:setShaderVector(0, AdjustStartEnd(0, 1, shaderW, shaderX, shaderY, shaderZ))
--      end
--    end


    local AmmoWidget = CoD.ZmAmmoContainerFactory.new(HudRef, InstanceRef)
    AmmoWidget:setLeftRight(false, true, -427.000000, 3.000000)
    AmmoWidget:setTopBottom(false, true, -232.000000, 0.000000)
    
    HudRef:addElement(AmmoWidget)
    HudRef.Ammo = AmmoWidget
    
    local ScoreWidget = CoD.ZMScr.new(HudRef, InstanceRef)
    ScoreWidget:setLeftRight(true, false, 30.000000, 164.000000)
    ScoreWidget:setTopBottom(false, true, -256.000000, -128.000000)
    ScoreWidget:setYRot(30.000000)
    
    local function HudStartScore(Unk1, Unk2, Unk3)
        if IsModelValueTrue(InstanceRef, "hudItems.playerSpawned") and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_GAME_ENDED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_KILLCAM) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_SCOPED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_VEHICLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_EMP_ACTIVE) then
            return true
        else
            return false
        end
    end
    
    ScoreWidget:mergeStateConditions({{stateName = "HudStart", condition = HudStartScore}})
    
    local function PlayerSpawnCallback(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "hudItems.playerSpawned"})
    end
    
    local function MergeBitVisible(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE})
    end
    
    local function MergeBitWeapon(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE})
    end
    
    local function MergeBitHardcore(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_HARDCORE})
    end
    
    local function MergeBitEndGame(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED})
    end
    
    local function MergeBitDemoMovie(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM})
    end
    
    local function MergeBitDemoHidden(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN})
    end
    
    local function MergeBitInKillcam(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM})
    end
    
    local function MergeBitFlash(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED})
    end
    
    local function MergeBitActive(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE})
    end
    
    local function MergeBitScoped(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED})
    end
    
    local function MergeBitVehicle(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE})
    end
    
    local function MergeBitMissile(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE})
    end
    
    local function MergeBitBoardOpen(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end
    
    local function MergeBitStaticKill(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC})
    end
    
    local function MergeBitEmpActive(ModelRef)
        HudRef:updateElementState(ScoreWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE})
    end
    
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "hudItems.playerSpawned"), PlayerSpawnCallback)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE), MergeBitVisible)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_WEAPON_HUD_VISIBLE), MergeBitWeapon)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_HARDCORE), MergeBitHardcore)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_GAME_ENDED), MergeBitEndGame)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_CAMERA_MODE_MOVIECAM), MergeBitDemoMovie)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_DEMO_ALL_GAME_HUD_HIDDEN), MergeBitDemoHidden)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_KILLCAM), MergeBitInKillcam)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED), MergeBitFlash)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE), MergeBitActive)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_SCOPED), MergeBitScoped)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_VEHICLE), MergeBitVehicle)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE), MergeBitMissile)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MergeBitBoardOpen)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_REMOTE_KILLSTREAK_STATIC), MergeBitStaticKill)
    ScoreWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_EMP_ACTIVE), MergeBitEmpActive)
    
    HudRef:addElement(ScoreWidget)
    HudRef.Score = ScoreWidget
    
    local DynaWidget = CoD.DynamicContainerWidget.new(HudRef, InstanceRef)
    DynaWidget:setLeftRight(false, false, -640.000000, 640.000000)
    DynaWidget:setTopBottom(false, false, -360.000000, 360.000000)
    
    HudRef:addElement(DynaWidget)
    HudRef.fullscreenContainer = DynaWidget
    
    local NotificationWidget = CoD.Notification.new(HudRef, InstanceRef)
    NotificationWidget:setLeftRight(true, true, 0.000000, 0.000000)
    NotificationWidget:setTopBottom(true, true, 0.000000, 0.000000)
    
    HudRef:addElement(NotificationWidget)
    HudRef.Notifications = NotificationWidget
    
    local GumWidget = CoD.ZmNotifBGB_ContainerFactory.new(HudRef, InstanceRef)
    GumWidget:setLeftRight(false, false, -156.000000, 156.000000)
    GumWidget:setTopBottom(true, false, -6.000000, 247.000000)
    GumWidget:setScale(0.750000)
    
    local function GumCallback(ModelRef)
        if IsParamModelEqualToString(ModelRef, "zombie_bgb_token_notification") then
            AddZombieBGBTokenNotification(HudRef, GumWidget, InstanceRef, ModelRef) -- Add a popup for a 'free hit'
        elseif IsParamModelEqualToString(ModelRef, "zombie_bgb_notification") then
            AddZombieBGBNotification(HudRef, GumWidget, ModelRef) -- Add a popup for the gum you got
        elseif IsParamModelEqualToString(ModelRef, "zombie_notification") then
            AddZombieNotification(HudRef, GumWidget, ModelRef) -- Add a popup for a powerup
        end
    end
    
    GumWidget:subscribeToGlobalModel(InstanceRef, "PerController", "scriptNotify", GumCallback)
    
    HudRef:addElement(GumWidget)
    HudRef.ZmNotifBGBContainerFactory = GumWidget
    
    local HintWidget = CoD.ZMCursorHint.new(HudRef, InstanceRef)
    HintWidget:setLeftRight(false, false, -250.000000, 250.000000)
    HintWidget:setTopBottom(true, false, 522.000000, 616.000000)
    
    local function ActiveState1x1(Unk1, Unk2, Unk3)
        if IsCursorHintActive(InstanceRef) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE) then
            return (Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(InstanceRef), "cursorHintIconRatio")) == 1.0)
        else
            return false
        end
    end
    
    local function ActiveState2x1(Unk1, Unk2, Unk3)
        if IsCursorHintActive(InstanceRef) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE) then
            return (Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(InstanceRef), "cursorHintIconRatio")) == 2.0)
        else
            return false
        end
    end
    
    local function ActiveState4x1(Unk1, Unk2, Unk3)
        if IsCursorHintActive(InstanceRef) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE) then
            return (Engine.GetModelValue(Engine.GetModel(DataSources.HUDItems.getModel(InstanceRef), "cursorHintIconRatio")) == 4.0)
        else
            return false
        end
    end
    
    local function ActiveStateNoImg(Unk1, Unk2, Unk3)
        if IsCursorHintActive(InstanceRef) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_HARDCORE) and
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_HUD_VISIBLE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT) and not
        Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_UI_ACTIVE) then
            return IsModelValueEqualTo(InstanceRef, "hudItems.cursorHintIconRatio", 0.0)
        else
            return false
        end
    end

    local ScoreBoardMapName = LUI.UIText.new(HudRef, InstanceRef)
    ScoreBoardMapName:setLeftRight(true, false, 245, 580)
    ScoreBoardMapName:setTopBottom(true, false, 265, 285)
    ScoreBoardMapName:setText("PROJECT ELEMENTAL")

    local function ShowMapName(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            --ScoreBoardMapName:beginAnimation("keyframe", 500, true, true, CoD.TweenType.Linear)
            ScoreBoardMapName:setAlpha(1)
        else
            --ScoreBoardMapName:beginAnimation("keyframe", 500, true, true, CoD.TweenType.Linear)
            ScoreBoardMapName:setAlpha(0)
        end
    end

    ScoreBoardMapName:mergeStateConditions({{stateName = "Scoreboard", condition = ShowMapName}})

    local function OpenMapName(ModelRef)
        HudRef:updateElementState(ScoreBoardMapName, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    ScoreBoardMapName:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), OpenMapName)

    HudRef:addElement(ScoreBoardMapName)


    
    HintWidget:mergeStateConditions({
        {stateName = "Active_1x1", condition = ActiveState1x1},
        {stateName = "Active_2x1", condition = ActiveState2x1},
        {stateName = "Active_4x1", condition = ActiveState4x1},
        {stateName = "Active_NoImage", condition = ActiveStateNoImg}
    })
    
    local CursorController = Engine.GetModel(Engine.GetModelForController(InstanceRef), "hudItems.showCursorHint")
    
    local function ShowCallback(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "hudItems.showCursorHint"})
    end
    
    HintWidget:subscribeToModel(CursorController, ShowCallback)
    
    local function CursorBitHardcore(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_HARDCORE})
    end    

    local function CursorBitVisible(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE})
    end
    
    local function CursorBitMissile(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE})
    end
    
    local function CursorBitDemo(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING})
    end
    
    local function CursorBitFlash(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED})
    end
    
    local function CursorBitMap(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK})
    end
    
    local function CursorBitSpectating(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT})
    end
    
    local function CursorBitActive(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE})
    end
    
    local function CursorRatioChange(ModelRef)
        HudRef:updateElementState(HintWidget, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "hudItems.cursorHintIconRatio"})
    end
    
    -- This widget reacts to these controller changes
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_HARDCORE), CursorBitHardcore)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_HUD_VISIBLE), CursorBitVisible)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IN_GUIDED_MISSILE), CursorBitMissile)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_DEMO_PLAYING), CursorBitDemo)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_IS_FLASH_BANGED), CursorBitFlash)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SELECTING_LOCATIONAL_KILLSTREAK), CursorBitMap)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SPECTATING_CLIENT), CursorBitSpectating)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_UI_ACTIVE), CursorBitActive)
    HintWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "hudItems.cursorHintIconRatio"), CursorRatioChange)
    
    HudRef:addElement(HintWidget)
    HudRef.CursorHint = HintWidget
    
    local CenterCon = CoD.CenterConsole.new(HudRef, InstanceRef)
    CenterCon:setLeftRight(false, false, -370.000000, 370.000000)
    CenterCon:setTopBottom(true, false, 68.500000, 166.500000)
    
    HudRef:addElement(CenterCon)
    HudRef.ConsoleCenter = CenterCon
    
    local DeadOverlay = CoD.DeadSpectate.new(HudRef, InstanceRef)
    DeadOverlay:setLeftRight(false, false, -150.000000, 150.000000)
    DeadOverlay:setTopBottom(false, true, -180.000000, -120.000000)
    
    HudRef:addElement(DeadOverlay)
    HudRef.DeadSpectate = DeadOverlay
    
    local ScoreBd = CoD.MPScr.new(HudRef, InstanceRef)
    ScoreBd:setLeftRight(false, false, -50.000000, 50.000000)
    ScoreBd:setTopBottom(true, false, 233.500000, 258.500000)
    
    local function MpCallback(ModelRef)
        if IsParamModelEqualToString(ModelRef, "score_event") then
            PlayClipOnElement(HudRef, {elementName = "MPScore",  clipName = "NormalScore"}, InstanceRef)
            SetMPScoreText(HudRef, ScoreBd, InstanceRef, ModelRef)
        end
    end
    
    HudRef:subscribeToGlobalModel(InstanceRef, "PerController", "scriptNotify", MpCallback)
    
    HudRef:addElement(ScoreBd)
    HudRef.MPScore = ScoreBd
    
    local PreMatch = CoD.ZM_PrematchCountdown.new(HudRef, InstanceRef)
    PreMatch:setLeftRight(false, false, -640.000000, 640.000000)
    PreMatch:setTopBottom(false, false, -360.000000, 360.000000)
    
    HudRef:addElement(PreMatch)
    HudRef.ZMPrematchCountdown0 = PreMatch
    
    local ScoreCP = CoD.ScoreboardWidgetCP.new(HudRef, InstanceRef)
    ScoreCP:setLeftRight(false, false, -503.000000, 503.000000)
    ScoreCP:setTopBottom(true, false, 247.000000, 773.000000)
    
    HudRef:addElement(ScoreCP)
    HudRef.ScoreboardWidget = ScoreCP
    
    local BeastTimer = CoD.ZM_BeastmodeTimeBarWidget.new(HudRef, InstanceRef)
    HudRef:setLeftRight(false, false, -242.500000, 321.500000)
    HudRef:setTopBottom(false, true, -174.000000, -18.000000)
    
    HudRef:addElement(BeastTimer)
    HudRef.ZMBeastBar = BeastTimer
    
    local ShieldWidget = CoD.RocketShieldBlueprintWidget.new(HudRef, InstanceRef)
    ShieldWidget:setLeftRight(true, false, -36.500000, 277.500000)
    ShieldWidget:setTopBottom(true, false, 104.000000, 233.000000)
    ShieldWidget:setScale(0.800000)
    
    local function ShieldCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then end
        return AlwaysFalse() -- Because the shield isn't available...
    end
    
    ShieldWidget:mergeStateConditions({{stateName = "Scoreboard", condition = ShieldCallback}})
    
    local function ShieldParts(ModelRef)
        HudRef:updateElementState(ShieldWidget, {name = "model_validation",
            menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "zmInventory.widget_shield_parts"})
    end
    
    local function ShieldBitOpen(ModelRef)
        HudRef:updateElementState(ShieldWidget, {name = "model_validation", 
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), 
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end
    
    ShieldWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "zmInventory.widget_shield_parts"), ShieldParts)
    ShieldWidget:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), ShieldBitOpen)
    
    HudRef:addElement(ShieldWidget)
    HudRef.RocketShieldBlueprintWidget = ShieldWidget
    
    local ChatContainer = CoD.IngameChatClientContainer.new(HudRef, InstanceRef)
    ChatContainer:setLeftRight(true, false, 0.000000, 360.000000)
    ChatContainer:setTopBottom(true, false, -2.500000, 717.500000)
    
    HudRef:addElement(ChatContainer)
    HudRef.IngameChatClientContainer = ChatContainer
    
    local ChatContainer2 = CoD.IngameChatClientContainer.new(HudRef, InstanceRef)
    ChatContainer2:setLeftRight(true, false, 0.000000, 360.000000)
    ChatContainer2:setTopBottom(true, false, -2.500000, 717.500000)
    
    HudRef:addElement(ChatContainer2)
    HudRef.IngameChatClientContainer0 = ChatContainer2
    
    local GumPack = CoD.BubbleGumPackInGame.new(HudRef, InstanceRef)
    GumPack:setLeftRight(false, false, -184.000000, 184.000000)
    GumPack:setTopBottom(true, false, 36.000000, 185.000000)
    
    HudRef:addElement(GumPack)
    HudRef.BubbleGumPackInGame = GumPack
    
    ScoreWidget.navigation = {up = ScoreCP, right = ScoreCP}
    ScoreCP.navigation = {left = ScoreWidget, down = ScoreWidget}
    
    CoD.Menu.AddNavigationHandler(HudRef, HudRef, InstanceRef)
    
    local function MenuLoadedCallback(HudObj, EventObj)
        SizeToSafeArea(HudObj, InstanceRef)
        return HudObj:dispatchEventToChildren(EventObj)
    end
    
    HudRef:registerEventHandler("menu_loaded", MenuLoadedCallback)
    
    -- Not sure why these are explicitly set, but they are
    ScoreWidget.id = "Score"
    ScoreCP.id = "ScoreboardWidget"
    
    HudRef:processEvent({name = "menu_loaded", controller = InstanceRef})
    HudRef:processEvent({name = "update_state", menu = HudRef})
    
    if not HudRef:restoreState() then
        HudRef.ScoreboardWidget:processEvent({name = "gain_focus", controller = InstanceRef})
    end
    
    -- D3V Team logo (Only difference from stock!)
    --local DevText = CoD.TextWithBg.new(HudRef, InstanceRef)
    --DevText:setLeftRight(true, false, 10, 255)
    --DevText:setTopBottom(true, false, 10, 40)
    --DevText.Text:setText("Project Elemental: Early Access (Private)")
    --DevText.Bg:setAlpha(0)
    --DevText:setAlpha(0.7)
    --DevText:setScale(0.7)
    
    --HudRef:addElement(DevText)
    --HudRef.DevWins = DevText
	
    local function HudCloseCallback(SenderObj)
        SenderObj.ZMPerksContainerFactory:close()
        SenderObj.Rounds:close()
        SenderObj.Ammo:close()
        SenderObj.Score:close()
        SenderObj.fullscreenContainer:close()
        SenderObj.Notifications:close()
        SenderObj.ZmNotifBGBContainerFactory:close()
        SenderObj.CursorHint:close()
        SenderObj.ConsoleCenter:close()
        SenderObj.DeadSpectate:close()
        SenderObj.MPScore:close()
        SenderObj.ZMPrematchCountdown0:close()
        SenderObj.ScoreboardWidget:close()
        SenderObj.ZMBeastBar:close()
        SenderObj.RocketShieldBlueprintWidget:close()
        SenderObj.IngameChatClientContainer:close()
        SenderObj.IngameChatClientContainer0:close()
        SenderObj.BubbleGumPackInGame:close()
        SenderObj.DevWins:close()
        
        Engine.GetModel(Engine.GetModelForController(InstanceRef), "T7Hud_zm_factory.buttonPrompts")
        Engine.UnsubscribeAndFreeModel()
    end
    
    LUI.OverrideFunction_CallOriginalSecond(HudRef, "close", HudCloseCallback)
    
    if PostLoadCallback then
        PostLoadCallback(HudRef, InstanceRef)
    end

    return HudRef

end