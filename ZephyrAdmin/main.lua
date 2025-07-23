if not game:IsLoaded() then
    game.Loaded:Wait()
end

local script = [[
https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/ZephyrAdmin/source.lua
]]

queue_on_teleport(script)
loadstring(script)()
