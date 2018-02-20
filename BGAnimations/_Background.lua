local t = Def.ActorFrame {}
local params = ...

t[#t+1] = Def.Quad {
	Name="BaseBackgroundColor",
	InitCommand=function(self)
    self.params = params
    CurrentBackground = self
		self:xy(_screen.w / 2, _screen.h / 2)
    self:zoomto(_screen.w, _screen.h)
    self:diffusetopedge(top_background_color)
    self:diffusebottomedge(bottom_background_color)
	end,
  UpdateCommand=function(self)
    self:linear(0.5)
        :diffusetopedge(top_background_color)
        :diffusebottomedge(bottom_background_color)
  end
}

local MAX_SIZE = 96

for i=1, 70 do
  -- Only generate size once, since otherwise the slower onces will start to dominate the screen
  local size = math.random(MAX_SIZE - 16) + 16;
  local first = true
  t[#t+1] = Def.Quad {
    OnCommand=function(self)
      self:queuecommand("Fall")
    end;
    FallCommand=function(self)
      -- Initialize
      local start_x = math.random(SCREEN_WIDTH)
      local start_y = first and -math.random(SCREEN_HEIGHT * 2) + SCREEN_HEIGHT or -(math.random(SCREEN_HEIGHT * 2) + size)
      first = false
      local fall_speed = size * 0.8
      self:SetWidth(size)
      self:SetHeight(size)
      self:diffuse(particle_color)
      self:xy(start_x, start_y)
      self:rotationz(math.random(360))
      self:rotationx(math.random(360))
      self:rotationy(math.random(360))

      self:xy(start_x, start_y)
          :linear((SCREEN_HEIGHT-start_y) / fall_speed)
          :xy(start_x, SCREEN_HEIGHT + 360)
          :basealpha((1/(MAX_SIZE + (MAX_SIZE * 2))) * size)
          :rotationz(math.random(360))
          :rotationx(math.random(360))
          :rotationy(math.random(360))
          :queuecommand("Fall")
    end
  }
end

t[#t+1] = Def.Sprite {
  Name="Overlay",
  Texture="../Graphics/_Misc/diagonal_scan_lines.png",
  InitCommand=function(self)
    self:diffusetopedge(top_background_color)
        :diffusebottomedge(ThemeColor.Black)
        :basealpha(0.25)
        :halign(0)
        :valign(0)
  end,
}

return t
