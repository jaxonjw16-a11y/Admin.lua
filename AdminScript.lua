
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ADMIN_ID = 123456789 --Change this to your roblox UserID

if player.UserId ~= ADMIN_ID then
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "SimpleAdmin"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 230)
frame.Position = UDim2.new(0.5, -120, 0.5, -115)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundTransparency = 1
title.Text = "ADMIN PANEL"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = frame

local function makeButton(name, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 36)
    button.Position = UDim2.new(0, 12, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(65, 95, 200)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = name
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.MouseButton1Click:Connect(callback)
end

local function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

makeButton("Speed Boost", 55, function()
    local h = getHumanoid()
    if h then h.WalkSpeed = 32 end
end)

makeButton("Super Jump", 100, function()
    local h = getHumanoid()
    if h then h.JumpPower = 100 end
end)

makeButton("Reset Stats", 145, function()
    local h = getHumanoid()
    if h then
        h.WalkSpeed = 16
        h.JumpPower = 50
    end
end)

makeButton("Reset Character", 190, function()
    player:LoadCharacter()
end)
