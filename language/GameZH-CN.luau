-- 智能加载器 v1.0
-- 功能：根据游戏ID自动加载专用脚本，否则加载通用脚本

-- ================ 1. 配置区域 ================



-- 通用脚本配置
local UniversalConfig = {
    Enabled = true, -- 是否启用通用脚本功能
    Script = {
        url = "https://raw.githubusercontent.com/CN-ZX114514/XM-Code/refs/heads/main/XM-Code/XM-Obsidian.luau", -- 通用脚本URL
        name = "通用功能脚本",
        timeout = 15, -- 超时时间(秒)
        retry = 1     -- 重试次数
    },
    -- 黑名单：即使启用通用脚本，这些游戏ID也不会加载任何脚本
    Blacklist = {
        1111111111,
        2222222222
    }
}
-- ================ 配置区域结束 ================

-- ================ 2. 核心函数 ================
-- 安全加载脚本函数
local function SafeLoadScript(scriptUrl, scriptName)
    local success, result = pcall(function()
        if not scriptUrl or scriptUrl == "" then
            return false, "脚本URL为空"
        end
        
        -- 尝试获取脚本内容
        local scriptContent = game:HttpGet(scriptUrl, true)
        if not scriptContent or scriptContent == "" then
            return false, "获取到的脚本内容为空"
        end
        
        -- 安全加载并执行
        local loadFunc, errorMsg = loadstring(scriptContent)
        if not loadFunc then
            return false, "脚本编译错误: " .. (errorMsg or "未知")
        end
        
        -- 设置安全环境
        local env = {
            print = function(...)
                local args = {...}
                for i, v in ipairs(args) do
                    args[i] = tostring(v)
                end
                warn("[" .. scriptName .. "]: " .. table.concat(args, "\t"))
            end,
            warn = warn,
            error = error,
            wait = task.wait,
            task = task,
            spawn = task.spawn,
            delay = task.delay
        }
        
        setfenv(loadFunc, setmetatable(env, {
            __index = getfenv(),
            __newindex = function(t, k, v)
                rawset(t, k, v)
            end
        }))
        
        -- 执行脚本
        local execSuccess, execResult = pcall(loadFunc)
        if not execSuccess then
            return false, "脚本执行错误: " .. (execResult or "未知")
        end
        
        return true, "脚本加载成功"
    end)
    
    return success, result
end

-- 带重试机制的加载函数
local function LoadScriptWithRetry(scriptConfig, scriptType)
    local retryCount = 0
    local maxRetries = scriptConfig.retry or 1
    local scriptName = scriptConfig.name or (scriptType .. "脚本")
    
    while retryCount <= maxRetries do
        if retryCount > 0 then
            print("[Loader] 第" .. retryCount .. "次重试加载 " .. scriptName .. "...")
            task.wait(2)
        end
        
        local timeoutSuccess, result = pcall(function()
            return SafeLoadScript(scriptConfig.url, scriptName)
        end)
        
        if timeoutSuccess then
            local loadSuccess, loadResult = result
            if loadSuccess then
                print("[Loader] " .. scriptName .. " 加载成功")
                return true
            else
                warn("[Loader] " .. scriptName .. " 加载失败: " .. loadResult)
            end
        else
            warn("[Loader] " .. scriptName .. " 加载过程异常: " .. result)
        end
        
        retryCount = retryCount + 1
        
        if retryCount > maxRetries then
            warn("[Loader] " .. scriptName .. " 已达到最大重试次数(" .. maxRetries .. ")，停止尝试")
            break
        end
    end
    return false
end

-- 检查是否在黑名单中
local function IsBlacklisted(placeId)
    for _, blackId in ipairs(UniversalConfig.Blacklist) do
        if placeId == blackId then
            return true
        end
    end
    return false
end

-- 主加载流程
local function MainLoader()
    -- 等待游戏加载
    if not game:IsLoaded() then
        local loadedSuccess, loadedError = pcall(function()
            game.Loaded:Wait()
        end)
        
        if not loadedSuccess then
            warn("[Loader] 等待游戏加载失败: " .. loadedError)
            return
        end
    end
    
    print("[Loader] 游戏加载完成")
    
    -- 等待玩家角色
    local player = game.Players.LocalPlayer
    local charWaitSuccess, charWaitError = pcall(function()
        repeat
            task.wait(0.5)
        until player.Character
    end)
    
    if not charWaitSuccess then
        warn("[Loader] 等待角色加载失败: " .. charWaitError)
        return
    end
    
    print("[Loader] 角色加载完成")
    
    local placeId = game.PlaceId
    local scriptConfig = scriptMap[placeId] -- 原有的专用脚本配置
    
    -- 检查是否在黑名单中
    if IsBlacklisted(placeId) then
        print("[Loader] 当前游戏(" .. placeId .. ")在黑名单中，跳过所有脚本加载。")
        return
    end
    
    -- 修改后的判断逻辑
    if scriptConfig then
        -- 情况A: 有专用脚本配置，加载专用脚本
        print("[Loader] 检测到游戏ID: " .. placeId)
        print("[Loader] 准备加载专用脚本: " .. scriptConfig.name)
        LoadScriptWithRetry(scriptConfig, "专用")
        
    elseif UniversalConfig.Enabled then
        -- 情况B: 无专用配置，但启用了通用脚本，加载通用脚本
        print("[Loader] 游戏ID(" .. placeId .. ")未配置专用脚本。")
        print("[Loader] 正在加载通用脚本: " .. UniversalConfig.Script.name)
        LoadScriptWithRetry(UniversalConfig.Script, "通用")
        
    else
        -- 情况C: 无专用配置，且未启用通用脚本
        print("[Loader] 当前游戏(" .. placeId .. ")未配置自动脚本，且通用脚本功能未启用。")
    end
end

-- ================ 3. 执行部分 ================
-- 延迟启动，避免与其他脚本冲突
task.wait(3)

-- 捕获整个加载过程的错误
local mainSuccess, mainError = pcall(MainLoader)
if not mainSuccess then
    warn("[Loader] 主加载流程发生致命错误: " .. mainError)
end

print("[Loader] 加载器完成运行")

-- ================ 4. 全局控制函数 ================
-- 切换通用脚本功能
_G.ToggleUniversalScript = function(enabled)
    UniversalConfig.Enabled = enabled
    -- 修正：将 ":" 改为 "or"
    print("[Loader] 通用脚本功能已" .. (enabled and "启用" or "禁用"))
end

-- 手动触发加载通用脚本
_G.LoadUniversalScriptNow = function()
    if UniversalConfig.Enabled then
        print("[Loader] 手动触发加载通用脚本...")
        LoadScriptWithRetry(UniversalConfig.Script, "手动触发-通用")
    else
        warn("[Loader] 通用脚本功能未启用，无法手动加载。")
    end
end

-- 添加专用脚本
_G.AddGameScript = function(gameId, config)
    if type(gameId) ~= "number" then
        return warn("[Loader] 游戏ID必须是数字")
    end
    
    if type(config) ~= "table" then
        return warn("[Loader] 配置必须是表格")
    end
    
    scriptMap[gameId] = config
    print("[Loader] 已添加游戏ID " .. gameId .. " 的专用脚本")
end

-- 检查当前状态
_G.CheckLoaderStatus = function()
    local placeId = game.PlaceId
    local hasSpecific = scriptMap[placeId] ~= nil
    local isBlacklisted = IsBlacklisted(placeId)
    
    print("=== 加载器状态 ===")
    print("当前游戏ID: " .. placeId)
    print("专用脚本配置: " .. (hasSpecific and "有" or "无"))
    print("黑名单状态: " .. (isBlacklisted and "是" or "否"))
    print("通用脚本功能: " .. (UniversalConfig.Enabled and "启用" or "禁用"))
    
    if hasSpecific then
        print("专用脚本名称: " .. scriptMap[placeId].name)
    end
end
