local colors = require("colors")

local app = sbar.add("item", "front_app", {
  position = "left",
  icon = {
    string = "",
    font = { family = "Symbols Nerd Font", style = "Regular", size = 12.0 },
    color = colors.mauve,
    padding_left = 8,
    padding_right = 2,
  },
  label = {
    string = "",
    color = colors.text,
    font = { family = "JetBrainsMono Nerd Font", style = "Bold", size = 12.0 },
    padding_left = 4,
    padding_right = 8,
  },
})

app:subscribe("front_app_switched", function(env)
  app:set({ label = { string = env.INFO } })
end)

sbar.exec('lsappinfo info -only name "$(lsappinfo front)"', function(out)
  local name = tostring(out):match('"LSDisplayName"="(.-)"')
  if name then
    app:set({ label = { string = name } })
  end
end)
