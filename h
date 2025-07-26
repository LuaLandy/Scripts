local repo = "https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/"

local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
	Title = "Granny Retro Fucker",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	NotifySide = "Left",
	TabPadding = 8,
	MenuFadeTime = 0.2,
})

local Tabs = {
	Main = Window:AddTab("Main"),
	["UI Settings"] = Window:AddTab("UI Settings"),
}

local Main = Tabs.Main:AddLeftGroupbox("Main")

Main:AddButton({
    Text = "Give 1000000 Points",
    Func = function()
local args = {
    1000000,
    "Code27",
    "Point",
    "LOL"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ExchangeCode2"):FireServer(unpack(args))
    end
})

Main:AddButton({
    Text = "Give 1000000 PU",
    Func = function()
local args = {
    1000000,
    "Code27",
    "PU",
    "LOL"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ExchangeCode2"):FireServer(unpack(args))
    end
})

local ValueToGive = 1000

Main:AddToggle("togglepoints", {
    Text = "Give 10000 Points",
    Default = false,
    Callback = function(Value)
getgenv().omgfreepoints = Value

while getgenv().omgfreepoints do
local args = {
    ValueToGive,
    "Code27",
    "Point",
    "LOL"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ExchangeCode2"):FireServer(unpack(args))
task.wait()
end
    end
})

Main:AddToggle("togglepu", {
    Text = "Give 10000 Points",
    Default = false,
    Callback = function(Value)
getgenv().omgfreepu = Value

while getgenv().omgfreepu do
local args = {
    ValueToGive,
    "Code27",
    "PU",
    "LOL"
}
game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ExchangeCode2"):FireServer(unpack(args))
task.wait()
end
    end
})

Main:AddSlider("SliderThing", {
    Text = "Amount",
    Default = 10,
    Min = 10,
    Max = 1000000,
    Rounding = 0,
    Callback = function(Value)
    ValueToGive = Value
    end
})

local Movement = Tabs.Main:AddLeftGroupbox("Movement")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local SpeedConnection
local JumpConnection
local FOVConnection

Movement:AddToggle("SpeedToggle", {
    Text = "Enable Speed",
    Default = false,
    Callback = function(Value)
        if Value then
            SpeedConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = _G.SpeedValue or 16
                end
            end)
        else
            if SpeedConnection then SpeedConnection:Disconnect() end
            SpeedConnection = nil
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

Movement:AddToggle("JumpToggle", {
    Text = "Enable Jump Power",
    Default = false,
    Callback = function(Value)
        if Value then
            JumpConnection = RunService.Heartbeat:Connect(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.JumpPower = _G.JumpValue or 50
                end
            end)
        else
            if JumpConnection then JumpConnection:Disconnect() end
            JumpConnection = nil
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
    end
})

Movement:AddToggle("FOVToggle", {
    Text = "Enable Field Of View",
    Default = false,
    Callback = function(Value)
        if Value then
            FOVConnection = RunService.Heartbeat:Connect(function()
                game.Workspace.CurrentCamera.FieldOfView = _G.FOVValue or 70
            end)
        else
            if FOVConnection then FOVConnection:Disconnect() end
            FOVConnection = nil
            game.Workspace.CurrentCamera.FieldOfView = 70
        end
    end
})

Movement:AddSlider("SpeedSlider", {
    Text = "Speed",
    Default = 16,
    Min = 16,
    Max = 70,
    Rounding = 0,
    Callback = function(Value)
        _G.SpeedValue = Value
    end
})

Movement:AddSlider("JumpSlider", {
    Text = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        _G.JumpValue = Value
    end
})

Movement:AddSlider("FOVSlider", {
    Text = "Field Of View",
    Default = 70,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        _G.FOVValue = Value
    end
})

Library:OnUnload(function()
	print("Unloaded!")
	Library.Unloaded = true
end)

local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown('Notification Side', {
	Values = {'Left', 'Right'},
	Default = 1,
	Multi = false,
	Text = 'Notification Side',
	Callback = function(Value)
		Library.NotifySide = Value
	end
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("GrannyRetroFucker")
SaveManager:SetFolder("GrannyRetroFucker/grannyretro")
SaveManager:SetSubFolder("grannyretro")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
