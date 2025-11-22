--====================================================
-- LOAD UI SUEPHUB
--====================================================
local SuepHub = loadstring(game:HttpGet("https://pastebin.com/SQ4s7zgy"))()

local Window = SuepHub:CreateWindow("SuepHub | Fish It")

local CreditsTab  = Window:CreateTab("Credits")
local FishingTab  = Window:CreateTab("Fishing")
local AutoFarmTab = Window:CreateTab("AutoFarm")
local TpTab       = Window:CreateTab("Teleports")
local MiscTab     = Window:CreateTab("Misc")

--====================================================
-- SERVICES
--====================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local StarterPack       = game:GetService("StarterPack")
local player            = Players.LocalPlayer

--====================================================
-- REMOTES FISHING
--====================================================
local StartRemote  = ReplicatedStorage:WaitForChild("FishingStart")
local ReelRemote   = ReplicatedStorage:WaitForChild("FishingReel")
local NotifyRemote = ReplicatedStorage:WaitForChild("FishingNotify")

--====================================================
-- KONFIGURASI FISHING
--====================================================
local DEV = {
    autoFish         = false,
    autoPerfection   = true,
    speedMultiplier  = 1.0,
    instantCatch     = true,
    superFast        = 0,
    delayMode        = 1.0,
    autoEquipRadar   = true,
    animationEnabled = false,
}

--====================================================
-- UI FISHING STATUS
--====================================================
local screen = Instance.new("ScreenGui")
screen.Name = "FishingUI"
screen.ResetOnSpawn = false
screen.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 70)
main.Position = UDim2.new(0, 15, 0, 15)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screen

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -10, 0, 20)
status.Position = UDim2.new(0, 5, 0, 5)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(255,255,255)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.Parent = main

local barBack = Instance.new("Frame")
barBack.Size = UDim2.new(1, -10, 0, 14)
barBack.Position = UDim2.new(0, 5, 0, 35)
barBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBack.Parent = main

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
bar.Parent = barBack

local function setStatus(t)
    status.Text = t
end

local function setProgress(p)
    bar.Size = UDim2.new(math.clamp(p,0,1),0,1,0)
end

--====================================================
-- FUNGSI FISHING
--====================================================
local isFishing = false
local startTick = 0
local biteTick  = nil

local function getSpeed()
    return DEV.speedMultiplier * (DEV.superFast > 0 and DEV.superFast or 1)
end

local function autoRadar()
    if not DEV.autoEquipRadar then return end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        local radar = bp:FindFirstChild("FishingRadar")
        if radar then
            local char = player.Character or player.CharacterAdded:Wait()
            char:WaitForChild("Humanoid"):EquipTool(radar)
        end
    end
end

local function startFishing()
    if isFishing then return end
    isFishing = true
    startTick = tick()
    setStatus("Casting...")
    setProgress(0)

    StartRemote:FireServer(startTick, {
        speed = getSpeed(),
        delay = DEV.delayMode
    })

    autoRadar()
end

NotifyRemote.OnClientEvent:Connect(function(data)
    if not data or not data.event then return end

    if data.event == "Started" then
        setStatus("Waiting for bite...")
        local target = data.when or tick()

        task.spawn(function()
            while isFishing and tick() < target do
                local total = target - startTick
                setProgress((tick()-startTick)/total)
                task.wait(0.03)
            end
        end)

    elseif data.event == "Bite" then
        setStatus("Fish biting!")
        setProgress(1)

        if DEV.instantCatch then
            ReelRemote:FireServer(0)
            return
        end

        local speed = math.max(getSpeed(), 0.01)

        if DEV.autoPerfection then
            local t = 3.0/speed
            task.delay(t, function()
                if isFishing then
                    ReelRemote:FireServer(tick()-startTick)
                end
            end)
        elseif DEV.autoFish then
            local t = 3.0/speed
            ReelRemote:FireServer(t)
        end

    elseif data.event == "Result" then
        isFishing = false
        setStatus("Result: "..(data.result.quality or "OK"))
        task.wait(1.5)
        setStatus("Ready")
        setProgress(0)
    end
end)

UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.E and isFishing then
        ReelRemote:FireServer(tick() - startTick)
    end
end)

task.spawn(function()
    while true do
        if DEV.autoFish and not isFishing then
            startFishing()
        end
        task.wait(0.6)
    end
end)

--====================================================
-- UI: FISHING TAB
--====================================================
local FS = FishingTab:CreateSection("Fishing Controls")

FS:CreateButton("Start Fishing", function()
    startFishing()
end)

FS:CreateToggle("Auto Fish", false, function(v)
    DEV.autoFish = v
end)

FS:CreateToggle("Instant Catch", true, function(v)
    DEV.instantCatch = v
end)

FS:CreateToggle("Auto Perfection", true, function(v)
    DEV.autoPerfection = v
end)

FS:CreateToggle("Auto Radar", true, function(v)
    DEV.autoEquipRadar = v
end)

FS:CreateSlider("Speed Multiplier", 1, 50, 10, function(v)
    DEV.speedMultiplier = v/10
end)

--====================================================
-- AUTOFARM
--====================================================
local AutoSection = AutoFarmTab:CreateSection("Autofarms")

local farm = {
    kohana = false,
    coral  = false,
    depths = false
}

local platform

local function makePlatform()
    if platform then platform:Destroy() end
    platform = Instance.new("Part")
    platform.Size = Vector3.new(6,1,6)
    platform.Anchored = true
    platform.Parent = workspace
end

local function doFarm(pos, key)
    makePlatform()
    task.spawn(function()
        while farm[key] do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(pos)
                platform.Position = pos - Vector3.new(0,3,0)
                mouse1click()
            end
            task.wait()
        end
    end)
end

AutoSection:CreateToggle("Autofarm Kohana", false, function(v)
    farm.kohana = v
    if v then
        doFarm(Vector3.new(-759.09,24.3,429.12),"kohana")
    end
end)

AutoSection:CreateToggle("Autofarm Coral", false, function(v)
    farm.coral = v
    if v then
        doFarm(Vector3.new(-3222.68,9.97,1898.06),"coral")
    end
end)

AutoSection:CreateToggle("Autofarm Depths", false, function(v)
    farm.depths = v
    if v then
        doFarm(Vector3.new(3239.96,-1298.21,1353.69),"depths")
    end
end)

--====================================================
-- TELEPORT
--====================================================
local TpSection = TpTab:CreateSection("TP")

local tpList = {
    ["Starter Island"] = Vector3.new(23,4,2868),
    ["Kohana Island"]  = Vector3.new(-842,55,146),
    ["Kohana Volcano"] = Vector3.new(-606,59,105),
    ["Coral Reefs"]    = Vector3.new(-2853,47,1988),
    ["The Depths"]     = Vector3.new(2002,12,1385),
    ["Altar Enchant"]  = Vector3.new(3177,-1302,1427),
}

for name, pos in pairs(tpList) do
    TpSection:CreateButton("Teleport to "..name, function()
        local hrp = player.Character.HumanoidRootPart
        hrp.CFrame = CFrame.new(pos)
    end)
end

--====================================================
-- MISC
--====================================================
local Misc = MiscTab:CreateSection("Extra")

Misc:CreateButton("Load Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

Misc:CreateToggle("Auto Collect Items", false, function(v)
    getgenv().autoCollect = v
    task.spawn(function()
        while getgenv().autoCollect do
            for _,tool in pairs(workspace:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    tool.Handle.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end
            task.wait()
        end
    end)
end)

Misc:CreateSlider("WalkSpeed", 16, 500, 16, function(val)
    player.Character.Humanoid.WalkSpeed = val
end)

--====================================================

print("SuepHub | Fish It Script Loaded Successfully!")
