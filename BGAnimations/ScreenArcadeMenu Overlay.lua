dofile(THEME:GetPathO("", "music_wheel.lua"))
dofile(THEME:GetPathO("", "entry_data.lua"))

GAMESTATE:LoadProfiles()

local music_wheel = MusicWheel.create(MusicWheelSort.by_difficulty)
local modifier_options_menu = ModifierOptionsMenu:create()

GLOBAL.PushInputFocus("MusicWheel")

local handle_input = function(event)
  local current_input_focus = GLOBAL.GetCurrentInputFocus()
  if current_input_focus == "MusicWheel" then
    music_wheel:handle_input(event)
  elseif current_input_focus == "ModifierOptions" then
    modifier_options_menu:handle_input(event)
  end

  if current_input_focus ~= GLOBAL.GetCurrentInputFocus() then
    modifier_options_menu:set_visible(GLOBAL.GetCurrentInputFocus() == "ModifierOptions")
  end
end

-- Create actors
local t = Def.ActorFrame {}

t[#t+1] = music_wheel:create_actors()

t[#t+1] = modifier_options_menu:create_actors()

t[#t+1] = Def.Actor {
  OnCommand = function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)
    modifier_options_menu:set_data()
  end
}

return t
