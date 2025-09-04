return (function()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ESPModels = {}
local ESPTracers = {}
local ESPCategories = {}
local RainbowEnabled = false
local RainbowConnection = nil
local ESPDefaultSettings = {Font = Enum.Font.FredokaOne, TextSize = 22}

function ESPAddCategory(Name, Color, Enabled, Tracers)
    ESPCategories[Name] = {Color=Color or Color3.new(1,1,1), Enabled=Enabled~=false, Tracers=Tracers==true}
end

local function InternalAddModel(Obj, Options)
    if not Obj then return end
    local Category = Options.Category or "Default"
    local Text = Options.Text or Obj.Name
    local CatData = ESPCategories[Category]
    if not CatData or not CatData.Enabled then return end
    local Part = Obj:IsA("BasePart") and Obj or Obj:FindFirstChildWhichIsA("BasePart")
    if not Part then return end
    local Highlight = Instance.new("Highlight")
    Highlight.Name = "ESP_Highlight"
    Highlight.FillColor = CatData.Color
    Highlight.OutlineColor = CatData.Color
    Highlight.Adornee = Part
    Highlight.Parent = Obj
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "ESP_Billboard"
    Billboard.Size = UDim2.new(0,100,0,20)
    Billboard.AlwaysOnTop = true
    Billboard.Adornee = Part
    Billboard.Parent = Obj
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1,0,1,0)
    Label.BackgroundTransparency = 1
    Label.Text = Text
    Label.TextColor3 = CatData.Color
    Label.TextScaled = true
    Label.Font = ESPDefaultSettings.Font
    Label.TextSize = ESPDefaultSettings.TextSize
    Label.Parent = Billboard
    if CatData.Tracers then
        local Tracer = Drawing.new("Line")
        Tracer.Thickness = 1
        Tracer.Color = CatData.Color
        Tracer.Visible = true
        ESPTracers[Obj] = Tracer
    end
    ESPModels[Obj] = {Part=Part, Category=Category}
end

function ESPAddModel(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    local Text = Options.Text or Name
    local Category = Options.Category or "Default"
    for _, Obj in ipairs(Parent:GetDescendants()) do
        if Obj.Name == Name and (Obj:IsA("Model") or Obj:IsA("BasePart")) then
            InternalAddModel(Obj, {Category=Category, Text=Text})
        end
    end
end

function ESPRemoveModel(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    for Obj,_ in pairs(ESPModels) do
        if Obj.Name == Name and Obj:IsDescendantOf(Parent) then
            if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight:Destroy() end
            if Obj:FindFirstChild("ESP_Billboard") then Obj.ESP_Billboard:Destroy() end
            if ESPTracers[Obj] then ESPTracers[Obj]:Remove(); ESPTracers[Obj]=nil end
            ESPModels[Obj] = nil
        end
    end
end

function ESPUpdateColor(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    local Color = Options.Color or Color3.new(1,1,1)
    for Obj,_ in pairs(ESPModels) do
        if Obj.Name == Name and Obj:IsDescendantOf(Parent) then
            if Obj:FindFirstChild("ESP_Highlight") then
                Obj.ESP_Highlight.FillColor = Color
                Obj.ESP_Highlight.OutlineColor = Color
            end
            if Obj:FindFirstChild("ESP_Billboard") and Obj.ESP_Billboard:FindFirstChildOfClass("TextLabel") then
                Obj.ESP_Billboard.TextLabel.TextColor3 = Color
            end
            if ESPTracers[Obj] then ESPTracers[Obj].Color = Color end
        end
    end
end

RunService.Heartbeat:Connect(function()
    for Obj,Data in pairs(ESPModels) do
        local Part = Data.Part
        if not Obj or not Obj.Parent or not Part or not Part.Parent then
            if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight:Destroy() end
            if Obj:FindFirstChild("ESP_Billboard") then Obj.ESP_Billboard:Destroy() end
            if ESPTracers[Obj] then ESPTracers[Obj]:Remove(); ESPTracers[Obj]=nil end
            ESPModels[Obj] = nil
        elseif ESPCategories[Data.Category].Tracers and ESPTracers[Obj] then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
            local Tracer = ESPTracers[Obj]
            Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
            Tracer.Visible = OnScreen
        end
    end
end)

function ESPRainbow(Enabled)
    if RainbowConnection then RainbowConnection:Disconnect(); RainbowConnection=nil end
    RainbowEnabled = Enabled
    if Enabled then
        local Hue = 0
        RainbowConnection = RunService.RenderStepped:Connect(function(dt)
            Hue = (Hue + dt*20)%360
            local Color = Color3.fromHSV(Hue/360,1,1)
            for Obj,_ in pairs(ESPModels) do
                local Cat = ESPModels[Obj].Category
                if ESPCategories[Cat].Enabled then
                    if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight.FillColor=Color; Obj.ESP_Highlight.OutlineColor=Color end
                    if Obj:FindFirstChild("ESP_Billboard") and Obj.ESP_Billboard:FindFirstChildOfClass("TextLabel") then
                        Obj.ESP_Billboard.TextLabel.TextColor3=Color
                    end
                    if ESPTracers[Obj] then ESPTracers[Obj].Color=Color end
                end
            end
        end)
    end
end

function ESPTracersToggle(Enabled)
    for Obj,Data in pairs(ESPModels) do
        local Cat = Data.Category
        if ESPTracers[Obj] then ESPTracers[Obj]:Remove(); ESPTracers[Obj]=nil end
        if ESPCategories[Cat].Enabled and Enabled then
            local Tracer = Drawing.new("Line")
            Tracer.Thickness = 1
            Tracer.Color = ESPCategories[Cat].Color
            Tracer.Visible = true
            ESPTracers[Obj] = Tracer
        end
    end
end

function ESPSettings(Options)
    ESPDefaultSettings.Font = Options.Font or Enum.Font.FredokaOne
    ESPDefaultSettings.TextSize = Options.TextSize or 22
end

workspace.DescendantAdded:Connect(function(Obj)
    for Name,_ in pairs(ESPCategories) do
        if Obj.Name == Name and (Obj:IsA("Model") or Obj:IsA("BasePart")) then
            InternalAddModel(Obj, {Category=Name, Text=Obj.Name})
        end
    end
end)

workspace.DescendantRemoving:Connect(function(Obj)
    if ESPModels[Obj] then
        if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight:Destroy() end
        if Obj:FindFirstChild("ESP_Billboard") then Obj.ESP_Billboard:Destroy() end
        if ESPTracers[Obj] then ESPTracers[Obj]:Remove(); ESPTracers[Obj]=nil end
        ESPModels[Obj] = nil
    end
end)

return {
    ESPAddCategory=ESPAddCategory,
    ESPAddModel=ESPAddModel,
    ESPRemoveModel=ESPRemoveModel,
    ESPUpdateColor=ESPUpdateColor,
    ESPRainbow=ESPRainbow,
    ESPTracers=ESPTracersToggle,
    ESPSettings=ESPSettings
}
end)()
