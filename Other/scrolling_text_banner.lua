local scrolling_text_banner_mt = {
  __index = {
    create_actors = function(self, y, text)
      self.text = text

      local t = Def.ActorFrame {
        InitCommand = function(subself)
          subself:y(y)
                 :queuecommand("Update")
        end,


        Def.Quad {
          InitCommand = function(subself)
            subself:diffuse(ThemeColor.Black)
                   :basealpha(0.25)
                   :zoomto(SCREEN_WIDTH * 2, 42)
          end,

        },
      }

      t[#t+1] = Def.BitmapText {
        Font = "Common Body",
        InitCommand = function(subself)
          subself:x(SCREEN_WIDTH)
          :diffuse(ThemeColor.White)
          :horizalign("HorizAlign_Left")
          :zoom(0.5)
        end,

        ScrollCommand = function(subself)
          local start_x = SCREEN_WIDTH/2
          local target_x = -((SCREEN_WIDTH/2) + (subself:GetWidth()/2))
          local travel_time = (start_x - target_x) / 300

          subself:x(start_x)
          :linear(travel_time)
          :x(target_x)
          :queuecommand("Scroll")
        end,

        UpdateCommand = function(subself)
          subself:stoptweening()
          :settext(self.text)
          :queuecommand("Scroll")
        end
      }

      return t
    end,

    set_text = function(self, text)
      self.text = text
    end
  }
}

ScrollingTextBanner = setmetatable({}, scrolling_text_banner_mt)
