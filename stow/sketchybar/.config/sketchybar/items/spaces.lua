local colors = require("colors")
local wm = require("lib.wm.omniwm")

local COUNT = 10

local STYLE = {
  active = { bg = colors.surface0, fg = colors.mauve },
  occupied = { bg = colors.transparent, fg = colors.text },
  empty = { bg = colors.transparent, fg = colors.overlay0 },
}

local slots = {}

for i = 1, COUNT do
  local name = tostring(i)
  slots[i] = {
    state = "empty",
    item = sbar.add("item", "space." .. name, {
      position = "left",
      icon = {
        string = name,
        font = { family = "JetBrainsMono Nerd Font", style = "Bold", size = 13.0 },
        color = STYLE.empty.fg,
        width = 24,
        align = "center",
        padding_left = 0,
        padding_right = 0,
      },
      label = { drawing = false },
      background = {
        color = STYLE.empty.bg,
        corner_radius = 8,
        height = 24,
      },
      padding_left = 2,
      padding_right = 2,
      click_script = wm.focus_cmd(name),
    }),
  }
end

local function apply(state)
  if next(state) == nil then
    return
  end

  for i, slot in ipairs(slots) do
    local ws = state[tostring(i)]
    local key = "empty"
    if ws then
      if ws.focused then
        key = "active"
      elseif ws.occupied then
        key = "occupied"
      end
    end
    if key ~= slot.state then
      slot.state = key
      local style = STYLE[key]
      slot.item:set({
        icon = { color = style.fg },
        background = { color = style.bg },
      })
    end
  end
end

local in_flight, pending = false, false

local function refresh()
  if in_flight then
    pending = true
    return
  end
  in_flight = true
  wm.query(function(state)
    apply(state)
    in_flight = false
    if pending then
      pending = false
      refresh()
    end
  end)
end

wm.start()
slots[1].item:subscribe({ wm.event, "system_woke", "forced" }, refresh)
refresh()
