local t = Def.ActorFrame{
	Def.Quad{
		InitCommand = function(self)
      self:zoomto(SCREEN_WIDTH*3,SCREEN_HEIGHT*3)
          :diffusealpha(0)
    end,

    StartTransitioningCommand = function(self)
      self:sleep(4)
    end,
	};
};

return t
