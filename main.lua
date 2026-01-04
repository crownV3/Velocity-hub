-- // VELOCITY HUB - PERSISTENT BUILD
if not game:IsLoaded() then game.Loaded:Wait() end

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // DRAWING API CHECK (Prevents script from breaking on low-end executors)
local function CreateDrawing(obj, props)
    local d = (Drawing and Drawing.new or function() return {Visible = false} end)(obj)
    for i, v in pairs(props) do d[i] = v end
    return d
end

-- // CONFIGURATION
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

-- // FOV CIRCLE
local FOVCircle = CreateDrawing("Circle", {
    Thickness = 1.5,
    Color = Config.AccentColor,
    Transparency = 0.7,
    Filled = false
})

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Velocity_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LPlayer:WaitForChild("PlayerGui")

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
Main.BorderSizePixel = 0
Main.Visible = true -- Ensure it starts visible

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main)
Stroke.Color = Color3.fromRGB(45, 48, 60)
Stroke.Thickness = 1.5

-- [Sidebar and Tab Logic remains exactly as your previous version]
-- (Shortened here for brevity, keep your NewTab/NewToggle functions as they were)

-- // TAB INITIALIZATION
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
Sidebar.BorderSizePixel = 0
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

-- // TABS
local Combat = NewTab("Combat")
local Visuals = NewTab("Visuals")
local Movement = NewTab("Movement")
Combat.Visible = true

NewToggle("Aimbot", Combat, function(v) Config.Aimbot = v end)
NewToggle("Triggerbot", Combat, function(v) Config.Triggerbot = v end)
NewToggle("Show FOV", Combat, function(v) Config.ShowFOV = v end)
NewToggle("Outline ESP", Visuals, function(v) Config.OutlineESP = v end)
NewToggle("CFrame Boost", Movement, function(v) Config.SpeedBoost = v end)

-- // MAIN RUN LOOP
local Cache = {}

RunService.RenderStepped:Connect(function()
    -- Sync FOV
    FOVCircle.Visible = Config.ShowFOV
    FOVCircle.Radius = Config.FOVRadius
    FOVCircle.Position = UIS:GetMouseLocation()

    -- Speed Boost
    if Config.SpeedBoost and LPlayer.Character and LPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LPlayer.Character.Humanoid
        if hum.MoveDirection.Magnitude > 0 then
            LPlayer.Character:TranslateBy(hum.MoveDirection * (Config.SpeedValue / 10))
        end
    end

    -- Outline ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("VelocityOutline")
            if Config.OutlineESP then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "VelocityOutline"
                    highlight.OutlineColor = Config.AccentColor
                    highlight.FillTransparency = 1
                end
            elseif highlight then highlight:Destroy() end
        end
    end
end)

-- // KEYBIND FIX: INSERT
UIS.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
        print("Velocity // Toggle:", Main.Visible)
    end
end)

print("Velocity Hub // Loaded Successfully")
