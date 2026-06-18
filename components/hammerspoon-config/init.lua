-- ~/.hammerspoon/init.lua — managed by dotmeow
-- https://github.com/meowshed/dotmeow
--
-- Dependencies (install via meowctl):
--   - adaptive-keyboard-layouts  (meowshed/adaptive-keyboard-layouts)
--   - zjstatus-widgets           (meowshed/zjstatus-widgets)
--   - meowvim-keyboard-layouts   (meowshed/meowvim-keyboard-layouts)

-- hs.ipc: enables `hs -c "..."` CLI from terminal (required by zellij integration)
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

function startSpoon(name)
    local ok, loadErr = pcall(hs.loadSpoon, name)
    if not ok then
        hs.printf("Failed to load Spoon %s: %s", name, tostring(loadErr))
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

-- ZJStatus widgets (zellij status bar integration)
startSpoon("ZJStatusWidgets")

-- Personal extensions (loaded last; provided by personal dotfiles layer).
local localPath = hs.configdir .. "/local.lua"
if hs.fs.attributes(localPath) then
    dofile(localPath)
end

hs.notify.new({ title = "Hammerspoon", informativeText = "Config loaded" }):send()
