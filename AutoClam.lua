local AutoClam = LibStub("AceAddon-3.0"):NewAddon("AutoClam", "AceEvent-3.0")
local clamIDs = {
  [5523] = true,  -- Small Barnacled Clam
  [5524] = true,  -- Thick-shelled Clam
  [7973] = true,  -- Big-mouth Clam
  [15874] = true, -- Soft-shelled Clam
  --[24476] = true  -- Jaggal Clam -- TBC
}
local clamScanQueued = false

function AutoClam:OnInitialize()
  self:RegisterEvent("BAG_UPDATE_DELAYED","BagUpdateDelayed")
  self:RegisterEvent("PLAYER_REGEN_ENABLED","PlayerRegenEnabled")
end

function AutoClam:SlotsFree()
  local totalFree, freeSlots, bagFamily = 0
  for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
    freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(bag)
    if ( bagFamily == 0 ) then -- not a specialty bag
      totalFree = totalFree + freeSlots
    end
  end
  return totalFree
end

function AutoClam:BagUpdateDelayed()
  if self:SlotsFree() == 0 then return end
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

function AutoClam:LOOT_READY(autoLoot)
  self:UnregisterEvent("LOOT_READY")
  if autoLoot ~= GetModifiedClick("AUTOLOOTTOGGLE") then
    for i=GetNumLootItems(),1,-1 do
      LootSlot(i)
      ConfirmLootSlot(i)
    end
  end
end

function AutoClam:ClamScan()
  for bag = NUM_BAG_SLOTS,BACKPACK_CONTAINER,-1 do
    for slot = C_Container.GetContainerNumSlots(bag),1,-1 do
      local slotInfo = C_Container.GetContainerItemInfo(bag, slot)
      if slotInfo and slotInfo.hasLoot then
        local itemID, isLocked = slotInfo.itemID, slotInfo.isLocked
        -- Check for clams being locked to avoid a potential error but that happening seems like such
        -- an edge case that we can't be bothered to queue an extra check for when it's unlocked.
        -- It will be opened the next time something happens in the bag anyway.
        if clamIDs[itemID] and not (InCombatLockdown() or isLocked) then
          self:RegisterEvent("LOOT_READY")
          C_Container.UseContainerItem(bag, slot)
        end
      end
    end
  end
end
