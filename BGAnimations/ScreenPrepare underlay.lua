top_background_color = Color.Black
bottom_background_color = ThemeColor.White
particle_color = ThemeColor.White

local t = Def.ActorFrame {}

t[#t+1] = LoadActor(THEME:GetPathB("", "_Background"), {})

t[#t+1] = Def.Sprite {
  InitCommand = function(self)
    self:LoadFromCurrentSongBackground()
  end,

  OnCommand = function(self)
    local brightness = PREFSMAN:GetPreference("BGBrightness")
    self:CropTo(SCREEN_WIDTH, SCREEN_HEIGHT)
        :x(SCREEN_CENTER_X)
        :y(SCREEN_CENTER_Y)
        :diffusealpha(0.2)
        :sleep(1.5)
        :linear(1)
        :diffuse(Brightness(Color.Black, brightness))
        :diffusealpha(1)
  end

}

return t
