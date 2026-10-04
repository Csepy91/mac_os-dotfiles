local colors = require("colors")

local cal = sbar.add("item", "calendar", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "",
    color = colors.mauve,
    font = { family = "JetBrainsMono Nerd Font", style = "Bold", size = 12.0 },
    padding_left = 8,
    padding_right = 8,
  },
  update_freq = 30,
})

local function update()
  cal:set({ label = { string = os.date("%a %d %b  %H:%M") } })
end

cal:subscribe({ "routine", "forced", "system_woke" }, update)
update()
