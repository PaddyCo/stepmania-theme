-- Group
GroupEntryData = {}
GroupEntryData_mt = { __index = GroupEntryData }

function GroupEntryData.create(group_name)
  local self = {}
  setmetatable( self, EntryData_mt )

  self.type = "Group"
  self.title = group_name
  self.color = SONGMAN:GetSongGroupColor(group_name)

  return self
end


-- Song
SongEntryData = {}
SongEntryData_mt = { __index = SongEntryData }

function SongEntryData.create(song, steps)
  local self = {}
  setmetatable( self, EntryData_mt )

  self.type = "Song"
  self.song = song
  self.steps = steps
  self.title = song:GetMainTitle()
  self.color = SONGMAN:GetSongColor(song)
  self.level = steps:GetMeter()
  self.difficulty = steps:GetDifficulty()
  self.all_steps = song:GetStepsByStepsType(steps:GetStepsType())

  self.music_preview  = {
    path = song:GetPreviewMusicPath(),
    sample_start = song:GetSampleStart(),
    sample_length = song:GetSampleLength()
  }
  self.banner = song:GetBannerPath()
  self.jacket = song:GetJacketPath()
  self.score = nil
  self.artist = song:GetDisplayArtist()
  self.group = song:GetGroupName()
  self.subtitle = song:GetDisplaySubTitle()
  self.bpm = table.map(song:GetDisplayBpms(), function(b) return math.floor(b) end)

  -- TODO: Deal with profiles
  local current_profile = PROFILEMAN:GetProfile("PlayerNumber_P1")
  local high_score_list = current_profile:GetHighScoreListIfExists(song, steps)
  local high_scores = high_score_list ~= nil and high_score_list:GetHighScores() or nil
  if high_scores ~= nil and #high_scores > 0 then
    self.score = {}

    -- Get highest score
    local compare_grade = function(a, b)
      return GradeIndex[a:GetGrade()] < GradeIndex[b:GetGrade()]
    end

    local highest_score = table.compare(high_scores, compare_grade)

    self.score.best_score = get_score(steps, highest_score)
    self.score.best_score_rounded = get_score(steps, highest_score, true)
    self.score.best_grade = iif(highest_score:GetGrade() == "Grade_Failed", "E", grade_from_score(self.score.best_score))

    local total_notes = steps:GetRadarValues("PlayerNumber_P1"):GetValue("RadarCategory_TapsAndHolds")

    -- Get lowest miss count
    local combine_misses = function(score)
      local hits = 0

      for i, v in ipairs({ "W3", "W2", "W1" }) do
        hits = hits + score:GetTapNoteScore("TapNoteScore_" .. v)
      end

      return total_notes - hits
    end


    local compare_miss_count = function(a, b)
      return combine_misses(a) < combine_misses(b)
    end

    self.score.miss_count = combine_misses(table.compare(high_scores, compare_miss_count))

    -- Get highest stage award
    local compare_stage_award = function(a, b)
      local a_stage_award = a:GetStageAward()
      local b_stage_award = b:GetStageAward()
      if (a_stage_award == nil) then return false end
      if (b_stage_award == nil) then return true end
      return StageAwardIndex[a_stage_award] > StageAwardIndex[b_stage_award]
    end
    self.score.award = table.compare(high_scores, compare_stage_award):GetStageAward()

    -- Calculate clear lamp state
    if highest_score:GetGrade() == "Grade_Failed" then
      self.clear_lamp = "Failed"
    elseif table.find_index(self.score.award, { "StageAward_FullComboW3", "StageAward_SingleDigitW3", "StageAward_OneW3" }) ~= -1 then
      self.clear_lamp = "FullCombo"
    elseif table.find_index(self.score.award, { "StageAward_FullComboW2", "StageAward_SingleDigitW2", "StageAward_OneW2" }) ~= -1 then
      self.clear_lamp = "PerfectFullCombo"
    elseif self.score.award == "StageAward_FullComboW1" then
      self.clear_lamp = "MarvelousFullCombo"
    else
      self.clear_lamp = "Clear"
    end
  end

  return self
end

function SongEntryData.create_table(songs)
  local charts = {}

  for i, song in ipairs(songs) do
    for i, steps in ipairs(song:GetStepsByStepsType("StepsType_Dance_Single")) do
      charts[#charts+1] = SongEntryData.create(song, steps)
    end
  end

  return charts
end
