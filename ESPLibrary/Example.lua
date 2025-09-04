local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/ESPLibrary/Main.lua"))()

ESPLibrary.ESPAddCategory("Door", Color3.fromRGB(0, 255, 0), true, true)
ESPLibrary.ESPAddCategory("KeyObtain", Color3.fromRGB(255, 255, 255), true, false)

ESPLibrary.ESPAddModel({
    Name = "Door",
    Category = "Door",
    Text = "Door",
    Enabled = true,
    Tracers = true
})

ESPLibrary.ESPAddModel({
    Name = "KeyObtain",
    Category = "KeyObtain",
    Text = "Key",
    Enabled = true,
    Tracers = false
})

ESPLibrary.ESPTables("Misc", {
    KeyObtain = "Key",
    Chest = "Treasure Chest",
    Barrel = "Loot Barrel"
})

ESPLibrary.ESPEnableTables("Misc")
ESPLibrary.ESPDisableTables("Misc")

ESPLibrary.ESPTracers(true)
ESPLibrary.ESPTracers(false)

ESPLibrary.ESPRainbow(true)

ESPLibrary.ESPSettings({
    Font = Enum.Font.SourceSansBold,
    TextSize = 18
})

ESPLibrary.ESPEnableCategory("Door")
ESPLibrary.ESPDisableCategory("KeyObtain")
