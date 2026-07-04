-- Heroes Battlegrounds - Script Sigiloso v3
-- Uso en ejecutor:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/HB_Sigiloso.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character
local Humanoid
local HRP

local NoDashCD = false
local SpeedBoost = false
local AntiStun = false
local AntiRagdoll = false
local HitboxExp = false

local defaultWalkSpeed = 16
local boostedWalkSpeed = 25

local function ApplyWalkSpeed()
    if Humanoid then
        Humanoid.WalkSpeed = SpeedBoost and boostedWalkSpeed or defaultWalkSpeed
    end
end

local function UpdateCharacter(char)
    Character = char
    Humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    HRP = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    ApplyWalkSpeed()
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HB_Sigiloso"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 300)
MainFrame.Position = UDim2.new(0.4, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BackgroundTransparency = 0.4
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 10)
FrameCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.BackgroundTransparency = 0.15
Title.Text = "⚡ HB Sigiloso"
Title.TextColor3 = Color3.fromRGB(255, 210, 120)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, 0, 0, 20)
InfoLabel.Position = UDim2.new(0, 0, 0, 40)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "RIGHT SHIFT para ocultar | Arrastra para mover"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.TextSize = 13
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Parent = MainFrame

local function CreateButton(text, positionY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Position = UDim2.new(0.05, 0, positionY, 0)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 15
    btn.Text = text .. ": OFF"
    btn.BorderSizePixel = 0
    btn.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    return btn
end

local DashBtn = CreateButton("🚀 No Dash CD", 0.18)
local SpeedBtn = CreateButton("⚡ Speed Boost", 0.32)
local StunBtn = CreateButton("🛡️ Anti Stun", 0.46)
local RagdollBtn = CreateButton("🎯 Anti Ragdoll", 0.60)
local HitboxBtn = CreateButton("📦 Hitbox Expand", 0.74)

local function UpdateButton(button, enabled)
    local label = button.Text:match("^.+:") or button.Text
    button.Text = label .. " " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(70, 70, 70)
end

DashBtn.MouseButton1Click:Connect(function()
    NoDashCD = not NoDashCD
    UpdateButton(DashBtn, NoDashCD)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    SpeedBoost = not SpeedBoost
    UpdateButton(SpeedBtn, SpeedBoost)
    ApplyWalkSpeed()
end)

StunBtn.MouseButton1Click:Connect(function()
    AntiStun = not AntiStun
    UpdateButton(StunBtn, AntiStun)
end)

RagdollBtn.MouseButton1Click:Connect(function()
    AntiRagdoll = not AntiRagdoll
    UpdateButton(RagdollBtn, AntiRagdoll)
end)

HitboxBtn.MouseButton1Click:Connect(function()
    HitboxExp = not HitboxExp
    UpdateButton(HitboxBtn, HitboxExp)
end)

local dragging = false
local dragStart
local dragInput
local startPos

MainFrame.InputBegan:Connect(function(input)
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

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging and dragStart and startPos then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local function DestroyDashCooldownParts(root)
    if not root then
        return
    end
    for _, child in ipairs(root:GetDescendants()) do
        local name = child.Name:lower()
        if name:find("dash") and name:find("cooldown") then
            child:Destroy()
        end
    end
end

local function ExpandHitboxes(tool)
    if not tool then
        return
    end
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("BasePart") then
            local name = child.Name:lower()
            if name:find("hitbox") then
                child.Size = Vector3.new(15, 15, 15)
                child.Transparency = 1
                child.CanCollide = false
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        return
    end

    if NoDashCD and input.KeyCode == Enum.KeyCode.Q then
        task.spawn(function()
            task.wait(0.12)
            DestroyDashCooldownParts(Character)
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if not Humanoid then
        return
    end

    if SpeedBoost and Humanoid.WalkSpeed ~= boostedWalkSpeed then
        Humanoid.WalkSpeed = boostedWalkSpeed
    elseif not SpeedBoost and Humanoid.WalkSpeed ~= defaultWalkSpeed then
        Humanoid.WalkSpeed = defaultWalkSpeed
    end

    if AntiStun then
        if Humanoid.WalkSpeed < 10 then
            ApplyWalkSpeed()
        end
    end

    if AntiRagdoll and HRP then
        if Humanoid.PlatformStand then
            Humanoid.PlatformStand = false
        end
        if Humanoid.Sit then
            Humanoid.Sit = false
        end
        Humanoid.AutoRotate = true
        HRP.AssemblyLinearVelocity = Vector3.new(
            HRP.AssemblyLinearVelocity.X * 0.6,
            math.max(HRP.AssemblyLinearVelocity.Y, 0),
            HRP.AssemblyLinearVelocity.Z * 0.6
        )
        HRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    end

    if NoDashCD then
        DestroyDashCooldownParts(Character)
    end

    if HitboxExp and Character then
        local tool = Character:FindFirstChildOfClass("Tool")
        if tool then
            ExpandHitboxes(tool)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    UpdateCharacter(newChar)
end)

print("✅ HB Sigiloso cargado")
print("🚀 No Dash CD - Dash ilimitado")
print("⚡ Speed Boost - Velocidad aumentada")
print("🛡️ Anti Stun - No te aturden")
print("🎯 Anti Ragdoll - No caes")
print("📦 Hitbox Expand - Mayor alcance")
print("Presiona RIGHT SHIFT para ocultar GUI")
