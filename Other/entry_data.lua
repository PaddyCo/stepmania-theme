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
  self.title = song:GetMainTitle()
  self.color = SONGMAN:GetSongColor(song)
  self.difficulty = steps:GetDifficulty()
  self.music_preview  = {
    path = song:GetPreviewMusicPath(),
    sample_start = song:GetSampleStart(),
    sample_length = song:GetSampleLength()
  }
  self.banner = song:GetBannerPath()
  self.jacket = song:GetJacketPath()
  self.level = steps:GetMeter()
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

    -- Get highest grade
    local compare_grade = function(a, b)
      return GradeIndex[a:GetGrade()] < GradeIndex[b:GetGrade()]
    end
    self.score.grade = table.compare(high_scores, compare_grade):GetGrade()

    -- Get highest stage award
    local compare_stage_award = function(a, b)
      local a_stage_award = a:GetStageAward()
      local b_stage_award = b:GetStageAward()
      if (a_stage_award == nil) then return false end
      if (b_stage_award == nil) then return true end
      return StageAwardIndex[a_stage_award] > StageAwardIndex[b_stage_award]
    end
    self.score.award = table.compare(high_scores, compare_stage_award):GetStageAward()
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
