AccountWideAchievments = {}
AccountWideAchievments.name = "AccountWideAchievments"
local accountSavedVars
 
function AccountWideAchievments:Initialize()
    accountSavedVars = ZO_SavedVars:NewAccountWide("AccountWideAchievments_SavedVariables", 1, "defaultNamespace", {}, "defaultProfile")
end
 
function AccountWideAchievments.OnAddOnLoaded(event, addonName)
  if addonName == AccountWideAchievments.name then
    AccountWideAchievments:Initialize()
  end
end
 
EVENT_MANAGER:RegisterForEvent(AccountWideAchievments.name, EVENT_ADD_ON_LOADED, AccountWideAchievments.OnAddOnLoaded)