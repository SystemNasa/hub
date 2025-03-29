-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Local Player
local player = Players.LocalPlayer

-- Body Copy Logic
local bodyParts = {"Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "HumanoidRootPart"}
local offsetMagnitude = 5
local updateConnection

local function findPlayer(displayName)
    displayName = displayName:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.DisplayName:lower():match(displayName) or p.Name:lower():match(displayName) then
            return p
        end
    end
    return nil
end

local function getOffset(targetCFrame)
    if selectedDirection == "Side" then
        return targetCFrame.RightVector * (-offsetMagnitude)
    elseif selectedDirection == "Front" then
        return targetCFrame.LookVector * offsetMagnitude
    elseif selectedDirection == "Behind" then
        return targetCFrame.LookVector * (-offsetMagnitude)
    end
end

local function activateBodyCopy(target)
    if not target or not target.Character then
        warn("Target player not found or has no character!")
        return
    end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then 
        warn("Local player character not loaded!")
        return 
    end

    workspace.Gravity = 0
    for _, partName in ipairs(bodyParts) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    if ReplicatedStorage:FindFirstChild("RagdollEvent") then
        ReplicatedStorage.RagdollEvent:FireServer()
    end
    if target.Character and target.Character:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
    end
    getgenv().Running = true

    updateConnection = RunService.RenderStepped:Connect(function()
        if not getgenv().Running then updateConnection:Disconnect() return end
        local localChar = player.Character
        local targetChar = target.Character
        if localChar and targetChar then
            local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if targetHRP and targetHRP.Position then
                local offset = getOffset(targetHRP.CFrame)
                for _, partName in ipairs(bodyParts) do
                    local localPart = localChar:FindFirstChild(partName)
                    local targetPart = targetChar:FindFirstChild(partName)
                    if localPart and targetPart and localPart:IsA("BasePart") and targetPart:IsA("BasePart") then
                        localPart.CFrame = targetPart.CFrame + offset
                    end
                end
            end
        end
    end)
    print("Body Copy activated with direction: " .. selectedDirection)
end

local function deactivateBodyCopy()
    getgenv().Running = false
    if updateConnection then
        updateConnection:Disconnect()
    end
    workspace.Gravity = 196.2
    local char = player.Character
    if ReplicatedStorage:FindFirstChild("UnragdollEvent") then
        ReplicatedStorage.UnragdollEvent:FireServer()
    end
    for _, seat in pairs(workspace:GetDescendants()) do
        if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
            seat.Disabled = false
            seat.CanCollide = true
        end
    end
    if char and char:FindFirstChild("Humanoid") then
        workspace.CurrentCamera.CameraSubject = char.Humanoid
    end
    NameBox.Text = ""
    CrossButton.Visible = false
    selectedTarget = nil
    print("Body Copy deactivated!")
end

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BodyCopyGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 350)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local FrameGradient = Instance.new("UIGradient")
FrameGradient.Rotation = 90
FrameGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 0.6)
})
FrameGradient.Parent = MainFrame

local GlassBorder = Instance.new("Frame")
GlassBorder.Size = UDim2.new(1, 0, 1, 0)
GlassBorder.BackgroundTransparency = 1
GlassBorder.BorderSizePixel = 1
GlassBorder.BorderColor3 = Color3.fromRGB(255, 255, 255)
GlassBorder.BorderMode = Enum.BorderMode.Inset
GlassBorder.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.BackgroundTransparency = 0.9
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "BODY COPY TOOL"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 16
TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local dragging = false
local dragInput, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local SearchLabel = Instance.new("TextLabel")
SearchLabel.Size = UDim2.new(0.9, 0, 0, 20)
SearchLabel.Position = UDim2.new(0.05, 0, 0, 50)
SearchLabel.BackgroundTransparency = 1
SearchLabel.Text = "PLAYER TO COPY:"
SearchLabel.Font = Enum.Font.Gotham
SearchLabel.TextSize = 12
SearchLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SearchLabel.TextXAlignment = Enum.TextXAlignment.Left
SearchLabel.Parent = MainFrame

local NameBox = Instance.new("TextBox")
NameBox.Size = UDim2.new(0.9, 0, 0, 40)
NameBox.Position = UDim2.new(0.05, 0, 0, 70)
NameBox.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
NameBox.BackgroundTransparency = 0.5
NameBox.BorderSizePixel = 0
NameBox.Text = ""
NameBox.PlaceholderText = "Enter Display Name..."
NameBox.Font = Enum.Font.Gotham
NameBox.TextSize = 14
NameBox.TextColor3 = Color3.fromRGB(240, 240, 240)
NameBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 190)
NameBox.ClearTextOnFocus = false
NameBox.Parent = MainFrame

local NameBoxCorner = Instance.new("UICorner")
NameBoxCorner.CornerRadius = UDim.new(0, 8)
NameBoxCorner.Parent = NameBox

local CrossButton = Instance.new("TextButton")
CrossButton.Size = UDim2.new(0, 30, 0, 30)
CrossButton.Position = UDim2.new(1, -35, 0, 5)
CrossButton.BackgroundTransparency = 1
CrossButton.Text = "✕"
CrossButton.TextSize = 20
CrossButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CrossButton.Font = Enum.Font.GothamBold
CrossButton.Visible = false
CrossButton.Parent = NameBox

local PositionLabel = Instance.new("TextLabel")
PositionLabel.Size = UDim2.new(0.9, 0, 0, 20)
PositionLabel.Position = UDim2.new(0.05, 0, 0, 110) -- Positioned just below NameBox
PositionLabel.BackgroundTransparency = 1
PositionLabel.Text = "POSITION:"
PositionLabel.Font = Enum.Font.Gotham
PositionLabel.TextSize = 12
PositionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PositionLabel.TextXAlignment = Enum.TextXAlignment.Left
PositionLabel.Parent = MainFrame

local PositionDropdown = Instance.new("Frame")
PositionDropdown.Size = UDim2.new(0.9, 0, 0, 40)
PositionDropdown.Position = UDim2.new(0.05, 0, 0, 130) -- Positioned below PositionLabel
PositionDropdown.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
PositionDropdown.BackgroundTransparency = 0.5
PositionDropdown.BorderSizePixel = 0
PositionDropdown.Parent = MainFrame

local PositionCorner = Instance.new("UICorner")
PositionCorner.CornerRadius = UDim.new(0, 8)
PositionCorner.Parent = PositionDropdown

local PositionButton = Instance.new("TextButton")
PositionButton.Size = UDim2.new(1, -40, 1, 0)
PositionButton.BackgroundTransparency = 1
PositionButton.Text = "Side"
PositionButton.Font = Enum.Font.Gotham
PositionButton.TextSize = 14
PositionButton.TextColor3 = Color3.fromRGB(240, 240, 240)
PositionButton.TextXAlignment = Enum.TextXAlignment.Left
PositionButton.Parent = PositionDropdown

local DropdownArrow = Instance.new("TextLabel")
DropdownArrow.Size = UDim2.new(0, 30, 0, 30)
DropdownArrow.Position = UDim2.new(1, -35, 0, 5)
DropdownArrow.BackgroundTransparency = 1
DropdownArrow.Text = "▼"
DropdownArrow.Font = Enum.Font.Gotham
DropdownArrow.TextSize = 14
DropdownArrow.TextColor3 = Color3.fromRGB(240, 240, 240)
DropdownArrow.Parent = PositionDropdown

local PositionDropdownList = Instance.new("Frame")
PositionDropdownList.Size = UDim2.new(0.9, 0, 0, 90)
PositionDropdownList.Position = UDim2.new(0.05, 0, 0, 170) -- Positioned below PositionDropdown
PositionDropdownList.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
PositionDropdownList.BackgroundTransparency = 0.2
PositionDropdownList.BorderSizePixel = 0
PositionDropdownList.Visible = false
PositionDropdownList.ZIndex = 5
PositionDropdownList.Parent = MainFrame

local PositionListCorner = Instance.new("UICorner")
PositionListCorner.CornerRadius = UDim.new(0, 8)
PositionListCorner.Parent = PositionDropdownList

local PositionListLayout = Instance.new("UIListLayout")
PositionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PositionListLayout.Padding = UDim.new(0, 2)
PositionListLayout.Parent = PositionDropdownList

local PlayerDropdown = Instance.new("Frame")
PlayerDropdown.Size = UDim2.new(0.9, 0, 0, 150)
PlayerDropdown.Position = UDim2.new(0.05, 0, 0, 260) -- Moved down to accommodate position dropdown
PlayerDropdown.BackgroundColor3 = Color3.fromRGB(40, 43, 48)
PlayerDropdown.BackgroundTransparency = 0.2
PlayerDropdown.BorderSizePixel = 0
PlayerDropdown.Visible = false
PlayerDropdown.ZIndex = 2
PlayerDropdown.Parent = MainFrame

local PlayerDropdownCorner = Instance.new("UICorner")
PlayerDropdownCorner.CornerRadius = UDim.new(0, 8)
PlayerDropdownCorner.Parent = PlayerDropdown

local PlayerDropdownList = Instance.new("ScrollingFrame")
PlayerDropdownList.Size = UDim2.new(1, 0, 1, 0)
PlayerDropdownList.BackgroundTransparency = 1
PlayerDropdownList.BorderSizePixel = 0
PlayerDropdownList.ScrollBarThickness = 4
PlayerDropdownList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
PlayerDropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerDropdownList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerDropdownList.Parent = PlayerDropdown

local PlayerListLayout = Instance.new("UIListLayout")
PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
PlayerListLayout.Padding = UDim.new(0, 5)
PlayerListLayout.Parent = PlayerDropdownList

local directions = {"Side", "Front", "Behind"}
local selectedDirection = "Side"
local selectedTarget = nil

for i, dir in ipairs(directions) do
    local option = Instance.new("TextButton")
    option.Size = UDim2.new(1, -10, 0, 28)
    option.Position = UDim2.new(0, 5, 0, 0)
    option.BackgroundColor3 = Color3.fromRGB(60, 65, 70)
    option.BackgroundTransparency = 0.5
    option.Text = dir
    option.Font = Enum.Font.Gotham
    option.TextSize = 14
    option.TextColor3 = Color3.fromRGB(240, 240, 240)
    option.LayoutOrder = i
    option.Parent = PositionDropdownList

    local optionCorner = Instance.new("UICorner")
    optionCorner.CornerRadius = UDim.new(0, 6)
    optionCorner.Parent = option

    option.MouseEnter:Connect(function()
        TweenService:Create(option, TweenInfo.new(0.2), {BackgroundTransparency = 0.3, TextColor3 = Color3.fromRGB(130, 150, 230)}):Play()
    end)
    
    option.MouseLeave:Connect(function()
        TweenService:Create(option, TweenInfo.new(0.2), {BackgroundTransparency = 0.5, TextColor3 = Color3.fromRGB(240, 240, 240)}):Play()
    end)

    option.MouseButton1Click:Connect(function()
        selectedDirection = dir
        PositionButton.Text = dir
        PositionDropdownList.Visible = false
        if selectedTarget then
            deactivateBodyCopy()
            activateBodyCopy(selectedTarget)
        end
    end)
end

PositionButton.MouseButton1Click:Connect(function()
    PositionDropdownList.Visible = not PositionDropdownList.Visible
    PlayerDropdown.Visible = false
end)

local function createPlayerEntry(playerObj)
    local entry = Instance.new("Frame")
    entry.Size = UDim2.new(1, 0, 0, 40)
    entry.BackgroundColor3 = Color3.fromRGB(50, 55, 60)
    entry.BackgroundTransparency = 0.5
    entry.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = entry
    
    local pfp = Instance.new("ImageLabel")
    pfp.Size = UDim2.new(0, 30, 0, 30)
    pfp.Position = UDim2.new(0, 5, 0.5, -15)
    pfp.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    pfp.BorderSizePixel = 0
    pfp.Image = "rbxthumb://type=AvatarHeadShot&id="..playerObj.UserId.."&w=150&h=150"
    pfp.Parent = entry
    
    local pfpCorner = Instance.new("UICorner")
    pfpCorner.CornerRadius = UDim.new(1, 0)
    pfpCorner.Parent = pfp
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -45, 1, 0)
    nameLabel.Position = UDim2.new(0, 40, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = playerObj.DisplayName .. " (@"..playerObj.Name..")"
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = entry
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = entry
    
    button.MouseEnter:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(entry, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        NameBox.Text = playerObj.DisplayName .. " (@"..playerObj.Name..")"
        selectedTarget = playerObj
        PlayerDropdown.Visible = false
        CrossButton.Visible = true
        activateBodyCopy(playerObj)
    end)
    
    return entry
end

local function updatePlayerDropdown(searchText)
    for _, child in ipairs(PlayerDropdownList:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    searchText = searchText:lower()
    local players = Players:GetPlayers()
    local matches = {}
    
    for _, p in ipairs(players) do
        if p ~= player and (p.DisplayName:lower():find(searchText) or p.Name:lower():find(searchText)) then
            table.insert(matches, p)
        end
    end
    
    table.sort(matches, function(a, b)
        return a.DisplayName:lower() < b.DisplayName:lower()
    end)
    
    for _, p in ipairs(matches) do
        local entry = createPlayerEntry(p)
        entry.Parent = PlayerDropdownList
    end
    
    PlayerDropdown.Visible = #matches > 0
    PositionDropdownList.Visible = false
end

NameBox:GetPropertyChangedSignal("Text"):Connect(function()
    if not selectedTarget then
        updatePlayerDropdown(NameBox.Text)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        
        local playerBoxPos = NameBox.AbsolutePosition
        local playerBoxSize = NameBox.AbsoluteSize
        local playerDropdownPos = PlayerDropdown.AbsolutePosition
        local playerDropdownSize = PlayerDropdown.AbsoluteSize
        
        if not (mousePos.X >= playerBoxPos.X and mousePos.X <= playerBoxPos.X + playerBoxSize.X and
               mousePos.Y >= playerBoxPos.Y and mousePos.Y <= playerDropdownPos.Y + playerDropdownSize.Y) then
            PlayerDropdown.Visible = false
        end
        
        local positionBoxPos = PositionDropdown.AbsolutePosition
        local positionBoxSize = PositionDropdown.AbsoluteSize
        local positionDropdownPos = PositionDropdownList.AbsolutePosition
        local positionDropdownSize = PositionDropdownList.AbsoluteSize
        
        if not (mousePos.X >= positionBoxPos.X and mousePos.X <= positionBoxPos.X + positionBoxSize.X and
               mousePos.Y >= positionBoxPos.Y and mousePos.Y <= positionDropdownPos.Y + positionDropdownSize.Y) then
            PositionDropdownList.Visible = false
        end
    end
end)

CrossButton.MouseButton1Click:Connect(function()
    deactivateBodyCopy()
end)

CrossButton.MouseEnter:Connect(function()
    TweenService:Create(CrossButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
end)

CrossButton.MouseLeave:Connect(function()
    TweenService:Create(CrossButton, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
