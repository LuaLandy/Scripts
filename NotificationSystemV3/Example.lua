local NotificationSystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/NotificationSystemV3/Main.lua"))()
local Notification = NotificationSystem.Notification

Notification("Notification without sound", 5, nil, false)
wait(1)
Notification("Notification with sound", 5, 91882565, false)
wait(1)
Notification("RGB Notification", 5, nil, true)
wait(1)
Notification("Custom Bar Color", 5, nil, false, Color3.fromRGB(0, 255, 0))
