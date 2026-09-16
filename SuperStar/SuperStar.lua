--[[
Author: Ayantir
Filename: SuperStar.lua
Version: 3.1
]]--

-- Init SuperStar variables
SuperStarSkills = ZO_Object:Subclass()
local ADDON_NAME = "SuperStar"

local TAG_ATTRIBUTES = "#"
local TAG_SKILLS = "@"
local TAG_CP = "%"

local REVISION_ATTRIBUTES = "1"
local REVISION_SKILLS = "2"
local REVISION_CP = "1"

-- No mode for attrs
local MODE_SKILLS = "1"
local MODE_CP = "4"

local ConstellationsDesc = {}
local ConstellationsDescPassives = {}
local actionBarConfig = {}
local ChampionParser = {}
local SkillParser = {}

local skillsDataForRespec
local SetTitle

local xmlIncludeAttributes = true
local xmlIncludeSkills = true
local xmlInclChampionSkills = true

local SKILL_ABILITY_DATA = 1
local SKILL_HEADER_DATA = 2

local ABILITY_TYPE_ULTIMATE = 0
local ABILITY_TYPE_ACTIVE = 1
local ABILITY_TYPE_PASSIVE = 2

local CLASS_DRAGONKNIGHT = 1
local CLASS_SORCERER = 2
local CLASS_NIGHTBLADE = 3
local CLASS_WARDEN = 4
local CLASS_TEMPLAR = 6

local ABILITY_LEVEL_NONMORPHED = 0
local ABILITY_LEVEL_UPPERMORPH = 1
local ABILITY_LEVEL_LOWERMORPH = 2

local ABILITY_TYPE_ULTIMATE_RANGE = 4
local ABILITY_TYPE_ACTIVE_RANGE = 8
local ABILITY_TYPE_PASSIVE_RANGE = 16

local SKILLTYPE_TREESHOLD = 31

local ATTR_MAX_SPENDABLE_POINTS = 64
local SP_MAX_SPENDABLE_POINTS = 400
local CP_MAX_SPENDABLE_POINTS = 100 -- Per skill

local MAX_PLAYABLE_RACES = 10
local SKILLTYPES_IN_SKILLBUILDER = 8

local FOOD_BUFF_NONE = 0
local FOOD_BUFF_MAX_HEALTH = 1
local FOOD_BUFF_MAX_MAGICKA = 2
local FOOD_BUFF_MAX_STAMINA = 4
local FOOD_BUFF_REGEN_HEALTH = 8
local FOOD_BUFF_REGEN_MAGICKA = 16
local FOOD_BUFF_REGEN_STAMINA = 32
local FOOD_BUFF_SPECIAL_VAMPIRE = 64
local FOOD_BUFF_MAX_HEALTH_MAGICKA = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_MAX_MAGICKA
local FOOD_BUFF_MAX_HEALTH_STAMINA = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_MAX_STAMINA
local FOOD_BUFF_MAX_MAGICKA_STAMINA = FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_MAX_STAMINA
local FOOD_BUFF_REGEN_HEALTH_MAGICKA = FOOD_BUFF_REGEN_HEALTH + FOOD_BUFF_REGEN_MAGICKA
local FOOD_BUFF_REGEN_HEALTH_STAMINA = FOOD_BUFF_REGEN_HEALTH + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_REGEN_MAGICKA_STAMINA = FOOD_BUFF_REGEN_MAGICKA + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_MAX_ALL = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_MAX_STAMINA
local FOOD_BUFF_REGEN_ALL = FOOD_BUFF_REGEN_HEALTH + FOOD_BUFF_REGEN_MAGICKA + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_MAX_HEALTH_REGEN_HEALTH = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_REGEN_HEALTH
local FOOD_BUFF_MAX_HEALTH_REGEN_MAGICKA = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_REGEN_MAGICKA
local FOOD_BUFF_MAX_HEALTH_REGEN_STAMINA = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_MAX_HEALTH_REGEN_ALL = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_REGEN_HEALTH + FOOD_BUFF_REGEN_MAGICKA + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_MAX_MAGICKA_REGEN_STAMINA = FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_REGEN_STAMINA
local FOOD_BUFF_MAX_MAGICKA_REGEN_HEALTH = FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_REGEN_HEALTH
local FOOD_BUFF_MAX_MAGICKA_REGEN_MAGICKA = FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_REGEN_MAGICKA
local FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_MAGICKA = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_REGEN_MAGICKA
local FOOD_BUFF_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE = FOOD_BUFF_MAX_HEALTH + FOOD_BUFF_MAX_MAGICKA + FOOD_BUFF_SPECIAL_VAMPIRE

local STAT_SPELL_CRITICAL_PERCENT = STAT_SPELL_CRITICAL * 100
local STAT_CRITICAL_STRIKE_PERCENT = STAT_CRITICAL_STRIKE * 100
local STAT_SPELL_RESIST_PERCENT = STAT_SPELL_RESIST * 100
local STAT_PHYSICAL_RESIST_PERCENT = STAT_PHYSICAL_RESIST * 100

local defaults = {
	favoritesList = {},
}

-- Register librairies
local LMM = LibStub("LibMainMenu")
local LSF = LibStub("LibSkillsFactory")

local MENU_CATEGORY_SUPERSTAR
local SUPERSTAR_SKILLS_WINDOW
local SUPERSTAR_SKILLS_PRESELECTORWINDOW
local SUPERSTAR_SKILLS_BUILDERWINDOW
local SUPERSTAR_SKILLS_SCENE

local SUPERSTAR_FAVORITES_WINDOW
local SUPERSTAR_IMPORT_WINDOW

local favoritesManager
local isFavoriteShown = false
local isFavoriteLocked = false
local isFavoriteHaveSP = false
local isFavoriteHaveCP = false
local isFavoriteValid = false
local isImportedBuildValid = false
local virtualFavorite = "$" .. GetUnitName("player")

local RESPEC_MODE_SP = 1
local RESPEC_MODE_CP = 2

local cpRespecInProgress = false

local db

-- Utility
local function Base62( value )
	local r = false
	local state = type( value )
	local u = string.sub(value, 1, 1) == "-"
	if state == "number" then
		local k = math.floor(math.abs(value)) -- no decimals, only integers, no negatives
		if k > 9 then
			local m
			r = ""
			while k > 0 do
				m = k % 62
				k = ( k - m ) / 62
				if m >= 36 then
					m = m + 61
				elseif m >= 10 then
					m = m + 55
				else
					m = m + 48
				end
				r = string.char( m ) .. r
			end
		else
			r = tostring(k)
		end
		if n then r = "-" .. r end
	elseif state == "string" then
		if u then value = value:sub(value, 1, -2) end
		if value:match( "^%w+$" ) then
			local n = #value
			local k = 1
			local c
			r = 0
			for i = n, 1, -1 do
				c = value:byte( i, i )
				if c >= 48  and  c <= 57 then
					c = c - 48
				elseif c >= 65  and  c <= 90 then
					c = c - 55
				elseif c >= 97  and  c <= 122 then
					c = c - 61
				else
					r = nil
					break
				end
				r = r + c * k
				k = k * 62
			end
			if u then r = 0 - r end
		end
	end
	return r
end

-- Skill Builder
local function SetAbilityButtonTextures(button, passive)
	if passive then
		button:SetNormalTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
		button:SetPressedTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
		button:SetMouseOverTexture(nil)
		button:SetDisabledTexture("EsoUI/Art/ActionBar/passiveAbilityFrame_round_up.dds")
	else
		button:SetNormalTexture("EsoUI/Art/ActionBar/abilityFrame64_up.dds")
		button:SetPressedTexture("EsoUI/Art/ActionBar/abilityFrame64_down.dds")
		button:SetMouseOverTexture("EsoUI/Art/ActionBar/actionBar_mouseOver.dds")
		button:SetDisabledTexture("EsoUI/Art/ActionBar/abilityFrame64_up.dds")
	end
end

function SuperStarSkills:New(container)

	local manager = ZO_Object.New(SuperStarSkills)
	LSF:Initialize(GetUnitClassId("player"), GetUnitRaceId("player"))
	
	SuperStarSkills:InitInternalFactoryForBuilder()
	SuperStarSkills:InitializePreSelector()
	
	SuperStarSkills.availableSkillsPoints = SuperStarSkills:GetAvailableSkillPoints()
	
	manager.displayedAbilityProgressions = {}
	
	manager.container = container
	manager.availablePoints = 0
	manager.availablePointsLabel = GetControl(container, "AvailablePoints")
	
	manager.navigationTree = ZO_Tree:New(GetControl(container, "NavigationContainerScrollChild"), 60, -10, 300)
	
	local function TreeHeaderSetup(node, control, skillType, open)
		control.skillType = skillType
		control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
		control.text:SetText(GetString("SI_SKILLTYPE", skillType))
		local down, up, over = ZO_Skills_GetIconsForSkillType(skillType)
		
		control.icon:SetTexture(open and down or up)
		control.iconHighlight:SetTexture(over)
		
		ZO_IconHeader_Setup(control, open)
	end
	
	manager.navigationTree:AddTemplate("ZO_IconHeader", TreeHeaderSetup, nil, nil, nil, 0)
	
	local function TreeEntrySetup(node, control, data, open)
		local name = LSF:GetSkillLineInfo(data.skillType, data.skillLineIndex)
		control:SetText(zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, name))
	end
	local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
		control:SetSelected(selected)
		if selected and not reselectingDuringRebuild then
			manager:RefreshSkillInfo()
			manager:RefreshList()
		end
		
	end
	local function TreeEntryEquality(left, right)
		return left.skillType == right.skillType and left.skillLineIndex == right.skillLineIndex
	end
	
	manager.navigationTree:AddTemplate("SuperStarXMLSkillsNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)
	
	manager.navigationTree:SetExclusive(true)
	manager.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
	
	manager.skillInfo = GetControl(container, "SkillInfo")
	
	manager.abilityList = GetControl(container, "AbilityList")
	ZO_ScrollList_Initialize(manager.abilityList)
	ZO_ScrollList_AddDataType(manager.abilityList, SKILL_ABILITY_DATA, "SuperStarXMLSkillsAbility", 70, function(control, data) manager:SetupAbilityEntry(control, data) end)
	ZO_ScrollList_AddDataType(manager.abilityList, SKILL_HEADER_DATA, "SuperStarXMLSkillsAbilityTypeHeader", 32, function(control, data) manager:SetupHeaderEntry(control, data) end)
	ZO_ScrollList_AddResizeOnScreenResize(manager.abilityList)
	
	manager.morphDialog = GetControl("SuperStarXMLSkillsMorphDialog")
	manager.morphDialog.desc = GetControl(manager.morphDialog, "Description")
	
	manager.morphDialog.baseAbility = GetControl(manager.morphDialog, "BaseAbility")
	manager.morphDialog.baseAbility.icon = GetControl(manager.morphDialog.baseAbility, "Icon")
	
	manager.morphDialog.morphAbility1 = GetControl(manager.morphDialog, "MorphAbility1")
	manager.morphDialog.morphAbility1.icon = GetControl(manager.morphDialog.morphAbility1, "Icon")
	manager.morphDialog.morphAbility1.selectedCallout = GetControl(manager.morphDialog.morphAbility1, "SelectedCallout")
	manager.morphDialog.morphAbility1.morph = ABILITY_LEVEL_UPPERMORPH
	manager.morphDialog.morphAbility1.rank = 4
	
	manager.morphDialog.morphAbility2 = GetControl(manager.morphDialog, "MorphAbility2")
	manager.morphDialog.morphAbility2.icon = GetControl(manager.morphDialog.morphAbility2, "Icon")
	manager.morphDialog.morphAbility2.selectedCallout = GetControl(manager.morphDialog.morphAbility2, "SelectedCallout")
	manager.morphDialog.morphAbility2.morph = ABILITY_LEVEL_LOWERMORPH
	manager.morphDialog.morphAbility2.rank = 4

	manager.morphDialog.confirmButton = GetControl(manager.morphDialog, "Confirm")

	local function SetupMorphAbilityConfirmDialog(dialog, abilityControl)
		if abilityControl.ability.atMorph then
		
			local ability = abilityControl.ability
			local slot = abilityControl.ability.slot
			
			dialog.desc:SetText(zo_strformat(SI_SKILLS_SELECT_MORPH, ability.name))
			
			dialog.baseAbility.skillType = abilityControl.skillType
			dialog.baseAbility.skillLineIndex = abilityControl.skillLineIndex
			dialog.baseAbility.abilityIndex = abilityControl.abilityIndex
			dialog.baseAbility.abilityId = abilityControl.abilityId
			dialog.baseAbility.abilityLevel = ABILITY_LEVEL_NONMORPHED
			dialog.baseAbility.icon:SetTexture(slot.iconFile)
			
			local _, morph1Icon = LSF:GetAbilityInfo(dialog.baseAbility.skillType, dialog.baseAbility.skillLineIndex, dialog.baseAbility.abilityIndex, dialog.morphAbility1.morph, dialog.morphAbility1.rank)
			dialog.morphAbility1.abilityId = LSF:GetAbilityId(dialog.baseAbility.skillType, dialog.baseAbility.skillLineIndex, dialog.baseAbility.abilityIndex, dialog.morphAbility1.morph, dialog.morphAbility1.rank)
			dialog.morphAbility1.skillType = dialog.baseAbility.skillType
			dialog.morphAbility1.skillLineIndex = dialog.baseAbility.skillLineIndex
			dialog.morphAbility1.abilityIndex = dialog.baseAbility.abilityIndex
			dialog.morphAbility1.abilityLevel = ABILITY_LEVEL_UPPERMORPH
			dialog.morphAbility1.icon:SetTexture(morph1Icon)
			dialog.morphAbility1.selectedCallout:SetHidden(true)
			ZO_ActionSlot_SetUnusable(dialog.morphAbility1.icon, false)
			
			local _, morph2Icon = LSF:GetAbilityInfo(dialog.baseAbility.skillType, dialog.baseAbility.skillLineIndex, dialog.baseAbility.abilityIndex, dialog.morphAbility2.morph, dialog.morphAbility2.rank)
			dialog.morphAbility2.abilityId = LSF:GetAbilityId(dialog.baseAbility.skillType, dialog.baseAbility.skillLineIndex, dialog.baseAbility.abilityIndex, dialog.morphAbility2.morph, dialog.morphAbility2.rank)
			dialog.morphAbility2.skillType = dialog.baseAbility.skillType
			dialog.morphAbility2.skillLineIndex = dialog.baseAbility.skillLineIndex
			dialog.morphAbility2.abilityIndex = dialog.baseAbility.abilityIndex
			dialog.morphAbility2.abilityLevel = ABILITY_LEVEL_LOWERMORPH
			dialog.morphAbility2.icon:SetTexture(morph2Icon)
			dialog.morphAbility2.selectedCallout:SetHidden(true)
			ZO_ActionSlot_SetUnusable(dialog.morphAbility2.icon, false)
			
			dialog.confirmButton:SetState(BSTATE_DISABLED)
			
			dialog.chosenSkillType = dialog.baseAbility.skillType
			dialog.chosenSkillLineIndex = dialog.baseAbility.skillLineIndex
			dialog.chosenAbilityIndex = dialog.baseAbility.abilityIndex
			dialog.chosenMorph = nil
			
		end
	end

	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_MORPH_ABILITY_CONFIRM",
	{
		customControl = manager.morphDialog,
		setup = SetupMorphAbilityConfirmDialog,
		title =
		{
			text = SI_SKILLS_MORPH_ABILITY,
		},
		buttons =
		{
			[1] =
			{
				control = GetControl(manager.morphDialog, "Confirm"),
				text =  SI_SKILLS_MORPH_CONFIRM,
				callback =  function(dialog)
					if dialog.chosenMorph then
						SuperStarSkills:MorphAbility(dialog.chosenSkillType, dialog.chosenSkillLineIndex, dialog.chosenAbilityIndex, dialog.chosenMorph)
					end
				end,
			},
			
			[2] =
			{
				control =   GetControl(manager.morphDialog, "Cancel"),
				text =	  SI_CANCEL,
			}
		}
	})

	manager.confirmDialog = GetControl("SuperStarXMLSkillsConfirmDialog")
	manager.confirmDialog.abilityName = GetControl(manager.confirmDialog, "AbilityName")
	manager.confirmDialog.ability = GetControl(manager.confirmDialog, "Ability")
	manager.confirmDialog.ability.icon = GetControl(manager.confirmDialog.ability, "Icon")

	local function SetupPurchaseAbilityConfirmDialog(dialog, abilityControl)
		local ability = abilityControl.ability
		local slot = abilityControl.ability.slot

		SetAbilityButtonTextures(dialog.ability, ability.passive)

		dialog.abilityName:SetText(ability.plainName)

		dialog.ability.skillType = abilityControl.skillType
		dialog.ability.skillLineIndex = abilityControl.skillLineIndex
		dialog.ability.abilityIndex = abilityControl.abilityIndex
		dialog.ability.abilityId = abilityControl.abilityId
		dialog.ability.abilityLevel = abilityControl.abilityLevel
		dialog.ability.icon:SetTexture(slot.iconFile)

		dialog.chosenSkillType = abilityControl.skillType
		dialog.chosenSkillLineIndex = abilityControl.skillLineIndex
		dialog.chosenAbilityIndex = abilityControl.abilityIndex		
	end

	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_PURCHASE_ABILITY_CONFIRM",
	{
		customControl = manager.confirmDialog,
		setup = SetupPurchaseAbilityConfirmDialog,
		title =
		{
			text = SI_SKILLS_CONFIRM_PURCHASE_ABILITY,
		},
		buttons =
		{
			[1] =
			{
				control =   GetControl(manager.confirmDialog, "Confirm"),
				text =	  SI_SKILLS_UNLOCK_CONFIRM,
				callback =  function(dialog)
					if dialog.chosenSkillType and dialog.chosenSkillLineIndex and dialog.chosenAbilityIndex then
						SuperStarSkills:PurchaseAbility(dialog.chosenSkillType, dialog.chosenSkillLineIndex, dialog.chosenAbilityIndex)
					end
				end,
			},
			[2] =
			{
			control =   GetControl(manager.confirmDialog, "Cancel"),
			text =	  SI_CANCEL,
			}
		}
	}) 

	manager.upgradeDialog = GetControl("SuperStarXMLSkillsUpgradeDialog")
	manager.upgradeDialog.desc = GetControl(manager.upgradeDialog, "Description")

	manager.upgradeDialog.baseAbility = GetControl(manager.upgradeDialog, "BaseAbility")
	manager.upgradeDialog.baseAbility.icon = GetControl(manager.upgradeDialog.baseAbility, "Icon")

	manager.upgradeDialog.upgradeAbility = GetControl(manager.upgradeDialog, "UpgradeAbility")
	manager.upgradeDialog.upgradeAbility.icon = GetControl(manager.upgradeDialog.upgradeAbility, "Icon")

	local function SetupUpgradeAbilityDialog(dialog, abilityControl)
	
		local ability = abilityControl.ability
		local slot = abilityControl.ability.slot
		
		dialog.desc:SetText(zo_strformat(SI_SKILLS_UPGRADE_DESCRIPTION, ability.plainName))

		SetAbilityButtonTextures(dialog.baseAbility, ability.passive)
		SetAbilityButtonTextures(dialog.upgradeAbility, ability.passive)

		dialog.baseAbility.skillType = abilityControl.skillType
		dialog.baseAbility.skillLineIndex = abilityControl.skillLineIndex
		dialog.baseAbility.abilityIndex = abilityControl.abilityIndex
		dialog.baseAbility.abilityId = abilityControl.abilityId
		dialog.baseAbility.abilityLevel = abilityControl.abilityLevel
		
		dialog.baseAbility.icon:SetTexture(slot.iconFile)
		
		local _, upgradeIcon = LSF:GetAbilityInfo(abilityControl.skillType, abilityControl.skillLineIndex, abilityControl.abilityIndex, ability.rank + 1)
		local nextAbilityId = LSF:GetAbilityId(abilityControl.skillType, abilityControl.skillLineIndex, abilityControl.abilityIndex, ability.rank + 1)
		
		dialog.upgradeAbility.skillType = abilityControl.skillType
		dialog.upgradeAbility.skillLineIndex = abilityControl.skillLineIndex
		dialog.upgradeAbility.abilityIndex = abilityControl.abilityIndex
		dialog.upgradeAbility.abilityId = nextAbilityId
		dialog.upgradeAbility.abilityLevel = abilityControl.abilityLevel + 1
		dialog.upgradeAbility.icon:SetTexture(upgradeIcon)

		dialog.chosenSkillType = abilityControl.skillType
		dialog.chosenSkillLineIndex = abilityControl.skillLineIndex
		dialog.chosenAbilityIndex = abilityControl.abilityIndex
		
	end

	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_UPGRADE_ABILITY_CONFIRM",
	{
		customControl = manager.upgradeDialog,
		setup = SetupUpgradeAbilityDialog,
		title =
		{
			text = SI_SKILLS_UPGRADE_ABILITY,
		},
		buttons =
		{
			[1] =
			{
				control = GetControl(manager.upgradeDialog, "Confirm"),
				text =  SI_SKILLS_UPGRADE_CONFIRM,
				callback =  function(dialog)
					if dialog.chosenSkillType and dialog.chosenSkillLineIndex and dialog.chosenAbilityIndex then
						SuperStarSkills:UpgradeAbility(dialog.chosenSkillType, dialog.chosenSkillLineIndex, dialog.chosenAbilityIndex)
					end
				end,
			},
			[2] =
			{
				control =   GetControl(manager.upgradeDialog, "Cancel"),
				text =	  SI_CANCEL,
			}
		}
	})
	
	local function Refresh()
		manager:Refresh()
	end
	
	local function OnSkillPointsChanged()
		manager:RefreshSkillInfo()
		manager:RefreshList()
	end
	
	container:RegisterForEvent(EVENT_SKILLS_FULL_UPDATE, Refresh)
	container:RegisterForEvent(EVENT_SKILL_POINTS_CHANGED, OnSkillPointsChanged)
	container:RegisterForEvent(EVENT_PLAYER_ACTIVATED, Refresh)
	
	return manager
	
end

function SuperStarSkills:SetupAbilityEntry(ability, data)
	
	local ALERT_TEXTURES =
	{
		[ZO_SKILLS_MORPH_STATE] = {normal = "EsoUI/Art/Progression/morph_up.dds", mouseDown = "EsoUI/Art/Progression/morph_down.dds", mouseover = "EsoUI/Art/Progression/morph_over.dds"},
		[ZO_SKILLS_PURCHASE_STATE] = {normal = "EsoUI/Art/Progression/addPoints_up.dds", mouseDown = "EsoUI/Art/Progression/addPoints_down.dds", mouseover = "EsoUI/Art/Progression/addPoints_over.dds"},
	}

	SetAbilityButtonTextures(ability.slot, data.passive)

	ability.name = data.name
	ability.plainName = data.plainName
	ability.nameLabel:SetText(data.name)
	
	-- To dialogs
	ability.alert.skillType = data.skillType
	ability.alert.skillLineIndex = data.skillLineIndex
	ability.alert.abilityIndex = data.abilityIndex
	ability.alert.abilityId = data.abilityId
	ability.alert.abilityLevel = data.abilityLevel
	ability.alert.rank = data.rank
	
	-- To this function
	ability.purchased = data.purchased
	ability.passive = data.passive
	ability.rank = data.rank
	ability.maxUpgradeLevel = data.maxUpgradeLevel
	
	-- To icon
	local slot = ability.slot
	slot.skillType = data.skillType
	slot.skillLineIndex = data.skillLineIndex
	slot.abilityIndex = data.abilityIndex
	slot.abilityId = data.abilityId
	--slot.abilityLevel = data.abilityLevel
	slot.icon:SetTexture(data.icon)
	slot.iconFile = data.icon

	ability:ClearAnchors()
	
	if (not ability.passive) then
		ability.atMorph = true
	else
		ability.atMorph = false
		ability.upgradeAvailable = false
		if (ability.maxUpgradeLevel) then
			ability.upgradeAvailable = ability.rank < ability.maxUpgradeLevel
		end
	end
	
	ability.nameLabel:SetAnchor(LEFT, ability.slot, RIGHT, 10, 0)
	
	if ability.purchased then
		
		slot:SetEnabled(true)
		ZO_ActionSlot_SetUnusable(slot.icon, false)
		ability.nameLabel:SetColor(PURCHASED_COLOR:UnpackRGBA())
		
		if ability.atMorph and SUPERSTAR_SKILLS_WINDOW.availablePoints > 0 then
			ability.alert:SetHidden(false)
			ability.lock:SetHidden(true)
			ZO_Skills_SetAlertButtonTextures(ability.alert, ALERT_TEXTURES[ZO_SKILLS_MORPH_STATE])
		elseif not ability.maxUpgradeLevel then
			ability.alert:SetHidden(true)
			ability.lock:SetHidden(true)
		elseif ability.upgradeAvailable and SUPERSTAR_SKILLS_WINDOW.availablePoints > 0 then
			ability.alert:SetHidden(false)
			ability.lock:SetHidden(true)
			ZO_Skills_SetAlertButtonTextures(ability.alert, ALERT_TEXTURES[ZO_SKILLS_PURCHASE_STATE])
		else
			ability.alert:SetHidden(true)
			ability.lock:SetHidden(true)
		end
		
	else
		
		slot:SetEnabled(false)
		ZO_ActionSlot_SetUnusable(slot.icon, true)
		ability.nameLabel:SetColor(UNPURCHASED_COLOR:UnpackRGBA())
		ability.lock:SetHidden(true)
		
		if SUPERSTAR_SKILLS_WINDOW.availablePoints > 0 then
			ability.alert:SetHidden(false)
			ZO_Skills_SetAlertButtonTextures(ability.alert, ALERT_TEXTURES[ZO_SKILLS_PURCHASE_STATE])
		else
			ability.alert:SetHidden(true)
		end
			
	end
end

function SuperStarSkills:SetupHeaderEntry(header, data)
	local label = GetControl(header, "Label")

	if data.passive then
		label:SetText(GetString(SI_SKILLS_PASSIVE_ABILITIES))
	elseif data.ultimate then
		label:SetText(GetString(SI_SKILLS_ULTIMATE_ABILITIES))
	else
		label:SetText(GetString(SI_SKILLS_ACTIVE_ABILITIES))
	end
end

function SuperStarSkills:RefreshList()

	if SUPERSTAR_SKILLS_WINDOW.container:IsHidden() then
		SUPERSTAR_SKILLS_WINDOW.dirty = true
		return
	end

	local skillType = SuperStarSkills:GetSelectedSkillType()
	local skillLineIndex = SuperStarSkills:GetSelectedSkillLineIndex()
	
	SuperStarSkills.scrollData = ZO_ScrollList_GetDataList(SUPERSTAR_SKILLS_WINDOW.abilityList)
	ZO_ScrollList_Clear(SUPERSTAR_SKILLS_WINDOW.abilityList)
	SUPERSTAR_SKILLS_WINDOW.displayedAbilityProgressions = {}
	
	local numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
	
	local foundFirstActive = false
	local foundFirstPassive = false
	local foundFirstUltimate = false
	
	for abilityIndex=1, numAbilities do
		
		local abilityType, maxUpgradeLevel = LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex)
		
		local passive, ultimate
		if abilityType == ABILITY_TYPE_ULTIMATE then
			passive = false
			ultimate = true
		elseif abilityType == ABILITY_TYPE_ACTIVE	then
			passive = false
			ultimate = false
		elseif abilityType == ABILITY_TYPE_PASSIVE then
			passive = true
			ultimate = false
		end
		
		local abilityId, earnedRank, icon, rank, name, plainName, abilityLevel
		abilityLevel = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel
		
		if (not passive) then
			rank = 4
			earnedRank, icon = LSF:GetAbilityInfo(skillType, skillLineIndex, abilityIndex, abilityLevel)
			abilityId = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, abilityLevel, rank)
			name = GetAbilityName(abilityId)
			plainName = zo_strformat(SI_ABILITY_NAME, name)
			name = SuperStarSkills:GenerateAbilityName(name, rank, maxUpgradeLevel, abilityType)
		else
			
			if SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn == 0 then
				rank = 1
			else
				rank = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel
			end
			
			earnedRank, icon = LSF:GetAbilityInfo(skillType, skillLineIndex, abilityIndex, rank)
			abilityId = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, rank)
			name = GetAbilityName(abilityId)
			plainName = zo_strformat(SI_ABILITY_NAME, name)
			name = SuperStarSkills:GenerateAbilityName(name, SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel, maxUpgradeLevel, abilityType)
		end
		
		local isActive = (not passive and not ultimate)
		local isUltimate = (not passive and ultimate)
		
		local addHeader = (isActive and not foundFirstActive) or (passive and not foundFirstPassive) or (isUltimate and not foundFirstUltimate)
		if addHeader then
			table.insert(SuperStarSkills.scrollData, ZO_ScrollList_CreateDataEntry(SKILL_HEADER_DATA,  {
				passive = passive,
				ultimate = isUltimate
			}))
		end
		
		foundFirstActive = foundFirstActive or isActive
		foundFirstPassive = foundFirstPassive or passive
		foundFirstUltimate = foundFirstUltimate or isUltimate
		
		table.insert(SuperStarSkills.scrollData, ZO_ScrollList_CreateDataEntry(SKILL_ABILITY_DATA,  {
			skillType = skillType,
			skillLineIndex = skillLineIndex,
			abilityIndex = abilityIndex,
			abilityId = abilityId,
			abilityLevel = abilityLevel,
			plainName = plainName,
			name = name,
			icon = icon,
			earnedRank = earnedRank,
			passive = passive,
			ultimate = ultimate,
			purchased = SuperStarSkills:GetPurchasedFromInternalFactoryForBuilder(skillType, skillLineIndex, abilityIndex, true),
			rank = rank,
			maxUpgradeLevel = maxUpgradeLevel,
		}))
	end
	
	ZO_ScrollList_Commit(SUPERSTAR_SKILLS_WINDOW.abilityList)
	
end

function SuperStarSkills:GetPurchasedFromInternalFactoryForBuilder(skillType, skillLineIndex, abilityIndex)

	if SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn == 0 then
		return false
	else
		return true
	end

end

function SuperStarSkills:InitInternalFactoryForBuilder()

	SuperStarSkills.builderFactory = {}
	for skillType = 1, SKILLTYPES_IN_SKILLBUILDER do
		SuperStarSkills.builderFactory[skillType] = {}
		for skillLineIndex = 1, LSF:GetNumSkillLines(skillType) do
			SuperStarSkills.builderFactory[skillType][skillLineIndex] = {}
			for abilityIndex=1, LSF:GetNumSkillAbilities(skillType, skillLineIndex) do
				SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex] = {}
				
				if SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex) == 1 then
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = 1
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = 0
				else
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
				end
				
			end
		end
	end

end

function SuperStarSkills:GenerateAbilityName(name, currentUpgradeLevel, maxUpgradeLevel, abilityType)
	if currentUpgradeLevel and maxUpgradeLevel and maxUpgradeLevel > 1 then
		return zo_strformat(SI_ABILITY_NAME_AND_UPGRADE_LEVELS, name, currentUpgradeLevel, maxUpgradeLevel)
	elseif abilityType ~= ABILITY_TYPE_PASSIVE then
		if currentUpgradeLevel then
			return zo_strformat(SI_ABILITY_NAME_AND_RANK, name, currentUpgradeLevel)
		end
	end
	
	return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, name)
end

function SuperStarSkills:RefreshSkillInfo()
	
	if SUPERSTAR_SKILLS_WINDOW.container:IsHidden() then
		SUPERSTAR_SKILLS_WINDOW.dirty = true
		return
	end
	
	SUPERSTAR_SKILLS_WINDOW.availablePoints = SuperStarSkills.spentSkillPoints
	SUPERSTAR_SKILLS_WINDOW.availablePointsLabel:SetText(zo_strformat(SI_SKILLS_POINTS_TO_SPEND, SUPERSTAR_SKILLS_WINDOW.availablePoints))
	
end

function SuperStarSkills:GetAvailableSkillPoints()
	
	local skillPoints = 0
	
	-- SkillTypes (class, etc)
	for skillType=1, SKILLTYPES_IN_SKILLBUILDER do
		
		-- SkillLine (Bow, etc)
		for skillLineIndex=1, GetNumSkillLines(skillType) do
			
			for abilityIndex=1, GetNumSkillAbilities(skillType, skillLineIndex) do
				skillPoints = skillPoints + SuperStarSkills:GetPointsSpentInAbility(skillType, skillLineIndex, abilityIndex)
			end
			
		end
		
	end
	
	SuperStarSkills.spentSkillPoints = skillPoints + GetAvailableSkillPoints()
	
	return SuperStarSkills.spentSkillPoints
	
end

function SuperStarSkills:GetPointsSpentInAbility(skillType, skillLineIndex, abilityIndex)
	
	local _, _, _, _, _, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
	
	if not purchased then
		return 0
	elseif progressionIndex then
		
		-- Active skills
		
		-- Skill has been purchased
		local _, morph = GetAbilityProgressionInfo(progressionIndex)
		local skillLineName = GetSkillLineInfo(skillType, skillLineIndex)
		if morph > ABILITY_LEVEL_NONMORPHED then
			return (2 - SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, skillLineName, abilityIndex))
		else
			return (1 - SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, skillLineName, abilityIndex))
		end
		
	else
	
		-- Passive skills
		local currentUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, abilityIndex)
		
		local skillLineName = GetSkillLineInfo(skillType, skillLineIndex)
		if currentUpgradeLevel then
			return (currentUpgradeLevel - SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, skillLineName, abilityIndex))
		else
			return (1 - SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, skillLineName, abilityIndex))
		end
		
	end
	
end

function SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, skillLineName, abilityIndex)

	-- Using SkillLines because thoses skilllines can or cannot be unlocked
	
	local exceptionList = {}
	
	exceptionList[SKILL_TYPE_WORLD] = {}
	exceptionList[SKILL_TYPE_WORLD][2] = {}
	exceptionList[SKILL_TYPE_WORLD][2][2] = true -- Soul Magic SoulTrap
	exceptionList[SKILL_TYPE_WORLD][4] = {}
	exceptionList[SKILL_TYPE_WORLD][4][1] = true -- WW Ultimate
	
	exceptionList[SKILL_TYPE_GUILD] = {}
	exceptionList[SKILL_TYPE_GUILD][1] = {}
	exceptionList[SKILL_TYPE_GUILD][1][1] = true -- Blade of Woe
	exceptionList[SKILL_TYPE_GUILD][4] = {}
	exceptionList[SKILL_TYPE_GUILD][4][1] = true -- Finders keepers
	
	exceptionList[SKILL_TYPE_RACIAL] = {}
	exceptionList[SKILL_TYPE_RACIAL][1] = {}
	exceptionList[SKILL_TYPE_RACIAL][1][1] = true -- 1st Racial passive
	
	exceptionList[SKILL_TYPE_TRADESKILL] = {}
	
	exceptionList[SKILL_TYPE_TRADESKILL][1] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][1][1] = true -- 1st Alchemy passive
	
	exceptionList[SKILL_TYPE_TRADESKILL][4] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][4][1] = true -- 1st Enchanting passive
	exceptionList[SKILL_TYPE_TRADESKILL][4][2] = true -- 2nd Enchanting passive
	
	exceptionList[SKILL_TYPE_TRADESKILL][6] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][6][1] = true -- 1st Woodworking passive
	
	local _, blackSmithing = GetCraftingSkillLineIndices(CRAFTING_TYPE_BLACKSMITHING)
	if blackSmithing == 5 then -- FR, DE
		exceptionList[SKILL_TYPE_TRADESKILL][2] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][2][1] = true -- 1st Clothing passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][3] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][3][1] = true -- 1st Provisionning passive
		exceptionList[SKILL_TYPE_TRADESKILL][3][2] = true -- 2nd Provisionning passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][5] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][5][1] = true -- 1st Blacksmithing passive
	else
		exceptionList[SKILL_TYPE_TRADESKILL][3] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][3][1] = true -- 1st Clothing passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][5] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][5][1] = true -- 1st Provisionning passive
		exceptionList[SKILL_TYPE_TRADESKILL][5][2] = true -- 2nd Provisionning passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][2] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][2][1] = true -- 1st Blacksmithing passive
	end
	
	local skillLineConverter = {
		[LSF:GetSkillLineInfo(SKILL_TYPE_WORLD, 2)] = 2,
		[LSF:GetSkillLineInfo(SKILL_TYPE_WORLD, 4)] = 4,
		
		[LSF:GetSkillLineInfo(SKILL_TYPE_GUILD, 1)] = 1,
		[LSF:GetSkillLineInfo(SKILL_TYPE_GUILD, 4)] = 4,
	}
	
	if exceptionList[skillType] then
		if skillType == SKILL_TYPE_GUILD or skillType == SKILL_TYPE_WORLD then
			skillLineName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, skillLineName)
			if exceptionList[skillType][skillLineConverter[skillLineName]] then
				if exceptionList[skillType][skillLineConverter[skillLineName]][abilityIndex] then
					return 1
				end
			end
		else
			if exceptionList[skillType][skillLineIndex] then
				if exceptionList[skillType][skillLineIndex][abilityIndex] then
					return 1
				end
			end
		end
	end
	
	return 0
	
end

function SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)

	local exceptionList = {}
	
	exceptionList[SKILL_TYPE_WORLD] = {}
	exceptionList[SKILL_TYPE_WORLD][2] = {}
	exceptionList[SKILL_TYPE_WORLD][2][2] = true -- Soul trap
	exceptionList[SKILL_TYPE_WORLD][4] = {}
	exceptionList[SKILL_TYPE_WORLD][4][1] = true -- Wereform morph
	
	exceptionList[SKILL_TYPE_GUILD] = {}
	exceptionList[SKILL_TYPE_GUILD][1] = {}
	exceptionList[SKILL_TYPE_GUILD][1][1] = true -- Blade of Woe
	exceptionList[SKILL_TYPE_GUILD][4] = {}
	exceptionList[SKILL_TYPE_GUILD][4][1] = true -- Finders keepers
	
	exceptionList[SKILL_TYPE_RACIAL] = {}
	exceptionList[SKILL_TYPE_RACIAL][1] = {}
	exceptionList[SKILL_TYPE_RACIAL][1][1] = true -- 1st racial passive
	
	exceptionList[SKILL_TYPE_TRADESKILL] = {}
	
	exceptionList[SKILL_TYPE_TRADESKILL][1] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][1][1] = true -- 1st Alchemy passive
	
	exceptionList[SKILL_TYPE_TRADESKILL][4] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][4][1] = true -- 1st Enchanting passive
	exceptionList[SKILL_TYPE_TRADESKILL][4][2] = true -- 2nd Enchanting passive
	
	exceptionList[SKILL_TYPE_TRADESKILL][6] = {}
	exceptionList[SKILL_TYPE_TRADESKILL][6][1] = true -- 1st Woodworking passive
	
	local _, blackSmithing = GetCraftingSkillLineIndices(CRAFTING_TYPE_BLACKSMITHING)
	if blackSmithing == 5 then -- FR, DE
		exceptionList[SKILL_TYPE_TRADESKILL][2] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][2][1] = true -- 1st Clothing passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][3] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][3][1] = true -- 1st Provisionning passive
		exceptionList[SKILL_TYPE_TRADESKILL][3][2] = true -- 2nd Provisionning passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][5] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][5][1] = true -- 1st Blacksmithing passive
	else
		exceptionList[SKILL_TYPE_TRADESKILL][3] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][3][1] = true -- 1st Clothing passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][5] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][5][1] = true -- 1st Provisionning passive
		exceptionList[SKILL_TYPE_TRADESKILL][5][2] = true -- 2nd Provisionning passive
		
		exceptionList[SKILL_TYPE_TRADESKILL][2] = {}
		exceptionList[SKILL_TYPE_TRADESKILL][2][1] = true -- 1st Blacksmithing passive
	end
	
	if exceptionList[skillType] then
		if exceptionList[skillType][skillLineIndex] then
			if exceptionList[skillType][skillLineIndex][abilityIndex] then
				return 1
			end
		end
	end
	
	return 0
	
end

function SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)

	local exceptionList = {}
	
	exceptionList[SKILL_TYPE_WORLD] = {}
	exceptionList[SKILL_TYPE_WORLD][2] = {}
	exceptionList[SKILL_TYPE_WORLD][2][2] = true -- Soul trap
	exceptionList[SKILL_TYPE_WORLD][4] = {}
	exceptionList[SKILL_TYPE_WORLD][4][1] = true -- Wereform morph
	
	if exceptionList[skillType] then
		if exceptionList[skillType][skillLineIndex] then
			if exceptionList[skillType][skillLineIndex][abilityIndex] then
				return 1
			end
		end
	end
	
	return 0

end

function SuperStarSkills:ConvertExceptionsPointsSpentInAbility(skillType, skillLineIndex, abilityIndex, builder)
	
	if builder then
		if SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex) == 1 then
			return true
		else
			return false
		end

	else
		if SuperStarSkills:GetExceptionsPointsSpentInAbility(skillType, skillLineIndex, abilityIndex) == 1 then
			return true
		else
			return false
		end
	end
	
end

function SuperStarSkills:GetSelectedSkillType()
	local selectedData = SUPERSTAR_SKILLS_WINDOW.navigationTree:GetSelectedData()
	if selectedData then
		return selectedData.skillType
	end
end

function SuperStarSkills:GetSelectedSkillLineIndex()
	local selectedData = SUPERSTAR_SKILLS_WINDOW.navigationTree:GetSelectedData()
	if selectedData then
		return selectedData.skillLineIndex
	end
end

function SuperStarSkills:Refresh()

	local skillTypeToSound =
	{
		[SKILL_TYPE_CLASS] = SOUNDS.SKILL_TYPE_CLASS,
		[SKILL_TYPE_WEAPON] = SOUNDS.SKILL_TYPE_WEAPON,
		[SKILL_TYPE_ARMOR] = SOUNDS.SKILL_TYPE_ARMOR,
		[SKILL_TYPE_WORLD] = SOUNDS.SKILL_TYPE_WORLD,
		[SKILL_TYPE_GUILD] = SOUNDS.SKILL_TYPE_GUILD,
		[SKILL_TYPE_AVA] = SOUNDS.SKILL_TYPE_AVA,
		[SKILL_TYPE_RACIAL] = SOUNDS.SKILL_TYPE_RACIAL,
		[SKILL_TYPE_TRADESKILL] = SOUNDS.SKILL_TYPE_TRADESKILL,
	}

	if SUPERSTAR_SKILLS_WINDOW.container:IsHidden() then
		SUPERSTAR_SKILLS_WINDOW.dirty = true
		return
	end

	SUPERSTAR_SKILLS_WINDOW.navigationTree:Reset()
	for skillType = 1, SKILLTYPES_IN_SKILLBUILDER do
		local numSkillLines = LSF:GetNumSkillLines(skillType)
		if numSkillLines > 0 then
			local parent = SUPERSTAR_SKILLS_WINDOW.navigationTree:AddNode("ZO_IconHeader", skillType, nil, skillTypeToSound[skillType])
			for skillLineIndex = 1, numSkillLines do
				if LSF:GetNumSkillAbilities(skillType, skillLineIndex) > 0 then -- Handle an Empty SkillLine (removed)
					local node = SUPERSTAR_SKILLS_WINDOW.navigationTree:AddNode("SuperStarXMLSkillsNavigationEntry", { skillType = skillType, skillLineIndex = skillLineIndex }, parent, SOUNDS.SKILL_LINE_SELECT)
				end
			end
		end
	end

	SUPERSTAR_SKILLS_WINDOW.navigationTree:Commit()

	SuperStarSkills:RefreshSkillInfo()
	SuperStarSkills:RefreshList()

end

function SuperStarSkills:GetNumSkillAbilitiesForBuilder(skillType, skillLineIndex)
	
	if SuperStarSkills.builderFactory[skillType][skillLineIndex] then
		return #SuperStarSkills.builderFactory[skillType][skillLineIndex]
	end
	
	return 0
	
end

function SuperStarSkills:OnShown()
	if SUPERSTAR_SKILLS_WINDOW.dirty then
		SuperStarSkills:Refresh()
	end
end

function SuperStarSkills:PurchaseAbility(skillType, skillLineIndex, abilityIndex)
	
	SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = 1
	
	if LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex) == ABILITY_TYPE_PASSIVE then 
		SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = 1
	end
	
	SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints - 1
	
	SuperStarSkills:RefreshSkillInfo()
	SuperStarSkills:RefreshList()
	
end

function SuperStarSkills:UpgradeAbility(skillType, skillLineIndex, abilityIndex)
	
	SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn + 1
	SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel + 1
	SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints - 1
	
	SuperStarSkills:RefreshSkillInfo()
	SuperStarSkills:RefreshList()
	
end

function SuperStarSkills:MorphAbility(skillType, skillLineIndex, abilityIndex, morphChoiceIndex)

	if SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel == ABILITY_LEVEL_NONMORPHED then
		SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn + 1
		SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints - 1
	end
	
	SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = morphChoiceIndex
	
	SuperStarSkills:RefreshSkillInfo()
	SuperStarSkills:RefreshList()
	
end

-- Called by Keybind
local function ResetSkillBuilder()

	if SuperStarSkills.pendingCPDataForBuilder or SuperStarSkills.pendingAttrDataForBuilder then
		ZO_Dialogs_ShowDialog("SUPERSTAR_REINIT_SKILLBUILDER_WITH_ATTR_CP")
	else

		SuperStarSkills:InitInternalFactoryForBuilder()
		SuperStarSkills:GetAvailableSkillPoints(true)
		SuperStarSkills:Refresh()
		
		SUPERSTAR_SKILLS_SCENE:RemoveFragment(SUPERSTAR_SKILLS_BUILDERWINDOW)
		SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_PRESELECTORWINDOW)
	end
	
end

-- Called by XML
function SuperStar_AbilityAlert_OnClicked(control)
	if not control.ability.purchased then
		ZO_Dialogs_ShowDialog("SUPERSTAR_PURCHASE_ABILITY_CONFIRM", control)
	elseif control.ability.atMorph then
		ZO_Dialogs_ShowDialog("SUPERSTAR_MORPH_ABILITY_CONFIRM", control)
	elseif control.ability.upgradeAvailable then
		ZO_Dialogs_ShowDialog("SUPERSTAR_UPGRADE_ABILITY_CONFIRM", control)
	end
end

-- Called by XML
function SuperStar_AbilitySlot_OnMouseEnter(control)

	local abilityId = control.abilityId
	local skillType = control.skillType
	local skillLineIndex = control.skillLineIndex
	local abilityIndex = control.abilityIndex
	local abilityLevel = control.abilityLevel
	
	if(DoesAbilityExist(abilityId)) then
		
		local abilityName = GetAbilityName(abilityId)
		
		InitializeTooltip(SuperStarAbilityTooltip, control, TOPLEFT, 5, -5, TOPRIGHT)
		SuperStarAbilityTooltip:SetAbilityId(abilityId)

		if abilityLevel then
			local abilityIdRank1 = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, abilityLevel, 1)
			local newEffectLine = GetAbilityNewEffectLines(abilityIdRank1)
			
			if(newEffectLine and newEffectLine ~= "") then
				
				local r, g, b = unpack({0, 1, 0})
				SuperStarAbilityTooltip:AddLine(GetString(SI_ABILITY_TOOLTIP_NEW_EFFECT), "ZoFontWinT2", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_UPPERCASE, TEXT_ALIGN_CENTER, true)
				SuperStarAbilityTooltip:AddLine(newEffectLine, "ZoFontGame", r, g, b, TOPLEFT, MODIFY_TEXT_TYPE_NONE, TEXT_ALIGN_CENTER, true)
				
			end
		end
		
	end

end

function SuperStarSkills:GetAbilityFullDesc(abilityId)

	local fullDesc = ""
	
	if(DoesAbilityExist(abilityId)) then
		
		local abilityName = GetAbilityName(abilityId)
		fullDesc = fullDesc .. zo_strformat(SI_ABILITY_TOOLTIP_NAME, abilityName) .. ": "
		
		if(not IsAbilityPassive(abilityId)) then

			local channeled, castTime, channelTime = GetAbilityCastInfo(abilityId)
			if(channeled) then
				fullDesc = fullDesc .. "Chan:" .. string.gsub(ZO_FormatTimeMilliseconds(channelTime, TIME_FORMAT_STYLE_CHANNEL_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE):gsub("%s", ""), "%a+", "s")
			else
				if castTime == 0 then
					fullDesc = fullDesc .. "Instant"
				else
					fullDesc = fullDesc .. "Cast:" .. string.gsub(ZO_FormatTimeMilliseconds(castTime, TIME_FORMAT_STYLE_CAST_TIME, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE):gsub("%s", ""), "%a+", "s")
				end
			end
			
			local targetDescription = GetAbilityTargetDescription(abilityId)
			
			if(targetDescription) then
				
				-- Zone, Area, Fläche = Zone (PBAoE)
				-- Cible, Enemy, Feind = Cible (Mono)
				-- Sol, Ground, Bodenziel = Sol (GTAoE)
				-- Vous-même, Self, Eigener Charakter = Self
				-- Cône, Cone, Kegel = CAoE
				
				if targetDescription == "Zone" or targetDescription == "Area" or targetDescription == "Fläche" then
					fullDesc = fullDesc .. "/PBAoE"
				elseif targetDescription == "Ennemi" or targetDescription == "Enemy" or targetDescription == "Feind" then
					fullDesc = fullDesc .. "/Mono"
				elseif targetDescription == "Sol" or targetDescription == "Ground" or targetDescription == "Bodenziel" then
					fullDesc = fullDesc .. "/GTAoE"
				elseif targetDescription == "Vous-même" or targetDescription == "Self" or targetDescription == "Eigener Charakter" then
					fullDesc = fullDesc .. "/Self"
				elseif targetDescription == "Cône" or targetDescription == "Cone" or targetDescription == "Kegel" then
					fullDesc = fullDesc .. "/CAoE"
				end
				
			end
			
			local minRange, maxRange = GetAbilityRange(abilityId)
			if(maxRange > 0) then
				if(minRange == 0) then
					fullDesc = fullDesc ..  "/Range:" .. string.gsub(zo_strformat(SI_ABILITY_TOOLTIP_RANGE, FormatFloatRelevantFraction(maxRange / 100)):gsub("è", ""):gsub("%s", ""), "%a+", "m")
				else
					fullDesc = fullDesc ..  "/Range:" .. string.gsub(zo_strformat(SI_ABILITY_TOOLTIP_MIN_TO_MAX_RANGE, FormatFloatRelevantFraction(minRange / 100), FormatFloatRelevantFraction(maxRange / 100)):gsub("è", ""):gsub("%s", ""), "%a+", "m")
				end
			end
			
			local radius = GetAbilityRadius(abilityId)
			local distance = GetAbilityAngleDistance(abilityId)
			if(radius > 0) then
				if(distance > 0) then
					fullDesc = fullDesc ..  "/AOE:" .. string.gsub(zo_strformat(SI_ABILITY_TOOLTIP_AOE_DIMENSIONS, FormatFloatRelevantFraction(radius / 100), FormatFloatRelevantFraction(distance / 100)):gsub("è", ""):gsub("%s", ""), "%a+", "m")
				else
					fullDesc = fullDesc ..  "/Radius:" .. string.gsub(zo_strformat(SI_ABILITY_TOOLTIP_RADIUS, FormatFloatRelevantFraction(radius / 100)):gsub("è", ""):gsub("%s", ""), "%a+", "m")
				end
			end
			
			local duration = GetAbilityDuration(abilityId)
			if(duration > 0) then
				fullDesc = fullDesc ..  "/Dur:" .. string.gsub(ZO_FormatTimeMilliseconds(duration, TIME_FORMAT_STYLE_DURATION, TIME_FORMAT_PRECISION_TENTHS_RELEVANT, TIME_FORMAT_DIRECTION_NONE):gsub("%s", ""), "%a+", "s")
			end
		
		end
		
		local descriptionHeader = GetAbilityDescriptionHeader(abilityId)
		local description = GetChampionAbilityDescription(abilityId)
		
		if(descriptionHeader ~= "" or description ~= "") then
			
			if(descriptionHeader ~= "") then
				fullDesc = fullDesc .. " " .. zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION_HEADER, descriptionHeader)
			end
			
			if(description ~= "") then
				fullDesc = fullDesc .. " " .. zo_strformat(SI_ABILITY_TOOLTIP_DESCRIPTION, description)
			end
			
		end
		
	end
	
	return fullDesc:gsub("|[cC]%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("\r\n", " "):gsub("  ", " ")

end

-- Called by XML
function SuperStar_AbilitySlot_OnMouseExit()
	ClearTooltip(SuperStarAbilityTooltip)
end

-- Called by XML
function SuperStarSkillsMorphAbilitySlot_OnClicked(control)
	SuperStarSkills:ChooseMorph(control)
end

function SuperStarSkills:SetMorphButtonTextures(button, chosen)
	if chosen then
		ZO_ActionSlot_SetUnusable(button.icon, false)
		button.selectedCallout:SetHidden(false)
	else
		ZO_ActionSlot_SetUnusable(button.icon, true)
		button.selectedCallout:SetHidden(true)
	end
end

function SuperStarSkills:ChooseMorph(morphSlot)
	if morphSlot then
	
		SUPERSTAR_SKILLS_WINDOW.morphDialog.chosenMorph = morphSlot.morph
		
		if morphSlot == SUPERSTAR_SKILLS_WINDOW.morphDialog.morphAbility1 then
			SuperStarSkills:SetMorphButtonTextures(SUPERSTAR_SKILLS_WINDOW.morphDialog.morphAbility1, true)
			SuperStarSkills:SetMorphButtonTextures(SUPERSTAR_SKILLS_WINDOW.morphDialog.morphAbility2, false)
		else
			SuperStarSkills:SetMorphButtonTextures(SUPERSTAR_SKILLS_WINDOW.morphDialog.morphAbility1, false)
			SuperStarSkills:SetMorphButtonTextures(SUPERSTAR_SKILLS_WINDOW.morphDialog.morphAbility2, true)
		end

		SUPERSTAR_SKILLS_WINDOW.morphDialog.confirmButton:SetState(BSTATE_NORMAL)
		
	end
end

-- Called by XML
function SuperStarSkills:InitializePreSelector()
	
	local classId = GetUnitClassId("player")
	SuperStarXMLSkillsPreSelector:GetNamedChild("Class" .. classId):SetState(BSTATE_PRESSED, false)
	SuperStarSkills.class = classId
	
	local raceId = GetUnitRaceId("player")
	SuperStarXMLSkillsPreSelector:GetNamedChild("Race" .. raceId):SetState(BSTATE_PRESSED, false)
	SuperStarSkills.race = raceId
	
	local availablePointsForChar = SuperStarSkills:GetAvailableSkillPoints(true)
	
	SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetText(availablePointsForChar)
	SuperStarSkills.spentSkillPoints = availablePointsForChar
	SuperStarSkills.availableSkillsPointsForBuilder = availablePointsForChar
	
end

-- Called by XML
function SuperStarSkills_OnClickedAbility(control, button)
	
	if button == MOUSE_BUTTON_INDEX_LEFT then
		-- Display ability in chat
		if CHAT_SYSTEM.textEntry:GetText() == "" then
			local abilityFullDesc = SuperStarSkills:GetAbilityFullDesc(control.abilityId)
			if string.len(abilityFullDesc) > 347 then
				abilityFullDesc = string.sub(abilityFullDesc, 0, 347) .. " .."
			end
			CHAT_SYSTEM.textEntry:Open(abilityFullDesc)
			ZO_ChatWindowTextEntryEditBox:SelectAll()
		end
	elseif button == MOUSE_BUTTON_INDEX_MIDDLE then
		
		local skillType = control.skillType
		local skillLineIndex = control.skillLineIndex
		local abilityIndex = control.abilityIndex
		
		local abilityType, maxRank = LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex)
		
		if not maxRank then
			maxRank = 1
		end
		
		local actualRank = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn
		
		if abilityType == ABILITY_TYPE_PASSIVE and actualRank < maxRank and SuperStarSkills.spentSkillPoints >= (maxRank - actualRank) then
		
			SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = maxRank
			SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = maxRank
			SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints - (maxRank - actualRank)
			
			SuperStarSkills:RefreshSkillInfo()
			SuperStarSkills:RefreshList()
		
		end
		
	elseif button == MOUSE_BUTTON_INDEX_RIGHT then
		
		local skillType = control.skillType
		local skillLineIndex = control.skillLineIndex
		local abilityIndex = control.abilityIndex
		
		-- Remove it from Skill Builder
		local oldSpentIn = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn
		if oldSpentIn >= 1 then
			
			local isException = SuperStarSkills:ConvertExceptionsPointsSpentInAbility(skillType, skillLineIndex, abilityIndex, true)
			
			if isException and oldSpentIn > 1 then
				
				local exceptionPoints = SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
				SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = exceptionPoints
				
				if LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex) ~= ABILITY_TYPE_PASSIVE then
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = ABILITY_LEVEL_NONMORPHED
				else
					SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = 1
				end
				
				SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints + oldSpentIn - exceptionPoints
				SuperStarSkills:RefreshSkillInfo()
				SuperStarSkills:RefreshList()
				
			elseif isException == false then
			
				SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn = 0
				SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel = ABILITY_LEVEL_NONMORPHED
				SuperStarSkills.spentSkillPoints = SuperStarSkills.spentSkillPoints + oldSpentIn
				
				SuperStarSkills:RefreshSkillInfo()
				SuperStarSkills:RefreshList()
				
			end
			
		end
		
	end

end

-- Called by XML
function SuperStarSkills_ChangeSP(delta)

	local displayedValue = SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):GetText()
	
	if displayedValue ~= "" then
		local value = tonumber(displayedValue)
		value = value + delta
		
		if value < 0 then value = 0 end
		if value > SP_MAX_SPENDABLE_POINTS then value = SP_MAX_SPENDABLE_POINTS end
		
		SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetText(value)
		SuperStarSkills.spentSkillPoints = value
		SuperStarSkills.availableSkillsPointsForBuilder = value
		
		if value < SuperStarSkills.availableSkillsPoints then
			SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetColor(0, 1, 0, 1)
		elseif value > SuperStarSkills.availableSkillsPoints then
			SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetColor(1, 0, 0, 1)
		else
			SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetColor(1, 1, 1, 1)
		end
		
	else
		SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetText(SuperStarSkills.availableSkillsPoints)
		SuperStarSkills.spentSkillPoints = SuperStarSkills.availableSkillsPoints
		SuperStarSkills.availableSkillsPointsForBuilder = SuperStarSkills.availableSkillsPoints
	end

end

-- Called by XML
function SuperStar_SetSkillBuilderRace(control, raceId)

	control:SetState(BSTATE_PRESSED, false)
	SuperStarSkills.race = raceId
	
	for button=1, 10 do
		if button ~= raceId then
			SuperStarXMLSkillsPreSelector:GetNamedChild("Race" .. button):SetState(BSTATE_NORMAL, false)
		end
	end
	
end

-- Called by XML
function SuperStar_SkillBuilderPreselector_HoverClass(control, classId)
	InitializeTooltip(InformationTooltip, control, BOTTOM, 5, -5)
	InformationTooltip:AddLine(zo_strformat(SI_CLASS_NAME, GetClassName(GetUnitGender("player"), classId)))
end

-- Called by XML
function SuperStar_SkillBuilderPreselector_ExitClass()
	ClearTooltip(InformationTooltip)
end

-- Called by XML
function SuperStar_SkillBuilderPreselector_HoverRace(control, raceId)
	InitializeTooltip(InformationTooltip, control, BOTTOM, 5, -5)
	InformationTooltip:AddLine(LSF.skillSubFactory[SKILL_TYPE_RACIAL][raceId].name)
end

-- Called by XML
function SuperStar_SkillBuilderPreselector_ExitRace()
	ClearTooltip(InformationTooltip)
end

-- Called by XML
function SuperStar_SetSkillBuilderClass(control, classId)

	control:SetState(BSTATE_PRESSED, false)
	SuperStarSkills.class = classId
	
	if classId == CLASS_DRAGONKNIGHT then
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class2"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class3"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class4"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class6"):SetState(BSTATE_NORMAL, false)
	elseif classId == CLASS_SORCERER then
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class1"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class3"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class4"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class6"):SetState(BSTATE_NORMAL, false)
	elseif classId == CLASS_NIGHTBLADE then
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class1"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class2"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class4"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class6"):SetState(BSTATE_NORMAL, false)
	elseif classId == CLASS_TEMPLAR then
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class1"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class2"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class3"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class4"):SetState(BSTATE_NORMAL, false)
	elseif classId == CLASS_WARDEN then
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class1"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class2"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class3"):SetState(BSTATE_NORMAL, false)
		SuperStarXMLSkillsPreSelector:GetNamedChild("Class6"):SetState(BSTATE_NORMAL, false)
	end
	
	if SuperStarXMLSkillsPreSelectorStartBuild:IsHidden() == true then
		SuperStarXMLSkillsPreSelectorStartBuild:SetHidden(false)
	end

end

-- Called by XML
function SuperStar_StartSkillBuilder()

	if SuperStarSkills.class and SuperStarSkills.race then
	
		local displayedValue = SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):GetText()
		
		if displayedValue ~= "" then
			
			local spentSkillPoints = tonumber(displayedValue)
			local maxPoints = SP_MAX_SPENDABLE_POINTS
			
			if spentSkillPoints < 0 then spentSkillPoints = 0 end
			if spentSkillPoints > maxPoints then spentSkillPoints = maxPoints end
			
			SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetText(spentSkillPoints)
			SuperStarSkills.spentSkillPoints = spentSkillPoints
			
		else
			SuperStarXMLSkillsPreSelector:GetNamedChild("SkillPoints"):GetNamedChild("Display"):SetText(SuperStarSkills.availableSkillsPoints)
			SuperStarSkills.spentSkillPoints = SuperStarSkills.availableSkillsPoints
			SuperStarSkills.availableSkillsPointsForBuilder = SuperStarSkills.spentSkillPoints
		end
		
		LSF:Initialize(SuperStarSkills.class, SuperStarSkills.race)
		SUPERSTAR_SKILLS_SCENE:RemoveFragment(SUPERSTAR_SKILLS_PRESELECTORWINDOW)
		SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_BUILDERWINDOW)
	end
	
end

-- Called by XML
function SuperStar_ShowSkills(self)
	SUPERSTAR_SKILLS_WINDOW:OnShown()
end

local function InitSkills(control)
	SUPERSTAR_SKILLS_WINDOW = SuperStarSkills:New(control)
end

local function InitSkillParser()

	local skillParser = {}
	
	for skillType = 1, SKILLTYPES_IN_SKILLBUILDER do
		skillParser[skillType] = {}
		for skillLineIndex = 1, LSF:GetNumSkillLines(skillType) do
			skillParser[skillType][skillLineIndex] = {}
			for abilityIndex=1, LSF:GetNumSkillAbilities(skillType, skillLineIndex) do
				skillParser[skillType][skillLineIndex][abilityIndex] = {}
				
				if SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex) == 1 then
					skillParser[skillType][skillLineIndex][abilityIndex].spentIn = 1
					skillParser[skillType][skillLineIndex][abilityIndex].abilityLevel = ABILITY_LEVEL_NONMORPHED
				else
					skillParser[skillType][skillLineIndex][abilityIndex].spentIn = SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
					skillParser[skillType][skillLineIndex][abilityIndex].abilityLevel = SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
				end
				
			end
		end
	end
	
	return skillParser

end

local function FormatOn2BytesInBase62(base10Char)
	if base10Char < 62 then
		return "0" .. Base62(base10Char)
	else
		return Base62(base10Char)
	end
end

local function BuildChampionHash()

	local hash = zo_strformat("<<1>><<2>><<3>>", TAG_CP, REVISION_CP, MODE_CP)
	local pointsSpentInTotal = 0
	
	if IsChampionSystemUnlocked() then
		for disciplineIndex = 1, GetNumChampionDisciplines() do
			for skillIndex = 1, GetNumChampionDisciplineSkills() do
				
				local pointsSpent = GetNumPointsSpentOnChampionSkill(disciplineIndex, skillIndex)
				local skillUnlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex)
				
				if not skillUnlockLevel then
					hash = hash .. FormatOn2BytesInBase62(pointsSpent)
					pointsSpentInTotal = pointsSpentInTotal + pointsSpent
				end
				
			end
		end
	else
		hash = hash .. "000000000000000000000000000000000000000000000000000000000000000000000000"
	end
	
	return hash, pointsSpentInTotal

end

local function GetSkillLineVirtualIndexForClass(classId, skillLineIndex)

	local skillLineVirtualIndex
	if classId == CLASS_DRAGONKNIGHT then
		skillLineVirtualIndex = skillLineIndex
	elseif classId == CLASS_SORCERER then
		skillLineVirtualIndex = skillLineIndex + 3
	elseif classId == CLASS_NIGHTBLADE then
		skillLineVirtualIndex = skillLineIndex + 6
	elseif classId == CLASS_TEMPLAR then
		skillLineVirtualIndex = skillLineIndex + 9
	elseif classId == CLASS_WARDEN then
		skillLineVirtualIndex = skillLineIndex + 12
	end

	return Base62(SKILL_TYPE_CLASS + SKILLTYPE_TREESHOLD) .. Base62(skillLineVirtualIndex)
	
end

local function BuildLegitSkillsHash()

	local playerClassId = GetUnitClassId("player")
	local playerRaceId = GetUnitRaceId("player")
	local pointsSpentInTotal = 0
	
	local hash = zo_strformat("<<1>><<2>><<3>>", TAG_SKILLS, REVISION_SKILLS, MODE_SKILLS)
	
	for skillType = 1, SKILLTYPES_IN_SKILLBUILDER do
		
		for skillLineIndex = 1, GetNumSkillLines(skillType) do
			
			if skillType == SKILL_TYPE_CLASS then
				hash = hash .. GetSkillLineVirtualIndexForClass(playerClassId, skillLineIndex)
			elseif skillType == SKILL_TYPE_RACIAL then
				hash = hash .. Base62(skillType + SKILLTYPE_TREESHOLD) .. Base62(playerRaceId)
			else
				
				local skillLineName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(skillType, skillLineIndex))
				if skillLineName == LSF:GetSkillLineInfo(skillType, skillLineIndex) then
					hash = hash .. Base62(skillType + SKILLTYPE_TREESHOLD) .. Base62(skillLineIndex)
				else
					
					local reverseSearchFound
					for reverseSearchIndex=1, LSF:GetNumSkillLines(skillType) do
						if skillLineName == LSF:GetSkillLineInfo(skillType, reverseSearchIndex) then
							hash = hash .. Base62(skillType + SKILLTYPE_TREESHOLD) .. Base62(reverseSearchIndex)
							reverseSearchFound = reverseSearchIndex
							break
						end
					end
					if not reverseSearchFound then -- A skillLine which is not yet handled. Abort
						return "", 0 -- For compatibility.
					end
					
				end
				
			end
			
			for abilityIndex=1, GetNumSkillAbilities(skillType, skillLineIndex) do
				
				local _, _, _, passive, ultimate, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
				
				local abilityType
				if passive then
					abilityType = ABILITY_TYPE_PASSIVE_RANGE
				elseif ultimate then
					abilityType = ABILITY_TYPE_ULTIMATE_RANGE
				else
					abilityType = ABILITY_TYPE_ACTIVE_RANGE
				end
				
				local abilityLevel
				
				if not purchased then
					abilityLevel = 0
				else
					
					pointsSpentInTotal = pointsSpentInTotal + SuperStarSkills:GetPointsSpentInAbility(skillType, skillLineIndex, abilityIndex)
					
					if progressionIndex then
						local _, morph = GetAbilityProgressionInfo(progressionIndex)
						abilityLevel = morph + 1
					else
						local currentUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, abilityIndex)
						if currentUpgradeLevel then
							abilityLevel = currentUpgradeLevel
						else
							abilityLevel = 1
						end
					end
				end
				
				hash = hash .. Base62(abilityType + abilityLevel)
				
			end
			
		end
	end
	
	return hash, pointsSpentInTotal

end

local function BuildBuilderSkillsHash()
	
	local function BuildSkillLineHashFromBuilder(skillType, skillLineIndex, classId, raceId)
		
		local pointsSpentInSkillLine = 0
		local hashCode = ""
		
		for abilityIndex=1, LSF:GetNumSkillAbilities(skillType, skillLineIndex) do
			
			local spentIn = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].spentIn
			local abilityType = LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex)
			
			local blockCode
			if spentIn == 0 then
			
				if abilityType == ABILITY_TYPE_ULTIMATE then
					blockCode = ABILITY_TYPE_ULTIMATE_RANGE
				elseif abilityType == ABILITY_TYPE_ACTIVE then
					blockCode = ABILITY_TYPE_ACTIVE_RANGE
				elseif abilityType == ABILITY_TYPE_PASSIVE then
					blockCode = ABILITY_TYPE_PASSIVE_RANGE
				end
				
				hashCode = hashCode .. Base62(blockCode)
				
			else
				
				pointsSpentInSkillLine = pointsSpentInSkillLine + spentIn
				
				local abilityLevel = SuperStarSkills.builderFactory[skillType][skillLineIndex][abilityIndex].abilityLevel
				
				if abilityType == ABILITY_TYPE_ULTIMATE then
					blockCode = ABILITY_TYPE_ULTIMATE_RANGE + abilityLevel + 1 - SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
				elseif abilityType == ABILITY_TYPE_ACTIVE then
					blockCode = ABILITY_TYPE_ACTIVE_RANGE + abilityLevel + 1 - SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
				elseif abilityType == ABILITY_TYPE_PASSIVE then
					blockCode = ABILITY_TYPE_PASSIVE_RANGE + abilityLevel
				end			
				
				hashCode = hashCode .. Base62(blockCode)
			end
		
		end
		
		if pointsSpentInSkillLine > 0 then
			if skillType == SKILL_TYPE_CLASS then
				return GetSkillLineVirtualIndexForClass(classId, skillLineIndex) .. hashCode, pointsSpentInSkillLine
			elseif skillType == SKILL_TYPE_RACIAL then
				return Base62(SKILL_TYPE_RACIAL + SKILLTYPE_TREESHOLD) .. Base62(raceId) .. hashCode, pointsSpentInSkillLine
			else
				return Base62(skillType + SKILLTYPE_TREESHOLD) .. Base62(skillLineIndex) .. hashCode, pointsSpentInSkillLine
			end
		else
			return "", pointsSpentInSkillLine
		end
	
	end
	
	local hash = ""
	
	local classId = SuperStarSkills.class
	local raceId = SuperStarSkills.race
	local pointsSpentInTotal = 0
	
	for skillType=1, SKILLTYPES_IN_SKILLBUILDER do
		for skillLineIndex=1, LSF:GetNumSkillLines(skillType) do
			local skillLineHash, skillLinePoints = BuildSkillLineHashFromBuilder(skillType, skillLineIndex, classId, raceId)
			hash = hash .. skillLineHash
			pointsSpentInTotal = pointsSpentInTotal + skillLinePoints
		end
	end
	
	if hash ~= "" then
		hash = TAG_SKILLS .. REVISION_SKILLS .. MODE_SKILLS .. hash
	end
	
	return hash, pointsSpentInTotal
	
end

local function BuildSkillsHash(skillsFromBuilder)
	
	if skillsFromBuilder then
		return BuildBuilderSkillsHash()
	else
		return BuildLegitSkillsHash()
	end
	
end

local function BuildAttributesHash()

	local attrMagicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA)
	local attrHealth = GetAttributeSpentPoints(ATTRIBUTE_HEALTH)
	local attrStamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA)
	
	local formattedMagicka = FormatOn2BytesInBase62(attrMagicka)
	local formattedHealth = FormatOn2BytesInBase62(attrHealth)
	local formattedStamina = FormatOn2BytesInBase62(attrStamina)
	
	local hash = zo_strformat("<<1>><<2>><<3>><<4>><<5>>", TAG_ATTRIBUTES, REVISION_ATTRIBUTES, formattedMagicka, formattedHealth, formattedStamina)
	
	return hash, attrMagicka + attrHealth + attrStamina

end

local function BuildHashs(inclChampionSkills, includeSkills, includeAttributes, skillsFromBuilder)

	local CHash = ""
	local SHash = ""
	local AHash = ""
	local FHash = ""
	
	local CRequired = 0
	local SRequired = 0
	local ARequired = 0
	
	if inclChampionSkills then
		CHash, CRequired = BuildChampionHash()
		FHash = FHash .. CHash
	end
	
	if includeSkills then
		SHash, SRequired = BuildSkillsHash(skillsFromBuilder)
		FHash = FHash .. SHash
	end
	
	if includeAttributes then
		AHash, ARequired = BuildAttributesHash()
		FHash = FHash .. AHash
	end
	
	return FHash, CRequired, SRequired, ARequired
	
end

local function RefreshImport(inclChampionSkills, includeSkills, includeAttributes)
	local hash = BuildHashs(inclChampionSkills, includeSkills, includeAttributes)
	SuperStarXMLImport:GetNamedChild("MyBuildValue"):GetNamedChild("Edit"):SetText(hash)
end

function SuperStar_ToggleImportAttr()
	
	if xmlIncludeAttributes then
		xmlIncludeAttributes = false
		SuperStarXMLImport:GetNamedChild("MyBuildIclAttr"):SetText(GetString(SUPERSTAR_IMPORT_ATTR_DISABLED))
	else
		xmlIncludeAttributes = true
		SuperStarXMLImport:GetNamedChild("MyBuildIclAttr"):SetText(GetString(SUPERSTAR_IMPORT_ATTR_ENABLED))
	end
	
	RefreshImport(xmlInclChampionSkills, xmlIncludeSkills, xmlIncludeAttributes)
	
end

function SuperStar_ToggleImportSP()
	
	if xmlIncludeSkills then
		xmlIncludeSkills = false
		SuperStarXMLImport:GetNamedChild("MyBuildIclSP"):SetText(GetString(SUPERSTAR_IMPORT_SP_DISABLED))
	else
		xmlIncludeSkills = true
		SuperStarXMLImport:GetNamedChild("MyBuildIclSP"):SetText(GetString(SUPERSTAR_IMPORT_SP_ENABLED))
	end
	
	RefreshImport(xmlInclChampionSkills, xmlIncludeSkills, xmlIncludeAttributes)
	
end

function SuperStar_ToggleImportCP()

	if xmlInclChampionSkills then
		xmlInclChampionSkills = false
		SuperStarXMLImport:GetNamedChild("MyBuildIclCP"):SetText(GetString(SUPERSTAR_IMPORT_CP_DISABLED))
	else
		xmlInclChampionSkills = true
		SuperStarXMLImport:GetNamedChild("MyBuildIclCP"):SetText(GetString(SUPERSTAR_IMPORT_CP_ENABLED))
	end
	
	RefreshImport(xmlInclChampionSkills, xmlIncludeSkills, xmlIncludeAttributes)

end

local function IsValidAttrHash(hash)

	if string.sub(hash, 1, 1) == TAG_ATTRIBUTES then
		if string.sub(hash, 2, 2) == REVISION_ATTRIBUTES then
			if string.len(hash) == 8 then
				
				local AttrMagick = Base62(string.sub(hash, 3, 4))
				local AttrHealth = Base62(string.sub(hash, 5, 6))
				local AttrStamin = Base62(string.sub(hash, 7, 8))
				
				if type(AttrMagick) == "number" and type(AttrHealth) == "number" and type(AttrStamin) == "number" then
					if AttrMagick + AttrHealth + AttrStamin <= ATTR_MAX_SPENDABLE_POINTS then
						return true
					end
				end
				
			end
		end
	end
	
	return false

end

local function IsValidSkillsHash(hash)
	
	local isValid = false
	
	if string.sub(hash, 1, 1) == TAG_SKILLS then
		if string.sub(hash, 2, 2) == REVISION_SKILLS then
			if string.sub(hash, 3, 3) == MODE_SKILLS then
				
				local needToParse = true
				local nextBlockIdx = 4
				local skillType, skillLineIndex, abilityIndex, numAbilities
				
				local nextIsSkillType = true
				local nextIsSkillLine = false
				
				local nextIsClass = false
				local nextIsRace = false
				
				isValid = true
				
				while needToParse do
					
					local blockToCheck = string.sub(hash, nextBlockIdx, nextBlockIdx)
					nextBlockIdx = nextBlockIdx + 1
					
					if blockToCheck ~= "" then
					
						local decimalBlock = Base62(blockToCheck)
						
						if nextIsSkillType then
						
							nextIsSkillType = false
							
							-- Only 32/39 range is defined for now
							if decimalBlock < (SKILLTYPE_TREESHOLD + SKILL_TYPE_CLASS) or decimalBlock > (SKILLTYPE_TREESHOLD + SKILL_TYPE_TRADESKILL) then
								return false
							end
							
							if decimalBlock == (SKILLTYPE_TREESHOLD + SKILL_TYPE_CLASS) then
								nextIsClass = true
							elseif decimalBlock == (SKILLTYPE_TREESHOLD + SKILL_TYPE_RACIAL) then
								nextIsRace = true
							else
								nextIsSkillLine = true
							end
							
							skillType = decimalBlock - SKILLTYPE_TREESHOLD
						
						elseif nextIsClass then
						
							nextIsClass = false
							
							-- 15 = NbClass * NbSkillsLines
							if decimalBlock < 1 or decimalBlock > 15 then
								return false
							end
							
							if decimalBlock <= 3 then
								skillLineIndex = decimalBlock
							elseif decimalBlock <= 6 then
								skillLineIndex = decimalBlock - 3
							elseif decimalBlock <= 9 then
								skillLineIndex = decimalBlock - 6
							elseif decimalBlock <= 12 then
								skillLineIndex = decimalBlock - 9
							else
								skillLineIndex = decimalBlock - 12
							end
							
							skillLineIndex = 1
							numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
							abilityIndex = 1
						
						elseif nextIsRace then
						
							nextIsRace = false
							
							if decimalBlock < 1 or decimalBlock > MAX_PLAYABLE_RACES then
								return false
							end
							
							skillLineIndex = 1
							numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
							abilityIndex = 1
						
						elseif nextIsSkillLine then
						
							nextIsSkillLine = false
							local numSkillLines = LSF:GetNumSkillLines(skillType)
							
							-- Invalid skillLine
							if decimalBlock < 1 or decimalBlock > numSkillLines then
								return false
							end
							
							skillLineIndex = decimalBlock
							numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
							abilityIndex = 1
							
						else
						
							if decimalBlock <= SKILLTYPE_TREESHOLD then
								
								local correctType, maxLevel = LSF:GetAbilityType(skillType, skillLineIndex, abilityIndex)
								
								if decimalBlock < ABILITY_TYPE_ULTIMATE_RANGE then
									return false
								elseif decimalBlock < ABILITY_TYPE_ACTIVE_RANGE and correctType == ABILITY_TYPE_ULTIMATE then
									-- Ultimate
								elseif decimalBlock < ABILITY_TYPE_PASSIVE_RANGE and correctType == ABILITY_TYPE_ACTIVE then
									-- Active
								elseif correctType == ABILITY_TYPE_PASSIVE then
									-- Passive
									local abilityLevel = decimalBlock - ABILITY_TYPE_PASSIVE_RANGE
									if maxLevel and abilityLevel > maxLevel then
										return false
									end
								else
									return false
								end
								
								if abilityIndex < numAbilities then
									-- Next is another ability
									abilityIndex = abilityIndex + 1
								else
									nextIsSkillType = true
								end
								
							else
								return false
							end
							
						end
					elseif not nextIsSkillType then
						return false
					else
						needToParse = false
					end
					
				end
				
			end
		end
	end
	
	return isValid
	
end

local function IsValidChampionHash(hash)
	
	local isValid
	
	if string.sub(hash, 1, 1) == TAG_CP then
		if string.sub(hash, 2, 2) == REVISION_CP then
			if string.sub(hash, 3, 3) == MODE_CP then
				if string.len(hash) == 75 then
					
					local startPos = 4
					
					for disciplineIndex = 1, GetNumChampionDisciplines() do
						for skillIndex = 1, GetNumChampionDisciplineSkills() do
							
							local skillUnlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex)
							if not skillUnlockLevel then
								
								local CPValue = Base62(string.sub(hash, startPos, startPos + 1))
								if type(CPValue) == "number" and CPValue <= CP_MAX_SPENDABLE_POINTS then
									isValid = true
								else
									return false
								end
								
								startPos = startPos + 2
								
							end
							
						end
					end
					
				end
			end
		end
	end
	
	if isValid then
		return true
	end

end

local function ParseAttrHash(hash)
	
	if IsValidAttrHash(hash) then
	
		local AttrMagick = Base62(string.sub(hash, 3, 4))
		local AttrHealth = Base62(string.sub(hash, 5, 6))
		local AttrStamin = Base62(string.sub(hash, 7, 8))
		
		return {magick = AttrMagick, health = AttrHealth, stam = AttrStamin, pointsRequired = AttrMagick + AttrHealth + AttrStamin}
		
	else
		return false
	end
	
end

local function ParseSkillsHash(hash)
	
	local isValidHash = IsValidSkillsHash(hash)
	local skillData
	
	local classId = GetUnitClassId("player")
	local raceId = GetUnitRaceId("player")
	
	if isValidHash then
		
		skillData = InitSkillParser()
		skillData.pointsRequired = 0
		
		local needToParse = true
		local nextBlockIdx = 4
		local skillType, skillLineIndex, abilityIndex, numSkillLines, numAbilities
		
		local nextIsSkillType = true
		local nextIsSkillLine = false
		
		local nextIsClass = false
		local nextIsRace = false
		
		while needToParse do
			
			local blockToCheck = string.sub(hash, nextBlockIdx, nextBlockIdx)
			nextBlockIdx = nextBlockIdx + 1
			
			if blockToCheck ~= "" then
			
				local decimalBlock = Base62(blockToCheck)
			
				if nextIsSkillType then
				
					nextIsSkillType = false
					
					if decimalBlock == (SKILLTYPE_TREESHOLD + SKILL_TYPE_CLASS) then
						nextIsClass = true
					elseif decimalBlock == (SKILLTYPE_TREESHOLD + SKILL_TYPE_RACIAL) then
						nextIsRace = true
					else
						nextIsSkillLine = true
					end
					
					skillType = decimalBlock - SKILLTYPE_TREESHOLD
				
				elseif nextIsClass then
				
					nextIsClass = false
					
					if decimalBlock <= 3 then
						skillLineIndex = decimalBlock
						classId = CLASS_DRAGONKNIGHT
					elseif decimalBlock <= 6 then
						skillLineIndex = decimalBlock - 3
						classId = CLASS_SORCERER
					elseif decimalBlock <= 9 then
						skillLineIndex = decimalBlock - 6
						classId = CLASS_NIGHTBLADE
					elseif decimalBlock <= 12 then
						skillLineIndex = decimalBlock - 9
						classId = CLASS_TEMPLAR
					else
						skillLineIndex = decimalBlock - 12
						classId = CLASS_WARDEN
					end
					
					numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
					abilityIndex = 1
				
				elseif nextIsRace then
				
					nextIsRace = false
					
					raceId = decimalBlock
					skillLineIndex = 1
					numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
					abilityIndex = 1
				
				elseif nextIsSkillLine then
				
					nextIsSkillLine = false
					
					skillLineIndex = decimalBlock
					numAbilities = LSF:GetNumSkillAbilities(skillType, skillLineIndex)
					abilityIndex = 1
					
				else
				
					local abilityLevel, spentIn
					local abilityId
					if decimalBlock >= ABILITY_TYPE_ULTIMATE_RANGE and decimalBlock < ABILITY_TYPE_ACTIVE_RANGE then
						if decimalBlock > ABILITY_TYPE_ULTIMATE_RANGE then
							abilityLevel = decimalBlock - ABILITY_TYPE_ULTIMATE_RANGE - 1
							spentIn = math.min(decimalBlock - ABILITY_TYPE_ULTIMATE_RANGE, 2)
						else
							abilityLevel = 0
							spentIn = 0
						end
						abilityId = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, abilityLevel, 4)
					elseif decimalBlock >= ABILITY_TYPE_ACTIVE_RANGE and decimalBlock < ABILITY_TYPE_PASSIVE_RANGE then
						if decimalBlock > ABILITY_TYPE_ACTIVE_RANGE then
							abilityLevel = decimalBlock - ABILITY_TYPE_ACTIVE_RANGE - 1
							spentIn = math.min(decimalBlock - ABILITY_TYPE_ACTIVE_RANGE, 2)
						else
							abilityLevel = 0
							spentIn = 0
						end
						abilityId = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, abilityLevel, 4)
					else
						abilityLevel = decimalBlock - ABILITY_TYPE_PASSIVE_RANGE
						spentIn = abilityLevel
						abilityId = LSF:GetAbilityId(skillType, skillLineIndex, abilityIndex, 1)
					end
					
					skillData[skillType][skillLineIndex][abilityIndex].spentIn = spentIn
					skillData[skillType][skillLineIndex][abilityIndex].abilityLevel = abilityLevel
					
					local name = zo_strformat(SI_ABILITY_NAME, GetAbilityName(abilityId))
					
					if SuperStarSkills:GetActiveSkillsExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex) == 1 then
						spentIn = 1
					end
					
					skillData.pointsRequired = skillData.pointsRequired + spentIn - SuperStarSkills:GetExceptionsPointsSpentInAbilityForBuilder(skillType, skillLineIndex, abilityIndex)
					
					if abilityIndex < numAbilities then
						-- Next is another ability
						abilityIndex = abilityIndex + 1
					else
						nextIsSkillType = true
					end
					
				end
			else
				needToParse = false
			end
			
		end
		
		skillData.classId = classId
		skillData.raceId = raceId
		
		return skillData
		
	else
		return false
	end
	
end

local function ParseCPHash(hash)
	
	if IsValidChampionHash(hash) then
	
		local startPos = 4
		local cpData = {}
		cpData.pointsRequired = 0
		
		for disciplineIndex = 1, GetNumChampionDisciplines() do
			cpData[disciplineIndex] = {}
			for skillIndex = 1, GetNumChampionDisciplineSkills() do
				
				local skillUnlockLevel = GetChampionSkillUnlockLevel(disciplineIndex, skillIndex)
				if not skillUnlockLevel then
					local pointsSpent = Base62(string.sub(hash, startPos, startPos + 1))
					cpData[disciplineIndex][skillIndex] = pointsSpent
					cpData.pointsRequired = cpData.pointsRequired + pointsSpent
					startPos = startPos + 2
				end
				
			end
		end
		
		return cpData
		
	else
		return false
	end

end

local function CheckImportedBuild(build)

	local hasAttr = string.find(build, TAG_ATTRIBUTES)
	local hasSkills = string.find(build, TAG_SKILLS)
	local hasCP = string.find(build, "%%") -- special char for gsub (TAG_CP)
	
	local hashAttr = ""
	local hashSkills = ""
	local hashCP = ""
	
	if hasAttr then
		hashAttr = string.sub(build, hasAttr)
	end
	
	if hasSkills then
		if hasAttr then
			hashSkills = string.sub(build, hasSkills, hasAttr-1)
		else
			hashSkills = string.sub(build, hasSkills)
		end
	end
	
	if hasCP then
		if hasSkills then
			hashCP = string.sub(build, 1, hasSkills-1)
		elseif hasAttr then
			hashCP = string.sub(build, 1, hasAttr-1)
		else
			hashCP = build
		end
	end
	
	local attrData
	local skillsData
	local cpData
	
	if hasAttr or hasSkills or hasCP then
	
		attrData = true
		skillsData = true
		cpData = true
		
		if hasAttr and hashAttr then
			attrData = ParseAttrHash(hashAttr)
		end
		
		if hasSkills and hashSkills then
			skillsData = ParseSkillsHash(hashSkills)
		end
		
		if hasCP and hashCP then
			cpData = ParseCPHash(hashCP)
		end
	
	end
	
	return attrData, skillsData, cpData
	
end

local function UpdateHashDataContainer(attrData, skillsData, cpData)
	
	if not attrData and not skillsData and not cpData then
		SuperStarXMLImport:GetNamedChild("Container"):SetHidden(true)
		SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetText(GetString(SUPERSTAR_IMPORT_BUILD_NOK))
		SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetState(BSTATE_DISABLED, true)
	else
		
		isImportedBuildValid = true
		
		SuperStarXMLImport:GetNamedChild("Container"):SetHidden(false)
		
		local SUPERSTAR_GENERIC_NA = "N/A"
		
		if attrData then
			if type(attrData) == "boolean" then
				
				local MagickaAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("MagickaAttributeLabel")
				local HealthAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("HealthAttributeLabel")
				local StaminaAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("StaminaAttributeLabel")
				
				MagickaAttributeLabel:SetText(SUPERSTAR_GENERIC_NA)
				HealthAttributeLabel:SetText(SUPERSTAR_GENERIC_NA)
				StaminaAttributeLabel:SetText(SUPERSTAR_GENERIC_NA)
				
			else
			
				local MagickaAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("MagickaAttributeLabel")
				local HealthAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("HealthAttributeLabel")
				local StaminaAttributeLabel = SuperStarXMLImportHashData:GetNamedChild("StaminaAttributeLabel")
				
				MagickaAttributeLabel:SetText(attrData.magick)
				HealthAttributeLabel:SetText(attrData.health)
				StaminaAttributeLabel:SetText(attrData.stam)
			
			end
		end
		
		if skillsData then
			if type(skillsData) == "boolean" then
				local SkillPointsValue = SuperStarXMLImportHashData:GetNamedChild("SkillPointsValue")
				SkillPointsValue:SetText(SUPERSTAR_GENERIC_NA)
				
				SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetText(GetString(SUPERSTAR_IMPORT_BUILD_NO_SKILLS))
				SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetState(BSTATE_DISABLED, true)
				
			else
			
				local SkillPointsValue = SuperStarXMLImportHashData:GetNamedChild("SkillPointsValue")
				SkillPointsValue:SetText(skillsData.pointsRequired)
				
				SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetText(GetString(SUPERSTAR_IMPORT_BUILD_OK))
				SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetState(BSTATE_NORMAL, true)
				
			end
		end
		
		if cpData then
			if type(cpData) == "boolean" then
				for disciplineIndex=1, 9 do
				
					local StarName = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex)
					
					local SkillName1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName1")
					local SkillValue1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue1")
					local SkillName2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName2")
					local SkillValue2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue2")
					local SkillName3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName3")
					local SkillValue3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue3")
					local SkillName4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName4")
					local SkillValue4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue4")
					
					local SkillBonus1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus1")
					local SkillBonus2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus2")
					local SkillBonus3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus3")
					local SkillBonus4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus4")
					
					StarName:SetHidden(true)
					
					SkillName1:SetHidden(true)
					SkillValue1:SetHidden(true)
					SkillName2:SetHidden(true)
					SkillValue2:SetHidden(true)
					SkillName3:SetHidden(true)
					SkillValue3:SetHidden(true)
					SkillName4:SetHidden(true)
					SkillValue4:SetHidden(true)
					
					SkillBonus1:SetHidden(true)
					SkillBonus2:SetHidden(true)
					SkillBonus3:SetHidden(true)
					SkillBonus4:SetHidden(true)
					
				end
				
			else
				
				local magickaColor = GetItemQualityColor(ITEM_QUALITY_ARCANE)
				local staminaColor = GetItemQualityColor(ITEM_QUALITY_MAGIC)
				local SUPERSTAR_GENERIC_MINUS = "-"
				
				for disciplineIndex=1, 9 do
				
					local StarName = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex)
					
					local SkillName1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName1")
					local SkillValue1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue1")
					local SkillName2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName2")
					local SkillValue2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue2")
					local SkillName3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName3")
					local SkillValue3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue3")
					local SkillName4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName4")
					local SkillValue4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue4")
					
					local SkillBonus1 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus1")
					local SkillBonus2 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus2")
					local SkillBonus3 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus3")
					local SkillBonus4 = SuperStarXMLImportHashData:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus4")
					
					StarName:SetHidden(false)
					
					SkillName1:SetHidden(false)
					SkillValue1:SetHidden(false)
					SkillName2:SetHidden(false)
					SkillValue2:SetHidden(false)
					SkillName3:SetHidden(false)
					SkillValue3:SetHidden(false)
					SkillName4:SetHidden(false)
					SkillValue4:SetHidden(false)
					
					SkillBonus1:SetHidden(false)
					SkillBonus2:SetHidden(false)
					SkillBonus3:SetHidden(false)
					SkillBonus4:SetHidden(false)
					
					local pointsInSkill1 = cpData[disciplineIndex][1]
					local pointsInSkill2 = cpData[disciplineIndex][2]
					local pointsInSkill3 = cpData[disciplineIndex][3]
					local pointsInSkill4 = cpData[disciplineIndex][4]
					
					local bonusUnlocked1 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 10
					local bonusUnlocked2 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 30
					local bonusUnlocked3 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 75
					local bonusUnlocked4 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 120
					
					SkillName1.disciplineIndex = disciplineIndex
					SkillName1.skillIndex = 1
					SkillName1.skillLevel = 0
					SkillValue1.disciplineIndex = disciplineIndex
					SkillValue1.skillIndex = 1
					SkillValue1.skillLevel = 0
					
					SkillName2.disciplineIndex = disciplineIndex
					SkillName2.skillIndex = 2
					SkillName2.skillLevel = 0
					SkillValue2.disciplineIndex = disciplineIndex
					SkillValue2.skillIndex = 2
					SkillValue2.skillLevel = 0
					
					SkillName3.disciplineIndex = disciplineIndex
					SkillName3.skillIndex = 3
					SkillName3.skillLevel = 0
					SkillValue3.disciplineIndex = disciplineIndex
					SkillValue3.skillIndex = 3
					SkillValue3.skillLevel = 0
					
					SkillName4.disciplineIndex = disciplineIndex
					SkillName4.skillIndex = 4
					SkillName4.skillLevel = 0
					SkillValue4.disciplineIndex = disciplineIndex
					SkillValue4.skillIndex = 4
					SkillValue4.skillLevel = 0
					
					local function EnableCPBonus(SuperStarXMLImportHashData, enable, disciplineIndex, skillIndex, unlockColor)
						SuperStarXMLImportHashData:SetHidden(not enable)
						SuperStarXMLImportHashData.disciplineIndex = disciplineIndex
						SuperStarXMLImportHashData.skillIndex = skillIndex
						SuperStarXMLImportHashData.skillLevel = 0
						SuperStarXMLImportHashData:SetColor(unlockColor.r, unlockColor.g, unlockColor.b)
						SuperStarXMLImportHashData:SetFont("ZoFontGameMini")
					end
					
					EnableCPBonus(SkillBonus1, bonusUnlocked1, disciplineIndex, 5, GetItemQualityColor(ITEM_QUALITY_MAGIC))
					EnableCPBonus(SkillBonus2, bonusUnlocked2, disciplineIndex, 6, GetItemQualityColor(ITEM_QUALITY_ARCANE))
					EnableCPBonus(SkillBonus3, bonusUnlocked3, disciplineIndex, 7, GetItemQualityColor(ITEM_QUALITY_ARTIFACT))
					EnableCPBonus(SkillBonus4, bonusUnlocked4, disciplineIndex, 8, GetItemQualityColor(ITEM_QUALITY_LEGENDARY))
					
					local pointsInDisciple = GetNumPointsSpentInChampionDiscipline(i)
					
					if pointsInSkill1 == 0 then pointsInSkill1 = SUPERSTAR_GENERIC_MINUS end
					if pointsInSkill2 == 0 then pointsInSkill2 = SUPERSTAR_GENERIC_MINUS end
					if pointsInSkill3 == 0 then pointsInSkill3 = SUPERSTAR_GENERIC_MINUS end
					if pointsInSkill4 == 0 then pointsInSkill4 = SUPERSTAR_GENERIC_MINUS end
					
					StarName:SetText(zo_strformat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT, GetChampionDisciplineName(disciplineIndex)))
					
					if disciplineIndex >= 2 and disciplineIndex <= 4 then
						StarName:SetColor(1, 0, 0)
					elseif disciplineIndex >= 5 and disciplineIndex <= 7 then
						StarName:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
					else
						StarName:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
					end
					
					local function ShortenCPSkillName(discipline, skill)
						if GetString("SUPERSTAR_CHAMPION_SKILL".. discipline .."NAME", skill) ~= "" then
							return GetString("SUPERSTAR_CHAMPION_SKILL".. discipline .."NAME", skill)
						else
							return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, GetChampionSkillName(discipline, skill))
						end
					end
					
					SkillName1:SetText(ShortenCPSkillName(disciplineIndex, 1))
					SkillValue1:SetText(pointsInSkill1)
					SkillName2:SetText(ShortenCPSkillName(disciplineIndex, 2))
					SkillValue2:SetText(pointsInSkill2)
					SkillName3:SetText(ShortenCPSkillName(disciplineIndex, 3))
					SkillValue3:SetText(pointsInSkill3)
					SkillName4:SetText(ShortenCPSkillName(disciplineIndex, 4))
					SkillValue4:SetText(pointsInSkill4)
					
				end
			end
		end
		
	end
	
	KEYBIND_STRIP:UpdateKeybindButtonGroup(SUPERSTAR_IMPORT_WINDOW.importKeybindStripDescriptor)
	
end

function SuperStar_SeeImportedBuild(self)

	local hash = SuperStarXMLImport:GetNamedChild("ImportValue"):GetNamedChild("Edit"):GetText()
	
	if hash ~= "" then
	
		local attrData, skillsData, cpData = CheckImportedBuild(hash)
	
		if attrData and skillsData and cpData then
			
			ResetSkillBuilder()
			
			local availablePoints = SuperStarSkills.spentSkillPoints - skillsData.pointsRequired
			
			if availablePoints >= 0 then
				
				LSF:Initialize(skillsData.classId, skillsData.raceId)
				SuperStarSkills.builderFactory = skillsData
				SuperStarSkills.pendingCPDataForBuilder = cpData
				SuperStarSkills.pendingAttrDataForBuilder = attrData
				
				SuperStarSkills.spentSkillPoints = availablePoints
				
				SUPERSTAR_SKILLS_SCENE:RemoveFragment(SUPERSTAR_SKILLS_PRESELECTORWINDOW)
				SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_BUILDERWINDOW)
				
				LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarSkills")
				
			end
			
		else
			--
		end
	
	end
	
end

function SuperStar_CheckImportedBuild(self)
	local text = self:GetText()
	
	isImportedBuildValid = false
	
	if text ~= "" then
		
		local attrData, skillsData, cpData = CheckImportedBuild(text)
		SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetHidden(false)
		
		if attrData and skillsData and cpData then
			UpdateHashDataContainer(attrData, skillsData, cpData)
		else
			UpdateHashDataContainer(false, false, false)
		end
		
	else
		SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetHidden(true)
		UpdateHashDataContainer(false, false, false)
	end
	
end

local SUPERSTAR_NOWARNING = 0
local SUPERSTAR_INVALID_CLASS = 1
local SUPERSTAR_NOT_ENOUGHT_SP = 2
local SUPERSTAR_INVALID_RACE = 3
local SUPERSTAR_REQ_SKILLLINE_BUTNOTFOUND = 4
local SUPERSTAR_INVALID_CHAMPION = 5
local SUPERSTAR_NOT_ENOUGHT_CP = 6

local function AnnounceCPRespecDone()
	CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_LARGE_TEXT, SOUNDS.LEVEL_UP, GetString(SUPERSTAR_CSA_RESPECDONE_TITLE))
end

local function AnnounceSPRespecDone(totalPointSet)
	CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT, SOUNDS.LEVEL_UP, GetString(SUPERSTAR_CSA_RESPECDONE_TITLE), zo_strformat(SUPERSTAR_CSA_RESPECDONE_POINTS, totalPointSet))
end

local function AnnounceSPRespecProgress(skillType)
	CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE, GetString("SUPERSTAR_RESPEC_INPROGRESS", skillType))
end

local function AnnounceSPRespecStarted(totalPointSet)
	
	local minutes
	if totalPointSet < 150 then
		minutes = 1
	elseif totalPointSet < 300 then
		minutes = 2
	else
		minutes = 3
	end
	
	CENTER_SCREEN_ANNOUNCE:AddMessage(999, CSA_EVENT_COMBINED_TEXT, SOUNDS.CHAMPION_WINDOW_OPENED, GetString(SUPERSTAR_CSA_RESPEC_INPROGRESS), zo_strformat(SUPERSTAR_CSA_RESPEC_TIME, minutes), nil, nil, nil, nil)
	
end

-- zo_callLater is here to prevent ZOS limitation of 100 messages / minute
local function RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, abilityIndex, totalPointSet, noRace, skillLineForReference)
	
	local function GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
	
		if abilityIndex + 1 > GetNumSkillAbilities(skillType, skillLineIndex) then
			abilityIndex = 1
			skillLineIndex = skillLineIndex + 1
			skillLineForReference = skillLineIndex
		else
			abilityIndex = abilityIndex + 1
		end
		
		if skillLineIndex > GetNumSkillLines(skillType) then
			abilityIndex = 1
			skillLineIndex = 1
			skillLineForReference = 1
			skillType = skillType + 1
			AnnounceSPRespecProgress(skillType - 1)
		end
		
		return skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference
	
	end
	
	local function RespecAbilitiesInSkillLine(skillType, skillLineIndex, abilityIndex, skillLineForReference)
		
		if not skillLineForReference then
			skillLineForReference = skillLineIndex
		end
		
		local _, _, earnedRank, passive, _, purchased, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
		local exception = SuperStarSkills:ConvertExceptionsPointsSpentInAbility(skillType, skillLineForReference, abilityIndex, true)
		local spentIn = skillsData[skillType][skillLineForReference][abilityIndex].spentIn
		local abilityLevel = skillsData[skillType][skillLineForReference][abilityIndex].abilityLevel
		local _, actualSkillRank = GetSkillLineInfo(skillType, skillLineIndex)
		
		-- Don't buy 1st point if granted
		if not purchased and not exception and spentIn > 0 then
			
			--d("Not Purchased")
			-- take it
			if earnedRank <= actualSkillRank then
				--d("Not Purchased and ok !")
				PutPointIntoSkillAbility(skillType, skillLineIndex, abilityIndex)
				totalPointSet = totalPointSet + 1
			else
				skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
			end
			
			--d("Calling with args :" .. skillType .. ";" .. skillLineIndex .. ";" .. abilityIndex .. ";" .. totalPointSet)
			zo_callLater(function() RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, abilityIndex, totalPointSet, noRace, skillLineForReference) end, 350)
			
			return true
			
		elseif purchased and spentIn > 1 then
			
			--d("Purchased")
			
			if passive then
				
				--d("Passive")
				
				local currentUpgradeLevel, maxUpgradeLevel = GetSkillAbilityUpgradeInfo(skillType, skillLineIndex, abilityIndex)
				local _, _, upgradeEarningRank = GetSkillAbilityNextUpgradeInfo(skillType, skillLineIndex, abilityIndex)
				if spentIn <= maxUpgradeLevel and spentIn > currentUpgradeLevel then
					
					if upgradeEarningRank <= actualSkillRank then
						--d("Purchased and ok !")
						PutPointIntoSkillAbility(skillType, skillLineIndex, abilityIndex, true)
						totalPointSet = totalPointSet + 1
						
						if spentIn == currentUpgradeLevel + 1 then
							skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
						end
						
					else
						skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
					end
					
					--d("Calling with args :" .. skillType .. ";" .. skillLineIndex .. ";" .. abilityIndex .. ";" .. totalPointSet)
					zo_callLater(function() RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, abilityIndex, totalPointSet, noRace, skillLineForReference) end, 350)
					
					return true
				end
			else
				
				--d("Active/Ultimate")
				
				if abilityLevel == ABILITY_LEVEL_UPPERMORPH or abilityLevel == ABILITY_LEVEL_LOWERMORPH then
				
					ChooseAbilityProgressionMorph(progressionIndex, abilityLevel)
					totalPointSet = totalPointSet + 1
					
					skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
					
					--d("Calling with args :" .. skillType .. ";" .. skillLineIndex .. ";" .. abilityIndex .. ";" .. totalPointSet)
					zo_callLater(function() RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, abilityIndex, totalPointSet, noRace, skillLineForReference) end, 350)
					
					return true
				
				end
			end
		else
		
			skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference)
			
			--d("Calling with args :" .. skillType .. ";" .. skillLineIndex .. ";" .. abilityIndex .. ";" .. totalPointSet)
			zo_callLater(function() RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, abilityIndex, totalPointSet, noRace, skillLineForReference) end, 1)
			
			return true
			
		end
	
	end
	
	if totalPointSet < SP_MAX_SPENDABLE_POINTS then
		if skillType <= SKILLTYPES_IN_SKILLBUILDER then
			if noRace and skillType == SKILL_TYPE_RACIAL then
				skillType, skillLineIndex, abilityIndex, noRace, skillLineForReference = GoForward(SKILL_TYPE_RACIAL, 9, 9, totalPointSet, noRace, skillLineForReference)
			end
			local referenceNumSkillLines = LSF:GetNumSkillLines(skillType)
			if referenceNumSkillLines > 0 and skillLineIndex <= referenceNumSkillLines then
				
				local referenceNumAbilities = SuperStarSkills:GetNumSkillAbilitiesForBuilder(skillType, skillLineForReference)
				local referenceSkillLineName = LSF:GetSkillLineInfo(skillType, skillLineForReference)
				
				local realityNumAbilities = GetNumSkillAbilities(skillType, skillLineIndex)
				local realitySkillLineName = zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(skillType, skillLineIndex))
				
				-- Protect against new skillLines & new abilities
				if referenceNumAbilities == realityNumAbilities and (skillType == SKILL_TYPE_RACIAL or referenceSkillLineName == realitySkillLineName) then
					if abilityIndex <= referenceNumAbilities then
						local shouldReturn = RespecAbilitiesInSkillLine(skillType, skillLineIndex, abilityIndex, skillLineForReference)
						if shouldReturn then return end
					end
				else
					
					local reverseSearchFound
					for reverseSearchIndex=1, LSF:GetNumSkillLines(skillType) do
						if realitySkillLineName == LSF:GetSkillLineInfo(skillType, reverseSearchIndex) then
							reverseSearchFound = reverseSearchIndex
							break
						end
					end
					if not reverseSearchFound then -- A skillLine which is not yet handled. Abort
						skillType = skillType + 1
						skillLineIndex = 1
						skillLineForReference = skillLineIndex
					else
						skillLineForReference = reverseSearchFound
					end
					
					zo_callLater(function()
						--d("Another try for skillLine " .. skillLineIndex .. " (" .. skillLineForReference .. "/" .. referenceNumSkillLines .. ") ( Ref: " .. referenceSkillLineName .. " / Need: " .. realitySkillLineName .." )")
						RespecSkillsSpendPoints(skillsData, skillType, skillLineIndex, 1, totalPointSet, noRace, skillLineForReference)
					end, 200)
					
					return
					
				end
			end
		end
		
		skillsDataForRespec = nil
		AnnounceSPRespecDone(totalPointSet)
	
	end
	
end

local function RespecCPPoints(cpDataForRespec) 
	
	SetChampionIsInRespecMode(true)
	
	for disciplineIndex=1, 9 do
		for skillIndex=1, 4 do
			if cpDataForRespec[disciplineIndex][skillIndex] > 0 then
				SetNumPendingChampionPoints(disciplineIndex, skillIndex, cpDataForRespec[disciplineIndex][skillIndex])
			end
		end
	end
	
	if IsChampionRespecNeeded() then
		ZO_Dialogs_ShowDialog("SUPERSTAR_CONFIRM_CPRESPEC_COST", nil, { mainTextParams = { GetChampionRespecCost(), ZO_Currency_GetPlatformFormattedGoldIcon() } }) -- pay
	else
		ZO_Dialogs_ShowDialog("SUPERSTAR_CONFIRM_CPRESPEC_NOCOST") -- free
	end
	
end

local function FinalizeCPRespec(shouldFinalize)

	if shouldFinalize then
		cpRespecInProgress = true
		SpendPendingChampionPoints(true)
		AnnounceCPRespecDone()
		SuperStar_ToggleSuperStarPanel()
	else
		for disciplineIndex=1, 9 do
			for skillIndex=1, 4 do
				if cpDataForRespec[disciplineIndex][skillIndex] > 0 then
					SetNumPendingChampionPoints(disciplineIndex, skillIndex, 0)
				end
			end
		end
		ClearPendingChampionPoints()
	end
	
	SetChampionIsInRespecMode(false)
	
end

-- Will trigger an error if executed by SuperStar
function CHAMPION_PERKS:OnChampionPurchaseResult(result)

	if not cpRespecInProgress then

		self.awaitingSpendPointsResponse = false

		if result == CHAMPION_PURCHASE_SUCCESS then
			--depends on the pending points and respec mode not being reset yet
			self:PlayStarConfirmAnimations()
		end

		SetChampionIsInRespecMode(false)
		self:ResetPendingPoints()
		self:RefreshConstellationSpentPoints()

		--depends on pending and spent points being updated
		self:RefreshConstellationStarStates()

		self:RefreshUnspentPoints()
		self:RefreshAvailablePointDisplays()
		self:RefreshChosenConstellationInfo()
		self:RefreshMenuIndicators()
		KEYBIND_STRIP:UpdateKeybindButtonGroup(self.sharedKeybindStripDescriptor)
	else
		cpRespecInProgress = false
	end
	
end

-- stripped MAIN_MENU_GAMEPAD:RefreshLists() with make a call to a private function.
function CHAMPION_PERKS:RefreshMenuIndicators()
	if not IsConsoleUI() then
		MAIN_MENU_KEYBOARD:RefreshCategoryIndicators()
	end
end

local function CheckSPrespec(skillsData)

	local letsGo = false
	local returnCode = SUPERSTAR_NOWARNING
	
	-- blocked
	if GetUnitClassId("player") ~= skillsData.classId then
		returnCode = SUPERSTAR_INVALID_CLASS
		return letsGo, returnCode
	end
	
	-- blocked
	if GetAvailableSkillPoints() < skillsData.pointsRequired then
		returnCode = SUPERSTAR_NOT_ENOUGHT_SP
		return letsGo, returnCode
	end
	
	letsGo = true
	
	--authorized
	if GetUnitRaceId("player") ~= skillsData.raceId then
		returnCode = SUPERSTAR_INVALID_RACE
	end
	
	return letsGo, returnCode
		
end

local function CheckRespecSkillLines()
	
	local realSkillLines = {}
	local refSkillLines = {}
	local skillLinesNotFound = ""
	
	for skillType = 1, SKILLTYPES_IN_SKILLBUILDER do
		
		if skillType ~= SKILL_TYPE_RACIAL then
			for skillLineIndex = 1, GetNumSkillLines(skillType) do
				realSkillLines[zo_strformat(SI_SKILLS_TREE_NAME_FORMAT, GetSkillLineInfo(skillType, skillLineIndex))] = true
			end
			
			for skillLineIndex = 1, LSF:GetNumSkillLines(skillType) do
				refSkillLines[LSF:GetSkillLineInfo(skillType, skillLineIndex)] = true
			end
		end
		
	end
	
	for skillLineName in pairs(refSkillLines) do
		if not realSkillLines[skillLineName] then
			skillLinesNotFound = zo_strjoin(", ", skillLineName, skillLinesNotFound)
		end
	end
	
	if skillLinesNotFound ~= "" then
		skillLinesNotFound = string.sub(skillLinesNotFound, 0, -3)
	end
	
	return skillLinesNotFound

end

local function CheckCPrespec(cpData)

	local letsGo = false
	local returnCode = SUPERSTAR_NOWARNING
	
	-- blocked
	if not AreChampionPointsActive() then
		returnCode = SUPERSTAR_INVALID_CHAMPION
		return letsGo, returnCode
	end
	
	-- blocked
	if GetUnitChampionPoints("player") < cpData.pointsRequired then
		returnCode = SUPERSTAR_NOT_ENOUGHT_CP
		return letsGo, returnCode
	end
	
	letsGo = true
	
	return letsGo, returnCode
		
end

function ShowRespecScene(favoriteIndex, mode)
	
	local hash = db.favoritesList[favoriteIndex].hash
	local favName = db.favoritesList[favoriteIndex].name
	local attrData, skillsData, cpData = CheckImportedBuild(hash)
	
	if mode == RESPEC_MODE_SP then
		
		if skillsData then
		
			LSF:Initialize(skillsData.classId, skillsData.raceId)
			LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarRespec")
			
			local doRespec, returnCode = CheckSPrespec(skillsData)
			
			if doRespec then
				
				skillsDataForRespec = skillsData
				skillsDataForRespec.noRace = returnCode == SUPERSTAR_INVALID_RACE
				
				SuperStarXMLRespec:GetNamedChild("Title"):SetText(zo_strformat(SUPERSTAR_RESPEC_SPTITLE, favName))
				SuperStarXMLRespec:GetNamedChild("Warning"):SetText(GetString(SUPERSTAR_RESPEC_SKILLLINES_MISSING))
				SuperStarXMLRespec:GetNamedChild("SkillLines"):SetText(CheckRespecSkillLines())
				SuperStarXMLRespec:GetNamedChild("Respec"):SetHidden(false)
				
			else
				SuperStarXMLRespec:GetNamedChild("Title"):SetText(zo_strformat(SUPERSTAR_RESPEC_SPTITLE, favName))
				SuperStarXMLRespec:GetNamedChild("Warning"):SetText(GetString("SUPERSTAR_RESPEC_ERROR", returnCode))
				SuperStarXMLRespec:GetNamedChild("SkillLines"):SetText("")
				SuperStarXMLRespec:GetNamedChild("Respec"):SetHidden(true)
				skillsDataForRespec = nil
			end
			
		else
			-- Build error
		end
	elseif mode == RESPEC_MODE_CP then
		
		if cpData then
		
			LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarRespec")
			
			local doRespec, returnCode = CheckCPrespec(cpData)
			
			if doRespec then
				
				cpDataForRespec = cpData
				
				SuperStarXMLRespec:GetNamedChild("Title"):SetText(zo_strformat(SUPERSTAR_RESPEC_CPTITLE, favName))
				SuperStarXMLRespec:GetNamedChild("Warning"):SetText(zo_strformat(GetString(SUPERSTAR_RESPEC_CPREQUIRED), cpData.pointsRequired))
				SuperStarXMLRespec:GetNamedChild("SkillLines"):SetText("")
				SuperStarXMLRespec:GetNamedChild("Respec"):SetHidden(false)
				
			else
				SuperStarXMLRespec:GetNamedChild("Title"):SetText(zo_strformat(SUPERSTAR_RESPEC_CPTITLE, favName))
				SuperStarXMLRespec:GetNamedChild("Warning"):SetText(GetString("SUPERSTAR_RESPEC_ERROR", returnCode))
				SuperStarXMLRespec:GetNamedChild("SkillLines"):SetText("")
				SuperStarXMLRespec:GetNamedChild("Respec"):SetHidden(true)
				cpDataForRespec = nil
			end
			
		else
			-- Build error
		end
		
	end
	
end

function SuperStar_DoRespec()
	if skillsDataForRespec then
		AnnounceSPRespecStarted(skillsDataForRespec.pointsRequired)
		RespecSkillsSpendPoints(skillsDataForRespec, 1, 1, 1, 0, skillsDataForRespec.noRace, 1)
		SuperStar_ToggleSuperStarPanel()
	elseif cpDataForRespec then
		RespecCPPoints(cpDataForRespec)
	end
end

-- Main Scene

-- Called by XML
function SuperStar_HoverRowOfSlot(control)

	InitializeTooltip(SuperStarAbilityTooltip, control, TOPLEFT, 5, 5, BOTTOMRIGHT)
	SuperStarAbilityTooltip:SetAbilityId(control.abilityId)

end

-- Called by XML
function SuperStar_ExitRowOfSlot(control)
	ClearTooltip(SuperStarAbilityTooltip)
end

-- Called by XML
function SuperStar_HoverRowOfCSkill(control)
	InitializeTooltip(SuperStarCSkillTooltip, control, TOPLEFT, 5, 5, BOTTOMRIGHT)
	SuperStarCSkillTooltip:SetChampionSkillAbility(control.disciplineIndex, control.skillIndex, control.skillLevel)
end

-- Called by XML
function SuperStar_ExitRowOfCSkill(control)
	ClearTooltip(SuperStarCSkillTooltip)
end

-- Called by XML
function SuperStar_HoverRowOfStuff(control)

	if control.itemLink then
		InitializeTooltip(SuperStarItemTooltip, control, TOPLEFT, 5, 5, BOTTOMRIGHT)
		SuperStarItemTooltip:SetLink(control.itemLink)
	end
	
end

-- Called by XML
function SuperStar_ExitRowOfStuff(control)
	ClearTooltip(SuperStarItemTooltip)
end

local function SwapSniffer(_, isSwap)
	
	local function GetWeaponIconPair(firstWeapon, secondWeapon)
		
		if firstWeapon ~= WEAPONTYPE_NONE then
			if firstWeapon == WEAPONTYPE_FIRE_STAFF then
				return "/esoui/art/icons/progression_tabicon_damagestaff_up.dds"
			elseif firstWeapon == WEAPONTYPE_FROST_STAFF then
				return "/esoui/art/icons/icon_icestaff.dds"
			elseif firstWeapon == WEAPONTYPE_LIGHTNING_STAFF then
				return "/esoui/art/icons/icon_lightningstaff.dds"
			elseif firstWeapon == WEAPONTYPE_HEALING_STAFF then
				return "/esoui/art/icons/progression_tabicon_healstaff_up.dds"
			elseif firstWeapon == WEAPONTYPE_TWO_HANDED_AXE then
				return "/esoui/art/icons/icon_2handed.dds"
			elseif firstWeapon == WEAPONTYPE_TWO_HANDED_HAMMER then
				return "/esoui/art/icons/icon_2handed.dds"
			elseif firstWeapon == WEAPONTYPE_TWO_HANDED_SWORD then
				return "/esoui/art/icons/icon_2handed.dds"
			elseif firstWeapon == WEAPONTYPE_BOW then
				return "/esoui/art/icons/progression_tabicon_bow_inactive.dds"
			elseif secondWeapon ~= WEAPONTYPE_NONE and secondWeapon ~= WEAPONTYPE_SHIELD then
				return "/esoui/art/icons/progression_tabicon_dualwield_up.dds"
			else
				return "/esoui/art/icons/icon_1handed.dds"
			end
		else
			return ""
		end
		
	end
	
	local function CheckSwap(isSwap)
	
		if isSwap then
			
			local activeWeapon, locked = GetActiveWeaponPairInfo()
			local firstWeapon, secondWeapon
			
			if (locked) and GetUnitLevel("player") > GetWeaponSwapUnlockedLevel() and GetUnitClassId("player") == CLASS_SORCERER then
			
				-- Sorcerer Overcharge 3rd bar (or werewolf bar, I guess)
				actionBarConfig[3] =
				{
					slot1 = GetSlotBoundId(3),
					slot2 = GetSlotBoundId(4),
					slot3 = GetSlotBoundId(5),
					slot4 = GetSlotBoundId(6),
					slot5 = GetSlotBoundId(7),
					slot6 = GetSlotBoundId(8),
					weaponIconPair = GetClassIcon(GetUnitClassId("player")),
				}
				
			else
			
				if activeWeapon == ACTIVE_WEAPON_PAIR_MAIN then
					firstWeapon = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
					secondWeapon = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_OFF_HAND)
				elseif activeWeapon == ACTIVE_WEAPON_PAIR_BACKUP then
					firstWeapon = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
					secondWeapon = GetItemWeaponType(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)
				end
				
				actionBarConfig[activeWeapon] =
				{
					slot1 = GetSlotBoundId(3),
					slot2 = GetSlotBoundId(4),
					slot3 = GetSlotBoundId(5),
					slot4 = GetSlotBoundId(6),
					slot5 = GetSlotBoundId(7),
					slot6 = GetSlotBoundId(8),
					weaponIconPair = GetWeaponIconPair(firstWeapon, secondWeapon),
				}
				
			end
			
		end
		
	end
	
	-- After a swap, there is a small delay where swap is impossible and "locked" state from GetActiveWeaponPairInfo() returns true. so delay our check with 0.5s.
	zo_callLater(function() CheckSwap(isSwap) end, 500)

end

local function GetActiveFoodTypeBonus()
	
	local isFoodBudd = {
		[61259] = FOOD_BUFF_MAX_HEALTH,
		[61260] = FOOD_BUFF_MAX_MAGICKA,
		[61261] = FOOD_BUFF_MAX_STAMINA,
		[61322] = FOOD_BUFF_REGEN_HEALTH,
		[61325] = FOOD_BUFF_REGEN_MAGICKA,
		[61328] = FOOD_BUFF_REGEN_STAMINA,
		[61257] = FOOD_BUFF_MAX_HEALTH_MAGICKA,
		[61255] = FOOD_BUFF_MAX_HEALTH_STAMINA,
		[61294] = FOOD_BUFF_MAX_MAGICKA_STAMINA,
		[72816] = FOOD_BUFF_REGEN_HEALTH_MAGICKA,
		[61340] = FOOD_BUFF_REGEN_HEALTH_STAMINA,
		[61345] = FOOD_BUFF_REGEN_MAGICKA_STAMINA,
		[61218] = FOOD_BUFF_MAX_ALL,
		[61350] = FOOD_BUFF_REGEN_ALL,
		[72822] = FOOD_BUFF_MAX_HEALTH_REGEN_HEALTH,
		[72816] = FOOD_BUFF_MAX_HEALTH_REGEN_MAGICKA,
		[72819] = FOOD_BUFF_MAX_HEALTH_REGEN_STAMINA,
		[72824] = FOOD_BUFF_MAX_HEALTH_REGEN_ALL,
		[68411] = FOOD_BUFF_MAX_ALL, -- Crown store
		[68416] = FOOD_BUFF_REGEN_ALL, -- Crown store
		[84681] = FOOD_BUFF_MAX_MAGICKA_STAMINA, -- 2h Witches event
		[84709] = FOOD_BUFF_MAX_MAGICKA_REGEN_STAMINA, -- 2h Witches event
		[84725] = FOOD_BUFF_MAX_MAGICKA_REGEN_HEALTH, -- 2h Witches event
		[84678] = FOOD_BUFF_MAX_MAGICKA, -- 2h Witches event
		[84704] = FOOD_BUFF_REGEN_ALL, -- 2h Witches event
		[84720] = FOOD_BUFF_MAX_MAGICKA_REGEN_MAGICKA, -- 2h Witches event
		[84700] = FOOD_BUFF_REGEN_HEALTH_MAGICKA, -- 2h Witches event
		[84731] = FOOD_BUFF_MAX_HEALTH_MAGICKA_REGEN_MAGICKA, -- 2h Witches event
		[84735] = FOOD_BUFF_MAX_HEALTH_MAGICKA_SPECIAL_VAMPIRE, -- 2h Witches event
	}
	
	local numBuffs = GetNumBuffs("player")
	local hasActiveEffects = numBuffs > 0
	if (hasActiveEffects) then
		for i = 1, numBuffs do
			local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
			if isFoodBudd[abilityId] then
				return isFoodBudd[abilityId]
			end
		end
	end
	
	return FOOD_BUFF_NONE
	
end

local function BuildMainSceneValues(control)
	
	local SUPERSTAR_GENERIC_NA = "N/A"
	
	-- Level / CPRank
	local LevelValue = control:GetNamedChild("LevelValue")
	local CPIcon = control:GetNamedChild("CPIcon")
	
	local playerCPRank = GetUnitChampionPoints("player") or 0
	
	local playerLevel = GetUnitLevel("player")
	local showCPIcon
	local maxStuffRank = GetMaxLevel()
	
	if playerCPRank > 0 then
		maxStuffRank = math.min(GetChampionPointsPlayerProgressionCap(), playerCPRank)
		showCPIcon = true
	end
	
	LevelValue:SetText(GetLevelOrChampionPointsStringNoIcon(playerLevel, playerCPRank))
	
	CPIcon:SetTexture(GetChampionPointsIcon())
	CPIcon:SetHidden(not showCPIcon)
	
	-- Class / Race
	local ClassAndRaceValue = control:GetNamedChild("ClassAndRaceValue")
	ClassAndRaceValue:SetText(zo_strformat(SI_STATS_RACE_CLASS, GetUnitRace("player"), GetUnitClass("player")))
	
	-- Ava Rank
	
	local playerAlliance = GetUnitAlliance("player")	
	local AllianceTexture = control:GetNamedChild("AllianceTexture")
	local AvaRankTexture = control:GetNamedChild("AvaRankTexture")
	local AvaRankName = control:GetNamedChild("AvaRankName")
	local AvaRankValue = control:GetNamedChild("AvaRankValue")
	
	AllianceTexture:SetTexture(GetLargeAllianceSymbolIcon(playerAlliance))
	local rank = GetUnitAvARank("player")
	
	AvaRankValue:SetText(rank)
	AvaRankName:SetText(zo_strformat(SI_STAT_RANK_NAME_FORMAT, GetAvARankName(GetUnitGender("player"), rank)))
	AvaRankTexture:SetTexture(GetLargeAvARankIcon(rank))
	
	-- Skill points
	
	local SkillPointsValue = control:GetNamedChild("SkillPointsValue")
	SkillPointsValue:SetText(SuperStarSkills.spentSkillPoints)
	
	-- Champion Points
	
	local ChampionPointsValue = control:GetNamedChild("ChampionPointsValue")
	
	local isCPUnlocked = IsChampionSystemUnlocked()
	if isCPUnlocked then
		ChampionPointsValue:SetText(GetPlayerChampionPointsEarned())
		if GetPlayerChampionPointsEarned() > GetMaxSpendableChampionPointsInAttribute() * 3 then
			ChampionPointsValue:SetText(GetPlayerChampionPointsEarned() .. " |cFF0000(+" .. (GetPlayerChampionPointsEarned() - GetMaxSpendableChampionPointsInAttribute() * 3) .. ")|r")
		end
	else
		ChampionPointsValue:SetText(ZO_DISABLED_TEXT:Colorize(SUPERSTAR_GENERIC_NA))
	end
	
	-- Active Skills
	
	local ActiveMWeapon = control:GetNamedChild("ActiveMWeapon")
	local ActiveMSkill1 = control:GetNamedChild("ActiveMSkill1")
	local ActiveMSkill2 = control:GetNamedChild("ActiveMSkill2")
	local ActiveMSkill3 = control:GetNamedChild("ActiveMSkill3")
	local ActiveMSkill4 = control:GetNamedChild("ActiveMSkill4")
	local ActiveMSkill5 = control:GetNamedChild("ActiveMSkill5")
	local ActiveMSkill6 = control:GetNamedChild("ActiveMSkill6")
	
	local ActiveOWeapon = control:GetNamedChild("ActiveOWeapon")
	local ActiveOSkill1 = control:GetNamedChild("ActiveOSkill1")
	local ActiveOSkill2 = control:GetNamedChild("ActiveOSkill2")
	local ActiveOSkill3 = control:GetNamedChild("ActiveOSkill3")
	local ActiveOSkill4 = control:GetNamedChild("ActiveOSkill4")
	local ActiveOSkill5 = control:GetNamedChild("ActiveOSkill5")
	local ActiveOSkill6 = control:GetNamedChild("ActiveOSkill6")
	
	local ActiveSWeapon = control:GetNamedChild("ActiveSWeapon")
	local ActiveSSkill1 = control:GetNamedChild("ActiveSSkill1")
	local ActiveSSkill2 = control:GetNamedChild("ActiveSSkill2")
	local ActiveSSkill3 = control:GetNamedChild("ActiveSSkill3")
	local ActiveSSkill4 = control:GetNamedChild("ActiveSSkill4")
	local ActiveSSkill5 = control:GetNamedChild("ActiveSSkill5")
	local ActiveSSkill6 = control:GetNamedChild("ActiveSSkill6")
	
	local ActivateSwapPlaceHolder = control:GetNamedChild("ActivateSwapPlaceHolder")
	
	ActiveMWeapon:SetHidden(true)
	ActiveOWeapon:SetHidden(true)
	ActiveSWeapon:SetHidden(true)
	
	local function ShowSlotTexture(control, abilityId)
		if type(abilityId) == "number" and abilityId ~= 0 then
			control:SetTexture(GetAbilityIcon(abilityId))
			control:SetHidden(false)
			control.abilityId = abilityId
		elseif type(abilityId) == "string" and abilityId ~= "" then
			control:SetTexture(abilityId)
			control:SetHidden(false)
		else
			control:SetHidden(true)
		end
	end
	
	ShowSlotTexture(ActiveMSkill1, GetSlotBoundId(3))
	ShowSlotTexture(ActiveMSkill2, GetSlotBoundId(4))
	ShowSlotTexture(ActiveMSkill3, GetSlotBoundId(5))
	ShowSlotTexture(ActiveMSkill4, GetSlotBoundId(6))
	ShowSlotTexture(ActiveMSkill5, GetSlotBoundId(7))
	ShowSlotTexture(ActiveMSkill6, GetSlotBoundId(8))
	
	ShowSlotTexture(ActiveOSkill1, 0)
	ShowSlotTexture(ActiveOSkill2, 0)
	ShowSlotTexture(ActiveOSkill3, 0)
	ShowSlotTexture(ActiveOSkill4, 0)
	ShowSlotTexture(ActiveOSkill5, 0)
	ShowSlotTexture(ActiveOSkill6, 0)
	
	ShowSlotTexture(ActiveSSkill1, 0)
	ShowSlotTexture(ActiveSSkill2, 0)
	ShowSlotTexture(ActiveSSkill3, 0)
	ShowSlotTexture(ActiveSSkill4, 0)
	ShowSlotTexture(ActiveSSkill5, 0)
	ShowSlotTexture(ActiveSSkill6, 0)
	
	if actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN] and actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP] then
	
		ShowSlotTexture(ActiveMWeapon, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].weaponIconPair)
		ShowSlotTexture(ActiveMSkill1, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot1)
		ShowSlotTexture(ActiveMSkill2, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot2)
		ShowSlotTexture(ActiveMSkill3, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot3)
		ShowSlotTexture(ActiveMSkill4, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot4)
		ShowSlotTexture(ActiveMSkill5, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot5)
		ShowSlotTexture(ActiveMSkill6, actionBarConfig[ACTIVE_WEAPON_PAIR_MAIN].slot6)
		
		ShowSlotTexture(ActiveOWeapon, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].weaponIconPair)
		ShowSlotTexture(ActiveOSkill1, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot1)
		ShowSlotTexture(ActiveOSkill2, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot2)
		ShowSlotTexture(ActiveOSkill3, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot3)
		ShowSlotTexture(ActiveOSkill4, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot4)
		ShowSlotTexture(ActiveOSkill5, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot5)
		ShowSlotTexture(ActiveOSkill6, actionBarConfig[ACTIVE_WEAPON_PAIR_BACKUP].slot6)
		
		ActivateSwapPlaceHolder:SetHidden(true)
		
	elseif playerLevel >= GetWeaponSwapUnlockedLevel() then
		ActivateSwapPlaceHolder:SetHidden(false)
	elseif playerLevel < GetWeaponSwapUnlockedLevel() then
		ActivateSwapPlaceHolder:SetHidden(true)
	end
	
	-- Attribute Stats
	
	local MagickaAttributeLabel = control:GetNamedChild("MagickaAttributeLabel")
	local HealthAttributeLabel = control:GetNamedChild("HealthAttributeLabel")
	local StaminaAttributeLabel = control:GetNamedChild("StaminaAttributeLabel")
	local MagickaAttributePoints = control:GetNamedChild("MagickaAttributePoints")
	local HealthAttributePoints = control:GetNamedChild("HealthAttributePoints")
	local StaminaAttributePoints = control:GetNamedChild("StaminaAttributePoints")
	local MagickaAttributeRegen = control:GetNamedChild("MagickaAttributeRegen")
	local HealthAttributeRegen = control:GetNamedChild("HealthAttributeRegen")
	local StaminaAttributeRegen = control:GetNamedChild("StaminaAttributeRegen")
	
	MagickaAttributeLabel:SetText(GetAttributeSpentPoints(ATTRIBUTE_MAGICKA))
	HealthAttributeLabel:SetText(GetAttributeSpentPoints(ATTRIBUTE_HEALTH))
	StaminaAttributeLabel:SetText(GetAttributeSpentPoints(ATTRIBUTE_STAMINA))
	
	MagickaAttributePoints:SetText(GetPlayerStat(STAT_MAGICKA_MAX))
	HealthAttributePoints:SetText(GetPlayerStat(STAT_HEALTH_MAX))
	StaminaAttributePoints:SetText(GetPlayerStat(STAT_STAMINA_MAX))
	
	MagickaAttributeRegen:SetText(GetPlayerStat(STAT_MAGICKA_REGEN_COMBAT))
	HealthAttributeRegen:SetText(GetPlayerStat(STAT_HEALTH_REGEN_COMBAT))
	StaminaAttributeRegen:SetText(GetPlayerStat(STAT_STAMINA_REGEN_COMBAT))
	
	-- Vampirism / WW
	local VampWWVIcon = control:GetNamedChild("VampWWVIcon")
	local VampWWValue = control:GetNamedChild("VampWWValue")
	
	local VampWW = {
		[35658]	= true,	-- Lycantropy
		[35771]	= true,	-- Vampirism: Stage 1
		[35776]	= true,	-- Vampirism: Stage 2
		[35783]	= true,	-- Vampirism: Stage 3
		[35792]	= true,	-- Vampirism: Stage 4
	}
	
	local numBuffs = GetNumBuffs("player")
	local hasActiveEffects = numBuffs > 0
	local activeVampWW = {}
	
	if (hasActiveEffects) then
		for i = 1, numBuffs do
			local _, _, _, _, _, iconFilename, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
			if VampWW[abilityId] then
				table.insert(activeVampWW, {abilityId = abilityId, iconFilename = iconFilename})
			end
		end
	end
	
	if #activeVampWW == 0 then
		VampWWVIcon:SetHidden(true)
		VampWWValue:SetHidden(true)
	elseif #activeVampWW == 1 then
		VampWWVIcon:SetTexture(activeVampWW[1].iconFilename)
		VampWWValue:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, GetAbilityName(activeVampWW[1].abilityId)))
		VampWWVIcon:SetHidden(false)
		VampWWValue:SetHidden(false)
	end
	
	-- Mundus
	local MundusBoonIcon = control:GetNamedChild("MundusBoonIcon")
	MundusBoonIcon:SetTexture(GetAbilityIcon(13940))
	local MundusBoonValue = control:GetNamedChild("MundusBoonValue")
	
	local MundusBoonIcon2 = control:GetNamedChild("MundusBoonIcon2")
	MundusBoonIcon2:SetTexture(GetAbilityIcon(13940))
	local MundusBoonValue2 = control:GetNamedChild("MundusBoonValue2")
	
	local mundusBoons = {
		[13940]	= true,	-- Boon: The Warrior
		[13943]	= true,	-- Boon: The Mage
		[13974]	= true,	-- Boon: The Serpent
		[13975]	= true,	-- Boon: The Thief
		[13976]	= true,	-- Boon: The Lady
		[13977]	= true,	-- Boon: The Steed
		[13978]	= true,	-- Boon: The Lord
		[13979]	= true,	-- Boon: The Apprentice
		[13980]	= true,	-- Boon: The Ritual
		[13981]	= true,	-- Boon: The Lover
		[13982]	= true,	-- Boon: The Atronach
		[13984]	= true,	-- Boon: The Shadow
		[13985]	= true,	-- Boon: The Tower
	}
	
	-- Many Thanks to Srendarr
	local undesiredBuffs  = {
		[29667] = true,		-- Concentration (Light Armour)
		[40359] = true,		-- Fed On Ally (Vampire)
		[45569] = true,		-- Medicinal Use (Alchemy)
		[62760] = true,		-- Spell Shield (Champion Point Ability)
		[63601] = true,		-- ESO Plus Member
		[64160] = true,		-- Crystal Fragments Passive (Not Timed)
		[36603] = true,		-- Soul Siphoner Passive I
		[45155] = true,		-- Soul Siphoner Passive II
		[57472] = true,		-- Rapid Maneuver (Extra Aura)
		[57475] = true,		-- Rapid Maneuver (Extra Aura)
		[57474] = true,		-- Rapid Maneuver (Extra Aura)
		[57476] = true,		-- Rapid Maneuver (Extra Aura)
		[57480]	= true,		-- Rapid Maneuver (Extra Aura)
		[57481]	= true,		-- Rapid Maneuver (Extra Aura)
		[57482]	= true,		-- Rapid Maneuver (Extra Aura)
		[64945] = true,		-- Guard Regen (Guarded Extra)
		[64946] = true,		-- Guard Regen (Guarded Extra)
		[46672] = true,		-- Propelling Shield (Extra Aura)
		[42197] = true,		-- Spinal Surge (Extra Aura)
		[42198] = true,		-- Spinal Surge (Extra Aura)
		[62587] = true,		-- Focused Aim (2s Refreshing Aura)
		[42589] = true,		-- Flawless Dawnbreaker (2s aura on Weaponswap)
		[40782] = true,		-- Acid Spray (Extra Aura)
		[14890]	= true,		-- Brace (Generic)
		[39269] = true,		-- Soul Summons (Rank 1)
		[43752] = true,		-- Soul Summons (Rank 2)
		[45590] = true,		-- Soul Summons (Rank 2)
		[35658] = true,		-- Lycanthropy
		[35771]	= true,		-- Stage 1 Vampirism (trivia: has a duration even though others don't)
		[35773]	= true,		-- Stage 2 Vampirism
		[35780]	= true,		-- Stage 3 Vampirism
		[35786]	= true,		-- Stage 4 Vampirism
		[35792]	= true,		-- Stage 4 Vampirism
		[39472] = true,		-- Vampirism
		[40521] = true,		-- Sanies Lupinus
		[40525] = true,		-- Bit an ally
		[40539] = true,		-- Fed on ally
	}
	
	local foodBuffs = {}
	
	local numBuffs = GetNumBuffs("player")
	local hasActiveEffects = numBuffs > 0
	local activeBoons = {}
	local activeBuff = {}
	
	if (hasActiveEffects) then
		for i = 1, numBuffs do
			local _, _, _, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
			if mundusBoons[abilityId] then
				table.insert(activeBoons, abilityId)
			elseif not undesiredBuffs[abilityId] then
				table.insert(activeBuff, abilityId)
			end
		end
	end
	
	local foodBonus = GetActiveFoodTypeBonus()
	local FoodBonusControl = {}
	FoodBonusControl[FOOD_BUFF_MAX_HEALTH] = control:GetNamedChild("MaxHealth")
	FoodBonusControl[FOOD_BUFF_MAX_MAGICKA] = control:GetNamedChild("MaxMagicka")
	FoodBonusControl[FOOD_BUFF_MAX_STAMINA] = control:GetNamedChild("MaxStamina")
	FoodBonusControl[FOOD_BUFF_REGEN_HEALTH] = control:GetNamedChild("RegenHealth")
	FoodBonusControl[FOOD_BUFF_REGEN_MAGICKA] = control:GetNamedChild("RegenMagicka")
	FoodBonusControl[FOOD_BUFF_REGEN_STAMINA] = control:GetNamedChild("RegenStamina")
	
	FoodBonusControl[FOOD_BUFF_MAX_HEALTH]:SetHidden(true)
	FoodBonusControl[FOOD_BUFF_MAX_MAGICKA]:SetHidden(true)
	FoodBonusControl[FOOD_BUFF_MAX_STAMINA]:SetHidden(true)
	FoodBonusControl[FOOD_BUFF_REGEN_HEALTH]:SetHidden(true)
	FoodBonusControl[FOOD_BUFF_REGEN_MAGICKA]:SetHidden(true)
	FoodBonusControl[FOOD_BUFF_REGEN_STAMINA]:SetHidden(true)
	
	if foodBonus > FOOD_BUFF_NONE then
		
		if foodBonus > FOOD_BUFF_SPECIAL_VAMPIRE then
			foodBonus = foodBonus - FOOD_BUFF_SPECIAL_VAMPIRE -- Vampire mess the UI
		end
		
		local vals = {FOOD_BUFF_MAX_HEALTH, FOOD_BUFF_MAX_MAGICKA, FOOD_BUFF_MAX_STAMINA, FOOD_BUFF_REGEN_HEALTH, FOOD_BUFF_REGEN_MAGICKA, FOOD_BUFF_REGEN_STAMINA}
		local i = #vals
		
		while foodBonus ~= 0 and i > 0 do
			if vals[i] <= foodBonus then
				foodBonus = foodBonus - vals[i]
				FoodBonusControl[vals[i]]:SetHidden(false)
			end
			i = i - 1
		end
	end

	if #activeBoons == 0 then
		MundusBoonValue:SetText(SUPERSTAR_GENERIC_NA)
		MundusBoonIcon2:SetHidden(true)
		MundusBoonValue2:SetHidden(true)
	elseif #activeBoons == 1 then
		MundusBoonValue:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, GetAbilityName(activeBoons[1])))
		MundusBoonIcon2:SetHidden(true)
		MundusBoonValue2:SetHidden(true)
	else
		MundusBoonValue:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, GetAbilityName(activeBoons[1])))
		MundusBoonValue2:SetText(zo_strformat(SI_ABILITY_TOOLTIP_NAME, GetAbilityName(activeBoons[2])))
		MundusBoonIcon2:SetHidden(false)
		MundusBoonValue2:SetHidden(false)
	end
	
	for i=1, 9 do
		if activeBuff[i] then
			local BuffIcon = control:GetNamedChild("BuffIcon" .. i)
			BuffIcon:SetHidden(false)
			BuffIcon:SetTexture(GetAbilityIcon(activeBuff[i]))
		else
			local BuffIcon = control:GetNamedChild("BuffIcon" .. i)
			BuffIcon:SetHidden(true)
		end
	end
	
	-- Magicka Stamina Dmg, Crit chance, Resist, Penetration
	local MagickaDmg = control:GetNamedChild("MagickaDmg")
	local StaminaDmg = control:GetNamedChild("StaminaDmg")
	local MagickaCrit = control:GetNamedChild("MagickaCrit")
	local StaminaCrit = control:GetNamedChild("StaminaCrit")
	local MagickaCritPercent = control:GetNamedChild("MagickaCritPercent")
	local StaminaCritPercent = control:GetNamedChild("StaminaCritPercent")
	local MagickaPene = control:GetNamedChild("MagickaPene")
	local StaminaPene = control:GetNamedChild("StaminaPene")
	local MagickaResist = control:GetNamedChild("MagickaResist")
	local StaminaResist = control:GetNamedChild("StaminaResist")
	local MagickaResistPercent = control:GetNamedChild("MagickaResistPercent")
	local StaminaResistPercent = control:GetNamedChild("StaminaResistPercent")
	
	local magickaColor = GetItemQualityColor(ITEM_QUALITY_ARCANE)
	local staminaColor = GetItemQualityColor(ITEM_QUALITY_MAGIC)
	
	MagickaDmg:SetText(GetPlayerStat(STAT_SPELL_POWER))
	StaminaDmg:SetText(GetPlayerStat(STAT_POWER))
	
	MagickaDmg:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaDmg:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	local spellCritical = GetPlayerStat(STAT_SPELL_CRITICAL)
	local weaponCritical = GetPlayerStat(STAT_CRITICAL_STRIKE)
	
	MagickaCrit:SetText(spellCritical)
	StaminaCrit:SetText(weaponCritical)
	
	MagickaCrit:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaCrit:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	MagickaCritPercent:SetText(zo_strformat(SI_STAT_VALUE_PERCENT, GetCriticalStrikeChance(spellCritical, true)))
	StaminaCritPercent:SetText(zo_strformat(SI_STAT_VALUE_PERCENT, GetCriticalStrikeChance(weaponCritical, true)))
	
	MagickaCritPercent:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaCritPercent:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	MagickaPene:SetText(GetPlayerStat(STAT_SPELL_PENETRATION))
	StaminaPene:SetText(GetPlayerStat(STAT_PHYSICAL_PENETRATION))
	
	MagickaPene:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaPene:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	local spellResist = GetPlayerStat(STAT_SPELL_RESIST)
	local weaponResist = GetPlayerStat(STAT_PHYSICAL_RESIST)
	
	MagickaResist:SetText(spellResist)
	StaminaResist:SetText(weaponResist)
	
	MagickaResist:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaResist:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	local championPointsForStatsCalculation = math.min(playerCPRank, GetChampionPointsPlayerProgressionCap()) / 10
	local spellResistPercent = (spellResist-100)/((playerLevel + championPointsForStatsCalculation) * 10)
	local weaponResistPercent = (weaponResist-100)/((playerLevel + championPointsForStatsCalculation) * 10)
	
	MagickaResistPercent:SetText(zo_strformat(SI_STAT_VALUE_PERCENT, spellResistPercent))
	StaminaResistPercent:SetText(zo_strformat(SI_STAT_VALUE_PERCENT, weaponResistPercent))
	
	MagickaResistPercent:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
	StaminaResistPercent:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
	
	if spellResistPercent >= 50 then
		MagickaResistPercent:SetColor(1, 0, 0)
	end
	
	if weaponResistPercent >= 50 then
		StaminaResistPercent:SetColor(1, 0, 0)
	end
	
	-- Stuff
	
	local slots =
	{
		[EQUIP_SLOT_HEAD]	   = true,
		[EQUIP_SLOT_NECK]	   = true,
		[EQUIP_SLOT_CHEST]	  = true,
		[EQUIP_SLOT_SHOULDERS]  = true,
		[EQUIP_SLOT_MAIN_HAND]  = true,
		[EQUIP_SLOT_OFF_HAND]   = true,
		[EQUIP_SLOT_WAIST]	  = true,
		[EQUIP_SLOT_LEGS]	   = true,
		[EQUIP_SLOT_FEET]	   = true,
		[EQUIP_SLOT_RING1]	  = true,
		[EQUIP_SLOT_RING2]	  = true,
		[EQUIP_SLOT_HAND]	   = true,
		[EQUIP_SLOT_BACKUP_MAIN]= true,
		[EQUIP_SLOT_BACKUP_OFF] = true,
	}
	
	local poisons = {
		[EQUIP_SLOT_POISON] = EQUIP_SLOT_MAIN_HAND,
		[EQUIP_SLOT_BACKUP_POISON] = EQUIP_SLOT_BACKUP_MAIN,
	}
	
	local SSslotData = {}
	local setEquipped = {}
	
	for slotId in pairs(slots) do
	
		local itemLink = GetItemLink(BAG_WORN, slotId)
		
		SSslotData[slotId] = {}
		if GetString("SUPERSTAR_SLOTNAME", slotId) ~= "" then
			SSslotData[slotId].slotName = GetString("SUPERSTAR_SLOTNAME", slotId)
		else
			SSslotData[slotId].slotName = zo_strformat(SI_ITEM_FORMAT_STR_BROAD_TYPE, GetString("SI_EQUIPSLOT", slotId))
		end
		
		if itemLink ~= "" then
			local name = GetItemLinkName(itemLink)
			local isMaelstrom = string.find(name, GetString(SUPERSTAR_MAELSTROM_WEAPON))
			local requiredLevel = GetItemLinkRequiredLevel(itemLink)
			local requiredCPRank = GetItemLinkRequiredChampionPoints(itemLink)
			local traitType, traitDescription = GetItemLinkTraitInfo(itemLink)
			local hasCharges, enchantHeader, enchantDescription = GetItemLinkEnchantInfo(itemLink)
			local quality = GetItemLinkQuality(itemLink)
			local armorType = GetItemLinkArmorType(itemLink) 
			local icon = GetItemLinkInfo(itemLink)
			local hasSet, setName, _, numEquipped, maxEquipped = GetItemLinkSetInfo(itemLink, true)
			local setRequires = GetItemLinkSetBonusInfo(itemLink, true, 1)
			
			name = GetItemQualityColor(quality):Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, name))
			
			if hasSet then
				if not setEquipped[setName] then
					setEquipped[setName] = {
						numEquipped = numEquipped,
						maxEquipped = maxEquipped,
						enabled = numEquipped >= setRequires,
					}
					
					if setEquipped[setName].enabled then
						name = zo_strformat("<<1>> " .. GetItemQualityColor(ITEM_QUALITY_MAGIC):Colorize(("Set: <<2>>/<<3>>")), name, setEquipped[setName].numEquipped, setEquipped[setName].maxEquipped)
					else
						name = zo_strformat("<<1>> |cFF0000Set: <<2>>/<<3>>|r", name, setEquipped[setName].numEquipped, setEquipped[setName].maxEquipped)
					end
					
				end
			end
			
			local requiredFormattedLevel
			if requiredCPRank > 0 then
				requiredFormattedLevel = "|t32:32:" .. GetChampionPointsIcon() .. "|t" .. requiredCPRank
			else
				requiredFormattedLevel = requiredLevel
			end
			
			local traitName
			if(traitType ~= ITEM_TRAIT_TYPE_NONE and traitType ~= ITEM_TRAIT_TYPE_SPECIAL_STAT and traitDescription ~= "") then
				traitName = GetString("SI_ITEMTRAITTYPE", traitType)
			else
				traitName = SUPERSTAR_GENERIC_NA
			end
			
			if enchantDescription == "" then
				enchantDescription = SUPERSTAR_GENERIC_NA
			elseif isMaelstrom and isMaelstrom > 0 then
				enchantDescription = enchantHeader
			else
				enchantDescription = enchantDescription:gsub("\n", " "):gsub(GetString(SUPERSTAR_DESC_ENCHANT_MAX), ""):gsub(GetString(SUPERSTAR_DESC_ENCHANT_SEC), GetString(SUPERSTAR_DESC_ENCHANT_SEC_SHORT))
				enchantDescription = enchantDescription:gsub(GetString(SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG), GetString(SUPERSTAR_DESC_ENCHANT_MAGICKA_DMG_SHORT)):gsub(GetString(SUPERSTAR_DESC_ENCHANT_BASH), GetString(SUPERSTAR_DESC_ENCHANT_BASH_SHORT))
				enchantDescription = enchantDescription:gsub(GetString(SUPERSTAR_DESC_ENCHANT_REDUCE), GetString(SUPERSTAR_DESC_ENCHANT_REDUCE_SHORT))
			end
			
			SSslotData[slotId].name = name
			SSslotData[slotId].requiredFormattedLevel = requiredFormattedLevel
			SSslotData[slotId].traitName = traitName
			SSslotData[slotId].icon = icon
			SSslotData[slotId].enchantDescription = enchantDescription
			
			SSslotData[slotId].labelControl = control:GetNamedChild("Stuff" .. slotId)
			SSslotData[slotId].valueControl = control:GetNamedChild("StuffValue" .. slotId)
			SSslotData[slotId].levelControl = control:GetNamedChild("StuffLevel" .. slotId)
			SSslotData[slotId].traitControl = control:GetNamedChild("StuffTrait" .. slotId)
			SSslotData[slotId].enchantControl = control:GetNamedChild("StuffEnchant" .. slotId)
			
			SSslotData[slotId].labelControl:SetText(SSslotData[slotId].slotName)
			
			if armorType == ARMORTYPE_HEAVY then
				SSslotData[slotId].labelControl:SetColor(1, 0, 0)
			elseif armorType == ARMORTYPE_MEDIUM then
				SSslotData[slotId].labelControl:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
			elseif armorType == ARMORTYPE_LIGHT then
				SSslotData[slotId].labelControl:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
			end
			
			SSslotData[slotId].valueControl:SetText(SSslotData[slotId].name)
			SSslotData[slotId].valueControl.itemLink = itemLink
			
			if requiredCPRank < maxStuffRank then
				SSslotData[slotId].levelControl:SetColor(1, 0, 0)
			else
				SSslotData[slotId].levelControl:SetColor(1, 1, 1)
			end
			
			SSslotData[slotId].levelControl:SetText(SSslotData[slotId].requiredFormattedLevel)
			SSslotData[slotId].traitControl:SetText(SSslotData[slotId].traitName)
			SSslotData[slotId].enchantControl:SetText(SSslotData[slotId].enchantDescription)
			
		else
			SSslotData[slotId].dontWearSlot = true
			
			SSslotData[slotId].labelControl = control:GetNamedChild("Stuff" .. slotId)
			SSslotData[slotId].labelControl:SetText(SSslotData[slotId].slotName)
			
			SSslotData[slotId].valueControl = control:GetNamedChild("StuffValue" .. slotId)
			SSslotData[slotId].valueControl:SetText(SUPERSTAR_GENERIC_NA)
			
			SSslotData[slotId].levelControl = control:GetNamedChild("StuffLevel" .. slotId)
			SSslotData[slotId].traitControl = control:GetNamedChild("StuffTrait" .. slotId)
			SSslotData[slotId].enchantControl = control:GetNamedChild("StuffEnchant" .. slotId)
			
			SSslotData[slotId].levelControl:SetText(SUPERSTAR_GENERIC_NA)
			SSslotData[slotId].traitControl:SetText(SUPERSTAR_GENERIC_NA)
			SSslotData[slotId].enchantControl:SetText(SUPERSTAR_GENERIC_NA)

		end
		
	end
	
	local function changeQuality(itemLink)

		local quality = ITEM_QUALITY_NORMAL
		
		if quality < ITEM_QUALITY_LEGENDARY then
			for i = 1, GetMaxTraits() do
				
				local hasTraitAbility = GetItemLinkTraitOnUseAbilityInfo(itemLink, i)
				
				if(hasTraitAbility) then
					quality = quality + 1
				end
				
			end
			
			if quality == ITEM_QUALITY_NORMAL then
				quality = ITEM_QUALITY_MAGIC
			end
		end
		
		return quality

	end
	
	for slotId, correspondance in pairs(poisons) do
	
		local itemLink = GetItemLink(BAG_WORN, slotId)
		local itemLinkCorresp = GetItemLink(BAG_WORN, correspondance)
		
		SSslotData[slotId] = {}
		
		if itemLink ~= "" and itemLink ~= "" then
			
			local name = GetItemLinkName(itemLink)
			
			local quality = GetItemLinkQuality(itemLink)
			if select(24, ZO_LinkHandler_ParseLink(itemLink)) ~= "0" then
				quality = changeQuality(quality)
			end
			
			name = GetItemQualityColor(quality):Colorize(zo_strformat(SI_TOOLTIP_ITEM_NAME, name))
			
			SSslotData[correspondance].enchantControl = control:GetNamedChild("StuffEnchant" .. correspondance)
			SSslotData[correspondance].enchantControl:SetText(name)
			
		end
	end
	
	-- CP
	if isCPUnlocked then
		
		for disciplineIndex=1, 9 do
		
			local StarName = control:GetNamedChild("ChampionStarName" .. disciplineIndex)
			
			local SkillName1 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName1")
			local SkillValue1 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue1")
			local SkillName2 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName2")
			local SkillValue2 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue2")
			local SkillName3 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName3")
			local SkillValue3 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue3")
			local SkillName4 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillName4")
			local SkillValue4 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "SkillValue4")
			
			local SkillBonus1 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus1")
			local SkillBonus2 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus2")
			local SkillBonus3 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus3")
			local SkillBonus4 = control:GetNamedChild("ChampionStarName" .. disciplineIndex .. "Bonus4")
			
			local pointsInSkill1 = GetNumPointsSpentOnChampionSkill(disciplineIndex, 1)
			local pointsInSkill2 = GetNumPointsSpentOnChampionSkill(disciplineIndex, 2)
			local pointsInSkill3 = GetNumPointsSpentOnChampionSkill(disciplineIndex, 3)
			local pointsInSkill4 = GetNumPointsSpentOnChampionSkill(disciplineIndex, 4)
			
			local bonusUnlocked1 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 10
			local bonusUnlocked2 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 30
			local bonusUnlocked3 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 75
			local bonusUnlocked4 = GetNumPointsSpentInChampionDiscipline(disciplineIndex) >= 120
			
			SkillName1.disciplineIndex = disciplineIndex
			SkillName1.skillIndex = 1
			SkillName1.skillLevel = 0
			SkillValue1.disciplineIndex = disciplineIndex
			SkillValue1.skillIndex = 1
			SkillValue1.skillLevel = 0
			
			SkillName2.disciplineIndex = disciplineIndex
			SkillName2.skillIndex = 2
			SkillName2.skillLevel = 0
			SkillValue2.disciplineIndex = disciplineIndex
			SkillValue2.skillIndex = 2
			SkillValue2.skillLevel = 0
			
			SkillName3.disciplineIndex = disciplineIndex
			SkillName3.skillIndex = 3
			SkillName3.skillLevel = 0
			SkillValue3.disciplineIndex = disciplineIndex
			SkillValue3.skillIndex = 3
			SkillValue3.skillLevel = 0
			
			SkillName4.disciplineIndex = disciplineIndex
			SkillName4.skillIndex = 4
			SkillName4.skillLevel = 0
			SkillValue4.disciplineIndex = disciplineIndex
			SkillValue4.skillIndex = 4
			SkillValue4.skillLevel = 0
			
			local function EnableCPBonus(control, enable, disciplineIndex, skillIndex, unlockColor)
				control:SetHidden(not enable)
				control.disciplineIndex = disciplineIndex
				control.skillIndex = skillIndex
				control.skillLevel = 0
				control:SetColor(unlockColor.r, unlockColor.g, unlockColor.b)
				control:SetFont("ZoFontGameMini")
			end
			
			EnableCPBonus(SkillBonus1, bonusUnlocked1, disciplineIndex, 5, GetItemQualityColor(ITEM_QUALITY_MAGIC))
			EnableCPBonus(SkillBonus2, bonusUnlocked2, disciplineIndex, 6, GetItemQualityColor(ITEM_QUALITY_ARCANE))
			EnableCPBonus(SkillBonus3, bonusUnlocked3, disciplineIndex, 7, GetItemQualityColor(ITEM_QUALITY_ARTIFACT))
			EnableCPBonus(SkillBonus4, bonusUnlocked4, disciplineIndex, 8, GetItemQualityColor(ITEM_QUALITY_LEGENDARY))
			
			local pointsInDisciple = GetNumPointsSpentInChampionDiscipline(i)
			
			local SUPERSTAR_GENERIC_MINUS = "-"
			if pointsInSkill1 == 0 then pointsInSkill1 = SUPERSTAR_GENERIC_MINUS end
			if pointsInSkill2 == 0 then pointsInSkill2 = SUPERSTAR_GENERIC_MINUS end
			if pointsInSkill3 == 0 then pointsInSkill3 = SUPERSTAR_GENERIC_MINUS end
			if pointsInSkill4 == 0 then pointsInSkill4 = SUPERSTAR_GENERIC_MINUS end
			
			StarName:SetText(zo_strformat(SI_CHAMPION_CONSTELLATION_NAME_FORMAT, GetChampionDisciplineName(disciplineIndex)))
			
			if disciplineIndex >= 2 and disciplineIndex <= 4 then
				StarName:SetColor(1, 0, 0)
			elseif disciplineIndex >= 5 and disciplineIndex <= 7 then
				StarName:SetColor(magickaColor.r, magickaColor.g, magickaColor.b)
			else
				StarName:SetColor(staminaColor.r, staminaColor.g, staminaColor.b)
			end
			
			local function ShortenCPSkillName(discipline, skill)
				if GetString("SUPERSTAR_CHAMPION_SKILL".. discipline .."NAME", skill) ~= "" then
					return GetString("SUPERSTAR_CHAMPION_SKILL".. discipline .."NAME", skill)
				else
					return zo_strformat(SI_SKILLS_ENTRY_NAME_FORMAT, GetChampionSkillName(discipline, skill))
				end
			end
			
			SkillName1:SetText(ShortenCPSkillName(disciplineIndex, 1))
			SkillValue1:SetText(pointsInSkill1)
			SkillName2:SetText(ShortenCPSkillName(disciplineIndex, 2))
			SkillValue2:SetText(pointsInSkill2)
			SkillName3:SetText(ShortenCPSkillName(disciplineIndex, 3))
			SkillValue3:SetText(pointsInSkill3)
			SkillName4:SetText(ShortenCPSkillName(disciplineIndex, 4))
			SkillValue4:SetText(pointsInSkill4)
			
		end
		
	end
	
end

-- Favorites List

local function GetDataByName(name, array)
	local dataList = db[array]
	for index, data in ipairs(dataList) do
		if(data.name == name) then
			return data, index
		end
	end
end

local favoritesList = ZO_SortFilterList:Subclass()

function favoritesList:New(control)
	
	SuperStarSkills.localPlayerHash, SuperStarSkills.localPlayerCRequired, SuperStarSkills.localPlayerSRequired, SuperStarSkills.localPlayerARequired = BuildHashs(true, true, true)
	
	ZO_SortFilterList.InitializeSortFilterList(self, control)
	
	local SorterKeys =
	{
		["name"] = {},
		["cp"] = {tiebreaker = "name", isNumeric = true},
		["sp"] = {tiebreaker = "name", isNumeric = true},
		["attr"] = {tiebreaker = "name", isNumeric = true},
	}
	
 	self.masterList = {}
	
 	ZO_ScrollList_AddDataType(self.list, 1, "SuperStarXMLFavoriteRowTemplate", 32, function(control, data) self:SetupEntry(control, data) end)
 	ZO_ScrollList_EnableHighlight(self.list, "ZO_ThinListHighlight")
	
	self.currentSortKey = "name"
 	self.sortFunction = function(listEntry1, listEntry2) return ZO_TableOrderingFunction(listEntry1.data, listEntry2.data, self.currentSortKey, SorterKeys, self.currentSortOrder) end
	self:SetAlternateRowBackgrounds(true)
	
	return self
	
end

function favoritesList:SetupEntry(control, data)
	
	control.data = data
	control.name = GetControl(control, "Name")
	control.sp = GetControl(control, "SP")
	control.cp = GetControl(control, "CP")
	control.attr = GetControl(control, "Attr")
	
	control.name:SetText(data.name)
	control.sp:SetText(data.sp)
	control.cp:SetText(data.cp)
	control.attr:SetText(data.attr)
	
	ZO_SortFilterList.SetupRow(self, control, data)
	
end

function favoritesList:BuildMasterList()
	self.masterList = {}
	
	local _, index = GetDataByName(virtualFavorite, "favoritesList")
	local updatedDataForLocalChar = {name = virtualFavorite, cp = SuperStarSkills.localPlayerCRequired, attr = SuperStarSkills.localPlayerARequired, hash = SuperStarSkills.localPlayerHash, sp = SuperStarSkills.localPlayerSRequired, favoriteLocked = true}
	
	if index then
		db.favoritesList[index] = updatedDataForLocalChar
	else
		table.insert(db.favoritesList, updatedDataForLocalChar)
	end
	
	if db.favoritesList then
		for k, v in ipairs(db.favoritesList) do
			local data = v
			table.insert(self.masterList, data)
		end
	end
	
end

function favoritesList:SortScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	table.sort(scrollData, self.sortFunction)
end

function favoritesList:FilterScrollList()
	local scrollData = ZO_ScrollList_GetDataList(self.list)
	ZO_ClearNumericallyIndexedTable(scrollData)

	for i = 1, #self.masterList do
		local data = self.masterList[i]
		table.insert(scrollData, ZO_ScrollList_CreateDataEntry(1, data))
	end
end

local function CleanSortListForDB(array)
	-- :RefreshData() adds dataEntry recursively, delete it to avoid overflow in SavedVars
	for i=#db[array],1,-1 do
		db[array][i].dataEntry = nil
	end
end

local function AddFavoriteFromSkillBuilder(control)

	local hash = BuildBuilderSkillsHash()
	if hash ~= "" then
		ZO_Dialogs_ShowDialog("SUPERSTAR_SAVE_SKILL_FAV", {hash = hash}, {mainTextParams = {functionName}})
	end

end

local function AddFavoriteFromImport(control)
	local hash = SuperStarXMLImport:GetNamedChild("ImportValueEdit"):GetText()
	ZO_Dialogs_ShowDialog("SUPERSTAR_SAVE_FAV", {hash = hash}, {mainTextParams = {functionName}})
end

local function ConfirmSaveFav(favName, hash)
	
	-- Show SuperStar Build Scene
	LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarFavorites")
	
	local attrData, skillsData, cpData = CheckImportedBuild(hash)
	
	if attrData and skillsData and cpData then
	
		if string.len(favName) > 40 then
			favName = string.sub(favName, 1, 40) .. " ..."
		end
		
		local cpPoints = 0
		local attrPoints = 0
		local spPoints = 0
		
		if type(cpData) == "table" then
			cpPoints = cpData.pointsRequired
		end
		if type(attrData) == "table" then
			attrPoints = attrData.pointsRequired
		end
		if type(skillsData) == "table" then
			spPoints = skillsData.pointsRequired
		end
		
		local data = {name = favName, cp = cpPoints, attr = attrPoints, hash = hash, sp = spPoints}
		local entry = ZO_ScrollList_CreateDataEntry(1, data)
		local entryList = ZO_ScrollList_GetDataList(favoritesManager.list)
		
		table.insert(entryList, entry)
		table.insert(db.favoritesList, {name = favName, cp = cpPoints, attr = attrPoints, hash = hash, sp = spPoints}) -- "data" variable is modified by ZO_ScrollList_CreateDataEntry and will crash eso if saved to savedvars
		
		favoritesManager:RefreshData()
		CleanSortListForDB("favoritesList")
		
	end
	
end

local function RespecFavoriteSP(control)
	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	local _, index = GetDataByName(data.name, "favoritesList")
	ShowRespecScene(index, RESPEC_MODE_SP)
end

local function RespecFavoriteCP(control)
	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	local _, index = GetDataByName(data.name, "favoritesList")
	ShowRespecScene(index, RESPEC_MODE_CP)
end

local function RemoveFavorite(control)

	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	if data.name ~= virtualFavorite then
		local _, index = GetDataByName(data.name, "favoritesList")
		table.remove(db.favoritesList, index)
		favoritesManager:RefreshData()
		CleanSortListForDB("favoritesList")
	end
	
end

local function ViewFavorite()

	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	local _, index = GetDataByName(data.name, "favoritesList")
	
	local attrData, skillsData, cpData = CheckImportedBuild(db.favoritesList[index].hash)
	
	if attrData and skillsData and cpData then
		
		ResetSkillBuilder()
		
		local availablePoints = SuperStarSkills.spentSkillPoints - db.favoritesList[index].sp
		
		if availablePoints > 0 then
			
			LSF:Initialize(skillsData.classId, skillsData.raceId)
			SuperStarSkills.builderFactory = skillsData
			SuperStarSkills.pendingCPDataForBuilder = cpData
			SuperStarSkills.pendingAttrDataForBuilder = attrData
				
			SuperStarSkills.spentSkillPoints = availablePoints
			
			SUPERSTAR_SKILLS_SCENE:RemoveFragment(SUPERSTAR_SKILLS_PRESELECTORWINDOW)
			SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_BUILDERWINDOW)
			
			LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarSkills")
			
		end
		
	else
		--
	end
	
end

local function ViewFavoriteHash()

	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	local _, index = GetDataByName(data.name, "favoritesList")
	
	local attrData, skillsData, cpData = CheckImportedBuild(db.favoritesList[index].hash)
	
	if attrData and skillsData and cpData then
		
		SuperStarXMLImport:GetNamedChild("ImportValueEdit"):SetText(db.favoritesList[index].hash)
		
		local text = db.favoritesList[index].hash
		
		isImportedBuildValid = false
		
		if text ~= "" then
			
			local attrData, skillsData, cpData = CheckImportedBuild(text)
			SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetHidden(false)
			
			if attrData and skillsData and cpData then
				UpdateHashDataContainer(attrData, skillsData, cpData)
			else
				UpdateHashDataContainer(false, false, false)
			end
			
		else
			SuperStarXMLImport:GetNamedChild("ImportSeeBuild"):SetHidden(true)
			UpdateHashDataContainer(false, false, false)
		end
		
		LMM:Update(MENU_CATEGORY_SUPERSTAR, "SuperStarImport")
		
	end
	
end

-- Called by XML
function SuperStar_HoverRowOfFavorite(control)
	
	favoritesList:Row_OnMouseEnter(control)
	local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
	
	isFavoriteLocked = data.favoriteLocked and "$" .. GetUnitName("player") == data.name
	isFavoriteShown = true
	
	local attrData, skillsData, cpData = CheckImportedBuild(data.hash)

	if attrData and skillsData and cpData then
		isFavoriteValid = true
		isFavoriteHaveSP = type(skillsData) == "table" and skillsData.pointsRequired > 0
		isFavoriteHaveCP = type(cpData) == "table" and cpData.pointsRequired > 0
	end
	
	KEYBIND_STRIP:UpdateKeybindButtonGroup(SUPERSTAR_FAVORITES_WINDOW.favoritesKeybindStripDescriptor)
	
end

-- Called by XML
function SuperStar_ExitRowOfFavorite(control)

	isFavoriteShown = false
	isFavoriteLocked = false
	isFavoriteHaveSP = false
	isFavoriteHaveCP = false
	isFavoriteValid = false

	favoritesList:Row_OnMouseExit(control)
	KEYBIND_STRIP:UpdateKeybindButtonGroup(SUPERSTAR_FAVORITES_WINDOW.favoritesKeybindStripDescriptor)
	
end

local function InitializeDialogs()

	favoritesManager = favoritesList:New(SuperStarXMLFavorites)
	favoritesManager:RefreshData()
	CleanSortListForDB("favoritesList")
	
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_SAVE_SKILL_FAV",
	{
		title =
		{
			text = SUPERSTAR_SAVEFAV,
		},
		mainText =
		{
			text = SUPERSTAR_FAVNAME,
		},
		editBox =
		{
			defaultText = "",
		},
		buttons =
		{
			{
				text = SI_DIALOG_CONFIRM,
				requiresTextInput = true,
				callback =  function(dialog)
					local favName = ZO_Dialogs_GetEditBoxText(dialog)
					if favName and favName ~= "" then
						ConfirmSaveFav(favName, dialog.data.hash)
					end
				end,
			},
			{
				text = SI_DIALOG_CANCEL,
				callback = function(dialog)
					return true
				end,
			}
		}
	})
	
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_SAVE_FAV",
	{
		title =
		{
			text = SUPERSTAR_SAVEFAV,
		},
		mainText =
		{
			text = SUPERSTAR_FAVNAME,
		},
		editBox =
		{
			defaultText = "",
		},
		buttons =
		{
			{
				text = SI_DIALOG_CONFIRM,
				requiresTextInput = true,
				callback =  function(dialog)
					local favName = ZO_Dialogs_GetEditBoxText(dialog)
					if favName and favName ~= "" then
						ConfirmSaveFav(favName, dialog.data.hash)
					end
				end,
			},
			{
				text = SI_DIALOG_CANCEL,
				callback = function(dialog)
					return true
				end,
			}
		}
	})
	
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_CONFIRM_SPRESPEC",
	{
		title =
		{
			text = SUPERSTAR_DIALOG_SPRESPEC_TITLE,
		},
		mainText =
		{
			text = SUPERSTAR_DIALOG_SPRESPEC_TEXT,
		},
		buttons =
		{
			{
				text = SI_DIALOG_CONFIRM,
				callback = RespecSkills,
			},
			{
				text = SI_DIALOG_CANCEL,
			}
		}
	})
	
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_REINIT_SKILLBUILDER_WITH_ATTR_CP",
	{
		title =
		{
			text = SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TITLE,
		},
		mainText =
		{
			text = SUPERSTAR_DIALOG_REINIT_SKB_ATTR_CP_TEXT,
		},
		buttons =
		{
			{
				text = SI_DIALOG_CONFIRM,
				callback = function()
					SuperStarSkills.pendingCPDataForBuilder = nil
					SuperStarSkills.pendingAttrDataForBuilder = nil
					ResetSkillBuilder()
				end
			},
			{
				text = SI_DIALOG_CANCEL,
			}
		}
	})
	
	local customControl = ZO_ChampionRespecConfirmationDialog
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_CONFIRM_CPRESPEC_COST",
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		customControl = customControl,
		title =
		{
			text = SI_CHAMPION_DIALOG_CONFIRM_CHANGES_TITLE,
		},
		mainText =
		{
			text = zo_strformat(SI_CHAMPION_DIALOG_TEXT_FORMAT, GetString(SI_CHAMPION_DIALOG_CONFIRM_POINT_COST)),
		},
		setup = function()
			ZO_CurrencyControl_SetSimpleCurrency(customControl:GetNamedChild("BalanceAmount"), CURT_MONEY,  GetCarriedCurrencyAmount(CURT_MONEY))
			ZO_CurrencyControl_SetSimpleCurrency(customControl:GetNamedChild("RespecCost"), CURT_MONEY,  GetChampionRespecCost())
		end,
		buttons =
		{
			{
				control = customControl:GetNamedChild("Confirm"),
				text = SI_DIALOG_CONFIRM,
				callback = function()
					FinalizeCPRespec(true)
				end,
			},
			{
				control = customControl:GetNamedChild("Cancel"),
				text = SI_DIALOG_CANCEL,
				callback = function()
					FinalizeCPRespec(false)
				end,
			}
		}
	})
	
	ZO_Dialogs_RegisterCustomDialog("SUPERSTAR_CONFIRM_CPRESPEC_NOCOST",
	{
		gamepadInfo =
		{
			dialogType = GAMEPAD_DIALOGS.BASIC,
		},
		title =
		{
			text = SI_CHAMPION_DIALOG_CONFIRM_CHANGES_TITLE,
		},
		mainText =
		{
			text = SUPERSTAR_DIALOG_CPRESPEC_NOCOST_TEXT,
		},
		buttons =
		{
			{
				text = SI_DIALOG_CONFIRM,
				callback =  function()
					FinalizeCPRespec(true)
				end,
			},
			{
				text = SI_DIALOG_CANCEL,
				callback = function()
					FinalizeCPRespec(false)
				end,
			}
		}
	})
	
end

local function CreateScenes()

	-- Build the Menu
	-- Its name for the menu (the meta scene)
	ZO_CreateStringId("SI_SUPERSTAR_CATEGORY_MENU_TITLE", ADDON_NAME)
	
	-- Its infos
   local SUPERSTAR_MAIN_MENU_CATEGORY_DATA =
	{
		binding = "SUPERSTAR_SHOW_PANEL",
		categoryName = SI_SUPERSTAR_CATEGORY_MENU_TITLE,
		normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
		pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
		highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
	}
	
	-- Then the scenes
	
	-- Main Scene
	local SUPERSTAR_MAIN_SCENE = ZO_Scene:New("SuperStarMain", SCENE_MANAGER)	
	
	-- Mouse standard position and background
	SUPERSTAR_MAIN_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	SUPERSTAR_MAIN_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	SUPERSTAR_MAIN_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	
	-- The title fragment
	SUPERSTAR_MAIN_SCENE:AddFragment(TITLE_FRAGMENT)
	
	-- Set Title
	ZO_CreateStringId("SUPERSTAR_MAIN_MENU_TITLE", GetUnitName("player"))
	local SUPERSTAR_MAIN_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_SUPERSTAR_CATEGORY_MENU_TITLE)
	SUPERSTAR_MAIN_SCENE:AddFragment(SUPERSTAR_MAIN_TITLE_FRAGMENT)
	
	-- Add the XML to our scene
	local SUPERSTAR_MAIN_WINDOW = ZO_FadeSceneFragment:New(SuperStarXMLMain)
	SUPERSTAR_MAIN_SCENE:AddFragment(SUPERSTAR_MAIN_WINDOW)
	
	-- Auto Update
	SUPERSTAR_MAIN_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			BuildMainSceneValues(SuperStarXMLMain)
			EVENT_MANAGER:RegisterForUpdate(ADDON_NAME, 1000, function() BuildMainSceneValues(SuperStarXMLMain) end)
		elseif(newState == SCENE_HIDDEN) then
			EVENT_MANAGER:UnregisterForUpdate(ADDON_NAME)
		end
	end)
	
	-- Skill Simulator Scene
	SUPERSTAR_SKILLS_SCENE = ZO_Scene:New("SuperStarSkills", SCENE_MANAGER)
	
	-- Mouse standard position and background
	SUPERSTAR_SKILLS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	SUPERSTAR_SKILLS_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	SUPERSTAR_SKILLS_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	
	-- The title fragment
	SUPERSTAR_SKILLS_SCENE:AddFragment(TITLE_FRAGMENT)
	
	SUPERSTAR_SKILLS_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	SUPERSTAR_SKILLS_SCENE:AddFragment(FRAME_EMOTE_FRAGMENT_SKILLS)
	SUPERSTAR_SKILLS_SCENE:AddFragment(SKILLS_WINDOW_SOUNDS)
	
	-- Set Title
	ZO_CreateStringId("SUPERSTAR_SKILLS_MENU_TITLE", GetString(SI_MAIN_MENU_SKILLS))
	local SUPERSTAR_SKILLS_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_SUPERSTAR_CATEGORY_MENU_TITLE)
	SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_TITLE_FRAGMENT)
	
	-- Add the XML to our scene
	SUPERSTAR_SKILLS_PRESELECTORWINDOW = ZO_FadeSceneFragment:New(SuperStarXMLSkillsPreSelector)
	SUPERSTAR_SKILLS_BUILDERWINDOW = ZO_FadeSceneFragment:New(SuperStarXMLSkills)
	
	local skillBuilderKeybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name = GetString(SUPERSTAR_XML_BUTTON_FAV),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = AddFavoriteFromSkillBuilder,
		},
		{
			name = GetString(SUPERSTAR_XML_BUTTON_REINIT),
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = ResetSkillBuilder,
		},
	}
	
	SUPERSTAR_SKILLS_BUILDERWINDOW:RegisterCallback("StateChange",  function(oldState, newState)
		if(newState == SCENE_SHOWING) then 
			KEYBIND_STRIP:AddKeybindButtonGroup(skillBuilderKeybindStripDescriptor)
		elseif(newState == SCENE_HIDDEN) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(skillBuilderKeybindStripDescriptor)
		end
	end)
	
	SUPERSTAR_SKILLS_SCENE:AddFragment(SUPERSTAR_SKILLS_PRESELECTORWINDOW)
	
	-- Summary Scene
	local SUPERSTAR_IMPORT_SCENE = ZO_Scene:New("SuperStarImport", SCENE_MANAGER)	
	
	-- Mouse standard position and background
	SUPERSTAR_IMPORT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	SUPERSTAR_IMPORT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	SUPERSTAR_IMPORT_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	
	-- The title fragment
	SUPERSTAR_IMPORT_SCENE:AddFragment(TITLE_FRAGMENT)
	
	-- Tree background
	SUPERSTAR_IMPORT_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	
	-- Set Title
	local SUPERSTAR_IMPORT_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_SUPERSTAR_CATEGORY_MENU_TITLE)
	SUPERSTAR_IMPORT_SCENE:AddFragment(SUPERSTAR_IMPORT_TITLE_FRAGMENT)
	
	-- Add the XML to our scene
	SUPERSTAR_IMPORT_WINDOW = ZO_FadeSceneFragment:New(SuperStarXMLImport)
	SUPERSTAR_IMPORT_SCENE:AddFragment(SUPERSTAR_IMPORT_WINDOW)
	
	SUPERSTAR_IMPORT_WINDOW.importKeybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name = GetString(SUPERSTAR_XML_BUTTON_FAV),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = AddFavoriteFromImport,
			visible = function() return isImportedBuildValid end,
		},
	}
	
	SUPERSTAR_IMPORT_SCENE:RegisterCallback("StateChange",  function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			RefreshImport(xmlInclChampionSkills, xmlIncludeSkills, xmlIncludeAttributes)
			KEYBIND_STRIP:AddKeybindButtonGroup(SUPERSTAR_IMPORT_WINDOW.importKeybindStripDescriptor)
		elseif(newState == SCENE_HIDDEN) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(SUPERSTAR_IMPORT_WINDOW.importKeybindStripDescriptor)
		end
	end)
	
	-- Favorites Scene
	local SUPERSTAR_FAVORITES_SCENE = ZO_Scene:New("SuperStarFavorites", SCENE_MANAGER)	
	
	-- Mouse standard position and background
	SUPERSTAR_FAVORITES_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	SUPERSTAR_FAVORITES_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	SUPERSTAR_FAVORITES_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	
	-- The title fragment
	SUPERSTAR_FAVORITES_SCENE:AddFragment(TITLE_FRAGMENT)
	
	-- Tree background
	SUPERSTAR_FAVORITES_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	
	-- Set Title
	local SUPERSTAR_FAVORITES_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_SUPERSTAR_CATEGORY_MENU_TITLE)
	SUPERSTAR_FAVORITES_SCENE:AddFragment(SUPERSTAR_FAVORITES_TITLE_FRAGMENT)
	
	-- Add the XML to our scene
	SUPERSTAR_FAVORITES_WINDOW = ZO_FadeSceneFragment:New(SuperStarXMLFavorites)
	SUPERSTAR_FAVORITES_SCENE:AddFragment(SUPERSTAR_FAVORITES_WINDOW)
	
	SUPERSTAR_FAVORITES_WINDOW.favoritesKeybindStripDescriptor =
	{
		alignment = KEYBIND_STRIP_ALIGN_CENTER,
		{
			name = GetString(SUPERSTAR_VIEWFAV),
			keybind = "UI_SHORTCUT_PRIMARY",
			callback = ViewFavorite,
			visible = function() return isFavoriteShown and isFavoriteHaveSP end,
		},
		{
			name = GetString(SUPERSTAR_RESPECFAV_SP),
			keybind = "UI_SHORTCUT_SECONDARY",
			callback = RespecFavoriteSP,
			visible = function() return isFavoriteShown and isFavoriteHaveSP end,
		},
		{
			name = GetString(SUPERSTAR_RESPECFAV_CP),
			keybind = "UI_SHORTCUT_TERTIARY",
			callback = RespecFavoriteCP,
			visible = function() return isFavoriteShown and isFavoriteHaveCP end,
		},
		{
			name = GetString(SUPERSTAR_VIEWHASH),
			keybind = "UI_SHORTCUT_QUATERNARY",
			callback = ViewFavoriteHash,
			visible = function() return isFavoriteShown and isFavoriteValid end,
		},
		{
			name = GetString(SUPERSTAR_REMFAV),
			keybind = "UI_SHORTCUT_NEGATIVE",
			callback = RemoveFavorite,
			visible = function() return isFavoriteShown and not isFavoriteLocked end,
		},
	}
	
	SUPERSTAR_FAVORITES_WINDOW:RegisterCallback("StateChange",  function(oldState, newState)
		if(newState == SCENE_SHOWING) then
			KEYBIND_STRIP:AddKeybindButtonGroup(SUPERSTAR_FAVORITES_WINDOW.favoritesKeybindStripDescriptor)
		elseif(newState == SCENE_HIDDEN) then
			KEYBIND_STRIP:RemoveKeybindButtonGroup(SUPERSTAR_FAVORITES_WINDOW.favoritesKeybindStripDescriptor)
		end
	end)
	
	-- Respec Scene
	local SUPERSTAR_RESPEC_SCENE = ZO_Scene:New("SuperStarRespec", SCENE_MANAGER)	
	
	-- Mouse standard position and background
	SUPERSTAR_RESPEC_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
	SUPERSTAR_RESPEC_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
	
	--  Background Right, it will set ZO_RightPanelFootPrint and its stuff.
	SUPERSTAR_RESPEC_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
	
	-- The title fragment
	SUPERSTAR_RESPEC_SCENE:AddFragment(TITLE_FRAGMENT)
	
	-- Tree background
	SUPERSTAR_RESPEC_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)
	
	-- Set Title
	local SUPERSTAR_RESPEC_TITLE_FRAGMENT = ZO_SetTitleFragment:New(SI_SUPERSTAR_CATEGORY_MENU_TITLE)
	SUPERSTAR_RESPEC_SCENE:AddFragment(SUPERSTAR_RESPEC_TITLE_FRAGMENT)
	
	-- Add the XML to our scene
	local SUPERSTAR_RESPEC_WINDOW = ZO_FadeSceneFragment:New(SuperStarXMLRespec)
	SUPERSTAR_RESPEC_SCENE:AddFragment(SUPERSTAR_RESPEC_WINDOW)
	
	-- To build a window with multiple scene, we need to use a ZO_SceneGroup
	-- Set tabs and visibility, etc
	
	do
		local iconData = {
			{
				categoryName = SUPERSTAR_MAIN_MENU_TITLE,
				descriptor = "SuperStarMain",
				normal = "EsoUI/Art/MainMenu/menuBar_champion_up.dds",
				pressed = "EsoUI/Art/MainMenu/menuBar_champion_down.dds",
				highlight = "EsoUI/Art/MainMenu/menuBar_champion_over.dds",
			},
			{
				categoryName = SUPERSTAR_SKILLS_MENU_TITLE,
				descriptor = "SuperStarSkills",
				normal = "EsoUI/Art/MainMenu/menuBar_skills_up.dds",
				pressed = "EsoUI/Art/MainMenu/menuBar_skills_down.dds",
				highlight = "EsoUI/Art/MainMenu/menuBar_skills_over.dds",
			},
			{
				categoryName = SUPERSTAR_IMPORT_MENU_TITLE,
				descriptor = "SuperStarImport",
				normal = "EsoUI/Art/Icons/achievements_indexicon_summary_up.dds",
				pressed = "EsoUI/Art/Icons/achievements_indexicon_summary_down.dds",
				highlight = "EsoUI/Art/Icons/achievements_indexicon_summary_over.dds",
			},
			{
				categoryName = SUPERSTAR_FAVORITES_MENU_TITLE,
				descriptor = "SuperStarFavorites",
				normal = "EsoUI/Art/Cadwell/cadwell_indexicon_gold_up.dds",
				pressed = "EsoUI/Art/Cadwell/cadwell_indexicon_gold_down.dds",
				highlight = "EsoUI/Art/Cadwell/cadwell_indexicon_gold_over.dds",
			},
			{
				categoryName = SUPERSTAR_RESPEC_MENU_TITLE,
				descriptor = "SuperStarRespec",
				normal = "EsoUI/Art/Guild/tabicon_history_up.dds",
				pressed = "EsoUI/Art/Guild/tabicon_history_down.dds",
				highlight = "EsoUI/Art/Guild/tabicon_history_over.dds",
			},
		}
		
		-- Register Scenes and the group name
		SCENE_MANAGER:AddSceneGroup("SuperStarSceneGroup", ZO_SceneGroup:New("SuperStarMain", "SuperStarSkills", "SuperStarImport", "SuperStarFavorites", "SuperStarRespec"))
		
		MENU_CATEGORY_SUPERSTAR = LMM:AddCategory(SUPERSTAR_MAIN_MENU_CATEGORY_DATA)
		
		-- Register the group and add the buttons (we cannot all AddRawScene, only AddSceneGroup, so we emulate both functions).
		LMM:AddSceneGroup(MENU_CATEGORY_SUPERSTAR, "SuperStarSceneGroup", iconData)
		
	end

end

-- Called by Bindings and Slash Command
function SuperStar_ToggleSuperStarPanel()
	LMM:ToggleCategory(MENU_CATEGORY_SUPERSTAR)
end

-- Initialises the settings and settings menu
local function OnAddonLoaded(_, addonName)

	--Protect
	if addonName == ADDON_NAME then
	
		-- Fetch the saved variables
		db = ZO_SavedVars:NewAccountWide('SUPERSTAR', 1, nil, defaults)
		
		-- Init Scenes
		CreateScenes()
		
		-- Init Skill Builder
		InitSkills(SuperStarXMLSkills)
		
		-- Init Dialogs
		InitializeDialogs()
		
		-- Register Slash commands
		SLASH_COMMANDS["/superstar"] = SuperStar_ToggleSuperStarPanel
		
		EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ACTION_SLOTS_FULL_UPDATE, SwapSniffer)
		EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
		
	end
	
end

-- Initialize
EVENT_MANAGER:RegisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)