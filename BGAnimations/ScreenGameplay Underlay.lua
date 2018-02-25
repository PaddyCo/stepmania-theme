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

  -- If broken combo by letting go of hold note, color white
  if stage_stats:GetHoldNoteScores("HoldNoteScore_LetGo") > 0 then return ThemeColor.White end

  local tap_judgments = { "Miss", "W4", "W3", "W2", "W1" }

  for i, v in ipairs(tap_judgments) do
    local t = "TapNoteScore_" .. v

    local color

    color = stage_stats:GetTapNoteScores(t) > 0 and JudgmentColors[t] or nil

    if color ~= nil then
      -- If Miss, color it white instead of it's intended color
      return v == "Miss" and ThemeColor.White or color
    end
  end
end

for player_index, player_number in ipairs(GAMESTATE:GetEnabledPlayers()) do
  -- Notefield Background
  t[#t+1] = Def.Quad {
    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(SCREEN_CENTER_Y)
          :zoomto(600, SCREEN_HEIGHT)
          :diffuse(Color.Black)
          :diffusealpha(0.7)

    end
  }

  -- Combo Counter
  ---- Frame
  local combo_frame = Def.ActorFrame {
    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(SCREEN_CENTER_Y + 32)
          :visible(false)
    end,

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= player_number then return end


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

  ---- Combo Number
  combo_frame[#combo_frame+1] = Def.BitmapText {
    Font = "Gameplay Combo",

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= player_number then return end

      local combo = data.PlayerStageStats:GetCurrentCombo()

      if combo == data.OldCombo then return end

      local zoom = calculate_zoom_from_combo(combo)
      local color = calculate_color(player_number)

      self:stoptweening()
          :settext(combo)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)
          :linear(0.1)
          :diffusealpha(1)
          :zoom(zoom)
          :x((-(zoom * 52)) + 16)
          :y(-(zoom * 18))

    end,
  }

  ---- Combo Label
  combo_frame[#combo_frame+1] = Def.BitmapText {
    Font = "Common Body",

    InitCommand = function(self)
      self:y(-(self:GetHeight()/2))
          :x(32)
          :zoom(0.85)
          :settext("Combo")
    end,

    ComboChangedMessageCommand = function(self, data)
      if data.Player ~= player_number then return end

      local combo = data.PlayerStageStats:GetCurrentCombo()

      if combo == data.OldCombo then return end

      local zoom = calculate_zoom_from_combo(combo)
      local color = calculate_color(player_number)

      self:stoptweening()
          :Stroke(ThemeColor.White)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)
          :linear(0.1)
          :x((zoom * 52)+64)

    end,
  }

  t[#t+1] = combo_frame

  -- Judgment
  ---- Frame
  local judgment_frame = Def.ActorFrame {
    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(SCREEN_CENTER_Y - 130)
    end,

    JudgmentMessageCommand = function(self, data)
      if data.Player ~= player_number then return end
      if data.TapNoteOffset == nil then return end

      self:stoptweening()
          :visible(true)
          :linear(0.05)
          :zoom(1.25)
          :linear(0.1)
          :zoom(1)
    end,
  }

  ---- Tap Note Judgment
  judgment_frame[#judgment_frame+1] = Def.BitmapText {
    Font = "Gameplay Judgment",

    JudgmentMessageCommand = function(self, data)
      if data.Player ~= player_number then return end

      if data.TapNoteOffset == nil then return end

      -- if TapNoteOffset is nil, it's not a tap note
      local color = JudgmentColors[data.TapNoteScore]

      local append = ""

      if data.TapNoteScore == "TapNoteScore_W1" then append = "!!!"
      elseif data.TapNoteScore == "TapNoteScore_W2" then append = "!!"
      elseif data.TapNoteScore == "TapNoteScore_W3" then append = "!"
      end

      self:stoptweening()
          :diffusealpha(1)
          :settext(string.upper(THEME:GetString("Judgment", data.TapNoteScore) .. append))
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)

      for i=1, 10 do
        self:diffuse(ColorLightTone(color))
            :sleep(0.025)
            :diffuse(ColorLightTone(color))
            :diffusebottomedge(color)
            :sleep(0.025)
      end

      self:sleep(1)
          :diffusealpha(0)
    end
  }

  -- Hold Note Judgment
  t[#t+1] = Def.BitmapText {
    Font = "Gameplay Judgment",

    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(SCREEN_CENTER_Y - 280)
          :zoom(0.85)
    end,

    JudgmentMessageCommand = function(self, data)
      if data.Player ~= player_number then return end

      -- if TapNoteOffset is not nil, it's not a hold note
      if data.TapNoteOffset ~= nil then return end

      local color = JudgmentColors[data.HoldNoteScore]

      local append = data.HoldNoteScore == "HoldNoteScore_Held" and "!!!" or ""

      self:stoptweening()
          :diffusealpha(1)
          :settext(string.upper(THEME:GetString("Judgment", data.HoldNoteScore) .. append))
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :diffuse(ColorLightTone(color))
          :diffusebottomedge(color)

      for i=1, 10 do
        self:diffuse(ColorLightTone(color))
            :sleep(0.025)
            :diffuse(ColorLightTone(color))
            :diffusebottomedge(color)
            :sleep(0.025)
      end

      self:sleep(0.15)
          :diffusealpha(0)
    end
  }


  t[#t+1] = judgment_frame
end


return t
