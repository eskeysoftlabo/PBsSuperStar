-- Run from the project root: lua tests/run.lua
-- ESO API fixtures, not a substitute for testing in the game client.
unpack = unpack or table.unpack
local checks = 0
local function eq(actual, expected, message)
    checks = checks + 1
    assert(actual == expected, (message or "mismatch") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function contains(value, part) assert(value:find(part, 1, true), value); checks = checks + 1 end
function zo_strformat(_, s) return s end
function zo_round(n) return math.floor(n + 0.5) end
function GetString(_, id) return tostring(id) end
BAG_WORN, LINK_STYLE_DEFAULT = 1, 0
EQUIP_SLOT_HEAD, EQUIP_SLOT_HAND, EQUIP_SLOT_BACKUP_MAIN = 0, 3, 20
function GetItemLink(_, slot) return slot == 0 and "item-link" or "" end
function GetItemLinkTraitInfo() return 1, "trait" end
function GetItemLinkEnchantInfo() return false, "enchant", "enchantment description" end
function GetItemLinkSetInfo() return true, "set", 2, 3, 5, 99, 1 end
function GetItemLinkSetBonusInfo(_, equipped, index) eq(equipped, true); return index + 1, "bonus " .. index end
function GetItemLinkDisplayQuality() return 5 end
function GetItemLinkRequiredLevel() return 50 end
function GetItemLinkRequiredChampionPoints() return 160 end
function GetItemCondition() return 99 end
function GetItemLinkArmorRating() return 1500 end
function GetItemLinkWeaponPower() return 0 end
function GetItemLinkArmorType() return 1 end
function GetItemLinkWeaponType() return 0 end
function DoesItemLinkHaveEnchantCharges() return false end
function GetItemLinkName() return "Test helm" end
function GetItemInfo() return "helm.dds", 1, 2 end
STAT_HEALTH_MAX, STAT_BONUS_OPTION_APPLY_BONUS = 1, 1
ATTRIBUTE_HEALTH, ATTRIBUTE_MAGICKA, ATTRIBUTE_STAMINA = 1, 2, 3
function GetPlayerStat(_, bonus) eq(bonus, 1); return 30000 end
function GetAttributeSpentPoints() return 20 end
ADVANCED_STAT_DISPLAY_FORMAT_FLAT = 1
ADVANCED_STAT_DISPLAY_FORMAT_PERCENT = 2
ADVANCED_STAT_DISPLAY_FORMAT_FLAT_OR_PERCENT = 3
ADVANCED_STAT_DISPLAY_FORMAT_FLAT_AND_PERCENT = 4
function GetNumAdvancedStatCategories() return 1 end
function GetAdvancedStatsCategoryId() return 15 end
function GetAdvancedStatCategoryInfo(id) eq(id, 15); return "Advanced", 4 end
function GetAdvancedStatInfo(_, i) return i, "stat" .. i, "description", "flat", "percent" end
function GetAdvancedStatValue(id) return id, 100, 12.5 end
function GetUnitActiveMundusStoneBuffIndices() return 1 end
function GetNumBuffs() return 1 end
function GetUnitBuffInfo() return "Boon", 0, 0, 1, 1, "buff.dds", nil, 0, 0, 0, 77 end
function GetAbilityDescription(id) return "description " .. id end
function GetFrameTimeSeconds() return 50 end
HOTBAR_CATEGORY_CHAMPION, HOTBAR_CATEGORY_PRIMARY, HOTBAR_CATEGORY_BACKUP = 4, 0, 1
ACTION_TYPE_CRAFTED_ABILITY = 9
function GetAssignableChampionBarStartAndEndSlots() return 1, 12 end
function GetSlotBoundId(slot, bar)
    if bar == 4 then return slot == 1 and 201 or 0 end
    return slot == 3 and (bar == 0 and 111 or 222) or 0
end
function GetNumChampionDisciplines() return 1 end
function GetChampionDisciplineId(i) eq(i, 1); return 17 end
function GetChampionDisciplineName(id) eq(id, 17, "discipline ID, not index"); return "Warfare" end
CHAMPION_DISCIPLINE_TYPE_COMBAT, CHAMPION_DISCIPLINE_TYPE_CONDITIONING, CHAMPION_DISCIPLINE_TYPE_WORLD = 1, 2, 3
function GetChampionDisciplineType() return CHAMPION_DISCIPLINE_TYPE_COMBAT end
function GetRequiredChampionDisciplineIdForSlot(_, bar) eq(bar, HOTBAR_CATEGORY_CHAMPION); return 17 end
function GetNumSpentChampionPoints(id) eq(id, 17); return 60 end
function GetNumUnspentChampionPoints(id) eq(id, 17); return 10 end
function GetNumChampionDisciplineSkills(i) eq(i, 1); return 4 end
function GetChampionSkillId(_, i) return 200 + i end
function GetChampionSkillName(id) return "Star " .. id end
function GetNumPointsSpentOnChampionSkill(id) return id == 204 and 0 or 20 end
function GetChampionSkillMaxPoints() return 50 end
function GetChampionSkillType(id) return id == 203 and 0 or 1 end
function CanChampionSkillTypeBeSlotted(t) return t == 1 end
function WouldChampionSkillNodeBeUnlocked(_, points) return points > 0 end
function GetChampionSkillDescription(_, points) return "spent " .. points end
function GetChampionSkillCurrentBonusText() return "bonus" end
function GetActiveHotbarCategory() return 0 end
function GetSlotType(_, bar) return bar == 0 and 1 or 9 end
function GetSlotName(_, bar) return bar == 0 and "Front" or "Back crafted" end
function GetSlotTexture() return "skill.dds" end
function GetCraftedAbilityDescription(id) return "crafted " .. id end
function GetAvailableSkillPoints() return 12 end
function GetNumSkillTypes() return 1 end
local LINE_NAMES = {[42] = "Class line", [43] = "Class mastery", [44] = "Other class mastery", [45] = "Other class line"}
SUBCLASSED = false
function GetNumSkillLines() return 4 end
function GetSkillLineId(_, l) return 41 + l end
function GetSkillLineNameById(id) return LINE_NAMES[id] end
-- Line 2 is this character's Class Mastery line: undiscovered, as the client reports them
-- before max rank. Lines 3 and 4 belong to another class, and line 4 is only active while
-- this character is subclassed into it.
function GetSkillLineDynamicInfo(_, l)
    if l == 2 then return 4, false, true, false, false, false, true end
    if l == 3 then return 4, false, false, false, false, false, true end
    if l == 4 then return 10, false, SUBCLASSED, true end
    return 50, false, true, true
end
function GetSkillLineClassId(_, l) return l >= 3 and 2 or 1 end
function IsPlayerClassSkillLineById(id) return id <= 43 end
function GetNumClassMasteryPointsBySkillLineId(id) return id == 43 and 2 or 7 end
function GetNumSkillAbilities() return 3 end
function GetSkillAbilityInfo(_, _, index) return "Skill " .. index, "skill.dds", 1, index == 2, false, index < 3, nil, 2 end
function GetSkillAbilityId(_, _, index) return 300 + index end
function IsCraftedAbilitySkill() return false end
function GetUnitName() return "Hero" end
function GetUnitRace() return "Race" end
function GetUnitClass() return "Class" end
function GetUnitLevel() return 50 end
function GetUnitChampionPoints() return 1600 end
function GetUnitTitle() return "Title" end

dofile("Data.lua")
local D = PBsSuperStar.Data
local function find(rows, key)
    for _, r in ipairs(rows) do if r.key == key then return r end end
end
local gear = D.Equipment()
eq(#gear, 3)
eq(find(gear, "HEAD").icon, "helm.dds")
contains(find(gear, "HEAD").detail, "enchantment description")
contains(find(gear, "HEAD").detail, "bonus 2")
eq(find(gear, "HEAD").itemName, "Test helm")
eq(find(gear, "HEAD").level, "CP 160")
eq(find(gear, "HEAD").setText, "Set 4/5")
eq(find(gear, "HEAD").slotLabel, "頭")
contains(find(gear, "HEAD").subline, "enchant")
contains(find(gear, "HAND").name, "未装備")
local stats = D.Stats()
eq(find(stats, "stat1").value, "100")
eq(find(stats, "stat2").value, "12.5%")
eq(find(stats, "stat3").value, "12.5%")
eq(find(stats, "stat4").value, "100 / 12.5%")
contains(find(stats, "buff77:1").name, "ムンダス")
local cp = D.Champion(false)
contains(find(cp, "cp201").name, "装備中")
contains(find(cp, "cp202").name, "未装備")
contains(find(cp, "cp203").name, "パッシブ")
eq(find(cp, "cp204"), nil)
contains(find(D.Champion(true), "cp204").name, "未発動")
local skills = D.Skills(false)
eq(find(skills, "bar0:3").detail, "description 111")
eq(find(skills, "bar1:3").detail, "crafted 222")
contains(find(skills, "skill1:1:2").detail, "パッシブ")
eq(find(skills, "skill1:1:3"), nil)
eq(find(D.Skills(true), "skill1:1:3").value, "未取得")
contains(find(skills, "line43").name, "クラスマスタリー")
eq(#skills.mastery, 2, "purchased class mastery passives")
eq(skills.mastery.lines, 1, "another class's mastery line is not this character's")
eq(skills.mastery.points, 2, "points of the active class only, not every class")
eq(skills.mastery[1].name, "Skill 1")
eq(skills.mastery.subclassed, false)
-- Subclassing deactivates Class Mastery, so its points stop counting entirely.
SUBCLASSED = true
local subclassed = D.Skills(false)
eq(subclassed.mastery.subclassed, true)
eq(subclassed.mastery.points, 0, "no Class Mastery points while subclassed")
eq(#subclassed.mastery, 0)
SUBCLASSED = false
local original = D.Equipment
D.Equipment = function() error("test API failure") end
local failed = D.Collect(false)
eq(failed[1][1].key, "error")
contains(failed[1][1].detail, "test API failure")
assert(#failed[4] > 1, "one collector must not blank other columns")
D.Equipment = original

-- UI controls fail on unknown methods, catching typos rather than absorbing them.
local Control = {}
for _, method in ipairs({"SetAnchor", "SetFont", "SetColor", "SetHorizontalAlignment", "SetMaxLineCount", "SetWrapMode", "SetCenterColor", "SetEdgeColor", "SetTexture"}) do Control[method] = function() end end
function Control:GetFontHeight() return 26 end
function Control:SetDimensions(w, h) self.width, self.height = w, h end
function Control:GetDimensions() return self.width, self.height end
function Control:SetWidth(w) self.width = w end
function Control:SetHeight(h) self.height = h end
function Control:GetHeight() return self.height end
function Control:SetText(s) self.text = s end
function Control:GetTextHeight() return 200 end
function Control:SetHidden(v) self.hidden = v end
function Control:SetScale(v) self.scale = v end
function Control:SetVerticalScroll(v) self.scroll = v end
function Control:GetVerticalScroll() return self.scroll or 0 end
local function control() return setmetatable({}, {__index = Control}) end
WINDOW_MANAGER = {CreateControl = control, CreateTopLevelWindow = control}
GuiRoot = control(); GuiRoot:SetDimensions(1920, 1080)
TOPLEFT, CENTER, CT_LABEL, CT_BACKDROP, CT_TEXTURE, CT_SCROLL = 1, 2, 3, 4, 5, 6
TEXT_ALIGN_RIGHT, TEXT_WRAP_MODE_ELLIPSIS, KEYBIND_STRIP_ALIGN_LEFT = 1, 1, 1
dofile("UI.lua")
local U = PBsSuperStar.UI
U:Create(); U:Refresh()
eq(#U.gear, 14)
eq(#U.inspect, 5)
eq(#U.bars[1].slots, 6)
eq(#U.bars[2].slots, 6)
eq(#U.champion, 3)
eq(#U.champion[1].slots, 4)
contains(U.champion[1].slots[1].text, "Star 201")
eq(U.gear[1].name.text, "Test helm")
contains(U.effects[1].name.text, "ムンダス")
eq(#U.mastery, 4)
contains(U.mastery[1].text, "Skill 1")
contains(U.masteryTitle.text, "取得 2")
contains(U.masteryTitle.text, "ポイント 2")
SUBCLASSED = true; U:Refresh()
contains(U.masteryTitle.text, "選択不可")
eq(U.mastery[2].text, "")
SUBCLASSED = false; U:Refresh()
eq(U.resources[2].max.text, "30000", "resource columns are separate controls")
eq(U.detailScroll.height % 26, 0, "description height must be whole lines")
U:MoveColumn(-1); eq(U.column, 4)
U:MoveColumn(1); eq(U.column, 1)
U:MoveRow(-100); eq(U.selected[1], 1)
U:MoveRow(1000); eq(U.selected[1], #U.data[1])
U:MoveColumn(2); U:MoveRow(1000)
eq(U.offsets[3], #U.data[3] - U:PageSize(3))
U:ScrollDetail(10000); eq(U.detailScroll:GetVerticalScroll(), 200 - U.detailScroll:GetHeight())
U:ScrollDetail(-10000); eq(U.detailScroll:GetVerticalScroll(), 0)
local selectedKey = U.data[3][U.selected[3]].key
U:Refresh(); eq(U.data[3][U.selected[3]].key, selectedKey)
GuiRoot:SetDimensions(1280, 720); U:Resize(); assert(U.root.scale < 0.7)

local events, updates = {}, {}
EVENT_ADD_ON_LOADED, EVENT_PLAYER_ACTIVATED, EVENT_SCREEN_RESIZED = 1, 2, 3
SCENE_SHOWING, SCENE_HIDING = 1, 2
EVENT_MANAGER = {
    RegisterForEvent = function(_, name, event, fn) events[name .. event] = fn end,
    UnregisterForEvent = function(_, name, event) events[name .. event] = nil end,
    RegisterForUpdate = function(_, name, _, fn) updates[name] = fn end,
    UnregisterForUpdate = function(_, name) updates[name] = nil end,
}
ZO_Scene = {New = function()
    return {AddFragmentGroup = function() end, AddFragment = function() end,
        RegisterCallback = function(self, _, fn) self.changed = fn end}
end}
ZO_FadeSceneFragment = {New = function() return {} end}
FRAGMENT_GROUP = {GAMEPAD_DRIVEN_UI_WINDOW = {}}
ZO_MENU_ENTRIES = {}
ZO_GamepadEntryData = {New = function(_, name)
    return {name = name, SetIconTintOnSelection = function() end, SetIconDisabledTintOnSelection = function() end,
        SetEnabled = function(self, value) self.enabled = value end}
end}
local binds = 0
KEYBIND_STRIP = {AddKeybindButtonGroup = function() binds = binds + 1 end, RemoveKeybindButtonGroup = function() binds = binds - 1 end}
SLASH_COMMANDS = {}
SCENE_MANAGER = {Push = function(_, name) eq(name, "pbsSuperStar") end}
-- A fresh UI must stay unallocated at addon load, including without coroutines.
coroutine = nil
dofile("UI.lua")
U = PBsSuperStar.UI
local controlsCreated = 0
WINDOW_MANAGER.CreateControl = function() controlsCreated = controlsCreated + 1; return control() end
WINDOW_MANAGER.CreateTopLevelWindow = WINDOW_MANAGER.CreateControl
dofile("PBsSuperStar.lua")
events.PBsSuperStar1(nil, "DifferentAddon"); eq(#ZO_MENU_ENTRIES, 0)
events.PBsSuperStar1(nil, "PBsSuperStar"); eq(#ZO_MENU_ENTRIES, 1)
eq(ZO_MENU_ENTRIES[1].name, "ステータス超詳細")
PBsSuperStar:InstallMenu(); eq(#ZO_MENU_ENTRIES, 1)
eq(controlsCreated, 0, "addon load must not create dashboard controls")
events.PBsSuperStar3(); eq(controlsCreated, 0, "resize before first open")
PBsSuperStar:Open()
PBsSuperStar.scene.changed(nil, SCENE_SHOWING)
eq(controlsCreated, 0, "show event must defer construction")
eq(updates.PBsSuperStarRefresh, nil)
U:MoveRow(1); U:MoveColumn(1); U:ScrollDetail(32); U:Refresh()
updates.PBsSuperStarBuildUI()
assert(controlsCreated > 0 and not U.ready)
PBsSuperStar.scene.changed(nil, SCENE_HIDING)
eq(updates.PBsSuperStarBuildUI, nil, "close pauses construction")
eq(updates.PBsSuperStarRefresh, nil)
eq(binds, 0)
PBsSuperStar.scene.changed(nil, SCENE_SHOWING)
local frameCount = 0
while updates.PBsSuperStarBuildUI do
    local before = controlsCreated
    updates.PBsSuperStarBuildUI()
    assert(controlsCreated - before <= 20, "construction stage exceeded control limit")
    frameCount = frameCount + 1
    assert(frameCount < 100, "construction did not complete")
end
assert(frameCount > 1 and U.ready)
assert(updates.PBsSuperStarRefresh)
eq(#U.gear, 14, "all gear rows constructed after resuming")
eq(#U.champion, 3)
PBsSuperStar.scene.changed(nil, SCENE_HIDING)
local finishedCount = controlsCreated
for _ = 1, 2 do
    PBsSuperStar.scene.changed(nil, SCENE_SHOWING); eq(binds, 1)
    assert(updates.PBsSuperStarRefresh)
    PBsSuperStar.scene.changed(nil, SCENE_HIDING); eq(binds, 0)
    eq(updates.PBsSuperStarRefresh, nil)
end
eq(controlsCreated, finishedCount, "reopening reuses existing controls")
print("PASS: " .. checks .. " checks (data, navigation, scene lifecycle, menu)")
