if not WeakAuras.IsLibsOK() then return end
---@type string
local AddonName = ...
---@class OptionsPrivate
local OptionsPrivate = select(2, ...)

-- Magic constant
local deleteCondition = {}

local function AdjustConditions(data, replacements)
  if (data.conditions) then
    for conditionIndex, condition in ipairs(data.conditions) do
      for changeIndex, change in ipairs(condition.changes) do
        if change.property then
          local sub, rest = string.match(change.property, "^(sub.%d+%.)(.+)$")
          if sub and replacements[sub] then
            if replacements[sub] == deleteCondition then
              change.property = nil
            else
              change.property = replacements[sub] .. rest
            end
          end
        end
      end
    end
  end
end

local function ReplacePrefix(hay, replacements)
  for old, new in pairs(replacements) do
    if hay:sub(1, #old) == old then
      return new .. hay:sub(#old + 1)
    end
  end
end

local function AdjustAnchors(data, replacements)
  if not data.subRegions then
    return
  end

  for _, subRegionData in ipairs(data.subRegions) do
    local anchor_area = subRegionData.anchor_area
    if anchor_area then
      local replaced = ReplacePrefix(anchor_area, replacements)
      if replaced then
        subRegionData.anchor_area = replaced
      end
    end
    local anchor_point = subRegionData.anchor_point
    if anchor_point then
      local replaced = ReplacePrefix(anchor_point, replacements)
      if replaced then
        subRegionData.anchor_point = replaced
      end
    end
  end
end

function OptionsPrivate.DeleteSubRegion(data, index, regionType)
  if not data.subRegions then
    return
  end
  if data.subRegions[index] and data.subRegions[index].type == regionType then
    tremove(data.subRegions, index)

    local replacements = {
      ["sub." .. index .. "."] = deleteCondition
    }

    for i = index + 1, #data.subRegions + 1 do
      replacements["sub." .. i .. "."] = "sub." .. (i - 1) .. "."
    end

    AdjustConditions(data, replacements);
    AdjustAnchors(data, replacements)

    WeakAuras.Add(data)
    OptionsPrivate.ClearOptions(data.id)
  end
end

function OptionsPrivate.MoveSubRegionUp(data, index, regionType)
  if not data.subRegions or index <= 1 then
    return
  end
  if data.subRegions[index] and data.subRegions[index].type == regionType then
    data.subRegions[index - 1], data.subRegions[index] = data.subRegions[index], data.subRegions[index - 1]

    local replacements = {
      ["sub." .. (index -1) .. "."] = "sub." .. index .. ".",
      ["sub." .. index .. "."] = "sub." .. (index - 1) .. ".",
    }

    AdjustConditions(data, replacements);
    AdjustAnchors(data, replacements)

    WeakAuras.Add(data)
    OptionsPrivate.ClearOptions(data.id)
  end
end

function OptionsPrivate.MoveSubRegionDown(data, index, regionType)
  if not data.subRegions then
    return
  end
  if data.subRegions[index] and data.subRegions[index].type == regionType and data.subRegions[index + 1] then
    data.subRegions[index], data.subRegions[index + 1] = data.subRegions[index + 1], data.subRegions[index]

    local replacements = {
      ["sub." .. index .. "."] = "sub." .. (index + 1) .. ".",
      ["sub." .. (index + 1) .. "."] = "sub." .. index .. ".",
    }

    AdjustConditions(data, replacements);
    AdjustAnchors(data, replacements)

    WeakAuras.Add(data)
    OptionsPrivate.ClearOptions(data.id)
  end
end

function OptionsPrivate.DuplicateSubRegion(data, index, regionType)
  if not data.subRegions then
    return
  end
  if data.subRegions[index] and data.subRegions[index].type == regionType then
    tinsert(data.subRegions, index, CopyTable(data.subRegions[index]))


    local replacements = {}
    for i = index + 1, #data.subRegions do
      replacements["sub." .. i .. "."] = "sub." .. (i + 1) .. "."
    end
    AdjustConditions(data, replacements)
    AdjustAnchors(data, replacements)

    WeakAuras.Add(data)
    OptionsPrivate.ClearOptions(data.id)
  end
end

function OptionsPrivate.AddUpDownDeleteDuplicate(options, parentData, index, subRegionType)
  options.__up = function()
    for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
      OptionsPrivate.MoveSubRegionUp(child, index, subRegionType)
    end
    WeakAuras.ClearAndUpdateOptions(parentData.id)
  end
  options.__down = function()
    for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
      OptionsPrivate.MoveSubRegionDown(child, index, subRegionType)
    end
    WeakAuras.ClearAndUpdateOptions(parentData.id)
  end
  options.__duplicate = function()
    for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
      OptionsPrivate.DuplicateSubRegion(child, index, subRegionType)
    end
    WeakAuras.ClearAndUpdateOptions(parentData.id)
  end
  options.__delete = function()
    for child in OptionsPrivate.Private.TraverseLeafsOrAura(parentData) do
      OptionsPrivate.DeleteSubRegion(child, index, subRegionType)
    end
    WeakAuras.ClearAndUpdateOptions(parentData.id)
  end
end
