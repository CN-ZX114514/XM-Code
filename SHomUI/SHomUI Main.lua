--[[
    AdvancedUI v2.0.0
    一个功能完整的 Roblox 高级 UI 库
    设计灵感来自 Obsidian UI，但完全重写并增强
    作者: AI Assistant
    许可证: MIT
]]

-- ==================== 核心模块 ====================
local AdvancedUI = {}
AdvancedUI.__index = AdvancedUI

-- 服务引用
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- 本地玩家
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ==================== 配置常量 ====================
local CONFIG = {
    Version = "2.0.0",
    DefaultTheme = "Dark",
    AnimationSpeed = 0.2,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    WindowMinSize = UDim2.new(0, 300, 0, 200),
    WindowMaxSize = UDim2.new(0, 800, 0, 600),
    ElementPadding = 5,
    GroupboxPadding = 10,
    Font = Enum.Font.Code,
    TextSize = 14,
    CornerRadius = UDim.new(0, 6),
    ShadowEnabled = true,
    SaveConfig = true,
    ConfigFolder = "AdvancedUI_Configs"
}

-- ==================== 主题系统 ====================
local THEMES = {
    Dark = {
        Background = Color3.fromRGB(30, 30, 40),
        Foreground = Color3.fromRGB(240, 240, 240),
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(100, 100, 120),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Border = Color3.fromRGB(60, 60, 70),
        Hover = Color3.fromRGB(50, 50, 60),
        Active = Color3.fromRGB(40, 40, 50),
        Disabled = Color3.fromRGB(80, 80, 90)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Foreground = Color3.fromRGB(30, 30, 30),
        Primary = Color3.fromRGB(0, 120, 215),
        Secondary = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Border = Color3.fromRGB(220, 220, 220),
        Hover = Color3.fromRGB(235, 235, 235),
        Active = Color3.fromRGB(225, 225, 225),
        Disabled = Color3.fromRGB(200, 200, 200)
    },
    Blue = {
        Background = Color3.fromRGB(25, 35, 50),
        Foreground = Color3.fromRGB(240, 240, 240),
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(70, 90, 120),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Border = Color3.fromRGB(40, 50, 70),
        Hover = Color3.fromRGB(35, 45, 65),
        Active = Color3.fromRGB(30, 40, 60),
        Disabled = Color3.fromRGB(60, 70, 90)
    },
    Purple = {
        Background = Color3.fromRGB(40, 30, 50),
        Foreground = Color3.fromRGB(240, 240, 240),
        Primary = Color3.fromRGB(155, 89, 182),
        Secondary = Color3.fromRGB(100, 80, 120),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
        Info = Color3.fromRGB(52, 152, 219),
        Border = Color3.fromRGB(60, 50, 70),
        Hover = Color3.fromRGB(50, 40, 60),
        Active = Color3.fromRGB(45, 35, 55),
        Disabled = Color3.fromRGB(80, 70, 90)
    }
}

-- 当前主题
local CurrentTheme = THEMES[CONFIG.DefaultTheme]

-- ==================== 工具函数 ====================
local Utils = {}

-- 创建圆角
function Utils:CreateCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or CONFIG.CornerRadius
    return corner
end

-- 创建描边
function Utils:CreateStroke(thickness, color)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = color or CurrentTheme.Border
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return stroke
end

-- 创建阴影
function Utils:CreateShadow()
    if not CONFIG.ShadowEnabled then return nil end
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.8
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.SliceScale = 0.25
    shadow.ZIndex = -1
    
    return shadow
end

-- 创建渐变
function Utils:CreateGradient(colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = rotation or 0
    return gradient
end

-- 动画函数
function Utils:Tween(object, properties, duration, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        duration or CONFIG.AnimationSpeed,
        easingStyle or CONFIG.EasingStyle,
        easingDirection or CONFIG.EasingDirection
    )
    
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- 防抖函数
function Utils:Debounce(func, wait)
    local lastCall = 0
    return function(...)
        local now = tick()
        if now - lastCall >= wait then
            lastCall = now
            return func(...)
        end
    end
end

-- 节流函数
function Utils:Throttle(func, limit)
    local lastRun = 0
    return function(...)
        local now = tick()
        if now - lastRun >= limit then
            lastRun = now
            return func(...)
        end
    end
end

-- 深拷贝
function Utils:DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = Utils:DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- 生成唯一ID
function Utils:GenerateID()
    return HttpService:GenerateGUID(false)
end

-- 颜色转换
function Utils:RGBToHex(color)
    return string.format("#%02X%02X%02X", 
        math.floor(color.R * 255),
        math.floor(color.G * 255),
        math.floor(color.B * 255)
    )
end

function Utils:HexToRGB(hex)
    hex = hex:gsub("#", "")
    return Color3.fromRGB(
        tonumber(hex:sub(1, 2), 16),
        tonumber(hex:sub(3, 4), 16),
        tonumber(hex:sub(5, 6), 16)
    )
end

-- ==================== 通知系统 ====================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new()
    local self = setmetatable({}, NotificationManager)
    self.Notifications = {}
    self.NotificationQueue = {}
    self.MaxNotifications = 5
    self.NotificationSpacing = 5
    self.Parent = nil
    
    return self
end

function NotificationManager:SetParent(parent)
    self.Parent = parent
end

function NotificationManager:ShowNotification(options)
    if not self.Parent then
        warn("Notification parent not set!")
        return
    end
    
    local notification = self:CreateNotification(options)
    table.insert(self.Notifications, notification)
    
    self:UpdateNotificationPositions()
    
    task.delay(options.Duration or 5, function()
        self:HideNotification(notification)
    end)
    
    return notification
end

function NotificationManager:CreateNotification(options)
    local notification = Instance.new("Frame")
    notification.Name = "Notification_" .. Utils:GenerateID()
    notification.BackgroundColor3 = CurrentTheme.Background
    notification.BackgroundTransparency = 0.1
    notification.BorderSizePixel = 0
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.Position = UDim2.new(1, -310, 1, -85)
    notification.AnchorPoint = Vector2.new(1, 1)
    notification.ZIndex = 1000
    
    -- 阴影
    local shadow = Utils:CreateShadow()
    if shadow then
        shadow.Size = UDim2.new(1, 10, 1, 10)
        shadow.Position = UDim2.new(0, -5, 0, -5)
        shadow.Parent = notification
    end
    
    -- 圆角
    Utils:CreateCorner(UDim.new(0, 8)).Parent = notification
    
    -- 描边
    local stroke = Utils:CreateStroke(1)
    stroke.Parent = notification
    
    -- 图标
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.BackgroundTransparency = 1
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 15, 0.5, -12)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    
    local iconType = options.Type or "Info"
    local iconMap = {
        Success = "rbxassetid://3926305904",
        Error = "rbxassetid://3926305904",
        Warning = "rbxassetid://3926305904",
        Info = "rbxassetid://3926305904"
    }
    
    local iconRectMap = {
        Success = Vector2.new(1344, 672),
        Error = Vector2.new(1444, 672),
        Warning = Vector2.new(1394, 672),
        Info = Vector2.new(1294, 672)
    }
    
    icon.Image = iconMap[iconType]
    icon.ImageRectOffset = iconRectMap[iconType] or Vector2.new(1294, 672)
    icon.ImageRectSize = Vector2.new(48, 48)
    icon.ImageColor3 = CurrentTheme[iconType] or CurrentTheme.Info
    icon.Parent = notification
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -60, 0, 20)
    title.Position = UDim2.new(0, 50, 0, 15)
    title.Font = CONFIG.Font
    title.TextSize = 16
    title.TextColor3 = CurrentTheme.Foreground
    title.Text = options.Title or "通知"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Top
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = notification
    
    -- 内容
    local content = Instance.new("TextLabel")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -60, 1, -40)
    content.Position = UDim2.new(0, 50, 0, 35)
    content.Font = CONFIG.Font
    content.TextSize = 14
    content.TextColor3 = CurrentTheme.Secondary
    content.Text = options.Text or ""
    content.TextXAlignment = Enum.TextXAlignment.Left
    content.TextYAlignment = Enum.TextYAlignment.Top
    content.TextWrapped = true
    content.Parent = notification
    
    -- 关闭按钮
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(1, -25, 0, 10)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = CurrentTheme.Secondary
    closeButton.MouseButton1Click:Connect(function()
        self:HideNotification(notification)
    end)
    closeButton.Parent = notification
    
    -- 悬停效果
    closeButton.MouseEnter:Connect(function()
        Utils:Tween(closeButton, {ImageColor3 = CurrentTheme.Error}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utils:Tween(closeButton, {ImageColor3 = CurrentTheme.Secondary}, 0.2)
    end)
    
    -- 动画显示
    notification.Parent = self.Parent
    notification.Position = UDim2.new(1, 310, 1, -85)
    Utils:Tween(notification, {Position = UDim2.new(1, -310, 1, -85)}, 0.3)
    
    return notification
end

function NotificationManager:HideNotification(notification)
    for i, notif in ipairs(self.Notifications) do
        if notif == notification then
            table.remove(self.Notifications, i)
            break
        end
    end
    
    Utils:Tween(notification, {
        Position = UDim2.new(1, 310, notification.Position.Y.Scale, notification.Position.Y.Offset)
    }, 0.3):andThen(function()
        notification:Destroy()
        self:UpdateNotificationPositions()
    end)
end

function NotificationManager:UpdateNotificationPositions()
    for i, notification in ipairs(self.Notifications) do
        local targetY = 1 - (i * (80 + self.NotificationSpacing)) / self.Parent.AbsoluteSize.Y
        Utils:Tween(notification, {
            Position = UDim2.new(1, -310, targetY, -85)
        }, 0.2)
    end
end

function NotificationManager:ClearAll()
    for _, notification in ipairs(self.Notifications) do
        notification:Destroy()
    end
    self.Notifications = {}
end

-- ==================== 控件基类 ====================
local Control = {}
Control.__index = Control

function Control.new(name, options)
    local self = setmetatable({}, Control)
    self.Name = name
    self.Options = options or {}
    self.Enabled = true
    self.Visible = true
    self.Parent = nil
    self.Instance = nil
    self.Callbacks = {}
    
    return self
end

function Control:SetEnabled(enabled)
    self.Enabled = enabled
    if self.Instance then
        self.Instance.Visible = enabled and self.Visible
    end
end

function Control:SetVisible(visible)
    self.Visible = visible
    if self.Instance then
        self.Instance.Visible = visible and self.Enabled
    end
end

function Control:Destroy()
    if self.Instance then
        self.Instance:Destroy()
    end
    setmetatable(self, nil)
end

-- ==================== 按钮控件 ====================
local Button = setmetatable({}, {__index = Control})
Button.__index = Button

function Button.new(name, options)
    local self = setmetatable(Control.new(name, options), Button)
    self.Text = options.Text or "按钮"
    self.Callback = options.Callback or function() end
    
    return self
end

function Button:Create(parent)
    local button = Instance.new("TextButton")
    button.Name = self.Name
    button.BackgroundColor3 = CurrentTheme.Primary
    button.BackgroundTransparency = 0
    button.BorderSizePixel = 0
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = CONFIG.Font
    button.Text = self.Text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = CONFIG.TextSize
    button.AutoButtonColor = false
    button.Parent = parent
    
    -- 圆角
    Utils:CreateCorner().Parent = button
    
    -- 悬停效果
    button.MouseEnter:Connect(function()
        if self.Enabled then
            Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if self.Enabled then
            Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
        end
    end)
    
    -- 点击效果
    button.MouseButton1Down:Connect(function()
        if self.Enabled then
            Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Active}, 0.1)
        end
    end)
    
    button.MouseButton1Up:Connect(function()
        if self.Enabled then
            Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Hover}, 0.1)
        end
    end)
    
    -- 点击事件
    button.MouseButton1Click:Connect(function()
        if self.Enabled then
            self.Callback()
        end
    end)
    
    self.Instance = button
    self.Parent = parent
    
    return button
end

function Button:SetText(text)
    self.Text = text
    if self.Instance then
        self.Instance.Text = text
    end
end

-- ==================== 开关控件 ====================
local Toggle = setmetatable({}, {__index = Control})
Toggle.__index = Toggle

function Toggle.new(name, options)
    local self = setmetatable(Control.new(name, options), Toggle)
    self.Text = options.Text or "开关"
    self.Default = options.Default or false
    self.State = self.Default
    self.Callback = options.Callback or function() end
    
    return self
end

function Toggle:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Parent = parent
    
    -- 标签
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- 开关背景
    local toggleBackground = Instance.new("Frame")
    toggleBackground.Name = "ToggleBackground"
    toggleBackground.BackgroundColor3 = CurrentTheme.Secondary
    toggleBackground.Size = UDim2.new(0, 40, 0, 20)
    toggleBackground.Position = UDim2.new(1, -40, 0.5, -10)
    toggleBackground.AnchorPoint = Vector2.new(1, 0.5)
    toggleBackground.Parent = container
    
    Utils:CreateCorner(UDim.new(0, 10)).Parent = toggleBackground
    
    -- 开关滑块
    local toggleSlider = Instance.new("Frame")
    toggleSlider.Name = "ToggleSlider"
    toggleSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    toggleSlider.Size = UDim2.new(0, 16, 0, 16)
    toggleSlider.Position = UDim2.new(0, 2, 0.5, -8)
    toggleSlider.AnchorPoint = Vector2.new(0, 0.5)
    toggleSlider.Parent = toggleBackground
    
    Utils:CreateCorner(UDim.new(0, 8)).Parent = toggleSlider
    
    -- 点击区域
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.BackgroundTransparency = 1
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.Text = ""
    clickArea.Parent = container
    
    -- 初始化状态
    self:SetState(self.State)
    
    -- 点击事件
    clickArea.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)
    
    self.Instance = container
    self.Parent = parent
    self.ToggleBackground = toggleBackground
    self.ToggleSlider = toggleSlider
    
    return container
end

function Toggle:Toggle()
    self.State = not self.State
    self:UpdateVisual()
    self.Callback(self.State)
end

function Toggle:SetState(state)
    self.State = state
    self:UpdateVisual()
end

function Toggle:GetValue()
    return self.State
end

function Toggle:UpdateVisual()
    if not self.ToggleBackground or not self.ToggleSlider then return end
    
    if self.State then
        Utils:Tween(self.ToggleBackground, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
        Utils:Tween(self.ToggleSlider, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
    else
        Utils:Tween(self.ToggleBackground, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        Utils:Tween(self.ToggleSlider, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
    end
end

-- ==================== 滑块控件 ====================
local Slider = setmetatable({}, {__index = Control})
Slider.__index = Slider

function Slider.new(name, options)
    local self = setmetatable(Control.new(name, options), Slider)
    self.Text = options.Text or "滑块"
    self.Min = options.Min or 0
    self.Max = options.Max or 100
    self.Default = options.Default or self.Min
    self.Rounding = options.Rounding or 0
    self.Suffix = options.Suffix or ""
    self.Value = self.Default
    self.Callback = options.Callback or function() end
    self.Dragging = false
    
    return self
end

function Slider:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 50)
    container.Parent = parent
    
    -- 标签和值显示
    local labelContainer = Instance.new("Frame")
    labelContainer.Name = "LabelContainer"
    labelContainer.BackgroundTransparency = 1
    labelContainer.Size = UDim2.new(1, 0, 0, 20)
    labelContainer.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = labelContainer
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "ValueLabel"
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0.3, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.Font = CONFIG.Font
    valueLabel.Text = tostring(self.Value) .. self.Suffix
    valueLabel.TextColor3 = CurrentTheme.Secondary
    valueLabel.TextSize = CONFIG.TextSize
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = labelContainer
    
    -- 滑块轨道
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = CurrentTheme.Secondary
    track.Size = UDim2.new(1, 0, 0, 4)
    track.Position = UDim2.new(0, 0, 0, 30)
    track.Parent = container
    
    Utils:CreateCorner(UDim.new(0, 2)).Parent = track
    
    -- 滑块进度
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.BackgroundColor3 = CurrentTheme.Primary
    progress.Size = UDim2.new(0, 0, 1, 0)
    progress.Position = UDim2.new(0, 0, 0, 0)
    progress.Parent = track
    
    Utils:CreateCorner(UDim.new(0, 2)).Parent = progress
    
    -- 滑块手柄
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(0, -8, 0.5, -8)
    handle.AnchorPoint = Vector2.new(0, 0.5)
    handle.Parent = track
    
    Utils:CreateCorner(UDim.new(0, 8)).Parent = handle
    Utils:CreateStroke(2, CurrentTheme.Primary).Parent = handle
    
    -- 点击区域
    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.BackgroundTransparency = 1
    clickArea.Size = UDim2.new(1, 0, 0, 20)
    clickArea.Position = UDim2.new(0, 0, 0, 25)
    clickArea.Text = ""
    clickArea.Parent = container
    
    -- 初始化值
    self:SetValue(self.Value)
    
    -- 拖动逻辑
    local function updateValue(x)
        local relativeX = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local percentage = relativeX / track.AbsoluteSize.X
        local rawValue = self.Min + (self.Max - self.Min) * percentage
        
        -- 四舍五入
        local roundedValue
        if self.Rounding == 0 then
            roundedValue = math.floor(rawValue + 0.5)
        else
            local factor = 10 ^ self.Rounding
            roundedValue = math.floor(rawValue * factor + 0.5) / factor
        end
        
        roundedValue = math.clamp(roundedValue, self.Min, self.Max)
        
        if roundedValue ~= self.Value then
            self.Value = roundedValue
            self:UpdateVisual()
            self.Callback(self.Value)
        end
    end
    
    clickArea.MouseButton1Down:Connect(function()
        if not self.Enabled then return end
        self.Dragging = true
        updateValue(Mouse.X)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.Dragging then
            updateValue(Mouse.X)
        end
    end)
    
    self.Instance = container
    self.Parent = parent
    self.Track = track
    self.Progress = progress
    self.Handle = handle
    self.ValueLabel = valueLabel
    
    return container
end

function Slider:SetValue(value)
    self.Value = math.clamp(value, self.Min, self.Max)
    self:UpdateVisual()
end

function Slider:GetValue()
    return self.Value
end

function Slider:UpdateVisual()
    if not self.Track or not self.Progress or not self.Handle or not self.ValueLabel then return end
    
    local percentage = (self.Value - self.Min) / (self.Max - self.Min)
    local trackWidth = self.Track.AbsoluteSize.X
    
    self.Progress.Size = UDim2.new(percentage, 0, 1, 0)
    self.Handle.Position = UDim2.new(percentage, -8, 0.5, -8)
    
    -- 更新值显示
    local displayValue = self.Value
    if self.Rounding == 0 then
        displayValue = math.floor(displayValue)
    end
    self.ValueLabel.Text = tostring(displayValue) .. self.Suffix
end

-- ==================== 下拉菜单控件 ====================
local Dropdown = setmetatable({}, {__index = Control})
Dropdown.__index = Dropdown

function Dropdown.new(name, options)
    local self = setmetatable(Control.new(name, options), Dropdown)
    self.Text = options.Text or "下拉菜单"
    self.Values = options.Values or {}
    self.Default = options.Default or (self.Values[1] or "")
    self.Multi = options.Multi or false
    self.Selected = self.Multi and {} or self.Default
    self.Callback = options.Callback or function() end
    self.Open = false
    self.OptionButtons = {}
    
    if self.Multi then
        if type(self.Default) == "table" then
            self.Selected = self.Default
        else
            self.Selected = {self.Default}
        end
    end
    
    return self
end

function Dropdown:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 30)
    container.ClipsDescendants = true
    container.Parent = parent
    
    -- 主按钮
    local mainButton = Instance.new("TextButton")
    mainButton.Name = "MainButton"
    mainButton.BackgroundColor3 = CurrentTheme.Secondary
    mainButton.Size = UDim2.new(1, 0, 0, 30)
    mainButton.Position = UDim2.new(0, 0, 0, 0)
    mainButton.Font = CONFIG.Font
    mainButton.Text = ""
    mainButton.TextColor3 = CurrentTheme.Foreground
    mainButton.TextSize = CONFIG.TextSize
    mainButton.AutoButtonColor = false
    mainButton.Parent = container
    
    Utils:CreateCorner().Parent = mainButton
    
    -- 标签
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainButton
    
    -- 箭头图标
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 20, 0, 20)
    arrow.Position = UDim2.new(1, -25, 0.5, -10)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Image = "rbxassetid://3926305904"
    arrow.ImageRectOffset = Vector2.new(884, 284)
    arrow.ImageRectSize = Vector2.new(36, 36)
    arrow.ImageColor3 = CurrentTheme.Foreground
    arrow.Parent = mainButton
    
    -- 选项容器
    local optionsContainer = Instance.new("Frame")
    optionsContainer.Name = "OptionsContainer"
    optionsContainer.BackgroundColor3 = CurrentTheme.Active
    optionsContainer.Size = UDim2.new(1, 0, 0, 0)
    optionsContainer.Position = UDim2.new(0, 0, 0, 35)
    optionsContainer.ClipsDescendants = true
    optionsContainer.Parent = container
    
    Utils:CreateCorner().Parent = optionsContainer
    Utils:CreateStroke(1, CurrentTheme.Border).Parent = optionsContainer
    
    -- 选项列表
    local optionsList = Instance.new("UIListLayout")
    optionsList.Name = "OptionsList"
    optionsList.Padding = UDim.new(0, 1)
    optionsList.SortOrder = Enum.SortOrder.LayoutOrder
    optionsList.Parent = optionsContainer
    
    -- 创建选项
    self:CreateOptions(optionsContainer)
    
    -- 点击事件
    mainButton.MouseButton1Click:Connect(function()
        if self.Enabled then
            self:Toggle()
        end
    end)
    
    -- 悬停效果
    mainButton.MouseEnter:Connect(function()
        if self.Enabled then
            Utils:Tween(mainButton, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
        end
    end)
    
    mainButton.MouseLeave:Connect(function()
        if self.Enabled then
            Utils:Tween(mainButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end
    end)
    
    self.Instance = container
    self.Parent = parent
    self.MainButton = mainButton
    self.Label = label
    self.Arrow = arrow
    self.OptionsContainer = optionsContainer
    self.OptionsList = optionsList
    
    -- 更新显示文本
    self:UpdateDisplayText()
    
    return container
end

function Dropdown:CreateOptions(container)
    -- 清空现有选项
    for _, button in ipairs(self.OptionButtons) do
        button:Destroy()
    end
    self.OptionButtons = {}
    
    -- 创建新选项
    for i, value in ipairs(self.Values) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option_" .. value
        optionButton.BackgroundColor3 = CurrentTheme.Active
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.LayoutOrder = i
        optionButton.Font = CONFIG.Font
        optionButton.Text = value
        optionButton.TextColor3 = CurrentTheme.Foreground
        optionButton.TextSize = CONFIG.TextSize
        optionButton.AutoButtonColor = false
        optionButton.Parent = container
        
        -- 悬停效果
        optionButton.MouseEnter:Connect(function()
            if self.Enabled then
                Utils:Tween(optionButton, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
            end
        end)
        
        optionButton.MouseLeave:Connect(function()
            if self.Enabled then
                local isSelected = self.Multi and table.find(self.Selected, value) or self.Selected == value
                Utils:Tween(optionButton, {
                    BackgroundColor3 = isSelected and CurrentTheme.Primary or CurrentTheme.Active
                }, 0.2)
            end
        end)
        
        -- 点击事件
        optionButton.MouseButton1Click:Connect(function()
            if not self.Enabled then return end
            
            if self.Multi then
                local index = table.find(self.Selected, value)
                if index then
                    table.remove(self.Selected, index)
                else
                    table.insert(self.Selected, value)
                end
            else
                self.Selected = value
                self:Close()
            end
            
            self:UpdateDisplayText()
            self:UpdateOptionColors()
            self.Callback(self.Selected)
        end)
        
        table.insert(self.OptionButtons, optionButton)
    end
    
    -- 更新容器大小
    local optionCount = #self.Values
    local containerHeight = math.min(optionCount * 31, 155) -- 最多显示5个选项
    self.OptionsContainer.Size = UDim2.new(1, 0, 0, containerHeight)
end

function Dropdown:Toggle()
    if self.Open then
        self:Close()
    else
        self:OpenDropdown()
    end
end

function Dropdown:OpenDropdown()
    if not self.Enabled then return end
    
    self.Open = true
    Utils:Tween(self.Arrow, {Rotation = 180}, 0.2)
    Utils:Tween(self.OptionsContainer, {Size = UDim2.new(1, 0, 0, math.min(#self.Values * 31, 155))}, 0.2)
    Utils:Tween(self.Instance, {Size = UDim2.new(1, 0, 0, 30 + math.min(#self.Values * 31, 155))}, 0.2)
    
    self:UpdateOptionColors()
end

function Dropdown:Close()
    self.Open = false
    Utils:Tween(self.Arrow, {Rotation = 0}, 0.2)
    Utils:Tween(self.OptionsContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
    Utils:Tween(self.Instance, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
end

function Dropdown:UpdateDisplayText()
    if not self.Label then return end
    
    if self.Multi then
        if #self.Selected == 0 then
            self.Label.Text = self.Text
        elseif #self.Selected == 1 then
            self.Label.Text = self.Selected[1]
        else
            self.Label.Text = string.format("%s (%d)", self.Text, #self.Selected)
        end
    else
        self.Label.Text = self.Selected or self.Text
    end
end

function Dropdown:UpdateOptionColors()
    for _, button in ipairs(self.OptionButtons) do
        local value = button.Text
        local isSelected = self.Multi and table.find(self.Selected, value) or self.Selected == value
        
        Utils:Tween(button, {
            BackgroundColor3 = isSelected and CurrentTheme.Primary or CurrentTheme.Active
        }, 0.2)
    end
end

function Dropdown:SetValues(values)
    self.Values = values
    if self.OptionsContainer then
        self:CreateOptions(self.OptionsContainer)
        self:UpdateDisplayText()
    end
end

function Dropdown:SetSelected(selected)
    if self.Multi then
        self.Selected = type(selected) == "table" and selected or {selected}
    else
        self.Selected = selected
    end
    
    self:UpdateDisplayText()
    self:UpdateOptionColors()
end

function Dropdown:GetValue()
    return self.Selected
end

-- ==================== 输入框控件 ====================
local Input = setmetatable({}, {__index = Control})
Input.__index = Input

function Input.new(name, options)
    local self = setmetatable(Control.new(name, options), Input)
    self.Text = options.Text or "输入框"
    self.Placeholder = options.Placeholder or "请输入..."
    self.Default = options.Default or ""
    self.Numeric = options.Numeric or false
    self.Value = self.Default
    self.Callback = options.Callback or function() end
    
    return self
end

function Input:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 50)
    container.Parent = parent
    
    -- 标签
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- 输入框
    local textBox = Instance.new("TextBox")
    textBox.Name = "TextBox"
    textBox.BackgroundColor3 = CurrentTheme.Secondary
    textBox.BackgroundTransparency = 0
    textBox.Size = UDim2.new(1, 0, 0, 30)
    textBox.Position = UDim2.new(0, 0, 0, 20)
    textBox.Font = CONFIG.Font
    textBox.Text = self.Value
    textBox.PlaceholderText = self.Placeholder
    textBox.TextColor3 = CurrentTheme.Foreground
    textBox.PlaceholderColor3 = CurrentTheme.Disabled
    textBox.TextSize = CONFIG.TextSize
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    
    -- 添加内边距
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.Parent = textBox
    
    Utils:CreateCorner().Parent = textBox
    
    -- 焦点效果
    textBox.FocusLost:Connect(function(enterPressed)
        if self.Enabled then
            Utils:Tween(textBox, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
            
            local newValue = textBox.Text
            if self.Numeric then
                newValue = tonumber(newValue) or 0
            end
            
            if newValue ~= self.Value then
                self.Value = newValue
                self.Callback(self.Value, enterPressed)
            end
        end
    end)
    
    self.Instance = container
    self.Parent = parent
    self.Label = label
    self.TextBox = textBox
    
    return container
end

function Input:SetValue(value)
    self.Value = value
    if self.TextBox then
        self.TextBox.Text = tostring(value)
    end
end

function Input:GetValue()
    return self.Value
end

-- ==================== 键位绑定控件 ====================
local Keybind = setmetatable({}, {__index = Control})
Keybind.__index = Keybind

function Keybind.new(name, options)
    local self = setmetatable(Control.new(name, options), Keybind)
    self.Text = options.Text or "快捷键"
    self.Default = options.Default or Enum.KeyCode.F
    self.Mode = options.Mode or "Toggle" -- "Toggle" 或 "Hold"
    self.CurrentKey = self.Default
    self.Listening = false
    self.Callback = options.Callback or function() end
    
    return self
end

function Keybind:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 30)
    container.Parent = parent
    
    -- 标签
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- 键位显示
    local keyButton = Instance.new("TextButton")
    keyButton.Name = "KeyButton"
    keyButton.BackgroundColor3 = CurrentTheme.Secondary
    keyButton.Size = UDim2.new(0.4, 0, 1, 0)
    keyButton.Position = UDim2.new(0.6, 0, 0, 0)
    keyButton.Font = CONFIG.Font
    keyButton.Text = self.CurrentKey.Name
    keyButton.TextColor3 = CurrentTheme.Foreground
    keyButton.TextSize = CONFIG.TextSize
    keyButton.AutoButtonColor = false
    keyButton.Parent = container
    
    Utils:CreateCorner().Parent = keyButton
    
    -- 点击事件
    keyButton.MouseButton1Click:Connect(function()
        if not self.Enabled then return end
        self:StartListening()
    end)
    
    -- 悬停效果
    keyButton.MouseEnter:Connect(function()
        if self.Enabled then
            Utils:Tween(keyButton, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
        end
    end)
    
    keyButton.MouseLeave:Connect(function()
        if self.Enabled and not self.Listening then
            Utils:Tween(keyButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end
    end)
    
    self.Instance = container
    self.Parent = parent
    self.Label = label
    self.KeyButton = keyButton
    
    -- 设置全局监听
    self:SetupGlobalListener()
    
    return container
end

function Keybind:StartListening()
    if not self.Enabled then return end
    
    self.Listening = true
    self.KeyButton.Text = "..."
    self.KeyButton.BackgroundColor3 = CurrentTheme.Primary
end

function Keybind:StopListening()
    self.Listening = false
    self.KeyButton.Text = self.CurrentKey.Name
    Utils:Tween(self.KeyButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
end

function Keybind:SetKey(keyCode)
    self.CurrentKey = keyCode
    self.KeyButton.Text = keyCode.Name
    self.Callback(keyCode)
end

function Keybind:SetupGlobalListener()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
            self:SetKey(input.KeyCode)
            self:StopListening()
        elseif not self.Listening and input.KeyCode == self.CurrentKey then
            if self.Mode == "Toggle" then
                self.Callback(self.CurrentKey)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if self.Mode == "Hold" and not self.Listening and input.KeyCode == self.CurrentKey then
            self.Callback(self.CurrentKey, false)
        end
    end)
end

function Keybind:GetValue()
    return self.CurrentKey
end

-- ==================== 颜色选择器控件 ====================
local ColorPicker = setmetatable({}, {__index = Control})
ColorPicker.__index = ColorPicker

function ColorPicker.new(name, options)
    local self = setmetatable(Control.new(name, options), ColorPicker)
    self.Text = options.Text or "颜色选择"
    self.Default = options.Default or Color3.new(1, 1, 1)
    self.Value = self.Default
    self.Callback = options.Callback or function() end
    self.Open = false
    
    return self
end

function ColorPicker:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 30)
    container.ClipsDescendants = true
    container.Parent = parent
    
    -- 标签
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    -- 颜色预览按钮
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "ColorButton"
    colorButton.BackgroundColor3 = self.Value
    colorButton.Size = UDim2.new(0.4, 0, 1, 0)
    colorButton.Position = UDim2.new(0.6, 0, 0, 0)
    colorButton.Font = CONFIG.Font
    colorButton.Text = ""
    colorButton.AutoButtonColor = false
    colorButton.Parent = container
    
    Utils:CreateCorner().Parent = colorButton
    Utils:CreateStroke(1, CurrentTheme.Border).Parent = colorButton
    
    -- 颜色选择器容器
    local pickerContainer = Instance.new("Frame")
    pickerContainer.Name = "PickerContainer"
    pickerContainer.BackgroundColor3 = CurrentTheme.Active
    pickerContainer.Size = UDim2.new(1, 0, 0, 0)
    pickerContainer.Position = UDim2.new(0, 0, 0, 35)
    pickerContainer.ClipsDescendants = true
    pickerContainer.Visible = false
    pickerContainer.Parent = container
    
    Utils:CreateCorner().Parent = pickerContainer
    Utils:CreateStroke(1, CurrentTheme.Border).Parent = pickerContainer
    
    -- 点击事件
    colorButton.MouseButton1Click:Connect(function()
        if not self.Enabled then return end
        self:TogglePicker()
    end)
    
    self.Instance = container
    self.Parent = parent
    self.Label = label
    self.ColorButton = colorButton
    self.PickerContainer = pickerContainer
    
    -- 创建颜色选择器
    self:CreateColorPicker()
    
    return container
end

function ColorPicker:CreateColorPicker()
    -- 色相滑块
    local hueSlider = Instance.new("Frame")
    hueSlider.Name = "HueSlider"
    hueSlider.BackgroundColor3 = Color3.new(1, 1, 1)
    hueSlider.Size = UDim2.new(1, -20, 0, 20)
    hueSlider.Position = UDim2.new(0, 10, 0, 10)
    hueSlider.Parent = self.PickerContainer
    
    local hueGradient = Utils:CreateGradient({
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(255, 0, 0)
    })
    hueGradient.Parent = hueSlider
    
    -- 饱和度/亮度区域
    local svArea = Instance.new("Frame")
    svArea.Name = "SVArea"
    svArea.BackgroundColor3 = Color3.new(1, 1, 1)
    svArea.Size = UDim2.new(1, -20, 0, 100)
    svArea.Position = UDim2.new(0, 10, 0, 40)
    svArea.Parent = self.PickerContainer
    
    -- 颜色值输入
    local hexInput = Instance.new("TextBox")
    hexInput.Name = "HexInput"
    hexInput.BackgroundColor3 = CurrentTheme.Secondary
    hexInput.Size = UDim2.new(1, -20, 0, 25)
    hexInput.Position = UDim2.new(0, 10, 0, 150)
    hexInput.Font = CONFIG.Font
    hexInput.Text = Utils:RGBToHex(self.Value)
    hexInput.PlaceholderText = "#RRGGBB"
    hexInput.TextColor3 = CurrentTheme.Foreground
    hexInput.PlaceholderColor3 = CurrentTheme.Disabled
    hexInput.TextSize = CONFIG.TextSize
    hexInput.TextXAlignment = Enum.TextXAlignment.Center
    hexInput.ClearTextOnFocus = false
    hexInput.Parent = self.PickerContainer
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 5)
    padding.PaddingRight = UDim.new(0, 5)
    padding.Parent = hexInput
    
    Utils:CreateCorner(UDim.new(0, 4)).Parent = hexInput
    
    -- 焦点事件
    hexInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local hex = hexInput.Text
            if hex:match("^#?%x%x%x%x%x%x$") then
                hex = hex:gsub("#", "")
                local color = Utils:HexToRGB(hex)
                self:SetValue(color)
            end
        end
    end)
    
    -- 预设颜色
    local presetColors = {
        Color3.fromRGB(255, 0, 0),     -- 红
        Color3.fromRGB(0, 255, 0),     -- 绿
        Color3.fromRGB(0, 0, 255),     -- 蓝
        Color3.fromRGB(255, 255, 0),   -- 黄
        Color3.fromRGB(255, 0, 255),   -- 品红
        Color3.fromRGB(0, 255, 255),   -- 青
        Color3.fromRGB(255, 255, 255), -- 白
        Color3.fromRGB(0, 0, 0)        -- 黑
    }
    
    local presetContainer = Instance.new("Frame")
    presetContainer.Name = "PresetContainer"
    presetContainer.BackgroundTransparency = 1
    presetContainer.Size = UDim2.new(1, -20, 0, 30)
    presetContainer.Position = UDim2.new(0, 10, 0, 185)
    presetContainer.Parent = self.PickerContainer
    
    for i, color in ipairs(presetColors) do
        local presetButton = Instance.new("TextButton")
        presetButton.Name = "Preset_" .. i
        presetButton.BackgroundColor3 = color
        presetButton.Size = UDim2.new(0.1, -2, 1, 0)
        presetButton.Position = UDim2.new((i-1) * 0.1, 0, 0, 0)
        presetButton.Text = ""
        presetButton.AutoButtonColor = false
        presetButton.Parent = presetContainer
        
        Utils:CreateCorner(UDim.new(0, 4)).Parent = presetButton
        
        presetButton.MouseButton1Click:Connect(function()
            self:SetValue(color)
        end)
    end
end

function ColorPicker:TogglePicker()
    if self.Open then
        self:ClosePicker()
    else
        self:OpenPicker()
    end
end

function ColorPicker:OpenPicker()
    if not self.Enabled then return end
    
    self.Open = true
    self.PickerContainer.Visible = true
    Utils:Tween(self.PickerContainer, {Size = UDim2.new(1, 0, 0, 220)}, 0.2)
    Utils:Tween(self.Instance, {Size = UDim2.new(1, 0, 0, 250)}, 0.2)
end

function ColorPicker:ClosePicker()
    self.Open = false
    Utils:Tween(self.PickerContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
    Utils:Tween(self.Instance, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
    
    task.delay(0.2, function()
        if not self.Open then
            self.PickerContainer.Visible = false
        end
    end)
end

function ColorPicker:SetValue(color)
    self.Value = color
    self.ColorButton.BackgroundColor3 = color
    
    if self.PickerContainer:FindFirstChild("HexInput") then
        self.PickerContainer.HexInput.Text = Utils:RGBToHex(color)
    end
    
    self.Callback(color)
end

function ColorPicker:GetValue()
    return self.Value
end

-- ==================== 标签控件 ====================
local Label = setmetatable({}, {__index = Control})
Label.__index = Label

function Label.new(name, options)
    local self = setmetatable(Control.new(name, options), Label)
    self.Text = options.Text or "标签"
    self.Center = options.Center or false
    
    return self
end

function Label:Create(parent)
    local label = Instance.new("TextLabel")
    label.Name = self.Name
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = CONFIG.Font
    label.Text = self.Text
    label.TextColor3 = CurrentTheme.Foreground
    label.TextSize = CONFIG.TextSize
    label.TextXAlignment = self.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    label.Parent = parent
    
    self.Instance = label
    self.Parent = parent
    
    return label
end

function Label:SetText(text)
    self.Text = text
    if self.Instance then
        self.Instance.Text = text
    end
end

-- ==================== 分隔线控件 ====================
local Divider = setmetatable({}, {__index = Control})
Divider.__index = Divider

function Divider.new(name, options)
    local self = setmetatable(Control.new(name, options), Divider)
    self.Text = options.Text or ""
    
    return self
end

function Divider:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, 20)
    container.Parent = parent
    
    if self.Text and self.Text ~= "" then
        -- 带文本的分隔线
        local leftLine = Instance.new("Frame")
        leftLine.Name = "LeftLine"
        leftLine.BackgroundColor3 = CurrentTheme.Border
        leftLine.Size = UDim2.new(0.4, 0, 0, 1)
        leftLine.Position = UDim2.new(0, 0, 0.5, 0)
        leftLine.AnchorPoint = Vector2.new(0, 0.5)
        leftLine.Parent = container
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "Text"
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(0.2, 0, 1, 0)
        textLabel.Position = UDim2.new(0.4, 0, 0, 0)
        textLabel.Font = CONFIG.Font
        textLabel.Text = self.Text
        textLabel.TextColor3 = CurrentTheme.Secondary
        textLabel.TextSize = 12
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.Parent = container
        
        local rightLine = Instance.new("Frame")
        rightLine.Name = "RightLine"
        rightLine.BackgroundColor3 = CurrentTheme.Border
        rightLine.Size = UDim2.new(0.4, 0, 0, 1)
        rightLine.Position = UDim2.new(0.6, 0, 0.5, 0)
        rightLine.AnchorPoint = Vector2.new(0, 0.5)
        rightLine.Parent = container
    else
        -- 简单的分隔线
        local line = Instance.new("Frame")
        line.Name = "Line"
        line.BackgroundColor3 = CurrentTheme.Border
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0.5, 0)
        line.AnchorPoint = Vector2.new(0, 0.5)
        line.Parent = container
    end
    
    self.Instance = container
    self.Parent = parent
    
    return container
end

-- ==================== 组框控件 ====================
local Groupbox = {}
Groupbox.__index = Groupbox

function Groupbox.new(name, options)
    local self = setmetatable({}, Groupbox)
    self.Name = name
    self.Text = options.Text or "组框"
    self.Parent = nil
    self.Instance = nil
    self.Controls = {}
    self.LayoutOrder = 0
    
    return self
end

function Groupbox:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundColor3 = CurrentTheme.Active
    container.BackgroundTransparency = 0.1
    container.Size = UDim2.new(1, 0, 0, 100)
    container.Parent = parent
    
    Utils:CreateCorner().Parent = container
    Utils:CreateStroke(1, CurrentTheme.Border).Parent = container
    
    -- 标题
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundColor3 = CurrentTheme.Active
    title.BackgroundTransparency = 0.1
    title.Size = UDim2.new(1, 0, 0, 25)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Font = CONFIG.Font
    title.Text = self.Text
    title.TextColor3 = CurrentTheme.Foreground
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.Parent = title
    
    -- 内容区域
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, -20, 1, -35)
    content.Position = UDim2.new(0, 10, 0, 30)
    content.Parent = container
    
    -- 内容布局
    local layout = Instance.new("UIListLayout")
    layout.Name = "Layout"
    layout.Padding = UDim.new(0, CONFIG.ElementPadding)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        container.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 40)
    end)
    
    self.Instance = container
    self.Parent = parent
    self.Content = content
    self.Layout = layout
    
    return container
end

-- 添加控件的方法
function Groupbox:AddButton(options)
    local button = Button.new("Button_" .. #self.Controls + 1, options)
    button:Create(self.Content)
    button.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, button)
    return button
end

function Groupbox:AddToggle(options)
    local toggle = Toggle.new("Toggle_" .. #self.Controls + 1, options)
    toggle:Create(self.Content)
    toggle.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, toggle)
    return toggle
end

function Groupbox:AddSlider(options)
    local slider = Slider.new("Slider_" .. #self.Controls + 1, options)
    slider:Create(self.Content)
    slider.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, slider)
    return slider
end

function Groupbox:AddDropdown(options)
    local dropdown = Dropdown.new("Dropdown_" .. #self.Controls + 1, options)
    dropdown:Create(self.Content)
    dropdown.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, dropdown)
    return dropdown
end

function Groupbox:AddInput(options)
    local input = Input.new("Input_" .. #self.Controls + 1, options)
    input:Create(self.Content)
    input.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, input)
    return input
end

function Groupbox:AddKeybind(options)
    local keybind = Keybind.new("Keybind_" .. #self.Controls + 1, options)
    keybind:Create(self.Content)
    keybind.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, keybind)
    return keybind
end

function Groupbox:AddColorPicker(options)
    local colorpicker = ColorPicker.new("ColorPicker_" .. #self.Controls + 1, options)
    colorpicker:Create(self.Content)
    colorpicker.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, colorpicker)
    return colorpicker
end

function Groupbox:AddLabel(options)
    local label = Label.new("Label_" .. #self.Controls + 1, options)
    label:Create(self.Content)
    label.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, label)
    return label
end

function Groupbox:AddDivider(options)
    local divider = Divider.new("Divider_" .. #self.Controls + 1, options)
    divider:Create(self.Content)
    divider.Instance.LayoutOrder = #self.Controls + 1
    table.insert(self.Controls, divider)
    return divider
end

-- ==================== 标签页控件 ====================
local Tab = {}
Tab.__index = Tab

function Tab.new(name, options)
    local self = setmetatable({}, Tab)
    self.Name = name
    self.Text = options.Text or "标签页"
    self.Icon = options.Icon or ""
    self.Parent = nil
    self.Instance = nil
    self.Groupboxes = {}
    self.LeftGroupboxes = {}
    self.RightGroupboxes = {}
    
    return self
end

function Tab:Create(parent)
    local container = Instance.new("Frame")
    container.Name = self.Name
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, 0)
    container.Visible = false
    container.Parent = parent
    
    -- 左侧组框容器
    local leftContainer = Instance.new("Frame")
    leftContainer.Name = "LeftContainer"
    leftContainer.BackgroundTransparency = 1
    leftContainer.Size = UDim2.new(0.5, -CONFIG.GroupboxPadding/2, 1, 0)
    leftContainer.Position = UDim2.new(0, 0, 0, 0)
    leftContainer.Parent = container
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Name = "LeftLayout"
    leftLayout.Padding = UDim.new(0, CONFIG.GroupboxPadding)
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftContainer
    
    leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        leftContainer.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y)
    end)
    
    -- 右侧组框容器
    local rightContainer = Instance.new("ScrollingFrame")
    rightContainer.Name = "RightContainer"
    rightContainer.BackgroundTransparency = 1
    rightContainer.Size = UDim2.new(0.5, -CONFIG.GroupboxPadding/2, 1, 0)
    rightContainer.Position = UDim2.new(0.5, CONFIG.GroupboxPadding/2, 0, 0)
    rightContainer.ScrollBarThickness = 6
    rightContainer.ScrollBarImageColor3 = CurrentTheme.Secondary
    rightContainer.Parent = container
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Name = "RightLayout"
    rightLayout.Padding = UDim.new(0, CONFIG.GroupboxPadding)
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightContainer
    
    rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rightContainer.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y)
    end)
    
    self.Instance = container
    self.Parent = parent
    self.LeftContainer = leftContainer
    self.RightContainer = rightContainer
    
    return container
end

function Tab:AddLeftGroupbox(text)
    local groupbox = Groupbox.new("LeftGroupbox_" .. #self.LeftGroupboxes + 1, {Text = text})
    groupbox:Create(self.LeftContainer)
    groupbox.Instance.LayoutOrder = #self.LeftGroupboxes + 1
    table.insert(self.LeftGroupboxes, groupbox)
    table.insert(self.Groupboxes, groupbox)
    return groupbox
end

function Tab:AddRightGroupbox(text)
    local groupbox = Groupbox.new("RightGroupbox_" .. #self.RightGroupboxes + 1, {Text = text})
    groupbox:Create(self.RightContainer)
    groupbox.Instance.LayoutOrder = #self.RightGroupboxes + 1
    table.insert(self.RightGroupboxes, groupbox)
    table.insert(self.Groupboxes, groupbox)
    return groupbox
end

-- ==================== 窗口类 ====================
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Title = options.Title or "AdvancedUI"
    self.Footer = options.Footer or "v2.0.0"
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    self.Center = options.Center or false
    self.AutoShow = options.AutoShow or false
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.Resizable = options.Resizable or true
    self.ShowCustomCursor = options.ShowCustomCursor or true
    self.CornerRadius = UDim.new(0, options.CornerRadius or 8)
    
    self.Instance = nil
    self.Tabs = {}
    self.TabButtons = {}
    self.CurrentTab = nil
    self.Dragging = false
    self.DragStart = nil
    self.DragStartPosition = nil
    self.Resizing = false
    self.ResizeStart = nil
    self.ResizeStartSize = nil
    self.Visible = false
    
    return self
end

function Window:Create()
    -- 创建主ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedUI_" .. self.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    
    -- 主窗口容器
    local mainWindow = Instance.new("Frame")
    mainWindow.Name = "MainWindow"
    mainWindow.BackgroundColor3 = CurrentTheme.Background
    mainWindow.BackgroundTransparency = 0.1
    mainWindow.Size = self.Size
    mainWindow.Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2)
    mainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    mainWindow.BorderSizePixel = 0
    mainWindow.Visible = self.AutoShow
    mainWindow.Parent = screenGui
    
    -- 窗口阴影
    local shadow = Utils:CreateShadow()
    if shadow then
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.Parent = mainWindow
    end
    
    -- 圆角
    Utils:CreateCorner(self.CornerRadius).Parent = mainWindow
    
    -- 描边
    Utils:CreateStroke(2, CurrentTheme.Border).Parent = mainWindow
    
    -- 标题栏
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = CurrentTheme.Active
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainWindow
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(self.CornerRadius.Scale, self.CornerRadius.Offset)
    titleBarCorner.Parent = titleBar
    
    -- 标题文本
    local titleText = Instance.new("TextLabel")
    titleText.Name = "TitleText"
    titleText.BackgroundTransparency = 1
    titleText.Size = UDim2.new(1, -100, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.Font = CONFIG.Font
    titleText.Text = self.Title
    titleText.TextColor3 = CurrentTheme.Foreground
    titleText.TextSize = 18
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.TextTruncate = Enum.TextTruncate.AtEnd
    titleText.Parent = titleBar
    
    -- 关闭按钮
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundTransparency = 1
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -35, 0.5, -15)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.Image = "rbxassetid://3926305904"
    closeButton.ImageRectOffset = Vector2.new(284, 4)
    closeButton.ImageRectSize = Vector2.new(24, 24)
    closeButton.ImageColor3 = CurrentTheme.Secondary
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        self:Hide()
    end)
    
    closeButton.MouseEnter:Connect(function()
        Utils:Tween(closeButton, {ImageColor3 = CurrentTheme.Error}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Utils:Tween(closeButton, {ImageColor3 = CurrentTheme.Secondary}, 0.2)
    end)
    
    -- 最小化按钮
    local minimizeButton = Instance.new("ImageButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -70, 0.5, -15)
    minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
    minimizeButton.Image = "rbxassetid://3926305904"
    minimizeButton.ImageRectOffset = Vector2.new(844, 124)
    minimizeButton.ImageRectSize = Vector2.new(36, 36)
    minimizeButton.ImageColor3 = CurrentTheme.Secondary
    minimizeButton.Parent = titleBar
    
    minimizeButton.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    minimizeButton.MouseEnter:Connect(function()
        Utils:Tween(minimizeButton, {ImageColor3 = CurrentTheme.Warning}, 0.2)
    end)
    
    minimizeButton.MouseLeave:Connect(function()
        Utils:Tween(minimizeButton, {ImageColor3 = CurrentTheme.Secondary}, 0.2)
    end)
    
    -- 标签按钮容器
    local tabButtonsContainer = Instance.new("Frame")
    tabButtonsContainer.Name = "TabButtons"
    tabButtonsContainer.BackgroundTransparency = 1
    tabButtonsContainer.Size = UDim2.new(1, 0, 0, 40)
    tabButtonsContainer.Position = UDim2.new(0, 0, 0, 40)
    tabButtonsContainer.Parent = mainWindow
    
    local tabButtonsList = Instance.new("UIListLayout")
    tabButtonsList.Name = "TabButtonsList"
    tabButtonsList.FillDirection = Enum.FillDirection.Horizontal
    tabButtonsList.Padding = UDim.new(0, 5)
    tabButtonsList.SortOrder = Enum.SortOrder.LayoutOrder
    tabButtonsList.Parent = tabButtonsContainer
    
    -- 标签页容器
    local tabContainer = Instance.new("Frame")
    tabContainer.Name = "TabContainer"
    tabContainer.BackgroundTransparency = 1
    tabContainer.Size = UDim2.new(1, -20, 1, -100)
    tabContainer.Position = UDim2.new(0, 10, 0, 90)
    tabContainer.Parent = mainWindow
    
    -- 页脚
    local footer = Instance.new("TextLabel")
    footer.Name = "Footer"
    footer.BackgroundTransparency = 1
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.Font = CONFIG.Font
    footer.Text = self.Footer
    footer.TextColor3 = CurrentTheme.Secondary
    footer.TextSize = 12
    footer.TextXAlignment = Enum.TextXAlignment.Center
    footer.Parent = mainWindow
    
    -- 设置拖动功能
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.DragStartPosition = mainWindow.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if self.Dragging then
                local delta = input.Position - self.DragStart
                mainWindow.Position = UDim2.new(
                    self.DragStartPosition.X.Scale,
                    self.DragStartPosition.X.Offset + delta.X,
                    self.DragStartPosition.Y.Scale,
                    self.DragStartPosition.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    -- 设置调整大小功能
    if self.Resizable then
        local resizeHandle = Instance.new("Frame")
        resizeHandle.Name = "ResizeHandle"
        resizeHandle.BackgroundTransparency = 1
        resizeHandle.Size = UDim2.new(0, 20, 0, 20)
        resizeHandle.Position = UDim2.new(1, -20, 1, -20)
        resizeHandle.ZIndex = 2
        resizeHandle.Parent = mainWindow
        
        local resizeIcon = Instance.new("ImageLabel")
        resizeIcon.Name = "ResizeIcon"
        resizeIcon.BackgroundTransparency = 1
        resizeIcon.Size = UDim2.new(1, 0, 1, 0)
        resizeIcon.Image = "rbxassetid://3926305904"
        resizeIcon.ImageRectOffset = Vector2.new(964, 324)
        resizeIcon.ImageRectSize = Vector2.new(36, 36)
        resizeIcon.ImageColor3 = CurrentTheme.Secondary
        resizeIcon.Parent = resizeHandle
        
        resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Resizing = true
                self.ResizeStart = input.Position
                self.ResizeStartSize = mainWindow.Size
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and self.Resizing then
                local delta = input.Position - self.ResizeStart
                local newSize = UDim2.new(
                    self.ResizeStartSize.X.Scale,
                    math.clamp(
                        self.ResizeStartSize.X.Offset + delta.X,
                        CONFIG.WindowMinSize.X.Offset,
                        CONFIG.WindowMaxSize.X.Offset
                    ),
                    self.ResizeStartSize.Y.Scale,
                    math.clamp(
                        self.ResizeStartSize.Y.Offset + delta.Y,
                        CONFIG.WindowMinSize.Y.Offset,
                        CONFIG.WindowMaxSize.Y.Offset
                    )
                )
                mainWindow.Size = newSize
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Resizing = false
            end
        end)
    end
    
    self.Instance = screenGui
    self.MainWindow = mainWindow
    self.TitleBar = titleBar
    self.TabContainer = tabContainer
    self.TabButtonsContainer = tabButtonsContainer
    
    -- 设置快捷键
    if self.ToggleKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == self.ToggleKey then
                self:Toggle()
            end
        end)
    end
    
    return screenGui
end

function Window:AddTab(name, icon)
    local tab = Tab.new(name, {Text = name, Icon = icon})
    tab:Create(self.TabContainer)
    
    -- 创建标签按钮
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton_" .. name
    tabButton.BackgroundColor3 = CurrentTheme.Secondary
    tabButton.Size = UDim2.new(0, 100, 0, 30)
    tabButton.LayoutOrder = #self.TabButtons + 1
    tabButton.Font = CONFIG.Font
    tabButton.Text = name
    tabButton.TextColor3 = CurrentTheme.Foreground
    tabButton.TextSize = 14
    tabButton.AutoButtonColor = false
    tabButton.Parent = self.TabButtonsContainer
    
    Utils:CreateCorner(UDim.new(0, 4)).Parent = tabButton
    
    -- 点击事件
    tabButton.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    
    -- 悬停效果
    tabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            Utils:Tween(tabButton, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            Utils:Tween(tabButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end
    end)
    
    table.insert(self.Tabs, tab)
    table.insert(self.TabButtons, {Tab = tab, Button = tabButton})
    
    -- 如果是第一个标签，设置为当前标签
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end
    
    return tab
end

function Window:SwitchTab(tab)
    -- 隐藏所有标签页
    for _, t in ipairs(self.Tabs) do
        t.Instance.Visible = false
    end
    
    -- 重置所有标签按钮颜色
    for _, tb in ipairs(self.TabButtons) do
        Utils:Tween(tb.Button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
    end
    
    -- 显示选中的标签页
    tab.Instance.Visible = true
    self.CurrentTab = tab
    
    -- 高亮选中的标签按钮
    for _, tb in ipairs(self.TabButtons) do
        if tb.Tab == tab then
            Utils:Tween(tb.Button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            break
        end
    end
end

function Window:Show()
    self.Visible = true
    self.MainWindow.Visible = true
    
    if self.Center then
        self.MainWindow.Position = UDim2.new(0.5, -self.MainWindow.Size.X.Offset/2, 0.5, -self.MainWindow.Size.Y.Offset/2)
    end
end

function Window:Hide()
    self.Visible = false
    self.MainWindow.Visible = false
end

function Window:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Window:Minimize()
    if self.MainWindow.Size.Y.Offset > 80 then
        self.SavedSize = self.MainWindow.Size
        Utils:Tween(self.MainWindow, {Size = UDim2.new(self.MainWindow.Size.X.Scale, self.MainWindow.Size.X.Offset, 0, 80)}, 0.2)
    else
        Utils:Tween(self.MainWindow, {Size = self.SavedSize or self.Size}, 0.2)
    end
end

-- ==================== 主库函数 ====================
function AdvancedUI:CreateWindow(options)
    local window = Window.new(options)
    window:Create()
    
    -- 创建通知管理器
    local notificationManager = NotificationManager.new()
    notificationManager:SetParent(window.MainWindow)
    
    window.NotificationManager = notificationManager
    
    -- 添加通知方法
    window.Notify = function(notificationOptions)
        notificationManager:ShowNotification(notificationOptions)
    end
    
    return window
end

function AdvancedUI:SetTheme(themeName)
    if THEMES[themeName] then
        CurrentTheme = THEMES[themeName]
        return true
    end
    return false
end

function AdvancedUI:GetCurrentTheme()
    return CurrentTheme
end

function AdvancedUI:CreateCustomTheme(themeData)
    local themeName = "Custom_" .. Utils:GenerateID()
    THEMES[themeName] = themeData
    return themeName
end

function AdvancedUI:Notify(options)
    -- 全局通知函数（需要先创建一个窗口）
    warn("Please create a window first to use notifications")
end

-- 返回库对象
return AdvancedUI
