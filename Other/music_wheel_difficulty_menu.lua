MusicWheelDifficultyMenu = {}
MusicWheelDifficultyMenu_mt = { __index = MusicWheelDifficultyMenu }

function MusicWheelDifficultyMenu.create()
  local self = {}

  setmetatable( self, MusicWheelDifficultyMenu_mt )

  return self
end

function MusicWheelDifficultyMenu:create_actors(params)
  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself

      subself:y(64)
    end
  }

  for i in ipairs(Difficulty) do
    local difficulty = Def.ActorFrame {
      InitCommand = function(subself)
        subself:y(i * 64)
               :halign(0)
               :x(-300)
      end,

      UpdateCommand = function(subself)
        subself:stoptweening()

        if self.data ~= nil and #self.data >= i then
          subself:linear(0.1)
                 :x(-1)
        else
          subself:linear(0.1)
                 :x(-300)
        end
      end
    }

    difficulty[#difficulty+1] = Def.Quad {
      InitCommand = function(subself)
        self.mask = subself

        subself:diffuse(Alpha(ThemeColor.Black, 0.2))
               :diffuserightedge(Alpha(ThemeColor.Black, 0.8))
               :zoomto(221, 60)
               :x(0)
               :halign(0)
      end,
    }

    -- Focus background
    difficulty[#difficulty+1] = Def.Quad {
      InitCommand = function(subself)
        subself:zoomto(0, 60)
               :halign(0)
               :diffuse(ThemeColor.Red)
      end,

      UpdateCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          if (self.entry.difficulty == self.data[i].difficulty) then
            subself:stoptweening()
                   :linear(0.1)
                   :zoomtowidth(223)
          else
            subself:stoptweening()
                   :linear(0.1)
                   :zoomtowidth(0)
          end
        end
      end,
    }

    difficulty[#difficulty+1] = Def.BitmapText {
      Font = "Common Body",
      Name = "Difficulty" .. i,
      InitCommand = function(subself)
        subself:diffuse(ThemeColor.White)
               :shadowcolor(ThemeColor.Black)
               :shadowlength(1)
               :zoom(0.5)
               :x(140)
               :halign(1)
      end,

      UpdateCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          subself:settext(THEME:GetString("Difficulty", self.data[i].difficulty))
        end
      end
    }

    -- Difficulty Segment Background
    difficulty[#difficulty+1] = Def.Sprite {
      Name = "Difficulty Segment",
      Texture = THEME:GetPathG("", "MusicWheel/DifficultySegment.png"),
      InitCommand = function(subself)
        subself:x(190)
               :basealpha(0.5)
               :zoom(0.5)
               :halign(0.5)
      end,
    }

    difficulty[#difficulty+1] = Def.BitmapText {
      Name = "DifficultyLevel" .. i,
      Font = "MusicWheel Difficulty",
      InitCommand = function(subself)
        subself:x(190)
               :diffuse(ThemeColor.White)
               :halign(0.5)
      end,

      UpdateCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          subself:settext(self.data[i].level)
                 :stoptweening()
                 :linear(0.1)
                 :diffuse(DifficultyColors[self.data[i].difficulty])
        end
      end
    }

    -- TODO: Make Clear Lamp its own actor type so I can re use it here and on the music_wheel_entry
    -- Instead of duplicating code.

    -- Clear lamp (Off)
    difficulty[#difficulty+1] = Def.Sprite {
      Name = "Clear Lamp - Off",
      Texture = THEME:GetPathG("", "MusicWheel/ClearLampOff.png"),
      InitCommand = function(subself)
        subself:y(0)
               :zoom(0.5)
               :x(231)
               :rotationy(180)
               :diffuse(ThemeColor.Black)
               :halign(0)
      end,

      UpdateCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          subself:visible(true)
        else
          subself:visible(false)
        end
      end,
    }

    -- Clear lamp
    difficulty[#difficulty+1] = Def.Sprite {
      Name = "Clear Lamp",
      Texture = THEME:GetPathG("", "MusicWheel/ClearLamp.png"),
      InitCommand = function(subself)
        subself:y(0)
               :rotationy(180)
               :zoom(0.5)
               :x(231+38)
               :visible(false)
               :halign(0)
      end,

      UpdateCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          -- TODO: Fix flashing lights being stuck during scrolling
          -- and make them all sync with a global timer or something

          subself:stoptweening()

          if (self.data[i].score ~= nil) then
            subself:visible(true)
            subself:queuecommand("Flash")
          else
            subself:visible(false)
          end
        end
      end,

      FlashCommand = function(subself)
        if self.data ~= nil and #self.data >= i then
          lamp_state = ClearLampStates[self.data[i].clear_lamp]
          subself:stoptweening()
          for i, color in ipairs(lamp_state.flash_colors) do
            subself:diffuse(color)
                   :sleep(lamp_state.flash_speed)
          end

          subself:queuecommand("Flash")
        end
      end,
    }

    t[#t+1] = difficulty
  end


  return t
end

function MusicWheelDifficultyMenu:set_current_entry(entry)
  self.entry = entry
  if entry.type == "Song" then
    self.data = table.map(entry.all_steps, function(steps) return SongEntryData.create(entry.song, steps) end)
    table.sort(self.data, function(a, b) return DifficultyIndex[a.difficulty] < DifficultyIndex[b.difficulty] end)
  else
    self.data = nil
  end

  self.container:queuecommand("Update")
end
