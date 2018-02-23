function ddr_score_from_score(score)
  return math.floor(score / 100)
end

-- Recalculate the score to use DDR A style calculations
-- Special thanks to Aaron C for his good documentation on various DDR scoring systems (http://aaronin.jp/ddrssystem.html#ss10)
function get_score(steps, score, rounded)
    local style = stepstype_to_style[steps:GetStepsType()][1]

    -- Don't know why this needs a player index? Whatever here you go :)
    local total_notes_and_holds = steps:GetRadarValues("PlayerNumber_P1"):GetValue("RadarCategory_TapsAndHolds")

    -- Since mines are basically the shock arrow equilevent in StepMania, I count them instead.
    -- But since a shock arrow in DDR always covers all columns and counts as one,
    -- I have to divide the number of mines with the amount of columns to make scoring on DDR songs
    -- equivalent to the arcade version. This might make the scoring ~slightly~ off for stepmania songs
    local total_mines = steps:GetRadarValues("PlayerNumber_P1"):GetValue("RadarCategory_Mines") / style.columns_per_player

    -- Calculate the step score
    local step_score = 1000000 / (total_notes_and_holds + total_mines)

    -- Judgement points
    local tap_judgements = {
      { type = "W1", value = step_score },
      { type = "W2", value = step_score - 10 },
      { type = "W3", value = (step_score * 0.6) - 10 },
      { type = "W4", value = (step_score * 0.2) - 10 },
      { type = "AvoidMine", value = step_score / style.columns_per_player },
    }

    -- Calculate actual score
    local actual_score = 0
    local scores = {}

    for i, v in ipairs(tap_judgements) do
      actual_score = actual_score + (score:GetTapNoteScore("TapNoteScore_" .. v.type) * v.value)
    end

    return rounded and math.floor(actual_score/10) * 10 or actual_score
end

function grade_from_score(score)
  if (score > 989990) then return "AAA"
  elseif (score > 949990) then return "AA+"
  elseif (score > 899990) then return "AA"
  elseif (score > 889990) then return "AA-"
  elseif (score > 849990) then return "A+"
  elseif (score > 799990) then return "A"
  elseif (score > 789990) then return "A-"
  elseif (score > 749990) then return "B+"
  elseif (score > 699990) then return "B"
  elseif (score > 689990) then return "B-"
  elseif (score > 649990) then return "C+"
  elseif (score > 599990) then return "C"
  elseif (score > 589990) then return "C-"
  elseif (score > 549990) then return "D+"
  else return "D" end
end










