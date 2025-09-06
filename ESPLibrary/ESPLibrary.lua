return (function()
    local RunService = game:GetService("RunService")
    local Players = game:GetService("Players")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    local ESPLibrary = {}
    local ESPObjects = {}
    local TracerLines = {}
    local rainbowEnabled = false
    local rainbowConnection
    local espTracersEnabled = false
    local textSize = 16
    local currentFont = Enum.Font.FredokaOne
    local distanceEnabled = false

    local function RemoveESPInternal(obj)
        if not obj then return end
        local data = ESPObjects[obj]
        if not data then return end
        if data.Highlight then data.Highlight:Destroy() end
        if data.Billboard then data.Billboard:Destroy() end
        if data.DistanceLabel then data.DistanceLabel:Destroy() end
        if TracerLines[obj] then TracerLines[obj]:Remove(); TracerLines[obj] = nil end
        ESPObjects[obj] = nil
    end

    local function UpdateESPColor(obj, color)
        local data = ESPObjects[obj]
        if not data then return end
        if data.Highlight then
            data.Highlight.FillColor = color
            data.Highlight.OutlineColor = color
        end
        if data.Label then
            data.Label.TextColor3 = color
        end
        if data.DistanceLabel then
            data.DistanceLabel.TextColor3 = color
        end
        if TracerLines[obj] then
            TracerLines[obj].Color = color
        end
    end

    function ESPLibrary:AddESP(options)
        local object = options.Object
        if not object then return end
        local color = options.Color or Color3.new(1,1,1)
        local text = options.Text or object.Name

        RemoveESPInternal(object)

        local adornee = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart")
        if not adornee then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = color
        highlight.OutlineColor = color
        highlight.Adornee = adornee
        highlight.Parent = object

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Size = distanceEnabled and UDim2.new(0,100,0,40) or UDim2.new(0,100,0,20)
        billboard.AlwaysOnTop = true
        billboard.Adornee = adornee
        billboard.Parent = object

        local label = Instance.new("TextLabel")
        label.Name = "ESP_Label"
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color
        label.TextScaled = true
        label.Font = currentFont
        label.TextSize = textSize
        label.Parent = billboard

        local distanceLabel
        if distanceEnabled then
            distanceLabel = Instance.new("TextLabel")
            distanceLabel.Name = "ESP_Distance"
            distanceLabel.Size = UDim2.new(1,0,0,20)
            distanceLabel.Position = UDim2.new(0,0,0,20)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Text = "[ 0 ]"
            distanceLabel.TextColor3 = color
            distanceLabel.TextScaled = true
            distanceLabel.Font = currentFont
            distanceLabel.TextSize = math.max(10, textSize - 2)
            distanceLabel.Parent = billboard
        end

        if espTracersEnabled then
            local tracer = Drawing.new("Line")
            tracer.Thickness = 1
            tracer.Color = color
            tracer.Visible = true
            TracerLines[object] = tracer
        end

        ESPObjects[object] = {
            Highlight = highlight,
            Billboard = billboard,
            Label = label,
            DistanceLabel = distanceLabel,
            Adornee = adornee
        }
    end

    function ESPLibrary:RemoveESP(object)
        RemoveESPInternal(object)
    end

    function ESPLibrary:UpdateObjectColor(object, color)
        UpdateESPColor(object, color)
    end

    function ESPLibrary:UpdateObjectText(object, text)
        local data = ESPObjects[object]
        if data and data.Label then
            data.Label.Text = text
        end
    end

    function ESPLibrary:TextSize(size)
        textSize = size
        for _,data in pairs(ESPObjects) do
            if data.Label then
                data.Label.TextSize = size
            end
            if data.DistanceLabel then
                data.DistanceLabel.TextSize = math.max(10, size - 2)
            end
            if data.Billboard then
                data.Billboard.Size = distanceEnabled and UDim2.new(0,100,0,40) or UDim2.new(0,100,0,20)
            end
        end
    end

    function ESPLibrary:Font(fontEnum)
        currentFont = fontEnum
        for _,data in pairs(ESPObjects) do
            if data.Label then data.Label.Font = fontEnum end
            if data.DistanceLabel then data.DistanceLabel.Font = fontEnum end
        end
    end

    function ESPLibrary:Rainbow(enabled)
        rainbowEnabled = enabled
        if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
        if rainbowEnabled then
            local hue = 0
            rainbowConnection = RunService.RenderStepped:Connect(function(dt)
                hue = (hue + dt * 20) % 360
                local c = Color3.fromHSV(hue/360,1,1)
                for obj,_ in pairs(ESPObjects) do
                    UpdateESPColor(obj,c)
                end
            end)
        end
    end

    function ESPLibrary:Tracers(enabled)
        espTracersEnabled = enabled
        if not enabled then
            for _,tracer in pairs(TracerLines) do tracer:Remove() end
            TracerLines = {}
        else
            for obj,data in pairs(ESPObjects) do
                local color = data.Highlight and data.Highlight.FillColor or Color3.new(1,1,1)
                local tracer = Drawing.new("Line")
                tracer.Thickness = 1
                tracer.Color = color
                tracer.Visible = true
                TracerLines[obj] = tracer
            end
        end
    end

    function ESPLibrary:DistanceMeters(enabled)
        distanceEnabled = enabled and true or false
        for obj,data in pairs(ESPObjects) do
            if not data or not data.Billboard then continue end
            if distanceEnabled then
                data.Billboard.Size = UDim2.new(0,100,0,40)
                if not data.DistanceLabel then
                    local distanceLabel = Instance.new("TextLabel")
                    distanceLabel.Name = "ESP_Distance"
                    distanceLabel.Size = UDim2.new(1,0,0,20)
                    distanceLabel.Position = UDim2.new(0,0,0,20)
                    distanceLabel.BackgroundTransparency = 1
                    distanceLabel.Text = "[ 0 ]"
                    distanceLabel.TextColor3 = (data.Highlight and data.Highlight.FillColor) or Color3.new(1,1,1)
                    distanceLabel.TextScaled = true
                    distanceLabel.Font = currentFont
                    distanceLabel.TextSize = math.max(10, textSize - 2)
                    distanceLabel.Parent = data.Billboard
                    data.DistanceLabel = distanceLabel
                end
            else
                if data.DistanceLabel then
                    data.DistanceLabel:Destroy()
                    data.DistanceLabel = nil
                end
                data.Billboard.Size = UDim2.new(0,100,0,20)
            end
        end
    end

    RunService.Heartbeat:Connect(function()
        local root = LocalPlayer and LocalPlayer.Character
        local hrp = nil
        if root then hrp = root:FindFirstChild("HumanoidRootPart") or root:FindFirstChildWhichIsA("BasePart") end

        for obj,data in pairs(ESPObjects) do
            if not obj or not obj.Parent or not data.Adornee or not data.Adornee.Parent then
                RemoveESPInternal(obj)
            else
                if espTracersEnabled and TracerLines[obj] then
                    local pos,vis = Camera:WorldToViewportPoint(data.Adornee.Position)
                    local tracer = TracerLines[obj]
                    tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    tracer.To = Vector2.new(pos.X,pos.Y)
                    tracer.Visible = vis
                end
                if distanceEnabled and data.DistanceLabel and hrp then
                    local success,dist = pcall(function()
                        return math.floor((data.Adornee.Position - hrp.Position).Magnitude + 0.5)
                    end)
                    if success and dist then
                        data.DistanceLabel.Text = string.format("[ %d ]", dist)
                    else
                        data.DistanceLabel.Text = "[ 0 ]"
                    end
                end
            end
        end
    end)

    return ESPLibrary
end)()
