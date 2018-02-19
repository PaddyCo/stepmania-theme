MusicWheelEntry = {}
MusicWheelEntry_mt = { __index = MusicWheelEntry }

function MusicWheelEntry:create()
  local self = {}
  setmetatable( self, MusicWheelEntry_mt )

  self.data = nil

  return self
end

function MusicWheelEntry:create_actors(params)
  local container = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself
    end,

    PlayPreviewCommand = function(subself)
      if self.is_focused then
        if self.data.type == "Song" then
          SOUND:PlayMusicPart(self.data.music_preview.path, self.data.music_preview.sample_start, self.data.music_preview.sample_length, 1, 1, true, true)
        else
          SOUND:StopMusic()
        end
      end
    end,

    OffCommand = function(subself)
      SOUND:StopMusic()
    end,

    ScrollCommand = function(subself)
      subself:sleep(0.1)
             :queuecommand("PlayPreview")
    end,

    PageSwitchCommand = function(subself)
      subself:sleep(0.1)
             :queuecommand("PlayPreview")
    end,

    OpenGroupCommand = function(subself)
      SOUND:StopMusic()
    end,

    CloseGroupCommand = function(subself)
      SOUND:StopMusic()
    end
  }

  local get_x = function()
    if self.data.type == "Song" then
      return self.is_focused and 0 or 50
    else
      return self.is_focused and -50 or 0
    end
  end

  local t = Def.ActorFrame {
    OnCommand = function(subself)
      subself:queuecommand("Scroll")
    end,

    ScrollCommand = function(subself)
      subself:stoptweening()
             :linear(0.1)
             :x(get_x())
    end,

    PageSwitchCommand = function(subself)
      subself:stoptweening()
             :x(get_x())
    end,

    OpenGroupCommand = function(subself)
      if self.data.type == "Group" then
        subself:finishtweening()
               :queuecommand("OnOpenGroup")
               :linear(0.1)
               :x(get_x())
      else
        subself:finishtweening()
               :tween(0.2, "TweenType_Accelerate")
               :x(SCREEN_WIDTH/2 + 128)
               :queuecommand("OnOpenGroup")
               :tween(0.2, "TweenType_Decelerate")
               :x(get_x())
      end
    end,

    CloseGroupCommand = function(subself)
      if self.last_type == "Group" then
        subself:finishtweening()
               :queuecommand("OnCloseGroup")
               :linear(0.1)
               :x(get_x())
      else
        subself:finishtweening()
               :tween(0.2, "TweenType_Accelerate")
               :x(SCREEN_WIDTH/2 + 128)
               :queuecommand("OnCloseGroup")
               :tween(0.2, "TweenType_Decelerate")
               :x(get_x())
      end
    end,
  }

  container[#container+1] = t

  -- Background
  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      self.mask = subself

      subself:diffuse(Alpha(ThemeColor.Black, 0.2))
             :diffuseleftedge(Alpha(ThemeColor.Black, 0.8))
             :zoomto(SCREEN_WIDTH/2 + 128, 60)
             :x(3)
             :y(1)
             :halign(0)
    end,
  }


  -- Background focus background
  t[#t+1] = Def.Quad {
    InitCommand = function(subself)
      subself:zoomto(0, 60)
             :x(3)
             :y(1)
             :halign(0)
             :diffuse(ThemeColor.Red)
    end,

    ScrollCommand = function(subself)
      if (self.is_focused) then
        subself:stoptweening()
               :linear(0.2)
               :zoomtowidth(SCREEN_WIDTH/2 + 128)
      else
        subself:stoptweening()
               :linear(0.15)
               :zoomtowidth(0)
      end
    end,

    PageSwitchCommand = function(subself)
      subself:stoptweening()
             :zoomtowidth(0)
             :queuecommand("Scroll")
    end,

    OpenGroupCommand = function(subself)
      if self.is_focused == false then return end
      subself:finishtweening()
    end
  }

  -- Difficulty Segment Background
  t[#t+1] = Def.Sprite {
    Name = "Difficulty Segment",
    Texture = THEME:GetPathG("", "MusicWheel/DifficultySegment.png"),
    InitCommand = function(subself)
      subself:y(1)
             :x(10)
             :basealpha(0.5)
             :zoom(0.5)
             :halign(0)
    end,

    UpdateCommand = function(subself)
      subself:visible(self.data.type == "Song")
    end,

    ScrollCommand = function(subself)
      subself:queuecommand("Update")
    end,

    PageSwitchCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnCloseGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnOpenGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,
  }

  -- Title
  t[#t+1] = Def.BitmapText {
    Font = "Common Normal",
    InitCommand = function(subself)
      subself:diffuse(ThemeColor.White)
             :shadowcolor(ThemeColor.Black)
             :shadowlength(1)
             :halign(0)
    end,

    UpdateCommand = function(subself)
      subself:settext(self.data.title)
             :x(self.data.type == "Song" and 64+24 or 16)
    end,

    ScrollCommand = function(subself)
      subself:queuecommand("Update")
    end,

    PageSwitchCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnCloseGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnOpenGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,
  }

  -- Difficulty level
  t[#t+1] = Def.BitmapText {
    Name = "Difficulty Level",
    Font = "MusicWheel Difficulty",
    InitCommand = function(subself)
      subself:diffuse(ThemeColor.White)
             :x(40)
             :visible(false)
             :horizalign("HorizAlign_Center")
    end,

    UpdateCommand = function(subself)
      if (self.data.type == "Song") then

        subself:settext(self.data.level)
               :diffuse(DifficultyColors[self.data.difficulty])
               :visible(true)
      else
        subself:visible(false)
      end
    end,

    ScrollCommand = function(subself)
      subself:queuecommand("Update")
    end,

    PageSwitchCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnCloseGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnOpenGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,
  }


  -- Clear lamp (Off)
  t[#t+1] = Def.Sprite {
    Name = "Clear Lamp - Off",
    Texture = THEME:GetPathG("", "MusicWheel/ClearLampOff.png"),
    InitCommand = function(subself)
      subself:y(1)
             :zoom(0.5)
             :diffuse(ThemeColor.Black)
             :visible(false)
             :halign(0)
    end,

    UpdateCommand = function(subself)
      subself:visible(self.data.type == "Song" and self.data.score == nil)
    end,

    ScrollCommand = function(subself)
      subself:queuecommand("Update")
    end,

    PageSwitchCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnCloseGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,

    OnOpenGroupCommand = function(subself)
      subself:queuecommand("Update")
    end,
  }



  -- Clear lamp
  t[#t+1] = Def.Sprite {
    Name = "Clear Lamp",
    Texture = THEME:GetPathG("", "MusicWheel/ClearLamp.png"),
    InitCommand = function(subself)
      subself:y(1)
             :zoom(0.5)
             :x(-38)
             :visible(false)
             :halign(0)
    end,

    UpdateCommand = function(subself)
      -- TODO: Fix flashing lights being stuck during scrolling
      -- and make them all sync with a global timer or something

      subself:stoptweening()
      if (self.data.type == "Song") then
        subself:visible(true)
               :diffuse(ThemeColor.Black)
        if (self.data.score == nil) then
          -- No play
          subself:visible(false)
          return
        end

        subself:SetStateProperties({{ Frame = 0, Delay = 100 }})

        if (self.data.score.grade == "Grade_Failed") then
          -- Failed
          subself.flash_speed = 0.03
          subself.flash_colors = { ThemeColor.Red, Brightness(ThemeColor.Red, 0.8) }
          subself:queuecommand("Flash")
        elseif table.find_index(self.data.score.award, { "StageAward_FullComboW3", "StageAward_SingleDigitW3", "StageAward_OneW3" }) ~= -1 then
          -- Full Combo Clear
          subself.flash_speed = 0.1
          subself.flash_colors = { ThemeColor.Red, ThemeColor.Yellow, ThemeColor.White, ThemeColor.Green }
          subself:queuecommand("Flash")
        elseif table.find_index(self.data.score.award, { "StageAward_FullComboW2", "StageAward_SingleDigitW2", "StageAward_OneW2" }) ~= -1 then
          -- Perfect Full Combo Clear
          subself.flash_speed = 0.06
          subself.flash_colors = { ThemeColor.Red, ThemeColor.Yellow, ThemeColor.White, ThemeColor.Green }
          subself:queuecommand("Flash")
        elseif self.data.score.award == "StageAward_FullComboW1" then
          -- Marevelous Full Combo Clear
          subself.flash_speed = 0.04
          subself.flash_colors = { ThemeColor.Red, ThemeColor.Yellow, ThemeColor.White, ThemeColor.Green }
          subself:queuecommand("Flash")
        else
          -- Regular Clear
          subself:diffuse(ThemeColor.Yellow)
        end
      else
        subself:visible(false)
      end
    end,

    FlashCommand = function(subself)
      subself:stoptweening()
      for i, color in ipairs(subself.flash_colors) do
        subself:diffuse(color)
               :sleep(subself.flash_speed)
      end

      subself:queuecommand("Flash")
    end,

    ScrollCommand = function(subself)
      subself:stoptweening()
             :queuecommand("Update")
    end,

    PageSwitchCommand = function(subself)
      subself:stoptweening()
             :queuecommand("Update")
    end,

    OnCloseGroupCommand = function(subself)
      subself:stoptweening()
             :queuecommand("Update")
    end,

    OnOpenGroupCommand = function(subself)
      subself:stoptweening()
             :queuecommand("Update")
    end,
  }
  return container
end

function MusicWheelEntry:transform(item_index, num_items, is_focus)
  if self.index_last_update == nil then
    -- Keep track what this entries index is, if it jumps more then one (because of scrolling multiple or it wrapping around) we should not tween it.
    self.index_last_update = item_index
  end

  self.is_focused = is_focus

  if item_index == self.index_last_update+1 or item_index == self.index_last_update-1 then
    self.container:stoptweening()
                  :linear(0.1)
                  :y(item_index * 64)
  else
    self.container:stoptweening()
                  :y(item_index * 64)
  end

  self.index_last_update = item_index
end

function MusicWheelEntry:set(data)
  if (self.data ~= nil) then
    self.last_type = self.data.type
  else
    self.last_type = "Group"
  end

  self.data = data
end
