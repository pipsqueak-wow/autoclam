local AutoClam = LibStub("AceAddon-3.0"):NewAddon("AutoClam", "AceEvent-3.0")
local clamIDs = {
  [5523] = true,  -- Small Barnacled Clam
  [5524] = true,  -- Thick-shelled Clam
  [7973] = true,  -- Big-mouth Clam
  [15874] = true, -- Soft-shelled Clam
  [24476] = true  -- Jaggal Clam
}
local clamScanQueued = false

function AutoClam:OnInitialize()
  self:RegisterEvent("BAG_UPDATE_DELAYED","BagUpdateDelayed")
  self:RegisterEvent("PLAYER_REGEN_ENABLED","PlayerRegenEnabled")
end

function AutoClam:BagUpdateDelayed()
  if not InCombatLockdown() then
    self:ClamScan()
  else
    clamScanQueued = true
  end
end

function AutoClam:PlayerRegenEnabled()
  if clamScanQueued then
    clamScanQueued = false
    self:ClamScan()
  end
end

function AutoClam:ClamScan()
  for bag = 4,0,-1 do
    for slot = GetContainerNumSlots(bag),1,-1 do
      local _, _, locked, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag, slot)
      -- Check for clams being locked to avoid a potential error but that happening seems like such
      -- an edge case that we can't be bothered to queue an extra check for when it's unlocked.
      -- It will be opened the next time something happens in the bag anyway.
      if clamIDs[itemId] and not InCombatLockdown() and not locked then
        UseContainerItem(bag, slot)
      end
    end
  end
end
