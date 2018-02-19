MusicWheelScoreView = {}
MusicWheelScoreView_mt = { __index = MusicWheelScoreView }

function MusicWheelScoreView:create()
  local self = {}

  setmetatable( self, MusicWheelScoreView_mt )

  return self
end

function MusicWheelScoreView:create_actors(params)
  local t = Def.ActorFrame {}
end
