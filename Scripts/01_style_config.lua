-- Shoutouts to the consensual theme for the following code (slightly altered)
local game_name = GAMESTATE:GetCurrentGame():GetName()
local styles_for_game = GAMEMAN:GetStylesForGame(game_name)

stepstype_to_style = {}

for i, style in ipairs(styles_for_game) do
  local stepstype = style:GetStepsType()
  local stame = style:GetName()
  local stype = style:GetStyleType()
  -- Why is couple-edit marked as OnePlayerTwoSides?  I'm throwing it out as
  -- unsupported rather than trying to write special case code for it.
  if stame == "couple-edit" then return end
  if stame == "couple" then return end

  if not stepstype_to_style[stepstype] then
    stepstype_to_style[stepstype] = {}
  end

  local for_players = 1
  local for_sides = 1

  if stype:find("TwoPlayers") then for_players = 2 end

  if stype:find("TwoSides") then for_sides = 2 end

  if stype:find("SharedSides") then for_sides = 2 end

  stepstype_to_style[stepstype][for_players] = {
    name = stame,
    stype = stype,
    steps_type = stepstype,
    for_players = for_players,
    for_sides = for_sides,
    columns_per_player = style:ColumnsPerPlayer()
  }
end
