dofile(THEME:GetPathO("", "music_wheel_entry.lua"))
dofile(THEME:GetPathO("", "entry_data.lua"))

MusicWheel = {}
MusicWheel_mt = { __index = MusicWheel }

function MusicWheel.create(sort_func)
  local self = {}
  setmetatable( self, MusicWheel_mt )

  self.sort_func = sort_func
  self.current_group = nil
  -- Attach an item_scroller
  self.scroller = setmetatable({}, item_scroller_mt)

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
  }

  t[#t+1] = self.scroller:create_actors("Entry", 26, MusicWheelEntry_mt, SCREEN_CENTER_X, -293)

  t[#t+1] = Def.Actor {
    OnCommand = function(subself)
      self:update_data(1)
      focused_wheel = self -- I don't know a good way to get the music wheel to the input callback!
      SCREENMAN:GetTopScreen():AddInputCallback(self.handle_input)
    end
  }

  return t
end

function MusicWheel:update_data(focus_index)
  self.scroller:set_info_set(self:get_entries(), focus_index)
  self:update()
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

function MusicWheel:update()
 -- self.container:queuecommand("Update")
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
  self.container:queuecommand("CloseGroup")

  new_index = self:get_group_index(self.current_group)
  self.current_group = nil
  self:update_data(new_index)
end

function MusicWheel:get_group_index(group_name)
  return table.find_index(group_name, SONGMAN:GetSongGroupNames())
end

function MusicWheel:sort(sort_func)
  self.sort_func = sort_func
end

function MusicWheel:scroll(amount)
  self.scroller:scroll_by_amount(amount)

  if math.abs(amount) == 1 then
    self.container:queuecommand("Scroll")
  else
    self.container:queuecommand("PageSwitch")
  end

  SOUND:PlayOnce(THEME:GetPathS("Common", "value"), true)
end

function MusicWheel.handle_input(event)
  local self = focused_wheel

  -- Ignore release event
  if event.type == "InputEventType_Release" then return end

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
      SM(current_entry)
    end
  elseif event.GameButton == "Back" then
    if self.current_group == nil then
      -- if at root, go back to main menu
      SOUND:PlayOnce(THEME:GetPathS("Common", "Start"), true)
      SCREENMAN:SetNewScreen("ScreenTitleMenu")
    else
      -- if in group, close group
      self:close_group()
    end
  elseif event.GameButton == "MenuDown" then
    self:scroll(1)
    self:update()
  elseif event.GameButton == "MenuUp" then
    self:scroll(-1)
    self:update()
  elseif event.GameButton == "MenuLeft" then
    self:scroll(-5)
    self:update()
  elseif event.GameButton == "MenuRight" then
    self:scroll(5)
    self:update()
  end
end

