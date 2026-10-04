-- OmniWM backend: workspace state + push watcher.
-- Pattern adapted from https://github.com/iluvgirlswithglasses/sketchybar
local watcher = require("lib.watcher")

local M = {}

M.event = "omniwm_workspace_changed"

local OMNIWMCTL = "/opt/homebrew/bin/omniwmctl"
local SKETCHYBAR = "/opt/homebrew/bin/sketchybar"

local WATCH = [[sh -c 'while :; do ]]
  .. OMNIWMCTL
  .. [[ watch active-workspace,windows-changed --reconnect ]]
  .. [[--exec ]]
  .. SKETCHYBAR
  .. [[ --trigger ]]
  .. M.event
  .. [[; ]]
  .. [[sleep 1; done']]

function M.start()
  sbar.add("event", M.event)
  watcher.start("/tmp/sketchybar_omniwm_watch.pid", WATCH, "omniwmctl watch")
end

local QUERY = OMNIWMCTL
  .. " query workspaces | /opt/homebrew/bin/jq -r "
  .. [['.result.payload.workspaces[] | "\(.rawName) \(.counts.total) \(.isCurrent)"']]

-- cb(state) with state[name] = { occupied = bool, focused = bool }.
function M.query(cb)
  sbar.exec(QUERY, function(out)
    local state = {}
    for name, count, focused in tostring(out):gmatch("(%S+) (%d+) (%a+)") do
      state[name] = { occupied = tonumber(count) > 0, focused = focused == "true" }
    end
    cb(state)
  end)
end

function M.focus_cmd(name)
  return OMNIWMCTL .. ' workspace focus-name "' .. name .. '"'
end

return M
