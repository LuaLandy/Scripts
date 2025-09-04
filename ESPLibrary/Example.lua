local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/ESPLibrary/Main.lua"))()

ESP.ESPAddCategory("Doors", Color3.fromRGB(255, 255, 255), true, true)
ESP.ESPAddCategory("Entities", Color3.fromRGB(255, 0, 0), true, true)
ESP.ESPAddCategory("BaseplateESP", Color3.fromRGB(255, 255, 0), true, false)

ESP.ESPAddModel({
    Name = "Baseplate",
    Path = workspace,
    Text = "Baseplate thing",
    Category = "BaseplateESP"
})

ESP.ESPAddModel({
    Name = "Door",
    Path = workspace,
    Text = "Door ESP",
    Category = "Doors"
})

local entities = {Baseplate="Baseplate", EnemyNumberOne="Enemy #1", SpookyMonster="Monster"}
for name,label in pairs(entities) do
    local obj = workspace:FindFirstChild(name)
    if obj then
        ESP.ESPAddModel({
            Name = name,
            Path = workspace,
            Text = label,
            Category = "Entities"
        })
    end
end

ESP.ESPUpdateColor({
    Name = "Door",
    Path = workspace,
    Color = Color3.fromRGB(0, 255, 0)
})

ESP.ESPRemoveModel({
    Name = "Door",
    Path = workspace
})

ESP.ESPRainbow(true)

ESP.ESPTracers(true)

ESP.ESPSettings({
    Font = Enum.Font.FredokaOne,
    TextSize = 22
})
