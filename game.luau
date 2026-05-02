-- ============================================
-- XM 响应式欢迎界面 v2.0
-- 功能：自适应所有设备，加载完成后显示启动按钮
-- 支持：手机、平板、电脑
-- ============================================

-- 设备检测和配置
local DeviceConfig = {
    isMobile = false,
    isTablet = false,
    isDesktop = true,
    screenSize = Vector2.new(0, 0),
    aspectRatio = 1
}

-- 响应式UI配置
local UIConfig = {
    BaseScale = 0.8,  -- 基础缩放比例
    MobileScale = 0.7,  -- 手机缩放
    TabletScale = 0.85,  -- 平板缩放
    DesktopScale = 1.0,  -- 电脑缩放
    FontSizes = {
        mobile = 20,
        tablet = 24,
        desktop = 28
    }
}

-- 检测设备类型
local function DetectDevice()
    local UserInputService = game:GetService("UserInputService")
    local screenSize = workspace.CurrentCamera.ViewportSize
    
    DeviceConfig.screenSize = screenSize
    DeviceConfig.aspectRatio = screenSize.X / screenSize.Y
    
    -- 检测设备类型
    DeviceConfig.isMobile = UserInputService.TouchEnabled
    DeviceConfig.isDesktop = not DeviceConfig.isMobile
    DeviceConfig.isTablet = DeviceConfig.isMobile and (screenSize.X > 600 or screenSize.Y > 600)
    
    -- 如果是手机，进一步区分平板
    if DeviceConfig.isMobile and (screenSize.X >= 768 or screenSize.Y >= 768) then
        DeviceConfig.isTablet = true
        DeviceConfig.isMobile = false
    end
    
    return DeviceConfig
end

-- 计算响应式尺寸
local function CalculateResponsiveSize()
    DetectDevice()
    
    local scale = UIConfig.BaseScale
    
    if DeviceConfig.isMobile then
        scale = UIConfig.MobileScale
    elseif DeviceConfig.isTablet then
        scale = UIConfig.TabletScale
    else
        scale = UIConfig.DesktopScale
    end
    
    -- 根据屏幕大小动态调整
    local screenWidth = DeviceConfig.screenSize.X
    local screenHeight = DeviceConfig.screenSize.Y
    
    local width = math.min(500, screenWidth * 0.8) * scale
    local height = math.min(350, screenHeight * 0.6) * scale
    
    return {
        width = width,
        height = height,
        scale = scale,
        fontSize = DeviceConfig.isMobile and UIConfig.FontSizes.mobile or 
                   DeviceConfig.isTablet and UIConfig.FontSizes.tablet or 
                   UIConfig.FontSizes.desktop
    }
end

-- 创建响应式欢迎界面
local function CreateResponsiveWelcomeUI()
    local responsiveSize = CalculateResponsiveSize()
    
    -- 创建主界面
    local WelcomeScreen = Instance.new("ScreenGui")
    WelcomeScreen.Name = "XMResponsiveWelcome"
    WelcomeScreen.ResetOnSpawn = false
    WelcomeScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    WelcomeScreen.IgnoreGuiInset = true
    
    -- 灰色毛玻璃背景
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.BackgroundColor3 = Color3.fromRGB(40, 40, 50)  -- 灰色调
    Background.BackgroundTransparency = 0.3
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.Position = UDim2.new(0, 0, 0, 0)
    Background.Parent = WelcomeScreen
    
    -- 高斯模糊效果
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 15
    BlurEffect.Enabled = true
    Background.BackgroundTransparency = 0.3
    BlurEffect.Parent = Background
    
    -- 主容器
    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "MainContainer"
    MainContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    MainContainer.BackgroundTransparency = 0.7
    MainContainer.Size = UDim2.new(0, responsiveSize.width, 0, responsiveSize.height)
    MainContainer.Position = UDim2.new(0.5, -responsiveSize.width/2, 0.5, -responsiveSize.height/2)
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.Parent = Background
    
    -- 圆角
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 20)
    Corner.Parent = MainContainer
    
    -- 边框
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(100, 100, 150)
    Stroke.Thickness = 3
    Stroke.Transparency = 0.5
    Stroke.Parent = MainContainer
    
    -- 内阴影
    local InnerShadow = Instance.new("ImageLabel")
    InnerShadow.Name = "InnerShadow"
    InnerShadow.Image = "rbxassetid://8575942831"
    InnerShadow.ScaleType = Enum.ScaleType.Slice
    InnerShadow.SliceCenter = Rect.new(20, 20, 280, 280)
    InnerShadow.BackgroundTransparency = 1
    InnerShadow.Size = UDim2.new(1, 0, 1, 0)
    InnerShadow.Position = UDim2.new(0, 0, 0, 0)
    InnerShadow.ImageTransparency = 0.7
    InnerShadow.Parent = MainContainer
    
    -- 欢迎文字容器
    local TextContainer = Instance.new("Frame")
    TextContainer.Name = "TextContainer"
    TextContainer.BackgroundTransparency = 1
    TextContainer.Size = UDim2.new(0.9, 0, 0, 100)
    TextContainer.Position = UDim2.new(0.05, 0, 0.1, 0)
    TextContainer.Parent = MainContainer
    
    -- 欢迎文字
    local WelcomeText = Instance.new("TextLabel")
    WelcomeText.Name = "WelcomeText"
    WelcomeText.Text = ""
    WelcomeText.Font = Enum.Font.GothamBold
    WelcomeText.TextSize = responsiveSize.fontSize
    WelcomeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    WelcomeText.BackgroundTransparency = 1
    WelcomeText.Size = UDim2.new(1, 0, 1, 0)
    WelcomeText.Position = UDim2.new(0, 0, 0, 0)
    WelcomeText.TextTransparency = 0
    WelcomeText.TextWrapped = true
    WelcomeText.TextScaled = false
    WelcomeText.Parent = TextContainer
    
    -- 加载条容器
    local LoadingContainer = Instance.new("Frame")
    LoadingContainer.Name = "LoadingContainer"
    LoadingContainer.BackgroundTransparency = 1
    LoadingContainer.Size = UDim2.new(0.8, 0, 0, 30)
    LoadingContainer.Position = UDim2.new(0.1, 0, 0.6, 0)
    LoadingContainer.Parent = MainContainer
    
    -- 加载条背景
    local LoadingBarBackground = Instance.new("Frame")
    LoadingBarBackground.Name = "LoadingBarBackground"
    LoadingBarBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    LoadingBarBackground.BackgroundTransparency = 0.3
    LoadingBarBackground.Size = UDim2.new(1, 0, 0, 20)
    LoadingBarBackground.Position = UDim2.new(0, 0, 0, 5)
    LoadingBarBackground.Parent = LoadingContainer
    
    local LoadingBarCorner = Instance.new("UICorner")
    LoadingBarCorner.CornerRadius = UDim.new(0, 10)
    LoadingBarCorner.Parent = LoadingBarBackground
    
    -- 加载条
    local LoadingBar = Instance.new("Frame")
    LoadingBar.Name = "LoadingBar"
    LoadingBar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    LoadingBar.BackgroundTransparency = 0.3
    LoadingBar.Size = UDim2.new(0, 0, 1, 0)
    LoadingBar.Position = UDim2.new(0, 0, 0, 0)
    LoadingBar.Parent = LoadingBarBackground
    
    local LoadingBarInnerCorner = Instance.new("UICorner")
    LoadingBarInnerCorner.CornerRadius = UDim.new(0, 10)
    LoadingBarInnerCorner.Parent = LoadingBar
    
    -- 加载文本
    local LoadingText = Instance.new("TextLabel")
    LoadingText.Name = "LoadingText"
    LoadingText.Text = "正在初始化..."
    LoadingText.Font = Enum.Font.Gotham
    LoadingText.TextSize = 16
    LoadingText.TextColor3 = Color3.fromRGB(200, 200, 200)
    LoadingText.BackgroundTransparency = 1
    LoadingText.Size = UDim2.new(1, 0, 1, 0)
    LoadingText.Position = UDim2.new(0, 0, 0, 25)
    LoadingText.TextTransparency = 0.5
    LoadingText.Parent = LoadingContainer
    
    -- 启动按钮（初始隐藏）
    local StartButton = Instance.new("TextButton")
    StartButton.Name = "StartButton"
    StartButton.Text = "🚀 启动 XM 脚本"
    StartButton.Font = Enum.Font.GothamBold
    StartButton.TextSize = 20
    StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    StartButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    StartButton.BackgroundTransparency = 0.3
    StartButton.Size = UDim2.new(0.6, 0, 0, 50)
    StartButton.Position = UDim2.new(0.2, 0, 0.8, 0)
    StartButton.Visible = false
    StartButton.Parent = MainContainer
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = StartButton
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(150, 200, 255)
    ButtonStroke.Thickness = 2
    ButtonStroke.Transparency = 0.5
    ButtonStroke.Parent = StartButton
    
    -- 按钮悬停效果
    StartButton.MouseEnter:Connect(function()
        StartButton.BackgroundTransparency = 0.1
        ButtonStroke.Transparency = 0.2
    end)
    
    StartButton.MouseLeave:Connect(function()
        StartButton.BackgroundTransparency = 0.3
        ButtonStroke.Transparency = 0.5
    end)
    
    -- 按钮点击事件
    StartButton.MouseButton1Click:Connect(function()
        -- 执行指定脚本
        local success, errorMsg = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CN-ZX114514/XM-Code/refs/heads/main/language/GameZH-CN.luau"))()
        end)
        
        if success then
            print("✅ XM脚本加载成功")
        else
            warn("❌ 脚本加载失败:", errorMsg)
        end
        
        -- 隐藏按钮
        StartButton.Visible = false
        
        -- 渐变消失整个界面
        for i = 0, 1, 0.1 do
            Background.BackgroundTransparency = 0.3 + (i * 0.7)
            MainContainer.BackgroundTransparency = 0.7 + (i * 0.3)
            wait(0.05)
        end
        
        -- 删除界面
        WelcomeScreen:Destroy()
    end)
    
    -- 设备信息显示
    local DeviceInfo = Instance.new("TextLabel")
    DeviceInfo.Name = "DeviceInfo"
    DeviceInfo.Text = "设备: " .. (DeviceConfig.isMobile and "手机" or DeviceConfig.isTablet and "平板" or "电脑")
    DeviceInfo.Font = Enum.Font.Gotham
    DeviceInfo.TextSize = 12
    DeviceInfo.TextColor3 = Color3.fromRGB(150, 150, 180)
    DeviceInfo.BackgroundTransparency = 1
    DeviceInfo.Size = UDim2.new(1, 0, 0, 20)
    DeviceInfo.Position = UDim2.new(0, 0, 0.95, 0)
    DeviceInfo.TextTransparency = 0.5
    DeviceInfo.Parent = MainContainer
    
    return {
        Screen = WelcomeScreen,
        Text = WelcomeText,
        LoadingBar = LoadingBar,
        LoadingText = LoadingText,
        StartButton = StartButton,
        DeviceInfo = DeviceInfo
    }
end

-- 主欢迎流程
local function ShowWelcomeAndLoad()
    print("正在启动 XM 响应式欢迎界面...")
    
    -- 创建界面
    local ui = CreateResponsiveWelcomeUI()
    
    -- 添加到CoreGui
    local CoreGui = game:GetService("CoreGui")
    ui.Screen.Parent = CoreGui
    
    -- 设备信息
    DetectDevice()
    print("设备类型:", DeviceConfig.isMobile and "手机" or DeviceConfig.isTablet and "平板" or "电脑")
    print("屏幕尺寸:", DeviceConfig.screenSize)
    print("宽高比:", DeviceConfig.aspectRatio)
    
    -- 更新设备信息
    ui.DeviceInfo.Text = string.format("设备: %s | 分辨率: %dx%d", 
        DeviceConfig.isMobile and "手机" or DeviceConfig.isTablet and "平板" or "电脑",
        DeviceConfig.screenSize.X, DeviceConfig.screenSize.Y)
    
    -- 初始状态：完全透明
    ui.Screen.Background.BackgroundTransparency = 1
    ui.Screen.Background.MainContainer.BackgroundTransparency = 1
    ui.Text.TextTransparency = 1
    ui.LoadingBar.BackgroundTransparency = 1
    ui.LoadingText.TextTransparency = 1
    
    -- 第一步：背景渐变显示
    for i = 0, 0.3, 0.05 do
        ui.Screen.Background.BackgroundTransparency = 1 - i
        wait(0.05)
    end
    
    -- 第二步：主容器渐变显示
    for i = 0, 0.7, 0.1 do
        ui.Screen.Background.MainContainer.BackgroundTransparency = 1 - i
        wait(0.05)
    end
    
    -- 第三步：显示欢迎文字
    local welcomeMessages = {
        "欢迎使用",
        "欢迎使用 XM",
        "欢迎使用 XM 脚本"
    }
    
    for _, message in ipairs(welcomeMessages) do
        ui.Text.Text = message
        for i = 0, 0.9, 0.1 do
            ui.Text.TextTransparency = 1 - i
            wait(0.05)
        end
        wait(0.5)
    end
    
    -- 第四步：加载动画
    ui.LoadingText.Text = "正在加载 XM 脚本..."
    ui.LoadingText.TextTransparency = 0.5
    
    local loadTime = 2.5
    local startTime = tick()
    
    while tick() - startTime < loadTime do
        local progress = (tick() - startTime) / loadTime
        ui.LoadingBar.Size = UDim2.new(progress, 0, 1, 0)
        
        -- 更新加载文本
        local percent = math.floor(progress * 100)
        ui.LoadingText.Text = string.format("正在加载 XM 脚本... %d%%", percent)
        
        -- 加载条透明度动画
        ui.LoadingBar.BackgroundTransparency = 0.1 + (math.sin(tick() * 5) * 0.1)
        
        wait(0.05)
    end
    
    -- 完成加载
    ui.LoadingBar.Size = UDim2.new(1, 0, 1, 0)
    ui.LoadingText.Text = "✅ 加载完成！"
    ui.LoadingBar.BackgroundTransparency = 0.1
    
    -- 第五步：显示启动按钮
    wait(1)  -- 延迟1秒显示按钮
    
    -- 按钮出现动画
    ui.StartButton.Visible = true
    ui.StartButton.BackgroundTransparency = 1
    ui.StartButton.TextTransparency = 1
    
    for i = 0, 1, 0.1 do
        ui.StartButton.BackgroundTransparency = 1 - (i * 0.7)
        ui.StartButton.TextTransparency = 1 - i
        wait(0.05)
    end
    
    ui.StartButton.BackgroundTransparency = 0.3
    ui.StartButton.TextTransparency = 0
    
    print("✅ 欢迎界面加载完成，等待用户点击启动按钮...")
    
    return ui
end

-- 屏幕大小变化监听
local function SetupScreenResizeListener(ui)
    local Camera = workspace.CurrentCamera
    local lastSize = Camera.ViewportSize
    
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        local newSize = Camera.ViewportSize
        
        if newSize ~= lastSize then
            lastSize = newSize
            
            -- 重新计算尺寸
            local responsiveSize = CalculateResponsiveSize()
            
            -- 更新主容器尺寸
            ui.Screen.Background.MainContainer.Size = UDim2.new(0, responsiveSize.width, 0, responsiveSize.height)
            ui.Screen.Background.MainContainer.Position = UDim2.new(0.5, -responsiveSize.width/2, 0.5, -responsiveSize.height/2)
            
            -- 更新设备信息
            DetectDevice()
            ui.DeviceInfo.Text = string.format("设备: %s | 分辨率: %dx%d", 
                DeviceConfig.isMobile and "手机" or DeviceConfig.isTablet and "平板" or "电脑",
                DeviceConfig.screenSize.X, DeviceConfig.screenSize.Y)
            
            print("屏幕尺寸变化:", newSize)
        end
    end)
end

-- 主执行函数
local function Main()
    print("========================================")
    print("🚀 XM 响应式欢迎界面 v2.0")
    print("========================================")
    
    -- 等待游戏加载
    if not game:IsLoaded() then
        print("等待游戏加载...")
        game.Loaded:Wait()
    end
    
    -- 显示欢迎界面
    local success, errorMsg = pcall(function()
        local ui = ShowWelcomeAndLoad()
        SetupScreenResizeListener(ui)
        return true
    end)
    
    if not success then
        warn("欢迎界面加载失败:", errorMsg)
        
        -- 直接加载脚本
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/CN-ZX114514/XM-Code/refs/heads/main/language/GameZH-CN.luau"))()
        end)
    end
    
    print("欢迎界面执行完成")
    print("========================================")
end

-- 启动脚本
if script and script.Parent then
    -- 如果作为本地脚本运行
    Main()
else
    -- 如果在执行器中运行
    task.spawn(function()
        wait(1)  -- 延迟启动
        Main()
    end)
end

-- 全局控制函数
return {
    ShowWelcome = ShowWelcomeAndLoad,
    GetDeviceInfo = DetectDevice,
    CalculateResponsiveSize = CalculateResponsiveSize
}
