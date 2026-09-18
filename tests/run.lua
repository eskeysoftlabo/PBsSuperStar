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
-- Enum value 0 (*_NONE) names a placeholder string the game never shows, as in the client.
function GetString(_, id) if id == 0 then return "翻訳しない" end return tostring(id) end
ARMORTYPE_NONE, WEAPONTYPE_NONE, ITEM_TRAIT_TYPE_NONE = 0, 0, 0
BAG_WORN, LINK_STYLE_DEFAULT = 1, 0
EQUIP_SLOT_HEAD, EQUIP_SLOT_HAND, EQUIP_SLOT_BACKUP_MAIN = 0, 3, 20
function GetItemLink(_, slot) return slot == 0 and "item-link" or "" end
function GetItemLinkTraitInfo() return 1, "trait" end
function GetItemLinkEnchantInfo() return false, "enchant", "enchantment description" end
function GetItemLinkSetInfo() return true, "set", 3, 3, 5, 99, 1 end
function GetItemLinkSetBonusInfo(_, equipped, index)
    eq(equipped, true)
    if index == 3 then return 5, "(5 items) bonus 3", false end
    return index + 1, index == 2 and "(3 items) bonus 2" or ("bonus " .. index), false
end
ITEM_QUALITY = 5
function GetItemLinkDisplayQuality() return ITEM_QUALITY end
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
STAT_HEALTH_MAX, STAT_SPELL_CRITICAL, STAT_BONUS_OPTION_APPLY_BONUS = 1, 2, 1
function GetCriticalStrikeChance(rating) eq(rating, 30000); return 55.25 end
CURSE_TYPE_NONE, CURSE_TYPE_VAMPIRE = 0, 1
CURSE = CURSE_TYPE_NONE
function GetPlayerCurseType() return CURSE end
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
local helm, helmSet = find(gear, "HEAD").detail, find(gear, "HEAD").detailSet
assert(not (helm .. helmSet):find("翻訳しない", 1, true), "no placeholder type names: " .. helm)
assert(not helm:find("item-link", 1, true), "the item name is the title, not repeated")
contains(helm, "状態 99%　／　防御 1500　／　1", "short facts share a line, clearly separated")
assert(not helm:find("武器威力", 1, true), "armour has no weapon power")
assert(not helm:find("セット", 1, true), "the set is its own block")
contains(helmSet, "セット効果：set（4/5）")
contains(helmSet, "\n(2) bonus 1")
contains(helmSet, "\n(3 items) bonus 2")
assert(not helmSet:find("(3) (3 items)", 1, true), "the game's own count is not doubled")
contains(helmSet, "|c9EA6B0(5 items) bonus 3|r")
eq(find(gear, "HAND").detailSet, nil)
eq(find(gear, "HEAD").itemName, "Test helm")
eq(find(gear, "HEAD").level, "CP 160")
eq(find(gear, "HEAD").setText, "Set 4/5")
eq(find(gear, "HEAD").slotLabel, "頭")
contains(find(gear, "HEAD").subline, "enchant")
contains(find(gear, "HAND").name, "未装備")
local stats = D.Stats()
eq(find(stats, "HEALTH_MAX"), nil, "header-band numbers are not listed again")
eq(find(stats, "attrHEALTH"), nil)
eq(find(stats, "category15").header, true, "the list starts at the first advanced category")
local basics = D.Basics()
eq(basics.HEALTH_MAX, 30000)
eq(basics.attrHEALTH, 20)
eq(D.Critical(basics.SPELL_CRITICAL), "30000 (55.2%)", "rating followed by the chance it gives")
eq(D.Critical(nil), "—")
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
eq(#skills.classLines, 1, "the selected class skill lines, mastery lines excluded")
eq(skills.classLines[1].name, "Class line")
eq(skills.classLines[1].rank, 50)
eq(skills.classLines[1].own, true)
-- Subclassing deactivates Class Mastery, so its points stop counting entirely.
SUBCLASSED = true
local subclassed = D.Skills(false)
eq(subclassed.mastery.subclassed, true)
eq(subclassed.mastery.points, 0, "no Class Mastery points while subclassed")
eq(#subclassed.mastery, 0)
eq(#subclassed.classLines, 2)
eq(subclassed.classLines[2].name, "Other class line")
eq(subclassed.classLines[2].own, false, "a subclassed line is marked as such")
SUBCLASSED = false
-- The first page's build summary: slotted CP by constellation, Class Mastery, Mundus, curse.
local build = D.Build(skills.mastery, skills.classLines)
eq(find(build, "cpgroup17").header, true)
eq(find(build, "cpgroup17").value, "60")
eq(find(build, "cpgroup17").discipline, CHAMPION_DISCIPLINE_TYPE_COMBAT, "coloured by constellation")
eq(find(build, "cpslot1").name, "Star 201")
eq(find(build, "cpslot1").discipline, CHAMPION_DISCIPLINE_TYPE_COMBAT)
contains(find(build, "cpslot2").name, "未装備")
eq(find(build, "classLines").breakBefore, true, "the class lines head the second column")
eq(find(build, "classLine1").name, "Class line")
eq(find(build, "classLine1").value, "R50")
eq(find(D.Build(subclassed.mastery, subclassed.classLines), "classLine2").value, "サブ R10")
eq(find(build, "mastery").value, "取得 2 / 保有 2")
eq(find(build, "mastery").gapBefore, true)
eq(find(build, "mastery1").value, "R2")
eq(find(build, "mastery1").detail, "description 301", "mastery passives carry their description")
eq(find(build, "mundus1").name, "Boon")
eq(find(build, "curseType").name, "なし")
CURSE = CURSE_TYPE_VAMPIRE
eq(find(D.Build(skills.mastery), "curseType").name, "1", "curse named by the game's own string")
CURSE = CURSE_TYPE_NONE
eq(find(D.Build(subclassed.mastery), "mastery").value, "選択不可")
local original = D.Equipment
D.Equipment = function() error("test API failure") end
local failed = D.Collect(false)
eq(failed[1][1].key, "error")
contains(failed[1][1].detail, "test API failure")
assert(#failed[4] > 1, "one collector must not blank other columns")
eq(#failed, 5)
eq(failed.basics.HEALTH_MAX, 30000)
D.Equipment = original

-- UI controls fail on unknown methods, catching typos rather than absorbing them.
local Control = {}
function Control:SetColor(r, g, b, a) self.color = {r, g, b, a} end
function Control:SetAnchor(_, _, _, x, y)
    assert(not self.anchored, "re-anchoring without ClearAnchors adds a second anchor")
    self.x, self.y, self.anchored = x, y, true
end
function Control:ClearAnchors() self.anchored = false end
function Control:IsHidden() return self.hidden or false end
for _, method in ipairs({"SetFont", "SetHorizontalAlignment", "SetMaxLineCount", "SetWrapMode", "SetCenterColor", "SetEdgeColor", "SetTexture"}) do Control[method] = function() end end
function Control:GetFontHeight() return 26 end
function Control:SetDimensions(w, h) self.width, self.height = w, h end
function Control:GetDimensions() return self.width, self.height end
function Control:SetWidth(w) self.width = w end
function Control:SetHeight(h) self.height = h end
function Control:GetHeight() return self.height end
function Control:SetText(s) self.text = s end
function Control:GetTextHeight() return self.textHeight or 200 end
function Control:SetHidden(v) self.hidden = v end
function Control:SetScale(v) self.scale = v end
function Control:SetVerticalScroll(v) self.scroll = v end
function Control:GetVerticalScroll() return self.scroll or 0 end
local function control() return setmetatable({}, {__index = Control}) end
WINDOW_MANAGER = {CreateControl = control, CreateTopLevelWindow = control}
GuiRoot = control(); GuiRoot:SetDimensions(1920, 1080)
TOPLEFT, CENTER, CT_LABEL, CT_BACKDROP, CT_TEXTURE, CT_SCROLL = 1, 2, 3, 4, 5, 6
TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, TEXT_WRAP_MODE_ELLIPSIS, KEYBIND_STRIP_ALIGN_LEFT = 1, 2, 1, 1
dofile("UI.lua")
local U = PBsSuperStar.UI
U:Create(); U:Refresh()
eq(#U.gear, 17, "every equipment slot has a row of its own")
eq(#U.cells, 224)
eq(#U.bars[1].slots, 6)
eq(#U.bars[2].slots, 6)
eq(#U.bars[1].names, 6)
eq(U.bars[1].names[1].text, "Front", "the slotted skill is named, not just drawn")
eq(U.bars[2].names[1].text, "Back crafted")
eq(U.bars[1].names[2].text, "未装備")
eq(U.gear[1].name.text, "Test helm")
eq(U.gear[1].name.color[1], 0.88, "legendary items are gold")
ITEM_QUALITY = 6; U:Refresh()
eq(U.gear[1].name.color[1], 1); eq(U.gear[1].name.color[2], 0.55, "Mythic items are orange, not white")
INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS = 7
function GetInterfaceColor(kind, quality) eq(kind, 7); eq(quality, 6); return 0.9, 0.5, 0.1, 1 end
U:Refresh(); eq(U.gear[1].name.color[2], 0.5, "the game's own quality colour wins when available")
GetInterfaceColor, ITEM_QUALITY = nil, 5; U:Refresh()
eq(U.resources[2].max.text, "30000", "resource columns are separate controls")
eq(U.offense[1][2].text, "30000 (55.2%)", "critical rating with its chance")
eq(U.detailScroll.height % 26, 0, "description window is whole lines")
-- Page 1's description is taller, and equipment shows its set in a column of its own.
eq(U.detailScroll.y, 860); eq(U.detailScroll.height, 156)
eq(U.detailSet.hidden, false)
contains(U.detailSet.text, "セット効果：set（4/5）")
eq(U.detail.width, 846, "the item block makes room for the set block")
eq(U.detailSet.x, 886)
eq(U.detail.height, 0, "description labels size themselves to their text")
-- Page 1: equipment on the left, the build in two columns of large cells beside it.
local C = U.buildCells
eq(#C, 34)
for n = 1, #U.cells do assert(U.cells[n].name.text == "", "the small grid is empty on page 1") end
contains(U.gear[3].name.text, "未装備")
eq(U:PageSize(2), 34)
eq(C[1].name.text, "Warfare", "constellation heads the first column")
eq(C[1].name.color[1], 0.35, "combat CP is blue")
eq(C[2].name.text, "Star 201")
eq(C[2].name.color[1], 0.35)
eq(C[18].name.text, "クラススキルライン", "the selected class lines start the next column")
eq(C[21].value.width, 172, "a section title's value has room for 取得 2 / 保有 2")
eq(C[21].value.text, "取得 2 / 保有 2")
eq(C[22].value.width, 92, "an entry's value keeps the narrow field")
eq(C[19].name.text, "Class line")
eq(C[20].name.text, "", "a blank row before Class Mastery")
eq(C[21].name.text, "クラスマスタリー", "Class Mastery directly after the class lines")
eq(C[22].name.text, "Skill 1")
eq(C[24].name.text, "", "a blank row separates Class Mastery from Mundus")
eq(C[25].name.text, "ムンダス")
eq(C[26].name.text, "Boon"); eq(C[26].icon.hidden, false, "mundus keeps its icon")
eq(C[28].name.text, "呪い")
-- A second column that would overflow loses its blank rows, never an entry.
local crowded = {}
for i = 1, 30 do crowded[i] = {key = "c" .. i, name = "c" .. i, value = "", gapBefore = (i % 3 == 0)} end
U.column = 2; U.data[2] = crowded; U:Render()
eq(C[30].name.text, "c30", "all 30 entries placed once the gaps are dropped")
U:Refresh(); U.column = 1; U:Render()
U:MoveColumn(1)
eq(U.column, 2)
eq(U.gear[1].name.text, "Test helm", "equipment stays while the build summary has focus")
U:MoveRow(13)
eq(U.data[2][U.selected[2]].key, "classLines")
eq(U.highlight.x, 1140 + 412, "highlight follows the column break")
eq(U.highlight.y, 308)
-- Page 2 onwards: the detailed statistics take the full width.
U:MoveColumn(1)
eq(U.column, 3)
eq(U.detailScroll.y, 932, "under the grid the description pane is back at the foot")
eq(U.detailSet.hidden, true); eq(U.detail.width, 1880, "one column when there is no set")
eq(U.gear[1].name.text, "", "equipment rows clear when another area is selected")
contains(U.cells[1].name.text, "Advanced")
-- The description continues with L2/R2, one whole window at a time.
contains(U.detailTitle.text, "説明 1/3")
local page = U.detailScroll.height
U:PageDetail(1); eq(U.detail.y, -page, "R2 moves the text up one window")
contains(U.detailTitle.text, "説明 2/3")
U:PageDetail(10); eq(U.detail.y, -2 * page)
U:PageDetail(-10); eq(U.detail.y, 0)
U:MoveRow(1); eq(U.detail.y, 0, "a new entry starts at its first line")
-- The client lays text out a frame after SetText: a height read then is one line. R2 must
-- measure again when pressed, not trust the stale value.
U.detail.textHeight = 26; U:MoveRow(1)
eq(U.detail.y, 0)
U.detail.textHeight = 200
U:PageDetail(1); eq(U.detail.y, -page, "R2 works once the text has been laid out")
U.detail.textHeight = nil
U:MoveColumn(1); eq(U.column, 4)
contains(U.cells[1].name.text, "スロット")
U:MoveColumn(-4); eq(U.column, 5)
U:MoveColumn(1); eq(U.column, 1)
U:MoveRow(-100); eq(U.selected[1], 1)
U:MoveRow(1000); eq(U.selected[1], #U.data[1])
eq(U.offsets[1], 0, "every equipment row is on screen at once")
U:MoveColumn(3); U:MoveRow(1000)
eq(U.offsets[4], 0, "the whole CP list is on screen at once")
U:MoveGridColumn(-1); eq(U.selected[4], math.max(1, #U.data[4] - 32))
-- More entries than the grid holds is the one case that still pages.
U.column = 3
U.data[3] = {}
for i = 1, 300 do U.data[3][i] = {key = "over" .. i, name = "entry " .. i, value = "", detail = "d"} end
U:MoveRow(1000)
eq(U.selected[3], 300)
eq(U.offsets[3], 300 - U:PageSize(3))
eq(U.cells[U:PageSize(3)].name.text, "entry 300")
U:Refresh()
local selectedKey = U.data[4][U.selected[4]].key
U:Refresh(); eq(U.data[4][U.selected[4]].key, selectedKey)
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
local GAMEPAD_STRIP = {nameFont = "ZoFontGamepad34", keyFont = "ZoFontGamepad22", yAnchorOffset = -53}
KEYBIND_STRIP = {AddKeybindButtonGroup = function() binds = binds + 1 end, RemoveKeybindButtonGroup = function() binds = binds - 1 end,
    style = GAMEPAD_STRIP, GetStyle = function(self) return self.style end, SetStyle = function(self, style) self.style = style end}
ZO_KeybindStripGamepadBackground = control(); ZO_KeybindStripGamepadBackground:SetDimensions(1920, 90)
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
-- The keybind strip is shorter and lower while the screen is open, and restored after.
eq(KEYBIND_STRIP.style.yAnchorOffset, -23, "strip moved down")
eq(KEYBIND_STRIP.style.nameFont, "ZoFontGamepad27", "strip labels smaller")
eq(KEYBIND_STRIP.style.keyFont, "ZoFontGamepad22", "everything else about the style is kept")
eq(ZO_KeybindStripGamepadBackground.height, 60, "strip background shorter")
eq(controlsCreated, 0, "show event must defer construction")
eq(updates.PBsSuperStarRefresh, nil)
U:MoveRow(1); U:MoveColumn(1); U:MoveGridColumn(1); U:Refresh()
updates.PBsSuperStarBuildUI()
assert(controlsCreated > 0 and not U.ready)
PBsSuperStar.scene.changed(nil, SCENE_HIDING)
eq(KEYBIND_STRIP.style, GAMEPAD_STRIP, "the game's own style comes back on close")
eq(ZO_KeybindStripGamepadBackground.height, 90)
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
eq(#U.gear, 17, "all gear rows constructed after resuming")
eq(#U.cells, 224)
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
