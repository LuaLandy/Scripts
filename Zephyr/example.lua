local Zephyr = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/Zephyr/zephyr.lua"))()

local Combat = Zephyr:CreateWindow({ Name = "Combat" })

local KillAura = Combat:CreateOptionsButton({
    Name = "KillAura",
    Default = false,
    Function = function(enabled) print("KillAura toggled:", enabled) end,
    DefaultKeybind = "Q"
})

KillAura:CreateToggle({
    Name = "AutoAttack",
    Default = true,
    Function = function(enabled) print("AutoAttack:", enabled) end
})

KillAura:CreateSelector({
    Name = "Mode",
    List = {"Single", "Multi", "Hybrid"},
    Default = "Single",
    Function = function(mode) print("Mode selected:", mode) end
})

KillAura:CreateSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Round = 0,
    Function = function(value)
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = value
        end
    end
})

KillAura:CreateTextbox({
    Name = "Message",
    Default = "",
    Function = function(text) print("Message set to:", text) end
})

local Other = Zephyr:CreateWindow({ Name = "Other" })

local GodMode = Other:CreateOptionsButton({
    Name = "God Mode",
    Default = false,
    Function = function(enabled) print("God Mode toggled:", enabled) end,
    DefaultKeybind = "P"
})

GodMode:CreateToggle({
    Name = "Auto Dodge",
    Default = true,
    Function = function(enabled) print("Auto Dodge", enabled) end
})
