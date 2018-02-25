local t = Def.ActorFrame { }


for player_index, player_number in ipairs(GAMESTATE:GetEnabledPlayers()) do

  -- Score display
  local SCORE_FRAME_WIDTH = 360
  ---- Frame
  local score_frame = Def.ActorFrame {
    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and -SCORE_FRAME_WIDTH or SCREEN_WIDTH + SCORE_FRAME_WIDTH)
          :y(SCREEN_HEIGHT - 96)
    end,

    OnCommand = function(self)
      self:tween(0.8, "TweenType_Decelerate")
          :x(player_number == "PlayerNumber_P1" and SCORE_FRAME_WIDTH/2 or SCREEN_WIDTH - SCORE_FRAME_WIDTH/2)
          :y(SCREEN_HEIGHT - 96)
    end
  }

  ---- Background
  score_frame[#score_frame+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Gameplay/ScoreHolder.png"),
    InitCommand = function(self)
      self:diffuse(PlayerColors[player_number])
          :zoom(0.60)
          :rotationy(player_number == "PlayerNumber_P1" and 0 or 180)
    end

  }

  ---- Score
  score_frame[#score_frame+1] = Def.RollingNumbers {
    Font = "Common body",

    InitCommand = function(self)
      self:diffuse(ThemeColor.White)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :set_chars_wide(7)
          :set_approach_seconds(0.5)
          :set_leading_attribute{ Diffuse=ThemeColor.Black }
    end,

    ScoreChangedMessageCommand = function(self, data)
      if data.PlayerNumber ~= player_number then return end

      local stage_stats = STATSMAN:GetCurStageStats()
      self:target_number(get_score(GAMESTATE:GetCurrentSteps(data.PlayerNumber), stage_stats:GetPlayerStageStats(data.PlayerNumber), true))
    end,
  }

  ---- Background (Difficulty)
  score_frame[#score_frame+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Gameplay/DifficultyHolder.png"),
    InitCommand = function(self)
      local difficulty = GAMESTATE:GetCurrentSteps(player_number):GetDifficulty()
      self:diffuse(ThemeColor.Black)
          :zoom(0.60)
          :y(-58)
          :x(player_number == "PlayerNumber_P1" and -58 or 58)
          :rotationy(player_number == "PlayerNumber_P1" and 0 or 180)
    end

  }

  ---- Difficulty name
  score_frame[#score_frame+1] = Def.BitmapText {
    Font = "Common Body",

    InitCommand = function(self)
      local difficulty = GAMESTATE:GetCurrentSteps(player_number):GetDifficulty()
      self:diffuse(ThemeColor.White)
          :settext(THEME:GetString("Difficulty", difficulty))
          :diffuse(ThemeColor.White)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :zoom(0.5)
          :halign(player_number == "PlayerNumber_P1" and 1 or 0)
          :y(-54)
          :x(player_number == "PlayerNumber_P1" and -35 or 35)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
    end,
  }

  ---- Difficulty level
  score_frame[#score_frame+1] = Def.BitmapText {
    Font = "MusicWheel Difficulty",

    InitCommand = function(self)
      local meter = GAMESTATE:GetCurrentSteps(player_number):GetMeter()
      local difficulty = GAMESTATE:GetCurrentSteps(player_number):GetDifficulty()
      self:diffuse(ThemeColor.White)
          :settext(meter)
          :diffuse(DifficultyColors[difficulty])
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
          :halign(player_number == "PlayerNumber_P1" and 0 or 1)
          :y(-54)
          :x(player_number == "PlayerNumber_P1" and -25 or 25)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
    end,
  }

  t[#t+1] = score_frame


  -- Life display
  local LIFE_FRAME_WIDTH = 650
  local LIFE_FRAME_HEIGHT = 34
  ---- Frame
  local life_frame = Def.ActorFrame {
    InitCommand = function(self)
      self:x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(-48)
    end,

    OnCommand = function(self)
      self:tween(0.8, "TweenType_Decelerate" )
          :x(player_number == "PlayerNumber_P1" and PlayerP1X() or PlayerP2X())
          :y(48)
    end
  }

  ---- Background
  life_frame[#life_frame+1] = Def.Quad {
    InitCommand = function(self)
      self:zoomto(LIFE_FRAME_WIDTH, LIFE_FRAME_HEIGHT)
          :diffuse(PlayerColors[player_number])
          :diffusealpha(0.4)
    end

  }

  ---- Life Meter
  life_frame[#life_frame+1] = Def.Quad {
    InitCommand = function(self)
      self:zoomto(0, LIFE_FRAME_HEIGHT)
          :halign(player_number == "PlayerNumber_P1" and 0 or 1)
          :x(player_number == "PlayerNumber_P1" and -LIFE_FRAME_WIDTH/2 or LIFE_FRAME_WIDTH/2)
          :diffuse(ThemeColor.Green)
    end,

    LifeChangedMessageCommand = function(self, data)
      if data.Player ~= player_number then return end

      local life = data.LifeMeter:GetLife()
      local state = "Regular"

      if data.LifeMeter:IsInDanger() then state = "Danger"
      elseif data.LifeMeter:IsHot() then state = "Hot" end

      if self.life_last_update ~= life then
        self:stoptweening()
            :linear(0.1)
            :zoomto(LIFE_FRAME_WIDTH * data.LifeMeter:GetLife(), LIFE_FRAME_HEIGHT)
            :diffuse(ThemeColor.White)
            :queuecommand(state)
      end

      self.life_last_update = data.LifeMeter:GetLife()
    end,


    RegularCommand = function(self)
      self:linear(0.2)
          :diffuse(ThemeColor.Green)
    end,

    HotCommand = function(self)
      local color = { ThemeColor.Green, ThemeColor.Blue, ThemeColor.Purple }

      for i, color in ipairs(color) do
       self:linear(0.2)
           :diffuse(color)
      end

      self:queuecommand("Hot")
    end,

    DangerCommand = function(self)

      for i, color in ipairs(ClearLampStates.Failed.flash_colors) do
       self:diffuse(color)
           :sleep(ClearLampStates.Failed.flash_speed)
      end

      self:queuecommand("Danger")
    end
  }

  life_frame[#life_frame+1] = Def.Sprite {
    Texture = THEME:GetPathG("", "Gameplay/LifeBar.png"),
    InitCommand = function(self)
      self:zoom(0.50)
          :diffuse(PlayerColors[player_number])
          :x(player_number == "PlayerNumber_P1" and 9 or -9)
          :rotationy(player_number == "PlayerNumber_P1" and 0 or 180)
          :shadowcolor(ThemeColor.Black)
          :shadowlength(1)
    end
  }

  t[#t+1] = life_frame

end

return t

