local M = {}

-- Run `cmd` in the background and keep a singleton via pidfile.
function M.start(pidfile, cmd, match)
  os.execute(
    'pid=$(cat '
      .. pidfile
      .. ' 2>/dev/null) && '
      .. 'ps -p "$pid" -o command= 2>/dev/null | grep -qF -- "'
      .. match
      .. '" && '
      .. '{ pkill -P "$pid"; kill "$pid"; }'
  )
  os.execute("(" .. cmd .. " >/dev/null 2>&1 & echo $! > " .. pidfile .. ")")
end

return M
