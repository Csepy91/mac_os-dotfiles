local colors = require("colors")

-- Primary Wi-Fi / LAN interface on Apple Silicon Macs.
local IFACE = "en0"

local wifi = sbar.add("item", "wifi", {
  position = "right",
  icon = {
    string = "󰖩",
    font = { family = "Symbols Nerd Font", style = "Regular", size = 14.0 },
    color = colors.teal,
  },
  label = {
    string = "↓0 B/s  ↑0 B/s",
    color = colors.text,
    font = { family = "JetBrainsMono Nerd Font", style = "Semibold", size = 11.0 },
  },
  update_freq = 2,
})

local prev_rx, prev_tx, prev_t = nil, nil, nil

local function human_rate(bytes_per_sec)
  if bytes_per_sec < 1024 then
    return string.format("%dB/s", bytes_per_sec)
  elseif bytes_per_sec < 1024 * 1024 then
    return string.format("%.0fKB/s", bytes_per_sec / 1024)
  elseif bytes_per_sec < 1024 * 1024 * 1024 then
    return string.format("%.1fMB/s", bytes_per_sec / (1024 * 1024))
  end
  return string.format("%.1fGB/s", bytes_per_sec / (1024 * 1024 * 1024))
end

local function update()
  local cmd = "STATUS=$(ifconfig "
    .. IFACE
    .. " 2>/dev/null | awk '/status:/{print $2}'); "
    .. "BYTES=$(netstat -ibn | awk -v iface=\""
    .. IFACE
    .. '\" \'$1==iface && $3 ~ /^<Link/ { print $7, $10; exit }\'); '
    .. 'printf "%s\t%s\n" "${STATUS:-}" "${BYTES:-}"'

  sbar.exec(cmd, function(out)
    local status, rx_s, tx_s = tostring(out):match("([^\t]*)\t(%d+)%s+(%d+)")
    status = status or ""
    local rx = tonumber(rx_s)
    local tx = tonumber(tx_s)
    local now = os.time()
    local connected = status == "active" and rx ~= nil

    if not connected then
      prev_rx, prev_tx, prev_t = nil, nil, nil
      wifi:set({
        icon = { string = "󰖪", color = colors.overlay0 },
        label = { string = "offline", color = colors.overlay0 },
      })
      return
    end

    local down, up = 0, 0
    if prev_rx and prev_tx and prev_t and now > prev_t then
      local dt = now - prev_t
      down = math.max(0, math.floor((rx - prev_rx) / dt))
      up = math.max(0, math.floor((tx - prev_tx) / dt))
    end
    prev_rx, prev_tx, prev_t = rx, tx, now

    wifi:set({
      icon = { string = "󰖩", color = colors.teal },
      label = {
        string = "↓" .. human_rate(down) .. "  ↑" .. human_rate(up),
        color = colors.text,
      },
    })
  end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke", "forced" }, update)
update()
