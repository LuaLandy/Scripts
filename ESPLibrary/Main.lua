return (function()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local ESPModels = {}
local ESPTracers = {}
local ESPCategories = {}
local ESPModelDefs = {}
local RainbowEnabled = false
local RainbowConnection = nil
local ESPDefaultSettings = {Font = Enum.Font.FredokaOne, TextSize = 22}
local ESPTablesData = {}

function ESPAddCategory(Name, Color, Enabled, Tracers, Text)
    ESPCategories[Name] = {Color = Color or Color3.new(1,1,1), Enabled = Enabled ~= false, Tracers = Tracers == true, Text = Text or Name}
end

local function safeRemoveTracer(t)
    if not t then return end
    pcall(function()
        if type(t.Remove) == "function" then t:Remove() end
        if type(t.Destroy) == "function" then t:Destroy() end
    end)
end

local function createTracer(Color)
    local ok, tracer = pcall(function() return Drawing.new("Line") end)
    if not ok or not tracer then return nil end
    pcall(function()
        tracer.Thickness = 1
        tracer.Color = Color
        tracer.Visible = true
    end)
    return tracer
end

local function choosePartForObject(Obj)
    if not Obj then return nil end
    if Obj:IsA("BasePart") then return Obj end
    if Obj:IsA("Model") then
        if Obj.PrimaryPart and Obj.PrimaryPart:IsA("BasePart") then return Obj.PrimaryPart end
        return Obj:FindFirstChildWhichIsA("BasePart")
    end
    return nil
end

local function ensureSingleHighlight(Obj, Part, Color, enabled)
    local hl = Obj:FindFirstChild("ESP_Highlight")
    if hl and hl:IsA("Highlight") then
        hl.FillColor = Color
        hl.OutlineColor = Color
        hl.Adornee = Part
        hl.Enabled = enabled
        return hl
    end
    local newHl = Instance.new("Highlight")
    newHl.Name = "ESP_Highlight"
    newHl.FillColor = Color
    newHl.OutlineColor = Color
    newHl.Adornee = Part
    newHl.Parent = Obj
    newHl.Enabled = enabled
    return newHl
end

local function ensureSingleBillboard(Obj, Part, text, textColor, font, textSize, enabled)
    local bb = Obj:FindFirstChild("ESP_Billboard")
    if bb and bb:IsA("BillboardGui") then
        bb.Adornee = Part
        bb.AlwaysOnTop = true
        bb.Size = UDim2.new(0,100,0,20)
        bb.Enabled = enabled
        local lbl = bb:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = text
            lbl.TextColor3 = textColor
            lbl.Font = font
            lbl.TextSize = textSize
            lbl.TextScaled = true
            return bb, lbl
        end
    end
    local newBB = Instance.new("BillboardGui")
    newBB.Name = "ESP_Billboard"
    newBB.Size = UDim2.new(0,100,0,20)
    newBB.AlwaysOnTop = true
    newBB.Adornee = Part
    newBB.Parent = Obj
    newBB.Enabled = enabled
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = textColor
    lbl.TextScaled = true
    lbl.Font = font
    lbl.TextSize = textSize
    lbl.Parent = newBB
    return newBB, lbl
end

local function InternalAddModel(Obj, Options)
    if not Obj or ESPModels[Obj] then return end
    if not (Obj:IsA("Model") or Obj:IsA("BasePart")) then return end
    local Category = Options.Category or "Default"
    local CatData = ESPCategories[Category]
    if not CatData then return end
    local Text = Options.Text or CatData.Text or Obj.Name
    local Enabled = (Options.Enabled ~= false)
    local Tracers = Options.Tracers
    local Part = choosePartForObject(Obj)
    if not Part then return end
    local textColor
    if Category == "Keys" then
        textColor = Color3.fromRGB(255,255,255)
    elseif Category == "Door" then
        textColor = Color3.fromRGB(0,255,0)
    else
        textColor = CatData.Color
    end
    ensureSingleHighlight(Obj, Part, CatData.Color, (Enabled and CatData.Enabled))
    ensureSingleBillboard(Obj, Part, Text, textColor, ESPDefaultSettings.Font, ESPDefaultSettings.TextSize, (Enabled and CatData.Enabled))
    local shouldTracer = (Tracers == true) or (Tracers == nil and CatData.Tracers == true)
    if shouldTracer and (Enabled and CatData.Enabled) then
        if not ESPTracers[Obj] then
            local tr = createTracer(CatData.Color)
            if tr then ESPTracers[Obj] = tr end
        else
            ESPTracers[Obj].Color = CatData.Color
        end
    end
    ESPModels[Obj] = {Part = Part, Category = Category}
end

function ESPAddModel(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    if type(Name) ~= "string" or Name == "" then return end
    local Text = Options.Text or Name
    local Category = Options.Category or "Default"
    local Enabled = Options.Enabled
    local Tracers = Options.Tracers
    ESPModelDefs[Name] = {Category = Category, Text = Text, Enabled = (Enabled ~= false), Tracers = (Tracers == true) or nil}
    for _, Obj in ipairs(Parent:GetDescendants()) do
        if Obj:IsA("Model") and Obj.Name == Name then
            InternalAddModel(Obj, {Category = Category, Text = Text, Enabled = Enabled, Tracers = Tracers})
        elseif Obj:IsA("BasePart") and Obj.Name == Name then
            if not (Obj.Parent and Obj.Parent:IsA("Model") and Obj.Parent.Name == Name) then
                InternalAddModel(Obj, {Category = Category, Text = Text, Enabled = Enabled, Tracers = Tracers})
            end
        end
    end
end

function ESPRemoveModel(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    for Obj, _ in pairs(ESPModels) do
        if Obj.Name == Name and Obj:IsDescendantOf(Parent) then
            if Obj:FindFirstChild("ESP_Highlight") then pcall(function() Obj.ESP_Highlight:Destroy() end) end
            if Obj:FindFirstChild("ESP_Billboard") then pcall(function() Obj.ESP_Billboard:Destroy() end) end
            safeRemoveTracer(ESPTracers[Obj])
            ESPTracers[Obj] = nil
            ESPModels[Obj] = nil
        end
    end
    ESPModelDefs[Name] = nil
end

function ESPUpdateColor(Options)
    local Parent = Options.Path or workspace
    local Name = Options.Name
    local Color = Options.Color or Color3.new(1,1,1)
    for Obj, _ in pairs(ESPModels) do
        if Obj.Name == Name and Obj:IsDescendantOf(Parent) then
            if Obj:FindFirstChild("ESP_Highlight") then
                Obj.ESP_Highlight.FillColor = Color
                Obj.ESP_Highlight.OutlineColor = Color
            end
            if Obj:FindFirstChild("ESP_Billboard") then
                local lbl = Obj.ESP_Billboard:FindFirstChildOfClass("TextLabel")
                if lbl then lbl.TextColor3 = Color end
            end
            if ESPTracers[Obj] then ESPTracers[Obj].Color = Color end
        end
    end
    if ESPCategories[Name] then ESPCategories[Name].Color = Color end
end

RunService.Heartbeat:Connect(function()
    for Obj, Data in pairs(ESPModels) do
        local Part = Data.Part
        if not Obj or not Obj.Parent or not Part or not Part.Parent then
            if Obj and Obj:FindFirstChild("ESP_Highlight") then pcall(function() Obj.ESP_Highlight:Destroy() end) end
            if Obj and Obj:FindFirstChild("ESP_Billboard") then pcall(function() Obj.ESP_Billboard:Destroy() end) end
            safeRemoveTracer(ESPTracers[Obj])
            ESPTracers[Obj] = nil
            ESPModels[Obj] = nil
        else
            local Cat = Data.Category
            if ESPCategories[Cat] and ESPCategories[Cat].Tracers and ESPTracers[Obj] then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                local Tracer = ESPTracers[Obj]
                pcall(function()
                    Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(ScreenPos.X, ScreenPos.Y)
                    Tracer.Visible = OnScreen
                end)
            end
        end
    end
end)

function ESPRainbow(Enabled)
    if RainbowConnection then RainbowConnection:Disconnect(); RainbowConnection = nil end
    RainbowEnabled = Enabled
    if Enabled then
        local Hue = 0
        RainbowConnection = RunService.RenderStepped:Connect(function(dt)
            Hue = (Hue + dt * 40) % 360
            local Color = Color3.fromHSV(Hue/360, 1, 1)
            for Obj, _ in pairs(ESPModels) do
                local Cat = ESPModels[Obj].Category
                if ESPCategories[Cat] and ESPCategories[Cat].Enabled then
                    if Obj:FindFirstChild("ESP_Highlight") then
                        Obj.ESP_Highlight.FillColor = Color
                        Obj.ESP_Highlight.OutlineColor = Color
                    end
                    if Obj:FindFirstChild("ESP_Billboard") then
                        local lbl = Obj.ESP_Billboard:FindFirstChildOfClass("TextLabel")
                        if lbl then lbl.TextColor3 = Color end
                    end
                    if ESPTracers[Obj] then ESPTracers[Obj].Color = Color end
                end
            end
        end)
    else
        if RainbowConnection then RainbowConnection:Disconnect(); RainbowConnection = nil end
        for Obj, _ in pairs(ESPModels) do
            local Cat = ESPModels[Obj].Category
            if ESPCategories[Cat] and Obj:FindFirstChild("ESP_Highlight") then
                Obj.ESP_Highlight.FillColor = ESPCategories[Cat].Color
                Obj.ESP_Highlight.OutlineColor = ESPCategories[Cat].Color
            end
            if Obj:FindFirstChild("ESP_Billboard") then
                local lbl = Obj.ESP_Billboard:FindFirstChildOfClass("TextLabel")
                if lbl then
                    if Cat == "Keys" then
                        lbl.TextColor3 = Color3.fromRGB(255,255,255)
                    elseif Cat == "Door" then
                        lbl.TextColor3 = Color3.fromRGB(0,255,0)
                    else
                        lbl.TextColor3 = ESPCategories[Cat] and ESPCategories[Cat].Color or Color3.new(1,1,1)
                    end
                end
            end
            if ESPTracers[Obj] then ESPTracers[Obj].Color = ESPCategories[Cat] and ESPCategories[Cat].Color or Color3.new(1,1,1) end
        end
    end
end

function ESPTracersToggle(Enabled)
    for Obj, Data in pairs(ESPModels) do
        local Cat = Data.Category
        safeRemoveTracer(ESPTracers[Obj])
        ESPTracers[Obj] = nil
        local def = ESPModelDefs[Obj.Name]
        local want = (def and def.Tracers == true) or (not def and ESPCategories[Cat] and ESPCategories[Cat].Tracers)
        if ESPCategories[Cat] and ESPCategories[Cat].Enabled and Enabled and want then
            local Tracer = createTracer(ESPCategories[Cat].Color)
            if Tracer then ESPTracers[Obj] = Tracer end
        end
    end
end

function ESPSettings(Options)
    ESPDefaultSettings.Font = Options.Font or Enum.Font.FredokaOne
    ESPDefaultSettings.TextSize = Options.TextSize or 22
end

workspace.DescendantAdded:Connect(function(Obj)
    if not (Obj:IsA("Model") or Obj:IsA("BasePart")) then return end
    local def = ESPModelDefs[Obj.Name]
    if def then
        if Obj:IsA("BasePart") and Obj.Parent and Obj.Parent:IsA("Model") and Obj.Parent.Name == Obj.Name then return end
        InternalAddModel(Obj, {Category = def.Category, Text = def.Text, Enabled = def.Enabled, Tracers = def.Tracers})
        return
    end
    for Name, Cat in pairs(ESPCategories) do
        if Obj:IsA("Model") and Obj.Name == Name and Cat.Enabled then
            InternalAddModel(Obj, {Category = Name, Text = Cat.Text, Enabled = true})
            return
        elseif Obj:IsA("BasePart") and Obj.Name == Name and not (Obj.Parent and Obj.Parent:IsA("Model") and Obj.Parent.Name == Name) and Cat.Enabled then
            InternalAddModel(Obj, {Category = Name, Text = Cat.Text, Enabled = true})
            return
        end
    end
    for TableName, TableData in pairs(ESPTablesData) do
        for ModelName, Text in pairs(TableData) do
            if Obj:IsA("Model") and Obj.Name == ModelName then
                InternalAddModel(Obj, {Category = TableName, Text = Text, Enabled = true})
                return
            elseif Obj:IsA("BasePart") and Obj.Name == ModelName and not (Obj.Parent and Obj.Parent:IsA("Model") and Obj.Parent.Name == ModelName) then
                InternalAddModel(Obj, {Category = TableName, Text = Text, Enabled = true})
                return
            end
        end
    end
end)

workspace.DescendantRemoving:Connect(function(Obj)
    if ESPModels[Obj] then
        if Obj:FindFirstChild("ESP_Highlight") then pcall(function() Obj.ESP_Highlight:Destroy() end) end
        if Obj:FindFirstChild("ESP_Billboard") then pcall(function() Obj.ESP_Billboard:Destroy() end) end
        safeRemoveTracer(ESPTracers[Obj])
        ESPTracers[Obj] = nil
        ESPModels[Obj] = nil
    end
end)

function ESPEnableCategory(Category)
    if ESPCategories[Category] then
        ESPCategories[Category].Enabled = true
        for Name, def in pairs(ESPModelDefs) do
            if def.Category == Category then ESPModelDefs[Name].Enabled = true end
        end
        for Obj, _ in pairs(ESPModels) do
            if ESPModels[Obj].Category == Category then
                if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight.Enabled = true end
                if Obj:FindFirstChild("ESP_Billboard") then Obj.ESP_Billboard.Enabled = true end
                local def = ESPModelDefs[Obj.Name]
                local want = (def and def.Tracers == true) or (not def and ESPCategories[Category].Tracers)
                if ESPCategories[Category].Tracers and want and not ESPTracers[Obj] then
                    local Tracer = createTracer(RainbowEnabled and Color3.fromHSV(0,1,1) or ESPCategories[Category].Color)
                    if Tracer then ESPTracers[Obj] = Tracer end
                end
            end
        end
    end
end

function ESPDisableCategory(Category)
    if ESPCategories[Category] then
        ESPCategories[Category].Enabled = false
        for Name, def in pairs(ESPModelDefs) do
            if def.Category == Category then ESPModelDefs[Name].Enabled = false end
        end
        for Obj, _ in pairs(ESPModels) do
            if ESPModels[Obj].Category == Category then
                if Obj:FindFirstChild("ESP_Highlight") then Obj.ESP_Highlight.Enabled = false end
                if Obj:FindFirstChild("ESP_Billboard") then Obj.ESP_Billboard.Enabled = false end
                safeRemoveTracer(ESPTracers[Obj])
                ESPTracers[Obj] = nil
            end
        end
    end
end

function ESPTables(TableName, TableData)
    ESPTablesData[TableName] = TableData
end

function ESPEnableTables(TableName)
    local TableData = ESPTablesData[TableName]
    if TableData then
        for ModelName, Text in pairs(TableData) do
            ESPModelDefs[ModelName] = {Category = TableName, Text = Text, Enabled = true}
            ESPAddModel({Name = ModelName, Text = Text, Category = TableName, Enabled = true})
        end
    end
end

function ESPDisableTables(TableName)
    for Obj, _ in pairs(ESPModels) do
        if ESPModels[Obj].Category == TableName then
            if Obj:FindFirstChild("ESP_Highlight") then pcall(function() Obj.ESP_Highlight:Destroy() end) end
            if Obj:FindFirstChild("ESP_Billboard") then pcall(function() Obj.ESP_Billboard:Destroy() end) end
            safeRemoveTracer(ESPTracers[Obj])
            ESPTracers[Obj] = nil
            ESPModels[Obj] = nil
        end
    end
    for k, v in pairs(ESPModelDefs) do
        if v.Category == TableName then ESPModelDefs[k] = nil end
    end
end

return {
    ESPAddCategory = ESPAddCategory,
    ESPAddModel = ESPAddModel,
    ESPRemoveModel = ESPRemoveModel,
    ESPUpdateColor = ESPUpdateColor,
    ESPRainbow = ESPRainbow,
    ESPTracers = ESPTracersToggle,
    ESPSettings = ESPSettings,
    ESPEnableCategory = ESPEnableCategory,
    ESPDisableCategory = ESPDisableCategory,
    ESPTables = ESPTables,
    ESPEnableTables = ESPEnableTables,
    ESPDisableTables = ESPDisableTables
}
end)()
