---------------------------------------
-- Author: Zarem (Faerlina)
-- File version: Wrath

local _G, ipairs, format, strfind = _G, ipairs, format, strfind
local GameTooltip, GameTooltipStatusBar, ItemRefTooltip = GameTooltip, GameTooltipStatusBar, ItemRefTooltip
local GameTooltipTextLeft1, GameTooltipTextLeft2 = GameTooltipTextLeft1, GameTooltipTextLeft2

local config = {
    bg = { 0, 0, 0, 0.2 },
    border = { 0.7, 0.7, 0.7 },
    health = { 0, 1, 0 },

    classBorder = true,
    classBg = false,
    classNames = true,
    classHealth = true,

    reactionBorder = true,
    reactionBg = false,
    reactionGuild = true,
    reactionHealth = false,

    itemBorder = true,
    itemBg = false,

    scale = 1.0,

    font = STANDARD_TEXT_FONT,
    fontHeaderSize = 14,
    fontSize = 12,

    outlineFontHeader = true,
    outlineFont = false,

    healthHeight = 4.75,
    healthTexture = "Interface\\TargetingFrame\\UI-StatusBar",
    healthInside = true,

    -- Possible positions: ANCHOR_CURSOR_RIGHT, ANCHOR_CURSOR_LEFT, ANCHOR_CURSOR
    mouseAnchorPos = { "ANCHOR_CURSOR_RIGHT", 24, 5 }, -- Position, X, Y

    instantFade = true,

    hideInCombat = false,
    hideHealthBar = false,

    playerTitle = true,
    playerRealm = true,
    guildRank = true,
    pvpText = false, -- Reaction colored

    youText = format(">>%s<<", strupper(YOU)),
    afkText = "|cff909090 <AFK>",
    dndText = "|cff909090 <DND>",
    dcText = "|cff909090 <DC>",
    --targetText = format("%s:", TARGET),
    targetText = "|cffffffff@",

    yourGuild = true,
    yourGuildColor = { 1, 0.3, 1 },
    guildColor = { 1, 0.3, 1 },
    gRankColor = "|cff909090",

    bossLevel = "|r|cffff0000??",
    bossClass = format(" (%s)", BOSS),
    eliteClass = "+",
    rareClass = format(" |cffff00da%s", ITEM_QUALITY3_DESC),
    rareEliteClass = format("+ |cffff00da%s", ITEM_QUALITY3_DESC),

    backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    },
}

GameTooltipStatusBar:SetStatusBarTexture(config.healthTexture)
GameTooltipStatusBar:SetHeight(config.healthHeight)

if config.healthInside then
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT", 8, 6)
    GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT", -8, 6)
end

do
    if not ZaremTooltipAnchor then
        ZaremTooltipAnchor = {
            point = "BOTTOMRIGHT",
            relativePoint = "BOTTOMRIGHT",
            xOffset = "-95",
            yOffset = "110",
        }
    end

    local moverFrame = CreateFrame("Frame", nil, UIParent)
    moverFrame:SetFrameStrata("TOOLTIP")
    moverFrame:SetMovable(true)
    moverFrame:EnableMouse(true)
    moverFrame:RegisterForDrag("LeftButton")
    moverFrame:SetClampedToScreen(true)
    moverFrame:Hide()

    moverFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    moverFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()

        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        ZaremTooltipAnchor.point = point
        ZaremTooltipAnchor.relativePoint = relativePoint
        ZaremTooltipAnchor.xOffset = xOffset
        ZaremTooltipAnchor.yOffset = yOffset
    end)

    moverFrame:SetPoint("CENTER")
    moverFrame:SetSize(180, 80)

    local texture = moverFrame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    texture:SetColorTexture(0, 0.8, 0, 0.6)

    SLASH_ZAREMTOOLTIP1 = "/zaremtooltip"
    SLASH_ZAREMTOOLTIP2 = "/ztt"
    SlashCmdList["ZAREMTOOLTIP"] = function(msg)
        if msg == "mouse" then
            if not ZaremTooltipAnchor.mouse then
                ZaremTooltipAnchor.mouse = true
            else
                ZaremTooltipAnchor.mouse = nil
            end
        else
            if moverFrame:IsShown() then
                moverFrame:Hide()
            else
                moverFrame:Show()
            end
        end
    end
end

hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
    self:ClearAllPoints()

    if ZaremTooltipAnchor.mouse and GetMouseFocus() == WorldFrame then 
        self:SetOwner(parent, config.mouseAnchorPos[1], config.mouseAnchorPos[2], config.mouseAnchorPos[3])
    else
        self:SetOwner(parent, "ANCHOR_NONE") 
        self:SetPoint(ZaremTooltipAnchor.point, UIParent, ZaremTooltipAnchor.relativePoint, ZaremTooltipAnchor.xOffset, ZaremTooltipAnchor.yOffset)
    end
end)

GameTooltip:HookScript("OnUpdate", function(self)
    if config.instantFade and self:GetUnit() and not (UnitExists("mouseover") or ZaremTooltipAnchor.mouse) and GetMouseFocus() == WorldFrame then
        self:Hide()
    end
end)

function GameTooltip:FadeOut()
    if ZaremTooltipAnchor.mouse or config.instantFade then
        self:Hide()
    end
end

do
    if config.outlineFontHeader then
        GameTooltipHeaderText:SetFont(config.font, config.fontHeaderSize, "OUTLINE")
    else
        GameTooltipHeaderText:SetFont(config.font, config.fontHeaderSize, "")
    end

    if config.outlineFont then
        GameTooltipText:SetFont(config.font, config.fontSize, "OUTLINE")
        GameTooltipTextSmall:SetFont(config.font, config.fontSize, "OUTLINE")
    else
        GameTooltipText:SetFont(config.font, config.fontSize, "")
        GameTooltipTextSmall:SetFont(config.font, config.fontSize, "")
    end
end

local Tooltips = {
    GameTooltip,
    WorldMapTooltip,
    ShoppingTooltip1,
    ShoppingTooltip2,
    ItemRefTooltip,
    ItemRefShoppingTooltip1,
    ItemRefShoppingTooltip2,
}

local function ItemQuality(tips)
    local _, link = tips:GetItem()
    if not link then return end

    local _, _, quality = GetItemInfo(link)
    if not quality then return end

    local r, g, b = GetItemQualityColor(quality)

    if config.itemBorder then
        tips:SetBackdropBorderColor(r, g, b)
    end

    if config.itemBg then
        tips:SetBackdropColor(r, g, b, config.bg[4])
    end
end

for i, v in ipairs(Tooltips) do
    if not v.SetBackdrop then Mixin(v, BackdropTemplateMixin) end

    v:SetBackdrop(config.backdrop)
    v:SetScale(config.scale)

    v:HookScript("OnShow", function(self)
        if not GameTooltip:GetUnit() then
            self:SetBackdropColor(config.bg[1], config.bg[2], config.bg[3], config.bg[4])
            self:SetBackdropBorderColor(config.border[1], config.border[2], config.border[3])
        end

        if self.GetItem then 
            ItemQuality(self) 
        end

        if config.hideInCombat and UnitAffectingCombat("player") and not IsShiftKeyDown() then
            self:Hide()
        end
    end)
end

ItemRefTooltip:HookScript("OnTooltipSetItem", function(self)
    ItemQuality(self)
end)

ItemRefTooltip:HookScript("OnTooltipCleared", function(self)
    self:SetBackdropColor(config.bg[1], config.bg[2], config.bg[3], config.bg[4])
    self:SetBackdropBorderColor(config.border[1], config.border[2], config.border[3])
end)

local function Reaction(unit)
    local r, g, b
    if UnitIsDeadOrGhost(unit) or (UnitIsTapDenied(unit) and not (UnitIsPlayer(unit) or UnitPlayerControlled(unit))) or not UnitIsConnected(unit) then
        r, g, b = 0.5, 0.5, 0.5
    elseif UnitReaction(unit, "player") == 4 then
        r, g, b = 0.9, 0.8, 0.3
    elseif UnitIsFriend(unit, "player") then
        r, g, b = 0, 0.8, 0
    elseif UnitIsEnemy(unit, "player") then
        r, g, b = 0.9, 0.2, 0
    else
        r, g, b = 1, 1, 1
    end
    return r, g, b
end

local function ReactionHex(unit)
    local r, g, b = Reaction(unit)
    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function ClassHex(unit)
    local _, class = UnitClass(unit)
    local r, g, b = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b
    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function QuestHex(unit)
    local level = UnitLevel(unit)
    local color = GetQuestDifficultyColor(level)
    return format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

local function StatusBarColor(unit)
    if config.classHealth and UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if not class then return end
        local color = RAID_CLASS_COLORS[class]
        GameTooltipStatusBar:SetStatusBarColor(color.r, color.g, color.b)
    elseif config.reactionHealth then
        local r, g, b = Reaction(unit)
        GameTooltipStatusBar:SetStatusBarColor(r, g, b)
    else
        GameTooltipStatusBar:SetStatusBarColor(config.health[1], config.health[2], config.health[3])
    end
end

GameTooltip:HookScript("OnTooltipCleared", function(self)
    if self:IsOwned(UIParent) and not self:GetUnit() and not self:GetItem() then
        self:SetBackdropColor(config.bg[1], config.bg[2], config.bg[3], config.bg[4])
        self:SetBackdropBorderColor(config.border[1], config.border[2], config.border[3])
    end
    self:SetPadding(0, 0)
end)

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local _, unit = self:GetUnit()
    if not unit then return end

    self:SetBackdropColor(config.bg[1], config.bg[2], config.bg[3], config.bg[4])
    self:SetBackdropBorderColor(config.border[1], config.border[2], config.border[3])

    local r, g, b = Reaction(unit)
    local level = UnitLevel(unit)

    if UnitIsPlayer(unit) then
        local _, class = UnitClass(unit)
        if not class then return end
        local cr, cg, cb = RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b

        if config.classBorder then
            self:SetBackdropBorderColor(cr, cg, cb)
        elseif config.reactionBorder then
            self:SetBackdropBorderColor(r, g, b)
        end

        if config.classBg then
            self:SetBackdropColor(cr, cg, cb, config.bg[4])
        elseif config.reactionBg then
            self:SetBackdropColor(r, g, b, config.bg[4])
        end

        local nameColor
        if config.classNames then
            nameColor = ClassHex(unit)
        else
            nameColor = ReactionHex(unit)
        end

        local name, realm = UnitName(unit)
        if config.playerTitle then name = UnitPVPName(unit) or name end

        if realm and realm ~= "" then
            if config.playerRealm then
                GameTooltipTextLeft1:SetFormattedText("%s%s (%s)", nameColor, name, realm)
            else
                GameTooltipTextLeft1:SetFormattedText("%s%s (*)", nameColor, name)
            end
        else
            GameTooltipTextLeft1:SetFormattedText("%s%s", nameColor, name)
        end

        local guild, rank = GetGuildInfo(unit)
        if guild and strfind(GameTooltipTextLeft2:GetText(), guild) then
            if config.yourGuild and UnitIsInMyGuild(unit) and UnitIsSameServer(unit, "player") and UnitIsFriend(unit, "player") then
                GameTooltipTextLeft2:SetTextColor(config.yourGuildColor[1], config.yourGuildColor[2], config.yourGuildColor[3])
            else
                if config.reactionGuild then
                    GameTooltipTextLeft2:SetTextColor(r, g, b)
                else
                    GameTooltipTextLeft2:SetTextColor(config.guildColor[1], config.guildColor[2], config.guildColor[3])
                end
            end

            if config.guildRank then
                GameTooltipTextLeft2:SetFormattedText("<%s> %s%s", guild, config.gRankColor, rank)
            else
                GameTooltipTextLeft2:SetFormattedText("<%s>", guild)
            end
        end

        if UnitIsAFK(unit) then
            self:AppendText(config.afkText)
        elseif UnitIsDND(unit) then
            self:AppendText(config.dndText)
        elseif not UnitIsConnected(unit) then
            self:AppendText(config.dcText)
        end
    else
        if config.reactionBorder then
            self:SetBackdropBorderColor(r, g, b)
        end

        if config.reactionBg then
            self:SetBackdropColor(r, g, b, config.bg[4])
        end

        GameTooltipTextLeft1:SetFormattedText("%s%s", ReactionHex(unit), GameTooltipTextLeft1:GetText())

        if GameTooltipTextLeft2:IsShown() and not strfind(GameTooltipTextLeft2:GetText(), level) then
            GameTooltipTextLeft2:SetTextColor(r, g, b)
            GameTooltipTextLeft2:SetFormattedText("<%s>", GameTooltipTextLeft2:GetText())
        end
    end

    for i = 2, self:NumLines() do
        local lines = _G["GameTooltipTextLeft" .. i]

        if strfind(lines:GetText(), UNIT_LEVEL_TEMPLATE) or strfind(lines:GetText(), UNIT_LETHAL_LEVEL_TEMPLATE) then
            if level == -1 then 
                level = config.bossLevel
            end

            if UnitIsPlayer(unit) then
                lines:SetFormattedText("%s%s|r %s %s%s", QuestHex(unit), level, UnitRace(unit), ClassHex(unit), UnitClass(unit))
            else
                local class = UnitClassification(unit)
                if class == "worldboss" or strfind(lines:GetText(), BOSS) then
                    class = config.bossClass
                elseif class == "elite" then
                    class = config.eliteClass
                elseif class == "rare" then
                    class = config.rareClass
                elseif class == "rareelite" then
                    class = config.rareEliteClass
                else
                    class = ""
                end

                local creature = UnitCreatureFamily(unit) or UnitCreatureType(unit) or ""

                if creature == "Not specified" then
                    creature = ""
                end

                if creature == "Non-combat Pet" then
                    creature = "Pet"
                end

                lines:SetFormattedText("%s%s%s|r|cffffffff %s", QuestHex(unit), level, class, creature)
            end
        end

        if i > 2 then
            if lines:GetText() == PVP_ENABLED then
                if config.pvpText then
                    lines:SetTextColor(r, g, b)
                else
                    lines:SetText(nil)
                end
            end
        end
    end

    local tot = unit .. "target"
    if UnitExists(tot) then
        if UnitIsUnit("player", tot) then
            self:AddLine(format("%s %s%s", config.targetText, ReactionHex(unit), config.youText))
        elseif UnitIsPlayer(tot) then
            self:AddLine(format("%s %s%s", config.targetText, ClassHex(tot), UnitName(tot)))
        else
            self:AddLine(format("%s %s%s", config.targetText, ReactionHex(tot), UnitName(tot)))
        end
    end

    StatusBarColor(unit)

    if config.hideHealthBar or UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        GameTooltipStatusBar:Hide()
    end

    if config.healthInside and GameTooltipStatusBar:IsShown() then
        self:SetPadding(0, 8)
    end

    self:Show()
end)

GameTooltipStatusBar:HookScript("OnValueChanged", function(self, value)
    if not value then return end
    local _, unit = GameTooltip:GetUnit()
    if not unit then return end
    StatusBarColor(unit)
end)
