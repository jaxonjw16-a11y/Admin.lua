
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local DataStoreService = game:GetService("DataStoreService")

local ADMINS = {
    [123456789] = true, -- UserID Here
}

local BanStore = DataStoreService:GetDataStore("AdminBans_V1")

local remote = Instance.new("RemoteFunction")
remote.Name = "AdminFunction"
remote.Parent = ReplicatedStorage

local function isAdmin(player)
    return ADMINS[player.UserId] == true
end

local function findPlayer(userId)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.UserId == userId then
            return p
        end
    end
end

-- Check bans when players join
Players.PlayerAdded:Connect(function(player)
    local success, banned = pcall(function()
        return BanStore:GetAsync(tostring(player.UserId))
    end)

    if success and banned == true then
        player:Kick("You are banned from this game.")
    end
end)

remote.OnServerInvoke = function(admin, action, targetId)
    if not isAdmin(admin) then
        return false, "Not authorized"
    end

    if action == "GetPlayers" then
        local list = {}

        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(list, {
                Name = p.Name,
                DisplayName = p.DisplayName,
                UserId = p.UserId
            })
        end

        return true, list
    end

    if action == "FlyPermission" then
        return true
    end

    if typeof(targetId) ~= "number" then
        return false, "Invalid player"
    end

    local target = findPlayer(targetId)

    if not target or target == admin then
        return false, "Player not found or invalid target"
    end

    if action == "Kick" then
        target:Kick("Removed by an administrator.")
        return true
    end

    if action == "Ban" then
        local success = pcall(function()
            BanStore:SetAsync(tostring(target.UserId), true)
        end)

        if not success then
            return false, "Ban could not be saved"
        end

        target:Kick("You have been banned.")
        return true
    end

    if action == "Teleport" then
        local adminCharacter = admin.Character
        local targetCharacter = target.Character

        if adminCharacter and targetCharacter then
            local root = targetCharacter:FindFirstChild("HumanoidRootPart")
            if root then
                adminCharacter:PivotTo(root.CFrame * CFrame.new(3, 0, 0))
                return true
            end
        end

        return false, "Character unavailable"
    end

    if action == "GiveTools" then
        local folder = ServerStorage:FindFirstChild("AdminTools")

        if not folder then
            return false, "AdminTools folder missing"
        end

        local backpack = target:FindFirstChild("Backpack")

        if backpack then
            for _, tool in ipairs(folder:GetChildren()) do
                if tool:IsA("Tool") then
                    tool:Clone().Parent = backpack
                end
            end
            return true
        end
    end

    return false, "Unknown action"
end
