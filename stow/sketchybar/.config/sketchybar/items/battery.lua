local colors = require("colors")

local battery = sbar.add("item", "battery", {
  position = "right",
  icon = {
    string = "󰁹",
    font = { family = "Symbols Nerd Font", style = "Regular", size = 14.0 },
    color = colors.green,
  },
  label = {
    string = "??%",
    color = colors.text,
    font = { family = "JetBrainsMono Nerd Font", style = "Semibold", size = 12.0 },
  },
  update_freq = 120,
})

local function glyph(pct, on_ac)
  if on_ac then
    return "󰂄"
  end
  if pct >= 90 then
    return "󰁹"
  elseif pct >= 70 then
    return "󰂁"
  elseif pct >= 50 then
    return "󰁾"
  elseif pct >= 30 then
    return "󰁽"
  elseif pct >= 15 then
    return "󰁻"
  end
  return "󰁺"
end

local function update()
  sbar.exec("pmset -g batt", function(out)
    local pct = tonumber(out:match("(%d+)%%"))
    if not pct then
      battery:set({ drawing = false })
      return
    end
    local on_ac = out:find("AC Power") ~= nil
    local color = colors.green
    if pct < 20 and not on_ac then
      color = colors.red
    elseif pct < 40 and not on_ac then
      color = colors.yellow
    end
    battery:set({
      drawing = true,
      icon = { string = glyph(pct, on_ac), color = color },
      label = { string = pct .. "%" },
    })
  end)
end

battery:subscribe({ "routine", "forced", "power_source_change", "system_woke" }, update)
update()
