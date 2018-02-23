local t = Def.ActorFrame {}


local banner = Def.ActorFrame {
  InitCommand = function(self)
    self:x(SCREEN_CENTER_X)
        :y(SCREEN_CENTER_Y)
  end,

  OnCommand = function(self)
    self:sleep(1.5)
        :linear(1)
        :diffusealpha(0)
        :queuecommand("Start")
  end,

  StartCommand = function(self)
    SCREENMAN:SetNewScreen("ScreenGameplay")
  end
}

local song = GAMESTATE:GetCurrentSong()

local banner_dimension = iif(song:GetJacketPath(), { 256, 256 }, { 256, 80 })
local banner_src = song:GetJacketPath() or song:GetBannerPath()
local banner_zoom = 2.2

banner[#banner+1] = Def.Sprite {
  InitCommand = function(self)

  end,

  OnCommand = function(self)
    self:Load(banner_src)
        :scaletoclipped(banner_dimension[1], banner_dimension[2])
        :visible(true)
        :zoom(banner_zoom)
  end,
}

banner[#banner+1] = Def.Quad {
  InitCommand = function(self)
    self:zoomto(banner_dimension[1] * banner_zoom, banner_dimension[2] * banner_zoom)
        :diffuse(ThemeColor.White)
  end,

  OnCommand = function(self)
    self:sleep(0.4)
        :linear(1)
        :zoomto(banner_dimension[1] * (banner_zoom * 1.5), banner_dimension[2] * (banner_zoom * 1.5))
        :diffusealpha(0)
      end
}

t[#t+1] = banner

t[#t+1] = Def.Quad {
  InitCommand = function(self)
    self:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
        :diffuse(Brightness(ThemeColor.White, 0.5))
        :x(SCREEN_CENTER_X)
        :y(SCREEN_CENTER_Y)
  end,

  OnCommand = function(self)
    self:linear(0.1)
        :diffuse(ThemeColor.White)
        :sleep(0.4)
        :linear(0.2)
        :zoomto(SCREEN_WIDTH, 0)
  end,

}

t[#t+1] = Def.BitmapText {
  Font = "Common header",
  InitCommand = function(self)
    self:settext(THEME:GetString("Stage", GAMESTATE:GetCurrentStage()))
        :diffuse(ThemeColor.Black)
        :x(SCREEN_CENTER_X)
        :y(SCREEN_CENTER_Y - self:GetHeight() / 2)
  end,

  OnCommand = function(self)
    self:linear(0.2)
        :sleep(0.4)
        :linear(0.1)
        :zoomto(self:GetWidth(), 0)
        :y(SCREEN_CENTER_Y)

  end,
}

return t;

