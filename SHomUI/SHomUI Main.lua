--[[
    AdvancedUI v2.0.1 - 修复版
    一个功能完整的 Roblox 高级 UI 库
    设计灵感来自 Obsidian UI，但完全重写并增强
    作者: AI Assistant
    修复版本: 2024
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

-- 安全的本地玩家获取函数
local function GetLocalPlayer()
    local success, result = pcall(function()
        return Players.LocalPlayer
    end)
    return success and result or nil
end

-- 安全的鼠标获取函数
local function GetMouse()
    local player = GetLocalPlayer()
    if player then
        local success, result = pcall(function()
            return player:GetMouse()
        end)
        return success and result or nil
    end
    return nil
end

-- 等待游戏加载
local function WaitForGameLoad()
    if not game:IsLoaded() then
        local loaded = Instance.new("BindableEvent")
        game.Loaded:Connect(function()
            loaded:Fire()
        end)
        loaded.Event:Wait()
    end
end

-- 等待本地玩家加载
local function WaitForLocalPlayer()
    local player = GetLocalPlayer()
    while not player do
        task.wait(0.5)
        player = GetLocalPlayer()
    end
    return player
end

-- 初始化本地玩家和鼠标
local LocalPlayer = WaitForLocalPlayer()
local Mouse = GetMouse()

-- ==================== 配置常量 ====================
local CONFIG = {
    Version = "2.0.1",
    DefaultTheme = "Dark",
    AnimationSpeed = 0.2,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
    WindowMinSize = UDim2.new(0, 300, 0, 200),
    WindowMaxSize = UDim2.new(0, 800, 0, 600),
    ElementPadding = 5,
    GroupboxPadding = 10,
    Font = Enum.Font.Gotham,  -- 使用更可靠的字体
    TextSize = 14,
    CornerRadius = UDim.new(0, 6),
    ShadowEnabled = true,
    SaveConfig = false,  -- 暂时禁用配置保存
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
    }
}

-- 当前主题
local CurrentTheme = THEMES[CONFIG.DefaultTheme]

-- ==================== 工具函数 ====================
local Utils = {}

-- 安全执行函数
function Utils:TrySafe(func, errorMessage)
    local success, result = pcall(func)
    if not success then
        warn("[AdvancedUI Error] " .. (errorMessage or "Unknown error") .. ": " .. tostring(result))
        return nil
    end
    return result
end

-- 创建圆角
function Utils:CreateCorner(radius)
    return Utils:TrySafe(function()
        local corner = Instance.new("UICorner")
        corner.CornerRadius = radius or CONFIG.CornerRadius
        return corner
    end, "Failed to create corner")
end

-- 创建描边
function Utils:CreateStroke(thickness, color)
    return Utils:TrySafe(function()
        local stroke = Instance.new("UIStroke")
        stroke.Thickness = thickness or 1
        stroke.Color = color or CurrentTheme.Border
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return stroke
    end, "Failed to create stroke")
end

-- 动画函数
function Utils:Tween(object, properties, duration, easingStyle, easingDirection)
    return Utils:TrySafe(function()
        local tweenInfo = TweenInfo.new(
            duration or CONFIG.AnimationSpeed,
            easingStyle or CONFIG.EasingStyle,
            easingDirection or CONFIG.EasingDirection
        )
        
        local tween = TweenService:Create(object, tweenInfo, properties)
        tween:Play()
        return tween
    end, "Failed to create tween")
end

-- 生成唯一ID
function Utils:GenerateID()
    return Utils:TrySafe(function()
        return HttpService:GenerateGUID(false)
    end, "Failed to generate ID") or tostring(tick())
end

-- 颜色转换
function Utils:RGBToHex(color)
    return Utils:TrySafe(function()
        return string.format("#%02X%02X%02X", 
            math.floor(color.R * 255),
            math.floor(color.G * 255),
            math.floor(color.B * 255)
        )
    end, "Failed to convert RGB to hex") or "#FFFFFF"
end

function Utils:HexToRGB(hex)
    return Utils:TrySafe(function()
        hex = hex:gsub("#", "")
        return Color3.fromRGB(
            tonumber(hex:sub(1, 2), 16),
            tonumber(hex:sub(3, 4), 16),
            tonumber(hex:sub(5, 6), 16)
        )
    end, "Failed to convert hex to RGB") or Color3.new(1, 1, 1)
end

-- 安全设置父级
function Utils:SetParentSafe(child, parent)
    return Utils:TrySafe(function()
        if child and parent then
            child.Parent = parent
            return true
        end
        return false
    end, "Failed to set parent")
end

-- 安全创建实例
function Utils:CreateInstance(className, properties)
    return Utils:TrySafe(function()
        local instance = Instance.new(className)
        if properties then
            for key, value in pairs(properties) do
                instance[key] = value
            end
        end
        return instance
    end, "Failed to create instance: " .. className)
end

-- ==================== 窗口类 (重写) ====================
local Window = {}
Window.__index = Window

function Window.new(options)
    local self = setmetatable({}, Window)
    self.Title = options.Title or "AdvancedUI"
    self.Footer = options.Footer or "v2.0.1"
    self.ToggleKey = options.ToggleKey or Enum.KeyCode.RightControl
    self.Center = options.Center or false
    self.AutoShow = options.AutoShow or false
    self.Size = options.Size or UDim2.new(0, 500, 0, 400)
    self.Resizable = options.Resizable or false
    self.ShowCustomCursor = options.ShowCustomCursor or false
    self.CornerRadius = UDim.new(0, options.CornerRadius or 8)
    
    self.Instance = nil
    self.ScreenGui = nil
    self.MainWindow = nil
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
    self.Initialized = false
    
    return self
end

-- 安全的GUI父级查找
function Window:FindSafeParent()
    local possibleParents = {
        function() return game:GetService("CoreGui") end,
        function() 
            local player = WaitForLocalPlayer()
            if player then
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    return playerGui
                end
            end
            return nil
        end,
        function() return game:GetService("StarterGui") end
    }
    
    for _, parentFunc in ipairs(possibleParents) do
        local success, parent = pcall(parentFunc)
        if success and parent then
            return parent
        end
    end
    
    return nil
end

-- 创建窗口
function Window:Create()
    if self.Initialized then
        warn("Window already initialized")
        return
    end
    
    -- 等待游戏加载
    WaitForGameLoad()
    
    -- 等待本地玩家
    local player = WaitForLocalPlayer()
    if not player then
        warn("Failed to get local player")
        return
    end
    
    -- 等待PlayerGui
    local maxWaitTime = 5
    local startTime = tick()
    while not player:FindFirstChild("PlayerGui") and tick() - startTime < maxWaitTime do
        task.wait(0.1)
    end
    
    -- 创建ScreenGui
    self.ScreenGui = Utils:CreateInstance("ScreenGui", {
        Name = "AdvancedUI_" .. self.Title:gsub("%s+", "_"),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    if not self.ScreenGui then
        warn("Failed to create ScreenGui")
        return
    end
    
    -- 寻找安全的父级
    local parent = self:FindSafeParent()
    if not parent then
        warn("No safe parent found for ScreenGui")
        self.ScreenGui:Destroy()
        return
    end
    
    -- 设置父级
    Utils:SetParentSafe(self.ScreenGui, parent)
    
    -- 创建主窗口
    self.MainWindow = Utils:CreateInstance("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = CurrentTheme.Background,
        BackgroundTransparency = 0.1,
        Size = self.Size,
        Position = UDim2.new(0.5, -self.Size.X.Offset/2, 0.5, -self.Size.Y.Offset/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        Visible = self.AutoShow
    })
    
    if not self.MainWindow then
        warn("Failed to create MainWindow")
        return
    end
    
    Utils:SetParentSafe(self.MainWindow, self.ScreenGui)
    
    -- 圆角
    local corner = Utils:CreateCorner(self.CornerRadius)
    if corner then
        corner.Parent = self.MainWindow
    end
    
    -- 描边
    local stroke = Utils:CreateStroke(2, CurrentTheme.Border)
    if stroke then
        stroke.Parent = self.MainWindow
    end
    
    -- 标题栏
    local titleBar = Utils:CreateInstance("Frame", {
        Name = "TitleBar",
        BackgroundColor3 = CurrentTheme.Active,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    
    if titleBar then
        Utils:SetParentSafe(titleBar, self.MainWindow)
        local titleBarCorner = Utils:CreateCorner(self.CornerRadius)
        if titleBarCorner then
            titleBarCorner.Parent = titleBar
        end
    end
    
    -- 标题文本
    local titleText = Utils:CreateInstance("TextLabel", {
        Name = "TitleText",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        Font = CONFIG.Font,
        Text = self.Title,
        TextColor3 = CurrentTheme.Foreground,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
    
    if titleText then
        Utils:SetParentSafe(titleText, titleBar)
    end
    
    -- 关闭按钮
    local closeButton = Utils:CreateInstance("TextButton", {
        Name = "CloseButton",
        BackgroundColor3 = CurrentTheme.Secondary,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0.5, -15),
        AnchorPoint = Vector2.new(1, 0.5),
        Font = CONFIG.Font,
        Text = "X",
        TextColor3 = CurrentTheme.Foreground,
        TextSize = 16,
        AutoButtonColor = false
    })
    
    if closeButton then
        Utils:SetParentSafe(closeButton, titleBar)
        local closeCorner = Utils:CreateCorner(UDim.new(0, 6))
        if closeCorner then
            closeCorner.Parent = closeButton
        end
        
        -- 点击事件
        closeButton.MouseButton1Click:Connect(function()
            self:Hide()
        end)
        
        -- 悬停效果
        closeButton.MouseEnter:Connect(function()
            Utils:Tween(closeButton, {BackgroundColor3 = CurrentTheme.Error}, 0.2)
        end)
        
        closeButton.MouseLeave:Connect(function()
            Utils:Tween(closeButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end)
    end
    
    -- 最小化按钮
    local minimizeButton = Utils:CreateInstance("TextButton", {
        Name = "MinimizeButton",
        BackgroundColor3 = CurrentTheme.Secondary,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -70, 0.5, -15),
        AnchorPoint = Vector2.new(1, 0.5),
        Font = CONFIG.Font,
        Text = "_",
        TextColor3 = CurrentTheme.Foreground,
        TextSize = 16,
        AutoButtonColor = false
    })
    
    if minimizeButton then
        Utils:SetParentSafe(minimizeButton, titleBar)
        local minimizeCorner = Utils:CreateCorner(UDim.new(0, 6))
        if minimizeCorner then
            minimizeCorner.Parent = minimizeButton
        end
        
        minimizeButton.MouseButton1Click:Connect(function()
            self:Minimize()
        end)
        
        minimizeButton.MouseEnter:Connect(function()
            Utils:Tween(minimizeButton, {BackgroundColor3 = CurrentTheme.Warning}, 0.2)
        end)
        
        minimizeButton.MouseLeave:Connect(function()
            Utils:Tween(minimizeButton, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
        end)
    end
    
    -- 标签按钮容器
    local tabButtonsContainer = Utils:CreateInstance("Frame", {
        Name = "TabButtons",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 40)
    })
    
    if tabButtonsContainer then
        Utils:SetParentSafe(tabButtonsContainer, self.MainWindow)
    end
    
    local tabButtonsList = Utils:CreateInstance("UIListLayout", {
        Name = "TabButtonsList",
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    if tabButtonsList then
        Utils:SetParentSafe(tabButtonsList, tabButtonsContainer)
    end
    
    -- 标签页容器
    local tabContainer = Utils:CreateInstance("Frame", {
        Name = "TabContainer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -100),
        Position = UDim2.new(0, 10, 0, 90)
    })
    
    if tabContainer then
        Utils:SetParentSafe(tabContainer, self.MainWindow)
    end
    
    -- 页脚
    local footer = Utils:CreateInstance("TextLabel", {
        Name = "Footer",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        Font = CONFIG.Font,
        Text = self.Footer,
        TextColor3 = CurrentTheme.Secondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Center
    })
    
    if footer then
        Utils:SetParentSafe(footer, self.MainWindow)
    end
    
    -- 设置拖动功能
    if titleBar then
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = true
                self.DragStart = input.Position
                self.DragStartPosition = self.MainWindow.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and self.Dragging then
                local delta = input.Position - self.DragStart
                self.MainWindow.Position = UDim2.new(
                    self.DragStartPosition.X.Scale,
                    self.DragStartPosition.X.Offset + delta.X,
                    self.DragStartPosition.Y.Scale,
                    self.DragStartPosition.Y.Offset + delta.Y
                )
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = false
            end
        end)
    end
    
    -- 设置调整大小功能
    if self.Resizable then
        local resizeHandle = Utils:CreateInstance("Frame", {
            Name = "ResizeHandle",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -20, 1, -20),
            ZIndex = 2
        })
        
        if resizeHandle then
            Utils:SetParentSafe(resizeHandle, self.MainWindow)
            
            resizeHandle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    self.Resizing = true
                    self.ResizeStart = input.Position
                    self.ResizeStartSize = self.MainWindow.Size
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
                    self.MainWindow.Size = newSize
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    self.Resizing = false
                end
            end)
        end
    end
    
    -- 设置快捷键
    if self.ToggleKey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == self.ToggleKey then
                self:Toggle()
            end
        end)
    end
    
    self.Initialized = true
    return self.ScreenGui
end

-- 简化版添加标签
function Window:AddTab(name)
    if not self.Initialized then
        warn("Window not initialized")
        return nil
    end
    
    local tabContainer = self.MainWindow:FindFirstChild("TabContainer")
    if not tabContainer then
        warn("Tab container not found")
        return nil
    end
    
    local tab = Utils:CreateInstance("Frame", {
        Name = name,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Visible = #self.Tabs == 0
    })
    
    if not tab then
        warn("Failed to create tab")
        return nil
    end
    
    Utils:SetParentSafe(tab, tabContainer)
    
    local tabButtonContainer = self.MainWindow:FindFirstChild("TabButtons")
    if tabButtonContainer then
        local tabButton = Utils:CreateInstance("TextButton", {
            Name = "TabButton_" .. name,
            BackgroundColor3 = #self.Tabs == 0 and CurrentTheme.Primary or CurrentTheme.Secondary,
            Size = UDim2.new(0, 100, 0, 30),
            LayoutOrder = #self.Tabs + 1,
            Font = CONFIG.Font,
            Text = name,
            TextColor3 = CurrentTheme.Foreground,
            TextSize = 14,
            AutoButtonColor = false
        })
        
        if tabButton then
            Utils:SetParentSafe(tabButton, tabButtonContainer)
            local buttonCorner = Utils:CreateCorner(UDim.new(0, 4))
            if buttonCorner then
                buttonCorner.Parent = tabButton
            end
            
            tabButton.MouseButton1Click:Connect(function()
                self:SwitchTab(tab)
            end)
            
            table.insert(self.TabButtons, {Tab = tab, Button = tabButton})
        end
    end
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        self.CurrentTab = tab
    end
    
    return {
        Instance = tab,
        AddLeftGroupbox = function(text)
            return self:AddGroupbox(tab, text, "left")
        end,
        AddRightGroupbox = function(text)
            return self:AddGroupbox(tab, text, "right")
        end
    }
end

-- 添加组框
function Window:AddGroupbox(tab, text, side)
    if not tab or not text then
        warn("Invalid tab or text")
        return nil
    end
    
    local container = Utils:CreateInstance("Frame", {
        Name = "Groupbox_" .. text,
        BackgroundColor3 = CurrentTheme.Active,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(0.5, -5, 0, 100),
        Position = side == "left" and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, 5, 0, 0)
    })
    
    if not container then
        warn("Failed to create groupbox")
        return nil
    end
    
    Utils:SetParentSafe(container, tab)
    
    local corner = Utils:CreateCorner()
    if corner then
        corner.Parent = container
    end
    
    local stroke = Utils:CreateStroke(1, CurrentTheme.Border)
    if stroke then
        stroke.Parent = container
    end
    
    local title = Utils:CreateInstance("TextLabel", {
        Name = "Title",
        BackgroundColor3 = CurrentTheme.Active,
        BackgroundTransparency = 0.1,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        Font = CONFIG.Font,
        Text = text,
        TextColor3 = CurrentTheme.Foreground,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    if title then
        Utils:SetParentSafe(title, container)
        local padding = Utils:CreateInstance("UIPadding", {
            PaddingLeft = UDim.new(0, 10)
        })
        if padding then
            padding.Parent = title
        end
    end
    
    local content = Utils:CreateInstance("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -35),
        Position = UDim2.new(0, 10, 0, 30)
    })
    
    if content then
        Utils:SetParentSafe(content, container)
        
        local layout = Utils:CreateInstance("UIListLayout", {
            Padding = UDim.new(0, CONFIG.ElementPadding),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        
        if layout then
            layout.Parent = content
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, layout.AbsoluteContentSize.Y + 40)
            end)
        end
    end
    
    return {
        Instance = container,
        AddButton = function(options)
            return self:AddButton(content, options)
        end,
        AddToggle = function(options)
            return self:AddToggle(content, options)
        end,
        AddSlider = function(options)
            return self:AddSlider(content, options)
        end,
        AddLabel = function(options)
            return self:AddLabel(content, options)
        end,
        AddDivider = function(options)
            return self:AddDivider(content, options)
        end
    }
end

-- 添加按钮
function Window:AddButton(parent, options)
    if not parent then
        warn("Invalid parent for button")
        return nil
    end
    
    local button = Utils:CreateInstance("TextButton", {
        Name = "Button_" .. (options.Text or "Button"),
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(1, 0, 0, 30),
        Font = CONFIG.Font,
        Text = options.Text or "按钮",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = CONFIG.TextSize,
        AutoButtonColor = false
    })
    
    if not button then
        warn("Failed to create button")
        return nil
    end
    
    Utils:SetParentSafe(button, parent)
    
    local corner = Utils:CreateCorner()
    if corner then
        corner.Parent = button
    end
    
    if options.Callback then
        button.MouseButton1Click:Connect(function()
            Utils:TrySafe(options.Callback, "Button callback failed")
        end)
    end
    
    -- 悬停效果
    button.MouseEnter:Connect(function()
        Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Hover}, 0.2)
    end)
    
    button.MouseLeave:Connect(function()
        Utils:Tween(button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
    end)
    
    return button
end

-- 添加开关
function Window:AddToggle(parent, options)
    if not parent then
        warn("Invalid parent for toggle")
        return nil
    end
    
    local container = Utils:CreateInstance("Frame", {
        Name = "Toggle_" .. (options.Text or "Toggle"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    if not container then
        warn("Failed to create toggle container")
        return nil
    end
    
    Utils:SetParentSafe(container, parent)
    
    local label = Utils:CreateInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Font = CONFIG.Font,
        Text = options.Text or "开关",
        TextColor3 = CurrentTheme.Foreground,
        TextSize = CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    if label then
        Utils:SetParentSafe(label, container)
    end
    
    local toggleBackground = Utils:CreateInstance("Frame", {
        Name = "ToggleBackground",
        BackgroundColor3 = options.Default and CurrentTheme.Primary or CurrentTheme.Secondary,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -40, 0.5, -10),
        AnchorPoint = Vector2.new(1, 0.5)
    })
    
    if toggleBackground then
        Utils:SetParentSafe(toggleBackground, container)
        local bgCorner = Utils:CreateCorner(UDim.new(0, 10))
        if bgCorner then
            bgCorner.Parent = toggleBackground
        end
    end
    
    local toggleSlider = Utils:CreateInstance("Frame", {
        Name = "ToggleSlider",
        BackgroundColor3 = Color3.new(1, 1, 1),
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(options.Default and 1 or 0, options.Default and -18 or 2, 0.5, -8),
        AnchorPoint = Vector2.new(options.Default and 1 or 0, 0.5)
    })
    
    if toggleSlider then
        Utils:SetParentSafe(toggleSlider, toggleBackground)
        local sliderCorner = Utils:CreateCorner(UDim.new(0, 8))
        if sliderCorner then
            sliderCorner.Parent = toggleSlider
        end
    end
    
    local clickArea = Utils:CreateInstance("TextButton", {
        Name = "ClickArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = ""
    })
    
    if clickArea then
        Utils:SetParentSafe(clickArea, container)
        
        local state = options.Default or false
        
        clickArea.MouseButton1Click:Connect(function()
            state = not state
            
            if state then
                Utils:Tween(toggleBackground, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                Utils:Tween(toggleSlider, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
            else
                Utils:Tween(toggleBackground, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                Utils:Tween(toggleSlider, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
            end
            
            if options.Callback then
                Utils:TrySafe(function()
                    options.Callback(state)
                end, "Toggle callback failed")
            end
        end)
    end
    
    return {
        Instance = container,
        SetState = function(newState)
            state = newState
            if toggleBackground and toggleSlider then
                if state then
                    Utils:Tween(toggleBackground, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
                    Utils:Tween(toggleSlider, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Utils:Tween(toggleBackground, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
                    Utils:Tween(toggleSlider, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
            end
        end
    }
end

-- 添加滑块
function Window:AddSlider(parent, options)
    if not parent then
        warn("Invalid parent for slider")
        return nil
    end
    
    local container = Utils:CreateInstance("Frame", {
        Name = "Slider_" .. (options.Text or "Slider"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50)
    })
    
    if not container then
        warn("Failed to create slider container")
        return nil
    end
    
    Utils:SetParentSafe(container, parent)
    
    local value = options.Default or options.Min or 0
    
    local label = Utils:CreateInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 0),
        Font = CONFIG.Font,
        Text = options.Text or "滑块",
        TextColor3 = CurrentTheme.Foreground,
        TextSize = CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    if label then
        Utils:SetParentSafe(label, container)
    end
    
    local valueLabel = Utils:CreateInstance("TextLabel", {
        Name = "ValueLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0, 20),
        Position = UDim2.new(0.7, 0, 0, 0),
        Font = CONFIG.Font,
        Text = tostring(value) .. (options.Suffix or ""),
        TextColor3 = CurrentTheme.Secondary,
        TextSize = CONFIG.TextSize,
        TextXAlignment = Enum.TextXAlignment.Right
    })
    
    if valueLabel then
        Utils:SetParentSafe(valueLabel, container)
    end
    
    local track = Utils:CreateInstance("Frame", {
        Name = "Track",
        BackgroundColor3 = CurrentTheme.Secondary,
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, 30)
    })
    
    if track then
        Utils:SetParentSafe(track, container)
        local trackCorner = Utils:CreateCorner(UDim.new(0, 2))
        if trackCorner then
            trackCorner.Parent = track
        end
    end
    
    local progress = Utils:CreateInstance("Frame", {
        Name = "Progress",
        BackgroundColor3 = CurrentTheme.Primary,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })
    
    if progress then
        Utils:SetParentSafe(progress, track)
        local progressCorner = Utils:CreateCorner(UDim.new(0, 2))
        if progressCorner then
            progressCorner.Parent = progress
        end
    end
    
    return {
        Instance = container,
        SetValue = function(newValue)
            value = math.clamp(newValue, options.Min or 0, options.Max or 100)
            local percentage = (value - (options.Min or 0)) / ((options.Max or 100) - (options.Min or 0))
            
            if valueLabel then
                valueLabel.Text = tostring(math.floor(value + 0.5)) .. (options.Suffix or "")
            end
            
            if progress then
                progress.Size = UDim2.new(percentage, 0, 1, 0)
            end
        end
    }
end

-- 添加标签
function Window:AddLabel(parent, options)
    if not parent then
        warn("Invalid parent for label")
        return nil
    end
    
    local label = Utils:CreateInstance("TextLabel", {
        Name = "Label_" .. (options.Text or "Label"),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
        Font = CONFIG.Font,
        Text = options.Text or "标签",
        TextColor3 = CurrentTheme.Foreground,
        TextSize = CONFIG.TextSize,
        TextXAlignment = options.Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
    })
    
    if label then
        Utils:SetParentSafe(label, parent)
    end
    
    return label
end

-- 添加分隔线
function Window:AddDivider(parent, options)
    if not parent then
        warn("Invalid parent for divider")
        return nil
    end
    
    local container = Utils:CreateInstance("Frame", {
        Name = "Divider",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20)
    })
    
    if not container then
        warn("Failed to create divider container")
        return nil
    end
    
    Utils:SetParentSafe(container, parent)
    
    local line = Utils:CreateInstance("Frame", {
        Name = "Line",
        BackgroundColor3 = CurrentTheme.Border,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5)
    })
    
    if line then
        Utils:SetParentSafe(line, container)
    end
    
    return container
end

-- 切换标签
function Window:SwitchTab(tab)
    if not tab then
        warn("Invalid tab to switch to")
        return
    end
    
    for _, t in ipairs(self.Tabs) do
        t.Visible = false
    end
    
    for _, tb in ipairs(self.TabButtons) do
        Utils:Tween(tb.Button, {BackgroundColor3 = CurrentTheme.Secondary}, 0.2)
    end
    
    tab.Visible = true
    self.CurrentTab = tab
    
    for _, tb in ipairs(self.TabButtons) do
        if tb.Tab == tab then
            Utils:Tween(tb.Button, {BackgroundColor3 = CurrentTheme.Primary}, 0.2)
            break
        end
    end
end

function Window:Show()
    if self.MainWindow then
        self.Visible = true
        self.MainWindow.Visible = true
        
        if self.Center then
            self.MainWindow.Position = UDim2.new(0.5, -self.MainWindow.Size.X.Offset/2, 0.5, -self.MainWindow.Size.Y.Offset/2)
        end
    end
end

function Window:Hide()
    if self.MainWindow then
        self.Visible = false
        self.MainWindow.Visible = false
    end
end

function Window:Toggle()
    if self.Visible then
        self:Hide()
    else
        self:Show()
    end
end

function Window:Minimize()
    if self.MainWindow then
        if self.MainWindow.Size.Y.Offset > 80 then
            self.SavedSize = self.MainWindow.Size
            Utils:Tween(self.MainWindow, {Size = UDim2.new(self.MainWindow.Size.X.Scale, self.MainWindow.Size.X.Offset, 0, 80)}, 0.2)
        else
            Utils:Tween(self.MainWindow, {Size = self.SavedSize or self.Size}, 0.2)
        end
    end
end

-- ==================== 主库函数 ====================
function AdvancedUI:CreateWindow(options)
    local window = Window.new(options)
    local success, result = pcall(function()
        return window:Create()
    end)
    
    if not success then
        warn("Failed to create window: " .. tostring(result))
        return nil
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

-- 返回库对象
return AdvancedUI
