local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"))()
local Window = Library:CreateWindow({
    Title = "XM",
    Footer = "版本: V1 | 游戏 :通用",
    Icon = 106760189301805,
    NotifySide = "Right",
})
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
    Max = 100,
    Rounding = 0,
    Callback = function(speed)
    Humanoid.WalkSpeed:speed
    end
})
LeftGroupBox:AddSlider("MySlider", {
    Text = "跳跃",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(speed)
    Humanoid.JumpHeight:speed
    end
})

local RightGroupBox = Tab:AddRightGroupbox("后门")
RightGroupBox:AddButton({
    Text = "LALOL-Hub-Backdoor",
    Func = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-LALOL-Hub-Backdoor-158177"))()
    end
})
local Tab = Window:AddTab({
    Name = "脚本中心",
    Description = "BROBROBROBROBRO",
    Icon = "wrench"
})
