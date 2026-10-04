local colors = require("colors")

local font_text = "JetBrainsMono Nerd Font"
local font_icon = "Symbols Nerd Font"

sbar.default({
  updates = "when_shown",
  icon = {
    font = { family = font_icon, style = "Regular", size = 14.0 },
    color = colors.text,
    padding_left = 4,
    padding_right = 4,
  },
  label = {
    font = { family = font_text, style = "Semibold", size = 12.0 },
    color = colors.text,
    padding_left = 4,
    padding_right = 4,
  },
  background = {
    color = colors.transparent,
    corner_radius = 8,
    height = 24,
  },
  padding_left = 4,
  padding_right = 4,
  scroll_texts = true,
})
