-- module metadata
ErgarothsUITools = {}
ErgarothsUITools.name = "ErgarothsUITools"

-- global variables

local accountSavedVars

-- helper functions

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
    accountSavedVars[achievementId] = name
end

local function syncAchievments()
    forEachAchievement(syncAchievmentProgress)
end

local function printInfo()
    d("ErgarothsUITools is ON")
end

-- initialization
 
function ErgarothsUITools:Initialize()
    accountSavedVars = ZO_SavedVars:NewAccountWide("ErgarothsUITools_SavedVariables", 1, "defaultNamespace", {}, "defaultProfile")
    syncAchievments()
end
 
function ErgarothsUITools.OnAddOnLoaded(event, addonName)
  if addonName == ErgarothsUITools.name then
    EVENT_MANAGER:UnregisterForEvent(ErgarothsUITools.name, EVENT_ADD_ON_LOADED)
    ErgarothsUITools:Initialize()
  end
end

-- global event registration
 
EVENT_MANAGER:RegisterForEvent(ErgarothsUITools.name, EVENT_ADD_ON_LOADED, ErgarothsUITools.OnAddOnLoaded)

-- slash commands

SLASH_COMMANDS["/euit_info"] = printInfo