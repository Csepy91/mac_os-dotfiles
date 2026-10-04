local colors = require("colors")

sbar.bar({
  position = "top",
  height = 34,
  color = colors.base,
  border_color = colors.base,
  border_width = 0,
  sticky = true,
  topmost = "window",
  padding_left = 8,
  padding_right = 8,
  y_offset = 0,
  margin = 0,
  shadow = false,
  blur_radius = 0,
})
