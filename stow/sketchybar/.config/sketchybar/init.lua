sbar = require("sketchybar")

sbar.begin_config()
require("bar")
require("defaults")
-- Left
require("items.spaces")
require("items.front_app")
-- Right (added outermost-first: calendar is far right)
require("items.calendar")
require("items.battery")
require("items.volume")
require("items.wifi")
sbar.end_config()

sbar.event_loop()
