local ESPLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/LuaLandy/Scripts/refs/heads/main/ESPLibrary/ESPLibrary.lua"))()

for _,door in pairs(workspace:GetDescendants()) do
    if door:IsA("Model") and door.Name == "Door" then
        local part = door:FindFirstChild("Door")
        if part then
            ESPLibrary:AddESP({
                Object = part,
                Text = "Door",
                Color = Color3.fromRGB(255, 50, 50)
            })
        end
    end
end

ESPLibrary:Font(Enum.Font.GothamBold)
ESPLibrary:TextSize(20)
ESPLibrary:Rainbow(true)
ESPLibrary:Tracers(true)
ESPLibrary:DistanceMeters(true)

task.delay(10, function()
    for _,door in pairs(workspace:GetDescendants()) do
        if door:IsA("Model") and door.Name == "Door" then
            local part = door:FindFirstChild("Door")
            if part then
                ESPLibrary:RemoveESP(part)
            end
        end
    end
end)
