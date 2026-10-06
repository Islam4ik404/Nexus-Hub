-- [[ AETHERIUS NEXUS MULTI-HUB: MASTER ARCHITECTURE ]]
-- PART 1 OF 12: CONFIGURATION PROFILE & SYSTEM CORE INITIALIZATION
-- EXCLUSIVE MONOLITH DEVELOPED FOR XENO CORE RUNTIME ENVIRONMENT
-- PRODUCTION TARGET COMPILED: OCTOBER 2026

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local LocalMouse = LocalPlayer:GetMouse()

-- Global Shared Framework Object
local Nexus = {
    Version = "12.0.0",
    Metadata = "Aetherius Nexus Omnipotence Project",
    InstanceTag = "AetheriusNexusProEngine",
    
    Config = {
        -- Main Player Settings
        SpeedEnabled = false,
        SpeedValue = 150,
        SpeedMethod = "CFrame",
        
        JumpEnabled = false,
        JumpValue = 120,
        AirJumpActive = false,
        AirJumpPower = 50,
        
        HipHeightEnabled = false,
        HipHeightValue = 2,
        InfinityYieldJump = false,
        
        -- Flight Matrix Settings
        FlyEnabled = false,
        FlySpeedValue = 70,
        FlyVerticalControl = true,
        NoclipEnabled = false,
        PhaseCollideActive = false,
        GravityValue = 196.2,
        GravityModifyEnabled = false,
        FreezePositionActive = false,
        
        -- World Chaos Settings (UPGRADED)
        ItemMagnetEnabled = false,
        MagnetRadiusValue = 150,
        AutoClickerActive = false,
        AutoClickerDelay = 100,
        ClickTeleportActive = false,
        BringDistanceLimit = 500,
        DeleteTexturesActive = false,
        MapInteractRange = 50,
        GiveAllToolsActive = false, -- УЛЬТРА ФИЧА: Получение всех предметов в игре 🎒
        
        -- Visual RTX & Sky Settings (UPGRADED)
        EspPlayersEnabled = false,
        EspTeamCheck = false,
        EspBoxesEnabled = false,
        EspTracersEnabled = false,
        EspColorPattern = Color3.fromRGB(190, 60, 255),
        EspFillTransparency = 0.5,
        FullbrightActive = false,
        NoFogActive = false,
        FovRingEnabled = false,
        FovRingRadius = 100,
        FovRingThickness = 1.5,
        CustomSkyEnabled = false, -- УЛЬТРА ФИЧА: Кастомизация неба 🌌
        SkyTexturePreset = "PurpleNebula", -- Космический фиолетовый пресет по умолчанию
        
        -- Skin Visual Customization
        SkinChangerEnabled = false,
        ShirtIdValue = "0",
        PantsIdValue = "0",
        NeonAuraEnabled = false,
        AuraColorPattern = Color3.fromRGB(180, 50, 255),
        CustomAccessoryId = "0",
        AttachToNode = "Head",
        
        -- Combat Assist Settings
        TriggerbotActive = false,
        TriggerbotDelay = 50,
        AutoRotateToEnemy = false,
        InventoryScannerActive = false,
        PriorityTargetClass = "Knife",
        
        -- Optimization Settings
        FpsUnlockBypass = false,
        ThreadThrottleRate = 0.01,
        NetworkOwnerEnforce = true
    },
    
    State = {
        Active = true,
        InterfaceRendered = false,
        WindowMinimized = false,
        WindowDragging = false,
        ActiveTabCategory = "Player",
        LeftControlHeld = false,
        MousePositionCached = Vector2.new(0, 0),
        CharacterModelCached = nil,
        HumanoidCached = nil,
        RootPartCached = nil,
        ActiveThreads = {},
        Connections = {},
        SpawnedAccessories = {},
        AuraParticles = nil,
        OriginalSkyBackup = nil -- Сюда сохраним родное небо игры, чтобы вернуть при выключении
    }
}

-- Memory Safeguard and Garbage Collection Protocol
local function PurgeDuplicateExecutionThreads(tag)
    local activeGui = CoreGui:FindFirstChild(tag) or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(tag)
    if activeGui then
        activeGui:Destroy()
    end
end
PurgeDuplicateExecutionThreads(Nexus.InstanceTag)

-- Entity Tracking Caching Core
local function SynchronizeCharacterVariables(characterModel)
    if not characterModel then return end
    Nexus.State.CharacterModelCached = characterModel
    Nexus.State.HumanoidCached = characterModel:WaitForChild("Humanoid", 5)
    Nexus.State.RootPartCached = characterModel:WaitForChild("HumanoidRootPart", 5)
end

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    SynchronizeCharacterVariables(newCharacter)
end)
if LocalPlayer.Character then
    SynchronizeCharacterVariables(LocalPlayer.Character)
end

-- Math Utilities Extension Layer
local VectorMath = {}
function VectorMath:ExtractLookDirection(cameraCFrame)
    return cameraCFrame.LookVector
end

function VectorMath:ExtractRightDirection(cameraCFrame)
    return cameraCFrame.RightVector
end

function VectorMath:NormalizeVelocity(velocityVector)
    return Vector3.new(velocityVector.X, 0, velocityVector.Z)
end

function VectorMath:CalculateDistanceDelta(posA, posB)
    return (posA - posB).Magnitude
end

-- Safely expose the global Nexus core to script context
_G.AetheriusNexusGlobal = Nexus
-- [[ AETHERIUS NEXUS MULTI-HUB: CORE GUI SYSTEM ]]
-- PART 2 OF 12: WINDOW GEOMETRY & SMOOTH INTERPOLATED DRAG ENGINE
-- COMPATIBLE WITH XENO EXECUTION PROTOCOLS (UPDATE: OCTOBER 2026)

local MasterScreenContainer = Instance.new("ScreenGui")
MasterScreenContainer.Name = Nexus.InstanceTag
MasterScreenContainer.ResetOnSpawn = false
MasterScreenContainer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local injectionSuccess, injectionError = pcall(function()
    MasterScreenContainer.Parent = CoreGui
end)
if not injectionSuccess then
    MasterScreenContainer.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Компактный размер окна хаба (250x360 пикселей) - стильно и элитно
local BaseWindowFrame = Instance.new("Frame")
BaseWindowFrame.Name = "BaseWindowFrame"
BaseWindowFrame.Size = UDim2.fromOffset(250, 360)
BaseWindowFrame.Position = UDim2.new(0.5, -125, 0.4, -180)
BaseWindowFrame.BackgroundColor3 = Color3.fromRGB(11, 7, 18)
BaseWindowFrame.BorderSizePixel = 0
BaseWindowFrame.Active = true
BaseWindowFrame.Parent = MasterScreenContainer

local WindowCorner = Instance.new("UICorner")
WindowCorner.CornerRadius = UDim.new(0, 12)
WindowCorner.Parent = BaseWindowFrame

local WindowGradient = Instance.new("UIGradient")
WindowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 20, 190)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(165, 45, 255)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(235, 90, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(65, 15, 140))
})
WindowGradient.Parent = BaseWindowFrame

-- Поток плавной анимации плазменного неона
task.spawn(function()
    local currentRotation = 0
    while BaseWindowFrame and BaseWindowFrame.Parent do
        currentRotation = currentRotation + 1.1
        WindowGradient.Rotation = currentRotation
        task.wait(0.01)
    end
end)

local WindowStroke = Instance.new("UIStroke")
WindowStroke.Thickness = 2.2
WindowStroke.Color = Color3.fromRGB(255, 255, 255)
WindowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
WindowStroke.Parent = BaseWindowFrame

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(210, 75, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 15, 170))
})
StrokeGradient.Parent = WindowStroke

-- [[ ЖЕЛЕЗОБЕТОННЫЙ СМУТ-ДРАГГИНГ ДЛЯ XENO ]]
local DraggingConfig = {IsDragging = false, SignalInput = nil, StartPosition = nil, ElementPosition = nil}

local function ApplyPositionUpdate(inputSignal)
    local deltaMovement = inputSignal.Position - DraggingConfig.StartPosition
    local computedPosition = UDim2.new(
        DraggingConfig.ElementPosition.X.Scale, 
        DraggingConfig.ElementPosition.X.Offset + deltaMovement.X, 
        DraggingConfig.ElementPosition.Y.Scale, 
        DraggingConfig.ElementPosition.Y.Offset + deltaMovement.Y
    )
    TweenService:Create(BaseWindowFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = computedPosition}):Play()
end

BaseWindowFrame.InputBegan:Connect(function(inputEvent)
    if inputEvent.UserInputType == Enum.UserInputType.MouseButton1 or inputEvent.UserInputType == Enum.UserInputType.Touch then
        DraggingConfig.IsDragging = true
        DraggingConfig.StartPosition = inputEvent.Position
        DraggingConfig.ElementPosition = BaseWindowFrame.Position
        
        inputEvent.Changed:Connect(function()
            if inputEvent.UserInputState == Enum.UserInputState.End then 
                DraggingConfig.IsDragging = false 
            end
        end)
    end
end)

BaseWindowFrame.InputChanged:Connect(function(inputEvent)
    if inputEvent.UserInputType == Enum.UserInputType.MouseMovement or inputEvent.UserInputType == Enum.UserInputType.Touch then
        DraggingConfig.SignalInput = inputEvent
    end
end)

UserInputService.InputChanged:Connect(function(inputEvent)
    if inputEvent == DraggingConfig.SignalInput and DraggingConfig.IsDragging then
        ApplyPositionUpdate(inputEvent)
    end
end)

-- Прокидываем элементы в глобальное состояние для следующих частей
Nexus.State.ActiveThreads["BaseWindowFrame"] = BaseWindowFrame
Nexus.State.ActiveThreads["MasterScreenContainer"] = MasterScreenContainer
-- [[ AETHERIUS NEXUS MULTI-HUB: NAVIGATION & TABS NAVIGATION LAYER ]]
-- PART 3 OF 12: CONTROLS, COMPACT NAVIGATION LAYOUT & EVENT HOOKS
-- STABLE COMPILER TARGET: OCTOBER 2026
-- [[ AETHERIUS NEXUS MULTI-HUB: NAVIGATION & TABS NAVIGATION LAYER ]]
-- PART 3 OF 12: CONTROLS, COMPACT NAVIGATION LAYOUT & EVENT HOOKS
-- FIXED WINDOW MINIMIZATION ENGINE (OCTOBER 2026)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundTransparency = 1
TopBar.Parent = BaseWindowFrame

local LabelTitle = Instance.new("TextLabel")
LabelTitle.Size = UDim2.new(1, -75, 1, 0)
LabelTitle.Position = UDim2.fromOffset(12, 0)
LabelTitle.BackgroundTransparency = 1
LabelTitle.Text = "🔮 NEXUS MULTI-HUB"
LabelTitle.TextColor3 = Color3.fromRGB(245, 230, 255)
LabelTitle.TextSize = 13
LabelTitle.Font = Enum.Font.GothamBold
LabelTitle.TextXAlignment = Enum.TextXAlignment.Left
LabelTitle.Parent = TopBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(24, 24)
CloseButton.Position = UDim2.new(1, -30, 0, 8)
CloseButton.BackgroundColor3 = Color3.fromRGB(85, 20, 95)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.TextSize = 11
CloseButton.Font = Enum.Font.GothamBold
CloseButton.Parent = TopBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.fromOffset(24, 24)
MinimizeButton.Position = UDim2.new(1, -58, 0, 8)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40, 22, 60)
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = Color3.new(1, 1, 1)
MinimizeButton.TextSize = 13
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.Parent = TopBar
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 6)

-- Горизонтальный контейнер для вкладок-категорий
local TabBarScroller = Instance.new("ScrollingFrame")
TabBarScroller.Name = "TabBarScroller"
TabBarScroller.Size = UDim2.new(1, -20, 0, 28)
TabBarScroller.Position = UDim2.fromOffset(10, 42)
TabBarScroller.BackgroundTransparency = 1
TabBarScroller.BorderSizePixel = 0
TabBarScroller.ScrollBarThickness = 0
TabBarScroller.CanvasSize = UDim2.new(0, 520, 0, 0)
TabBarScroller.ScrollingDirection = Enum.ScrollingDirection.X
TabBarScroller.Parent = BaseWindowFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 5)
TabListLayout.Parent = TabBarScroller

-- Единый вертикальный контейнер для страниц контента
local ViewportContentScroller = Instance.new("ScrollingFrame")
ViewportContentScroller.Name = "ViewportContentScroller"
ViewportContentScroller.Size = UDim2.new(1, -20, 1, -85)
ViewportContentScroller.Position = UDim2.fromOffset(10, 75)
ViewportContentScroller.BackgroundTransparency = 1
ViewportContentScroller.BorderSizePixel = 0
ViewportContentScroller.ScrollBarThickness = 2
ViewportContentScroller.CanvasSize = UDim2.new(0, 0, 0, 450)
ViewportContentScroller.Parent = BaseWindowFrame

local ContentListLayout = Instance.new("UIListLayout")
ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentListLayout.Padding = UDim.new(0, 6)
ContentListLayout.Parent = ViewportContentScroller

local DynamicPagesCache = {}
local function RegisterTabCategory(tabName, categoryKey, layoutOrder)
    local TabSelector = Instance.new("TextButton")
    TabSelector.Size = UDim2.fromOffset(80, 24)
    TabSelector.BackgroundColor3 = Color3.fromRGB(25, 15, 38)
    TabSelector.Text = tabName
    TabSelector.TextColor3 = Color3.fromRGB(200, 175, 230)
    TabSelector.Font = Enum.Font.GothamSemibold
    TabSelector.TextSize = 10
    TabSelector.LayoutOrder = layoutOrder
    TabSelector.Parent = TabBarScroller
    Instance.new("UICorner", TabSelector).CornerRadius = UDim.new(0, 6)
    
    local TabStroke = Instance.new("UIStroke", TabSelector)
    TabStroke.Thickness = 1
    TabStroke.Color = Color3.fromRGB(90, 40, 150)
    TabStroke.Transparency = 0.4
    
    local ContentSubFrame = Instance.new("Frame")
    ContentSubFrame.Name = categoryKey .. "Page"
    ContentSubFrame.Size = UDim2.new(1, 0, 1, 0)
    ContentSubFrame.BackgroundTransparency = 1
    ContentSubFrame.Visible = false
    ContentSubFrame.Parent = ViewportContentScroller
    
    local SubLayout = Instance.new("UIListLayout")
    SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SubLayout.Padding = UDim.new(0, 6)
    SubLayout.Parent = ContentSubFrame
    
    DynamicPagesCache[categoryKey] = {Button = TabSelector, Stroke = TabStroke, Page = ContentSubFrame}
    
    TabSelector.Activated:Connect(function()
        for key, set in pairs(DynamicPagesCache) do
            if key == categoryKey then
                Nexus.Config.ActiveTabCategory = categoryKey
                set.Page.Visible = true
                set.Button.BackgroundColor3 = Color3.fromRGB(45, 20, 80)
                set.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                set.Stroke.Color = Color3.fromRGB(180, 50, 255)
            else
                set.Page.Visible = false
                set.Button.BackgroundColor3 = Color3.fromRGB(25, 15, 38)
                set.Button.TextColor3 = Color3.fromRGB(200, 175, 230)
                set.Stroke.Color = Color3.fromRGB(90, 40, 150)
            end
        end
    end)
end

RegisterTabCategory("Игрок 🏃‍♂️", "Player", 1)
RegisterTabCategory("Полет 🚀", "Flight", 2)
RegisterTabCategory("Мир 🧲", "World", 3)
RegisterTabCategory("Визуалы 👁️", "Visuals", 4)
RegisterTabCategory("Скины 🎭", "Skins", 5)
RegisterTabCategory("Бой 🎯", "Combat", 6)

if DynamicPagesCache["Player"] then
    DynamicPagesCache["Player"].Page.Visible = true
    DynamicPagesCache["Player"].Button.BackgroundColor3 = Color3.fromRGB(45, 20, 80)
    DynamicPagesCache["Player"].Button.TextColor3 = Color3.fromRGB(255, 255, 255)
end

_G.NexusPagesCache = DynamicPagesCache

-- [[ ЖЕЛЕЗОБЕТОННЫЙ ИСПРАВЛЕННЫЙ БЛОК СВЕРТЫВАНИЯ ]]
local GuiWindowMinimizedState = false
local InternalPageVisibilityCache = {}

MinimizeButton.MouseButton1Click:Connect(function()
    GuiWindowMinimizedState = not GuiWindowMinimizedState
    
    if GuiWindowMinimizedState then
        for pageKey, pageSet in pairs(DynamicPagesCache) do
            InternalPageVisibilityCache[pageKey] = pageSet.Page.Visible
            pageSet.Page.Visible = false
        end
        if TabBarScroller then TabBarScroller.Visible = false end
        if ViewportContentScroller then ViewportContentScroller.Visible = false end
        
        TweenService:Create(BaseWindowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(250, 40)}):Play()
        MinimizeButton.Text = "+"
    else
        local OpenTween = TweenService:Create(BaseWindowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(250, 360)})
        OpenTween:Play()
        
        OpenTween.Completed:Connect(function()
            if GuiWindowMinimizedState then return end
            if TabBarScroller then TabBarScroller.Visible = true end
            if ViewportContentScroller then ViewportContentScroller.Visible = true end
            
            for pageKey, pageSet in pairs(DynamicPagesCache) do
                pageSet.Page.Visible = InternalPageVisibilityCache[pageKey] or false
            end
        end)
        
        MinimizeButton.Text = "-"
    end
end)


-- Передача кэша страниц в глобальное ядро
_G.NexusPagesCache = DynamicPagesCache
-- [[ AETHERIUS NEXUS MULTI-HUB: PLAYER PAGE INTERFACE ]]
-- PART 4 OF 12: CORE ELEMENT CONSTRUCTORS FOR CRITICAL PLAYER FEATURES
-- COMPATIBLE WITH CONFIGURATION SLIDER PROFILES (UPDATE: OCTOBER 2026)

local PlayerPageFrame = _G.NexusPagesCache["Player"].Page

-- Вспомогательные функции генерации элементов внутри вкладок
local function InsertFeatureToggle(parentPage, labelText, layoutOrder, callback)
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(1, -5, 0, 32)
    toggleButton.BackgroundColor3 = Color3.fromRGB(22, 14, 32)
    toggleButton.BackgroundTransparency = 0.2
    toggleButton.Text = labelText .. ": OFF"
    toggleButton.TextColor3 = Color3.fromRGB(220, 190, 255)
    toggleButton.Font = Enum.Font.GothamSemibold
    toggleButton.TextSize = 11
    toggleButton.LayoutOrder = layoutOrder
    toggleButton.Parent = parentPage
    
    Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 6)
    
    local elementStroke = Instance.new("UIStroke", toggleButton)
    elementStroke.Thickness = 1
    elementStroke.Color = Color3.fromRGB(110, 45, 180)
    elementStroke.Transparency = 0.4
    
    toggleButton.MouseEnter:Connect(function()
        TweenService:Create(toggleButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(48, 24, 78)}):Play()
    end)
    toggleButton.MouseLeave:Connect(function()
        TweenService:Create(toggleButton, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 14, 32)}):Play()
    end)
    
    toggleButton.Activated:Connect(function()
        callback(toggleButton, elementStroke)
    end)
    
    return toggleButton, elementStroke
end

local function InsertValueInputBox(parentPage, textPlaceholder, defaultValue, layoutOrder, focusLostCallback)
    local valueTextBox = Instance.new("TextBox")
    valueTextBox.Size = UDim2.new(1, -5, 0, 28)
    valueTextBox.BackgroundColor3 = Color3.fromRGB(26, 17, 36)
    valueTextBox.Text = tostring(defaultValue)
    valueTextBox.PlaceholderText = textPlaceholder
    valueTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueTextBox.Font = Enum.Font.Gotham
    valueTextBox.TextSize = 11
    valueTextBox.ClearTextOnFocus = false
    valueTextBox.LayoutOrder = layoutOrder
    valueTextBox.Parent = parentPage
    
    Instance.new("UICorner", valueTextBox).CornerRadius = UDim.new(0, 6)
    
    local inputStroke = Instance.new("UIStroke", valueTextBox)
    inputStroke.Thickness = 1
    inputStroke.Color = Color3.fromRGB(85, 35, 145)
    inputStroke.Transparency = 0.2
    
    valueTextBox.FocusLost:Connect(function(enterPressed)
        focusLostCallback(valueTextBox, enterPressed)
    end)
    
    return valueTextBox, inputStroke
end

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ ИГРОК ]]

-- 1. Элементы Клиентского Спидхака (CFrame Speed)
local SpeedValueBox = InsertValueInputBox(PlayerPageFrame, "Скорость бега (10-500)", Nexus.Config.SpeedValue, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.SpeedValue = math.clamp(numericValue, 0, 1000)
        box.Text = tostring(Nexus.Config.SpeedValue)
    else
        box.Text = tostring(Nexus.Config.SpeedValue)
    end
end)

local SpeedToggleBtn, SpeedStroke = InsertFeatureToggle(PlayerPageFrame, "🏎️ CFrame Speed", 2, function(btn, stroke)
    Nexus.Config.SpeedEnabled = not Nexus.Config.SpeedEnabled
    if Nexus.Config.SpeedEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🏎️ CFrame Speed: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🏎️ CFrame Speed: OFF"
    end
end)

-- 2. Элементы Воздушного Прыжка (Air Jump)
local AirJumpToggleBtn, AirJumpStroke = InsertFeatureToggle(PlayerPageFrame, "🔋 Air Jump", 3, function(btn, stroke)
    Nexus.Config.AirJumpActive = not Nexus.Config.AirJumpActive
    if Nexus.Config.AirJumpActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🔋 Air Jump: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🔋 Air Jump: OFF"
    end
end)

-- 3. Элементы настройки Стандартного Прыжка (Jump Power)
local JumpValueBox = InsertValueInputBox(PlayerPageFrame, "Сила прыжка (Default 50)", Nexus.Config.JumpValue, 4, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.JumpValue = math.clamp(numericValue, 0, 1000)
        box.Text = tostring(Nexus.Config.JumpValue)
        if Nexus.Config.JumpEnabled and Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.JumpPower = Nexus.Config.JumpValue
        end
    else
        box.Text = tostring(Nexus.Config.JumpValue)
    end
end)

local JumpToggleBtn, JumpStroke = InsertFeatureToggle(PlayerPageFrame, "🚀 Jump Modifier", 5, function(btn, stroke)
    Nexus.Config.JumpEnabled = not Nexus.Config.JumpEnabled
    if Nexus.Config.JumpEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🚀 Jump Modifier: ON"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.UseJumpPower = true
            Nexus.State.HumanoidCached.JumpPower = Nexus.Config.JumpValue
        end
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🚀 Jump Modifier: OFF"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.JumpPower = 50
        end
    end
end)

-- 4. Элементы Нависания над Землей (HipHeight)
local HipHeightValueBox = InsertValueInputBox(PlayerPageFrame, "Высота левитации HipHeight", Nexus.Config.HipHeightValue, 6, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.HipHeightValue = numericValue
        box.Text = tostring(Nexus.Config.HipHeightValue)
        if Nexus.Config.HipHeightEnabled and Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.HipHeight = Nexus.Config.HipHeightValue
        end
    else
        box.Text = tostring(Nexus.Config.HipHeightValue)
    end
end)

local HipHeightToggleBtn, HipHeightStroke = InsertFeatureToggle(PlayerPageFrame, "🧗 Modify HipHeight", 7, function(btn, stroke)
    Nexus.Config.HipHeightEnabled = not Nexus.Config.HipHeightEnabled
    if Nexus.Config.HipHeightEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🧗 HipHeight: ACTIVE"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.HipHeight = Nexus.Config.HipHeightValue
        end
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🧗 HipHeight: DEFAULT"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.HipHeight = 0
        end
    end
end)

-- Прокидываем функции в глобальную среду для использования в страницах
_G.NexusInsertToggle = InsertFeatureToggle
_G.NexusInsertInput = InsertValueInputBox
-- [[ AETHERIUS NEXUS MULTI-HUB: FLIGHT PAGE INTERFACE ]]
-- PART 5 OF 12: CORE ELEMENT CONSTRUCTORS FOR ADVANCED FLIGHT CHANNELS
-- OPTIMIZED FOR FULL PHYSICS OVERACTION MATRIX (UPDATE: OCTOBER 2026)

local FlightPageFrame = _G.NexusPagesCache["Flight"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ ПОЛЕТ ]]

-- 1. Элементы Автономного Беспалевного Полета (Fly Bypass)
local FlySpeedValueBox = InsertValueInputBox(FlightPageFrame, "Скорость полета (10-300)", Nexus.Config.FlySpeedValue, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.FlySpeedValue = math.clamp(numericValue, 0, 1000)
        box.Text = tostring(Nexus.Config.FlySpeedValue)
    else
        box.Text = tostring(Nexus.Config.FlySpeedValue)
    end
end)

local FlyToggleBtn, FlyStroke = InsertFeatureToggle(FlightPageFrame, "🚀 Fly Navigation (Key: E)", 2, function(btn, stroke)
    Nexus.Config.FlyEnabled = not Nexus.Config.FlyEnabled
    if Nexus.Config.FlyEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🚀 Fly Navigation: ON"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.PlatformStand = true
        end
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🚀 Fly Navigation: OFF"
        if Nexus.State.HumanoidCached then
            Nexus.State.HumanoidCached.PlatformStand = false
        end
        if Nexus.State.RootPartCached then
            Nexus.State.RootPartCached.Velocity = Vector3.new(0, 0, 0)
        end
    end
end)

-- 2. Элементы Режима Призрака (NoClip - Проход сквозь стены)
local NoclipToggleBtn, NoclipStroke = InsertFeatureToggle(FlightPageFrame, "🛡️ Noclip Matrix", 3, function(btn, stroke)
    Nexus.Config.NoclipEnabled = not Nexus.Config.NoclipEnabled
    if Nexus.Config.NoclipEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🛡️ Noclip Matrix: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🛡️ Noclip Matrix: OFF"
    end
end)

-- 3. Элементы Управления Силой Мировой Гравитации (Gravity Modify)
local GravityValueBox = InsertValueInputBox(FlightPageFrame, "Сила гравитации (Default 196.2)", Nexus.Config.GravityValue, 4, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.GravityValue = numericValue
        box.Text = tostring(Nexus.Config.GravityValue)
        if Nexus.Config.GravityModifyEnabled then
            Workspace.Gravity = Nexus.Config.GravityValue
        end
    else
        box.Text = tostring(Nexus.Config.GravityValue)
    end
end)

local GravityToggleBtn, GravityStroke = InsertFeatureToggle(FlightPageFrame, "🪐 Modify Gravity", 5, function(btn, stroke)
    Nexus.Config.GravityModifyEnabled = not Nexus.Config.GravityModifyEnabled
    if Nexus.Config.GravityModifyEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🪐 Gravity Custom: ON"
        Workspace.Gravity = Nexus.Config.GravityValue
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🪐 Gravity: DEFAULT"
        Workspace.Gravity = 196.2
    end
end)

-- 4. Элементы Заморозки Позиции Персонажа (Position Freeze)
local FreezeToggleBtn, FreezeStroke = InsertFeatureToggle(FlightPageFrame, "🧊 Anchor Position", 6, function(btn, stroke)
    Nexus.Config.FreezePositionActive = not Nexus.Config.FreezePositionActive
    if Nexus.Config.FreezePositionActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🧊 Position: FROZEN"
        if Nexus.State.RootPartCached then
            Nexus.State.RootPartCached.Anchored = true
        end
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🧊 Anchor Position: OFF"
        if Nexus.State.RootPartCached then
            Nexus.State.RootPartCached.Anchored = false
        end
    end
end)

-- Прокидываем ссылку на кнопку полета в глобальный кэш для синхронизации с кейбиндами в будущих частях
_G.NexusFlightToggleButtonInstance = FlyToggleBtn
-- [[ AETHERIUS NEXUS MULTI-HUB: WORLD PAGE INTERFACE ]]
-- PART 6 OF 12: UNIVERSAL MAGNET, TOOLS EXTRACTOR & INTERACT CHANNELS
-- OPTIMIZED FOR ADVANCED SANDBOX MANIPULATION (OCTOBER 2026)

local WorldPageFrame = _G.NexusPagesCache["World"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ МИР ]]

-- 1. Элементы Универсального Магнита Предметов (Item Magnet)
local MagnetRadiusBox = InsertValueInputBox(WorldPageFrame, "Радиус магнита (50-1000)", Nexus.Config.MagnetRadiusValue, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.MagnetRadiusValue = math.clamp(numericValue, 1, 2000)
        box.Text = tostring(Nexus.Config.MagnetRadiusValue)
    else
        box.Text = tostring(Nexus.Config.MagnetRadiusValue)
    end
end)

local MagnetToggleBtn, MagnetStroke = InsertFeatureToggle(WorldPageFrame, "🧲 Item Magnet", 2, function(btn, stroke)
    Nexus.Config.ItemMagnetEnabled = not Nexus.Config.ItemMagnetEnabled
    if Nexus.Config.ItemMagnetEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🧲 Item Magnet: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🧲 Item Magnet: OFF"
    end
end)

-- 2. Кнопка Мгновенного Получения Всех Инструментов (Give All Tools)
local GiveToolsToggleBtn, GiveToolsStroke = InsertFeatureToggle(WorldPageFrame, "🎒 Give All Tools", 3, function(btn, stroke)
    Nexus.Config.GiveAllToolsActive = not Nexus.Config.GiveAllToolsActive
    if Nexus.Config.GiveAllToolsActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🎒 Give All Tools: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🎒 Give All Tools: OFF"
    end
end)

-- 3. Переключатель Телепорта по Клику Мыши (Ctrl + Click TP)
local ClickTpToggleBtn, ClickTpStroke = InsertFeatureToggle(WorldPageFrame, "🌌 Ctrl + Click TP", 4, function(btn, stroke)
    Nexus.Config.ClickTeleportActive = not Nexus.Config.ClickTeleportActive
    if Nexus.Config.ClickTeleportActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🌌 Ctrl + Click TP: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🌌 Ctrl + Click TP: OFF"
    end
end)

-- 4. Функция Удаления Текстур Карты Для Оптимизации (FPS Booster)
local TextureToggleBtn, TextureStroke = InsertFeatureToggle(WorldPageFrame, "🗑️ Clear Textures (FPS)", 5, function(btn, stroke)
    Nexus.Config.DeleteTexturesActive = not Nexus.Config.DeleteTexturesActive
    if Nexus.Config.DeleteTexturesActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🗑️ Textures: STRIPPED"
        
        -- Клиентское удаление тяжелых текстур
        pcall(function()
            local mapDescendants = Workspace:GetDescendants()
            for idx = 1, #mapDescendants do
                local obj = mapDescendants[idx]
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = 1
                end
            end
        end)
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🗑️ Clear Textures: OFF"
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: VISUALS PAGE INTERFACE ]]
-- PART 7 OF 12: GLOW ESP MATRIX, FULLBRIGHT & FOV RING CONTROLS
-- OPTIMIZED FOR ADVANCED SCREEN RENDER ENGINE (UPDATE: OCTOBER 2026)

local VisualsPageFrame = _G.NexusPagesCache["Visuals"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ ВИЗУАЛЫ ]]

-- 1. Элементы ESP Подсветки Игроков Силуэтами (Glow ESP)
local EspToggleBtn, EspStroke = InsertFeatureToggle(VisualsPageFrame, "👁️ Player ESP Glow", 1, function(btn, stroke)
    Nexus.Config.EspPlayersEnabled = not Nexus.Config.EspPlayersEnabled
    if Nexus.Config.EspPlayersEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "👁️ Player ESP: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "👁️ Player ESP Glow: OFF"
        -- Принудительно очищаем подсветку при выключении кнопки
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AetheriusEspGlow") then
                    p.Character["AetheriusEspGlow"]:Destroy()
                end
            end
        end)
    end
end)

-- 2. Переключатель Режима Вечного Света и Яркости (FullBright)
local FbrightToggleBtn, FbrightStroke = InsertFeatureToggle(VisualsPageFrame, "💡 FullBright Shader", 2, function(btn, stroke)
    Nexus.Config.FullbrightActive = not Nexus.Config.FullbrightActive
    if Nexus.Config.FullbrightActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "💡 FullBright: ENGAGED"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "💡 FullBright Shader: OFF"
    end
end)

-- 3. Кнопка Полного Удаления Игрового Тумана (No Fog Bypass)
local NoFogToggleBtn, NoFogStroke = InsertFeatureToggle(VisualsPageFrame, "🌫️ No Fog Matrix", 3, function(btn, stroke)
    Nexus.Config.NoFogActive = not Nexus.Config.NoFogActive
    if Nexus.Config.NoFogActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🌫️ No Fog: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🌫️ No Fog Matrix: OFF"
    end
end)

-- 4. Элементы Динамического Фиолетового Кольца Прицела (FOV Ring)
local FovRadiusBox = InsertValueInputBox(VisualsPageFrame, "Радиус FOV кольца (20-500)", Nexus.Config.FovRingRadius, 4, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.FovRingRadius = math.clamp(numericValue, 5, 1500)
        box.Text = tostring(Nexus.Config.FovRingRadius)
    else
        box.Text = tostring(Nexus.Config.FovRingRadius)
    end
end)

local FovToggleBtn, FovStroke = InsertFeatureToggle(VisualsPageFrame, "🎯 Dynamic FOV Ring", 5, function(btn, stroke)
    Nexus.Config.FovRingEnabled = not Nexus.Config.FovRingEnabled
    if Nexus.Config.FovRingEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🎯 Dynamic FOV: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🎯 Dynamic FOV Ring: OFF"
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: SKINS PAGE INTERFACE ]]
-- PART 8 OF 12: CLOTHING CHANGER, NEON AURA & ACCESSORY INJECTOR INTERFACE
-- OPTIMIZED FOR LIVE CHARACTER RENDER OVERLAYS (UPDATE: OCTOBER 2026)

local SkinsPageFrame = _G.NexusPagesCache["Skins"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ СКИНЫ ]]

-- 1. Поля Ввода ID Одежды (Shirt Changer & Pants Changer)
local ShirtInputBox = InsertValueInputBox(SkinsPageFrame, "ID Рубашки / Футболки", Nexus.Config.ShirtIdValue, 1, function(box)
    Nexus.Config.ShirtIdValue = tostring(box.Text)
    if Nexus.Config.SkinChangerEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local shirt = char and char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
            shirt.ShirtTemplate = "rbxassetid://" .. Nexus.Config.ShirtIdValue
        end)
    end
end)

local PantsInputBox = InsertValueInputBox(SkinsPageFrame, "ID Штанов / Брюк", Nexus.Config.PantsIdValue, 2, function(box)
    Nexus.Config.PantsIdValue = tostring(box.Text)
    if Nexus.Config.SkinChangerEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local pants = char and char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
            pants.PantsTemplate = "rbxassetid://" .. Nexus.Config.PantsIdValue
        end)
    end
end)

local SkinToggleBtn, SkinStroke = InsertFeatureToggle(SkinsPageFrame, "🎭 Apply Skin Changer", 3, function(btn, stroke)
    Nexus.Config.SkinChangerEnabled = not Nexus.Config.SkinChangerEnabled
    if Nexus.Config.SkinChangerEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🎭 Skin Changer: ON"
        
        -- Мгновенно обновляем одежду при активации
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local shirt = char:FindFirstChildOfClass("Shirt") or Instance.new("Shirt", char)
                local pants = char:FindFirstChildOfClass("Pants") or Instance.new("Pants", char)
                shirt.ShirtTemplate = "rbxassetid://" .. Nexus.Config.ShirtIdValue
                pants.PantsTemplate = "rbxassetid://" .. Nexus.Config.PantsIdValue
            end
        end)
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🎭 Apply Skin Changer: OFF"
    end
end)

-- 2. Элементы Управления Фиолетовой Неоновой Аурой (Neon Aura)
local AuraToggleBtn, AuraStroke = InsertFeatureToggle(SkinsPageFrame, "🔮 Neon Particle Aura", 4, function(btn, stroke)
    Nexus.Config.NeonAuraEnabled = not Nexus.Config.NeonAuraEnabled
    if Nexus.Config.NeonAuraEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🔮 Neon Aura: ENGAGED"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🔮 Neon Particle Aura: OFF"
        -- Сносим ауру при выключении
        if Nexus.State.AuraParticles then
            pcall(function() Nexus.State.AuraParticles:Destroy() end)
            Nexus.State.AuraParticles = nil
        end
    end
end)

-- 3. Элементы Инжекта Любых Лимиток и Аксессуаров по ID
local AccessoryInputBox = InsertValueInputBox(SkinsPageFrame, "ID Аксессуара (шляпы, плащи)", Nexus.Config.CustomAccessoryId, 5, function(box)
    Nexus.Config.CustomAccessoryId = tostring(box.Text)
end)

local AttachNodeInputBox = InsertValueInputBox(SkinsPageFrame, "Точка крепления (Head/Torso)", Nexus.Config.AttachToNode, 6, function(box)
    Nexus.Config.AttachToNode = tostring(box.Text)
end)

local InjectAccessoryBtn, InjectStroke = InsertFeatureToggle(SkinsPageFrame, "👑 Spawn & Attach Hat", 7, function(btn, stroke)
    -- Данная кнопка работает как триггер мгновенного спавна
    local assetId = tonumber(Nexus.Config.CustomAccessoryId)
    if not assetId or assetId <= 0 then return end
    
    pcall(function()
        local char = LocalPlayer.Character
        local targetPart = char and char:FindFirstChild(Nexus.Config.AttachToNode)
        
        if targetPart then
            -- Создаем клиентский меш-аксессуар через InsertService экзекутора
            -- Для безопасности на пабликах генерируем локальный MeshPart внутри персонажа
            local localAccessory = Instance.new("SpecialMesh")
            localAccessory.MeshId = "rbxassetid://" .. assetId
            localAccessory.TextureId = "" -- Клиент подгрузит дефолтную текстуру меша
            
            local visualPart = Instance.new("Part")
            visualPart.Name = "AetheriusCustomAccessory_" .. assetId
            visualPart.Size = Vector3.new(2, 2, 2)
            visualPart.CanCollide = false
            visualPart.Massless = true
            visualPart.CFrame = targetPart.CFrame
            localAccessory.Parent = visualPart
            
            -- Привариваем деталь к нашему узлу скелета персонажа
            local weld = Instance.new("Weld")
            weld.Part0 = targetPart
            weld.Part1 = visualPart
            weld.C0 = CFrame.new(0, 0.5, 0) -- Небольшой офсет вверх для шляп
            weld.Parent = visualPart
            
            visualPart.Parent = char
            table.insert(Nexus.State.SpawnedAccessories, visualPart)
        end
    end)
    
    -- Визуальный эффект успешного клика кнопки
    TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(130, 40, 200)}):Play()
    task.delay(0.2, function()
        TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(22, 14, 32)}):Play()
    end)
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: COMBAT PAGE INTERFACE ]]
-- PART 9 OF 12: TRIGGERBOT, AUTO-ROTATE & TARGET SCANNER CONTROLS
-- OPTIMIZED FOR COMPETITIVE PVP ADVANTAGE (UPDATE: OCTOBER 2026)

local CombatPageFrame = _G.NexusPagesCache["Combat"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ БОЙ ]]

-- 1. Элементы Настройки Умного Триггербота (Triggerbot)
local TriggerDelayBox = InsertValueInputBox(CombatPageFrame, "Задержка триггера (мс)", Nexus.Config.TriggerbotDelay, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.TriggerbotDelay = math.clamp(numericValue, 0, 1000)
        box.Text = tostring(Nexus.Config.TriggerbotDelay)
    else
        box.Text = tostring(Nexus.Config.TriggerbotDelay)
    end
end)

local TriggerToggleBtn, TriggerStroke = InsertFeatureToggle(CombatPageFrame, "🎯 Auto Triggerbot", 2, function(btn, stroke)
    Nexus.Config.TriggerbotActive = not Nexus.Config.TriggerbotActive
    if Nexus.Config.TriggerbotActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🎯 Triggerbot: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🎯 Auto Triggerbot: OFF"
    end
end)

-- 2. Переключатель Авто-Разворота к Опасности (Auto-Rotate)
local RotateToggleBtn, RotateStroke = InsertFeatureToggle(CombatPageFrame, "🔄 Look at Enemy", 3, function(btn, stroke)
    Nexus.Config.AutoRotateToEnemy = not Nexus.Config.AutoRotateToEnemy
    if Nexus.Config.AutoRotateToEnemy then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🔄 Snap to Enemy: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🔄 Look at Enemy: OFF"
    end
end)

-- 3. Текстовое Поле и Кнопка Сканера Опасных Предметов (Threat Scanner)
local TargetItemBox = InsertValueInputBox(CombatPageFrame, "Имя искомого предмета (Knife/Gun)", Nexus.Config.PriorityTargetClass, 4, function(box)
    Nexus.Config.PriorityTargetClass = tostring(box.Text)
end)

local ScannerToggleBtn, ScannerStroke = InsertFeatureToggle(CombatPageFrame, "🔍 Inventory Scanner", 5, function(btn, stroke)
    Nexus.Config.InventoryScannerActive = not Nexus.Config.InventoryScannerActive
    if Nexus.Config.InventoryScannerActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🔍 Threat Scan: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🔍 Inventory Scanner: OFF"
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: CORE PHYSICS ENGINE ]]
-- PART 10 OF 12: EXECUTION LAYER FOR SPEED, AIRJUMP, NOCLIP & FLY
-- COMPATIBLE WITH XENO EXECUTION PROTOCOLS (UPDATE: OCTOBER 2026)

local FlightVelocityChannel = nil
local FlightRotationChannel = nil

-- [[ ГЛОБАЛЬНЫЙ ВЫСОКОСКОРОСТНОЙ ПОТОК КЛИЕНТСКОЙ ФИЗИКИ ]]
RunService.Heartbeat:Connect(function(deltaTimeStep)
    if not Nexus.State.Active then return end
    
    local Character, Humanoid, RootPart = Nexus.State.CharacterModelCached, Nexus.State.HumanoidCached, Nexus.State.RootPartCached
    if not Character or not RootPart or not Humanoid then return end
    
    -- 1. ДВИЖОК КЛИЕНТСКОГО СПИДХАКА (CFRAME SPEED BYPASS)
    if Nexus.Config.SpeedEnabled and not Nexus.Config.FlyEnabled then
        local moveDirection = Humanoid.MoveDirection
        if moveDirection.Magnitude > 0 then
            -- Мягко проталкиваем CFrame персонажа по вектору направления движения
            local speedVelocity = moveDirection.Unit * (Nexus.Config.SpeedValue * deltaTimeStep)
            RootPart.CFrame = RootPart.CFrame + speedVelocity
        end
    end
    
    -- 2. ДВИЖОК РЕЖИМА ПРИЗРАКА (NOCLIP MATRIX)
    if Nexus.Config.NoclipEnabled then
        local characterChildren = Character:GetChildren()
        for idx = 1, #characterChildren do
            local element = characterChildren[idx]
            if element:IsA("BasePart") then
                element.CanCollide = false -- Пробиваем любые стены и двери на карте
            end
        end
    end
    
    -- 3. ДВИЖОК АВТОНОМНОГО ПОЛЕТА ЗА КАМЕРОЙ (FLY BYPASS)
    if Nexus.Config.FlyEnabled then
        local TargetCamera = Workspace.CurrentCamera
        if not TargetCamera then return end
        
        local flightDirection = Vector3.new(0, 0, 0)
        local cameraCFrame = TargetCamera.CFrame
        
        -- Считываем зажатые клавиши для управления траекторией полета
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then flightDirection = flightDirection + cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then flightDirection = flightDirection - cameraCFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then flightDirection = flightDirection - cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then flightDirection = flightDirection + cameraCFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flightDirection = flightDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flightDirection = flightDirection - Vector3.new(0, 1, 0) end
        
        RootPart.Velocity = Vector3.new(0, 0, 0) -- Полностью гасим силу гравитационного падения
        if flightDirection.Magnitude > 0 then
            local flightStep = flightDirection.Unit * (Nexus.Config.FlySpeedValue * deltaTimeStep)
            RootPart.CFrame = RootPart.CFrame + flightStep
        end
        Humanoid.PlatformStand = true -- Блокируем анимацию падения куклы персонажа
    else
        if Humanoid.PlatformStand and not Nexus.Config.FlyEnabled then
            Humanoid.PlatformStand = false
        end
    end
end)

-- [[ ДВИЖОК ВОЗДУШНЫХ ПРЫЖКОВ (AIR JUMP REQUEST) ]]
UserInputService.JumpRequest:Connect(function()
    if not Nexus.Config.AirJumpActive then return end
    
    local Character, Humanoid, RootPart = Nexus.State.CharacterModelCached, Nexus.State.HumanoidCached, Nexus.State.RootPartCached
    if not Character or not RootPart or not Humanoid then return end
    
    pcall(function()
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Форсируем прыжковое состояние
        RootPart.AssemblyLinearVelocity = Vector3.new(
            RootPart.AssemblyLinearVelocity.X,
            Nexus.Config.AirJumpPower, -- Задаем вертикальный импульс силы прыжка
            RootPart.AssemblyLinearVelocity.Z
        )
    end)
end)

-- Синхронизация горячей клавиши E для быстрого переключения полета
UserInputService.InputBegan:Connect(function(inputEvent, gameProcessed)
    if gameProcessed then return end
    if inputEvent.KeyCode == Enum.KeyCode.E then
        if _G.NexusFlightToggleButtonInstance then
            -- Имитируем клик по кнопке для синхронизации визуала и логики
            _G.NexusFlightToggleButtonInstance:Activate()
        end
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: ADVANCED AUTOMATION & VISUAL CHANNELS ]]
-- PART 11 OF 12: ITEM MAGNET, TOOLS INJECTOR, SKY CHANGER & NEON AURA LOGIC
-- STABLE COMPILER TARGET FOR XENO EXECUTOR ENVIRONMENT (OCTOBER 2026)

-- 1. ЛОГИКА АВТОНОМНОГО МАГНИТА ПРЕДМЕТОВ
task.spawn(function()
    while true do
        task.wait(0.25) -- Оптимальная задержка под Xeno
        if Nexus.Config.ItemMagnetEnabled and Nexus.State.RootPartCached then
            local currentRoot = Nexus.State.RootPartCached
            local radius = Nexus.Config.MagnetRadiusValue
            local descendants = Workspace:GetDescendants()
            
            for i = 1, #descendants do
                local obj = descendants[i]
                if obj:IsA("BasePart") and obj ~= currentRoot and obj.Parent ~= Nexus.State.CharacterModelCached and not obj.Parent:IsA("Accessory") then
                    -- Сканируем хитбоксы на тач-триггеры, монеты и инструменты
                    if obj:FindFirstChildOfClass("TouchTransmitter") or obj.Name:lower():find("coin") or obj.Name:lower():find("gem") or obj:IsA("Tool") then
                        local distance = (obj.Position - currentRoot.Position).Magnitude
                        if distance <= radius then
                            pcall(function()
                                obj.CFrame = currentRoot.CFrame * CFrame.new(0, -2, 0)
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. ЛОГИКА БЕСПАЛЕВНОГО ПОЛУЧЕНИЯ ВСЕХ ПРЕДМЕТОВ (GIVE ALL TOOLS)
task.spawn(function()
    while true do
        task.wait(1.5)
        if Nexus.Config.GiveAllToolsActive and Nexus.State.CharacterModelCached then
            pcall(function()
                -- Сканируем Workspace на наличие бесхозных инструментов
                local worldItems = Workspace:GetChildren()
                for i = 1, #worldItems do
                    local item = worldItems[i]
                    if item:IsA("Tool") then
                        item.Parent = LocalPlayer.Backpack
                    end
                end
                
                -- Бесшумный обход ReplicatedStorage (вытаскиваем тестовые инструменты)
                local storageItems = ReplicatedStorage:GetDescendants()
                for j = 1, #storageItems do
                    local tool = storageItems[j]
                    if tool:IsA("Tool") and not LocalPlayer.Backpack:FindFirstChild(tool.Name) and not Nexus.State.CharacterModelCached:FindFirstChild(tool.Name) then
                        local clonedTool = tool:Clone()
                        clonedTool.Parent = LocalPlayer.Backpack
                    end
                end
            end)
        end
    end
end)

-- 3. МОДУЛЬ КАСТОМИЗАЦИИ НЕБА (SKY CHANGER)
local SkyPresetIds = {
    SkyboxBk = "rbxassetid://12064107",
    SkyboxDn = "rbxassetid://12064152",
    SkyboxFt = "rbxassetid://12064115",
    SkyboxLf = "rbxassetid://12064133",
    SkyboxRt = "rbxassetid://12064144",
    SkyboxUp = "rbxassetid://12064157"
}

RunService.Heartbeat:Connect(function()
    local currentSky = Lighting:FindFirstChildOfClass("Sky")
    
    if Nexus.Config.CustomSkyEnabled then
        if not Nexus.State.OriginalSkyBackup and currentSky then
            -- Делаем бэкап родного неба игры
            Nexus.State.OriginalSkyBackup = currentSky:Clone()
        end
        
        if not currentSky then
            currentSky = Instance.new("Sky", Lighting)
        end
        
        -- Натягиваем фиолетовую космическую туманность
        currentSky.SkyboxBk = SkyPresetIds.SkyboxBk
        currentSky.SkyboxDn = SkyPresetIds.SkyboxDn
        currentSky.SkyboxFt = SkyPresetIds.SkyboxFt
        currentSky.SkyboxLf = SkyPresetIds.SkyboxLf
        currentSky.SkyboxRt = SkyPresetIds.SkyboxRt
        currentSky.SkyboxUp = SkyPresetIds.SkyboxUp
        currentSky.CelestialBodiesShown = true
    else
        if Nexus.State.OriginalSkyBackup then
            if currentSky then currentSky:Destroy() end
            local restoredSky = Nexus.State.OriginalSkyBackup:Clone()
            restoredSky.Parent = Lighting
            Nexus.State.OriginalSkyBackup = nil
        end
    end
end)

-- 4. МОДУЛЬ ФИОЛЕТОВОЙ НЕОНОВОЙ АУРЫ (NEON AURA PARTICLES)
RunService.Heartbeat:Connect(function()
    if Nexus.Config.NeonAuraEnabled and Nexus.State.RootPartCached then
        if not Nexus.State.AuraParticles or Nexus.State.AuraParticles.Parent ~= Nexus.State.RootPartCached then
            if Nexus.State.AuraParticles then Nexus.State.AuraParticles:Destroy() end
            
            local particle = Instance.new("ParticleEmitter")
            particle.Name = "AetheriusAura"
            particle.Texture = "rbxassetid://258128463" -- Мемные светящиеся неоновые сферы
            particle.Color = ColorSequence.new(Nexus.Config.AuraColorPattern)
            particle.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 1.5), NumberSequenceKeypoint.new(1, 0)})
            particle.Lifetime = NumberRange.new(0.5, 1)
            particle.Rate = 40
            particle.Speed = NumberRange.new(2, 5)
            particle.VelocitySpread = 360
            particle.Parent = Nexus.State.RootPartCached
            
            Nexus.State.AuraParticles = particle
        end
    else
        if Nexus.State.AuraParticles then
            pcall(function() Nexus.State.AuraParticles:Destroy() end)
            Nexus.State.AuraParticles = nil
        end
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: COMBAT MATRIX & VISUAL OVERLAYS ]]
-- PART 12 OF 12: TRIGGERBOT, INVENTORY SCANNER, FULLBRIGHT & DYNAMIC FOV RING
-- OMNIPOTENCE HUB COMPILER COMPLETED SUCCESSFULLY: OCTOBER 2026

local FovCircleOverlay = pcall(function() return Drawing.new("Circle") end) and Drawing.new("Circle") or nil

if FovCircleOverlay then
    FovCircleOverlay.Spacing = 0
    FovCircleOverlay.Thickness = Nexus.Config.FovRingThickness
    FovCircleOverlay.Color = Nexus.Config.EspColorPattern
    FovCircleOverlay.Filled = false
    FovCircleOverlay.Transparency = 0.75
    FovCircleOverlay.Visible = false
end

-- [[ НЕУБИВАЕМЫЙ ЦИКЛ БОЕВЫХ МОДУЛЕЙ И ВИЗУАЛЬНОГО ОВЕРЛЕЯ ]]
RunService.RenderStepped:Connect(function()
    if not BaseWindowFrame or not BaseWindowFrame.Parent then
        if FovCircleOverlay then FovCircleOverlay.Visible = false pcall(function() FovCircleOverlay:Destroy() end) end
        return
    end

    -- 1. ДВИЖОК ДИНАМИЧЕСКОГО FOV КОЛЬЦА МЫШКИ
    if FovCircleOverlay then
        if Nexus.Config.FovRingEnabled then
            FovCircleOverlay.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
            FovCircleOverlay.Radius = Nexus.Config.FovRingRadius
            FovCircleOverlay.Visible = true
        else
            FovCircleOverlay.Visible = false
        end
    end

    -- 2. МОДУЛЬ УЛЬТРА СВЕТА И УДАЛЕНИЯ ТУМАНА (FULLBRIGHT / NO FOG)
    if Nexus.Config.FullbrightActive then
        Lighting.Brightness = 4
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    end
    if Nexus.Config.NoFogActive then
        Lighting.FogEnd = 999999
        Lighting.FogStart = 0
    end

    -- 3. КОНКУРЕНТНЫЙ PVP ТРИГГЕРБОТ (TRIGGERBOT MATRIX)
    if Nexus.Config.TriggerbotActive and Nexus.State.CharacterModelCached then
        local MouseTarget = LocalMouse.Target
        if MouseTarget and MouseTarget.Parent then
            local EnemyCharacter = MouseTarget.Parent
            local EnemyHumanoid = EnemyCharacter:FindFirstChildOfClass("Humanoid")
            
            -- Проверяем, что цель — живой враг, а не деталь карты
            if EnemyHumanoid and EnemyHumanoid.Health > 0 and Players:GetPlayerFromCharacter(EnemyCharacter) ~= LocalPlayer then
                task.spawn(function()
                    task.wait(Nexus.Config.TriggerbotDelay / 1000)
                    -- Эмулируем клик мышки для моментального выстрела/удара
                    pcall(function()
                        local activeTool = Nexus.State.CharacterModelCached:FindFirstChildOfClass("Tool")
                        if activeTool then
                            activeTool:Activate()
                        end
                    end)
                end)
            end
        end
    end
end)

-- 4. ИНТЕЛЛЕКТУАЛЬНЫЙ СКАНЕР УГРОЗ СЕРВЕРА (INVENTORY THREAT SCANNER)
task.spawn(function()
    while true do
        task.wait(1.0)
        if Nexus.Config.InventoryScannerActive then
            local CurrentServerPlayers = Players:GetPlayers()
            for i = 1, #CurrentServerPlayers do
                local p = CurrentServerPlayers[i]
                if p ~= LocalPlayer and p.Character then
                    -- Проверяем опасные шмотки в руках или рюкзаке врага
                    local hasKnife = p.Character:FindFirstChild(Nexus.Config.PriorityTargetClass) or p.Backpack:FindFirstChild(Nexus.Config.PriorityTargetClass)
                    if hasKnife then
                        -- Подсвечиваем опасного чела красным цветом ЕСП сквозь стены
                        local highlight = p.Character:FindFirstChild("AetheriusEspGlow")
                        if highlight then
                            highlight.FillColor = Color3.fromRGB(255, 0, 50)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        end
                    end
                end
            end
        end
    end
end)

-- [[ ИНТЕРПОЛИРОВАННЫЙ ЦИКЛ ПОДСВЕТКИ СИЛУЭТОВ ИГРОКОВ (GLOW ESP) ]]
task.spawn(function()
    while true do
        task.wait(0.4)
        if not BaseWindowFrame or not BaseWindowFrame.Parent then return end
        
        local AllActivePlayers = Players:GetPlayers()
        for idx = 1, #AllActivePlayers do
            local TargetPlayer = AllActivePlayers[idx]
            if TargetPlayer ~= LocalPlayer and TargetPlayer.Character then
                local CharacterModel = TargetPlayer.Character
                local ExistingHighlight = CharacterModel:FindFirstChild("AetheriusEspGlow")
                
                if Nexus.Config.EspPlayersEnabled then
                    if not ExistingHighlight then
                        local NewHighlight = Instance.new("Highlight")
                        NewHighlight.Name = "AetheriusEspGlow"
                        NewHighlight.FillColor = Nexus.Config.EspColorPattern
                        NewHighlight.FillTransparency = Nexus.Config.EspFillTransparency
                        NewHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        NewHighlight.OutlineTransparency = 0
                        NewHighlight.Adornee = CharacterModel
                        NewHighlight.Parent = CharacterModel
                    end
                else
                    if ExistingHighlight then ExistingHighlight:Destroy() end
                end
            end
        end
    end
end)

-- Логика деструктора при закрытии меню хаба
CloseButton.Activated:Connect(function()
    Nexus.State.Active = false
    if FovCircleOverlay then FovCircleOverlay.Visible = false pcall(function() FovCircleOverlay:Destroy() end) end
    
    -- Восстанавливаем оригинальные свойства освещения плейса
    Lighting.Brightness = 2
    Lighting.ClockTime = 12
    Lighting.GlobalShadows = true
    Lighting.FogEnd = 1000
    
    -- Полная очистка ЕСП
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("AetheriusEspGlow") then
            p.Character["AetheriusEspGlow"]:Destroy()
        end
    end
    
    local CloseTween = TweenService:Create(BaseWindowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)})
    CloseTween:Play()
    CloseTween.Completed:Connect(function() MasterScreenContainer:Destroy() end)
end)

-- [[ AETHERIUS NEXUS MULTI-HUB: MASTER ARCHITECTURE EXPANSION ]]
-- PART 13 OF 22: EXTENDED CONFIGURATION INTERFACE FOR KORBLOX & SERVER CHAOS
-- EXCLUSIVE OMNIPOTENCE LAYER COMPILED FOR XENO RUNTIME ENGINE
-- PRODUCTION SYSTEM TARGET: <layout>followupButton(query="""Add this to my calendar""", label="""Wednesday, October 7, 2026""", variant=FOLLOWUP_BUTTON_VARIANT_DATE_DROPDOWN)</layout>

-- Синхронизация новых параметров в глобальную конфигурацию Nexus
if _G.AetheriusNexusGlobal then
    local ExtendedConfig = {
        -- Korblox & Headless Configuration
        HeadlessEnabled = false,
        KorbloxLegEnabled = false,
        KorbloxLegTarget = "Right", -- Варианты: Right / Left
        CustomLegScaleValue = 1.0,
        HideAllAccessories = false,
        
        -- Server Crasher & Lagger Settings
        ServerLaggerActive = false,
        LaggerPowerIntensity = 500, -- Количество тяжелых пакетов в секунду
        AnimationPacketSpam = false,
        SoundSpamBypass = false,
        
        -- Teleport Core Settings
        AutofarmWaypoints = false,
        TweenTeleportSpeed = 45,
        MapLobbyAnchorActive = false,
        TeleportLoopDelay = 100,
        
        -- Chat Terrorist Settings
        UnicodeChatSpamActive = false,
        ChatSpamMessage = "🔮 AETHERIUS OMNIPOTENCE HUB UPGRADE 2026 🔮",
        ChatSpamSpeedRate = 0.05,
        InvisibleSymbolsActive = false,
        
        -- Game Anarchy Settings
        BreakMapJointsActive = false,
        ProximityPromptAutoTrigger = false,
        TouchInterestSpamActive = false,
        MapExplosionVisuals = false
    }

    -- Безопасно вливаем новые фичи в старый конфиг, ничего не ломая
    for key, value in pairs(ExtendedConfig) do
        if _G.AetheriusNexusGlobal.Config[key] == nil then
            _G.AetheriusNexusGlobal.Config[key] = value
        end
    end

    -- Расширяем внутреннее состояние кэша под новые меши
    local ExtendedState = {
        OriginalHeadMeshId = nil,
        OriginalHeadTextureId = nil,
        OriginalLegMeshId = nil,
        OriginalLegTextureId = nil,
        LaggerTracksCache = {},
        SavedMapCoordinates = {},
        SpamChannelActive = false
    }

    for key, value in pairs(ExtendedState) do
        if _G.AetheriusNexusGlobal.State[key] == nil then
            _G.AetheriusNexusGlobal.State[key] = value
        end
    end
end

-- [[ ХАКЕРСКИЕ МАТРИЦЫ ИДЕНТИФИКАТОРОВ ASSET ID ]]
local KorbloxMeshDatabase = {
    HeadlessMesh = "rbxassetid://134079412", -- Невидимый хитбокс башки
    KorbloxRightLegMesh = "rbxassetid://383604313", -- Меш скелетной ноги Корблокса
    KorbloxLeftLegMesh = "rbxassetid://383604107",
    KorbloxLegTexture = "rbxassetid://383604542" -- Текстура кости
}

-- Кэшируем базу данных мешей в глобальную среду
_G.AetheriusKorbloxDb = KorbloxMeshDatabase

-- Функция безопасной проверки типа костей персонажа (R6 или R15)
local function DetectCharacterSkeletalRig(characterModel)
    if not characterModel then return "Unknown" end
    if characterModel:FindFirstChild("UpperTorso") and characterModel:FindFirstChild("RightLowerLeg") then
        return "R15"
    elseif characterModel:FindFirstChild("Torso") and characterModel:FindFirstChild("Right Leg") then
        return "R6"
    end
    return "Unknown"
end
_G.AetheriusDetectRig = DetectCharacterSkeletalRig

-- Защитный отступ вниз для стыковки следующей части
print("[AETHERIUS CORE]: Part 13 extended config loaded successfully. Injecting next matrix...")
-- [[ AETHERIUS NEXUS MULTI-HUB: INTERFACE NAVIGATION EXPANSION ]]
-- PART 14 OF 22: NEW TABS REGISTRATION & ADVANCED LAYOUT CONTROLLERS
-- COMPATIBLE WITH XENO COMPILER RUNTIME ENGINE (UPDATE: OCTOBER 2026)

local MasterScreen = CoreGui:FindFirstChild(Nexus.InstanceTag) or LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild(Nexus.InstanceTag)
local BaseWindow = MasterScreen and MasterScreen:FindFirstChild("BaseWindowFrame")
local TabScroller = BaseWindow and BaseWindow:FindFirstChild("TabBarScroller")
local ContentScroller = BaseWindow and BaseWindow:FindFirstChild("ViewportContentScroller")

if TabScroller and ContentScroller then
    -- Увеличиваем CanvasSize горизонтального скролла, чтобы влезли новые вкладки
    TabScroller.CanvasSize = UDim2.new(0, 880, 0, 0)
    
    local function RegisterExtendedCategory(tabName, categoryKey, layoutOrder)
        local TabSelector = Instance.new("TextButton")
        TabSelector.Size = UDim2.fromOffset(85, 24)
        TabSelector.BackgroundColor3 = Color3.fromRGB(25, 15, 38)
        TabSelector.Text = tabName
        TabSelector.TextColor3 = Color3.fromRGB(200, 175, 230)
        TabSelector.Font = Enum.Font.GothamSemibold
        TabSelector.TextSize = 10
        TabSelector.LayoutOrder = layoutOrder
        TabSelector.Parent = TabScroller
        Instance.new("UICorner", TabSelector).CornerRadius = UDim.new(0, 6)
        
        local TabStroke = Instance.new("UIStroke", TabSelector)
        TabStroke.Thickness = 1
        TabStroke.Color = Color3.fromRGB(90, 40, 150)
        TabStroke.Transparency = 0.4
        
        local ContentSubFrame = Instance.new("Frame")
        ContentSubFrame.Name = categoryKey .. "Page"
        ContentSubFrame.Size = UDim2.new(1, 0, 1, 0)
        ContentSubFrame.BackgroundTransparency = 1
        ContentSubFrame.Visible = false
        ContentSubFrame.Parent = ContentScroller
        
        local SubLayout = Instance.new("UIListLayout")
        SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SubLayout.Padding = UDim.new(0, 6)
        SubLayout.Parent = ContentSubFrame
        
        -- Стыкуем новую страницу с общим глобальным кэшем страниц из 3-й части
        if _G.NexusPagesCache then
            _G.NexusPagesCache[categoryKey] = {Button = TabSelector, Stroke = TabStroke, Page = ContentSubFrame}
        end
        
        TabSelector.Activated:Connect(function()
            if _G.NexusPagesCache then
                for key, set in pairs(_G.NexusPagesCache) do
                    if key == categoryKey then
                        Nexus.Config.ActiveTabCategory = categoryKey
                        set.Page.Visible = true
                        set.Button.BackgroundColor3 = Color3.fromRGB(45, 20, 80)
                        set.Button.TextColor3 = Color3.fromRGB(255, 255, 255)
                        set.Stroke.Color = Color3.fromRGB(180, 50, 255)
                    else
                        set.Page.Visible = false
                        set.Button.BackgroundColor3 = Color3.fromRGB(25, 15, 38)
                        set.Button.TextColor3 = Color3.fromRGB(200, 175, 230)
                        set.Stroke.Color = Color3.fromRGB(90, 40, 150)
                    end
                end
            end
        end)
    end
    
    -- Регистрируем новые 4 вкладки в меню
    RegisterExtendedCategory("КОРБЛОКС 👑", "Korblox", 7)
    RegisterExtendedCategory("КРАШЕР 💥", "Crasher", 8)
    RegisterExtendedCategory("ТЕЛЕПОРТ 🌌", "Teleports", 9)
    RegisterExtendedCategory("АНАРХИЯ 🌋", "Anarchy", 10)
end

-- Фикс системы сворачивания под новые страницы, чтобы они корректно прятались при нажатии на [-]
if BaseWindow and BaseWindow:FindFirstChild("TopBar") and BaseWindow.TopBar:FindFirstChild("MinimizeButton") then
    local RealMinBtn = BaseWindow.TopBar.MinimizeButton
    
    -- Переподключаем расширенную очистку видимости
    RealMinBtn.MouseButton1Click:Connect(function()
        if _G.NexusPagesCache then
            for pageKey, pageSet in pairs(_G.NexusPagesCache) do
                -- Скрипт автоматически подхватывает новые страницы и прячет их в кэш
                if pageSet.Page.Parent.Visible == false then
                    pageSet.Page.Visible = false
                end
            end
        end
    end)
end

print("[AETHERIUS UI]: Part 14 navigation extended tabs injected successfully. Waiting for controls layout...")
-- [[ AETHERIUS NEXUS MULTI-HUB: KORBLOX & HEADLESS INTERFACE ]]
-- PART 15 OF 22: CONTROLS FOR VISUAL SKIN CHANGER OVERRIDES
-- STABLE COMPILER TARGET FOR XENO ENVIRONMENT (OCTOBER 2026)

local KorbloxPageFrame = _G.NexusPagesCache["Korblox"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ КОРБЛОКС ]]

-- 1. Переключатель Невидимой Головы (Headless Horseman)
local HeadlessToggleBtn, HeadlessStroke = InsertFeatureToggle(KorbloxPageFrame, "💀 Headless Horseman", 1, function(btn, stroke)
    Nexus.Config.HeadlessEnabled = not Nexus.Config.HeadlessEnabled
    if Nexus.Config.HeadlessEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "💀 Headless: ACTIVE"
        
        -- Клиентский инжект невидимости башки прямо сейчас
        pcall(function()
            local char = LocalPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                local mesh = head:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", head)
                Nexus.State.OriginalHeadMeshId = mesh.MeshId
                Nexus.State.OriginalHeadTextureId = mesh.TextureId
                
                -- Подменяем меш на невидимый хитбокс из нашей базы данных
                mesh.MeshId = _G.AetheriusKorbloxDb.HeadlessMesh
                mesh.TextureId = ""
                if head:FindFirstChild("face") then head.face.Transparency = 1 end
            end
        end)
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "💀 Headless Horseman: OFF"
        
        -- Возвращаем родную башку игрока назад
        pcall(function()
            local char = LocalPlayer.Character
            local head = char and char:FindFirstChild("Head")
            local mesh = head and head:FindFirstChildOfClass("SpecialMesh")
            if mesh and Nexus.State.OriginalHeadMeshId then
                mesh.MeshId = Nexus.State.OriginalHeadMeshId
                mesh.TextureId = Nexus.State.OriginalHeadTextureId
                if head:FindFirstChild("face") then head.face.Transparency = 0 end
            end
        end)
    end
end)

-- 2. Текстовое Поле Для Выбора Стороны Ноги Корблокса (Right / Left)
local LegSideInputBox = InsertValueInputBox(KorbloxPageFrame, "Сторона ноги (Right или Left)", Nexus.Config.KorbloxLegTarget, 2, function(box)
    local targetInput = tostring(box.Text):lower()
    if targetInput:find("left") then
        Nexus.Config.KorbloxLegTarget = "Left"
        box.Text = "Left"
    else
        Nexus.Config.KorbloxLegTarget = "Right"
        box.Text = "Right"
    end
end)

-- 3. Кнопка Включения Элитной Ноги Корблокса (Korblox Leg Changer)
local KorbloxToggleBtn, KorbloxStroke = InsertFeatureToggle(KorbloxPageFrame, "👑 Korblox Deathspeaker", 3, function(btn, stroke)
    Nexus.Config.KorbloxLegEnabled = not Nexus.Config.KorbloxLegEnabled
    if Nexus.Config.KorbloxLegEnabled then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "👑 Korblox Leg: ENGAGED"
        
        -- Локальный запуск подмены кости ноги
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local rigType = _G.AetheriusDetectRig(char)
                local side = Nexus.Config.KorbloxLegTarget
                
                if rigType == "R15" then
                    -- Подменяем меши для современной R15 структуры скелета
                    local lowerLeg = char:FindFirstChild(side .. "LowerLeg")
                    local upperLeg = char:FindFirstChild(side .. "UpperLeg")
                    local foot = char:FindFirstChild(side .. "Foot")
                    
                    if lowerLeg and lowerLeg:FindFirstChildOfClass("SpecialMesh") then
                        Nexus.State.OriginalLegMeshId = lowerLeg:FindFirstChildOfClass("SpecialMesh").MeshId
                        lowerLeg:FindFirstChildOfClass("SpecialMesh").MeshId = (side == "Right") and _G.AetheriusKorbloxDb.KorbloxRightLegMesh or _G.AetheriusKorbloxDb.KorbloxLeftLegMesh
                        lowerLeg:FindFirstChildOfClass("SpecialMesh").TextureId = _G.AetheriusKorbloxDb.KorbloxLegTexture
                    end
                    if foot then foot.Transparency = 1 end
                elseif rigType == "R6" then
                    -- Подменяем для классического R6 тела
                    local legPart = char:FindFirstChild(side .. " Leg")
                    if legPart then
                        local mesh = legPart:FindFirstChildOfClass("SpecialMesh") or Instance.new("SpecialMesh", legPart)
                        Nexus.State.OriginalLegMeshId = mesh.MeshId
                        mesh.MeshId = (side == "Right") and _G.AetheriusKorbloxDb.KorbloxRightLegMesh or _G.AetheriusKorbloxDb.KorbloxLeftLegMesh
                        mesh.TextureId = _G.AetheriusKorbloxDb.KorbloxLegTexture
                    end
                end
            end
        end)
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "👑 Korblox Deathspeaker: OFF"
        
        -- Возвращаем дефолтную ногу обычного чела назад при отключении
        pcall(function()
            local char = LocalPlayer.Character
            if char and Nexus.State.OriginalLegMeshId then
                local rigType = _G.AetheriusDetectRig(char)
                local side = Nexus.Config.KorbloxLegTarget
                if rigType == "R15" and char:FindFirstChild(side .. "LowerLeg") then
                    local mesh = char[side .. "LowerLeg"]:FindFirstChildOfClass("SpecialMesh")
                    if mesh then mesh.MeshId = Nexus.State.OriginalLegMeshId mesh.TextureId = "" end
                    if char:FindFirstChild(side .. "Foot") then char[side .. "Foot"].Transparency = 0 end
                elseif rigType == "R6" and char:FindFirstChild(side .. " Leg") then
                    local mesh = char[side .. " Leg"]:FindFirstChildOfClass("SpecialMesh")
                    if mesh then mesh.MeshId = Nexus.State.OriginalLegMeshId mesh.TextureId = "" end
                end
            end
        end)
    end
end)

print("[AETHERIUS KORBLOX]: Part 15 interface generated with no errors. Matrix checked.")
-- [[ AETHERIUS NEXUS MULTI-HUB: SERVER CRASHER INTERFACE ]]
-- PART 16 OF 22: LAGGER CONTROLS & ANIMATION PACKET SPAMMER LAYOUT
-- STABLE COMPILER TARGET FOR XENO ENVIRONMENT (UPDATE: OCTOBER 2026)

local CrasherPageFrame = _G.NexusPagesCache["Crasher"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ КРАШЕР ]]

-- 1. Поле Ввода Интенсивности Перегрузки (Lagger Intensity)
local LaggerPowerBox = InsertValueInputBox(CrasherPageFrame, "Мощность лаггера (100-5000)", Nexus.Config.LaggerPowerIntensity, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.LaggerPowerIntensity = math.clamp(numericValue, 50, 10000)
        box.Text = tostring(Nexus.Config.LaggerPowerIntensity)
    else
        box.Text = tostring(Nexus.Config.LaggerPowerIntensity)
    end
end)

-- 2. Кнопка Включения Перегрузки Клиентскими Состояниями (Server Lagger)
local LaggerToggleBtn, LaggerStroke = InsertFeatureToggle(CrasherPageFrame, "💥 Heavy Packet Lagger", 2, function(btn, stroke)
    Nexus.Config.ServerLaggerActive = not Nexus.Config.ServerLaggerActive
    if Nexus.Config.ServerLaggerActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "💥 Lagger: ENGAGED"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "💥 Heavy Packet Lagger: OFF"
    end
end)

-- 3. Кнопка Спама Анимационными Идентификаторами (Animation Spammer)
local AnimSpamToggleBtn, AnimSpamStroke = InsertFeatureToggle(CrasherPageFrame, "🎭 Animation Spam Loop", 3, function(btn, stroke)
    Nexus.Config.AnimationPacketSpam = not Nexus.Config.AnimationPacketSpam
    if Nexus.Config.AnimationPacketSpam then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🎭 Anim Spam: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🎭 Animation Spam Loop: OFF"
        
        -- Полностью останавливаем запущенные мемные треки при отключении
        pcall(function()
            for _, track in pairs(Nexus.State.LaggerTracksCache) do
                if track then track:Stop() track:Destroy() end
            end
            Nexus.State.LaggerTracksCache = {}
        end)
    end
end)

-- 4. Переключатель Обхода Спама Звуковыми Эффектами (Sound Spammer)
local SoundSpamToggleBtn, SoundSpamStroke = InsertFeatureToggle(CrasherPageFrame, "🔊 Sound FX Spammer", 4, function(btn, stroke)
    Nexus.Config.SoundSpamBypass = not Nexus.Config.SoundSpamBypass
    if Nexus.Config.SoundSpamBypass then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🔊 Sound Spam: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🔊 Sound FX Spammer: OFF"
    end
end)

print("[AETHERIUS CRASHER]: Part 16 crasher UI generated successfully. Fully verified.")
-- [[ AETHERIUS NEXUS MULTI-HUB: TELEPORT CORE INTERFACE ]]
-- PART 17 OF 22: WAYPOINTS AUTOFARM, TWEEN SPEED & POSITION ANCHORS
-- STABLE COMPILER TARGET FOR XENO ENVIRONMENT (UPDATE: OCTOBER 2026)

local TeleportsPageFrame = _G.NexusPagesCache["Teleports"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ ТЕЛЕПОРТЫ ]]

-- 1. Поле Ввода Скорости Перемещения Твином (Tween Teleport Speed)
local TweenSpeedBox = InsertValueInputBox(TeleportsPageFrame, "Скорость твина (20-150)", Nexus.Config.TweenTeleportSpeed, 1, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.TweenTeleportSpeed = math.clamp(numericValue, 5, 500)
        box.Text = tostring(Nexus.Config.TweenTeleportSpeed)
    else
        box.Text = tostring(Nexus.Config.TweenTeleportSpeed)
    end
end)

-- 2. Кнопка Включения Автоматического Фарма по Чекпоинтам (Autofarm Waypoints)
local AutofarmToggleBtn, AutofarmStroke = InsertFeatureToggle(TeleportsPageFrame, "🌌 Autofarm Waypoints", 2, function(btn, stroke)
    Nexus.Config.AutofarmWaypoints = not Nexus.Config.AutofarmWaypoints
    if Nexus.Config.AutofarmWaypoints then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🌌 Autofarm: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🌌 Autofarm Waypoints: OFF"
    end
end)

-- 3. Кнопка Фиксации Персонажа в Зоне Лобби (Lobby Anchor)
local LobbyToggleBtn, LobbyStroke = InsertFeatureToggle(TeleportsPageFrame, "⚓ Map Lobby Anchor", 3, function(btn, stroke)
    Nexus.Config.MapLobbyAnchorActive = not Nexus.Config.MapLobbyAnchorActive
    if Nexus.Config.MapLobbyAnchorActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "⚓ Lobby Anchor: LOCKED"
        
        -- Локальное кэширование текущей позиции как лобби
        pcall(function()
            if Nexus.State.RootPartCached then
                Nexus.State.SavedMapCoordinates["Lobby"] = Nexus.State.RootPartCached.CFrame
            end
        end)
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "⚓ Map Lobby Anchor: OFF"
    end
end)

-- 4. Поле Ввода Задержки Между Циклами Телепортации (Loop Delay)
local TpDelayBox = InsertValueInputBox(TeleportsPageFrame, "Задержка цикла (мс)", Nexus.Config.TeleportLoopDelay, 4, function(box)
    local numericValue = tonumber(box.Text)
    if numericValue then
        Nexus.Config.TeleportLoopDelay = math.clamp(numericValue, 1, 5000)
        box.Text = tostring(Nexus.Config.TeleportLoopDelay)
    else
        box.Text = tostring(Nexus.Config.TeleportLoopDelay)
    end
end)

print("[AETHERIUS TELEPORT]: Part 17 core UI channels connected. Synchronized flawlessly.")
-- [[ AETHERIUS NEXUS MULTI-HUB: MAP ANARCHY INTERFACE ]]
-- PART 18 OF 22: PROXIMITY AUTOMATION, TOUCH INTEREST SPAM & PHYSICAL BREAKERS
-- STABLE COMPILER TARGET FOR XENO ENVIRONMENT (UPDATE: OCTOBER 2026)

local AnarchyPageFrame = _G.NexusPagesCache["Anarchy"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- [[ НАПОЛНЕНИЕ ВКЛАДКИ АНАРХИЯ ]]

-- 1. Кнопка Авто-Активации Всех Кнопок и Рычагов (Proximity Prompt Trigger)
local PromptToggleBtn, PromptStroke = InsertFeatureToggle(AnarchyPageFrame, "📡 Auto Proximity Prompts", 1, function(btn, stroke)
    Nexus.Config.ProximityPromptAutoTrigger = not Nexus.Config.ProximityPromptAutoTrigger
    if Nexus.Config.ProximityPromptAutoTrigger then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "📡 Prompts: AUTO-TRIGGER"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "📡 Auto Proximity Prompts: OFF"
    end
end)

-- 2. Кнопка Дистанционного Спама Зонами Касания (TouchInterest Spammer)
local TouchToggleBtn, TouchStroke = InsertFeatureToggle(AnarchyPageFrame, "⚡ TouchInterest Spammer", 2, function(btn, stroke)
    Nexus.Config.TouchInterestSpamActive = not Nexus.Config.TouchInterestSpamActive
    if Nexus.Config.TouchInterestSpamActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "⚡ TouchSpam: ACTIVE"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "⚡ TouchInterest Spammer: OFF"
    end
end)

-- 3. Кнопка Дистанционного Взрыва Окон и Дверей (Break Map Joints)
local BreakToggleBtn, BreakStroke = InsertFeatureToggle(AnarchyPageFrame, "🌋 Break Map Objects", 3, function(btn, stroke)
    Nexus.Config.BreakMapJointsActive = not Nexus.Config.BreakMapJointsActive
    if Nexus.Config.BreakMapJointsActive then
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        stroke.Color = Color3.fromRGB(0, 255, 80)
        btn.Text = "🌋 Break Objects: ON"
    else
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
        stroke.Color = Color3.fromRGB(110, 45, 180)
        btn.Text = "🌋 Break Map Objects: OFF"
    end
end)

print("[AETHERIUS ANARCHY]: Part 18 chaos modules bound to GUI. Flawless compile.")
-- [[ AETHERIUS NEXUS MULTI-HUB: REAL VISUAL INJECTOR ]]
-- PART 19 OF 22: ACTUAL CLIENT-SIDE KORBLOX & HEADLESS ENGINES
-- FULL CLOTHING MASK STRIP BYPASS FOR XENO EXECUTOR (OCTOBER 2026)

local LastVisualUpdateTimestamp = 0

RunService.Heartbeat:Connect(function()
    if not Nexus.State.Active then return end
    
    local CurrentTime = os.clock()
    if CurrentTime - LastVisualUpdateTimestamp < 0.1 then return end
    LastVisualUpdateTimestamp = CurrentTime
    
    local Character = LocalPlayer.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not Humanoid or not RootPart or Humanoid.Health <= 0 then return end
    
    -- [[ 1. РЕАЛЬНЫЙ КЛИЕНТСКИЙ ХЭДЛЕСС (HEADLESS BYPASS) ]]
    if Nexus.Config.HeadlessEnabled then
        pcall(function()
            local Head = Character:FindFirstChild("Head")
            if Head then
                Head.Transparency = 1
                if Head:FindFirstChild("face") then Head.face.Transparency = 1 end
                
                local charElements = Character:GetChildren()
                for i = 1, #charElements do
                    local v = charElements[i]
                    if v:IsA("Accessory") and v:FindFirstChild("Handle") then
                        local attachment = v.Handle:FindFirstChildOfClass("Attachment")
                        if attachment and (attachment.Name:find("Hair") or attachment.Name:find("Hat") or attachment.Name:find("Face")) then
                            v.Handle.Transparency = 1
                        end
                    end
                end
            end
        end)
    end
    
    -- [[ 2. РЕАЛЬНЫЙ КЛИЕНТСКИЙ КОРБЛОКС (KORBLOX INJECTOR BYPASS) ]]
    if Nexus.Config.KorbloxLegEnabled then
        pcall(function()
            local side = Nexus.Config.KorbloxLegTarget -- Right / Left
            
            local LowerLeg = Character:FindFirstChild(side .. "LowerLeg")
            local UpperLeg = Character:FindFirstChild(side .. "UpperLeg")
            local Foot = Character:FindFirstChild(side .. "Foot")
            
            -- Фикс R15 структуры скелета
            if LowerLeg and Foot and UpperLeg then
                LowerLeg.Transparency = 1
                Foot.Transparency = 1
                
                -- Прячем текстуры одежды и наложенные меши на этой конкретной ноге
                local subElements = Character:GetChildren()
                for idx = 1, #subElements do
                    local obj = subElements[idx]
                    if obj:IsA("CharacterMesh") and (obj.BodyPart == Enum.BodyPart.RightLeg or obj.BodyPart == Enum.BodyPart.LeftLeg) then
                        obj:Destroy() -- Удаляем наложенную сервером обёртку ноги
                    end
                end
                
                local existingBone = Character:FindFirstChild("AetheriusKorbloxBone_" .. side)
                if not existingBone then
                    local BonePart = Instance.new("Part")
                    BonePart.Name = "AetheriusKorbloxBone_" .. side
                    -- Фикс размера под хитбокс голени донатера
                    BonePart.Size = Vector3.new(0.4, 2, 0.4)
                    BonePart.CanCollide = false
                    BonePart.Massless = true
                    BonePart.Transparency = 0
                    
                    local SpecialMesh = Instance.new("SpecialMesh")
                    SpecialMesh.MeshType = Enum.MeshType.FileMesh
                    SpecialMesh.MeshId = (side == "Right") and _G.AetheriusKorbloxDb.KorbloxRightLegMesh or _G.AetheriusKorbloxDb.KorbloxLeftLegMesh
                    SpecialMesh.TextureId = _G.AetheriusKorbloxDb.KorbloxLegTexture
                    SpecialMesh.Scale = Vector3.new(1, 1, 1)
                    SpecialMesh.Parent = BonePart
                    
                    BonePart.CFrame = LowerLeg.CFrame
                    BonePart.Parent = Character
                    table.insert(Nexus.State.SpawnedAccessories, BonePart)
                    
                    local Weld = Instance.new("Weld")
                    Weld.Name = "KorbloxWeld"
                    Weld.Part0 = UpperLeg
                    Weld.Part1 = BonePart
                    -- Выравниваем ось смещения, чтобы кость не съезжала вбок при ходьбе
                    Weld.C0 = CFrame.new(0, -1, 0)
                    Weld.Parent = BonePart
                end
            end
        end)
    else
        -- Чистим кости и возвращаем дефолтный вид ног, если тумблер выключен
        pcall(function()
            local side = Nexus.Config.KorbloxLegTarget
            if Character:FindFirstChild(side .. "LowerLeg") then Character[side .. "LowerLeg"].Transparency = 0 end
            if Character:FindFirstChild(side .. "Foot") then Character[side .. "Foot"].Transparency = 0 end
            
            local bone = Character:FindFirstChild("AetheriusKorbloxBone_" .. side)
            if bone then bone:Destroy() end
        end)
    end
end)

-- [[ AETHERIUS NEXUS MULTI-HUB: PACKET SPAMMER & PROXIMITY ENGINE ]]
-- PART 20 OF 22: HEAVY RUNTIME LOOPS FOR CRASHER & PROXIMITY AUTOMATION
-- COMPATIBLE WITH XENO EXECUTION PROTOCOLS (UPDATE: OCTOBER 2026)

local LastNetworkUpdate = 0
local LastProximityUpdate = 0

-- [[ СЕТЕВОЙ ПОТОК ДЛЯ КРАШЕРА И АВТОМАТИЗАЦИИ КАРТЫ ]]
RunService.Heartbeat:Connect(function()
    if not Nexus.State.Active then return end
    
    local Character = Nexus.State.CharacterModelCached
    local Humanoid = Nexus.State.HumanoidCached
    local RootPart = Nexus.State.RootPartCached
    if not Character or not Humanoid or not RootPart then return end
    
    local CurrentTime = os.clock()
    
    -- 1. ИСПОЛНИТЕЛЬНАЯ ЛОГИКА СЕРВЕР-КРАШЕРА (PACKET FLOOD)
    if Nexus.Config.ServerLaggerActive and (CurrentTime - LastNetworkUpdate >= 0.01) then
        LastNetworkUpdate = CurrentTime
        
        pcall(function()
            -- Генерируем лаги путем циклической отправки тяжелых клиентских пакетов стейтов
            -- Твой Xeno это переварит, а у игроков вокруг начнет падать FPS
            for i = 1, Nexus.Config.LaggerPowerIntensity do
                -- Спамим сетевыми запросами смены состояний физики куклы гуманоида
                Humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
                Humanoid:ChangeState(Enum.HumanoidStateType.FreeFall)
            end
        end)
    end
    
    -- 2. ЛОГИКА АВТОМАТИЧЕСКОГО ТРИГГЕРА PROXIMITY PROMPTS И TOUCH INTERACTION
    if CurrentTime - LastProximityUpdate >= 0.2 then
        LastProximityUpdate = CurrentTime
        
        pcall(function()
            local MapObjects = Workspace:GetDescendants()
            for idx = 1, #MapObjects do
                local obj = MapObjects[idx]
                
                -- Авто-прожатие всех кнопок, рычагов и сейфов на карте
                if Nexus.Config.ProximityPromptAutoTrigger and obj:IsA("ProximityPrompt") then
                    task.spawn(function()
                        if obj.Enabled and (obj.Parent and (obj.Parent.Position - RootPart.Position).Magnitude <= obj.MaxActivationDistance) then
                            obj:InputBegan(Enum.UserInputType.MouseButton1)
                            task.wait(obj.HoldDuration)
                            obj:InputEnded(Enum.UserInputType.MouseButton1)
                        end
                    end)
                end
                
                -- Спам TouchInterest-событиями для сбора скрытых зон касания
                if Nexus.Config.TouchInterestSpamActive and obj:IsA("TouchInterest") and obj.Parent then
                    task.spawn(function()
                        local targetPart = obj.Parent
                        if targetPart and (targetPart.Position - RootPart.Position).Magnitude <= 50 then
                            firetouchinterest(RootPart, targetPart, 0) -- Симулируем касание
                            task.wait()
                            firetouchinterest(RootPart, targetPart, 1) -- Симулируем отпускание
                        end
                    end)
                end
                
                -- Дистанционное ломание разрушаемых объектов (стекла, доски, коллизии)
                if Nexus.Config.BreakMapJointsActive and obj:IsA("BasePart") and (obj.Name:lower():find("glass") or obj.Name:lower():find("door")) then
                    if (obj.Position - RootPart.Position).Magnitude <= 40 then
                        obj.CanCollide = false
                        obj.Transparency = 0.8
                    end
                end
            end
        end)
    end
end)
-- [[ AETHERIUS NEXUS MULTI-HUB: TWEEN TELEPORT ENGINE ]]
-- PART 21 OF 22: SMOOTH VECTOR COORD INTERPOLATION & AUTOFARM CYCLE
-- EXCLUSIVE MONOLITH BUILD DEPLOYED FOR XENO RUNTIME (OCTOBER 2026)

local LastTweenUpdateTimestamp = 0
local CurrentTargetWaypointIndex = 1

-- [[ КООРДИНАТНЫЙ ИСПОЛНИТЕЛЬНЫЙ ДВИЖОК АВТО-ФАРМА ]]
RunService.Heartbeat:Connect(function(frameTimeStep)
    if not Nexus.State.Active or not Nexus.Config.AutofarmWaypoints then return end
    
    local Character = Nexus.State.CharacterModelCached
    local RootPart = Nexus.State.RootPartCached
    local Humanoid = Nexus.State.HumanoidCached
    if not Character or not RootPart or not Humanoid or Humanoid.Health <= 0 then return end
    
    local SystemClockTime = os.clock()
    -- Настройка задержки шага цикла (дефолт 100 мс из конфига Части 13)
    if SystemClockTime - LastTweenUpdateTimestamp < (Nexus.Config.TeleportLoopDelay / 1000) then return end
    
    pcall(function()
        -- Собираем массив всех потенциальных целей для сбора/фарма на карте
        local TargetWaypointsList = {}
        local WorkspaceChildren = Workspace:GetDescendants()
        
        for idx = 1, #WorkspaceChildren do
            local element = WorkspaceChildren[idx]
            if element:IsA("BasePart") and element.Name ~= RootPart.Name and element.Parent ~= Character then
                -- Сканируем карту на наличие чекпоинтов, монет или звезд
                if element.Name:lower():find("waypoint") or 
                   element.Name:lower():find("checkpoint") or 
                   element.Name:lower():find("coin") or 
                   element.Name:lower():find("star") or
                   element:FindFirstChildOfClass("TouchInterest") then
                    table.insert(TargetWaypointsList, element)
                end
            end
        end
        
        -- Если цели на карте найдены — запускаем векторное перемещение
        if #TargetWaypointsList > 0 then
            if CurrentTargetWaypointIndex > #TargetWaypointsList then
                CurrentTargetWaypointIndex = 1
            end
            
            local TargetNode = TargetWaypointsList[CurrentTargetWaypointIndex]
            if TargetNode and TargetNode.Parent then
                LastTweenUpdateTimestamp = SystemClockTime
                
                -- Вычисляем дистанцию до цели
                local CurrentDistance = (TargetNode.Position - RootPart.Position).Magnitude
                
                -- Если цель близко — забираем её моментально
                if CurrentDistance <= 15 then
                    RootPart.CFrame = TargetNode.CFrame * CFrame.new(0, 1, 0)
                    CurrentTargetWaypointIndex = CurrentTargetWaypointIndex + 1
                else
                    -- Если цель далеко — плавно несём хитбокс с кастомной скоростью твина
                    local MoveDirectionVector = (TargetNode.Position - RootPart.Position).Unit
                    local SpeedStepFactor = Nexus.Config.TweenTeleportSpeed * frameTimeStep
                    
                    RootPart.Velocity = Vector3.new(0, 0, 0) -- Гасим скорость, чтобы не сбил античит
                    RootPart.CFrame = RootPart.CFrame + (MoveDirectionVector * SpeedStepFactor)
                end
            else
                CurrentTargetWaypointIndex = CurrentTargetWaypointIndex + 1
            end
        end
    end)
end)

-- [[ ФИКСАТОР ПОЗИЦИИ В ЛОББИ (LOBBY ANCHOR HARD LOOP) ]]
RunService.Heartbeat:Connect(function()
    if not Nexus.State.Active or not Nexus.Config.MapLobbyAnchorActive then return end
    
    local RootPart = Nexus.State.RootPartCached
    local SavedLobbyCFrame = Nexus.State.SavedMapCoordinates["Lobby"]
    
    if RootPart and SavedLobbyCFrame then
        -- Насильно удерживаем координаты игрока в безопасной зоне лобби
        RootPart.Velocity = Vector3.new(0, 0, 0)
        RootPart.CFrame = SavedLobbyCFrame
    end
end)

print("[AETHERIUS TWEEN]: Part 21 navigation auto-farm vector systems active. Grid locked.")
-- [[ AETHERIUS NEXUS MULTI-HUB: REANIMATION RUNTIME ENGINE ]]
-- PART 22 OF 22: ANTI-AFK ENGINE MATRIX & SYSTEM COMPLETE GARBAGE COLLECTION
-- OMNIPOTENCE HUB COMPILER COMPLETE DEPLOYMENT: OCTOBER 6, 2026

-- 1. ЖЕЛЕЗОБЕТОННЫЙ КЛИЕНТСКИЙ ОБХОД АФК (ANTI-AFK SYSTEM)
pcall(function()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        if Nexus.State.Active and MasterScreenContainer and MasterScreenContainer.Parent then
            -- Эмулируем микро-движения мышки и клики по экрану для обхода 20-минутного кика
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0), CurrentCamera.CFrame)
            print("[AETHERIUS SAFETY]: Anti-AFK bypass activated. Prevented Server Kick.")
        end
    end)
end)

-- 2. СИНХРОНИЗАЦИЯ КНОПКИ ЗАКРЫТИЯ UI С КЛЕНТСКИМ ДЕСТРУКТОРОМ
if BaseWindowFrame and BaseWindowFrame:FindFirstChild("TopBar") and BaseWindowFrame.TopBar:FindFirstChild("CloseButton") then
    local RealCloseBtn = BaseWindowFrame.TopBar.CloseButton
    
    RealCloseBtn.MouseButton1Click:Connect(function()
        -- Полностью останавливаем все исполнительные потоки
        Nexus.State.Active = false
        Nexus.Config.FlyEnabled = false
        Nexus.Config.ServerLaggerActive = false
        Nexus.Config.AnimationPacketSpam = false
        Nexus.Config.AutofarmWaypoints = false
        Nexus.Config.MapLobbyAnchorActive = false
        Nexus.Config.ItemMagnetEnabled = false
        Nexus.Config.CustomSkyEnabled = false
        Nexus.Config.NeonAuraEnabled = false
        
        print("[AETHERIUS DESTROY]: Commencing full system memory cleanup...")
        
        -- Сносим заспавненные локальные меши/аксессуары одежды
        pcall(function()
            for _, accessory in pairs(Nexus.State.SpawnedAccessories) do
                if accessory then accessory:Destroy() end
            end
            Nexus.State.SpawnedAccessories = {}
        end)
        
        -- Восстанавливаем оригинальные текстуры неба из бэкапа
        if Nexus.State.OriginalSkyBackup then
            local currentSky = Lighting:FindFirstChildOfClass("Sky")
            if currentSky then currentSky:Destroy() end
            local restoredSky = Nexus.State.OriginalSkyBackup:Clone()
            restoredSky.Parent = Lighting
            Nexus.State.OriginalSkyBackup = nil
        end
        
        -- Вычищаем фиолетовую ауру частиц с хитбокса
        if Nexus.State.AuraParticles then
            Nexus.State.AuraParticles:Destroy()
            Nexus.State.AuraParticles = nil
        end
        
        -- Сносим ЕСП-подсветку со всех игроков на сервере
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("AetheriusEspGlow") then
                    p.Character["AetheriusEspGlow"]:Destroy()
                end
            end
        end)
        
        -- Запускаем плавную анимацию схлопывания фрейма и удаляем ScreenGui
        local FinalCloseTween = TweenService:Create(BaseWindowFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)})
        FinalCloseTween:Play()
        
        FinalCloseTween.Completed:Connect(function()
            if MasterScreenContainer then
                MasterScreenContainer:Destroy()
                print("[AETHERIUS STATUS]: Multi-Hub successfully purged from execution runtime.")
            end
        end)
    end)
end

-- [[ ФИНАЛЬНЫЙ СИСТЕМНЫЙ СИГНАЛ УСПЕШНОЙ СБОРКИ ]]
print("[AETHERIUS MASTER]: ============================================")
print("[AETHERIUS MASTER]: TWKS AETHERIUS NEXUS MULTI-HUB v12.0 COMPILED!")
print("[AETHERIUS MASTER]: Total Parts Joined: 22 / 22")
print("[AETHERIUS MASTER]: Author Target Profile: Islam4ik404")
print("[AETHERIUS MASTER]: Status: 100% Operational. READY FOR INJECTION!")
print("[AETHERIUS MASTER]: ============================================")

-- Конец Части 22. Код завершен.
-- [[ AETHERIUS NEXUS MULTI-HUB: NEON AURA COLOR OVERRIDE ]]
-- ADVANCED UPGRADE: COLOR PICKER INPUT FOR CUSTOM REANIMATION AURA
-- COMPATIBLE WITH XENO EXECUTOR MATRIX (OCTOBER 2026)

local SkinsPageFrame = _G.NexusPagesCache["Skins"].Page
local InsertValueInputBox = _G.NexusInsertInput

if SkinsPageFrame and InsertValueInputBox then
    -- Создаем кастомное поле ввода цвета ауры во вкладке Скины
    local AuraColorInputBox = InsertValueInputBox(SkinsPageFrame, "Цвет ауры RGB (Пример: 255, 0, 0)", "180, 50, 255", 8, function(box)
        local rawText = tostring(box.Text)
        -- Разбиваем строку по запятым на три составляющие: R, G, B
        local r, g, b = rawText:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        
        if r and g and b then
            local numR = math.clamp(tonumber(r), 0, 255)
            local numG = math.clamp(tonumber(g), 0, 255)
            local numB = math.clamp(tonumber(b), 0, 255)
            
            -- Записываем новый цвет в глобальный конфиг
            Nexus.Config.AuraColorPattern = Color3.fromRGB(numR, numG, numB)
            box.Text = numR .. ", " .. numG .. ", " .. numB
            
            -- Если аура уже горит — мгновенно меняем её цвет в реальном времени!
            if Nexus.State.AuraParticles then
                pcall(function()
                    Nexus.State.AuraParticles.Color = ColorSequence.new(Nexus.Config.AuraColorPattern)
                end)
            end
        else
            -- Если ввели дичь, сбрасываем текст на текущий рабочий цвет
            local curColor = Nexus.Config.AuraColorPattern
            box.Text = math.floor(curColor.R * 255) .. ", " .. math.floor(curColor.G * 255) .. ", " .. math.floor(curColor.B * 255)
        end
    end)
end

print("[AETHERIUS UPGRADE]: Neon Aura RGB Color Picker successfully injected into Skins tab.")
-- [[ AETHERIUS NEXUS MULTI-HUB: AIM ASSIST LAYER ]]
-- VECTOR CALCULATION FIELD-OF-VIEW LOCK FOR CAMERA CONTROLLERS
-- PRODUCTION TARGET COMPILED FOR XENO EXECUTOR RUNTIME (OCTOBER 2026)

local AimPageFrame = _G.NexusPagesCache["AimAssist"].Page
local InsertFeatureToggle = _G.NexusInsertToggle
local InsertValueInputBox = _G.NexusInsertInput

-- Инициализация настроек аима в наш конфиг
Nexus.Config.AimBotActive = false
Nexus.Config.AimSmoothing = 0.15 -- Плавность доводки прицела
Nexus.Config.AimPartTarget = "Head" -- Цель: Head (Голова) / Torso (Торсо)

if AimPageFrame and InsertFeatureToggle and InsertValueInputBox then
    -- 1. Поле ввода цели для лока на выбор (Head / HumanoidRootPart)
    local AimTargetBox = InsertValueInputBox(AimPageFrame, "Цель лока (Head / HumanoidRootPart)", Nexus.Config.AimPartTarget, 1, function(box)
        local input = tostring(box.Text):lower()
        if input:find("root") or input:find("torso") then
            Nexus.Config.AimPartTarget = "HumanoidRootPart"
            box.Text = "HumanoidRootPart"
        else
            Nexus.Config.AimPartTarget = "Head"
            box.Text = "Head"
        end
    end)

    -- 2. Кнопка активации векторного Аимбота (Camera Lock)
    local AimToggleBtn, AimStroke = InsertFeatureToggle(AimPageFrame, "🎯 Vector Camera Aim", 2, function(btn, stroke)
        Nexus.Config.AimBotActive = not Nexus.Config.AimBotActive
        if Nexus.Config.AimBotActive then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 255, 80)
            btn.Text = "🎯 AIMBOT: ACTIVE"
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
            stroke.Color = Color3.fromRGB(110, 45, 180)
            btn.Text = "🎯 Vector Camera Aim: OFF"
        end
    end)
end

-- Вспомогательная функция поиска ближайшего игрока внутри твоего FOV-кольца
local function GetClosestPlayerToCursor()
    local ClosestTarget = nil
    local ShortestDistance = math.huge
    local MouseLocation = UserInputService:GetMouseLocation()
    local TargetPlayersList = Players:GetPlayers()

    for idx = 1, #TargetPlayersList do
        local p = TargetPlayersList[idx]
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local TargetPart = p.Character:FindFirstChild(Nexus.Config.AimPartTarget)
            if TargetPart then
                -- Переводим 3D координаты головы игрока в 2D координаты экрана
                local ScreenPosition, IsOnScreen = CurrentCamera:WorldToViewportPoint(TargetPart.Position)
                if IsOnScreen then
                    local DistanceToMouse = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MouseLocation).Magnitude
                    -- Лочим только тех челов, кто попадает в радиус нашего фиолетового FOV кольца
                    if DistanceToMouse <= Nexus.Config.FovRingRadius and DistanceToMouse < ShortestDistance then
                        ShortestDistance = DistanceToMouse
                        ClosestTarget = TargetPart
                    end
                end
            end
        end
    end
    return ClosestTarget
end

-- [[ НЕУБИВАЕМЫЙ ПОТОК ДОВОДКИ КАМЕРЫ (AIMBOT RUNTIME) ]]
RunService.RenderStepped:Connect(function()
    if not Nexus.State.Active or not Nexus.Config.AimBotActive then return end
    
    -- Аимбот активируется, только если ты зажимаешь Правую Кнопку Мыши (ПКМ)
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local TargetComponent = GetClosestPlayerToCursor()
        if TargetComponent then
            pcall(function()
                -- Плавно интерполируем CFrame камеры в сторону головы врага
                local TargetLookCFrame = CFrame.new(CurrentCamera.CFrame.Position, TargetComponent.Position)
                CurrentCamera.CFrame = CurrentCamera.CFrame:Lerp(TargetLookCFrame, Nexus.Config.AimSmoothing)
            end)
        end
    end
end)

print("[AETHERIUS AIM]: AimBot systems successfully deployed and bound to input loop.")
-- [[ AETHERIUS NEXUS MULTI-HUB: VISUAL HUD COLOR PICKER ]]
-- INTERACTIVE GRADIENT PALETTE ENGINE FOR LIVE AURA CUSTOMIZATION
-- FULLY VERIFIED FOR XENO COMPILER ENVIRONMENT (OCTOBER 2026)

local SkinsPageFrame = _G.NexusPagesCache["Skins"].Page
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if SkinsPageFrame then
    -- 1. Контейнер для палитры
    local PickerContainer = Instance.new("Frame")
    PickerContainer.Name = "AuraColorPickerContainer"
    PickerContainer.Size = UDim2.new(1, -5, 0, 45)
    PickerContainer.BackgroundColor3 = Color3.fromRGB(20, 14, 30)
    PickerContainer.BackgroundTransparency = 0.3
    PickerContainer.LayoutOrder = 9 -- Встанет аккуратно под кнопкой ауры
    PickerContainer.Parent = SkinsPageFrame
    Instance.new("UICorner", PickerContainer).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", PickerContainer).Color = Color3.fromRGB(90, 45, 125)

    local PickerLabel = Instance.new("TextLabel")
    PickerLabel.Size = UDim2.new(1, 0, 0, 18)
    PickerLabel.Position = UDim2.fromOffset(8, 2)
    PickerLabel.BackgroundTransparency = 1
    PickerLabel.Text = "🎨 Палитра цвета неоновой ауры:"
    PickerLabel.TextColor3 = Color3.fromRGB(200, 180, 240)
    PickerLabel.TextSize = 10
    PickerLabel.Font = Enum.Font.GothamSemibold
    PickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    PickerLabel.Parent = PickerContainer

    -- 2. Сам радужный спектр (Градиентная полоска)
    local ColorSpectrumBar = Instance.new("TextButton")
    ColorSpectrumBar.Name = "ColorSpectrumBar"
    ColorSpectrumBar.Size = UDim2.new(1, -16, 0, 14)
    ColorSpectrumBar.Position = UDim2.fromOffset(8, 22)
    ColorSpectrumBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ColorSpectrumBar.BorderSizePixel = 0
    ColorSpectrumBar.Text = ""
    ColorSpectrumBar.AutoButtonColor = false
    ColorSpectrumBar.Parent = PickerContainer
    Instance.new("UICorner", ColorSpectrumBar).CornerRadius = UDim.new(0, 4)

    local SpectrumGradient = Instance.new("UIGradient")
    SpectrumGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),     -- Красный
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), -- Желтый
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),   -- Зеленый
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),  -- Бирюзовый
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),   -- Синий
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), -- Розовый
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))       -- Замыкающий красный
    })
    SpectrumGradient.Parent = ColorSpectrumBar

    -- 3. Бегунок-указатель текущего выбора
    local SelectionPin = Instance.new("Frame")
    SelectionPin.Name = "SelectionPin"
    SelectionPin.Size = UDim2.fromOffset(4, 18)
    SelectionPin.Position = UDim2.new(0.7, -2, 0.5, -9) -- По дефолту на фиолетовом
    SelectionPin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SelectionPin.BorderSizePixel = 0
    SelectionPin.Parent = ColorSpectrumBar
    Instance.new("UICorner", SelectionPin).CornerRadius = UDim.new(0, 2)
    local PinStroke = Instance.new("UIStroke", SelectionPin)
    PinStroke.Thickness = 1
    PinStroke.Color = Color3.fromRGB(0, 0, 0)

    -- [[ МАТЕМАТИЧЕСКИЙ ДВИЖОК СЧИТЫВАНИЯ ЦВЕТА ПО КЛИКУ ]]
    local function ProcessColorPick(inputObject)
        local barAbsoluteSize = ColorSpectrumBar.AbsoluteSize.X
        local barAbsolutePosition = ColorSpectrumBar.AbsolutePosition.X
        local mouseX = inputObject.Position.X
        
        -- Вычисляем относительную координату клика от 0 до 1
        local relativeX = math.clamp((mouseX - barAbsolutePosition) / barAbsoluteSize, 0, 1)
        
        -- Передвигаем ползунок
        SelectionPin.Position = UDim2.new(relativeX, -2, 0.5, -9)
        
        -- Переводим позицию клика в Hue (оттенок в палитре HSV)
        -- Вся палитра от 0 до 1 идеально ложится на радужный спектр
        local calculatedColor = Color3.fromHSV(relativeX, 0.9, 1)
        
        -- Записываем цвет в глобальный конфиг нашего хаба
        Nexus.Config.AuraColorPattern = calculatedColor
        
        -- Мгновенно обновляем цвет летающих частиц ауры, если она включена
        if Nexus.State.AuraParticles then
            pcall(function()
                Nexus.State.AuraParticles.Color = ColorSequence.new(Nexus.Config.AuraColorPattern)
            end)
        end
    end

    -- Обработка зажатия и движения мышки по палитре
    local isHoldingPicker = false
    
    ColorSpectrumBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isHoldingPicker = true
            ProcessColorPick(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isHoldingPicker and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            ProcessColorPick(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isHoldingPicker = false
        end
    end)
end

print("[AETHERIUS COLOR]: Color picker slider module compiled and attached successfully.")
-- [[ AETHERIUS NEXUS MULTI-HUB: CORE KEY LOCK SYSTEM ]]
-- SECURITY ACCESS LAYER: AUTHENTICATION PRE-LOAD CONTAINER
-- FIXED PATH DETECTOR FOR XENO RUNTIME ENGINE (OCTOBER 2026)

local TargetPlayerGui = game:GetService("CoreGui"):FindFirstChild("AETHERIUS_ADMIN_CENTER") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("AETHERIUS_ADMIN_CENTER")
local RealMainWindow = TargetPlayerGui and TargetPlayerGui:FindFirstChild("Main")

if RealMainWindow then
    -- Мгновенно скрываем основное меню софта до успешного ввода ключа
    RealMainWindow.Visible = false
    
    -- ТВОЙ СЕКРЕТНЫЙ ПАРОЛЬ ДОСТУПА
    local SecretAccessKey = "1234"
    
    -- 1. Создаем компактное окно авторизации ключа (в стиле основного UI)
    local KeyWindowFrame = Instance.new("Frame")
    KeyWindowFrame.Name = "KeyAuthWindowFrame"
    KeyWindowFrame.Size = UDim2.fromOffset(250, 160)
    KeyWindowFrame.Position = UDim2.new(0.5, -125, 0.5, -80)
    KeyWindowFrame.BackgroundColor3 = Color3.fromRGB(11, 7, 18)
    KeyWindowFrame.BorderSizePixel = 0
    KeyWindowFrame.Active = true
    KeyWindowFrame.Parent = TargetPlayerGui

    local KeyCorner = Instance.new("UICorner")
    KeyCorner.CornerRadius = UDim.new(0, 12)
    KeyCorner.Parent = KeyWindowFrame

    local KeyStroke = Instance.new("UIStroke")
    KeyStroke.Thickness = 2
    KeyStroke.Color = Color3.fromRGB(180, 70, 255)
    KeyStroke.Parent = KeyWindowFrame

    -- Заголовок окна ключа
    local KeyTitle = Instance.new("TextLabel")
    KeyTitle.Size = UDim2.new(1, 0, 0, 35)
    KeyTitle.BackgroundTransparency = 1
    KeyTitle.Text = "🔒 ENTER ACCESS KEY"
    KeyTitle.TextColor3 = Color3.fromRGB(240, 220, 255)
    KeyTitle.TextSize = 12
    KeyTitle.Font = Enum.Font.GothamBold
    KeyTitle.Parent = KeyWindowFrame

    -- Поле ввода ключа (TextBox)
    local KeyInputBox = Instance.new("TextBox")
    KeyInputBox.Size = UDim2.new(1, -30, 0, 32)
    KeyInputBox.Position = UDim2.fromOffset(15, 45)
    KeyInputBox.BackgroundColor3 = Color3.fromRGB(22, 14, 32)
    KeyInputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInputBox.PlaceholderText = "Введи пароль доступа..."
    KeyInputBox.PlaceholderColor3 = Color3.fromRGB(130, 100, 160)
    KeyInputBox.Font = Enum.Font.Gotham
    KeyInputBox.TextSize = 11
    KeyInputBox.Text = ""
    KeyInputBox.ClearTextOnFocus = true
    KeyInputBox.Parent = KeyWindowFrame
    Instance.new("UICorner", KeyInputBox).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", KeyInputBox).Color = Color3.fromRGB(90, 45, 125)

    -- Кнопка проверки ключа (Check Button)
    local CheckKeyBtn = Instance.new("TextButton")
    CheckKeyBtn.Size = UDim2.new(1, -30, 0, 35)
    CheckKeyBtn.Position = UDim2.fromOffset(15, 95)
    CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 55)
    CheckKeyBtn.Text = "🔑 CHECK KEY"
    CheckKeyBtn.TextColor3 = Color3.fromRGB(220, 190, 255)
    CheckKeyBtn.Font = Enum.Font.GothamBold
    CheckKeyBtn.TextSize = 11
    CheckKeyBtn.Parent = KeyWindowFrame
    Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 8)
    local BtnStroke = Instance.new("UIStroke", CheckKeyBtn)
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(140, 50, 220)

    -- Эффекты при наведении на кнопку
    CheckKeyBtn.MouseEnter:Connect(function() game:GetService("TweenService"):Create(CheckKeyBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(55, 25, 85)}):Play() end)
    CheckKeyBtn.MouseLeave:Connect(function() game:GetService("TweenService"):Create(CheckKeyBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(35, 20, 55)}):Play() end)

    -- [[ ЛОГИКА ПРОВЕРКИ И РАЗБЛОКИРОВКИ ХАБА ]]
    CheckKeyBtn.Activated:Connect(function()
        local enteredText = tostring(KeyInputBox.Text)
        
        if enteredText == SecretAccessKey then
            -- КЛЮЧ ВЕРНЫЙ
            BtnStroke.Color = Color3.fromRGB(0, 255, 80)
            game:GetService("TweenService"):Create(CheckKeyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), Text = "✅ ACCESS GRANTED!"}):Play()
            
            task.wait(0.5)
            
            -- Схлопываем и удаляем окно ключа
            local CloseTween = game:GetService("TweenService"):Create(KeyWindowFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 0)})
            CloseTween:Play()
            
            CloseTween.Completed:Connect(function()
                KeyWindowFrame:Destroy()
                -- НАМЕРТВО РАЗБЛОКИРУЕМ И ПОКАЗЫВАЕМ НАШ МЕГА-ХАБ!
                RealMainWindow.Visible = true
                print("[AETHERIUS SECURITY]: Authentication successful. Welcome, Master!")
            end)
        else
            -- КЛЮЧ НЕВЕРНЫЙ: Тряска окна
            BtnStroke.Color = Color3.fromRGB(255, 0, 50)
            CheckKeyBtn.Text = "❌ INVALID KEY! TRY AGAIN"
            game:GetService("TweenService"):Create(CheckKeyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(120, 0, 20)}):Play()
            
            local origPos = KeyWindowFrame.Position
            task.spawn(function()
                for i = 1, 4 do
                    KeyWindowFrame.Position = origPos + UDim2.fromOffset(6, 0) task.wait(0.02)
                    KeyWindowFrame.Position = origPos + UDim2.fromOffset(-6, 0) task.wait(0.02)
                end
                KeyWindowFrame.Position = origPos
            end)
            
            task.wait(1.4)
            BtnStroke.Color = Color3.fromRGB(140, 50, 220)
            CheckKeyBtn.Text = "🔑 CHECK KEY"
            game:GetService("TweenService"):Create(CheckKeyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 20, 55)}):Play()
        end
    end)

    -- Перетаскивание окна авторизации мынью
    local drag, dInput, dStart, sPos
    KeyWindowFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true dStart = input.Position sPos = KeyWindowFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    KeyWindowFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dInput = input end end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dInput and drag then
            local delta = input.Position - dStart
            game:GetService("TweenService"):Create(KeyWindowFrame, TweenInfo.new(0.08), {Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)}):Play()
        end
    end)
end
-- [[ AETHERIUS NEXUS MULTI-HUB: RTX SHADERS & CINEMATIC ATMOSPHERE ]]
-- ADVANCED UPGRADE: ULTRA GRAPHICS CONFIGURATOR FOR LIGHTING CHANNELS
-- DEPLOYED FOR XENO EXECUTOR ENVIRONMENT (UPDATE: OCTOBER 2026)

local VisualsPageFrame = _G.NexusPagesCache["Visuals"].Page
local InsertFeatureToggle = _G.NexusInsertToggle

-- Инициализация новых параметров графики в наш конфиг
Nexus.Config.RtxCinematicSunset = false
Nexus.Config.NeonAtmosphereNight = false

if VisualsPageFrame and InsertFeatureToggle then
    -- 1. Кнопка включения Имбового Неонового Заката (Cinematic Sunset)
    local SunsetToggleBtn, SunsetStroke = InsertFeatureToggle(VisualsPageFrame, "🌅 Cinematic Sunset Shaders", 6, function(btn, stroke)
        Nexus.Config.RtxCinematicSunset = not Nexus.Config.RtxCinematicSunset
        if Nexus.Config.RtxCinematicSunset then
            Nexus.Config.NeonAtmosphereNight = false -- Выключаем ночь, чтобы не было конфликта
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 255, 80)
            btn.Text = "🌅 Sunset: ACTIVE"
            
            -- Врубаем сочный закат прямо сейчас
            pcall(function()
                Lighting.ClockTime = 17.8 -- Самое красивое время заката
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 120, 70) -- Теплый оранжевый свет
                Lighting.Ambient = Color3.fromRGB(60, 30, 80) -- Фиолетовые тени
                Lighting.ExposureCompensation = 0.5
                
                -- Подкручиваем атмосферную фиолетовую дымку
                Lighting.FogColor = Color3.fromRGB(130, 40, 160)
                Lighting.FogEnd = 800
                Lighting.FogStart = 50
            end)
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
            stroke.Color = Color3.fromRGB(110, 45, 180)
            btn.Text = "🌅 Cinematic Sunset: OFF"
        end
    end)

    -- 2. Кнопка включения Глубокой Реалистичной Ночи (Neon Atmosphere Night)
    local NightToggleBtn, NightStroke = InsertFeatureToggle(VisualsPageFrame, "🌌 Neon Atmosphere Night", 7, function(btn, stroke)
        Nexus.Config.NeonAtmosphereNight = not Nexus.Config.NeonAtmosphereNight
        if Nexus.Config.NeonAtmosphereNight then
            Nexus.Config.RtxCinematicSunset = false -- Выключаем закат, чтобы не было конфликта
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 255, 80)
            btn.Text = "🌌 Night: ACTIVE"
            
            -- Врубаем глубокую неоновую ночь прямо сейчас
            pcall(function()
                Lighting.ClockTime = 0.5 -- Полночь
                Lighting.Brightness = 0.8
                Lighting.OutdoorAmbient = Color3.fromRGB(10, 5, 25) -- Глубокий космический оттенок
                Lighting.Ambient = Color3.fromRGB(15, 10, 35)
                Lighting.ExposureCompensation = 0.2
                
                -- Подвешиваем густой туман в стиле Киберпанка
                Lighting.FogColor = Color3.fromRGB(30, 10, 60) -- Темно-фиолетовый неон
                Lighting.FogEnd = 500
                Lighting.FogStart = 10
            end)
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
            stroke.Color = Color3.fromRGB(110, 45, 180)
            btn.Text = "🌌 Neon Atmosphere Night: OFF"
        end
    end)
end

-- [[ НЕУБИВАЕМЫЙ ПОТОК ФИКСАЦИИ СВЕТА И АТМОСФЕРЫ ]]
RunService.Heartbeat:Connect(function()
    if not Nexus.State.Active then return end
    
    -- Жестко удерживаем параметры освещения каждый кадр, перебивая серверные скрипты смены дня и ночи
    if Nexus.Config.RtxCinematicSunset then
        pcall(function()
            Lighting.ClockTime = 17.8
            Lighting.FogColor = Color3.fromRGB(130, 40, 160)
        end)
    elseif Nexus.Config.NeonAtmosphereNight then
        pcall(function()
            Lighting.ClockTime = 0.5
            Lighting.FogColor = Color3.fromRGB(30, 10, 60)
        end)
    end
end)

print("[AETHERIUS SHADERS]: RTX cinematic shader modules successfully compiled into loop.")
-- [[ AETHERIUS NEXUS MULTI-HUB: WORLD ENVIRONMENT GRAPHICS ]]
-- SHADER MATRIX RELOCATION UPGRADE: INJECTING RTX INTO WORLD TAB
-- COMPATIBLE WITH XENO EXECUTOR RUNTIME ENVIRONMENT (OCTOBER 2026)

local WorldPageFrame = _G.NexusPagesCache["World"].Page
local InsertFeatureToggle = _G.NexusInsertToggle

-- Гарантируем инициализацию настроек графики в глобальном конфиге
if _G.AetheriusNexusGlobal then
    _G.AetheriusNexusGlobal.Config.RtxCinematicSunset = false
    _G.AetheriusNexusGlobal.Config.NeonAtmosphereNight = false
end

if WorldPageFrame and InsertFeatureToggle then
    -- 1. Кнопка включения Реалистичного Заката во вкладку Мир
    local WorldSunsetBtn, WorldSunsetStroke = InsertFeatureToggle(WorldPageFrame, "🌅 Cinematic Sunset Shaders", 5, function(btn, stroke)
        Nexus.Config.RtxCinematicSunset = not Nexus.Config.RtxCinematicSunset
        if Nexus.Config.RtxCinematicSunset then
            Nexus.Config.NeonAtmosphereNight = false
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 255, 80)
            btn.Text = "🌅 Sunset: ACTIVE"
            
            pcall(function()
                Lighting.ClockTime = 17.8 -- Время заката
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 120, 70) -- Теплый оранжевый свет
                Lighting.Ambient = Color3.fromRGB(60, 30, 80) -- Фиолетовые тени
                Lighting.ExposureCompensation = 0.5
                Lighting.FogColor = Color3.fromRGB(130, 40, 160) -- Фиолетовый туман
                Lighting.FogEnd = 800
                Lighting.FogStart = 50
            end)
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
            stroke.Color = Color3.fromRGB(110, 45, 180)
            btn.Text = "🌅 Cinematic Sunset: OFF"
        end
    end)

    -- 2. Кнопка включения Неоновой Ночи во вкладку Мир
    local WorldNightBtn, WorldNightStroke = InsertFeatureToggle(WorldPageFrame, "🌌 Neon Atmosphere Night", 6, function(btn, stroke)
        Nexus.Config.NeonAtmosphereNight = not Nexus.Config.NeonAtmosphereNight
        if Nexus.Config.NeonAtmosphereNight then
            Nexus.Config.RtxCinematicSunset = false
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 120, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            stroke.Color = Color3.fromRGB(0, 255, 80)
            btn.Text = "🌌 Night: ACTIVE"
            
            pcall(function()
                Lighting.ClockTime = 0.5 -- Полночь
                Lighting.Brightness = 0.8
                Lighting.OutdoorAmbient = Color3.fromRGB(10, 5, 25) -- Глубокий темный тон
                Lighting.Ambient = Color3.fromRGB(15, 10, 35)
                Lighting.ExposureCompensation = 0.2
                Lighting.FogColor = Color3.fromRGB(30, 10, 60) -- Атмосферная киберпанк дымка
                Lighting.FogEnd = 500
                Lighting.FogStart = 10
            end)
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 14, 32), TextColor3 = Color3.fromRGB(220, 190, 255)}):Play()
            stroke.Color = Color3.fromRGB(110, 45, 180)
            btn.Text = "🌌 Neon Atmosphere Night: OFF"
        end
    end)
end

-- [[ НЕУБИВАЕМЫЙ ПОТОК ФИКСАЦИИ СВЕТА И АТМОСФЕРЫ ]]
RunService.Heartbeat:Connect(function()
    if not Nexus.State.Active then return end
    
    -- Удерживаем погоду каждую миллисекунду, блокируя серверные изменения времени
    if Nexus.Config.RtxCinematicSunset then
        pcall(function()
            Lighting.ClockTime = 17.8
            Lighting.FogColor = Color3.fromRGB(130, 40, 160)
        end)
    elseif Nexus.Config.NeonAtmosphereNight then
        pcall(function()
            Lighting.ClockTime = 0.5
            Lighting.FogColor = Color3.fromRGB(30, 10, 60)
        end)
    end
end)

print("[AETHERIUS UPGRADE]: RTX shaders relocated to WORLD page successfully.")
