local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Aimbot = false,
    Triggerbot = false,
    Smoothness = 0.1,
    FOVRadius = 150,
    ShowFOV = false,
    
    OutlineESP = false,
    CornerESP = false,
    Tracers = false,
    
    SpeedBoost = false,
    SpeedValue = 2,
    
    AccentColor = Color3.fromRGB(0, 242, 255),
    SecondaryColor = Color3.fromRGB(120, 120, 130)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Velocity_Persistent"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 48, 60)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Config.AccentColor
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
Sidebar.BorderSizePixel = 0
Instance.new("UIListLayout", Sidebar).HorizontalAlignment = Enum.HorizontalAlignment.Center

local Title = Instance.new("TextLabel", Sidebar)
Title.Text = "VELOCITY"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Config.AccentColor
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1

local Container = Instance.new("Frame", Main)
Container.Position = UDim2.new(0, 130, 0, 10)
Container.Size = UDim2.new(1, -140, 1, -20)
Container.BackgroundTransparency = 1

local Pages = {}
local function NewTab(name)
    local Page = Instance.new("ScrollingFrame", Container)
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.Visible = false
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)

    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0, 100, 0, 35)
    TabBtn.BackgroundTransparency = 1
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.Gotham
    TabBtn.TextColor3 = Config.SecondaryColor
    TabBtn.TextSize = 13
    
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Page.Visible = true
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Config.SecondaryColor end end
        TabBtn.TextColor3 = Config.AccentColor
    end)
    table.insert(Pages, Page)
    return Page
end

local function NewToggle(name, parent, callback)
    local Btn = Instance.new("TextButton", parent)
    Btn.Size = UDim2.new(1, 0, 0, 32)
    Btn.BackgroundColor3 = Color3.fromRGB(25, 27, 35)
    Btn.Text = "  " .. name .. ": OFF"
    Btn.Font = Enum.Font.Gotham
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    local on = false
    Btn.MouseButton1Click:Connect(function()
        on = not on
        Btn.Text = "  " .. name .. (on and ": ON" or ": OFF")
        Btn.TextColor3 = on and Config.AccentColor or Color3.fromRGB(200, 200, 200)
        callback(on)
    end)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
end

local function NewSlider(name, parent, min, max, default, callback)
    local Frame = Instance.new("Frame", parent)
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.BackgroundTransparency = 1
    local Label = Instance.new("TextLabel", Frame)
    Label.Text = name .. ": " .. default
    Label.Size = UDim2.new(1, 0, 0, 20)
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    local SliderBG = Instance.new("Frame", Frame)
    SliderBG.Size = UDim2.new(1, 0, 0, 6)
    SliderBG.Position = UDim2.new(0, 0, 0, 28)
    SliderBG.BackgroundColor3 = Color3.fromRGB(35, 37, 45)
    local SliderMain = Instance.new("Frame", SliderBG)
    SliderMain.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    SliderMain.BackgroundColor3 = Config.AccentColor
    Instance.new("UICorner", SliderBG)
    Instance.new("UICorner", SliderMain)
    SliderBG.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            local connection
            connection = RunService.RenderStepped:Connect(function()
                local percent = math.clamp((UIS:GetMouseLocation().X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                SliderMain.Size = UDim2.new(percent, 0, 1, 0)
                local val = math.floor(min + (max - min) * percent)
                Label.Text = name .. ": " .. val
                callback(val)
                if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then connection:Disconnect() end
            end)
        end
    end)
end

local Combat = NewTab("Combat")
local Visuals = NewTab("Visuals")
local Movement = NewTab("Movement")
Combat.Visible = true

NewToggle("Aimbot", Combat, function(v) Config.Aimbot = v end)
NewToggle("Triggerbot", Combat, function(v) Config.Triggerbot = v end)
NewToggle("Show FOV", Combat, function(v) Config.ShowFOV = v end)
NewSlider("FOV Radius", Combat, 10, 600, 150, function(v) Config.FOVRadius = v end)
NewSlider("Aimbot Smoothness", Combat, 1, 100, 10, function(v) Config.Smoothness = v/100 end)

NewToggle("Outline ESP", Visuals, function(v) Config.OutlineESP = v end)
NewToggle("Corner ESP", Visuals, function(v) Config.CornerESP = v end)
NewToggle("Tracers", Visuals, function(v) Config.Tracers = v end)

NewToggle("CFrame Speed Boost", Movement, function(v) Config.SpeedBoost = v end)
NewSlider("Speed Power", Movement, 1, 20, 2, function(v) Config.SpeedValue = v end)

local function CreateCorner()
    local lines = {}
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Thickness = 1.5
        l.Color = Config.AccentColor
        l.Visible = false
        lines[i] = l
    end
    return lines
end

local function CreateTracer()
    local l = Drawing.new("Line")
    l.Thickness = 1
    l.Color = Config.AccentColor
    l.Visible = false
    return l
end

local Cache = {}

local function GetNearestHead()
    local nearest = nil
    local lastDist = Config.FOVRadius
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - UIS:GetMouseLocation()).Magnitude
                if dist < lastDist then
                    nearest = p.Character.Head
                    lastDist = dist
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.FOVRadius
    FOVCircle.Position = UIS:GetMouseLocation()

    if Config.Triggerbot then
        local target = LPlayer:GetMouse().Target
        if target and target.Parent:FindFirstChild("Humanoid") and target.Parent ~= LPlayer.Character then
            mouse1click()
        end
    end

    if Config.SpeedBoost and LPlayer.Character and LPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LPlayer.Character:TranslateBy(hum.MoveDirection * (Config.SpeedValue / 10))
        end
    end

    if Config.Aimbot and (UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
        local head = GetNearestHead()
        if head then
            local hPos = Camera:WorldToViewportPoint(head.Position)
            mousemoverel((hPos.X - UIS:GetMouseLocation().X) * Config.Smoothness, (hPos.Y - UIS:GetMouseLocation().Y) * Config.Smoothness)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local char = p.Character
            local root = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

            local highlight = char:FindFirstChild("VelocityOutline")
            if Config.OutlineESP then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "VelocityOutline"
                    highlight.OutlineColor = Config.AccentColor
                    highlight.FillTransparency = 1
                end
            elseif highlight then highlight:Destroy() end

            if not Cache[p] then Cache[p] = {Corner = CreateCorner(), Tracer = CreateTracer()} end
            local c = Cache[p]

            if onScreen then
                if Config.Tracers then
                    c.Tracer.Visible = true
                    c.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                    c.Tracer.To = Vector2.new(pos.X, pos.Y)
                else c.Tracer.Visible = false end

                if Config.CornerESP then
                    local size = (Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0)).Y)
                    local w = size / 2
                    local x, y = pos.X, pos.Y
                    for i=1,8 do c.Corner[i].Visible = true end
                    c.Corner[1].From = Vector2.new(x-w, y-size/2) c.Corner[1].To = Vector2.new(x-w+(w/3), y-size/2)
                    c.Corner[2].From = Vector2.new(x-w, y-size/2) c.Corner[2].To = Vector2.new(x-w, y-size/2+(size/6))
                    c.Corner[3].From = Vector2.new(x+w, y-size/2) c.Corner[3].To = Vector2.new(x+w-(w/3), y-size/2)
                    c.Corner[4].From = Vector2.new(x+w, y-size/2) c.Corner[4].To = Vector2.new(x+w, y-size/2+(size/6))
                    c.Corner[5].From = Vector2.new(x-w, y+size/2) c.Corner[5].To = Vector2.new(x-w+(w/3), y+size/2)
                    c.Corner[6].From = Vector2.new(x-w, y+size/2) c.Corner[6].To = Vector2.new(x-w, y+size/2-(size/6))
                    c.Corner[7].From = Vector2.new(x+w, y+size/2) c.Corner[7].To = Vector2.new(x+w-(w/3), y+size/2)
                    c.Corner[8].From = Vector2.new(x+w, y+size/2) c.Corner[8].To = Vector2.new(x+w, y+size/2-(size/6))
                else for i=1,8 do c.Corner[i].Visible = false end end
            else
                c.Tracer.Visible = false
                for i=1,8 do c.Corner[i].Visible = false end
            end
        end
    end
end)

UIS.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.Insert then Main.Visible = not Main.Visible end end)
