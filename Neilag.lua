-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-----------------------------------------------------------
-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ServerCrasherGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Frame (modern design)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 140)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -70)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
}
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1
UIStroke.Color = Color3.fromRGB(50, 50, 60)
UIStroke.Transparency = 0.8
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 16)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Server Control"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 20
TitleLabel.Parent = TitleBar

-- Minimize and Close Buttons
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
MinimizeButton.Position = UDim2.new(1, -72, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
MinimizeButton.Text = "–"
MinimizeButton.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextSize = 20
MinimizeButton.Parent = TitleBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -36, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 20
CloseButton.Parent = TitleBar

for _, btn in pairs({MinimizeButton, CloseButton}) do
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn
end

-- Content Frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -44)
ContentFrame.Position = UDim2.new(0, 10, 0, 38)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- Lag Server Button
local LagServerButton = Instance.new("TextButton")
LagServerButton.Size = UDim2.new(1, 0, 0, 50)
LagServerButton.Position = UDim2.new(0, 0, 0.5, -25)
LagServerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
LagServerButton.Text = "Lag Server: OFF"
LagServerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LagServerButton.Font = Enum.Font.SourceSansSemibold
LagServerButton.TextSize = 18
LagServerButton.Parent = ContentFrame

local ButtonCorner = Instance.new("UICorner")
ButtonCorner.CornerRadius = UDim.new(0, 12)
ButtonCorner.Parent = LagServerButton

local ButtonStroke = Instance.new("UIStroke")
ButtonStroke.Thickness = 1
ButtonStroke.Color = Color3.fromRGB(60, 60, 70)
ButtonStroke.Parent = LagServerButton

-----------------------------------------------------------
-- Draggable Functionality
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Minimize and Close Functionality
local minimized = false
local expandedSize = UDim2.new(0, 320, 0, 140)
local minimizedSize = UDim2.new(0, 320, 0, 32)

MinimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ContentFrame.Visible = false
        MainFrame:TweenSize(minimizedSize, "Out", "Quad", 0.2, true)
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        MainFrame:TweenSize(expandedSize, "Out", "Quad", 0.2, true)
        MinimizeButton.Text = "–"
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-----------------------------------------------------------
-- Spectate Setup
local SpectateGui = Instance.new("ScreenGui")
SpectateGui.Name = "Spectate"
SpectateGui.Parent = localPlayer:WaitForChild("PlayerGui")
SpectateGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SpectateGui.ResetOnSpawn = false

local SpectateFrame = Instance.new("Frame")
SpectateFrame.Name = "SpectateFrame"
SpectateFrame.Parent = SpectateGui
SpectateFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SpectateFrame.BackgroundTransparency = 1
SpectateFrame.BorderSizePixel = 0
SpectateFrame.Position = UDim2.new(0, 0, 0.8, 0)
SpectateFrame.Size = UDim2.new(1, 0, 0.2, 0)
SpectateFrame.Visible = false

local LeftButton = Instance.new("TextButton")
LeftButton.Name = "Left"
LeftButton.Parent = SpectateFrame
LeftButton.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
LeftButton.BackgroundTransparency = 0.25
LeftButton.BorderSizePixel = 0
LeftButton.Position = UDim2.new(0.183150187, 0, 0.238433674, 0)
LeftButton.Size = UDim2.new(0.0688644722, 0, 0.514322877, 0)
LeftButton.Font = Enum.Font.FredokaOne
LeftButton.Text = "<"
LeftButton.TextColor3 = Color3.fromRGB(0, 0, 0)
LeftButton.TextScaled = true

local RightButton = Instance.new("TextButton")
RightButton.Name = "Right"
RightButton.Parent = SpectateFrame
RightButton.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
RightButton.BackgroundTransparency = 0.25
RightButton.BorderSizePixel = 0
RightButton.Position = UDim2.new(0.747985363, 0, 0.238433674, 0)
RightButton.Size = UDim2.new(0.0688644722, 0, 0.514322877, 0)
RightButton.Font = Enum.Font.FredokaOne
RightButton.Text = ">"
RightButton.TextColor3 = Color3.fromRGB(0, 0, 0)
RightButton.TextScaled = true

local PlayerDisplay = Instance.new("TextLabel")
PlayerDisplay.Name = "PlayerDisplay"
PlayerDisplay.Parent = SpectateFrame
PlayerDisplay.BackgroundTransparency = 1
PlayerDisplay.Position = UDim2.new(0.252014756, 0, 0.238433674, 0)
PlayerDisplay.Size = UDim2.new(0.495970696, 0, 0.514322877, 0)
PlayerDisplay.Font = Enum.Font.FredokaOne
PlayerDisplay.Text = "<player>"
PlayerDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerDisplay.TextScaled = true

local PlayerIndex = Instance.new("NumberValue")
PlayerIndex.Name = "PlayerIndex"
PlayerIndex.Parent = SpectateFrame
PlayerIndex.Value = 1

local UIStroke1 = Instance.new("UIStroke")
UIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke1.Thickness = 5
UIStroke1.Parent = LeftButton

local UIStroke2 = Instance.new("UIStroke")
UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke2.Thickness = 5
UIStroke2.Parent = RightButton

local UIStroke3 = Instance.new("UIStroke")
UIStroke3.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
UIStroke3.Thickness = 5
UIStroke3.Parent = PlayerDisplay

local allPlayers = {}
local function updatePlayers()
    allPlayers = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= localPlayer then -- Exclude LocalPlayer
            table.insert(allPlayers, plr)
        end
    end
    if #allPlayers == 0 then
        PlayerIndex.Value = 1
    elseif PlayerIndex.Value > #allPlayers then
        PlayerIndex.Value = #allPlayers
    end
end
updatePlayers()

Players.PlayerAdded:Connect(updatePlayers)
Players.PlayerRemoving:Connect(updatePlayers)

local function onPress(skip)
    if #allPlayers == 0 then return end
    local newIndex = PlayerIndex.Value + skip
    if newIndex > #allPlayers then
        PlayerIndex.Value = 1
    elseif newIndex < 1 then
        PlayerIndex.Value = #allPlayers
    else
        PlayerIndex.Value = newIndex
    end
end

LeftButton.MouseButton1Click:Connect(function() onPress(-1) end)
RightButton.MouseButton1Click:Connect(function() onPress(1) end)
LeftButton.TouchTap:Connect(function() onPress(-1) end)
RightButton.TouchTap:Connect(function() onPress(1) end)

local cam = workspace.CurrentCamera
local spectating = false

RunService.RenderStepped:Connect(function()
    if spectating and #allPlayers > 0 then
        local targetPlayer = allPlayers[PlayerIndex.Value]
        if targetPlayer and targetPlayer.Character then
            cam.CameraSubject = targetPlayer.Character:WaitForChild("Humanoid", 5)
            PlayerDisplay.Text = targetPlayer.Name
        end
    elseif not spectating then
        if localPlayer.Character then
            cam.CameraSubject = localPlayer.Character:WaitForChild("Humanoid", 5)
            PlayerDisplay.Text = localPlayer.Name
        end
    end
end)

local function updateStrokeThickness()
    local screenSize = workspace.CurrentCamera.ViewportSize
    local scaleFactor = screenSize.X / 1920
    UIStroke1.Thickness = 5 * scaleFactor * 1.25
    UIStroke2.Thickness = 5 * scaleFactor * 1.25
    UIStroke3.Thickness = 5 * scaleFactor * 1.25
end
RunService.RenderStepped:Connect(updateStrokeThickness)

-----------------------------------------------------------
-- Lag Server Functionality
local lagToggled = false
local lagEnabled = false
local ragdollConnection
local lastModifiedUsername
local buttonCooldown = false

local ragdollEvent = ReplicatedStorage:FindFirstChild("RagdollEvent")
local unragdollEvent = ReplicatedStorage:FindFirstChild("UnragdollEvent")
local ToggleDisallowEvent = ReplicatedStorage:WaitForChild("ToggleDisallowEvent")
local ModifyUserEvent = ReplicatedStorage:WaitForChild("ModifyUserEvent")
local ModifyUsername_upvr = ReplicatedStorage:WaitForChild("ModifyUsername")
local micEvent = ReplicatedStorage:WaitForChild("MicEvent")

local function setVelocityToZero(part)
    if part then
        part.AssemblyLinearVelocity = Vector3.zero
        part.AssemblyAngularVelocity = Vector3.zero
    end
end

local function isDonutInInventory()
    for _, item in ipairs(localPlayer.Backpack:GetChildren()) do
        if item.Name == "GradientDonut" then
            return true
        end
    end
    return false
end

local function loopFunction()
    while lagToggled do
        micEvent:FireServer("GradientDonut")
        if isDonutInInventory() then
            local donut = localPlayer.Backpack:FindFirstChild("GradientDonut")
            if donut then
                donut.Parent = localPlayer.Character
            end
        end
        wait(2)
    end
end

local function toggleRagdoll()
    local character = localPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if lagEnabled then
        -- 1. Start spectating
        updatePlayers()
        if #allPlayers > 0 then
            spectating = true
            SpectateFrame.Visible = true
            PlayerIndex.Value = 1 -- Start with the first valid player
            wait(1) -- Brief delay to ensure spectating starts
        end

        -- 2. Move LocalPlayer to (4224, 26, 62)
        if rootPart then
            rootPart.CFrame = CFrame.new(4224, 26, 62)
            wait(0.5) -- Small delay to ensure position update
        end

        -- 3. Lag the server
        if lagToggled then
            lastModifiedUsername = "izakf166"
            ModifyUsername_upvr:FireServer("izakf166")
            wait(1)
        else
            ToggleDisallowEvent:FireServer()
            ModifyUserEvent:FireServer(localPlayer.Name)
            wait(1)
            ToggleDisallowEvent:FireServer()
        end

        if humanoid then humanoid.PlatformStand = true end
        if rootPart then rootPart.Anchored = true end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = true
                setVelocityToZero(part)
            end
        end

        ragdollEvent:FireServer()
        wait(0.2)
        local oldCFrame = rootPart.CFrame * CFrame.new(0, 2, 0) * CFrame.Angles(math.rad(-90), 0, 0)
        local offset = 100000
        ragdollConnection = RunService.Heartbeat:Connect(function()
            if not character or not lagEnabled then return end
            local parts = {
                Head = oldCFrame * CFrame.new(0, 0, -offset/2),
                UpperTorso = oldCFrame * CFrame.new(0, offset, 0),
                LowerTorso = oldCFrame * CFrame.new(0, -offset/2, 0),
                RightUpperArm = oldCFrame * CFrame.new(offset, 0, 0),
                RightLowerArm = oldCFrame * CFrame.new(offset*1.5, 0, 0),
                RightHand = oldCFrame * CFrame.new(offset*2, 0, 0),
                LeftUpperArm = oldCFrame * CFrame.new(-offset, 0, 0),
                LeftLowerArm = oldCFrame * CFrame.new(-offset*1.5, 0, 0),
                LeftHand = oldCFrame * CFrame.new(-offset*2, 0, 0),
                RightUpperLeg = oldCFrame * CFrame.new(offset/2, -offset, 0),
                RightLowerLeg = oldCFrame * CFrame.new(offset/2, -offset*1.5, 0),
                RightFoot = oldCFrame * CFrame.new(offset/2, -offset*2, 0),
                LeftUpperLeg = oldCFrame * CFrame.new(-offset/2, -offset, 0),
                LeftLowerLeg = oldCFrame * CFrame.new(-offset/2, -offset*1.5, 0),
                LeftFoot = oldCFrame * CFrame.new(-offset/2, -offset*2, 0)
            }
            for partName, cf in pairs(parts) do
                local part = character:FindFirstChild(partName)
                if part then
                    part.CFrame = cf
                    setVelocityToZero(part)
                end
            end
        end)
        
        if lagToggled then
            spawn(loopFunction)
        end
    else
        -- 1. Stop lag server
        unragdollEvent:FireServer()
        if ragdollConnection then
            ragdollConnection:Disconnect()
        end
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Anchored = false
            end
        end
        if humanoid then
            humanoid.PlatformStand = false
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        ToggleDisallowEvent:FireServer()
        ModifyUserEvent:FireServer(localPlayer.Name)
        wait(0.5) -- Reduced from 1 to 0.5
        ToggleDisallowEvent:FireServer()

        -- 2. Move character back to a default position
        if rootPart then
            rootPart.CFrame = CFrame.new(0, 50, 0) -- Adjust to a safe location in the game
        end
        wait(1) -- Reduced from 2 to 1

        -- 3. Stop spectating
        spectating = false
        SpectateFrame.Visible = false
    end
end

LagServerButton.MouseButton1Click:Connect(function()
    if buttonCooldown then return end -- Prevent clicking during cooldown

    -- Toggle the lag state
    lagToggled = not lagToggled
    lagEnabled = lagToggled
    LagServerButton.Text = "Lag Server: " .. (lagToggled and "ON" or "OFF")
    LagServerButton.BackgroundColor3 = lagToggled and Color3.fromRGB(60, 40, 40) or Color3.fromRGB(40, 40, 45)

    -- Start the toggle process
    toggleRagdoll()

    -- Apply 10-second cooldown
    buttonCooldown = true
    LagServerButton.TextTransparency = 0.5 -- Dim the text to indicate cooldown
    LagServerButton.AutoButtonColor = false -- Disable button interaction visually
    spawn(function()
        wait(10) -- 10-second cooldown
        buttonCooldown = false
        LagServerButton.TextTransparency = 0 -- Restore text visibility
        LagServerButton.AutoButtonColor = true -- Re-enable button interaction
    end)
end)

-----------------------------------------------------------
-- Anti Lag (ON by default)
local targetItemNames = {"aura", "Fluffy Satin Gloves Black"}
local antiLagToggled = true

local function hasItemInName(accessory)
    for _, itemName in pairs(targetItemNames) do
        if accessory.Name:lower():find(itemName:lower()) then
            return true
        end
    end
    return false
end

local function isAccessoryOnHeadOrAbove(accessory)
    local handle = accessory:FindFirstChild("Handle")
    if handle and handle.Parent and handle.Parent.Name == "Head" then return true end
    local attachment = accessory:FindFirstChildWhichIsA("Attachment")
    if attachment and attachment.Parent and attachment.Parent.Name == "Head" then return true end
    if accessory.Parent and accessory.Parent:IsA("Model") then
        local head = accessory.Parent:FindFirstChild("Head")
        if head and handle and handle.Position.Y >= head.Position.Y then return true end
    end
    return false
end

local function removeTargetedItems(character)
    if not character then return end
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Accessory") and hasItemInName(item) and not isAccessoryOnHeadOrAbove(item) then
            item:Destroy()
        end
    end
end

local function removeGradientDonuts()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and string.lower(obj.Name):find("gradientdonut") then
            obj:Destroy()
        end
    end
end

local function continuouslyCheckItems()
    while antiLagToggled do
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                removeTargetedItems(player.Character)
            end
        end
        removeGradientDonuts()
        wait(1)
    end
end

spawn(continuouslyCheckItems) -- Start Anti-Lag by default

-----------------------------------------------------------
-- Notification System
local playerGui = localPlayer:WaitForChild("PlayerGui")
local screenGui = playerGui:FindFirstChild("NotificationGui") or Instance.new("ScreenGui", playerGui)
screenGui.Name = "NotificationGui"

local activeNotifications = {}

local function createNotification()
    local notification = Instance.new("Frame", screenGui)
    notification.Name = "Notification"
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.BackgroundTransparency = 0
    notification.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    notification.Visible = false

    local uiCorner = Instance.new("UICorner", notification)
    uiCorner.CornerRadius = UDim.new(0, 16)

    local uiShadow = Instance.new("UIStroke", notification)
    uiShadow.Name = "UIShadow"
    uiShadow.Thickness = 2
    uiShadow.Color = Color3.fromRGB(0, 0, 0)
    uiShadow.Transparency = 0.7
    uiShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local pfpFrame = Instance.new("Frame", notification)
    pfpFrame.Name = "PfpFrame"
    pfpFrame.Size = UDim2.new(0, 70, 0, 70)
    pfpFrame.Position = UDim2.new(0, 5, 0, 5)
    pfpFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    pfpFrame.BackgroundTransparency = 0.4
    local pfpFrameCorner = Instance.new("UICorner", pfpFrame)
    pfpFrameCorner.CornerRadius = UDim.new(0, 35)

    local profilePicture = Instance.new("ImageLabel", pfpFrame)
    profilePicture.Name = "ProfilePicture"
    profilePicture.Size = UDim2.new(0, 60, 0, 60)
    profilePicture.Position = UDim2.new(0, 5, 0, 5)
    profilePicture.BackgroundTransparency = 1
    local picCorner = Instance.new("UICorner", profilePicture)
    picCorner.CornerRadius = UDim.new(0, 30)

    local notificationText = Instance.new("TextLabel", notification)
    notificationText.Name = "NotificationText"
    notificationText.Size = UDim2.new(0, 220, 0, 60)
    notificationText.Position = UDim2.new(0, 80, 0, 10)
    notificationText.BackgroundTransparency = 1
    notificationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notificationText.TextSize = 18
    notificationText.Font = Enum.Font.GothamBold
    notificationText.TextXAlignment = Enum.TextXAlignment.Left
    notificationText.TextScaled = true
    notificationText.TextWrapped = true

    local notificationSound = Instance.new("Sound", notification)
    notificationSound.SoundId = "rbxassetid://1862047553"
    notificationSound.Volume = 3

    return notification, profilePicture, notificationText, notificationSound
end

local function showNotification(leavingPlayer)
    local notification, profilePicture, notificationText, notificationSound = createNotification()
    table.insert(activeNotifications, notification)

    notificationText.Text = leavingPlayer.Name .. " has left the server."
    local success, content = pcall(function()
        return Players:GetUserThumbnailAsync(leavingPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    profilePicture.Image = success and content or "rbxassetid://0"

    pcall(function()
        notificationSound:Play()
    end)

    local baseX = 1
    local baseOffsetX = -notification.Size.X.Offset - 10
    local baseOffsetY = -notification.Size.Y.Offset - 10
    local stackOffset = (#activeNotifications - 1) * -90

    local startPos = UDim2.new(baseX, baseOffsetX, 1, baseOffsetY + stackOffset + 80)
    local showPos = UDim2.new(baseX, baseOffsetX, 1, baseOffsetY + stackOffset)

    notification.Position = startPos
    notification.Visible = true

    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local showTween = TweenService:Create(notification, tweenInfo, {Position = showPos})
    showTween:Play()

    for i, activeNotif in ipairs(activeNotifications) do
        if activeNotif ~= notification then
            local newPos = UDim2.new(baseX, baseOffsetX, 1, baseOffsetY + (i - 1) * -90)
            activeNotif.Position = newPos
        end
    end

    task.spawn(function()
        task.wait(3)

        local hideTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local hidePos = UDim2.new(baseX, baseOffsetX + 310, 1, baseOffsetY + stackOffset)
        local hideTween = TweenService:Create(notification, hideTweenInfo, {Position = hidePos})
        hideTween:Play()
        hideTween.Completed:Wait()

        notification:Destroy()
        local index = table.find(activeNotifications, notification)
        if index then
            table.remove(activeNotifications, index)
        end

        for i, activeNotif in ipairs(activeNotifications) do
            local newPos = UDim2.new(baseX, baseOffsetX, 1, baseOffsetY + (i - 1) * -90)
            activeNotif.Position = newPos
        end
    end)
end

Players.PlayerRemoving:Connect(function(leavingPlayer)
    pcall(function()
        showNotification(leavingPlayer)
    end)
end)
