dofile(THEME:GetPathO("", "music_wheel.lua"))
dofile(THEME:GetPathO("", "entry_data.lua"))

GAMESTATE:LoadProfiles()

local music_wheel = MusicWheel.create(MusicWheelSort.by_difficulty)

return music_wheel:create_actors()
