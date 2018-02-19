MusicWheelSongView = {}
MusicWheelSongView_mt = { __index = MusicWheelSongView }

local MARGIN_X = 64
local TITLE_Y = SCREEN_CENTER_Y + 128

function MusicWheelSongView:create()
  local self = {}

  setmetatable( self, MusicWheelSongView_mt )

  return self
end

function MusicWheelSongView:create_actors(params)
  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself
      subself:x(SCREEN_CENTER_X + 128)
    end
  }

  t[#t+1] = Def.Banner {
    Name = "Entry Song Banner",
    InitCommand = function(subself)
      subself:halign(1)
             :valign(1)
             :visible(false)
             :y(SCREEN_CENTER_Y + 128)
    end,

    UpdateCommand = function(subself)
      subself:finishtweening()

      local target_y
      if (self.current_entry.type == "Group") then
        subself:LoadFromSongGroup(self.current_entry.title)
               :ScaleToClipped(256, 80)
        target_y = TITLE_Y - 256
      elseif self.current_entry.jacket ~= nil then
        subself:LoadFromCachedBanner(self.current_entry.jacket)
               :ScaleToClipped(256, 256)
        target_y = (TITLE_Y - 256) + 128
      else
        subself:LoadFromCachedBanner(self.current_entry.banner)
               :ScaleToClipped(256, 80)
        target_y = TITLE_Y - 256
      end

      subself:visible(true)
             :zoom(2)
             :skewy(0)
             :diffusealpha(0)
             :y(target_y + 128)
             :rotationy(20)
             :rotationx(-20)
             :tween(0.2, "TweenType_Decelerate")
             :rotationy(0)
             :rotationx(0)
             :y(target_y)
             :x(-MARGIN_X)
             :diffusealpha(1)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Name = "Entry Title",
    Font = "MusicWheel SongviewTitle",
    InitCommand = function(subself)
      subself:halign(1)
             :diffuse(ThemeColor.Black)
             :shadowcolor(ThemeColor.Black)
             :shadowlength(1)
             :x(-MARGIN_X)
             :y(TITLE_Y)
    end,

    UpdateCommand = function(subself)
      subself:finishtweening()
             :settext(self.current_entry.title)
             :scaletofit(0, 0, SCREEN_WIDTH/3, MARGIN_X)
             :y(TITLE_Y)
             :diffuse(Alpha(ThemeColor.White, 0.0))
             :x(-128)
             :tween(0.2, "TweenType_Decelerate")
             :x(-MARGIN_X)
             :diffuse(Alpha(ThemeColor.White, 1))
    end
  }

  t[#t+1] = Def.BitmapText {
    Name = "Entry Artist",
    Font = "Common Body",
    InitCommand = function(subself)
      subself:halign(1)
             :visible(false)
    end,

    UpdateCommand = function(subself)
      if (self.current_entry.type == "Group") then
        subself:visible(false)
        return
      end
      subself:finishtweening()
             :visible(true)
             :settext(self.current_entry.artist)
             :scaletofit(0, 0, SCREEN_WIDTH/3, 28)
             :y(TITLE_Y + 32)
             :diffusealpha(0)
             :x(-MARGIN_X)
             :tween(0.2, "TweenType_Decelerate")
             :diffusealpha(1)
             :y(TITLE_Y + 70)
    end
  }

  t[#t+1] = Def.Banner {
    Name = "Entry Group Banner",
    InitCommand = function(subself)
      subself:halign(1)
             :visible(false)
             :y(TITLE_Y - 68)
    end,

    UpdateCommand = function(subself)
      subself:finishtweening()

      if (self.current_entry.type == "Group") then
        subself:LoadFromSongGroup(self.current_entry.title)
      else
        subself:LoadFromSongGroup(self.current_entry.group)
      end

      subself:ScaleToClipped(128, 40)
             :visible(true)
             :diffusealpha(0)
             :x((-MARGIN_X) - 64)
             :tween(0.2, "TweenType_Decelerate")
             :x(-MARGIN_X)
             :diffusealpha(1)
    end,
  }

  t[#t+1] = Def.BitmapText {
    Name = "Entry BPM",
    Font = "MusicWheel SongViewTitle",
    InitCommand = function(subself)
      subself.bpm = 0
      subself:halign(1)
             :diffuse(ThemeColor.White)
             :x(-MARGIN_X)
             :visible(true)
    end,

    UpdateCommand = function(subself)
      if (self.current_entry.bpm ~= nil) then
        local text = ""
        if self.current_entry.bpm[1] == self.current_entry.bpm[2] then
          text = self.current_entry.bpm[1] .. " BPM"
        else
          text = self.current_entry.bpm[1] .. "~" .. self.current_entry.bpm[2] .. " BPM"
        end
        subself:finishtweening()
               :diffusealpha(0)
               :visible(true)
               :settext(text)
               :y(TITLE_Y + 64)
               :linear(0.15)
               :diffusealpha(1)
               :y(TITLE_Y + 128)
      else
        subself:visible(false)
      end
    end,
  }

  t[#t+1] = Def.BitmapText {
    Name = "Entry Subtitle",
    Font = "Common Body",
    InitCommand = function(subself)
      subself:halign(1)
             :visible(false)
    end,

    UpdateCommand = function(subself)
      if (self.current_entry.type == "Group") then
        subself:visible(false)
        return
      end
      subself:finishtweening()
             :visible(true)
             :settext(self.current_entry.subtitle)
             :scaletofit(0, 0, 640, 32)
             :y(TITLE_Y - 68)
             :diffusealpha(0)
             :x((-MARGIN_X) - 64)
             :tween(0.2, "TweenType_Decelerate")
             :diffusealpha(1)
             :x((-MARGIN_X) - (128 + MARGIN_X/2))
    end
  }

  t[#t+1] = Def.Banner {
    Name = "Entry Group Banner",
    InitCommand = function(subself)
      subself:halign(1)
             :visible(false)
             :y(TITLE_Y - 68)
    end,

    UpdateCommand = function(subself)
      subself:finishtweening()

      if (self.current_entry.type == "Group") then
        subself:LoadFromSongGroup(self.current_entry.title)
      else
        subself:LoadFromSongGroup(self.current_entry.group)
      end

      subself:ScaleToClipped(128, 40)
             :visible(true)
             :diffusealpha(0)
             :x((-MARGIN_X) - 64)
             :tween(0.2, "TweenType_Decelerate")
             :x(-MARGIN_X)
             :diffusealpha(1)
    end,
  }

  return t
end

function MusicWheelSongView:set_current_entry(entry)
  self.current_entry = entry
  self.container:queuecommand("Update")
end