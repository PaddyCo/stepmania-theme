dofile(THEME:GetPathO("", "modifier_options_menu_entry.lua"))
dofile(THEME:GetPathO("", "modifier_options_menu_data.lua"))

ModifierOptionsMenu = {}
ModifierOptionsMenu_mt = { __index = ModifierOptionsMenu }

local MENU_ENTRIES = {
  ModifierOptionsMenuData.create({
    label = "Speed Modifier Type",
    scroll = function(self, player_number, amount)
      local options = GAMESTATE:GetPlayerState(player_number):GetPlayerOptions("ModsLevel_Preferred")
      if options:MMod() == nil then
        options:MMod(100)
      else
        options:XMod(1)
      end
    end,
    current_value = function(self, player_number)
      local options = GAMESTATE:GetPlayerState(player_number):GetPlayerOptions("ModsLevel_Preferred")

      if options:MMod() ~= nil then return "Lowest BPM"
      else return "X" end

    end,
  }),
  ModifierOptionsMenuData.create({
    label = "Speed Modifier",
    scroll = function(self, player_number, amount)
      local options = GAMESTATE:GetPlayerState(player_number):GetPlayerOptions("ModsLevel_Preferred")
      if options:MMod() ~= nil then
        local old_mod = options:MMod() or 200
        local new_mod = math.min(math.max(old_mod + (amount * 25), 25), 1000)
        options:MMod(new_mod)
      else
        local options = GAMESTATE:GetPlayerState(player_number):GetPlayerOptions("ModsLevel_Preferred")
        local new_mod = math.min(math.max(options:XMod() + (0.25 * amount), 0.25), 8)
        options:XMod(new_mod)
      end
    end,
    current_value = function(self, player_number)
      local options = GAMESTATE:GetPlayerState(player_number):GetPlayerOptions("ModsLevel_Preferred")

      if options:MMod() ~= nil then
        return options:MMod()
      else
        return tostring(options:XMod()) .. "x"
      end
    end,
  }),
}


function ModifierOptionsMenu.create()
  local self = {}
  setmetatable( self, ModifierOptionsMenu_mt )

  self.scrollers = {
    PlayerNumber_P1 = setmetatable({ disable_wrapping = true }, item_scroller_mt),
    PlayerNumber_P2 = setmetatable({ disable_wrapping = true }, item_scroller_mt)
  }

  return self
end

function ModifierOptionsMenu:set_data()
  for player_index, player_number in ipairs(GAMESTATE:GetEnabledPlayers()) do
    self.scrollers[player_number]:set_info_set(MENU_ENTRIES, 1)
  end
end

function ModifierOptionsMenu:create_actors()
  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself

      subself:visible(false)
    end,

    ShowCommand = function(subself)
      subself:visible(true)
    end,
  }

  -- Background
  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      subself:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
             :xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
             :diffuse(Color.Black)
             :queuecommand("Hide")
    end,

    HideCommand = function(subself)
      subself:stoptweening()
             :linear(0.2)
             :diffusealpha(0)
    end,

    ShowCommand = function(subself)
      subself:stoptweening()
             :linear(0.2)
             :diffusealpha(0.8)
    end,
  }

  -- Menus
  for player_index, player_number in ipairs(GAMESTATE:GetEnabledPlayers()) do
    local menu_frame = Def.ActorFrame {
      InitCommand = function(subself)
        subself:x(player_number == "PlayerNumber_P1" and -640 or SCREEN_WIDTH+640)
               :y(SCREEN_CENTER_Y - (#MENU_ENTRIES/2 * 64))
               :queuecommand("Hide")
      end,

      ShowCommand = function(subself)
        subself:linear(0.2)
               :x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
      end,

      HideCommand = function(subself)
        subself:linear(0.2)
               :x(player_number == "PlayerNumber_P1" and -640 or SCREEN_WIDTH+640)
      end
    }

    menu_frame[#menu_frame+1] = self.scrollers[player_number]:create_actors("Entry", #MENU_ENTRIES, ModifierOptionsMenuEntry_mt, 0, 0, { player_number = player_number })

    t[#t+1] = menu_frame
  end

  return t
end

function ModifierOptionsMenu:set_visible(visible)
  if visible then
    self.container:queuecommand("Show")
  else
    self.container:queuecommand("Hide")
  end
end

function ModifierOptionsMenu:handle_input(event)
  -- Ignore release event
  if event.type == "InputEventType_Release" then return end

  if event.GameButton == "MenuDown" then
    self.scrollers[event.PlayerNumber]:scroll_by_amount(1)
  elseif event.GameButton == "MenuUp" then
    self.scrollers[event.PlayerNumber]:scroll_by_amount(-1)
  elseif event.GameButton == "MenuRight" then
    self.scrollers[event.PlayerNumber]:get_actor_item_at_focus_pos():scroll(1)
    self.container:queuecommand("Update")
  elseif event.GameButton == "MenuLeft" then
    self.scrollers[event.PlayerNumber]:get_actor_item_at_focus_pos():scroll(-1)
    self.container:queuecommand("Update")
  elseif event.GameButton == "Back" and event.type == "InputEventType_FirstPress" then
    GLOBAL.DropCurrentInputFocus()
  end
end
