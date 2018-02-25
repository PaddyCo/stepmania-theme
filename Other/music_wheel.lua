dofile(THEME:GetPathO("", "music_wheel_entry.lua"))
dofile(THEME:GetPathO("", "music_wheel_song_view.lua"))
dofile(THEME:GetPathO("", "entry_data.lua"))
dofile(THEME:GetPathO("", "music_wheel_difficulty_menu.lua"))
dofile(THEME:GetPathO("", "music_wheel_score_view.lua"))

MusicWheel = {}
MusicWheel_mt = { __index = MusicWheel }

-- TODO: Correctly deal with player joining, setting styles etc.
-- This is just a dirty hack for now :)
GAMESTATE:JoinPlayer("PlayerNumber_P1")
GAMESTATE:JoinPlayer("PlayerNumber_P2")
GAMESTATE:SetMultiplayer(false)
GAMESTATE:SetCurrentPlayMode("PlayMode_Regular")
GAMESTATE:SetCurrentStyle(GAMEMAN:GetStylesForGame("dance")[GAMESTATE:GetNumSidesJoined()])

function MusicWheel.create(sort_func)
  local self = {}
  setmetatable( self, MusicWheel_mt )

  self.sort_func = sort_func
  self.current_group = nil

  self.scroller = setmetatable({}, item_scroller_mt)
  self.song_view = MusicWheelSongView:create()
  self.difficulty_menu = MusicWheelDifficultyMenu:create()
  self.score_view = MusicWheelScoreView:create()

  return self
end

function MusicWheel:create_actors()
  local t = Def.ActorFrame {
    InitCommand = function(subself)
      self.container = subself
    end,

    UpdateCommand = function(subself)
      subself:stoptweening()
      :linear(0.05)
      :x(self.is_focused and -50 or 0)
    end,

    StartSongCommand = function(subself)
      subself:sleep(0.5)
             :queuecommand("ActuallyStartSong")
    end,

    ActuallyStartSongCommand = function(subself)
      SCREENMAN:SetNewScreen("ScreenPrepare")
    end
  }


  t[#t+1] = self.difficulty_menu:create_actors()

  t[#t+1] = self.score_view:create_actors()

  t[#t+1] = self.scroller:create_actors("Entry", 26, MusicWheelEntry_mt, SCREEN_CENTER_X + 128, -293)

  t[#t+1] = self.song_view:create_actors()

  t[#t+1] = Def.BitmapText {
    Font = "Common Header",
    InitCommand = function(subself)
      subself:settext("Select Music")
             :halign(0)
             :valign(0)
             :x(16)
             :y(16)
             :zoom(0.25)
             :diffuse(ThemeColor.Black)
    end
  }

  t[#t+1] = Def.BitmapText {
    Font = "Common Header",
    InitCommand = function(subself)
      subself:settext(THEME:GetString("Stage", GAMESTATE:GetCurrentStage()))
             :halign(0)
             :valign(0)
             :x(12)
             :y(48)
             :zoom(0.5)
             :diffuse(ThemeColor.Black)
    end
  }

  t[#t+1] = Def.Actor {
    OnCommand = function(subself)
      if (GAMESTATE:GetCurrentSong() ~= nil) then
        self.current_group = GAMESTATE:GetCurrentSong():GetGroupName()
      end

      self:update_data(1)

      local current_steps = GAMESTATE:GetCurrentSteps("PlayerNumber_P1")
      if current_steps ~= nil then
        self:scroll_to_steps(GAMESTATE:GetCurrentSteps("PlayerNumber_P1"))
      end
      self:update("Update")
      focused_wheel = self -- I don't know a good way to get the music wheel to the input callback!
      SCREENMAN:GetTopScreen():AddInputCallback(self.handle_input)
    end
  }

  return t
end

function MusicWheel:update_data(focus_index)
  self.scroller:set_info_set(self:get_entries(), focus_index)
end

function MusicWheel:get_entries()
  -- Get song groups
  local entries = table.map(SONGMAN:GetSongGroupNames(), GroupEntryData.create)

  if self.current_group ~= nil then
    local current_group_index = self:get_group_index(self.current_group)

    local songs = SongEntryData.create_table(SONGMAN:GetSongsInGroup(self.current_group))
    table.sort(songs, self.sort_func)
    entries = table.insert_table(entries, songs, current_group_index)
  end

  return entries
end

function MusicWheel:update(command)
  local current_entry = self.scroller:get_info_at_focus_pos()
  self.song_view:set_current_entry(current_entry)
  self.difficulty_menu:set_current_entry(current_entry)
  self.score_view:set_current_entry(current_entry)
  self.container:queuecommand(command)
end

function MusicWheel:open_group(group_name)
  SOUND:PlayOnce(THEME:GetPathS("MusicWheel", "Open"), true)
  self.container:queuecommand("OpenGroup")
  self.current_group = group_name
  self:update_data(self:get_group_index(group_name))
end

function MusicWheel:close_group()
  if (self.current_group == nil) then return end
  SOUND:PlayOnce(THEME:GetPathS("MusicWheel", "Close"), true)

  new_index = self:get_group_index(self.current_group)
  self.current_group = nil
  self:update_data(new_index)

  SOUND:StopMusic()

  self:update("CloseGroup")
end

function MusicWheel:get_group_index(group_name)
  return table.find_index(group_name, SONGMAN:GetSongGroupNames())
end

function MusicWheel:sort(sort_func)
  self.sort_func = sort_func
end

function MusicWheel:scroll(amount)
  self.scroller:scroll_by_amount(amount)

  SOUND:PlayOnce(THEME:GetPathS("Common", "value"), true)

  SOUND:StopMusic()

  self:update(math.abs(amount) == 1 and "Scroll" or "PageSwitch")
end

function MusicWheel:scroll_difficulty(amount)
  local current_entry = self.scroller:get_info_at_focus_pos()
  if current_entry.type == "Song" then
    local data = table.map(current_entry.all_steps, function(steps) return SongEntryData.create(current_entry.song, steps) end)
    table.sort(data, function(a, b) return DifficultyIndex[a.difficulty] < DifficultyIndex[b.difficulty] end)
    local current_difficulty_index = table.find_index(current_entry.difficulty, table.map(data, function(e) return e.difficulty end))
    if current_difficulty_index+amount > #data or current_difficulty_index+amount < 1 then
      return
    end

    self:scroll_to_steps(data[current_difficulty_index+amount].steps)
  end
end

function MusicWheel:scroll_to_steps(steps)
  for i, v in ipairs(self.scroller.info_set) do
    if v.steps == steps then
      self.scroller:scroll_to_pos(i)
      self:update("PageSwitch")
    end
  end
end

function MusicWheel.handle_input(event)
  local self = focused_wheel

  if self.ignore_input then return end

  -- Ignore release event
  if event.type == "InputEventType_Release" then return end

  local double_tap = false
  if self.last_press ~= nil and event.type == "InputEventType_FirstPress" and self.last_press.button == event.GameButton and self.last_press.time + 0.3 >= GetTimeSinceStart() then
    double_tap = true
    self.last_press = nil
  else
    self.last_press = {
      time = GetTimeSinceStart(),
      button = event.GameButton
    }
  end

  if event.GameButton == "Start" then
    if event.type ~= "InputEventType_FirstPress" then return end
    local current_entry = self.scroller:get_info_at_focus_pos()

    if current_entry.type == "Group" then
      if self.current_group ~= current_entry.title then
        self:open_group(current_entry.title)
      else
        self:close_group()
      end
    elseif current_entry.type == "Song" then
      SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)

      -- TODO: Correctly deal with player joining, setting styles etc.
      -- This is just a dirty hack for now :)
      GAMESTATE:SetCurrentSong(current_entry.song)
      SOUND:StopMusic()
      GAMESTATE:SetCurrentSteps("PlayerNumber_P1", current_entry.steps)
      GAMESTATE:SetCurrentSteps("PlayerNumber_P2", current_entry.steps)
      PREFSMAN:SetPreference("BGBrightness", 1)

      local can, reason = GAMESTATE:CanSafelyEnterGameplay()
      if can then
        self.ignore_input = true
        self.container:queuecommand("StartSong")
      else
        lua.ReportScriptError("Cannot safely enter gameplay: " .. tostring(reason))
      end
    end
  elseif event.GameButton == "Back" then
    if event.type ~= "InputEventType_FirstPress" then return end
    if self.current_group == nil then
      -- if at root, go back to main menu
      SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)
      SCREENMAN:SetNewScreen("ScreenTitleMenu")
    else
      -- if in group, close group
      self:close_group()
    end
  elseif event.GameButton == "MenuLeft" then
    self:scroll(-1)
  elseif event.GameButton == "MenuRight" then
    self:scroll(1)
  elseif event.GameButton == "MenuDown" and double_tap then
    self:scroll_difficulty(1)
  elseif event.GameButton == "MenuUp" and double_tap then
    self:scroll_difficulty(-1)
  end
end

