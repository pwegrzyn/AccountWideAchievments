-- module metadata
ErgarothsUITools = ErgarothsUITools or {}
ErgarothsUITools.Name = "ErgarothsUITools"
ErgarothsUITools.DisplayName = "|cFF5FF5Ergaroth's|r UI Tools"
ErgarothsUITools.Author = "|cFF5FF5Ergaroth|r"
ErgarothsUITools.Version = "0.0.1"

-- global variables

local BLUE, RED, WHITE, GREEN = 1,2,3,4
local VARIABLES_VERSION = 1
local Defaults = 
{
   achievmentsData = {},
   notesData = {},
}

-- helper functions

local function printMsg(stringToDisplay)
	d(stringToDisplay)
end

local function colorizeStr(stringToColorize, color)
	if ( color ~= nil and color ~="" ) then 
		if color == BLUE then
			return "|c2020F0"..stringToColorize.."|r"
		elseif color == WHITE then
			return "|cF0F0F0"..stringToColorize.."|r"
		elseif color == RED then
			return "|cF02020"..stringToColorize.."|r"
		elseif color == GREEN then
			return "|c1FFF29"..stringToColorize.."|r"
		end		
   else
      d("Something went wrong in colorizeString!")
      return ""
   end
end

local function forEachAchievement(functor)
    local function _perAchievement(achievementID)
       --
       -- Handle achievement lines. Only the first achievement in a line 
       -- exists in the category/subcategory tree.
       --
       if functor(achievementID) then
          return true
       end
       local id = GetNextAchievementInLine(achievementID)
       while (id ~= 0) do
          if functor(id) then
             return true
          end
          id = GetNextAchievementInLine(id)
       end
    end
    --
    -- Iterate over the achievement category tree:
    --
    for ci = 1, GetNumAchievementCategories() do
       local name, subcategoryCount, achievementCount, _, _, _ = GetAchievementCategoryInfo(ci)
       for ai = 1, achievementCount do
          --
          -- Handle achievements nested directly under a category.
          --
          local id = GetAchievementId(ci, nil, ai)
          if _perAchievement(id) then
             return
          end
       end
       for si = 1, subcategoryCount do
          local name, achievementCount, _, _, _ = GetAchievementSubCategoryInfo(ci, si)
          for ai = 1, achievementCount do
             --
             -- Handle achievements nested under a subcategory.
             --
             local id = GetAchievementId(ci, si, ai)
             if _perAchievement(id) then
                return
             end
          end
       end
    end
end

local function syncAchievmentProgress(achievementId)
   local name = GetAchievementInfo(achievementId)
   ErgarothsUITools.accVars.achievmentsData[achievementId] = name
end

local function syncAchievments()
    forEachAchievement(syncAchievmentProgress)
end

local function printHelp()
   printMsg(colorizeStr("Ergaroth's UI Tools v" .. ErgarothsUITools.Version, WHITE))
end

local function executeNotesDelete(options)
   if (#options == 1 or options[2] == "") then
      ErgarothsUITools.accVars.notesData = {}
      printMsg(colorizeStr("Deleted all notes.", WHITE))
  else
      ErgarothsUITools.accVars.notesData[options[2]] = nil
      printMsg(colorizeStr("Deleted the note " .. options[2] .. ".", WHITE))
  end
end

local function executeNotesSave(options)
   -- pop subcommand name
   table.remove(options, 1)
   if (#options == 0) then
      printMsg(colorizeStr("Must specify keyword to save the note!", RED))
      return
   end
   keyword = options[1]
   table.remove(options, 1)
   if (#options == 0) then
      printMsg(colorizeStr("Must specify body to save the note!", RED))
      return
   end
   fullString = table.concat(options, " ")
   ErgarothsUITools.accVars.notesData[keyword] = fullString
   printMsg(colorizeStr("Saved note as " .. keyword .. ".", WHITE))
end

local function GetKeys(someTable)
   local keys = {}
   for key in pairs(someTable) do
       keys[#keys + 1] = key
   end
   table.sort(keys)
   return keys
end

local function executeNotesShow(options)
   if (#options == 1 or options[2] == "") then
      printMsg(colorizeStr("Existing notes: " .. table.concat(GetKeys(ErgarothsUITools.accVars.notesData), ", "), WHITE))
  else
      printMsg(colorizeStr(ErgarothsUITools.accVars.notesData[options[2]], WHITE))
  end
end

local function executeSlashCommand(option)
   local options = {}
   local searchResult = {}
   for substring in option:gmatch("%S+") do
      table.insert(searchResult, substring)
   end
   for i,v in pairs(searchResult) do
       if (v ~= nil and v ~= "") then
           options[i] = string.lower(v)
       end
   end
   if #options == 0 or options[1] == "help" then
      printHelp()
   elseif options[1] == "notes" then
      table.remove(options, 1)
      if (#options == 0) then
         printMsg(colorizeStr("Must specify a subcommand!", RED))
      elseif options[1] == "show" then
         executeNotesShow(options)
      elseif options[1] == "save" then
         executeNotesSave(options)
      elseif options[1] == "delete" then
         executeNotesDelete(options)
      else
         printMsg(colorizeStr("Unknown subcommand! Avaiable: show, save, delete", RED))
      end
   else
      printMsg(colorizeStr("Unknown command! Avaiable: help, notes.", RED))
   end
end

-- initialization
 
function ErgarothsUITools:Initialize()
   ErgarothsUITools.accVars = ZO_SavedVars:NewAccountWide("ErgarothsUITools_SavedVariables", VARIABLES_VERSION, GetWorldName(), Defaults)
   --syncAchievments()
end
 
function ErgarothsUITools.OnAddOnLoaded(event, addonName)
  if addonName == ErgarothsUITools.Name then
    EVENT_MANAGER:UnregisterForEvent(ErgarothsUITools.Name, EVENT_ADD_ON_LOADED)
    ErgarothsUITools:Initialize()
  end
end

-- global event registration
 
EVENT_MANAGER:RegisterForEvent(ErgarothsUITools.Name, EVENT_ADD_ON_LOADED, ErgarothsUITools.OnAddOnLoaded)

-- slash commands

SLASH_COMMANDS["/euit"] = executeSlashCommand