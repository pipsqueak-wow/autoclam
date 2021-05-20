local AutoClam = LibStub("AceAddon-3.0"):NewAddon("AutoClam", "AceEvent-3.0")
local clamIDs = {
  [5523] = true,  -- Small Barnacled Clam
  [5524] = true,  -- Thick-shelled Clam
  [7973] = true,  -- Big-mouth Clam
  [15874] = true, -- Soft-shelled Clam
  [24476] = true  -- Jaggal Clam
}

function AutoClam:OnInitialize()
  self:RegisterEvent("BAG_UPDATE","BagUpdate")
end

function AutoClam:BagUpdate()
  for bag = 4,0,-1 do
    for slot = GetContainerNumSlots(bag),1,-1 do
      local itemId = GetContainerItemID(bag, slot)
      if clamIDs[itemId] then
        UseContainerItem(bag, slot)
      end
    end
  end
end
