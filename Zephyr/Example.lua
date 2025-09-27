local Zephyr = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/Zephyr/Zephyr.lua"))()

local Combat = Zephyr:CreateWindow({ Title = "Combat" })

local KillAura = Combat:CreateOption({
    Name = "KillAura",
    DefaultKeybind = "Q",
    Callback = function(enabled)
        print("[Zephyr] KillAura:", enabled)
    end
})

KillAura:CreateToggle({
    Name = "AutoAttack",
    Default = false,
    Callback = function(v)
        print("[Zephyr] AutoAttack:", v)
    end
})

KillAura:CreateSelector({
    Name = "Mode",
    List = { "Single", "Multi", "Hybrid" },
    Default = "Single",
    Callback = function(m)
        print("[Zephyr] Mode:", m)
    end
})

KillAura:CreateSlider({
    Name = "Speed",
    Min = 16,
    Max = 100,
    Default = 16,
    Round = 0,
    Callback = function(val)
        print("[Zephyr] Speed:", val)
    end
})

KillAura:CreateTextbox({
    Name = "Message",
    Default = "",
    Callback = function(t)
        print("[Zephyr] Message:", t)
    end
})

local Other = Zephyr:CreateWindow({ Title = "Other" })

local GodMode = Other:CreateOption({
    Name = "God Mode",
    DefaultKeybind = "P",
    Callback = function(enabled)
        print("[Zephyr] God Mode:", enabled)
    end
})

GodMode:CreateToggle({
    Name = "Auto Dodge",
    Default = false,
    Callback = function(v)
        print("[Zephyr] Auto Dodge:", v)
    end
})
