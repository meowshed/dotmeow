-- ~/.hammerspoon/init.lua — managed by dotmeow
-- https://github.com/meowshed/dotmeow

-- Enables `hs -c "..."` from any terminal (hs.ipc provides the CLI bridge).
require("hs.ipc")

-- Reload config on file change
local function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end

local configWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configWatcher:start()

-- startSpoon is a global so dofile(local.lua) can call it.
-- Example in local.lua:  startSpoon("MiroWindowsManager")
function startSpoon(name)
    local ok, errOrSpoon = pcall(hs.loadSpoon, name)
    if not ok then
        hs.printf("Failed to load Spoon %s: %s", name, tostring(errOrSpoon))
        return
    end

    local mod = spoon[name]
    if not mod then
        hs.printf("Loaded Spoon %s but module is nil", name)
        return
    end

    if type(mod.start) == "function" then
        mod:start()
    elseif type(mod.init) == "function" then
        mod:init()
    else
        hs.printf("Spoon %s has neither start() nor init()", name)
    end
end

-- Personal extensions (loaded last; provided by personal dotfiles layer).
local localPath = hs.configdir .. "/local.lua"
if hs.fs.attributes(localPath) then
    dofile(localPath)
end

-- hs.alert is transient and non-stacking; avoids notification pile-up on
-- frequent auto-reloads triggered by configWatcher file-change events.
hs.alert.show("Hammerspoon: config loaded")
