
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("AdminFunction")

-- Verify admin on the server
local success, allowed = pcall(function()
    return remote:InvokeServer("FlyPermission")
end)

if not success or not allowed then return end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local selectedId
local flying = false
local flyConnection
local flyVelocity
local flyGyro

local function create(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    obj.Parent = parent
    return obj
end

-- Open / Close button
local open = create("TextButton", {
    Size = UDim2.fromOffset(55, 40),
    Position = UDim2.new(0, 15, 0.5, 0),
    Text = "ADMIN",
    TextSize = 13,
    BackgroundColor3 = Color3.fromRGB(45, 100, 220),
    TextColor3 = Color3.new(1,1,1),
}, gui)

local frame = create("Frame", {
    Size = UDim2.fromOffset(330, 430),
    Position = UDim2.new(0.5, -165, 0.5, -215),
    BackgroundColor3 = Color3.fromRGB(25, 27, 38),
    BorderSizePixel = 0,
}, gui)

create("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, frame)

local top = create("TextLabel", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(40, 75, 150),
    Text = "  ADMIN CONTROL PANEL",
    TextColor3 = Color3.new(1,1,1),
    TextSize = 17,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, frame)

create("UICorner", {
    CornerRadius = UDim.new(0, 12)
}, top)

open.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- Draggable window
local dragging = false
local dragStart, startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Player selection
create("TextLabel", {
    Position = UDim2.fromOffset(12, 55),
    Size = UDim2.fromOffset(300, 25),
    BackgroundTransparency = 1,
    Text = "SELECT PLAYER",
    TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Left,
}, frame)

local playerList = create("ScrollingFrame", {
    Position = UDim2.fromOffset(12, 83),
    Size = UDim2.fromOffset(306, 105),
    BackgroundColor3 = Color3.fromRGB(38, 41, 54),
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0,0,0,0),
    ScrollBarThickness = 5,
}, frame)

create("UIListLayout", {
    Padding = UDim.new(0, 4),
}, playerList)

local selectedLabel = create("TextLabel", {
    Position = UDim2.fromOffset(12, 194),
    Size = UDim2.fromOffset(306, 25),
    BackgroundTransparency = 1,
    Text = "Selected: None",
    TextColor3 = Color3.fromRGB(150, 200, 255),
    TextSize = 13,
    Font = Enum.Font.Gotham,
    TextXAlignment = Enum.TextXAlignment.Left,
}, frame)

local function refreshPlayers()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local ok, list = pcall(function()
        return remote:InvokeServer("GetPlayers")
    end)

    if not ok or type(list) ~= "table" then return end

    for _, info in ipairs(list) do
        local button = create("TextButton", {
            Size = UDim2.new(1, -8, 0, 30),
            BackgroundColor3 = Color3.fromRGB(55, 65, 90),
            Text = info.DisplayName .. " (@" .. info.Name .. ")",
            TextColor3 = Color3.new(1,1,1),
            TextSize = 12,
            Font = Enum.Font.Gotham,
        }, playerList)

        button.MouseButton1Click:Connect(function()
            selectedId = info.UserId
            selectedLabel.Text = "Selected: " .. info.Name
        end)
    end

    task.wait()
    playerList.CanvasSize = UDim2.new(
        0, 0, 0,
        playerList.UIListLayout.AbsoluteContentSize.Y + 5
    )
end

local function action(name)
    if not selectedId then
        selectedLabel.Text = "Select a player first!"
        return
    end

    local ok, result, message = pcall(function()
        return remote:InvokeServer(name, selectedId)
    end)

    if not ok then
        selectedLabel.Text = "Request failed!"
    elseif result then
        selectedLabel.Text = name .. " successful!"
    else
        selectedLabel.Text = message or "Action failed!"
    end
end

local function button(name, x, y, callback, color)
    local b = create("TextButton", {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(145, 38),
        BackgroundColor3 = color or Color3.fromRGB(55, 95, 190),
        Text = name,
        TextColor3 = Color3.new(1,1,1),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
    }, frame)

    create("UICorner", {
        CornerRadius = UDim.new(0, 7)
    }, b)

    b.MouseButton1Click:Connect(callback)
end

button("Refresh Players", 12, 225, refreshPlayers)
button("Kick Player", 173, 225, function()
    action("Kick")
end, Color3.fromRGB(180, 75, 65))

button("Ban Player", 12, 270, function()
    action("Ban")
end, Color3.fromRGB(170, 50, 60))

button("Teleport To Player", 173, 270, function()
    action("Teleport")
end)

button("Give Tools", 12, 315, function()
    action("GiveTools")
end)

-- Fly toggle
button("Toggle Fly", 173, 315, function()
    flying = not flying

    if not flying then
        if flyConnection then flyConnection:Disconnect() end
        if flyVelocity then flyVelocity:Destroy() end
        if flyGyro then flyGyro:Destroy() end
        flyVelocity = nil
        flyGyro = nil

        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if h then h.PlatformStand = false end
        return
    end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then
        flying = false
        return
    end

    humanoid.PlatformStand = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    flyGyro.P = 10000
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then return end

        local camera = workspace.CurrentCamera
        local direction = Vector3.zero

        if UIS:IsKeyDown(Enum.KeyCode.W) then
            direction += camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.S) then
            direction -= camera.CFrame.LookVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            direction -= camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.D) then
            direction += camera.CFrame.RightVector
        end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then
            direction += Vector3.yAxis
        end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
            direction -= Vector3.yAxis
        end

        flyVelocity.Velocity = direction.Magnitude > 0
            and direction.Unit * 55 or Vector3.zero

        flyGyro.CFrame = camera.CFrame
    end)
end)

button("Close Panel", 12, 370, function()
    frame.Visible = false
end, Color3.fromRGB(80, 80, 90))

refreshPlayers()
