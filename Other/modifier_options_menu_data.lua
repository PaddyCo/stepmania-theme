ModifierOptionsMenuData = {}
ModifierOptionsMenuData_mt = { __index = ModifierOptionsMenuData }

function ModifierOptionsMenuData.create(params)
  local self = params
  setmetatable(self, ModifierOptionsMenuData_mt)

  return self
end

function ModifierOptionsMenuData:current_value(player_number)
  self.current_value_func(self, player_number)
end

function ModifierOptionsMenuData:scroll(player_number, amount)
  self.scroll_func(self, player_number, amount)
end
