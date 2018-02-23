MusicWheelStatsView = {}
MusicWheelStatsView_mt = { __index = MusicWheelStatsView }

function MusicWheelStatsView:create()
  local self = {}

  setmetatable( self, MusicWheelStatsView_mt )

  return self
end

function MusicWheelStatsView:create_actors(params)

end

function MusicWheelStatsView:set_current_entry(entry)
  self.entry = entry
  self.container:queuecommand("Update")
end
