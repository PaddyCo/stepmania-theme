-- Arcade icon
local arcade_frame_delay = 0.1
ARCADE_ICON = {
  texture = "../Graphics/_Icons/Arcade 5x1.png",
  frames = {
    inactive = {
      { Frame = 0, Delay = 100 }
    },
    active = {
      { Frame = 0, Delay = 1 },
      { Frame = 1, Delay = arcade_frame_delay },
      { Frame = 2, Delay = arcade_frame_delay },
      { Frame = 3, Delay = arcade_frame_delay },
      { Frame = 4, Delay = arcade_frame_delay },
      { Frame = 1, Delay = arcade_frame_delay },
      { Frame = 2, Delay = arcade_frame_delay },
      { Frame = 3, Delay = arcade_frame_delay },
      { Frame = 4, Delay = arcade_frame_delay },
      { Frame = 1, Delay = arcade_frame_delay },
    }
  }
}

-- Course Icon
local course_frame_delay = 0.05
COURSE_ICON = {
  texture = "../Graphics/_Icons/Course 4x5.png",
  frames = {
    inactive = {
      { Frame = 0, Delay = 100 },
    },
    active = {
      { Frame = 0, Delay = 1 },
      { Frame = 1, Delay = course_frame_delay },
      { Frame = 2, Delay = course_frame_delay },
      { Frame = 3, Delay = course_frame_delay },
      { Frame = 4, Delay = course_frame_delay },
      { Frame = 5, Delay = course_frame_delay },
      { Frame = 6, Delay = course_frame_delay },
      { Frame = 7, Delay = course_frame_delay },
      { Frame = 8, Delay = course_frame_delay },
      { Frame = 9, Delay = course_frame_delay },
      { Frame = 10, Delay = course_frame_delay },
      { Frame = 11, Delay = course_frame_delay },
      { Frame = 12, Delay = course_frame_delay },
      { Frame = 13, Delay = course_frame_delay },
      { Frame = 14, Delay = course_frame_delay },
      { Frame = 15, Delay = course_frame_delay },
      { Frame = 16, Delay = course_frame_delay },
      { Frame = 17, Delay = course_frame_delay },
      { Frame = 18, Delay = course_frame_delay },
      { Frame = 19, Delay = 1 },
      { Frame = 9, Delay = course_frame_delay },
      { Frame = 8, Delay = course_frame_delay },
      { Frame = 7, Delay = course_frame_delay },
      { Frame = 6, Delay = course_frame_delay },
      { Frame = 5, Delay = course_frame_delay },
      { Frame = 4, Delay = course_frame_delay },
      { Frame = 3, Delay = course_frame_delay },
      { Frame = 2, Delay = course_frame_delay },
      { Frame = 1, Delay = course_frame_delay }
    },
  }
}
