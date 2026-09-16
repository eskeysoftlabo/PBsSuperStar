--[[
Author: Ayantir
Filename: LibSkillFactory.lua
Version: 10
]]--

--Register LAM with LibStub
local MAJOR, MINOR = "LibSkillsFactory", 10
local LibSkillsFactory, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
if not LibSkillsFactory then return end -- the same or newer version of this lib is already loaded into memory 
	
local ABILITY_TYPE_ULTIMATE = 0
local ABILITY_TYPE_ACTIVE = 1
local ABILITY_TYPE_PASSIVE = 2
	
-- Class is ClassID : 1 (Dragon Knight), 2 (Sorcerer), 3 (Nightblade), 6 (templar) -- GetUnitClassId()
-- Races MUST be : 1 Breton, 2 Redguard, 3 Orc, 4 Dunmer, 5 Nord, 6 Argonian, 7 Altmer, 8 Bosmer, 9 Khajiit, 10 Imperial -- GetUnitRaceId()

-- Init the factory ~like this :
-- LibSkillsFactory:Initialize(GetUnitClassId("player"), GetUnitRaceId("player"))

--[[

NOTE FOR TRADESKILLS :

Depending on language used at launch (not reloadui), Skilllines are not sames.
For LibSkillsFactory :  1 = Alchemy, 2 = Clothing, 3 = Provisionning, 4 = Enchanting, 5 = Blacksmithing, 6 = Woodworking
If 1/6 are always same, 2/3/4/5 API is divergent depending language used AT LAUNCH

]]--


local function InitLanguage(lang)

local data = {
	en = {
		[SKILL_TYPE_CLASS] = {
			["Flame"] = "Ardent Flame",
			["Draconic"] = "Draconic Power",
			["Earth"] = "Earthen Heart",
			["Daedric"] = "Daedric Summoning",
			["Dark"] = "Dark Magic",
			["Storm"] = "Storm Calling",
			["Assassination"] = "Assassination",
			["Shadow"] = "Shadow",
			["Siphon"] = "Siphoning",
			["Spear"] = "Aedric Spear",
			["Dawn"] = "Dawn's Wrath",
			["Restoring"] = "Restoring Light",
			["Animal"] = "Animal Companions",
			["Green"] = "Green Balance",
			["Winter"] = "Winter's Embrace",
		},
		[SKILL_TYPE_WEAPON] = {
			[1] = "Two Handed",
			[2] = "One Hand and Shield",
			[3] = "Dual Wield",
			[4] = "Bow",
			[5] = "Destruction Staff",
			[6] = "Restoration Staff",
		},
		[SKILL_TYPE_ARMOR] = {
			[1] = "Light Armor",
			[2] = "Medium Armor",
			[3] = "Heavy Armor",
		},
		[SKILL_TYPE_WORLD] = {
			[1] = "Legerdemain",
			[2] = "Soul Magic",
			[3] = "Vampire",
			[4] = "Werewolf",
		},
		[SKILL_TYPE_GUILD] = {
			[1] = "Dark Brotherhood",
			[2] = "Fighters Guild",
			[3] = "Mages Guild",
			[4] = "Thieves Guild",
			[5] = "Undaunted",
		},
		[SKILL_TYPE_AVA] = {
		[1] = "Assault",
		--[2] = "Emperor",
		[2] = "Support",
		},
		[SKILL_TYPE_RACIAL] = {
			[1] = "Breton",
			[2] = "Redguard",
			[3] = "Orc",
			[4] = "Dark-Elf",
			[5] = "Nordic",
			[6] = "Argonian",
			[7] = "Hight-Elf",
			[8] = "Wood-Elf",
			[9] = "Khajiit",
			[10] = "Imperial",
		},
		[SKILL_TYPE_TRADESKILL] = {
			[1] = "Alchemy",
			[2] = "Clothing",
			[3] = "Provisioning",
			[4] = "Enchanting",
			[5] = "Blacksmithing",
			[6] = "Woodworking",
		},
	},
	fr = {
		[SKILL_TYPE_CLASS] = {
			["Flame"] = "Flamme ardente",
			["Draconic"] = "Puissance draconique",
			["Earth"] = "Cœur terrestre",
			["Daedric"] = "Invocation daedrique",
			["Dark"] = "Magie noire",
			["Storm"] = "Appel de la tempête",
			["Assassination"] = "Assassinat",
			["Shadow"] = "Ombre",
			["Siphon"] = "Siphon",
			["Spear"] = "Lance aedrique",
			["Dawn"] = "Courroux de l'aube",
			["Restoring"] = "Rétablissement lumineux",
			["Animal"] = "Compagnons animaux",
			["Green"] = "Équilibre vert",
			["Winter"] = "Étreinte hivernale",
		},
		[SKILL_TYPE_WEAPON] = {
			[1] = "Arme à deux mains",
			[2] = "Une main et un bouclier",
			[3] = "Deux armes",
			[4] = "Arc",
			[5] = "Bâton de destruction",
			[6] = "Bâton de rétablissement",
		},
		[SKILL_TYPE_ARMOR] = {
			[1] = "Armure légère",
			[2] = "Armure moyenne",
			[3] = "Armure lourde",
		},
		[SKILL_TYPE_WORLD] = {
			[1] = "Escroquerie",
			[2] = "Magie des âmes",
			[3] = "Vampire",
			[4] = "Loup-garou",
		},
		[SKILL_TYPE_GUILD] = {
			[1] = "Confrérie noire",
			[2] = "Guilde des guerriers",
			[3] = "Guilde des mages",
			[4] = "Guilde des voleurs",
			[5] = "Indomptable",
		},
		[SKILL_TYPE_AVA] = {
			[1] = "Assaut",
			--[2] = "Empereur",
			[2] = "Soutien",
		},
		[SKILL_TYPE_RACIAL] = {
			[1] = "Bréton",
			[2] = "Rougegarde",
			[3] = "Orque",
			[4] = "Elfe noir",
			[5] = "Nordique",
			[6] = "Argonien",
			[7] = "Haut-Elfe",
			[8] = "Elfe des bois",
			[9] = "Khajiit",
			[10] = "Impérial",
		},
		[SKILL_TYPE_TRADESKILL] = {
			[1] = "Alchimie",
			[2] = "Couture",
			[3] = "Cuisine",
			[4] = "Enchantement",
			[5] = "Forge",
			[6] = "Travail du bois",
		},
	},
	de = {
		[SKILL_TYPE_CLASS] = {
			["Flame"] = "Verzehrende Flame",
			["Draconic"] = "Drakonische Macht",
			["Earth"] = "Irdenes Herz",
			["Daedric"] = "Daedrische Beschwörung",
			["Dark"] = "Dunkle Magie",
			["Storm"] = "Sturmrufen",
			["Assassination"] = "Meuchelmord",
			["Shadow"] = "Schatten",
			["Siphon"] = "Auslaugen",
			["Spear"] = "Aedrischer Speer",
			["Dawn"] = "Zorn der Morgenröte",
			["Restoring"] = "Wiederherstellendes Licht",
			["Animal"] = "Tiergefährten",
			["Green"] = "Grünes Gleichgewicht",
			["Winter"] = "Winterkälte",
		},
		[SKILL_TYPE_WEAPON] = {
			[1] = "Zweihänder",
			[2] = "Waffe mit Schild",
			[3] = "Zwei Waffen",
			[4] = "Bogen",
			[5] = "Zerstörungsstab",
			[6] = "Heilungsstab",
		},
		[SKILL_TYPE_ARMOR] = {
			[1] = "Leichte Rüstung",
			[2] = "Mittlere Rüstung",
			[3] = "Schwere Rüstung",
		},
		[SKILL_TYPE_WORLD] = {
			[1] = "Lug und Trug",
			[2] = "Seelenmagie",
			[3] = "Vampirismus",
			[4] = "Werwolf",
		},
		[SKILL_TYPE_GUILD] = {
			[1] = "Dunkle Bruderschaft",
			[2] = "Kriegergilde",
			[3] = "Magiergilde",
			[4] = "Diebesgilde",
			[5] = "Unerschrockene",
		},
		[SKILL_TYPE_AVA] = {
			[1] = "Sturmangriff",
			[2] = "Unterstützung",
		},
		[SKILL_TYPE_RACIAL] = {
			[1] = "Bretone",
			[2] = "Rothwardone",
			[3] = "Ork",
			[4] = "Dunkelelf",
			[5] = "Nord",
			[6] = "Argonier",
			[7] = "Hochelf",
			[8] = "Waldelf",
			[9] = "Khajiit",
			[10] = "Kaiserlich",
		},
		[SKILL_TYPE_TRADESKILL] = {
			[1] = "Alchemie",
			[2] = "Schneiderei",
			[3] = "Versorgen",
			[4] = "Verzaubern",
			[5] = "Schmiedekunst",
			[6] = "Schreinerei"
		},
	},
	jp = {
		[SKILL_TYPE_CLASS] = {
			["Flame"] = "熾烈なる炎",
			["Draconic"] = "龍族の力",
			["Earth"] = "大いなる大地",
			["Daedric"] = "デイドラ召喚",
			["Dark"] = "闇魔法",
			["Storm"] = "嵐の召喚",
			["Assassination"] = "暗殺",
			["Shadow"] = "影",
			["Siphon"] = "吸引",
			["Spear"] = "エドラの槍",
			["Dawn"] = "暁の憤怒",
			["Restoring"] = "回復の光輝",
			["Animal"] = "Animal Companions", -- TODO
			["Green"] = "Green Balance", -- TODO
			["Winter"] = "Winter's Embrace", -- TODO
		},
		[SKILL_TYPE_WEAPON] = {
			[1] = "両手武器",
			[2] = "片手武器・盾",
			[3] = "二刀流",
			[4] = "弓",
			[5] = "攻撃の杖",
			[6] = "回復の杖",
		},
		[SKILL_TYPE_ARMOR] = {
			[1] = "軽装備",
			[2] = "中装備",
			[3] = "重装備",
		},
		[SKILL_TYPE_WORLD] = {
			[1] = "泥棒",
			[2] = "ソウルマジック",
			[3] = "吸血鬼",
			[4] = "ウェアウルフ",
		},
		[SKILL_TYPE_GUILD] = {
			[1] = "闇の一党",
			[2] = "戦士ギルド",
			[3] = "魔術師ギルド",
			[4] = "泥棒ギルド",
			[5] = "アンドーンテッド",
		},
		[SKILL_TYPE_AVA] = {
		[1] = "襲撃戦術",
		--[2] = "皇帝",
		[2] = "後方支援",
		},
		[SKILL_TYPE_RACIAL] = {
			[1] = "ブレトン",
			[2] = "レッドガード",
			[3] = "オーク",
			[4] = "ダークエルフ",
			[5] = "ノルド",
			[6] = "アルゴニアン",
			[7] = "ハイエルフ",
			[8] = "ウッドエルフ",
			[9] = "カジート",
			[10] = "インペリアル",
		},
		[SKILL_TYPE_TRADESKILL] = {
			[1] = "錬金術",
			[2] = "縫製",
			[3] = "調理",
			[4] = "付呪",
			[5] = "鍛冶",
			[6] = "木工",
		},
	},
}

	return data[lang] or data.en

end

local function GetCraftingMode()
	
	local _, blackSmithing = GetCraftingSkillLineIndices(CRAFTING_TYPE_BLACKSMITHING)
	if blackSmithing == 5 then -- FR, DE
		return 2
	else
		return 1 -- value is 2 in EN
	end

end

function LibSkillsFactory:Initialize(classId, raceId)

	if not classId then classId = GetUnitClassId("player") end
	if not raceId then raceId = GetUnitRaceId("player") end
	
	local classPool = {
		[1] = {"Flame", "Draconic", "Earth"},
		[2] = {"Dark", "Daedric", "Storm"},
		[3] = {"Assassination", "Shadow", "Siphon"},
		[4] = {"Animal", "Green", "Winter"},
		[6] = {"Spear", "Dawn", "Restoring"}
	}
	
	local langData = InitLanguage(GetCVar("Language.2"))
	
	for skillType, skillTypeData in pairs(langData) do
		for skillLine, skillLineName in pairs(skillTypeData) do
			LibSkillsFactory.skillSubFactory[skillType][skillLine].name = skillLineName
		end
	end
	
	LibSkillsFactory.skillFactory = {
		[SKILL_TYPE_CLASS] = {
			[1] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS][classPool[classId][1]],
			[2] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS][classPool[classId][2]],
			[3] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS][classPool[classId][3]],
		},
		[SKILL_TYPE_WEAPON] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON],
		[SKILL_TYPE_ARMOR] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR],
		[SKILL_TYPE_WORLD] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD],
		[SKILL_TYPE_GUILD] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD],
		[SKILL_TYPE_AVA] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA],
		[SKILL_TYPE_RACIAL] = {LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][raceId]},
	}
	
	if GetCraftingMode() == 1 then
		LibSkillsFactory.skillFactory[SKILL_TYPE_TRADESKILL] = {
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1],
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5],
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2],
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4],
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3],
			LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6],
		}
	else
		LibSkillsFactory.skillFactory[SKILL_TYPE_TRADESKILL] = LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL]
	end

end

function LibSkillsFactory:GetAbilityType(skillType, skillLineIndex, abilityIndex)

	local abilityType, maxRank
	if LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex] then
		abilityType = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].at
		if abilityType == ABILITY_TYPE_PASSIVE then
			maxRank = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].mx
		end
	else
		return nil
	end
	
	return abilityType, maxRank
	
end

function LibSkillsFactory:GetAbilityInfo(skillType, skillLineIndex, abilityIndex, abilityLevel)

	local earnedAt, texturePath
	if LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex] then
		abilityType = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].at
		
		if abilityType == ABILITY_TYPE_PASSIVE then
		
			texturePath = GetAbilityIcon(LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[1].id)
			
			if not abilityLevel then
				earnedAt = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[1].er
			elseif LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[abilityLevel] then
				earnedAt = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[abilityLevel].er
			else
				earnedAt = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[1].er
			end
			
		else
			earnedAt = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].er
			
			if not abilityLevel then
				texturePath = GetAbilityIcon(LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[0][1].id)
			elseif LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[abilityLevel] then
				texturePath = GetAbilityIcon(LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool[abilityLevel][1].id)
			end
		
		end
	
	else
		return nil
	end
	
	return earnedAt, texturePath
	
end

function LibSkillsFactory:GetSkillLineInfo(skillType, skillLineIndex)
	return LibSkillsFactory.skillFactory[skillType][skillLineIndex].name
end
	
function LibSkillsFactory:GetAbilityId(skillType, skillLineIndex, abilityIndex, abilityLevel, rank)

	local abilityType, skillPool
	if LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex] then
	
	abilityType = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].at
	skillPool = LibSkillsFactory.skillFactory[skillType][skillLineIndex][abilityIndex].skillPool
	
	local abilityPool
	
	if not abilityLevel then
		if skillPool[0] then
			abilityPool = skillPool[0]
		elseif skillPool[1] then
			abilityPool = skillPool[1]
		else
			return 0
		end
	else
		if skillPool[abilityLevel] then
			abilityPool = skillPool[abilityLevel]
		else
			return 0
		end
	end
	
	if abilityPool then
		if rank then
			if abilityPool[rank] then
				if abilityPool[rank] then
					return abilityPool[rank].id
				end
			else
				return 0
			end
		
		else
			if abilityType == ABILITY_TYPE_PASSIVE then
				return abilityPool.id
			else
				if abilityPool[0] then
					return abilityPool[0].id
				else
					return 0
				end
			end
		end
	end
	
	else
		return 0
	end
	
end
	
function LibSkillsFactory:GetNumSkillLines(skillType)

	local numSkillLines =
	{
		[SKILL_TYPE_CLASS] = GetNumSkillLines(skillType),
		[SKILL_TYPE_WEAPON] = GetNumSkillLines(skillType),
		[SKILL_TYPE_ARMOR] = GetNumSkillLines(skillType),
		[SKILL_TYPE_WORLD] = 4,
		[SKILL_TYPE_GUILD] = 5,
		[SKILL_TYPE_AVA] = 2,
		[SKILL_TYPE_RACIAL] = GetNumSkillLines(skillType),
		[SKILL_TYPE_TRADESKILL] = GetNumSkillLines(skillType),
	}
	
	return numSkillLines[skillType]
	
end

function LibSkillsFactory:GetNumSkillAbilities(skillType, skillLineIndex)
	
	if LibSkillsFactory.skillFactory[skillType][skillLineIndex] then
		return #LibSkillsFactory.skillFactory[skillType][skillLineIndex]
	end
	
	return nil
	
end

LibSkillsFactory.skillSubFactory = {
[SKILL_TYPE_CLASS] = {
	["Draconic"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29012,},[2] = {["id"] = 33652,},[3] = {["id"] = 33655,},[4] = {["id"] = 33658,},},
	[1] = {[1] = {["id"] = 32719,},[2] = {["id"] = 33662,},[3] = {["id"] = 33665,},[4] = {["id"] = 33668,},},
	[2] = {[1] = {["id"] = 32715,},[2] = {["id"] = 33671,},[3] = {["id"] = 33675,},[4] = {["id"] = 33679,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 20319,},[2] = {["id"] = 23822,},[3] = {["id"] = 23825,},[4] = {["id"] = 23828,},},
	[1] = {[1] = {["id"] = 20328,},[2] = {["id"] = 23846,},[3] = {["id"] = 23851,},[4] = {["id"] = 23856,},},
	[2] = {[1] = {["id"] = 20323,},[2] = {["id"] = 23834,},[3] = {["id"] = 23838,},[4] = {["id"] = 23842,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 20245,},[2] = {["id"] = 32105,},[3] = {["id"] = 32108,},[4] = {["id"] = 32111,},},
	[1] = {[1] = {["id"] = 20252,},[2] = {["id"] = 32114,},[3] = {["id"] = 32119,},[4] = {["id"] = 32123,},},
	[2] = {[1] = {["id"] = 20251,},[2] = {["id"] = 32127,},[3] = {["id"] = 32131,},[4] = {["id"] = 32135,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29004,},[2] = {["id"] = 33405,},[3] = {["id"] = 33616,},[4] = {["id"] = 33619,},},
	[1] = {[1] = {["id"] = 32744,},[2] = {["id"] = 33622,},[3] = {["id"] = 33627,},[4] = {["id"] = 33632,},},
	[2] = {[1] = {["id"] = 32722,},[2] = {["id"] = 33638,},[3] = {["id"] = 33642,},[4] = {["id"] = 33646,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 21007,},[2] = {["id"] = 33741,},[3] = {["id"] = 33742,},[4] = {["id"] = 33743,},},
	[1] = {[1] = {["id"] = 21014,},[2] = {["id"] = 33745,},[3] = {["id"] = 33747,},[4] = {["id"] = 33749,},},
	[2] = {[1] = {["id"] = 21017,},[2] = {["id"] = 33753,},[3] = {["id"] = 33757,},[4] = {["id"] = 33759,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 31837,},[2] = {["id"] = 33687,},[3] = {["id"] = 33693,},[4] = {["id"] = 33697,},},
	[1] = {[1] = {["id"] = 32792,},[2] = {["id"] = 33702,},[3] = {["id"] = 33708,},[4] = {["id"] = 33715,},},
	[2] = {[1] = {["id"] = 32785,},[2] = {["id"] = 33721,},[3] = {["id"] = 33726,},[4] = {["id"] = 33732,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29455,},[2] = {["id"] = 44922,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29457,},[2] = {["id"] = 44933,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29460,},[2] = {["id"] = 44951,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29462,},[2] = {["id"] = 44953,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Flame"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 28988,},[2] = {["id"] = 33955,},[3] = {["id"] = 33959,},[4] = {["id"] = 33963,},},
	[1] = {[1] = {["id"] = 32958,},[2] = {["id"] = 33967,},[3] = {["id"] = 33977,},[4] = {["id"] = 33987,},},
	[2] = {[1] = {["id"] = 32947,},[2] = {["id"] = 34009,},[3] = {["id"] = 34015,},[4] = {["id"] = 34021,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 20492,},[2] = {["id"] = 23736,},[3] = {["id"] = 23740,},[4] = {["id"] = 23744,},},
	[1] = {[1] = {["id"] = 20499,},[2] = {["id"] = 32215,},[3] = {["id"] = 32222,},[4] = {["id"] = 32229,},},
	[2] = {[1] = {["id"] = 20496,},[2] = {["id"] = 23770,},[3] = {["id"] = 23774,},[4] = {["id"] = 23778,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 20657,},[2] = {["id"] = 23882,},[3] = {["id"] = 23884,},[4] = {["id"] = 23886,},},
	[1] = {[1] = {["id"] = 20668,},[2] = {["id"] = 23907,},[3] = {["id"] = 23911,},[4] = {["id"] = 23915,},},
	[2] = {[1] = {["id"] = 20660,},[2] = {["id"] = 23888,},[3] = {["id"] = 23893,},[4] = {["id"] = 23898,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 20917,},[2] = {["id"] = 34027,},[3] = {["id"] = 34029,},[4] = {["id"] = 34031,},},
	[1] = {[1] = {["id"] = 20944,},[2] = {["id"] = 34033,},[3] = {["id"] = 34036,},[4] = {["id"] = 34039,},},
	[2] = {[1] = {["id"] = 20930,},[2] = {["id"] = 34042,},[3] = {["id"] = 34045,},[4] = {["id"] = 34048,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23806,},[2] = {["id"] = 20803,},[3] = {["id"] = 23809,},[4] = {["id"] = 23811,},},
	[1] = {[1] = {["id"] = 20805,},[2] = {["id"] = 23813,},[3] = {["id"] = 23816,},[4] = {["id"] = 23819,},},
	[2] = {[1] = {["id"] = 20816,},[2] = {["id"] = 23831,},[3] = {["id"] = 23916,},[4] = {["id"] = 23924,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 28967,},[2] = {["id"] = 34051,},[3] = {["id"] = 34056,},[4] = {["id"] = 34061,},},
	[1] = {[1] = {["id"] = 32853,},[2] = {["id"] = 34066,},[3] = {["id"] = 34073,},[4] = {["id"] = 34080,},},
	[2] = {[1] = {["id"] = 32881,},[2] = {["id"] = 34088,},[3] = {["id"] = 34094,},[4] = {["id"] = 34100,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29424,},[2] = {["id"] = 45011,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29430,},[2] = {["id"] = 45012,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29439,},[2] = {["id"] = 45023,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29451,},[2] = {["id"] = 45029,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Assassination"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33398,},[2] = {["id"] = 37510,},[3] = {["id"] = 37514,},[4] = {["id"] = 37518,},},
	[1] = {[1] = {["id"] = 36508,},[2] = {["id"] = 37522,},[3] = {["id"] = 37527,},[4] = {["id"] = 37532,},},
	[2] = {[1] = {["id"] = 36514,},[2] = {["id"] = 37537,},[3] = {["id"] = 37541,},[4] = {["id"] = 37545,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33386,},[2] = {["id"] = 35580,},[3] = {["id"] = 35582,},[4] = {["id"] = 35584,},},
	[1] = {[1] = {["id"] = 34843,},[2] = {["id"] = 35586,},[3] = {["id"] = 35588,},[4] = {["id"] = 35590,},},
	[2] = {[1] = {["id"] = 34851,},[2] = {["id"] = 35592,},[3] = {["id"] = 35594,},[4] = {["id"] = 35596,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 18342,},[2] = {["id"] = 35864,},[3] = {["id"] = 35868,},[4] = {["id"] = 35871,},},
	[1] = {[1] = {["id"] = 25493,},[2] = {["id"] = 35874,},[3] = {["id"] = 35878,},[4] = {["id"] = 35882,},},
	[2] = {[1] = {["id"] = 25484,},[2] = {["id"] = 35886,},[3] = {["id"] = 35892,},[4] = {["id"] = 35898,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33375,},[2] = {["id"] = 35907,},[3] = {["id"] = 35908,},[4] = {["id"] = 35909,},},
	[1] = {[1] = {["id"] = 35414,},[2] = {["id"] = 35910,},[3] = {["id"] = 35913,},[4] = {["id"] = 35916,},},
	[2] = {[1] = {["id"] = 35419,},[2] = {["id"] = 35920,},[3] = {["id"] = 35922,},[4] = {["id"] = 35924,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33357,},[2] = {["id"] = 37587,},[3] = {["id"] = 37595,},[4] = {["id"] = 37603,},},
	[1] = {[1] = {["id"] = 36968,},[2] = {["id"] = 37613,},[3] = {["id"] = 37622,},[4] = {["id"] = 37631,},},
	[2] = {[1] = {["id"] = 36967,},[2] = {["id"] = 37640,},[3] = {["id"] = 37649,},[4] = {["id"] = 37658,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 61902,},[2] = {["id"] = 62090,},[3] = {["id"] = 64176,},[4] = {["id"] = 62096,},},
	[1] = {[1] = {["id"] = 61927,},[2] = {["id"] = 62099,},[3] = {["id"] = 62103,},[4] = {["id"] = 62107,},},
	[2] = {[1] = {["id"] = 61919,},[2] = {["id"] = 62111,},[3] = {["id"] = 62114,},[4] = {["id"] = 62117,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36616,},[2] = {["id"] = 45038,},},
	["at"] = ABILITY_TYPE_PASSIVE,},[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36630,},[2] = {["id"] = 45048,},},
	["at"] = ABILITY_TYPE_PASSIVE,},[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36636,},[2] = {["id"] = 45053,},},
	["at"] = ABILITY_TYPE_PASSIVE,},[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36641,},[2] = {["id"] = 45060,},},
	["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Earth"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 15957,},[2] = {["id"] = 19976,},[3] = {["id"] = 19979,},[4] = {["id"] = 19982,},},
	[1] = {[1] = {["id"] = 17874,},[2] = {["id"] = 33835,},[3] = {["id"] = 33838,},[4] = {["id"] = 33841,},},
	[2] = {[1] = {["id"] = 17878,},[2] = {["id"] = 33844,},[3] = {["id"] = 33848,},[4] = {["id"] = 33852,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29032,},[2] = {["id"] = 32190,},[3] = {["id"] = 32192,},[4] = {["id"] = 32194,},},
	[1] = {[1] = {["id"] = 31820,},[2] = {["id"] = 32197,},[3] = {["id"] = 32198,},[4] = {["id"] = 32199,},},
	[2] = {[1] = {["id"] = 31816,},[2] = {["id"] = 32203,},[3] = {["id"] = 32204,},[4] = {["id"] = 32205,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29043,},[2] = {["id"] = 32151,},[3] = {["id"] = 32154,},[4] = {["id"] = 32156,},},
	[1] = {[1] = {["id"] = 31874,},[2] = {["id"] = 32158,},[3] = {["id"] = 32162,},[4] = {["id"] = 32166,},},
	[2] = {[1] = {["id"] = 31888,},[2] = {["id"] = 32171,},[3] = {["id"] = 32172,},[4] = {["id"] = 32173,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29071,},[2] = {["id"] = 33862,},[3] = {["id"] = 33864,},[4] = {["id"] = 33866,},},
	[1] = {[1] = {["id"] = 29224,},[2] = {["id"] = 33868,},[3] = {["id"] = 33870,},[4] = {["id"] = 33872,},},
	[2] = {[1] = {["id"] = 32673,},[2] = {["id"] = 33875,},[3] = {["id"] = 33878,},[4] = {["id"] = 33881,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29037,},[2] = {["id"] = 33888,},[3] = {["id"] = 33893,},[4] = {["id"] = 33898,},},
	[1] = {[1] = {["id"] = 32685,},[2] = {["id"] = 33903,},[3] = {["id"] = 33912,},[4] = {["id"] = 33921,},},
	[2] = {[1] = {["id"] = 32678,},[2] = {["id"] = 33930,},[3] = {["id"] = 33937,},[4] = {["id"] = 33944,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 29059,},[2] = {["id"] = 33768,},[3] = {["id"] = 33773,},[4] = {["id"] = 33778,},},
	[1] = {[1] = {["id"] = 20779,},[2] = {["id"] = 33783,},[3] = {["id"] = 33790,},[4] = {["id"] = 33797,},},
	[2] = {[1] = {["id"] = 32710,},[2] = {["id"] = 33804,},[3] = {["id"] = 33810,},[4] = {["id"] = 33816,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29468,},[2] = {["id"] = 44996,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29463,},[2] = {["id"] = 44984,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29473,},[2] = {["id"] = 45001,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29475,},[2] = {["id"] = 45009,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Storm"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24785,},[2] = {["id"] = 30348,},[3] = {["id"] = 30351,},[4] = {["id"] = 30354,},},
	[1] = {[1] = {["id"] = 24806,},[2] = {["id"] = 30358,},[3] = {["id"] = 30362,},[4] = {["id"] = 30366,},},
	[2] = {[1] = {["id"] = 24804,},[2] = {["id"] = 30371,},[3] = {["id"] = 30376,},[4] = {["id"] = 30381,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 18718,},[2] = {["id"] = 30311,},[3] = {["id"] = 30315,},[4] = {["id"] = 30319,},},
	[1] = {[1] = {["id"] = 19123,},[2] = {["id"] = 30323,},[3] = {["id"] = 30327,},[4] = {["id"] = 30331,},},
	[2] = {[1] = {["id"] = 19109,},[2] = {["id"] = 30335,},[3] = {["id"] = 30339,},[4] = {["id"] = 30343,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23210,},[2] = {["id"] = 30229,},[3] = {["id"] = 30232,},[4] = {["id"] = 30235,},},
	[1] = {[1] = {["id"] = 23231,},[2] = {["id"] = 30238,},[3] = {["id"] = 30241,},[4] = {["id"] = 30244,},},
	[2] = {[1] = {["id"] = 23213,},[2] = {["id"] = 30247,},[3] = {["id"] = 30251,},[4] = {["id"] = 30255,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23182,},[2] = {["id"] = 30259,},[3] = {["id"] = 30264,},[4] = {["id"] = 30269,},},
	[1] = {[1] = {["id"] = 23200,},[2] = {["id"] = 30274,},[3] = {["id"] = 30280,},[4] = {["id"] = 30286,},},
	[2] = {[1] = {["id"] = 23205,},[2] = {["id"] = 30292,},[3] = {["id"] = 30297,},[4] = {["id"] = 30302,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23670,},[2] = {["id"] = 30386,},[3] = {["id"] = 30388,},[4] = {["id"] = 30390,},},
	[1] = {[1] = {["id"] = 23674,},[2] = {["id"] = 30392,},[3] = {["id"] = 30394,},[4] = {["id"] = 30396,},},
	[2] = {[1] = {["id"] = 23678,},[2] = {["id"] = 30398,},[3] = {["id"] = 30402,},[4] = {["id"] = 30406,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23234,},[2] = {["id"] = 30201,},[3] = {["id"] = 30203,},[4] = {["id"] = 30205,},},
	[1] = {[1] = {["id"] = 23236,},[2] = {["id"] = 30208,},[3] = {["id"] = 30211,},[4] = {["id"] = 30215,},},
	[2] = {[1] = {["id"] = 23277,},[2] = {["id"] = 30218,},[3] = {["id"] = 30221,},[4] = {["id"] = 30224,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31419,},[2] = {["id"] = 45188,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31421,},[2] = {["id"] = 45190,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31422,},[2] = {["id"] = 45192,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31425,},[2] = {["id"] = 45195,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Shadow"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 25411,},[2] = {["id"] = 37686,},[3] = {["id"] = 37691,},[4] = {["id"] = 37696,},},
	[1] = {[1] = {["id"] = 36493,},[2] = {["id"] = 37734,},[3] = {["id"] = 37739,},[4] = {["id"] = 37744,},},
	[2] = {[1] = {["id"] = 36485,},[2] = {["id"] = 37701,},[3] = {["id"] = 37707,},[4] = {["id"] = 37713,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 25375,},[2] = {["id"] = 36329,},[3] = {["id"] = 36333,},[4] = {["id"] = 36337,},},
	[1] = {[1] = {["id"] = 25380,},[2] = {["id"] = 36356,},[3] = {["id"] = 36362,},[4] = {["id"] = 36368,},},
	[2] = {[1] = {["id"] = 25377,},[2] = {["id"] = 36341,},[3] = {["id"] = 36346,},[4] = {["id"] = 36351,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 25255,},[2] = {["id"] = 36217,},[3] = {["id"] = 36220,},[4] = {["id"] = 36223,},},
	[1] = {[1] = {["id"] = 25260,},[2] = {["id"] = 36226,},[3] = {["id"] = 36230,},[4] = {["id"] = 36234,},},
	[2] = {[1] = {["id"] = 25267,},[2] = {["id"] = 36238,},[3] = {["id"] = 36241,},[4] = {["id"] = 36244,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},[4] = {
	["skillPool"] = {
	[0] = {[1] = {["id"] = 33195,},[2] = {["id"] = 37751,},[3] = {["id"] = 37757,},[4] = {["id"] = 37764,},},
	[1] = {[1] = {["id"] = 36049,},[2] = {["id"] = 37788,},[3] = {["id"] = 37792,},[4] = {["id"] = 37796,},},
	[2] = {[1] = {["id"] = 36028,},[2] = {["id"] = 37800,},[3] = {["id"] = 37808,},[4] = {["id"] = 37816,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},[5] = {
	["skillPool"] = {
	[0] = {[1] = {["id"] = 25352,},[2] = {["id"] = 38061,},[3] = {["id"] = 38063,},[4] = {["id"] = 38065,},},
	[1] = {[1] = {["id"] = 37470,},[2] = {["id"] = 38067,},[3] = {["id"] = 38071,},[4] = {["id"] = 38075,},},
	[2] = {[1] = {["id"] = 37475,},[2] = {["id"] = 38080,},[3] = {["id"] = 38088,},[4] = {["id"] = 38096,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},[6] = {
	["skillPool"] = {
	[0] = {[1] = {["id"] = 33211,},[2] = {["id"] = 36267,},[3] = {["id"] = 36271,},[4] = {["id"] = 36313,},},
	[1] = {[1] = {["id"] = 35434,},[2] = {["id"] = 36273,},[3] = {["id"] = 36278,},[4] = {["id"] = 36283,},},
	[2] = {[1] = {["id"] = 35441,},[2] = {["id"] = 36288,},[3] = {["id"] = 36293,},[4] = {["id"] = 36298,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36549,},[2] = {["id"] = 45103,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 18866,},[2] = {["id"] = 45071,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36532,},[2] = {["id"] = 45084,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36552,},[2] = {["id"] = 45115,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Siphon"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 25091,},[2] = {["id"] = 36154,},[3] = {["id"] = 36160,},[4] = {["id"] = 36166,},},
	[1] = {[1] = {["id"] = 35508,},[2] = {["id"] = 36172,},[3] = {["id"] = 36179,},[4] = {["id"] = 36186,},},
	[2] = {[1] = {["id"] = 35460,},[2] = {["id"] = 36193,},[3] = {["id"] = 36200,},[4] = {["id"] = 36207,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33291,},[2] = {["id"] = 35927,},[3] = {["id"] = 35929,},[4] = {["id"] = 35931,},},
	[1] = {[1] = {["id"] = 34838,},[2] = {["id"] = 35933,},[3] = {["id"] = 35937,},[4] = {["id"] = 35941,},},
	[2] = {[1] = {["id"] = 34835,},[2] = {["id"] = 35945,},[3] = {["id"] = 35947,},[4] = {["id"] = 35949,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33308,},[2] = {["id"] = 36098,},[3] = {["id"] = 36104,},[4] = {["id"] = 36109,},},
	[1] = {[1] = {["id"] = 34721,},[2] = {["id"] = 36118,},[3] = {["id"] = 36124,},[4] = {["id"] = 36129,},},
	[2] = {[1] = {["id"] = 34727,},[2] = {["id"] = 36134,},[3] = {["id"] = 36139,},[4] = {["id"] = 36144,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33326,},[2] = {["id"] = 37850,},[3] = {["id"] = 37857,},[4] = {["id"] = 37864,},},
	[1] = {[1] = {["id"] = 36943,},[2] = {["id"] = 37871,},[3] = {["id"] = 37879,},[4] = {["id"] = 37887,},},
	[2] = {[1] = {["id"] = 36957,},[2] = {["id"] = 37895,},[3] = {["id"] = 37904,},[4] = {["id"] = 37913,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33319,},[2] = {["id"] = 37955,},[3] = {["id"] = 37966,},[4] = {["id"] = 37977,},},
	[1] = {[1] = {["id"] = 36908,},[2] = {["id"] = 37989,},[3] = {["id"] = 38002,},[4] = {["id"] = 38015,},},
	[2] = {[1] = {["id"] = 36935,},[2] = {["id"] = 38028,},[3] = {["id"] = 38039,},[4] = {["id"] = 38050,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 33316,},[2] = {["id"] = 37922,},[3] = {["id"] = 37925,},[4] = {["id"] = 37928,},},
	[1] = {[1] = {["id"] = 36901,},[2] = {["id"] = 37931,},[3] = {["id"] = 37934,},[4] = {["id"] = 37937,},},
	[2] = {[1] = {["id"] = 36891,},[2] = {["id"] = 37940,},[3] = {["id"] = 37945,},[4] = {["id"] = 37950,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36560,},[2] = {["id"] = 45135,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36595,},[2] = {["id"] = 45150,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36603,},[2] = {["id"] = 45155,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 36587,},[2] = {["id"] = 45145,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Restoring"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22223,},[2] = {["id"] = 27388,},[3] = {["id"] = 27392,},[4] = {["id"] = 27396,},},
	[1] = {[1] = {["id"] = 22229,},[2] = {["id"] = 27401,},[3] = {["id"] = 27407,},[4] = {["id"] = 27413,},},
	[2] = {[1] = {["id"] = 22226,},[2] = {["id"] = 27419,},[3] = {["id"] = 27423,},[4] = {["id"] = 27427,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22250,},[2] = {["id"] = 24198,},[3] = {["id"] = 24201,},[4] = {["id"] = 24204,},},
	[1] = {[1] = {["id"] = 22253,},[2] = {["id"] = 24207,},[3] = {["id"] = 24210,},[4] = {["id"] = 24213,},},
	[2] = {[1] = {["id"] = 22256,},[2] = {["id"] = 24216,},[3] = {["id"] = 24219,},[4] = {["id"] = 24222,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22304,},[2] = {["id"] = 27334,},[3] = {["id"] = 27340,},[4] = {["id"] = 27342,},},
	[1] = {[1] = {["id"] = 22327,},[2] = {["id"] = 27346,},[3] = {["id"] = 27349,},[4] = {["id"] = 27352,},},
	[2] = {[1] = {["id"] = 22314,},[2] = {["id"] = 27368,},[3] = {["id"] = 27372,},[4] = {["id"] = 27376,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 26209,},[2] = {["id"] = 26995,},[3] = {["id"] = 27001,},[4] = {["id"] = 27007,},},
	[1] = {[1] = {["id"] = 26807,},[2] = {["id"] = 27013,},[3] = {["id"] = 27024,},[4] = {["id"] = 27030,},},
	[2] = {[1] = {["id"] = 26821,},[2] = {["id"] = 27036,},[3] = {["id"] = 27040,},[4] = {["id"] = 27043,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22265,},[2] = {["id"] = 27243,},[3] = {["id"] = 27249,},[4] = {["id"] = 27255,},},
	[1] = {[1] = {["id"] = 22259,},[2] = {["id"] = 27261,},[3] = {["id"] = 27269,},[4] = {["id"] = 27275,},},
	[2] = {[1] = {["id"] = 22262,},[2] = {["id"] = 27281,},[3] = {["id"] = 27288,},[4] = {["id"] = 27295,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22234,},[2] = {["id"] = 23968,},[3] = {["id"] = 23969,},[4] = {["id"] = 23970,},},
	[1] = {[1] = {["id"] = 22240,},[2] = {["id"] = 23996,},[3] = {["id"] = 23997,},[4] = {["id"] = 23998,},},
	[2] = {[1] = {["id"] = 22237,},[2] = {["id"] = 23983,},[3] = {["id"] = 23984,},[4] = {["id"] = 23985,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31751,},[2] = {["id"] = 45206,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31757,},[2] = {["id"] = 45207,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31760,},[2] = {["id"] = 45208,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31747,},[2] = {["id"] = 45202,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Dawn"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 21752,},[2] = {["id"] = 24044,},[3] = {["id"] = 24052,},[4] = {["id"] = 24063,},},
	[1] = {[1] = {["id"] = 21755,},[2] = {["id"] = 24288,},[3] = {["id"] = 24295,},[4] = {["id"] = 24301,},},
	[2] = {[1] = {["id"] = 21758,},[2] = {["id"] = 24308,},[3] = {["id"] = 24314,},[4] = {["id"] = 24320,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 21726,},[2] = {["id"] = 24160,},[3] = {["id"] = 24167,},[4] = {["id"] = 24171,},},
	[1] = {[1] = {["id"] = 21729,},[2] = {["id"] = 24174,},[3] = {["id"] = 24177,},[4] = {["id"] = 24180,},},
	[2] = {[1] = {["id"] = 21732,},[2] = {["id"] = 24184,},[3] = {["id"] = 24187,},[4] = {["id"] = 24195,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22057,},[2] = {["id"] = 24080,},[3] = {["id"] = 24101,},[4] = {["id"] = 24110,},},
	[1] = {[1] = {["id"] = 22110,},[2] = {["id"] = 24129,},[3] = {["id"] = 24139,},[4] = {["id"] = 24147,},},
	[2] = {[1] = {["id"] = 22095,},[2] = {["id"] = 24155,},[3] = {["id"] = 24156,},[4] = {["id"] = 24157,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 21761,},[2] = {["id"] = 27211,},[3] = {["id"] = 27219,},[4] = {["id"] = 27227,},},
	[1] = {[1] = {["id"] = 21765,},[2] = {["id"] = 27534,},[3] = {["id"] = 27549,},[4] = {["id"] = 27558,},},
	[2] = {[1] = {["id"] = 21763,},[2] = {["id"] = 27569,},[3] = {["id"] = 27578,},[4] = {["id"] = 27587,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 21776,},[2] = {["id"] = 27303,},[3] = {["id"] = 27304,},[4] = {["id"] = 27306,},},
	[1] = {[1] = {["id"] = 22006,},[2] = {["id"] = 27313,},[3] = {["id"] = 27316,},[4] = {["id"] = 27324,},},
	[2] = {[1] = {["id"] = 22004,},[2] = {["id"] = 27307,},[3] = {["id"] = 27309,},[4] = {["id"] = 27311,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 63029,},[2] = {["id"] = 63054,},[3] = {["id"] = 63056,},[4] = {["id"] = 63058,},},
	[1] = {[1] = {["id"] = 63044,},[2] = {["id"] = 63060,},[3] = {["id"] = 63063,},[4] = {["id"] = 63066,},},
	[2] = {[1] = {["id"] = 63046,},[2] = {["id"] = 63069,},[3] = {["id"] = 63072,},[4] = {["id"] = 63075,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31739,},[2] = {["id"] = 45214,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31744,},[2] = {["id"] = 45216,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31743,},[2] = {["id"] = 45215,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31721,},[2] = {["id"] = 45212,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Spear"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22138,},[2] = {["id"] = 23782,},[3] = {["id"] = 23783,},[4] = {["id"] = 23784,},},
	[1] = {[1] = {["id"] = 22144,},[2] = {["id"] = 23792,},[3] = {["id"] = 23793,},[4] = {["id"] = 23794,},},
	[2] = {[1] = {["id"] = 22139,},[2] = {["id"] = 23785,},[3] = {["id"] = 23787,},[4] = {["id"] = 23788,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 26114,},[2] = {["id"] = 27179,},[3] = {["id"] = 27182,},[4] = {["id"] = 27186,},},
	[1] = {[1] = {["id"] = 26792,},[2] = {["id"] = 27189,},[3] = {["id"] = 27193,},[4] = {["id"] = 27197,},},
	[2] = {[1] = {["id"] = 26797,},[2] = {["id"] = 27201,},[3] = {["id"] = 27204,},[4] = {["id"] = 27207,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 26158,},[2] = {["id"] = 26971,},[3] = {["id"] = 26973,},[4] = {["id"] = 26975,},},
	[1] = {[1] = {["id"] = 26800,},[2] = {["id"] = 26977,},[3] = {["id"] = 26980,},[4] = {["id"] = 26983,},},
	[2] = {[1] = {["id"] = 26804,},[2] = {["id"] = 26986,},[3] = {["id"] = 26989,},[4] = {["id"] = 26992,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22149,},[2] = {["id"] = 23709,},[3] = {["id"] = 23713,},[4] = {["id"] = 23716,},},
	[1] = {[1] = {["id"] = 22161,},[2] = {["id"] = 23719,},[3] = {["id"] = 23722,},[4] = {["id"] = 23726,},},
	[2] = {[1] = {["id"] = 15540,},[2] = {["id"] = 23864,},[3] = {["id"] = 23869,},[4] = {["id"] = 23870,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 26188,},[2] = {["id"] = 27046,},[3] = {["id"] = 27059,},[4] = {["id"] = 27090,},},
	[1] = {[1] = {["id"] = 26858,},[2] = {["id"] = 27102,},[3] = {["id"] = 27112,},[4] = {["id"] = 27122,},},
	[2] = {[1] = {["id"] = 26869,},[2] = {["id"] = 27145,},[3] = {["id"] = 27156,},[4] = {["id"] = 27167,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 22178,},[2] = {["id"] = 27493,},[3] = {["id"] = 27497,},[4] = {["id"] = 27501,},},
	[1] = {[1] = {["id"] = 22182,},[2] = {["id"] = 27506,},[3] = {["id"] = 27510,},[4] = {["id"] = 27514,},},
	[2] = {[1] = {["id"] = 22180,},[2] = {["id"] = 27520,},[3] = {["id"] = 27526,},[4] = {["id"] = 27530,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31698,},[2] = {["id"] = 44046,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31708,},[2] = {["id"] = 44721,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31718,},[2] = {["id"] = 44730,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31565,},[2] = {["id"] = 44732,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Dark"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 27706,},[2] = {["id"] = 29833,},[3] = {["id"] = 29839,},[4] = {["id"] = 29844,},},
	[1] = {[1] = {["id"] = 28341,},[2] = {["id"] = 29849,},[3] = {["id"] = 29855,},[4] = {["id"] = 29861,},},
	[2] = {[1] = {["id"] = 28348,},[2] = {["id"] = 29867,},[3] = {["id"] = 29874,},[4] = {["id"] = 29881,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 43714,},[2] = {["id"] = 47548,},[3] = {["id"] = 47550,},[4] = {["id"] = 47552,},},
	[1] = {[1] = {["id"] = 46331,},[2] = {["id"] = 47554,},[3] = {["id"] = 47557,},[4] = {["id"] = 47560,},},
	[2] = {[1] = {["id"] = 46324,},[2] = {["id"] = 47565,},[3] = {["id"] = 47567,},[4] = {["id"] = 47569,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 28025,},[2] = {["id"] = 30083,},[3] = {["id"] = 30085,},[4] = {["id"] = 30087,},},
	[1] = {[1] = {["id"] = 28308,},[2] = {["id"] = 30089,},[3] = {["id"] = 30092,},[4] = {["id"] = 30095,},},
	[2] = {[1] = {["id"] = 28311,},[2] = {["id"] = 30098,},[3] = {["id"] = 30103,},[4] = {["id"] = 30107,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24371,},[2] = {["id"] = 30152,},[3] = {["id"] = 30157,},[4] = {["id"] = 30162,},},
	[1] = {[1] = {["id"] = 24578,},[2] = {["id"] = 30167,},[3] = {["id"] = 30172,},[4] = {["id"] = 30177,},},
	[2] = {[1] = {["id"] = 24574,},[2] = {["id"] = 30182,},[3] = {["id"] = 30188,},[4] = {["id"] = 30194,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24584,},[2] = {["id"] = 29995,},[3] = {["id"] = 30004,},[4] = {["id"] = 30012,},},
	[1] = {[1] = {["id"] = 24595,},[2] = {["id"] = 30022,},[3] = {["id"] = 30033,},[4] = {["id"] = 30043,},},
	[2] = {[1] = {["id"] = 24589,},[2] = {["id"] = 30056,},[3] = {["id"] = 30064,},[4] = {["id"] = 30072,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24828,},[2] = {["id"] = 29889,},[3] = {["id"] = 29899,},[4] = {["id"] = 29909,},},
	[1] = {[1] = {["id"] = 24842,},[2] = {["id"] = 29919,},[3] = {["id"] = 29929,},[4] = {["id"] = 29939,},},
	[2] = {[1] = {["id"] = 24834,},[2] = {["id"] = 29949,},[3] = {["id"] = 29961,},[4] = {["id"] = 29973,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31386,},[2] = {["id"] = 45176,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31383,},[2] = {["id"] = 45172,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31378,},[2] = {["id"] = 45165,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31389,},[2] = {["id"] = 45181,},},["at"] = ABILITY_TYPE_PASSIVE,},},
	["Daedric"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23634,},[2] = {["id"] = 30528,},[3] = {["id"] = 30533,},[4] = {["id"] = 30538,},},
	[1] = {[1] = {["id"] = 23492,},[2] = {["id"] = 30564,},[3] = {["id"] = 30569,},[4] = {["id"] = 30575,},},
	[2] = {[1] = {["id"] = 23495,},[2] = {["id"] = 30543,},[3] = {["id"] = 30548,},[4] = {["id"] = 30553,},},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 23304,},[2] = {["id"] = 30631,},[3] = {["id"] = 30636,},[4] = {["id"] = 30641,},},
	[1] = {[1] = {["id"] = 23319,},[2] = {["id"] = 30647,},[3] = {["id"] = 30652,},[4] = {["id"] = 30657,},},
	[2] = {[1] = {["id"] = 23316,},[2] = {["id"] = 30664,},[3] = {["id"] = 30669,},[4] = {["id"] = 30674,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24326,},[2] = {["id"] = 30491,},[3] = {["id"] = 30495,},[4] = {["id"] = 30499,},},
	[1] = {[1] = {["id"] = 24328,},[2] = {["id"] = 30503,},[3] = {["id"] = 30507,},[4] = {["id"] = 30511,},},
	[2] = {[1] = {["id"] = 24330,},[2] = {["id"] = 30515,},[3] = {["id"] = 30519,},[4] = {["id"] = 30523,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24613,},[2] = {["id"] = 30581,},[3] = {["id"] = 30584,},[4] = {["id"] = 30587,},},
	[1] = {[1] = {["id"] = 24636,},[2] = {["id"] = 30592,},[3] = {["id"] = 30595,},[4] = {["id"] = 30598,},},
	[2] = {[1] = {["id"] = 24639,},[2] = {["id"] = 30618,},[3] = {["id"] = 30622,},[4] = {["id"] = 30626,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 24158,},[2] = {["id"] = 30410,},[3] = {["id"] = 30414,},[4] = {["id"] = 30418,},},
	[1] = {[1] = {["id"] = 24165,},[2] = {["id"] = 30422,},[3] = {["id"] = 30427,},[4] = {["id"] = 30432,},},
	[2] = {[1] = {["id"] = 24163,},[2] = {["id"] = 30437,},[3] = {["id"] = 30441,},[4] = {["id"] = 30445,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 28418,},[2] = {["id"] = 30457,},[3] = {["id"] = 30460,},[4] = {["id"] = 30463,},},
	[1] = {[1] = {["id"] = 29489,},[2] = {["id"] = 30466,},[3] = {["id"] = 30470,},[4] = {["id"] = 30474,},},
	[2] = {[1] = {["id"] = 29482,},[2] = {["id"] = 30478,},[3] = {["id"] = 30482,},[4] = {["id"] = 30486,},},
	},["at"] = ABILITY_TYPE_ACTIVE,},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31398,},[2] = {["id"] = 45198,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31396,},[2] = {["id"] = 45196,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31417,},[2] = {["id"] = 45200,},},["at"] = ABILITY_TYPE_PASSIVE,},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 31412,},[2] = {["id"] = 45199,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	["Animal"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85982},[2] = {["id"] = 85983},[3] = {["id"] = 85984},[4] = {["id"] = 85985}},
	[1] = {[1] = {["id"] = 85986},[2] = {["id"] = 85987},[3] = {["id"] = 85988},[4] = {["id"] = 85989}},
	[2] = {[1] = {["id"] = 85990},[2] = {["id"] = 85991},[3] = {["id"] = 85992},[4] = {["id"] = 85993}},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85995},[2] = {["id"] = 85996},[3] = {["id"] = 85997},[4] = {["id"] = 85998}},
	[1] = {[1] = {["id"] = 85999},[2] = {["id"] = 86000},[3] = {["id"] = 86001},[4] = {["id"] = 86002}},
	[2] = {[1] = {["id"] = 86003},[2] = {["id"] = 86004},[3] = {["id"] = 86005},[4] = {["id"] = 86006}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86009},[2] = {["id"] = 86012},[3] = {["id"] = 86013},[4] = {["id"] = 93593}},
	[1] = {[1] = {["id"] = 86015},[2] = {["id"] = 86016},[3] = {["id"] = 86017},[4] = {["id"] = 93778}},
	[2] = {[1] = {["id"] = 86014},[2] = {["id"] = 86019},[3] = {["id"] = 86020},[4] = {["id"] = 86021}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86023},[2] = {["id"] = 86024},[3] = {["id"] = 86025},[4] = {["id"] = 86026}},
	[1] = {[1] = {["id"] = 86027},[2] = {["id"] = 86028},[3] = {["id"] = 86029},[4] = {["id"] = 86030}},
	[2] = {[1] = {["id"] = 86031},[2] = {["id"] = 86032},[3] = {["id"] = 86033},[4] = {["id"] = 86034}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86050},[2] = {["id"] = 86051},[3] = {["id"] = 86052},[4] = {["id"] = 86053}},
	[1] = {[1] = {["id"] = 86054},[2] = {["id"] = 86055},[3] = {["id"] = 86056},[4] = {["id"] = 86057}},
	[2] = {[1] = {["id"] = 86058},[2] = {["id"] = 86059},[3] = {["id"] = 86060},[4] = {["id"] = 86061}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86037},[2] = {["id"] = 86038},[3] = {["id"] = 86039},[4] = {["id"] = 86040}},
	[1] = {[1] = {["id"] = 86041},[2] = {["id"] = 86042},[3] = {["id"] = 86043},[4] = {["id"] = 86044}},
	[2] = {[1] = {["id"] = 86045},[2] = {["id"] = 86046},[3] = {["id"] = 86047},[4] = {["id"] = 86048}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86064},[2] = {["id"] = 86065}},["at"] = ABILITY_TYPE_PASSIVE},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86062},[2] = {["id"] = 86063}},["at"] = ABILITY_TYPE_PASSIVE},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86066},[2] = {["id"] = 86067}},["at"] = ABILITY_TYPE_PASSIVE},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86068},[2] = {["id"] = 86069}},["at"] = ABILITY_TYPE_PASSIVE}
	},
	["Green"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85532},[2] = {["id"] = 93966},[3] = {["id"] = 93967},[4] = {["id"] = 93968}},
	[1] = {[1] = {["id"] = 85804},[2] = {["id"] = 93969},[3] = {["id"] = 93970},[4] = {["id"] = 93971}},
	[2] = {[1] = {["id"] = 85807},[2] = {["id"] = 93972},[3] = {["id"] = 93973},[4] = {["id"] = 93974}},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85536},[2] = {["id"] = 93769},[3] = {["id"] = 93770},[4] = {["id"] = 93771}},
	[1] = {[1] = {["id"] = 85862},[2] = {["id"] = 93772},[3] = {["id"] = 93773},[4] = {["id"] = 93774}},
	[2] = {[1] = {["id"] = 85863},[2] = {["id"] = 93775},[3] = {["id"] = 93776},[4] = {["id"] = 93777}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85578},[2] = {["id"] = 93802},[3] = {["id"] = 93803},[4] = {["id"] = 93804}},
	[1] = {[1] = {["id"] = 85840},[2] = {["id"] = 93805},[3] = {["id"] = 93806},[4] = {["id"] = 93807}},
	[2] = {[1] = {["id"] = 85845},[2] = {["id"] = 93808},[3] = {["id"] = 93809},[4] = {["id"] = 93810}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85552},[2] = {["id"] = 93875},[3] = {["id"] = 93876},[4] = {["id"] = 93877}},
	[1] = {[1] = {["id"] = 85850},[2] = {["id"] = 93878},[3] = {["id"] = 93879},[4] = {["id"] = 93880}},
	[2] = {[1] = {["id"] = 85851},[2] = {["id"] = 93881},[3] = {["id"] = 93882},[4] = {["id"] = 93883}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85539},[2] = {["id"] = 93906},[3] = {["id"] = 93907},[4] = {["id"] = 93908}},
	[1] = {[1] = {["id"] = 85854},[2] = {["id"] = 93909},[3] = {["id"] = 93910},[4] = {["id"] = 93911}},
	[2] = {[1] = {["id"] = 85855},[2] = {["id"] = 93912},[3] = {["id"] = 93913},[4] = {["id"] = 93914}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 85564},[2] = {["id"] = 93932},[3] = {["id"] = 93933},[4] = {["id"] = 93934}},
	[1] = {[1] = {["id"] = 85859},[2] = {["id"] = 93935},[3] = {["id"] = 93936},[4] = {["id"] = 93937}},
	[2] = {[1] = {["id"] = 85858},[2] = {["id"] = 93938},[3] = {["id"] = 93939},[4] = {["id"] = 93940}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 85882},[2] = {["id"] = 85883}},["at"] = ABILITY_TYPE_PASSIVE},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 85878},[2] = {["id"] = 85879}},["at"] = ABILITY_TYPE_PASSIVE},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 85876},[2] = {["id"] = 85877}},["at"] = ABILITY_TYPE_PASSIVE},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 85880},[2] = {["id"] = 85881}},["at"] = ABILITY_TYPE_PASSIVE}
	},
	["Winter"] = {
	[1] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86109},[2] = {["id"] = 86110},[3] = {["id"] = 86111},[4] = {["id"] = 86112}},
	[1] = {[1] = {["id"] = 86113},[2] = {["id"] = 86114},[3] = {["id"] = 86115},[4] = {["id"] = 86116}},
	[2] = {[1] = {["id"] = 86117},[2] = {["id"] = 86118},[3] = {["id"] = 86119},[4] = {["id"] = 86120}},
	},["at"] = ABILITY_TYPE_ULTIMATE,},
	[2] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86122},[2] = {["id"] = 86123},[3] = {["id"] = 86124},[4] = {["id"] = 86125}},
	[1] = {[1] = {["id"] = 86126},[2] = {["id"] = 86127},[3] = {["id"] = 86128},[4] = {["id"] = 86129}},
	[2] = {[1] = {["id"] = 86130},[2] = {["id"] = 86131},[3] = {["id"] = 86132},[4] = {["id"] = 86133}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[3] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86161},[2] = {["id"] = 86162},[3] = {["id"] = 86163},[4] = {["id"] = 86164}},
	[1] = {[1] = {["id"] = 86165},[2] = {["id"] = 86166},[3] = {["id"] = 86167},[4] = {["id"] = 86168}},
	[2] = {[1] = {["id"] = 86169},[2] = {["id"] = 86170},[3] = {["id"] = 86171},[4] = {["id"] = 86172}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[4] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86148},[2] = {["id"] = 86149},[3] = {["id"] = 86150},[4] = {["id"] = 86151}},
	[1] = {[1] = {["id"] = 86152},[2] = {["id"] = 86153},[3] = {["id"] = 86154},[4] = {["id"] = 86155}},
	[2] = {[1] = {["id"] = 86156},[2] = {["id"] = 86157},[3] = {["id"] = 86158},[4] = {["id"] = 86159}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[5] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86135},[2] = {["id"] = 86136},[3] = {["id"] = 86137},[4] = {["id"] = 86138}},
	[1] = {[1] = {["id"] = 86139},[2] = {["id"] = 86140},[3] = {["id"] = 86141},[4] = {["id"] = 86142}},
	[2] = {[1] = {["id"] = 86143},[2] = {["id"] = 86144},[3] = {["id"] = 86145},[4] = {["id"] = 86146}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[6] = {["skillPool"] = {
	[0] = {[1] = {["id"] = 86175},[2] = {["id"] = 86176},[3] = {["id"] = 86177},[4] = {["id"] = 86178}},
	[1] = {[1] = {["id"] = 86179},[2] = {["id"] = 86180},[3] = {["id"] = 86181},[4] = {["id"] = 86182}},
	[2] = {[1] = {["id"] = 86183},[2] = {["id"] = 86184},[3] = {["id"] = 86185},[4] = {["id"] = 86186}}
	},["at"] = ABILITY_TYPE_ACTIVE},
	[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86191},[2] = {["id"] = 86192}},["at"] = ABILITY_TYPE_PASSIVE},
	[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86189},[2] = {["id"] = 86190}},["at"] = ABILITY_TYPE_PASSIVE},
	[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86193},[2] = {["id"] = 86194}},["at"] = ABILITY_TYPE_PASSIVE},
	[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 86195},[2] = {["id"] = 86196}},["at"] = ABILITY_TYPE_PASSIVE}
	},
},
[SKILL_TYPE_WEAPON] = {
	[1] = { -- Two Handed
		
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83216,},[2] = {["id"] = 86269,},[3] = {["id"] = 86272,},[4] = {["id"] = 86275,},},
		[1] = {[1] = {["id"] = 83229,},[2] = {["id"] = 86278,},[3] = {["id"] = 86281,},[4] = {["id"] = 86284,},},
		[2] = {[1] = {["id"] = 83238,},[2] = {["id"] = 86287,},[3] = {["id"] = 86291,},[4] = {["id"] = 86295,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		
		
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 20919,},[2] = {["id"] = 39742,},[3] = {["id"] = 39744,},[4] = {["id"] = 39746,},},
		[1] = {[1] = {["id"] = 38745,},[2] = {["id"] = 39748,},[3] = {["id"] = 39751,},[4] = {["id"] = 39754,},},
		[2] = {[1] = {["id"] = 38754,},[2] = {["id"] = 39757,},[3] = {["id"] = 39763,},[4] = {["id"] = 39769,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28448,},[2] = {["id"] = 39785,},[3] = {["id"] = 39789,},[4] = {["id"] = 39793,},},
		[1] = {[1] = {["id"] = 38788,},[2] = {["id"] = 39797,},[3] = {["id"] = 39802,},[4] = {["id"] = 39807,},},
		[2] = {[1] = {["id"] = 38778,},[2] = {["id"] = 39812,},[3] = {["id"] = 39817,},[4] = {["id"] = 39822,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28279,},[2] = {["id"] = 39962,},[3] = {["id"] = 39965,},[4] = {["id"] = 39968,},},
		[1] = {[1] = {["id"] = 38814,},[2] = {["id"] = 39976,},[3] = {["id"] = 39980,},[4] = {["id"] = 39984,},},
		[2] = {[1] = {["id"] = 38807,},[2] = {["id"] = 40000,},[3] = {["id"] = 40004,},[4] = {["id"] = 40008,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28302,},[2] = {["id"] = 39919,},[3] = {["id"] = 39925,},[4] = {["id"] = 39928,},},
		[1] = {[1] = {["id"] = 38823,},[2] = {["id"] = 39932,},[3] = {["id"] = 39937,},[4] = {["id"] = 39942,},},
		[2] = {[1] = {["id"] = 38819,},[2] = {["id"] = 39948,},[3] = {["id"] = 39952,},[4] = {["id"] = 39957,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28297,},[2] = {["id"] = 39868,},[3] = {["id"] = 39871,},[4] = {["id"] = 39881,},},
		[1] = {[1] = {["id"] = 38794,},[2] = {["id"] = 39884,},[3] = {["id"] = 39888,},[4] = {["id"] = 39892,},},
		[2] = {[1] = {["id"] = 38802,},[2] = {["id"] = 39896,},[3] = {["id"] = 39900,},[4] = {["id"] = 39904,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29387,},[2] = {["id"] = 45444,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29375,},[2] = {["id"] = 45430,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29388,},[2] = {["id"] = 45443,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29389,},[2] = {["id"] = 45446,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29391,},[2] = {["id"] = 45448,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- One hand and shield
		
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83272,},[2] = {["id"] = 86316,},[3] = {["id"] = 86319,},[4] = {["id"] = 86322,},},
		[1] = {[1] = {["id"] = 83292,},[2] = {["id"] = 86325,},[3] = {["id"] = 86329,},[4] = {["id"] = 86333,},},
		[2] = {[1] = {["id"] = 83310,},[2] = {["id"] = 86337,},[3] = {["id"] = 86341,},[4] = {["id"] = 86345,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		
		
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28306,},[2] = {["id"] = 41473,},[3] = {["id"] = 41475,},[4] = {["id"] = 41477,},},
		[1] = {[1] = {["id"] = 38256,},[2] = {["id"] = 41479,},[3] = {["id"] = 41483,},[4] = {["id"] = 41487,},},
		[2] = {[1] = {["id"] = 38250,},[2] = {["id"] = 41491,},[3] = {["id"] = 41494,},[4] = {["id"] = 41497,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {	["skillPool"] = {
		[0] = {[1] = {["id"] = 28304,},[2] = {["id"] = 41387,},[3] = {["id"] = 41391,},[4] = {["id"] = 41394,},},
		[1] = {[1] = {["id"] = 38268,},[2] = {["id"] = 41397,},[3] = {["id"] = 41398,},[4] = {["id"] = 41403,},},
		[2] = {[1] = {["id"] = 38264,},[2] = {["id"] = 41406,},[3] = {["id"] = 41410,},[4] = {["id"] = 41414,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28727,},[2] = {["id"] = 41349,},[3] = {["id"] = 41350,},[4] = {["id"] = 41351,},},
		[1] = {[1] = {["id"] = 38312,},[2] = {["id"] = 41352,},[3] = {["id"] = 41355,},[4] = {["id"] = 41358,},},
		[2] = {[1] = {["id"] = 38317,},[2] = {["id"] = 41370,},[3] = {["id"] = 41375,},[4] = {["id"] = 41380,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28719,},[2] = {["id"] = 41506,},[3] = {["id"] = 41509,},[4] = {["id"] = 41512,},},
		[1] = {[1] = {["id"] = 38401,},[2] = {["id"] = 41518,},[3] = {["id"] = 41522,},[4] = {["id"] = 41526,},},
		[2] = {[1] = {["id"] = 38405,},[2] = {["id"] = 41530,},[3] = {["id"] = 41534,},[4] = {["id"] = 41538,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28365,},[2] = {["id"] = 41429,},[3] = {["id"] = 41432,},[4] = {["id"] = 41435,},},
		[1] = {[1] = {["id"] = 38455,},[2] = {["id"] = 41438,},[3] = {["id"] = 41443,},[4] = {["id"] = 41448,},},
		[2] = {[1] = {["id"] = 38452,},[2] = {["id"] = 41453,},[3] = {["id"] = 41456,},[4] = {["id"] = 41459,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29420,},[2] = {["id"] = 45471,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29397,},[2] = {["id"] = 45452,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29415,},[2] = {["id"] = 45469,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29399,},[2] = {["id"] = 45472,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29422,},[2] = {["id"] = 45473,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Dual Wield
	
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83600,},[2] = {["id"] = 86360,},[3] = {["id"] = 86365,},[4] = {["id"] = 86370,},},
		[1] = {[1] = {["id"] = 85187,},[2] = {["id"] = 86383,},[3] = {["id"] = 86388,},[4] = {["id"] = 86393,},},
		[2] = {[1] = {["id"] = 85179,},[2] = {["id"] = 86398,},[3] = {["id"] = 86404,},[4] = {["id"] = 86410,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
	
	
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28379,},[2] = {["id"] = 40658,},[3] = {["id"] = 40661,},[4] = {["id"] = 40664,},},
		[1] = {[1] = {["id"] = 38839,},[2] = {["id"] = 40667,},[3] = {["id"] = 40671,},[4] = {["id"] = 40675,},},
		[2] = {[1] = {["id"] = 38845,},[2] = {["id"] = 40679,},[3] = {["id"] = 40683,},[4] = {["id"] = 40687,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28607,},[2] = {["id"] = 40578,},[3] = {["id"] = 40580,},[4] = {["id"] = 40582,},},
		[1] = {[1] = {["id"] = 38857,},[2] = {["id"] = 40584,},[3] = {["id"] = 40587,},[4] = {["id"] = 40590,},},
		[2] = {[1] = {["id"] = 38846,},[2] = {["id"] = 40593,},[3] = {["id"] = 40596,},[4] = {["id"] = 40599,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28591,},[2] = {["id"] = 40708,},[3] = {["id"] = 40711,},[4] = {["id"] = 40714,},},
		[1] = {[1] = {["id"] = 38891,},[2] = {["id"] = 40717,},[3] = {["id"] = 40724,},[4] = {["id"] = 40731,},},
		[2] = {[1] = {["id"] = 38861,},[2] = {["id"] = 40738,},[3] = {["id"] = 40741,},[4] = {["id"] = 40744,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28613,},[2] = {["id"] = 40631,},[3] = {["id"] = 40632,},[4] = {["id"] = 40633,},},
		[1] = {[1] = {["id"] = 38901,},[2] = {["id"] = 40634,},[3] = {["id"] = 40638,},[4] = {["id"] = 40642,},},
		[2] = {[1] = {["id"] = 38906,},[2] = {["id"] = 40646,},[3] = {["id"] = 40649,},[4] = {["id"] = 40651,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 21157,},[2] = {["id"] = 40604,},[3] = {["id"] = 40607,},[4] = {["id"] = 40610,},},
		[1] = {[1] = {["id"] = 38914,},[2] = {["id"] = 40613,},[3] = {["id"] = 40616,},[4] = {["id"] = 40619,},},
		[2] = {[1] = {["id"] = 38910,},[2] = {["id"] = 40622,},[3] = {["id"] = 40625,},[4] = {["id"] = 40628,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 18929,},[2] = {["id"] = 45476,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30873,},[2] = {["id"] = 45477,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30872,},[2] = {["id"] = 45478,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 21114,},[2] = {["id"] = 45481,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30893,},[2] = {["id"] = 45482,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[4] = { -- Bow
	
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83465,},[2] = {["id"] = 86582,},[3] = {["id"] = 86584,},[4] = {["id"] = 86586,},},
		[1] = {[1] = {["id"] = 85257,},[2] = {["id"] = 86597,},[3] = {["id"] = 86600,},[4] = {["id"] = 86603,},},
		[2] = {[1] = {["id"] = 85451,},[2] = {["id"] = 86614,},[3] = {["id"] = 86617,},[4] = {["id"] = 86620,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
	
	
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28869,},[2] = {["id"] = 40796,},[3] = {["id"] = 40801,},[4] = {["id"] = 40806,},},
		[1] = {[1] = {["id"] = 38645,},[2] = {["id"] = 40813,},[3] = {["id"] = 40818,},[4] = {["id"] = 40823,},},
		[2] = {[1] = {["id"] = 38660,},[2] = {["id"] = 40830,},[3] = {["id"] = 40836,},[4] = {["id"] = 40842,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28876,},[2] = {["id"] = 40911,},[3] = {["id"] = 40914,},[4] = {["id"] = 40917,},},
		[1] = {[1] = {["id"] = 38689,},[2] = {["id"] = 40920,},[3] = {["id"] = 40926,},[4] = {["id"] = 40932,},},
		[2] = {[1] = {["id"] = 38695,},[2] = {["id"] = 40938,},[3] = {["id"] = 40941,},[4] = {["id"] = 40944,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28879,},[2] = {["id"] = 40852,},[3] = {["id"] = 40855,},[4] = {["id"] = 40858,},},
		[1] = {[1] = {["id"] = 38672,},[2] = {["id"] = 40861,},[3] = {["id"] = 40865,},[4] = {["id"] = 40869,},},
		[2] = {[1] = {["id"] = 38669,},[2] = {["id"] = 40873,},[3] = {["id"] = 40878,},[4] = {["id"] = 40883,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 31271,},[2] = {["id"] = 40759,},[3] = {["id"] = 40762,},[4] = {["id"] = 40765,},},
		[1] = {[1] = {["id"] = 38705,},[2] = {["id"] = 40769,},[3] = {["id"] = 40773,},[4] = {["id"] = 40777,},},
		[2] = {[1] = {["id"] = 38701,},[2] = {["id"] = 40781,},[3] = {["id"] = 40785,},[4] = {["id"] = 40789,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28882,},[2] = {["id"] = 40890,},[3] = {["id"] = 40891,},[4] = {["id"] = 40892,},},
		[1] = {[1] = {["id"] = 38685,},[2] = {["id"] = 40893,},[3] = {["id"] = 40895,},[4] = {["id"] = 40897,},},
		[2] = {[1] = {["id"] = 38687,},[2] = {["id"] = 40899,},[3] = {["id"] = 40903,},[4] = {["id"] = 40907,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30937,},[2] = {["id"] = 45494,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30930,},[2] = {["id"] = 45492,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30942,},[2] = {["id"] = 45493,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30936,},[2] = {["id"] = 45497,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30923,},[2] = {["id"] = 45498,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[5] = { -- Destruction Staff
	
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83619,},[2] = {["id"] = 86481,},[3] = {["id"] = 86483,},[4] = {["id"] = 86485,},},
		[1] = {[1] = {["id"] = 84434,},[2] = {["id"] = 86506,},[3] = {["id"] = 86508,},[4] = {["id"] = 86510,},},
		[2] = {[1] = {["id"] = 83642,},[2] = {["id"] = 86530,},[3] = {["id"] = 86532,},[4] = {["id"] = 86534,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
	
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 29091,},[2] = {["id"] = 40947,},[3] = {["id"] = 40956,},[4] = {["id"] = 40964,},},
		[1] = {[1] = {["id"] = 38984,},[2] = {["id"] = 40977,},[3] = {["id"] = 40995,},[4] = {["id"] = 41006,},},
		[2] = {[1] = {["id"] = 38937,},[2] = {["id"] = 41029,},[3] = {["id"] = 41038,},[4] = {["id"] = 41047,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28858,},[2] = {["id"] = 41627,},[3] = {["id"] = 41642,},[4] = {["id"] = 41658,},},
		[1] = {[1] = {["id"] = 39052,},[2] = {["id"] = 41673,},[3] = {["id"] = 41691,},[4] = {["id"] = 41711,},},
		[2] = {[1] = {["id"] = 39011,},[2] = {["id"] = 41738,},[3] = {["id"] = 41754,},[4] = {["id"] = 41769,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 46340,},[2] = {["id"] = 48950,},[3] = {["id"] = 48953,},[4] = {["id"] = 48956,},},
		[1] = {[1] = {["id"] = 46348,},[2] = {["id"] = 48959,},[3] = {["id"] = 48965,},[4] = {["id"] = 48971,},},
		[2] = {[1] = {["id"] = 46356,},[2] = {["id"] = 48977,},[3] = {["id"] = 48984,},[4] = {["id"] = 48991,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 29173,},[2] = {["id"] = 41544,},[3] = {["id"] = 41546,},[4] = {["id"] = 41548,},},
		[1] = {[1] = {["id"] = 39089,},[2] = {["id"] = 41550,},[3] = {["id"] = 41553,},[4] = {["id"] = 41556,},},
		[2] = {[1] = {["id"] = 39095,},[2] = {["id"] = 41559,},[3] = {["id"] = 41563,},[4] = {["id"] = 41567,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28800,},[2] = {["id"] = 42949,},[3] = {["id"] = 42953,},[4] = {["id"] = 42957,},},
		[1] = {[1] = {["id"] = 39143,},[2] = {["id"] = 42961,},[3] = {["id"] = 42968,},[4] = {["id"] = 42975,},},
		[2] = {[1] = {["id"] = 39161,},[2] = {["id"] = 42982,},[3] = {["id"] = 42989,},[4] = {["id"] = 42996,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30948,},[2] = {["id"] = 45500,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30957,},[2] = {["id"] = 45509,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30962,},[2] = {["id"] = 45512,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30959,},[2] = {["id"] = 45513,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30965,},[2] = {["id"] = 45514,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[6] = { -- Restoration Staff
	
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 83552,},[2] = {["id"] = 86421,},[3] = {["id"] = 86423,},[4] = {["id"] = 86425,},},
		[1] = {[1] = {["id"] = 83850,},[2] = {["id"] = 86428,},[3] = {["id"] = 86441,},[4] = {["id"] = 86454,},},
		[2] = {[1] = {["id"] = 85132,},[2] = {["id"] = 86467,},[3] = {["id"] = 86471,},[4] = {["id"] = 86475,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
	
	
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28385,},[2] = {["id"] = 41244,},[3] = {["id"] = 41246,},[4] = {["id"] = 41248,},},
		[1] = {[1] = {["id"] = 40058,},[2] = {["id"] = 41251,},[3] = {["id"] = 41253,},[4] = {["id"] = 41255,},},
		[2] = {[1] = {["id"] = 40060,},[2] = {["id"] = 41257,},[3] = {["id"] = 41261,},[4] = {["id"] = 41265,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28536,},[2] = {["id"] = 41269,},[3] = {["id"] = 41270,},[4] = {["id"] = 41271,},},
		[1] = {[1] = {["id"] = 40076,},[2] = {["id"] = 41272,},[3] = {["id"] = 41274,},[4] = {["id"] = 41276,},},
		[2] = {[1] = {["id"] = 40079,},[2] = {["id"] = 41278,},[3] = {["id"] = 41283,},[4] = {["id"] = 41288,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 37243,},[2] = {["id"] = 41139,},[3] = {["id"] = 41145,},[4] = {["id"] = 41151,},},
		[1] = {[1] = {["id"] = 40103,},[2] = {["id"] = 41157,},[3] = {["id"] = 41163,},[4] = {["id"] = 41169,},},
		[2] = {[1] = {["id"] = 40094,},[2] = {["id"] = 41175,},[3] = {["id"] = 41182,},[4] = {["id"] = 41189,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 37232,},[2] = {["id"] = 41306,},[3] = {["id"] = 41308,},[4] = {["id"] = 41310,},},
		[1] = {[1] = {["id"] = 40130,},[2] = {["id"] = 41294,},[3] = {["id"] = 41298,},[4] = {["id"] = 41302,},},
		[2] = {[1] = {["id"] = 40126,},[2] = {["id"] = 41312,},[3] = {["id"] = 41316,},[4] = {["id"] = 41320,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 31531,},[2] = {["id"] = 41199,},[3] = {["id"] = 41203,},[4] = {["id"] = 41207,},},
		[1] = {[1] = {["id"] = 40109,},[2] = {["id"] = 41211,},[3] = {["id"] = 41220,},[4] = {["id"] = 41225,},},
		[2] = {[1] = {["id"] = 40116,},[2] = {["id"] = 41230,},[3] = {["id"] = 41234,},[4] = {["id"] = 41239,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30973,},[2] = {["id"] = 45517,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30980,},[2] = {["id"] = 45519,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30972,},[2] = {["id"] = 45520,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30869,},[2] = {["id"] = 45521,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 30981,},[2] = {["id"] = 45524,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_ARMOR] = {
	[1] = { -- Light
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 29338,},[2] = {["id"] = 41106,},[3] = {["id"] = 41107,},[4] = {["id"] = 41108,},},
		[1] = {[1] = {["id"] = 39186,},[2] = {["id"] = 41109,},[3] = {["id"] = 41111,},[4] = {["id"] = 41113,},},
		[2] = {[1] = {["id"] = 39182,},[2] = {["id"] = 41115,},[3] = {["id"] = 41118,},[4] = {["id"] = 41121,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 29639,},[2] = {["id"] = 45548,},[3] = {["id"] = 45549,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29665,},[2] = {["id"] = 45557,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29663,},[2] = {["id"] = 45559,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29668,},[2] = {["id"] = 45561,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29667,},[2] = {["id"] = 45562,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- Medium
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 29556,},[2] = {["id"] = 41124,},[3] = {["id"] = 41125,},[4] = {["id"] = 41126,},},
		[1] = {[1] = {["id"] = 39195,},[2] = {["id"] = 41127,},[3] = {["id"] = 41129,},[4] = {["id"] = 41131,},},
		[2] = {[1] = {["id"] = 39192,},[2] = {["id"] = 41133,},[3] = {["id"] = 41135,},[4] = {["id"] = 41137,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 29743,},[2] = {["id"] = 45563,},[3] = {["id"] = 45564,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29687,},[2] = {["id"] = 45565,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29738,},[2] = {["id"] = 45567,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29686,},[2] = {["id"] = 45572,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29742,},[2] = {["id"] = 45574,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Heavy
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 29552,},[2] = {["id"] = 41078,},[3] = {["id"] = 41080,},[4] = {["id"] = 41082,},},
		[1] = {[1] = {["id"] = 39205,},[2] = {["id"] = 41085,},[3] = {["id"] = 41088,},[4] = {["id"] = 41091,},},
		[2] = {[1] = {["id"] = 39197,},[2] = {["id"] = 41097,},[3] = {["id"] = 41100,},[4] = {["id"] = 41103,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 29825,},[2] = {["id"] = 45531,},[3] = {["id"] = 45533,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29769,},[2] = {["id"] = 45526,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29804,},[2] = {["id"] = 45546,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29773,},[2] = {["id"] = 45528,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 29791,},[2] = {["id"] = 45529,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_WORLD] = {
	[1] = { -- Legerdemain
		[1] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 63799,},[2] = {["id"] = 63800,},[3] = {["id"] = 63801,},[4] = {["id"] = 63802,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 63803,},[2] = {["id"] = 63804,},[3] = {["id"] = 63805,},[4] = {["id"] = 63806,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 63807,},[2] = {["id"] = 63808,},[3] = {["id"] = 63809,},[4] = {["id"] = 63810,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 63811,},[2] = {["id"] = 63812,},[3] = {["id"] = 63813,},[4] = {["id"] = 63814,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 63815,},[2] = {["id"] = 63816,},[3] = {["id"] = 63817,},[4] = {["id"] = 63818,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- Soul magic
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39270,},[2] = {["id"] = 43089,},[3] = {["id"] = 43091,},[4] = {["id"] = 43093,},},
		[1] = {[1] = {["id"] = 40420,},[2] = {["id"] = 43095,},[3] = {["id"] = 43097,},[4] = {["id"] = 43099,},},
		[2] = {[1] = {["id"] = 40414,},[2] = {["id"] = 43101,},[3] = {["id"] = 43105,},[4] = {["id"] = 43109,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 26768,},[2] = {["id"] = 43050,},[3] = {["id"] = 43053,},[4] = {["id"] = 43056,},},
		[1] = {[1] = {["id"] = 40328,},[2] = {["id"] = 43059,},[3] = {["id"] = 43063,},[4] = {["id"] = 43067,},},
		[2] = {[1] = {["id"] = 40317,},[2] = {["id"] = 43071,},[3] = {["id"] = 43077,},[4] = {["id"] = 43083,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39266,},[2] = {["id"] = 45583,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39269,},[2] = {["id"] = 45590,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39263,},[2] = {["id"] = 45580,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Vampire
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32624,},[2] = {["id"] = 41918,},[3] = {["id"] = 41919,},[4] = {["id"] = 41920,},},
		[1] = {[1] = {["id"] = 38932,},[2] = {["id"] = 41924,},[3] = {["id"] = 41925,},[4] = {["id"] = 41926,},},
		[2] = {[1] = {["id"] = 38931,},[2] = {["id"] = 41933,},[3] = {["id"] = 41936,},[4] = {["id"] = 41937,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32893,},[2] = {["id"] = 41864,},[3] = {["id"] = 41865,},[4] = {["id"] = 41866,},},
		[1] = {[1] = {["id"] = 38949,},[2] = {["id"] = 41900,},[3] = {["id"] = 41901,},[4] = {["id"] = 41902,},},
		[2] = {[1] = {["id"] = 38956,},[2] = {["id"] = 41879,},[3] = {["id"] = 41880,},[4] = {["id"] = 41881,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32986,},[2] = {["id"] = 41807,},[3] = {["id"] = 41808,},[4] = {["id"] = 41809,},},
		[1] = {[1] = {["id"] = 38963,},[2] = {["id"] = 41813,},[3] = {["id"] = 41814,},[4] = {["id"] = 41815,},},
		[2] = {[1] = {["id"] = 38965,},[2] = {["id"] = 41822,},[3] = {["id"] = 41823,},[4] = {["id"] = 41824,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 42054,},[2] = {["id"] = 46045,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 33095,},[2] = {["id"] = 46041,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 33091,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 33096,},[2] = {["id"] = 46040,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 33093,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 33090,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[4] = { -- Werewolf
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32455,},[2] = {["id"] = 42356,},[3] = {["id"] = 42357,},[4] = {["id"] = 42358,},},
		[1] = {[1] = {["id"] = 39075,},[2] = {["id"] = 42365,},[3] = {["id"] = 42366,},[4] = {["id"] = 42367,},},
		[2] = {[1] = {["id"] = 39076,},[2] = {["id"] = 42377,},[3] = {["id"] = 42378,},[4] = {["id"] = 42379,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32632,},[2] = {["id"] = 42108,},[3] = {["id"] = 42109,},[4] = {["id"] = 42110,},},
		[1] = {[1] = {["id"] = 39105,},[2] = {["id"] = 42117,},[3] = {["id"] = 42118,},[4] = {["id"] = 42119,},},
		[2] = {[1] = {["id"] = 39104,},[2] = {["id"] = 42126,},[3] = {["id"] = 42127,},[4] = {["id"] = 42128,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 58310,},[2] = {["id"] = 58314,},[3] = {["id"] = 58315,},[4] = {["id"] = 58316,},},
		[1] = {[1] = {["id"] = 58317,},[2] = {["id"] = 58319,},[3] = {["id"] = 58321,},[4] = {["id"] = 58323,},},
		[2] = {[1] = {["id"] = 58325,},[2] = {["id"] = 58329,},[3] = {["id"] = 58332,},[4] = {["id"] = 58334,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 32633,},[2] = {["id"] = 42143,},[3] = {["id"] = 42144,},[4] = {["id"] = 42145,},},
		[1] = {[1] = {["id"] = 39113,},[2] = {["id"] = 42155,},[3] = {["id"] = 42156,},[4] = {["id"] = 42157,},},
		[2] = {[1] = {["id"] = 39114,},[2] = {["id"] = 42177,},[3] = {["id"] = 42178,},[4] = {["id"] = 42179,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 58405,},[2] = {["id"] = 58736,},[3] = {["id"] = 58738,},[4] = {["id"] = 58740,},},
		[1] = {[1] = {["id"] = 58742,},[2] = {["id"] = 58786,},[3] = {["id"] = 58790,},[4] = {["id"] = 58794,},},
		[2] = {[1] = {["id"] = 58798,},[2] = {["id"] = 58802,},[3] = {["id"] = 58805,},[4] = {["id"] = 58808,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 58855,},[2] = {["id"] = 58857,},[3] = {["id"] = 58859,},[4] = {["id"] = 58862,},},
		[1] = {[1] = {["id"] = 58864,},[2] = {["id"] = 58870,},[3] = {["id"] = 58873,},[4] = {["id"] = 58876,},},
		[2] = {[1] = {["id"] = 58879,},[2] = {["id"] = 58901,},[3] = {["id"] = 58904,},[4] = {["id"] = 58907,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 32636,},[2] = {["id"] = 46142,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 32634,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 32637,},[2] = {["id"] = 46135,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 32639,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[11] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 32638,},[2] = {["id"] = 46139,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[12] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 32641,},[2] = {["id"] = 46137,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_GUILD] = {
	[1] = { -- Dark Brotherhood
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 78219,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 77392,},[2] = {["id"] = 77394,},[3] = {["id"] = 77395,},[4] = {["id"] = 79865,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 77397,},[2] = {["id"] = 77398,},[3] = {["id"] = 77399,},[4] = {["id"] = 79868,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 77396,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 77400,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 77401,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- Fighters Guild
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 35713,},[2] = {["id"] = 42554,},[3] = {["id"] = 42560,},[4] = {["id"] = 42566,},},
		[1] = {[1] = {["id"] = 40161,},[2] = {["id"] = 42575,},[3] = {["id"] = 42581,},[4] = {["id"] = 42586,},},
		[2] = {[1] = {["id"] = 40158,},[2] = {["id"] = 42592,},[3] = {["id"] = 42595,},[4] = {["id"] = 42598,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 35721,},[2] = {["id"] = 42647,},[3] = {["id"] = 42651,},[4] = {["id"] = 42655,},},
		[1] = {[1] = {["id"] = 40300,},[2] = {["id"] = 42659,},[3] = {["id"] = 42665,},[4] = {["id"] = 42671,},},
		[2] = {[1] = {["id"] = 40336,},[2] = {["id"] = 42677,},[3] = {["id"] = 42687,},[4] = {["id"] = 42696,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 35737,},[2] = {["id"] = 42501,},[3] = {["id"] = 42505,},[4] = {["id"] = 42509,},},
		[1] = {[1] = {["id"] = 40181,},[2] = {["id"] = 42515,},[3] = {["id"] = 42522,},[4] = {["id"] = 42529,},},
		[2] = {[1] = {["id"] = 40169,},[2] = {["id"] = 42536,},[3] = {["id"] = 42542,},[4] = {["id"] = 42548,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 35762,},[2] = {["id"] = 42602,},[3] = {["id"] = 42606,},[4] = {["id"] = 42610,},},
		[1] = {[1] = {["id"] = 40194,},[2] = {["id"] = 42614,},[3] = {["id"] = 42619,},[4] = {["id"] = 42624,},},
		[2] = {[1] = {["id"] = 40195,},[2] = {["id"] = 42629,},[3] = {["id"] = 42635,},[4] = {["id"] = 42641,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 35750,},[2] = {["id"] = 42706,},[3] = {["id"] = 42713,},[4] = {["id"] = 42720,},},
		[1] = {[1] = {["id"] = 40382,},[2] = {["id"] = 42727,},[3] = {["id"] = 42737,},[4] = {["id"] = 42747,},},
		[2] = {[1] = {["id"] = 40372,},[2] = {["id"] = 42757,},[3] = {["id"] = 42764,},[4] = {["id"] = 42771,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 29062,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35803,},[2] = {["id"] = 45595,},[3] = {["id"] = 45596,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35800,},[2] = {["id"] = 45597,},[3] = {["id"] = 45599,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 40393,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 35804,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Mages Guild
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 16536,},[2] = {["id"] = 42461,},[3] = {["id"] = 42464,},[4] = {["id"] = 42467,},},
		[1] = {[1] = {["id"] = 40489,},[2] = {["id"] = 42470,},[3] = {["id"] = 42474,},[4] = {["id"] = 42478,},},
		[2] = {[1] = {["id"] = 40493,},[2] = {["id"] = 42482,},[3] = {["id"] = 42487,},[4] = {["id"] = 42492,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 30920,},[2] = {["id"] = 42410,},[3] = {["id"] = 42414,},[4] = {["id"] = 42418,},},
		[1] = {[1] = {["id"] = 40478,},[2] = {["id"] = 42422,},[3] = {["id"] = 42426,},[4] = {["id"] = 42430,},},
		[2] = {[1] = {["id"] = 40483,},[2] = {["id"] = 42443,},[3] = {["id"] = 42449,},[4] = {["id"] = 42455,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 28567,},[2] = {["id"] = 42199,},[3] = {["id"] = 42203,},[4] = {["id"] = 42207,},},
		[1] = {[1] = {["id"] = 40457,},[2] = {["id"] = 42212,},[3] = {["id"] = 42218,},[4] = {["id"] = 42224,},},
		[2] = {[1] = {["id"] = 40452,},[2] = {["id"] = 42230,},[3] = {["id"] = 42235,},[4] = {["id"] = 42240,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 31632,},[2] = {["id"] = 42293,},[3] = {["id"] = 42299,},[4] = {["id"] = 42305,},},
		[1] = {[1] = {["id"] = 40470,},[2] = {["id"] = 42311,},[3] = {["id"] = 42319,},[4] = {["id"] = 42327,},},
		[2] = {[1] = {["id"] = 40465,},[2] = {["id"] = 42335,},[3] = {["id"] = 42342,},[4] = {["id"] = 42349,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 31642,},[2] = {["id"] = 42247,},[3] = {["id"] = 42249,},[4] = {["id"] = 42251,},},
		[1] = {[1] = {["id"] = 40445,},[2] = {["id"] = 42253,},[3] = {["id"] = 42258,},[4] = {["id"] = 42263,},},
		[2] = {[1] = {["id"] = 40441,},[2] = {["id"] = 42268,},[3] = {["id"] = 42273,},[4] = {["id"] = 42278,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 29061,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 40436,},[2] = {["id"] = 45601,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 40437,},[2] = {["id"] = 45602,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[9] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 40438,},[2] = {["id"] = 45603,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[10] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 43561,},[2] = {["id"] = 45607,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[4] = { -- Thieves Guild
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 74580,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 76454,},[2] = {["id"] = 76455,},[3] = {["id"] = 76456,},[4] = {["id"] = 76457,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 76458,},[2] = {["id"] = 76459,},[3] = {["id"] = 76460,},[4] = {["id"] = 76461,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 76451,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 76452,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 1,["skillPool"] = {[1] = {["id"] = 76453,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[5] = { -- Undaunted
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39489,},[2] = {["id"] = 43241,},[3] = {["id"] = 43246,},[4] = {["id"] = 43251,},},
		[1] = {[1] = {["id"] = 41967,},[2] = {["id"] = 43256,},[3] = {["id"] = 43261,},[4] = {["id"] = 43266,},},
		[2] = {[1] = {["id"] = 41958,},[2] = {["id"] = 43271,},[3] = {["id"] = 43277,},[4] = {["id"] = 43287,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39425,},[2] = {["id"] = 43533,},[3] = {["id"] = 43537,},[4] = {["id"] = 43541,},},
		[1] = {[1] = {["id"] = 41990,},[2] = {["id"] = 43481,},[3] = {["id"] = 43485,},[4] = {["id"] = 43489,},},
		[2] = {[1] = {["id"] = 42012,},[2] = {["id"] = 43469,},[3] = {["id"] = 43473,},[4] = {["id"] = 43477,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39475,},[2] = {["id"] = 43353,},[3] = {["id"] = 43358,},[4] = {["id"] = 43363,},},
		[1] = {[1] = {["id"] = 42056,},[2] = {["id"] = 43368,},[3] = {["id"] = 43373,},[4] = {["id"] = 43378,},},
		[2] = {[1] = {["id"] = 42060,},[2] = {["id"] = 43383,},[3] = {["id"] = 43388,},[4] = {["id"] = 43393,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39369,},[2] = {["id"] = 43304,},[3] = {["id"] = 43307,},[4] = {["id"] = 43310,},},
		[1] = {[1] = {["id"] = 42138,},[2] = {["id"] = 43313,},[3] = {["id"] = 43318,},[4] = {["id"] = 43323,},},
		[2] = {[1] = {["id"] = 42176,},[2] = {["id"] = 43328,},[3] = {["id"] = 43331,},[4] = {["id"] = 43334,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 39298,},[2] = {["id"] = 43400,},[3] = {["id"] = 43403,},[4] = {["id"] = 43406,},},
		[1] = {[1] = {["id"] = 42028,},[2] = {["id"] = 43409,},[3] = {["id"] = 43412,},[4] = {["id"] = 43415,},},
		[2] = {[1] = {["id"] = 42038,},[2] = {["id"] = 43439,},[3] = {["id"] = 43443,},[4] = {["id"] = 43447,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 55584,},[2] = {["id"] = 55676,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 55366,},[2] = {["id"] = 55386,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_AVA] = {
	[1] = { -- Assault
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 38563,},[2] = {["id"] = 46525,},[3] = {["id"] = 46527,},[4] = {["id"] = 46529,},},
		[1] = {[1] = {["id"] = 40223,},[2] = {["id"] = 46531,},[3] = {["id"] = 46534,},[4] = {["id"] = 46537,},},
		[2] = {[1] = {["id"] = 40220,},[2] = {["id"] = 46540,},[3] = {["id"] = 46543,},[4] = {["id"] = 46546,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 38566,},[2] = {["id"] = 46484,},[3] = {["id"] = 46488,},[4] = {["id"] = 46492,},},
		[1] = {[1] = {["id"] = 40211,},[2] = {["id"] = 46497,},[3] = {["id"] = 46501,},[4] = {["id"] = 46505,},},
		[2] = {[1] = {["id"] = 40215,},[2] = {["id"] = 46509,},[3] = {["id"] = 46514,},[4] = {["id"] = 46519,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 61503,},[2] = {["id"] = 63236,},[3] = {["id"] = 63238,},[4] = {["id"] = 63240,},},
		[1] = {[1] = {["id"] = 61505,},[2] = {["id"] = 63243,},[3] = {["id"] = 63245,},[4] = {["id"] = 63247,},},
		[2] = {[1] = {["id"] = 61507,},[2] = {["id"] = 63249,},[3] = {["id"] = 63252,},[4] = {["id"] = 63255,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 33376,},[2] = {["id"] = 46363,},[3] = {["id"] = 46374,},[4] = {["id"] = 46385,},},
		[1] = {[1] = {["id"] = 40255,},[2] = {["id"] = 46396,},[3] = {["id"] = 46408,},[4] = {["id"] = 46420,},},
		[2] = {[1] = {["id"] = 40242,},[2] = {["id"] = 46440,},[3] = {["id"] = 46453,},[4] = {["id"] = 46466,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 61487,},[2] = {["id"] = 63278,},[3] = {["id"] = 63281,},[4] = {["id"] = 63284,},},
		[1] = {[1] = {["id"] = 61491,},[2] = {["id"] = 63287,},[3] = {["id"] = 63290,},[4] = {["id"] = 63293,},},
		[2] = {[1] = {["id"] = 61500,},[2] = {["id"] = 63296,},[3] = {["id"] = 63299,},[4] = {["id"] = 63302,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39248,},[2] = {["id"] = 45614,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39254,},[2] = {["id"] = 45621,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39252,},[2] = {["id"] = 45619,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	--[[ -- Ex emperor. Keep here for reference
	[2] = {
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 39630,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 39641,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 39625,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 39647,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	]]--
	[2] = { -- Support
		[1] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 38573,},[2] = {["id"] = 46607,},[3] = {["id"] = 46608,},[4] = {["id"] = 46609,},},
		[1] = {[1] = {["id"] = 40237,},[2] = {["id"] = 46610,},[3] = {["id"] = 46612,},[4] = {["id"] = 46614,},},
		[2] = {[1] = {["id"] = 40239,},[2] = {["id"] = 46616,},[3] = {["id"] = 46619,},[4] = {["id"] = 46622,},},
		},["at"] = ABILITY_TYPE_ULTIMATE,},
		[2] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 38570,},[2] = {["id"] = 46649,},[3] = {["id"] = 46651,},[4] = {["id"] = 46653,},},
		[1] = {[1] = {["id"] = 40229,},[2] = {["id"] = 46655,},[3] = {["id"] = 46658,},[4] = {["id"] = 46661,},},
		[2] = {[1] = {["id"] = 40226,},[2] = {["id"] = 46664,},[3] = {["id"] = 46667,},[4] = {["id"] = 46670,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[3] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 38571,},[2] = {["id"] = 46626,},[3] = {["id"] = 46628,},[4] = {["id"] = 46630,},},
		[1] = {[1] = {["id"] = 40232,},[2] = {["id"] = 46632,},[3] = {["id"] = 46634,},[4] = {["id"] = 46636,},},
		[2] = {[1] = {["id"] = 40234,},[2] = {["id"] = 46638,},[3] = {["id"] = 46641,},[4] = {["id"] = 46644,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[4] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 61511,},[2] = {["id"] = 63308,},[3] = {["id"] = 63313,},[4] = {["id"] = 63318,},},
		[1] = {[1] = {["id"] = 61536,},[2] = {["id"] = 63323,},[3] = {["id"] = 63329,},[4] = {["id"] = 63335,},},
		[2] = {[1] = {["id"] = 61529,},[2] = {["id"] = 63341,},[3] = {["id"] = 63346,},[4] = {["id"] = 63351,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[5] = {["skillPool"] = {
		[0] = {[1] = {["id"] = 61489,},[2] = {["id"] = 63356,},[3] = {["id"] = 63363,},[4] = {["id"] = 63370,},},
		[1] = {[1] = {["id"] = 61519,},[2] = {["id"] = 63377,},[3] = {["id"] = 63384,},[4] = {["id"] = 63391,},},
		[2] = {[1] = {["id"] = 61524,},[2] = {["id"] = 63399,},[3] = {["id"] = 63407,},[4] = {["id"] = 63415,},},
		},["at"] = ABILITY_TYPE_ACTIVE,},
		[6] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39255,},[2] = {["id"] = 45622,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39259,},[2] = {["id"] = 45624,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[8] = {["mx"] = 2,["skillPool"] = {[1] = {["id"] = 39261,},[2] = {["id"] = 45625,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_RACIAL] = {
	[1] = { -- Breton
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36247,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35995,},[2] = {["id"] = 45259,},[3] = {["id"] = 45260,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36266,},[2] = {["id"] = 45261,},[3] = {["id"] = 45262,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36303,},[2] = {["id"] = 45263,},[3] = {["id"] = 45264,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- Redguard
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36312,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36009,},[2] = {["id"] = 45277,},[3] = {["id"] = 45278,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36153,},[2] = {["id"] = 45279,},[3] = {["id"] = 45280,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36546,},[2] = {["id"] = 45313,},[3] = {["id"] = 45315,},},	["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Orc
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 33293,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 33301,},[2] = {["id"] = 45307,},[3] = {["id"] = 45309,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36064,},[2] = {["id"] = 45297,},[3] = {["id"] = 45298,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 33304,},[2] = {["id"] = 45311,},[3] = {["id"] = 45312,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[4] = { -- Dark-Elf
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36588,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36591,},[2] = {["id"] = 45265,},[3] = {["id"] = 45267,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36593,},[2] = {["id"] = 45269,},[3] = {["id"] = 45270,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36598,},[2] = {["id"] = 45271,},[3] = {["id"] = 45272,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[5] = { -- Nord
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36626,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36064,},[2] = {["id"] = 45297,},[3] = {["id"] = 45298,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36627,},[2] = {["id"] = 45303,},[3] = {["id"] = 45304,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36628,},[2] = {["id"] = 45305,},[3] = {["id"] = 45306,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[6] = { -- Argonian
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36582,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36568,},[2] = {["id"] = 45243,},[3] = {["id"] = 45247,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36583,},[2] = {["id"] = 45253,},[3] = {["id"] = 45255,},},	["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36585,},[2] = {["id"] = 45257,},[3] = {["id"] = 45258,},},	["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[7] = { -- Hight-Elf
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 35965,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35993,},[2] = {["id"] = 45273,},[3] = {["id"] = 45274,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35995,},[2] = {["id"] = 45259,},[3] = {["id"] = 45260,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 35998,},[2] = {["id"] = 45275,},[3] = {["id"] = 45276,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[8] = { -- Wood-Elf
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36008,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 64279,},[2] = {["id"] = 64280,},[3] = {["id"] = 64281,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36011,},[2] = {["id"] = 45317,},[3] = {["id"] = 45319,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36022,},[2] = {["id"] = 45295,},[3] = {["id"] = 45296,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[9] = { -- Khajit
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36063,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 70386,},[2] = {["id"] = 70388,},[3] = {["id"] = 70390,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36022,},[2] = {["id"] = 45295,},[3] = {["id"] = 45296,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36067,},[2] = {["id"] = 45299,},[3] = {["id"] = 45301,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[10] = { -- Imperial
		[1] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 36312,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 50903,},[2] = {["id"] = 50906,},[3] = {["id"] = 50907,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36153,},[2] = {["id"] = 45279,},[3] = {["id"] = 45280,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 36155,},[2] = {["id"] = 45291,},[3] = {["id"] = 45293,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
[SKILL_TYPE_TRADESKILL] = {
	[1] = { -- Alchemy
		[1] = {["mx"] = 8,["skillPool"] = {[1] = {["id"] = 45542,},[2] = {["id"] = 45547,},[3] = {["id"] = 45550,},[4] = {["id"] = 45551,},[5] = {["id"] = 45552,},[6] = {["id"] = 49163},[7] = {["id"] = 70042},[8] = {["id"] = 70043,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47840,},[2] = {["id"] = 47841,},[3] = {["id"] = 47842,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 45569,},[2] = {["id"] = 45571,},[3] = {["id"] = 45573,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 45577,},[2] = {["id"] = 45578,},[3] = {["id"] = 45579,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = nil,["skillPool"] = {[1] = {["id"] = 45555,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47831,},[2] = {["id"] = 47832,},[3] = {["id"] = 47834,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[2] = { -- Clothing
		[1] = {["mx"] = 10,["skillPool"] = {[1] = {["id"] = 47288,},[2] = {["id"] = 47289,},[3] = {["id"] = 47290,},[4] = {["id"] = 47291,},[5] = {["id"] = 47292,},[6] = {["id"] = 47293,},[7] = {["id"] = 48187,},[8] = {["id"] = 48188,},[9] = {["id"] = 48189,},[10] = {["id"] = 70044,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47860,},[2] = {["id"] = 47861,},[3] = {["id"] = 47862,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48199,},[2] = {["id"] = 48200,},[3] = {["id"] = 48201,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48193,},[2] = {["id"] = 48194,},[3] = {["id"] = 48195,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 48190,},[2] = {["id"] = 48191,},[3] = {["id"] = 48192,},[4] = {["id"] = 58782,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48196,},[2] = {["id"] = 48197,},[3] = {["id"] = 48198,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[3] = { -- Provisionning
		[1] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 44625,},[2] = {["id"] = 44630,},[3] = {["id"] = 44631,},[4] = {["id"] = 69953,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 6,["skillPool"] = {[1] = {["id"] = 44590,},[2] = {["id"] = 44595,},[3] = {["id"] = 44597,},[4] = {["id"] = 44598,},[5] = {["id"] = 44599,},[6] = {["id"] = 44650,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 44602,},[2] = {["id"] = 44609,},[3] = {["id"] = 44610,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 44612,},[2] = {["id"] = 44614,},[3] = {["id"] = 44615,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 44616,},[2] = {["id"] = 44617,},[3] = {["id"] = 44619,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 44620,},[2] = {["id"] = 44621,},[3] = {["id"] = 44624,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[7] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 44634,},[2] = {["id"] = 44640,},[3] = {["id"] = 44641,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[4] = { -- Enchanting
		[1] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 46758,},[2] = {["id"] = 46759,},[3] = {["id"] = 46760,},[4] = {["id"] = 46763,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 10,["skillPool"] = {[1] = {["id"] = 46727,},[2] = {["id"] = 46729,},[3] = {["id"] = 46731,},[4] = {["id"] = 46735,},[5] = {["id"] = 46736,},[6] = {["id"] = 46740,},[7] = {["id"] = 49112,},[8] = {["id"] = 49113,},[9] = {["id"] = 49114,},[10] = {["id"] = 70045,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47851,},[2] = {["id"] = 47852,},[3] = {["id"] = 47853,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 46770,},[2] = {["id"] = 46771,},[3] = {["id"] = 46772,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 46767,},[2] = {["id"] = 46768,},[3] = {["id"] = 46769,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[5] = { -- Blacksmithing
		[1] = {["mx"] = 10,["skillPool"] = {[1] = {["id"] = 47276,},[2] = {["id"] = 47277,},[3] = {["id"] = 47278,},[4] = {["id"] = 47279,},[5] = {["id"] = 47280,},[6] = {["id"] = 47281,},[7] = {["id"] = 48157,},[8] = {["id"] = 48158,},[9] = {["id"] = 48159,},[10] = {["id"] = 70041,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47854,},[2] = {["id"] = 47855,},[3] = {["id"] = 47856,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48169,},[2] = {["id"] = 48170,},[3] = {["id"] = 48171,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48163,},[2] = {["id"] = 48164,},[3] = {["id"] = 48165,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 48160,},[2] = {["id"] = 48161,},[3] = {["id"] = 48162,},[4] = {["id"] = 58784,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48166,},[2] = {["id"] = 48167,},[3] = {["id"] = 48168,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
	[6] = { -- Woodworking
		[1] = {["mx"] = 10,["skillPool"] = {[1] = {["id"] = 47282,},[2] = {["id"] = 47283,},[3] = {["id"] = 47284,},[4] = {["id"] = 47285,},[5] = {["id"] = 47286,},[6] = {["id"] = 47287,},[7] = {["id"] = 48172,},[8] = {["id"] = 48173,},[9] = {["id"] = 48174,},[10] = {["id"] = 70046,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[2] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 47857,},[2] = {["id"] = 47858,},[3] = {["id"] = 47859,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[3] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48184,},[2] = {["id"] = 48185,},[3] = {["id"] = 48186,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[4] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48178,},[2] = {["id"] = 48179,},[3] = {["id"] = 48180,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[5] = {["mx"] = 4,["skillPool"] = {[1] = {["id"] = 48181,},[2] = {["id"] = 48182,},[3] = {["id"] = 48183,},[4] = {["id"] = 58783,},},["at"] = ABILITY_TYPE_PASSIVE,},
		[6] = {["mx"] = 3,["skillPool"] = {[1] = {["id"] = 48175,},[2] = {["id"] = 48176,},[3] = {["id"] = 48177,},},["at"] = ABILITY_TYPE_PASSIVE,},
	},
},
}

-- Earning ranks, Active & Ultimate skills

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][6].er = 42

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][4].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][5].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][6].er = 42


LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][1].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][4].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][6].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][1].er = 22

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][2].er = 1

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][2].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][3].er = 3

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][4].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][5].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][6].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][4].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][5].er = 8

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][4].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][5].er = 8

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][3].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][4].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][5].er = 5

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][3].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][4].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][5].er = 7

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][2].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][3].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][4].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][5].er = 7

-- Earning Ranks passive skills

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Draconic"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Flame"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Earth"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dark"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Storm"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Daedric"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Assassination"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Siphon"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Shadow"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Spear"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Dawn"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Restoring"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Animal"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Green"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][7]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][8]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][9]["skillPool"][1].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][10]["skillPool"][1].er = 39

LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][7]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][8]["skillPool"][2].er = 27
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][9]["skillPool"][2].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_CLASS]["Winter"][10]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][1][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][3][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][2][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][4][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][5][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][8]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][9]["skillPool"][1].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][10]["skillPool"][1].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][11]["skillPool"][1].er = 41

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][7]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][8]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][9]["skillPool"][2].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][10]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WEAPON][6][11]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][3]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][4]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][5]["skillPool"][1].er = 38
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][6]["skillPool"][1].er = 42

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][2]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][3]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][4]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][5]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][6]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][1][2]["skillPool"][3].er = 30

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][3]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][4]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][5]["skillPool"][1].er = 38
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][6]["skillPool"][1].er = 42

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][2]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][3]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][4]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][5]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][6]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][2][2]["skillPool"][3].er = 30

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][3]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][4]["skillPool"][1].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][5]["skillPool"][1].er = 38
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][6]["skillPool"][1].er = 42

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][2]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][3]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][4]["skillPool"][2].er = 34
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][5]["skillPool"][2].er = 46
LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][6]["skillPool"][2].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_ARMOR][3][2]["skillPool"][3].er = 30

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][4]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][5]["skillPool"][1].er = 6

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][1]["skillPool"][2].er = 69
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][2]["skillPool"][2].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][3]["skillPool"][2].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][4]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][5]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][1]["skillPool"][3].er = 11
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][2]["skillPool"][3].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][3]["skillPool"][3].er = 13
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][4]["skillPool"][3].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][5]["skillPool"][3].er = 69

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][1]["skillPool"][4].er = 69
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][2]["skillPool"][4].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][3]["skillPool"][4].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][4]["skillPool"][4].er = 19
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][1][5]["skillPool"][4].er = 20

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][3]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][4]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][5]["skillPool"][1].er = 3

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][3]["skillPool"][2].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][4]["skillPool"][2].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][2][5]["skillPool"][2].er = 5

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][4]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][5]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][6]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][7]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][8]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][9]["skillPool"][1].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][4]["skillPool"][2].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][5]["skillPool"][2].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][3][7]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][7]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][8]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][9]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][10]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][11]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][12]["skillPool"][1].er = 7

LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][7]["skillPool"][2].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][9]["skillPool"][2].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][11]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_WORLD][4][12]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][4]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][5]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][6]["skillPool"][1].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][2]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][3]["skillPool"][2].er = 6

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][2]["skillPool"][3].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][3]["skillPool"][3].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][2]["skillPool"][4].er = 11
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][1][3]["skillPool"][4].er = 12

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][6]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][7]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][8]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][9]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][10]["skillPool"][1].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][7]["skillPool"][2].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][8]["skillPool"][2].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][7]["skillPool"][2].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][2][8]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][6]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][7]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][8]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][9]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][10]["skillPool"][1].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][7]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][8]["skillPool"][2].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][9]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][3][10]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][4]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][5]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][6]["skillPool"][1].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][2]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][3]["skillPool"][2].er = 6

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][2]["skillPool"][3].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][3]["skillPool"][3].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][2]["skillPool"][4].er = 11
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][4][3]["skillPool"][4].er = 12

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][6]["skillPool"][1].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][7]["skillPool"][1].er = 7

LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][6]["skillPool"][2].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_GUILD][5][7]["skillPool"][2].er = 9

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][6]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][8]["skillPool"][1].er = 8

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][6]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][7]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][1][8]["skillPool"][2].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][6]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][7]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][8]["skillPool"][1].er = 8

LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][6]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][7]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_AVA][2][8]["skillPool"][2].er = 10


LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][1][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][3][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][2][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][4][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][5][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][6][4]["skillPool"][3].er = 50


LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][7][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][8][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][9][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][2]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][3]["skillPool"][1].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][4]["skillPool"][1].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][2]["skillPool"][2].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][3]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][4]["skillPool"][2].er = 35

LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][3]["skillPool"][3].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_RACIAL][10][4]["skillPool"][3].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][3]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][4]["skillPool"][1].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][5]["skillPool"][1].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][6]["skillPool"][1].er = 23

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][2]["skillPool"][2].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][3]["skillPool"][2].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][4]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][6]["skillPool"][2].er = 33

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][3].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][2]["skillPool"][3].er = 17
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][3]["skillPool"][3].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][4]["skillPool"][3].er = 47
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][6]["skillPool"][3].er = 43

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][4].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][5].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][1][1]["skillPool"][6].er = 48

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][4]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][5]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][6]["skillPool"][1].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][2]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][3]["skillPool"][2].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][4]["skillPool"][2].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][5]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][6]["skillPool"][2].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][3].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][3]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][4]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][5]["skillPool"][3].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][6]["skillPool"][3].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][4].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][5]["skillPool"][4].er = 45

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][4].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][4].er = 15

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][6].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][7].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][8].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][2][1]["skillPool"][9].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][4]["skillPool"][1].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][5]["skillPool"][1].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][6]["skillPool"][1].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][7]["skillPool"][1].er = 28

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][1]["skillPool"][2].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][2].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][3]["skillPool"][2].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][4]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][5]["skillPool"][2].er = 23
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][6]["skillPool"][2].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][7]["skillPool"][2].er = 38

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][1]["skillPool"][3].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][3]["skillPool"][3].er = 43
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][4]["skillPool"][3].er = 47
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][5]["skillPool"][3].er = 33
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][6]["skillPool"][3].er = 36
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][7]["skillPool"][3].er = 48

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][4].er = 40
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][5].er = 50
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][3][2]["skillPool"][6].er = 50

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][3]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][4]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][5]["skillPool"][1].er = 4

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][1]["skillPool"][2].er = 6
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][3]["skillPool"][2].er = 7
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][4]["skillPool"][2].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][5]["skillPool"][2].er = 19

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][1]["skillPool"][3].er = 16
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][3].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][3]["skillPool"][3].er = 14
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][4]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][5]["skillPool"][3].er = 29

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][1]["skillPool"][4].er = 31
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][4].er = 15

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][6].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][7].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][8].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][4][2]["skillPool"][9].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][4]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][5]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][6]["skillPool"][1].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][2]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][3]["skillPool"][2].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][4]["skillPool"][2].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][5]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][6]["skillPool"][2].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][3].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][3]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][4]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][5]["skillPool"][3].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][6]["skillPool"][3].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][4].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][4].er = 15

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][6].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][7].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][8].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][5][1]["skillPool"][9].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][1].er = 1
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][2]["skillPool"][1].er = 2
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][3]["skillPool"][1].er = 3
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][4]["skillPool"][1].er = 4
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][5]["skillPool"][1].er = 8
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][6]["skillPool"][1].er = 10

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][2].er = 5
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][2]["skillPool"][2].er = 9
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][3]["skillPool"][2].er = 12
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][4]["skillPool"][2].er = 22
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][5]["skillPool"][2].er = 18
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][6]["skillPool"][2].er = 25

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][3].er = 10
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][2]["skillPool"][3].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][3]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][4]["skillPool"][3].er = 32
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][5]["skillPool"][3].er = 28
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][6]["skillPool"][3].er = 40

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][4].er = 15
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][4].er = 15

LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][5].er = 20
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][6].er = 25
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][7].er = 30
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][8].er = 35
LibSkillsFactory.skillSubFactory[SKILL_TYPE_TRADESKILL][6][1]["skillPool"][9].er = 40