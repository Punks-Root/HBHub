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

local originalWalkSpeed = 16
local defaultBoostedWalkSpeed = 25
local currentBoostedWalkSpeed = defaultBoostedWalkSpeed
local dashBoostSpeed = 80
local dashBoostDuration = 0.18
local dashing = false
local dashEndTime = 0
local dashVelocityPart
local savedKeyStatus = LocalPlayer:GetAttribute("HBKeyStatus") or "inactive"
local trialActive = false

local function UpdateBoostedSpeed()
    if Humanoid then
        currentBoostedWalkSpeed = math.max(defaultBoostedWalkSpeed, originalWalkSpeed * 1.7)
    end
end

local function GetTargetWalkSpeed()
    if not Humanoid then
        return originalWalkSpeed
    end

    if dashing then
        return dashBoostSpeed
    end

    if SpeedBoost then
        return currentBoostedWalkSpeed
    end

    return originalWalkSpeed
end

local function ApplyWalkSpeed()
    if Humanoid and not dashing then
        Humanoid.WalkSpeed = GetTargetWalkSpeed()
    end
end

local function UpdateCharacter(char)
    Character = char
    Humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
    HRP = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
    originalWalkSpeed = Humanoid.WalkSpeed or originalWalkSpeed
    UpdateBoostedSpeed()
    if SpeedBoost then
        Humanoid.WalkSpeed = currentBoostedWalkSpeed
    else
        ApplyWalkSpeed()
    end
end

if LocalPlayer.Character then
    UpdateCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(UpdateCharacter)

-- GUI
local TweenService = game:GetService("TweenService")
local ActivationKeys = {
    "KEY-ALPHA-1234567890",
    "KEY-BETA-0987654321",
    "KEY-GAMMA-1122334455"
}
local permanentUnlocked = false
local panelHidden = false
local compactMode = false

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HB_Sigiloso"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 390)
MainFrame.Position = UDim2.new(0.4, 0, 0.18, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 12)
FrameCorner.Parent = MainFrame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(90, 120, 180)
Stroke.Thickness = 1.2
Stroke.Parent = MainFrame

local AccentBar = Instance.new("Frame")
AccentBar.Size = UDim2.new(1, 0, 0, 3)
AccentBar.Position = UDim2.new(0, 0, 0, 0)
AccentBar.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
AccentBar.BorderSizePixel = 0
AccentBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 0, 38)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "⚡ HB Sigiloso"
Title.TextColor3 = Color3.fromRGB(255, 220, 140)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local HideBtn = Instance.new("TextButton")
HideBtn.Size = UDim2.new(0, 30, 0, 30)
HideBtn.Position = UDim2.new(1, -40, 0, 10)
HideBtn.BackgroundColor3 = Color3.fromRGB(72, 72, 84)
HideBtn.Text = "—"
HideBtn.TextColor3 = Color3.new(1, 1, 1)
HideBtn.Font = Enum.Font.GothamBold
HideBtn.TextSize = 16
HideBtn.BorderSizePixel = 0
HideBtn.Visible = false
HideBtn.Parent = MainFrame

local HideBtnCorner = Instance.new("UICorner")
HideBtnCorner.CornerRadius = UDim.new(0, 8)
HideBtnCorner.Parent = HideBtn

local CompactBtn = Instance.new("TextButton")
CompactBtn.Size = UDim2.new(0, 30, 0, 30)
CompactBtn.Position = UDim2.new(1, -76, 0, 10)
CompactBtn.BackgroundColor3 = Color3.fromRGB(72, 72, 84)
CompactBtn.Text = "□"
CompactBtn.TextColor3 = Color3.new(1, 1, 1)
CompactBtn.Font = Enum.Font.GothamBold
CompactBtn.TextSize = 14
CompactBtn.BorderSizePixel = 0
CompactBtn.Visible = false
CompactBtn.Parent = MainFrame

local CompactBtnCorner = Instance.new("UICorner")
CompactBtnCorner.CornerRadius = UDim.new(0, 8)
CompactBtnCorner.Parent = CompactBtn

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 18)
InfoLabel.Position = UDim2.new(0, 10, 0, 48)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "Introduce la key que conseguiste en Discord"
InfoLabel.TextColor3 = Color3.fromRGB(180, 190, 210)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.Parent = MainFrame

local AccessFrame = Instance.new("Frame")
AccessFrame.Size = UDim2.new(1, -16, 0, 88)
AccessFrame.Position = UDim2.new(0, 8, 0, 70)
AccessFrame.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
AccessFrame.BorderSizePixel = 0
AccessFrame.Parent = MainFrame

local AccessCorner = Instance.new("UICorner")
AccessCorner.CornerRadius = UDim.new(0, 10)
AccessCorner.Parent = AccessFrame

local AccessTitle = Instance.new("TextLabel")
AccessTitle.Size = UDim2.new(1, -12, 0, 18)
AccessTitle.Position = UDim2.new(0, 6, 0, 6)
AccessTitle.BackgroundTransparency = 1
AccessTitle.Text = "Acceso"
AccessTitle.TextColor3 = Color3.fromRGB(255, 220, 140)
AccessTitle.TextSize = 13
AccessTitle.Font = Enum.Font.GothamBold
AccessTitle.TextXAlignment = Enum.TextXAlignment.Left
AccessTitle.Parent = AccessFrame

AccessStatusLabel = Instance.new("TextLabel")
AccessStatusLabel.Size = UDim2.new(1, -12, 0, 20)
AccessStatusLabel.Position = UDim2.new(0, 6, 0, 24)
AccessStatusLabel.BackgroundTransparency = 1
AccessStatusLabel.Text = "Introduce la key desde Discord"
AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
AccessStatusLabel.TextSize = 12
AccessStatusLabel.Font = Enum.Font.Gotham
AccessStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
AccessStatusLabel.Parent = AccessFrame

KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.62, 0, 0, 24)
KeyBox.Position = UDim2.new(0, 6, 0, 48)
KeyBox.BackgroundColor3 = Color3.fromRGB(36, 40, 50)
KeyBox.TextColor3 = Color3.new(1, 1, 1)
KeyBox.PlaceholderText = "Key permanente"
KeyBox.PlaceholderColor3 = Color3.fromRGB(140, 150, 170)
KeyBox.TextSize = 12
KeyBox.Font = Enum.Font.Gotham
KeyBox.ClearTextOnFocus = false
KeyBox.BorderSizePixel = 0
KeyBox.Parent = AccessFrame

local KeyBoxCorner = Instance.new("UICorner")
KeyBoxCorner.CornerRadius = UDim.new(0, 6)
KeyBoxCorner.Parent = KeyBox

local ActivateKeyBtn = Instance.new("TextButton")
ActivateKeyBtn.Size = UDim2.new(0.3, -6, 0, 24)
ActivateKeyBtn.Position = UDim2.new(0.62, 6, 0, 48)
ActivateKeyBtn.BackgroundColor3 = Color3.fromRGB(90, 140, 220)
ActivateKeyBtn.Text = "Activar"
ActivateKeyBtn.TextColor3 = Color3.new(1, 1, 1)
ActivateKeyBtn.Font = Enum.Font.GothamBold
ActivateKeyBtn.TextSize = 12
ActivateKeyBtn.BorderSizePixel = 0
ActivateKeyBtn.Parent = AccessFrame

local ActivateKeyCorner = Instance.new("UICorner")
ActivateKeyCorner.CornerRadius = UDim.new(0, 6)
ActivateKeyCorner.Parent = ActivateKeyBtn

local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.new(1, -16, 0, 220)
ButtonsFrame.Position = UDim2.new(0, 8, 0, 168)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = MainFrame

local function CreateButton(text, positionY)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.Position = UDim2.new(0, 0, 0, positionY)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.Text = text .. ": OFF"
    btn.BorderSizePixel = 0
    btn.Parent = ButtonsFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(90, 100, 120)
    stroke.Thickness = 0.8
    stroke.Parent = btn

    return btn
end

local DashBtn = CreateButton("🚀 No Dash CD", 0)
local SpeedBtn = CreateButton("⚡ Speed Boost", 40)
local StunBtn = CreateButton("🛡️ Anti Stun", 80)
local RagdollBtn = CreateButton("🎯 Anti Ragdoll", 120)
local HitboxBtn = CreateButton("📦 Hitbox Expand", 160)
ButtonsFrame.Visible = true

local function UpdateButton(button, enabled)
    local label = button.Text:match("^.+:") or button.Text
    button.Text = label .. " " .. (enabled and "ON" or "OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(80, 150, 80) or Color3.fromRGB(70, 70, 80)
end

local function SetPanelVisible(visible)
    panelHidden = not visible
    if visible then
        MainFrame.Visible = true
        FloatButton.Visible = false
        MainFrame.Position = UDim2.new(0.4, 0, 0.18, 0)
    else
        MainFrame.Visible = false
        FloatButton.Visible = true
    end
end

local function SetCompactMode(enabled)
    compactMode = enabled
    MainFrame.Size = UDim2.new(0, 260, 0, 210)
    ButtonsFrame.Visible = false
    AccessFrame.Position = UDim2.new(0, 8, 0, 70)
    AccessFrame.Size = UDim2.new(1, -16, 0, 88)
    AccessTitle.Visible = true
    AccessStatusLabel.Position = UDim2.new(0, 6, 0, 24)
    KeyBox.Visible = true
    ActivateKeyBtn.Visible = true
end

local function UpdateAccessUI()
    if permanentUnlocked then
        AccessStatusLabel.Text = "Key válida. Funciones activas."
        AccessStatusLabel.TextColor3 = Color3.fromRGB(120, 255, 145)
        ActivateKeyBtn.Text = "Activada"
        ActivateKeyBtn.BackgroundColor3 = Color3.fromRGB(55, 120, 75)
    else
        AccessStatusLabel.Text = "Introduce la key que conseguiste en Discord"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        ActivateKeyBtn.Text = "Activar"
        ActivateKeyBtn.BackgroundColor3 = Color3.fromRGB(90, 140, 220)
    end
end

local function ActivatePermanentKey()
    local entered = string.upper((KeyBox.Text or ""))
    local valid = false
    for _, key in ipairs(ActivationKeys) do
        if entered == key then
            valid = true
            break
        end
    end
    if valid then
        permanentUnlocked = true
        LocalPlayer:SetAttribute("HBKeyStatus", "active")
        UpdateAccessUI()
        SetCompactMode(false)
        UpdateButton(DashBtn, NoDashCD)
        UpdateButton(SpeedBtn, SpeedBoost)
        UpdateButton(StunBtn, AntiStun)
        UpdateButton(RagdollBtn, AntiRagdoll)
        UpdateButton(HitboxBtn, HitboxExp)
        KeyBox.Text = ""
    else
        KeyBox.Text = ""
        KeyBox.PlaceholderText = "Key incorrecta"
        AccessStatusLabel.Text = "Key incorrecta • usa Discord"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
    end
end

local function CanUseFeatures()
    return permanentUnlocked
end

DashBtn.MouseButton1Click:Connect(function()
    if not CanUseFeatures() then
        AccessStatusLabel.Text = "Activa la key primero para usar esto"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        return
    end
    NoDashCD = not NoDashCD
    UpdateButton(DashBtn, NoDashCD)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    if not CanUseFeatures() then
        AccessStatusLabel.Text = "Activa la key primero para usar esto"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        return
    end
    SpeedBoost = not SpeedBoost
    UpdateButton(SpeedBtn, SpeedBoost)
    if Humanoid then
        if SpeedBoost then
            UpdateBoostedSpeed()
            Humanoid.WalkSpeed = currentBoostedWalkSpeed
        else
            Humanoid.WalkSpeed = originalWalkSpeed
        end
    end
end)

StunBtn.MouseButton1Click:Connect(function()
    if not CanUseFeatures() then
        AccessStatusLabel.Text = "Activa la key primero para usar esto"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        return
    end
    AntiStun = not AntiStun
    UpdateButton(StunBtn, AntiStun)
end)

RagdollBtn.MouseButton1Click:Connect(function()
    if not CanUseFeatures() then
        AccessStatusLabel.Text = "Activa la key primero para usar esto"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        return
    end
    AntiRagdoll = not AntiRagdoll
    UpdateButton(RagdollBtn, AntiRagdoll)
end)

HitboxBtn.MouseButton1Click:Connect(function()
    if not CanUseFeatures() then
        AccessStatusLabel.Text = "Activa la key primero para usar esto"
        AccessStatusLabel.TextColor3 = Color3.fromRGB(255, 115, 115)
        return
    end
    HitboxExp = not HitboxExp
    UpdateButton(HitboxBtn, HitboxExp)
end)

HideBtn.MouseButton1Click:Connect(function()
    SetPanelVisible(false)
end)

CompactBtn.MouseButton1Click:Connect(function()
    SetCompactMode(not compactMode)
end)

ActivateKeyBtn.MouseButton1Click:Connect(function()
    ActivatePermanentKey()
end)

local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 54, 0, 54)
FloatButton.Position = UDim2.new(1, -68, 1, -70)
FloatButton.BackgroundColor3 = Color3.fromRGB(60, 95, 180)
FloatButton.Text = "HB"
FloatButton.TextColor3 = Color3.new(1, 1, 1)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.TextSize = 16
FloatButton.BorderSizePixel = 0
FloatButton.Visible = false
FloatButton.Parent = ScreenGui

local FloatButtonCorner = Instance.new("UICorner")
FloatButtonCorner.CornerRadius = UDim.new(0, 14)
FloatButtonCorner.Parent = FloatButton

FloatButton.MouseButton1Click:Connect(function()
    SetPanelVisible(true)
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

if savedKeyStatus == "active" then
    permanentUnlocked = true
else
    permanentUnlocked = false
end
UpdateAccessUI()
SetCompactMode(true)

SetCompactMode(true)

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

local function ClearDashVelocity()
    if dashVelocityPart and dashVelocityPart.Parent then
        dashVelocityPart:Destroy()
    end
    dashVelocityPart = nil
end

local function GetDashDirection()
    if not Humanoid or not HRP then
        return Vector3.new(0, 0, 0)
    end

    local moveVector = Vector3.new(0, 0, 0)
    local forward = Vector3.new(HRP.CFrame.LookVector.X, 0, HRP.CFrame.LookVector.Z).Unit
    local right = Vector3.new(HRP.CFrame.RightVector.X, 0, HRP.CFrame.RightVector.Z).Unit

    if UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up) then
        moveVector += forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down) then
        moveVector -= forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left) then
        moveVector -= right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right) then
        moveVector += right
    end

    if moveVector.Magnitude > 0 then
        return moveVector.Unit
    end

    local moveDirection = Humanoid.MoveDirection
    if moveDirection.Magnitude > 0 then
        return Vector3.new(moveDirection.X, 0, moveDirection.Z).Unit
    end

    return forward
end

local function ApplyDashBoost()
    if Humanoid and HRP and not dashing then
        dashing = true
        dashEndTime = tick() + dashBoostDuration
        Humanoid.WalkSpeed = dashBoostSpeed

        local dashDirection = GetDashDirection()

        ClearDashVelocity()
        dashVelocityPart = Instance.new("BodyVelocity")
        dashVelocityPart.Name = "HB_DashVelocity"
        dashVelocityPart.MaxForce = Vector3.new(1e5, 0, 1e5)
        dashVelocityPart.P = 1250
        dashVelocityPart.Velocity = dashDirection * dashBoostSpeed
        dashVelocityPart.Parent = HRP
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
        SetPanelVisible(not MainFrame.Visible)
        return
    end

    if NoDashCD and input.KeyCode == Enum.KeyCode.Q and CanUseFeatures() then
        DestroyDashCooldownParts(Character)
        ApplyDashBoost()
    end
end)

RunService.Heartbeat:Connect(function()
    if not Humanoid then
        return
    end

    if dashing then
        if tick() >= dashEndTime then
            dashing = false
            ClearDashVelocity()
            ApplyWalkSpeed()
        end
    end

    if CanUseFeatures() then
        if AntiStun and Humanoid and HRP then
            local state = Humanoid:GetState()
            local stunnedState = state == Enum.HumanoidStateType.Frozen
                or state == Enum.HumanoidStateType.GettingUp
                or state == Enum.HumanoidStateType.PlatformStanding
                or state == Enum.HumanoidStateType.Ragdoll
                or state == Enum.HumanoidStateType.Seated

            if stunnedState then
                Humanoid.PlatformStand = false
                Humanoid.Sit = false
                Humanoid.AutoRotate = true

                local targetSpeed = GetTargetWalkSpeed()
                if Humanoid.WalkSpeed < targetSpeed then
                    Humanoid.WalkSpeed = math.min(targetSpeed, Humanoid.WalkSpeed + 2.5)
                else
                    Humanoid.WalkSpeed = targetSpeed
                end

                if Humanoid.JumpPower < 50 then
                    Humanoid.JumpPower = 50
                end
                if Humanoid.JumpHeight < 7.2 then
                    Humanoid.JumpHeight = 7.2
                end

                if HRP.AssemblyLinearVelocity.Magnitude < 8 then
                    HRP.AssemblyLinearVelocity = Vector3.new(HRP.AssemblyLinearVelocity.X * 0.7, math.max(HRP.AssemblyLinearVelocity.Y, 0), HRP.AssemblyLinearVelocity.Z * 0.7)
                end
            else
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
    end

    -- No trial countdown, solo key manual.
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
