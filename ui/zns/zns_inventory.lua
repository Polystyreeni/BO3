CoD.ZMIslandInventory = InheritFrom(LUI.UIElement)

function CoD.ZMIslandInventory.new(HudRef,InstanceRef)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.ZMIslandInventory)
    Elem.id = "ZMIslandInventory"
    Elem.soundSet = "default"

    if not CoD.ZNSInvBar then
        CoD.ZNSInvBar = "$white"
    end
--BACKGROUND
    local Image = LUI.UIImage.new(Elem,Instance)
    Image:setLeftRight(true, true, 0, 0)
    Image:setTopBottom(false, true, -216, 0)
    Image:setImage(RegisterImage("uie_t7_base_project_e"))

    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            Image:setAlpha(1)
        else
            Image:setAlpha(0)
        end
    end

    Image:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})

    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(Image, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    Image:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)

    Elem:addElement(Image)
    Elem.BackGround = Image

--GENERATORS
    local genBottom = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_generator_bottom", "zmInventory.capture_gen1", "blacktransparent", "blacktransparent")
    genBottom:setTopBottom(false, true, -115, -30)
    genBottom:setLeftRight(true, false, 26, 104)
    Elem:addElement(genBottom)

    local genLeft = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_generator_left", "zmInventory.capture_gen2", "blacktransparent", "blacktransparent")
    genLeft:setTopBottom(false, true, -124, -29)
    genLeft:setLeftRight(true, false, 16, 110)
    Elem:addElement(genLeft)

    local genTop = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_generator_top", "zmInventory.capture_gen4", "blacktransparent", "blacktransparent")
    genTop:setTopBottom(false, true, -120, -35)
    genTop:setLeftRight(true, false, 20, 110)
    Elem:addElement(genTop)

    local genRight = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_generator_right", "zmInventory.capture_gen3", "blacktransparent", "blacktransparent")
    genRight:setTopBottom(false, true, -124, -29)
    genRight:setLeftRight(true, false, 25, 113)
    Elem:addElement(genRight)

-- SHIELD
    local window = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_shield_window", "zmInventory.piece_riotshield_clamp", "blacktransparent", "blacktransparent")
    window:setTopBottom(false, true, -126, -26)
    window:setLeftRight(true, false, 200, 308)
    Elem:addElement(window)

    local frame = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_shield_frame", "zmInventory.piece_riotshield_door", "blacktransparent", "blacktransparent")
    frame:setTopBottom(false, true, -131, -25)
    frame:setLeftRight(true, false, 123, 220)
    Elem:addElement(frame)

    local door = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_shield_tanks", "zmInventory.piece_riotshield_dolly", "blacktransparent", "blacktransparent")
    door:setTopBottom(false, true, -130, -27)
    door:setLeftRight(true, false, 285, 382)
    Elem:addElement(door)

-- IMS

--FRAME
    local piece1 = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_ims_body", "build_iw6_ims_buildable_body", "blacktransparent", "blacktransparent")
    piece1:setTopBottom(false, true, -116, -37)
    piece1:setLeftRight(true, false, 396, 472)
    Elem:addElement(piece1)

-- Bombs
    local piece2 = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_ims_explosives", "build_iw6_ims_explosive_bundle", "blacktransparent", "blacktransparent")
    piece2:setTopBottom(true, false, 615, 685)
    piece2:setLeftRight(true, false, 472, 548)
    Elem:addElement(piece2)

-- Lids
    local piece3 = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_ims_lids", "build_iw6_ims_buildable_lids", "blacktransparent", "blacktransparent")
    piece3:setTopBottom(true, false, 611, 686)
    piece3:setLeftRight(true, false, 547, 626)
    Elem:addElement(piece3)

-- METEORS
    local lightning_meteor = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_meteor_lightning", "pe_hud_p6_zm_buildable_sq_meteor_lightning", "uie_pe_meteor_lightning_ug", "blacktransparent")
    lightning_meteor:setTopBottom(false, true, -115, -42)
    lightning_meteor:setLeftRight(true, false, 655, 735)
    Elem:addElement(lightning_meteor)

    local fire_meteor = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_meteor_fire", "pe_hud_p6_zm_buildable_sq_meteor_fire", "uie_pe_meteor_fire_ug", "blacktransparent")
    fire_meteor:setTopBottom(false, true, -115, -42)
    fire_meteor:setLeftRight(true, false, 744, 825)
    Elem:addElement(fire_meteor)

    local wind_meteor = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_meteor_wind", "pe_hud_p6_zm_buildable_sq_meteor_wind", "uie_pe_meteor_wind_ug", "blacktransparent")
    wind_meteor:setTopBottom(false, true, -115, -42)
    wind_meteor:setLeftRight(true, false, 837, 920)
    Elem:addElement(wind_meteor)

    local ice_meteor = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_meteor_ice", "pe_hud_p6_zm_buildable_sq_meteor_ice", "uie_pe_meteor_ice_ug", "blacktransparent")
    ice_meteor:setTopBottom(false, true, -115, -42)
    ice_meteor:setLeftRight(true, false, 922, 1007)
    Elem:addElement(ice_meteor)

-- Spikes n Hawk
    local heroWeap = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_gravityspikes", "pe_hud_spikesgrabbed", "blacktransparent", "blacktransparent")
    heroWeap:setTopBottom(false, true, -116, -37)
    heroWeap:setLeftRight(true, false, 1147, 1225)
    Elem:addElement(heroWeap)

    local tomahawk = CoD.AddItemToHUD.new(HudRef, InstanceRef, "uie_pe_tomahawk", "pe_hud_tomahawkgrabbed", "uie_pe_tomahawk_upgraded", "blacktransparent")--cf,1,2,3,4
    tomahawk:setTopBottom(false, true, -113, -46)
    tomahawk:setLeftRight(true, false, 1061, 1155)
    Elem:addElement(tomahawk)

--TEXTS
    local GenTxt = CoD.TextWithBg.new(HudRef,InstanceRef)
    GenTxt:setLeftRight(true, false, 15, 115)
    GenTxt:setTopBottom(false, true, -200, -180)--   -(720-570=150)...
    GenTxt.Bg:setAlpha(0)
    GenTxt.Text:setText("Generators")
    GenTxt.Text:setTTF("fonts/FoundryGridnik-Medium.ttf")
    GenTxt:setRGB(1,1,1)
    GenTxt:setScale(.7)

    Elem:addElement(GenTxt)

    local ShieldTxt = CoD.TextWithBg.new(HudRef,InstanceRef)
    ShieldTxt:setLeftRight(true, false, 183, 326)
    ShieldTxt:setTopBottom(false, true, -200, -180)
    ShieldTxt.Bg:setAlpha(0)
    ShieldTxt.Text:setText("Rocket Shield")
    ShieldTxt.Text:setTTF("fonts/FoundryGridnik-Medium.ttf")
    ShieldTxt:setRGB(1,1,1)
    ShieldTxt:setScale(.75)

    Elem:addElement(ShieldTxt)

    local IMSTxt = CoD.TextWithBg.new(HudRef,InstanceRef)
    IMSTxt:setLeftRight(true, false, 466, 556)
    IMSTxt:setTopBottom(false, true, -200, -180)
    IMSTxt.Bg:setAlpha(0)
    IMSTxt.Text:setText("IMS")
    IMSTxt.Text:setTTF("fonts/FoundryGridnik-Medium.ttf")
    IMSTxt:setRGB(1,1,1)
    IMSTxt:setScale(.75)

    Elem:addElement(IMSTxt)

    local MeteorTxt = CoD.TextWithBg.new(HudRef,InstanceRef)
    MeteorTxt:setLeftRight(true, false, 746, 910)
    MeteorTxt:setTopBottom(false, true, -200, -180)
    MeteorTxt.Bg:setAlpha(0)
    MeteorTxt.Text:setText("Elemental Stones")
    MeteorTxt.Text:setTTF("fonts/FoundryGridnik-Medium.ttf")
    MeteorTxt:setRGB(1,1,1)
    MeteorTxt:setScale(.75)

    Elem:addElement(MeteorTxt)

    local WonderTxt = CoD.TextWithBg.new(HudRef,InstanceRef)
    WonderTxt:setLeftRight(true, false, 1096, 1223)
    WonderTxt:setTopBottom(false, true, -200, -180)
    WonderTxt.Bg:setAlpha(0)
    WonderTxt.Text:setText("Special Items")
    WonderTxt.Text:setTTF("fonts/FoundryGridnik-Medium.ttf")
    WonderTxt:setRGB(1,1,1)
    WonderTxt:setScale(.75)

    Elem:addElement(WonderTxt)

--END

--Hud Updates
    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            Elem:setAlpha(1)
        else
            Elem:setAlpha(0)
        end
    end

    Elem:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})
    
    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end
   Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)

    return Elem
end

CoD.AddItemToHUD = InheritFrom(LUI.UIElement)
CoD.AddTripleItemToHud = InheritFrom(LUI.UIElement)
CoD.addMark = InheritFrom(LUI.UIElement)

function CoD.AddItemToHUD.new(HudRef, InstanceRef, image, clientfield, secondary_image, third_image)

    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.AddItemToHUD)
    Elem.id = "AddItemToHUD"
    Elem.soundSet = "default"

    local null_image = RegisterImage("blacktransparent")--blacktransparent
    local MainQuestPartC_image = RegisterImage(image)
    
    local MainQuestPartCInventory = LUI.UIImage.new(Elem, Instance)
    MainQuestPartCInventory:setLeftRight(true, true, 0, 0)
    MainQuestPartCInventory:setTopBottom(true, true, 0, 0)
    --MainQuestPartCInventory:setImage(null_image)
    MainQuestPartCInventory:setImage(MainQuestPartC_image)

    local ShowMainQuestPartCInventory = Engine.CreateModel( Engine.GetModelForController(InstanceRef), clientfield )
    Engine.SetModelValue( ShowMainQuestPartCInventory, 0 )

    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            MainQuestPartCInventory:setAlpha(1)
        else
            MainQuestPartCInventory:setAlpha(0)
        end
    end

    MainQuestPartCInventory:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})

    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(MainQuestPartCInventory, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function ImageScoreBoardClientField(ModelRef)
        local rState = Engine.GetModelValue(ModelRef)

        if rState == 1 then
            MainQuestPartCInventory:setImage(MainQuestPartC_image)
            HudRef:updateElementState(MainQuestPartCInventory, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 2 then
            MainQuestPartCInventory:setImage(RegisterImage(secondary_image))
            HudRef:updateElementState(MainQuestPartCInventory, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 3 then
            MainQuestPartCInventory:setImage(RegisterImage(third_image))
            HudRef:updateElementState(MainQuestPartCInventory, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        else
            MainQuestPartCInventory:setImage(null_image)
            --MainQuestPartCInventory:setImage(MainQuestPartC_image)         
            HudRef:updateElementState(MainQuestPartCInventory, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        end
    end

    MainQuestPartCInventory:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)
    MainQuestPartCInventory:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), clientfield), ImageScoreBoardClientField)

    Elem:addElement(MainQuestPartCInventory)
    Elem.ImageElem = MainQuestPartCInventory
    return Elem
end

function CoD.AddTripleItemToHud.new(HudRef, InstanceRef, image, clientfield, secondary_image, third_image)

    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.AddTripleItemToHud)
    Elem.id = "AddTripleItemToHud"
    Elem.soundSet = "default"

    local null_image = RegisterImage("$white")--blacktransparent
    local MainQuestPartC_image = RegisterImage(image)

    local firstSeed = LUI.UIImage.new(Elem, Instance)
    firstSeed:setLeftRight(true, true, 0, 0)
    firstSeed:setTopBottom(true, true, 0, 0)
    firstSeed:setImage(RegisterImage(image))
    --firstSeed:setAlpha(0)

    Elem:addElement(firstSeed)
    Elem.FirstItem = firstSeed

    local secondSeed = LUI.UIImage.new(Elem, Instance)
    secondSeed:setLeftRight(true, true, 0, 0)
    secondSeed:setTopBottom(true, true, 0, 0)
    secondSeed:setImage(RegisterImage(image))
    --secondSeed:setAlpha(0)

    Elem:addElement(secondSeed)
    Elem.SecondItem = secondSeed

    local thirdSeed = LUI.UIImage.new(Elem, Instance)
    thirdSeed:setLeftRight(true, true, 0, 0)
    thirdSeed:setTopBottom(true, true, 0, 0)
    thirdSeed:setImage(RegisterImage(image))

    --thirdSeed:setAlpha(0)

    Elem:addElement(thirdSeed)
    Elem.ThirdItem = thirdSeed
    --firstSeed.ImageElem

    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            Elem:setAlpha(1)
        else
            Elem:setAlpha(0)
        end
    end

    Elem:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})

    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    --Elem:addElement(firstSeed)

    local function ImageScoreBoardClientField(ModelRef)
        local rState = Engine.GetModelValue(ModelRef)

        if rState == 1 then
            firstSeed:setImage(RegisterImage(image))
            secondSeed:setImage(RegisterImage("blacktransparent"))
            thirdSeed:setImage(RegisterImage("blacktransparent"))
            HudRef:updateElementState(firstSeed, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 2 then
            firstSeed:setImage(RegisterImage(image))
            secondSeed:setImage(RegisterImage(image))
            thirdSeed:setImage(RegisterImage("blacktransparent"))
            HudRef:updateElementState(secondSeed, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 3 then
            firstSeed:setImage(RegisterImage(image))
            secondSeed:setImage(RegisterImage(image))
            thirdSeed:setImage(RegisterImage(image))
            HudRef:updateElementState(thirdSeed, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 0 then
            firstSeed:setImage(RegisterImage("blacktransparent"))
            secondSeed:setImage(RegisterImage("$white"))
            thirdSeed:setImage(RegisterImage("blacktransparent"))
            HudRef:updateElementState(firstSeed, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        end
    end

    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), clientfield), ImageScoreBoardClientField)

    return Elem
end

function CoD.addMark.new(HudRef, InstanceRef, clientfield, mark1, mark2, mark3, mark4)
    local Elem = LUI.UIElement.new()
    Elem:setClass(CoD.addMark)
    Elem.id = "addMark"
    Elem.soundSet = "default"

    local null_image = RegisterImage("$white")--blacktransparent
    local MainQuestPartC_image = RegisterImage(image)

    local mark = {mark1, mark2, mark3, mark4}

    local function GetRandomMark(i)
        return mark[math.random(1, i)]
    end

    local StartMark = GetRandomMark(4)

    local Mark = LUI.UIImage.new(Elem, Instance)
    Mark:setLeftRight(true, true, 0, 0)
    Mark:setTopBottom(true, true, 0, 0)
    Mark:setImage(RegisterImage(StartMark))

    Elem:addElement(Mark)
    Elem.SkullMark = Mark

    local function MainQuestPartCScoreBoardCallback(Unk1, Unk2, Unk3)
        if Engine.IsVisibilityBitSet(InstanceRef, Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN) then
            Elem:setAlpha(1)
        else
            Elem:setAlpha(0)
        end
    end

    Elem:mergeStateConditions({{stateName = "Scoreboard", condition = MainQuestPartCScoreBoardCallback}})

    local function MainQuestPartCInventoryOpen(ModelRef)
        HudRef:updateElementState(Elem, {name = "model_validation",
            menu = HudRef, modelValue = Engine.GetModelValue(ModelRef),
            modelName = "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN})
    end

    local function ImageScoreBoardClientField(ModelRef)
        local rState = Engine.GetModelValue(ModelRef)

        if rState == 1 then
            Mark:setImage(RegisterImage(mark1))
            HudRef:updateElementState(Mark, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 2 then
            Mark:setImage(RegisterImage(mark2))
            HudRef:updateElementState(Mark, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 3 then
            Mark:setImage(RegisterImage(mark3))
            HudRef:updateElementState(Mark, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 4 then
            Mark:setImage(RegisterImage(mark4))
            HudRef:updateElementState(Mark, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        elseif rState == 0 then
            Mark:setImage(RegisterImage("blacktransparent"))
            HudRef:updateElementState(Mark, {name = "model_validation", menu = HudRef, menu = HudRef, modelValue = Engine.GetModelValue(ModelRef), modelName = clientfield})
        end
    end

    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), "UIVisibilityBit." .. Enum.UIVisibilityBit.BIT_SCOREBOARD_OPEN), MainQuestPartCInventoryOpen)
    Elem:subscribeToModel(Engine.GetModel(Engine.GetModelForController(InstanceRef), clientfield), ImageScoreBoardClientField)

    return Elem
end