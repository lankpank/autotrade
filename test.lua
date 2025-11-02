-- Mobile Fly & Noclip Script
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- States
local flying = false
local noclip = false
local flySpeed = 25

-- Create Mobile GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileFlyGui"
screenGui.Parent = player.PlayerGui

-- Fly Toggle Button
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(0, 100, 0, 50)
flyButton.Position = UDim2.new(0, 20, 0, 20)
flyButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
flyButton.TextColor3 = Color3.white
flyButton.Text = "FLY: OFF"
flyButton.TextScaled = true
flyButton.Parent = screenGui

-- Noclip Toggle Button
local noclipButton = Instance.new("TextButton")
noclipButton.Name = "NoclipButton"
noclipButton.Size = UDim2.new(0, 100, 0, 50)
noclipButton.Position = UDim2.new(0, 20, 0, 80)
noclipButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
noclipButton.TextColor3 = Color3.white
noclipButton.Text = "NOCLIP: OFF"
noclipButton.TextScaled = true
noclipButton.Parent = screenGui

-- Speed Controls
local speedUpButton = Instance.new("TextButton")
speedUpButton.Name = "SpeedUp"
speedUpButton.Size = UDim2.new(0, 80, 0, 40)
speedUpButton.Position = UDim2.new(0, 130, 0, 20)
speedUpButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedUpButton.TextColor3 = Color3.white
speedUpButton.Text = "SPEED+"
speedUpButton.TextScaled = true
speedUpButton.Parent = screenGui

local speedDownButton = Instance.new("TextButton")
speedDownButton.Name = "SpeedDown"
speedDownButton.Size = UDim2.new(0, 80, 0, 40)
speedDownButton.Position = UDim2.new(0, 130, 0, 70)
speedDownButton.BackgroundColor3 = Color3.fromRGB(33, 150, 243)
speedDownButton.TextColor3 = Color3.white
speedDownButton.Text = "SPEED-"
speedDownButton.TextScaled = true
speedDownButton.Parent = screenGui

-- Movement Buttons (WASD + Up/Down)
local moveForward = Instance.new("TextButton")
moveForward.Name = "Forward"
moveForward.Size = UDim2.new(0, 80, 0, 40)
moveForward.Position = UDim2.new(0.5, -40, 1, -120)
moveForward.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveForward.TextColor3 = Color3.white
moveForward.Text = "W"
moveForward.TextScaled = true
moveForward.Parent = screenGui

local moveBackward = Instance.new("TextButton")
moveBackward.Name = "Backward"
moveBackward.Size = UDim2.new(0, 80, 0, 40)
moveBackward.Position = UDim2.new(0.5, -40, 1, -60)
moveBackward.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveBackward.TextColor3 = Color3.white
moveBackward.Text = "S"
moveBackward.TextScaled = true
moveBackward.Parent = screenGui

local moveLeft = Instance.new("TextButton")
moveLeft.Name = "Left"
moveLeft.Size = UDim2.new(0, 80, 0, 40)
moveLeft.Position = UDim2.new(0.5, -130, 1, -90)
moveLeft.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveLeft.TextColor3 = Color3.white
moveLeft.Text = "A"
moveLeft.TextScaled = true
moveLeft.Parent = screenGui

local moveRight = Instance.new("TextButton")
moveRight.Name = "Right"
moveRight.Size = UDim2.new(0, 80, 0, 40)
moveRight.Position = UDim2.new(0.5, 50, 1, -90)
moveRight.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveRight.TextColor3 = Color3.white
moveRight.Text = "D"
moveRight.TextScaled = true
moveRight.Parent = screenGui

local moveUp = Instance.new("TextButton")
moveUp.Name = "Up"
moveUp.Size = UDim2.new(0, 60, 0, 40)
moveUp.Position = UDim2.new(1, -80, 1, -120)
moveUp.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveUp.TextColor3 = Color3.white
moveUp.Text = "UP"
moveUp.TextScaled = true
moveUp.Parent = screenGui

local moveDown = Instance.new("TextButton")
moveDown.Name = "Down"
moveDown.Size = UDim2.new(0, 60, 0, 40)
moveDown.Position = UDim2.new(1, -80, 1, -60)
moveDown.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
moveDown.TextColor3 = Color3.white
moveDown.Text = "DOWN"
moveDown.TextScaled = true
moveDown.Parent = screenGui

-- Movement state tracking
local moveDirection = Vector3.new(0, 0, 0)
local bodyVelocity

-- Toggle Flying
local function toggleFlying()
    flying = not flying
    
    if flying then
        -- Enable flying
        humanoid.PlatformStand = true
        
        -- Create BodyVelocity for movement
        bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        bodyVelocity.Parent = rootPart
        
        flyButton.BackgroundColor3 = Color3.fromRGB(56, 142, 60)
        flyButton.Text = "FLY: ON"
    else
        -- Disable flying
        humanoid.PlatformStand = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        flyButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        flyButton.Text = "FLY: OFF"
    end
end

-- Toggle Noclip
local function toggleNoclip()
    noclip = not noclip
    
    if noclip then
        noclipButton.BackgroundColor3 = Color3.fromRGB(198, 40, 40)
        noclipButton.Text = "NOCLIP: ON"
    else
        noclipButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
        noclipButton.Text = "NOCLIP: OFF"
    end
end

-- Noclip function
local function noclipLoop()
    if noclip and character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

-- Update movement based on button states
local function updateMovement()
    if not flying or not bodyVelocity then return end
    
    local camera = workspace.CurrentCamera
    local moveVector = Vector3.new(0, 0, 0)
    
    -- Forward/Backward
    if moveDirection.Z > 0 then
        moveVector = moveVector + camera.CFrame.LookVector
    elseif moveDirection.Z < 0 then
        moveVector = moveVector - camera.CFrame.LookVector
    end
    
    -- Left/Right
    if moveDirection.X < 0 then
        moveVector = moveVector - camera.CFrame.RightVector
    elseif moveDirection.X > 0 then
        moveVector = moveVector + camera.CFrame.RightVector
    end
    
    -- Up/Down
    moveVector = moveVector + Vector3.new(0, moveDirection.Y, 0)
    
    -- Apply movement
    if moveVector.Magnitude > 0 then
        bodyVelocity.Velocity = moveVector.Unit * flySpeed
    else
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
end

-- Button event handlers
flyButton.MouseButton1Click:Connect(toggleFlying)
noclipButton.MouseButton1Click:Connect(toggleNoclip)

speedUpButton.MouseButton1Click:Connect(function()
    flySpeed = math.min(flySpeed + 5, 100)
end)

speedDownButton.MouseButton1Click:Connect(function()
    flySpeed = math.max(flySpeed - 5, 5)
end)

-- Movement button handlers
local function setupMoveButton(button, axis, value)
    button.MouseButton1Down:Connect(function()
        if axis == "X" then
            moveDirection = Vector3.new(value, moveDirection.Y, moveDirection.Z)
        elseif axis == "Y" then
            moveDirection = Vector3.new(moveDirection.X, value, moveDirection.Z)
        elseif axis == "Z" then
            moveDirection = Vector3.new(moveDirection.X, moveDirection.Y, value)
        end
    end)
    
    button.MouseButton1Up:Connect(function()
        if axis == "X" then
            moveDirection = Vector3.new(0, moveDirection.Y, moveDirection.Z)
        elseif axis == "Y" then
            moveDirection = Vector3.new(moveDirection.X, 0, moveDirection.Z)
        elseif axis == "Z" then
            moveDirection = Vector3.new(moveDirection.X, moveDirection.Y, 0)
        end
    end)
    
    button.TouchLongPress:Connect(function()
        button.MouseButton1Down:Fire()
    end)
end

-- Setup movement buttons
setupMoveButton(moveForward, "Z", 1)    -- W
setupMoveButton(moveBackward, "Z", -1)  -- S
setupMoveButton(moveLeft, "X", -1)      -- A
setupMoveButton(moveRight, "X", 1)      -- D
setupMoveButton(moveUp, "Y", 1)         -- Up
setupMoveButton(moveDown, "Y", -1)      -- Down

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Reset states
    flying = false
    noclip = false
    moveDirection = Vector3.new(0, 0, 0)
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
    
    -- Reset button colors
    flyButton.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
    flyButton.Text = "FLY: OFF"
    noclipButton.BackgroundColor3 = Color3.fromRGB(244, 67, 54)
    noclipButton.Text = "NOCLIP: OFF"
end)

-- Main loop
RunService.Heartbeat:Connect(function()
    if flying then
        updateMovement()
    end
    noclipLoop()
end)

print("Mobile Fly & Noclip Script Loaded!")
print("Use the buttons on screen to control flying and noclip")
