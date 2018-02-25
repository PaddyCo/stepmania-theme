local t = Def.ActorFrame {
  InitCommand = function(self)
    self:diffusealpha(0)
        :linear(1)
        :diffusealpha(1)
  end
}

local calculate_zoom_from_combo = function(combo)
  return combo < 100 and (combo/100) + 0.5 or 2
end

local calculate_color = function(player)
  local stage_stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)

  local tap_judgments = {
    { type = "Miss", color = ThemeColor.White },
    { type = "W4", color = ThemeColor.Blue },
    { type = "W3", color = ThemeColor.Green },
    { type = "W2", color = ThemeColor.Yellow },
    { type = "W1", color = ThemeColor.Purple }
  }

  for i, v in ipairs(tap_judgments) do
    local t = "TapNoteScore_" .. v.type

    -- Differentiate between HighScore and PlayerStageStats (the first one has GetTapNoteScore while the other one has GetTapNoteScores)
    local color = stage_stats:GetTapNoteScores(t) > 0 and v.color or nil

    if color ~= nil then return color end
  end
end

for player_index=1, #GAMESTATE:GetEnabledPlayers() do
  -- Combo Counter
  ---- Frame
  local combo_frame = Def.ActorFrame {
    InitCommand = function(self)
      self:x(player_index == 1 and PlayerP1X() or PlayerP2X())
          :y(SCREEN_CENTER_Y)
          :visible(false)
    end,

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= "PlayerNumber_P" .. player_index then return end


      local combo = data.PlayerStageStats:GetCurrentCombo()

      self:stoptweening()

      if combo == data.OldCombo then return end

      if combo <= 1 then
        self:visible(false)
        return
      end

      self:visible(true)
          :linear(0.05)
          :zoom(1.5)
          :linear(0.1)
          :zoom(1)

    end,
  }

  combo_frame[#combo_frame+1] = Def.BitmapText {
    Font = "Gameplay Combo",

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= "PlayerNumber_P" .. player_index then return end

      local combo = data.PlayerStageStats:GetCurrentCombo()

      if combo == data.OldCombo then return end

      local zoom = calculate_zoom_from_combo(combo)
      local color = calculate_color("PlayerNumber_P" .. player_index)

      self:stoptweening()
          :settext(combo)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)
          :linear(0.1)
          :diffusealpha(1)
          :zoom(zoom)
          :x((-(zoom * 48))-24)
          :y(-(zoom * 18))

    end,
  }

  combo_frame[#combo_frame+1] = Def.BitmapText {
    Font = "Common Body",

    InitCommand = function(self)
      self:y(-(self:GetHeight()/2))
          :x(32)
          :zoom(0.85)
          :settext("Combo")
    end,

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= "PlayerNumber_P" .. player_index then return end

      local combo = data.PlayerStageStats:GetCurrentCombo()

      if combo == data.OldCombo then return end

      local zoom = calculate_zoom_from_combo(combo)
      local color = calculate_color("PlayerNumber_P" .. player_index)

      self:stoptweening()
          :Stroke(ThemeColor.White)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)
          :linear(0.1)
          :x((zoom * 48)+24)

    end,
  }

  t[#t+1] = combo_frame
end


return t
