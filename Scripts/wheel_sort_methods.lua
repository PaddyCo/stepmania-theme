MusicWheelSort = {}

function MusicWheelSort.by_difficulty(a, b)
  if (a.level == b.level) then return a.title < b.title
  else return a.level < b.level end
end
