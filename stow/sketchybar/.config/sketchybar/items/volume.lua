local colors = require("colors")

local volume = sbar.add("item", "volume", {
  position = "right",
  icon = {
    string = "󰕾",
    font = { family = "Symbols Nerd Font", style = "Regular", size = 14.0 },
    color = colors.blue,
  },
  label = {
    string = "??%",
    color = colors.text,
    font = { family = "JetBrainsMono Nerd Font", style = "Semibold", size = 12.0 },
  },
})

local function glyph(v)
  if v == 0 then
    return "󰖁"
  elseif v > 60 then
    return "󰕾"
  elseif v > 30 then
    return "󰖀"
  end
  return "󰕿"
end

local function apply(v)
  volume:set({
    icon = { string = glyph(v) },
    label = { string = v .. "%" },
  })
end

volume:subscribe("volume_change", function(env)
  local v = tonumber(env.INFO)
  if v then
    apply(v)
  end
end)

sbar.exec("osascript -e 'output volume of (get volume settings)'", function(out)
  local v = tonumber(out)
  if v then
    apply(v)
  end
end)
