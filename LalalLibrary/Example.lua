local LalalLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/LalalLibrary/LalalLibrary.lua"))()

local Window = LalalLibrary:CreateWindow("Example Library", {
    Colors = {
        Background = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(255, 255, 255),
        Transparency = 0.35
    }
})

local TabA = Window:CreateTab("Main")
local TabB = Window:CreateTab("Extras")

TabA:AddToggle{
    Text = "Test Toggle",
    Callback = function(State)
        print("Toggle is", State)
    end
}

local Dropdown = TabA:AddDropdown{
    Text = "Choose Option",
    Choices = {"Option 1", "Option 2", "Option 3"},
    Callback = function(Choice)
        print("Selected:", Choice)
    end
}

TabA:AddButton{
    Text = "Single Button",
    Callback = function()
        print("Button pressed")
    end
}

TabA:AddTextBox{
    Placeholder = "Type here...",
    Callback = function(Text, EnterPressed)
        print("TextBox:", Text, "EnterPressed:", EnterPressed)
    end
}

TabA:AddSlider{
    Text = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(val)
        print("Slider value:", val)
    end,
    Step = 1,
    Color = Color3.fromRGB(30, 30, 30)
}

Dropdown:Add("Option 4")
Dropdown:Remove("Option 1")
Dropdown:Clear()

for i = 1, 30 do
    TabB:AddButton{
        Text = "Test Button " .. i,
        Callback = function()
            print("Pressed", i)
        end
    }
end
