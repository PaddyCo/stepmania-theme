local scroller = setmetatable({ disable_wrapping = false }, item_scroller_mt)
local t = Def.ActorFrame {}
local song_containers = {}

-- TODO: Deal with profiles
GAMESTATE:LoadProfiles()
local current_profile = PROFILEMAN:GetProfile("PlayerNumber_P1")

local sort_by_level = function(a, b)
  if (a.level == b.level) then return a.title < b.title
  else return a.level < b.level end
end

local convert_groups_to_entries = function(group_name)
  return {
    type = "Group",
    title = group_name,
    color = SONGMAN:GetSongGroupColor(group_name),
  }
end

local convert_songs_to_entries = function(songs)
  local charts = {}

  for si, song in ipairs(songs) do
    for i, chart in ipairs(song:GetStepsByStepsType("StepsType_Dance_Single")) do
      local entry = {
        type = "Song",
        title = song:GetMainTitle(),
        color = SONGMAN:GetSongColor(song),
        difficulty = chart:GetDifficulty(),
        level = chart:GetMeter(),
        score = nil,
      }


      local high_score_list = current_profile:GetHighScoreListIfExists(song, chart)
      local high_scores = high_score_list ~= nil and high_score_list:GetHighScores() or nil
      if high_scores ~= nil and #high_scores > 0 then
        entry.score = {}

        -- Get highest grade
        local compare_grade = function(a, b)
          return GradeIndex[a:GetGrade()] < GradeIndex[b:GetGrade()]
        end
        entry.score.grade = table.compare(high_scores, compare_grade):GetGrade()

        -- Get highest stage award
        local compare_stage_award = function(a, b)
          local a_stage_award = a:GetStageAward()
          local b_stage_award = b:GetStageAward()
          if (a_stage_award == nil) then return false end
          if (b_stage_award == nil) then return true end
          return StageAwardIndex[a_stage_award] > StageAwardIndex[b_stage_award]
        end
        entry.score.award = table.compare(high_scores, compare_stage_award):GetStageAward()
      end

      charts[#charts+1] = entry
    end
  end

  table.sort(charts, sort_by_level)
  return charts
end

local get_group_index = function(group_name)
  return table.find_index(group_name, SONGMAN:GetSongGroupNames())
end

local get_entries = function(group_name)
  -- Get song groups
  local entries = table.map(SONGMAN:GetSongGroupNames(), convert_groups_to_entries)

  if (group_name ~= nil) then
    local current_group_index = get_group_index(group_name)

    for i, v in ipairs(convert_songs_to_entries(SONGMAN:GetSongsInGroup(group_name))) do
      table.insert(entries, current_group_index+i, v)
    end
  end

  return entries
end


local entry_mt = {
  __index = {
    create_actors = function(self, params)
      return Def.ActorFrame {
        Name = name,
        InitCommand = function(subself)
          self.container = subself
          song_containers[#song_containers+1] = subself
          self.entry = nil
        end,

        UpdateCommand = function(subself)
        end,

        Def.ActorFrame {
          UpdateCommand = function(subself)
            subself:stoptweening()
                   :linear(0.05)
                   :x(self.is_focused and -50 or 0)
          end,

          Def.Quad {
            InitCommand = function(subself)
              subself:diffuse(Alpha(ThemeColor.Black, 0.2))
                     :zoomto(SCREEN_WIDTH/2 + 128, 62)
                     :y(1)
                     :halign(0)
            end,

            UpdateCommand = function(subself)
              subself:stoptweening()
                     :linear(0.2)
                     :diffuseleftedge(self.is_focused and Alpha(ThemeColor.Red, 0.8) or Alpha(ThemeColor.Black, 0.8))
            end
          },

          Def.Quad {
            Name = "Clear Lamp",
            InitCommand = function(subself)
              subself:zoomto(8, 62)
                     :y(1)
                     :visible(false)
                     :halign(0)
            end,

            UpdateCommand = function(subself)
              -- TODO: Fix flashing lights being stuck during scrolling
              -- and make them all sync with a global timer or something
              subself:stoptweening()
              if (self.entry.type == "Song") then
                subself:visible(true)
                       :diffuse(ThemeColor.Black)

                if (self.entry.score == nil) then
                  -- No play
                  return
                end

                if (self.entry.score.grade == "Grade_Failed") then
                  -- Failed
                  subself.flash_speed = 0.2
                  subself.flash_colors = { ThemeColor.Red, ThemeColor.Black }
                  subself:queuecommand("Flash")
                elseif table.find_index(self.entry.score.award, { "StageAward_FullComboW3", "StageAward_SingleDigitW3", "StageAward_OneW3" }) ~= -1 then
                  -- Full Combo Clear
                  subself.flash_speed = 0.1
                  subself.flash_colors = { ThemeColor.Blue, ThemeColor.Yellow, ThemeColor.White }
                  subself:queuecommand("Flash")
                elseif table.find_index(self.entry.score.award, { "StageAward_FullComboW2", "StageAward_SingleDigitW2", "StageAward_OneW2" }) ~= -1 then
                  -- Perfect Full Combo Clear
                  subself.flash_speed = 0.06
                  subself.flash_colors = { ThemeColor.Red, ThemeColor.Yellow, ThemeColor.White, ThemeColor.Green }
                  subself:queuecommand("Flash")
                elseif self.entry.score.award == "StageAward_FullComboW1" then
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
            end
          },

          Def.BitmapText {
            Font = "Common Normal",
            InitCommand = function(subself)
              subself:diffuse(ThemeColor.White)
                     :shadowcolor(ThemeColor.Black)
                     :shadowlength(1)
                     :halign(0)
            end,

            UpdateCommand = function(subself)
              subself:settext(self.entry.title)
                     :x(self.entry.type == "Song" and 64+16 or 16)
            end
          },

          Def.BitmapText {
            Name = "Difficulty Level",
            Font = "Common Normal",
            InitCommand = function(subself)
              subself:diffuse(ThemeColor.White)
                     :x(45)
                     :visible(false)
                     :shadowcolor(ThemeColor.Black)
                     :shadowlength(1)
                     :horizalign("HorizAlign_Center")
            end,

            UpdateCommand = function(subself)
              if (self.entry.type == "Song") then
                subself:settext(self.entry.level)
                       :diffuse(DifficultyColors[self.entry.difficulty])
                       :visible(true)
              else
                subself:visible(false)
              end
            end
          },

        },

      }
    end,

    transform = function(self, item_index, num_items, is_focus)
      if (self.last_index == nil) then self.last_index = item_index end
      self.is_focused = is_focus

      if ((item_index < num_items-1 and item_index > 2) and (item_index == self.last_index+1 or item_index == self.last_index-1)) then
        self.container:stoptweening()
                      :linear(0.1)
                      :y(item_index * 64)
      else
        self.container:y(item_index * 64)
      end

      self.last_index = item_index
    end,

    set = function(self, song)
      self.entry = song
      self.container:queuecommand("Update")
    end,
  }
}

local update = function()
  SOUND:PlayOnce(THEME:GetPathS("Common", "value"), true)
  for i, song_container in ipairs(song_containers) do
    song_container:queuecommand("Update")
  end
end

local close_group = function()
  local current_group = scroller.current_group

  SOUND:PlayOnce(THEME:GetPathS("MusicWheel", "Close"), true)
  scroller.current_group = nil
  scroller:set_info_set(get_entries(), get_group_index(current_group))
end

local handle_input = function(event)
  -- Ignore release event
  if event.type == "InputEventType_Release" then return end

  if event.GameButton == "Start" then
    local current_entry = scroller:get_info_at_focus_pos()

    if current_entry.type == "Group" then
      if scroller.current_group ~= current_entry.title then
        -- Open group
        SOUND:PlayOnce(THEME:GetPathS("MusicWheel", "Open"), true)
        scroller.current_group = current_entry.title
        scroller:set_info_set(get_entries(current_entry.title), get_group_index(current_entry.title))
      else
        -- Close group
        close_group()
      end
    elseif current_entry.type == "Song" then
      SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)
      SM(current_entry)
    end
  end
  if event.GameButton == "Back" then
    if scroller.current_group == nil then
      -- if at root, go back to main menu
      SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)
      SCREENMAN:SetNewScreen("ScreenTitleMenu")
    else
      -- if in group, close group
      close_group()
    end
  end
  if event.GameButton == "MenuDown" then
    scroller:scroll_by_amount(1)
    update()
  end
  if event.GameButton == "MenuUp" then
    scroller:scroll_by_amount(-1)
    update()
  end
  if event.GameButton == "MenuLeft" then
    scroller:scroll_by_amount(-5)
    update()
  end
  if event.GameButton == "MenuRight" then
    scroller:scroll_by_amount(5)
    update()
  end
end


t[#t+1] = scroller:create_actors("Entry", 26, entry_mt, SCREEN_CENTER_X, -292)

-- Really dumb hack, if I do this outside an actors InitCommand
-- it will run before the actors have ben initialized
t[#t+1] = Def.Actor {
  InitCommand = function(self)
    scroller:set_info_set(get_entries(), 1)
  end,

  OnCommand = function(self)
    SCREENMAN:GetTopScreen():AddInputCallback(handle_input)
  end
}

return t
