local NotificationSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/NotificationSystemV3/Main.lua"))()
local Notification = NotificationSystem.Notification

Notification("Notification without sound", 5)
wait(1)
Notification("Notification with sound", 5, 91882565)
