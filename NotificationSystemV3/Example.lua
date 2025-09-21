local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/NotificationSystemV3/Main.lua"))()

Notification("Notification without sound", 5)
wait(1)
Notification("Notification with sound", 5, SoundID)
