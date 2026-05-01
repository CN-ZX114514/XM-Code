local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local Window = Library:CreateWindow({
    Title = "XM",
    Footer = "版本: V1 | 游戏 :通用",
    Icon = 106760189301805,
    NotifySide = "Right",
})
-- Sets the draggable label visibility
local DraggableLabel = Library:AddDraggableLabel("XM Code FREE")
DraggableLabel:SetVisible(true)
 
-- Example of dynamically-updating draggable label with common traits (fps and ping)
local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;
 
local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1;
 
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;
 
    DraggableLabel:SetText(('XM Code FREE | %s fps | %s ms | XM水印'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);
local Tab = Window:AddTab({
    Name = "首页",
    Description = "BROBROBROBROBRO",
    Icon = "home"
})
local LeftGroupBox = Tab:AddLeftGroupbox("主页", "wrench")
LeftGroupBox:AddInput("MyPseudoCodeInput", {
    Text = "鬼畜视频播放💀💀💀",
    Default = "https://github.com/CN-ZX114514/XM-Code/raw/refs/heads/main/%E7%9C%BC%20%E7%9D%9B%20%E7%9E%8E%20%E5%9C%A8%20%E6%89%8B%20%E6%9C%BA%20%E4%B8%8A_%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9_bilibili.mp4",
    Placeholder = "hhttps://github.com/CN-ZX114514/XM-Code/raw/refs/heads/main/%E7%9C%BC%20%E7%9D%9B%20%E7%9E%8E%20%E5%9C%A8%20%E6%89%8B%20%E6%9C%BA%20%E4%B8%8A_%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9_bilibili.mp4",
    Callback = function(value)
        print("Value changed", value)
    end
})
LeftGroupBox:AddVideo("MyVideo", {
    Video = "https://github.com/CN-ZX114514/XM-Code/raw/refs/heads/main/%E7%9C%BC%20%E7%9D%9B%20%E7%9E%8E%20%E5%9C%A8%20%E6%89%8B%20%E6%9C%BA%20%E4%B8%8A_%E5%93%94%E5%93%A9%E5%93%94%E5%93%A9_bilibili.mp4",
    Looped = true,
    Playing = true,
    Volume = 0,
})
LeftGroupBox:AddImage("MyImage", {
    Image = "rbxassetid://106760189301805",
    Callback = function(image)
        print("Image changed!", image)
    end,
})
LeftGroupBox:AddDivider("这是我们的DC(有漏洞可以反馈)")
LeftGroupBox:AddButton("复制(懒得写脚本直接弹出)", function()
    Library:Notify("https://discord.com/invite/9GFpDKXrXu", 4)
    loadstring("setclipboard('https://discord.com/invite/9GFpDKXrXu")()
end)
local RightGroupBox = Tab:AddRightGroupbox("支持游戏","wrench")
RightGroupBox:AddLabel("[🟢]通用")
RightGroupBox:AddLabel("[🟢]忍者传奇")
local RightGroupBox = Tab:AddRightGroupbox("编写人员与测试人员","wrench")
RightGroupBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">所有者</font>] NB123 ")
RightGroupBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">游戏执行器</font>] 元宝AI ")
RightGroupBox:AddLabel("[<font color=\"rgb(73, 230, 133)\">测试人员</font>] NB123 ")
local Tab = Window:AddTab({
    Name = "功能",
    Description = "BROBROBROBROBRO",
    Icon = "wrench"
})
local LeftGroupBox = Tab:AddLeftGroupbox("功能", "wrench")
LeftGroupBox:AddSlider("MySlider", {
    Text = "速度",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
    local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function boostCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = (value)
	humanoid.UseJumpPower = true
end

if player.Character then
	boostCharacter(player.Character)
end

player.CharacterAdded:Connect(boostCharacter)
    end
})
LeftGroupBox:AddSlider("MySlider", {
    Text = "跳跃",
    Default = 16,
    Min = 0,
    Max = 1000,
    Rounding = 0,
    Callback = function(value)
    local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function boostCharacter(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.JumpPower = value
	humanoid.UseJumpPower = true
end

if player.Character then
	boostCharacter(player.Character)
end

player.CharacterAdded:Connect(boostCharacter)
    end
})

local RightGroupBox = Tab:AddRightGroupbox("后门")
RightGroupBox:AddButton({
    Text = "LALOL-Hub-Backdoor",
    Func = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-LALOL-Hub-Backdoor-158177"))()
    end
})
local LeftGroupBox = Tab:AddLeftGroupbox("整蛊[TEST可能会引起不适]", "wrench")
LeftGroupBox:AddLabel("[<font color=\"rgb(255, 0, 0)\">TIP</font>]:<font color=\"rgb(116, 33, 44)\">有些可能会引发癫痫当你在使用时将同意此条信息</font>]")
LeftGroupBox:AddButton({
    Text = "地图彩色[光敏感患者不要使用]需要双击",
    DoubleClick = true,
    Risky = true,
    Func = function()
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local running = true
local hue = 0

local function stop()
	running = false
end

task.spawn(function()
	while running do
		pcall(function()
			hue = (hue + 0.01) % 1
			Lighting.Ambient = Color3.fromHSV(hue, 1, 1)
			Lighting.OutdoorAmbient = Color3.fromHSV(hue, 1, 1)
		end)
		task.wait(0.01)
	end
end)
end
})
local Tab = Window:AddTab({
    Name = "脚本中心",
    Description = "BROBROBROBROBRO",
    Icon = "wrench"
}) 
local Tab = Window:AddTab({
    Name = "自定义",
    Description = "BROBROBROBROBRO",
    Icon = "wrench"
})
local LeftGroupBox = Tab:AddLeftGroupbox("普通", "wrench")
LeftGroupBox:AddSlider("MySlider", {
    Text = "圆角",
    Default = 4,
    Min = 0,
    Max = 30,
    Rounding = 0,
    Callback = function(value)
    Window:SetCornerRadius(value)
    end
})
