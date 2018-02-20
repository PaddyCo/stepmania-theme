MusicWheelSort = {}

function MusicWheelSort.by_difficulty(a, b)
  if (a.level == b.level and a.title == b.title) then
    -- For rare cases where stepfile author has set the same difficulty to multiple
    -- stepcharts, make sure they are in difficulty order at least
    return DifficultyIndex[a.difficulty] < DifficultyIndex[b.difficulty]
  elseif a.level == b.level then
    -- If the levels are same, sort by title
    return a.title < b.title
  else
    -- Otherwise, sort on level
    return a.level < b.level
  end

end
