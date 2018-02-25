ModifierOptionsMenuEntry = {}
ModifierOptionsMenuEntry_mt = { __index = ModifierOptionsMenuEntry }

local WIDTH = 480
local HEIGHT = 48

function ModifierOptionsMenuEntry.create()
  local self = {}
  setmetatable( self, ModifierOptionsMenuEntry_mt )

  return self
end

function ModifierOptionsMenuEntry:create_actors(params)
  self.params = params

  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself
    end
  }

  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      subself:zoomto(WIDTH, HEIGHT)
             :diffuse(ThemeColor.Black)
    end
  }

  -- Background focus background
  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      if params.player_number == "PlayerNumber_P1" then
        subself:halign(0)
               :x(-WIDTH/2)
      else
        subself:halign(1)
               :x(WIDTH/2)
      end

      subself:zoomto(0, HEIGHT)
             :diffuse(PlayerColors[params.player_number])
    end,

    UpdateCommand = function(subself)
      if (self.is_focused) then
        subself:stoptweening()
               :linear(0.15)
               :zoomtowidth(WIDTH)
      else
        subself:stoptweening()
               :linear(0.1)
               :zoomtowidth(0)
      end
    end,
  }

  t[#t+1] = Def.BitmapText {
    Font = "Common Normal",
    InitCommand = function(subself)
      subself:diffuse(ThemeColor.White)

      if params.player_number == "PlayerNumber_P1" then
        subself:halign(0)
               :x(-WIDTH/2 + 16)
      else
        subself:halign(1)
               :x(WIDTH/2 - 16)
      end
    end,

    UpdateCommand = function(subself)
      if self.data == nil then return end
      subself:settext(self.data.label)
    end
  }

  t[#t+1] = Def.BitmapText {
    Font = "Common Normal",
    InitCommand = function(subself)
      subself:diffuse(ThemeColor.White)

      if params.player_number == "PlayerNumber_P1" then
        subself:halign(1)
               :x(WIDTH/2 - 16)
      else
        subself:halign(0)
               :x(-WIDTH/2 + 16)
      end
    end,

    UpdateCommand = function(subself)
      subself:settext(self.data:current_value(params.player_number))
    end
  }

  return t
end

function ModifierOptionsMenuEntry:scroll(amount)
  self.data:scroll(self.params.player_number, amount)
  self.container:queuecommand("Update")
end

function ModifierOptionsMenuEntry:transform(item_index, num_items, is_focus)
  if self.original_index == nil then
    self.original_index = item_index
  end

  self.container:stoptweening()
                :linear(0.1)
                :y(self.original_index * 64)
  self.is_focused = item_index == 1

  self.container:queuecommand("Update")
end

function ModifierOptionsMenuEntry:set(data)
  if (data == nil) then return end
  self.data = data
end
