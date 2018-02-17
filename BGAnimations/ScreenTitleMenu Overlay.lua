dofile(THEME:GetPathO("", "scrolling_text_banner.lua"))

local SCROLL_SPEED = 0.5

local menu = nil

-- Menu actor type
local main_menu_mt = {
  __index = {
    create_actors = function(self, options)

      -- Initialize properties
      self.current_option = options[1]
      self.time_since_last_update = 0
      self.options = options

      -- Set refernce to self (for input handler)
      menu = self

      -- Menu parent
      local t = Def.ActorFrame {
        InitCommand = function(subself)
          self.container = subself
          self.num_items = #options
          subself:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
        end,

        OnCommand = function(subself)
          SCREENMAN:GetTopScreen():AddInputCallback(self.handle_input)
        end,
      }

      -- Loop trough the options and create their actors
      for i, option in ipairs(options) do
        t[#t+1] = Def.ActorFrame {
          InitCommand = function(subself)
            subself:visible(false)
                   :queuecommand("Update")
            subself.init = false
          end,

          UpdateCommand = function(subself)
            if i == current_main_menu_index and CurrentBackground ~= nil then
              top_background_color = option.color
              CurrentBackground:queuecommand("Update")
            end

            local relative_index = i - current_main_menu_index

            local scroll_bezier = {
              0.0, 0.0,
              0.2, 0.5,
              0.6, 0.8,
              1.0, 1.0
            }

            subself:stoptweening()
                   :visible(true)
                   :tween(subself.init and SCROLL_SPEED or 0, "TweenType_Bezier", scroll_bezier)
                   :xy(relative_index * SCREEN_WIDTH, 0)

            subself.init = true

          end,

          -- Label
          Def.BitmapText {
            Font = "Common Header",
            InitCommand = function(subself)
              subself:settext(string.upper(THEME:GetString("MainMenu", option["label"] .. "Label")))
                     :diffuse(ThemeColor.Black)
                     :zoom(0.5)
                     :y(75)
            end,
            UpdateCommand = function(subself)
            end
          },

          -- Icon
          Def.Sprite{
            Name="Icon",
            Texture=option.icon.texture,
            InitCommand=function(subself)
              subself:y(-75)
                     :bob()
                     :zoom(0.5)
            end,
            UpdateCommand = function(subself)
              if (i == current_main_menu_index) then
                subself:SetStateProperties(option.icon.frames.active)
              else
                subself:SetStateProperties(option.icon.frames.inactive)
              end
            end,
          },

        }
      end

      -- Text banner
      self.description_text = ScrollingTextBanner

      t[#t+1] = self.description_text:create_actors(200, THEME:GetString("MainMenu", self.options[1]["label"] .. "Description"))

      return t
    end,

    -- Function used to update all the menu items etc after selecting a new option
    update = function(self)
      self.time_since_last_update = GetTimeSinceStart()
      self.description_text:set_text(THEME:GetString("MainMenu", self.options[current_main_menu_index]["label"] .. "Description"))
      self.container:queuecommand("Update")
      SOUND:PlayOnce(THEME:GetPathS("Common", "value"), true)
    end,

    -- Handle the input
    handle_input = function(event)
      -- Ignore release event
      if event.type == "InputEventType_Release" then return end

      -- Make sure that the menu has stopped scrolling before accepting input
      if menu.time_since_last_update + SCROLL_SPEED > GetTimeSinceStart() then return end

      if event.GameButton == "Start" then
        SCREENMAN:SetNewScreen(menu.options[current_main_menu_index].screen)
        SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)
      end
      if current_main_menu_index < menu.num_items and (event.GameButton == "MenuRight" or event.GameButton == "MenuDown") then
        current_main_menu_index = current_main_menu_index + 1
        menu:update()
      end
      if current_main_menu_index > 1 and (event.GameButton == "MenuLeft" or event.GameButton == "MenuUp") then
        current_main_menu_index = current_main_menu_index - 1
        menu:update()
      end
    end
  }
}

-- Setup menu options
local menu_options = {
  {
    label = "Arcade",
    color = ThemeColor.Red,
    screen = "ScreenArcadeMenu",
    icon = ARCADE_ICON
  },
  {
    label = "Course",
    color = ThemeColor.Blue,
    screen = "ScreenTitleMenu",
    icon = COURSE_ICON
  },
  {
    label = "Oni",
    color = ThemeColor.Black,
    screen = "ScreenTitleMenu",
    icon = ARCADE_ICON
  },
  {
    label = "Battle",
    color = ThemeColor.Blue,
    screen = "ScreenTitleMenu",
    icon = ARCADE_ICON
  },
  {
    label = "Profile",
    screen = "ScreenTitleMenu",
    color = ThemeColor.Blue,
    icon = ARCADE_ICON
  },
  {
    label = "Options",
    screen = "ScreenOptionsService",
    color = ThemeColor.Blue,
    icon = ARCADE_ICON
  },
  {
    label = "Quit",
    screen = "ScreenExit",
    color = ThemeColor.Blue,
    icon = ARCADE_ICON
  },
}

local main_menu = setmetatable({}, main_menu_mt)

return main_menu:create_actors(menu_options)

