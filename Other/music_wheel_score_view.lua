MusicWheelScoreView = {}
MusicWheelScoreView_mt = { __index = MusicWheelScoreView }

function MusicWheelScoreView:create()
  local self = {}

  setmetatable( self, MusicWheelScoreView_mt )

  return self
end

function MusicWheelScoreView:create_actors(params)
  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself
      subself:x(SCREEN_CENTER_X - 195)
             :y(SCREEN_HEIGHT + 100)
    end,

    UpdateCommand = function(subself)
      subself:stoptweening()
             :linear(0.1)
             :y(self.entry.type == "Group" and SCREEN_HEIGHT+100 or SCREEN_HEIGHT - 70)
    end
  }

  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      subself:zoomto(512, 140)
             :y(-30)
             :diffuse(ThemeColor.Black)
             :diffusealpha(0.5)
    end
  }

  t[#t+1] = Def.BitmapText {
    Name = "Score Label",
    Font = "Common Body",

    InitCommand = function(subself)
      subself:settext(string.upper(THEME:GetString("ScoreView", "Score")))
             :halign(0)
             :zoom(0.5)
             :y(-70)
             :x(-232)
    end
  }

  t[#t+1] = Def.RollingNumbers {
    Name = "Score",
    Font = "Score Regular",

    InitCommand = function(subself)
      self.score_text = subself
      subself:diffuse(ThemeColor.White)
             :zoom(0.5)
             :y(-70)
             :x(-54)
             :halign(0)
             :set_chars_wide(7)
             :set_approach_seconds(0.5)
             :set_leading_attribute{ Diffuse=ThemeColor.Black }
      self.score = 0
    end,

    UpdateCommand = function(subself)
      subself:target_number(self.entry.score ~= nil and self.entry.score.best_score_rounded or 0)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Name = "Miss Count Label",
    Font = "Common Body",

    InitCommand = function(subself)
      subself:settext(string.upper(THEME:GetString("ScoreView", "MissCount")))
             :halign(0)
             :zoom(0.5)
             :y(-32)
             :x(-232)
    end
  }

  t[#t+1] = Def.BitmapText {
    Name = "Grade",
    Font = "Common Body",

    InitCommand = function(subself)
      subself:diffuse(ThemeColor.Yellow)
             :y(-32)
             :x(175)
             :halign(0.5)
    end,

    UpdateCommand = function(subself)
      if self.entry.score == nil then
        subself:linear(0.1)
               :diffusealpha(0)
               :x(200)
        return
      end

      subself:linear(0.1)
             :diffusealpha(1)
             :x(175)
             :settext(self.entry.score.best_grade)
    end,
  }

  t[#t+1] = Def.RollingNumbers {
    Name = "Miss Count",
    Font = "Score Regular",

    InitCommand = function(subself)
      subself:diffuse(ThemeColor.White)
             :y(-32)
             :x(-54)
             :zoom(0.5)
             :halign(0)
             :set_chars_wide(4)
             :set_approach_seconds(0.5)
             :set_leading_attribute{ Diffuse=ThemeColor.Black }

    end,

    UpdateCommand = function(subself)
      local miss_count = self.entry.score and self.entry.score.miss_count or 0
      subself:target_number(miss_count)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Name = "Clear State",
    Font = "Common Body",

    InitCommand = function(subself)
      subself:settext("")
             :halign(0)
             :zoom(0.5)
             :y(6)
             :x(-232)
    end,

    UpdateCommand = function(subself)
      subself:stoptweening()
      if self.entry.type == "Group" or self.entry.score == nil then
        subself:linear(0.1)
               :diffuse(ThemeColor.White)
               :diffusealpha(0.5)
               :settext("NO PLAY")
        return
      end

      subself:linear(0.1)
             :diffusealpha(1)

      if self.entry.clear_lamp == "Failed" then
        subself:settext(string.upper(THEME:GetString("ClearState", "Failed")))
      elseif self.entry.clear_lamp == "FullCombo" then
        subself:settext(string.upper(THEME:GetString("ClearState", "FullCombo")))
      elseif self.entry.clear_lamp == "PerfectFullCombo" then
        subself:settext(string.upper(THEME:GetString("ClearState", "PerfectFullCombo")))
      elseif self.entry.clear_lamp == "MarvelousFullCombo" then
        subself:settext(string.upper(THEME:GetString("ClearState", "MarvelousFullCombo")))
      else
        subself:settext(string.upper(THEME:GetString("ClearState", "Clear")))
      end

      subself:queuecommand("Flash")
    end,

    FlashCommand = function(subself)
      if self.entry.clear_lamp == nil then
        subself:stoptweening()
        return
      end

      local lamp_state = ClearLampStates[self.entry.clear_lamp]
      subself:stoptweening()
      for i, color in ipairs(lamp_state.flash_colors) do
        subself:diffuse(color)
               :sleep(lamp_state.flash_speed)
      end

      subself:queuecommand("Flash")
    end
  }

  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      subself:zoomto(0, 16)
             :halign(0)
             :x(-256)
             :y(32)
    end,

    UpdateCommand = function(subself)
      local max_width = 512
      local percentage = self.entry.score ~= nil and self.entry.score.best_score / 1000000 or 0
      subself:stoptweening()
             :linear(0.1)
             :zoomto(max_width * percentage, 16)

      if self.entry.score ~= nil then
        subself:queuecommand("Flash")
      end
    end,

    FlashCommand = function(subself)
      if self.entry.clear_lamp == nil then
        subself:stoptweening()
        return
      end
      local lamp_state = ClearLampStates[self.entry.clear_lamp]
      subself:stoptweening()
      for i, color in ipairs(lamp_state.flash_colors) do
        subself:diffuse(color)
               :sleep(lamp_state.flash_speed)
      end

        subself:queuecommand("Flash")
    end
  }

  return t
end

function MusicWheelScoreView:set_current_entry(entry)
  self.entry = entry
  self.container:queuecommand("Update")
end
