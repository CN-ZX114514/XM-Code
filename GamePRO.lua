-- 主加载器 - 带安全错误处理的版本（增强：支持通用脚本）
local function SafeLoadScript(scriptUrl, scriptName)
    -- ... (函数体保持不变，同文档) ...
    return success, result
end

-- ================ 新增：通用脚本配置区域 ================
-- 用户可以在此配置当没有专用脚本时，默认加载的通用脚本
local UniversalConfig = {
    Enabled = true, -- 是否启用通用脚本功能
    Script = {
        url = "https://raw.githubusercontent.com/您的用户名/仓库名/main/universal_script.lua", -- 通用脚本URL
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

-- 主加载流程 (已修改，加入通用逻辑)
local function MainLoader()
    -- ... (等待游戏和角色加载的代码保持不变) ...

    local placeId = game.PlaceId
    local scriptConfig = scriptMap[placeId] -- 原有的专用脚本配置
    
    -- 新增：检查是否在黑名单中
    local isBlacklisted = false
    for _, blackId in ipairs(UniversalConfig.Blacklist) do
        if placeId == blackId then
            isBlacklisted = true
            print("[Loader] 当前游戏(" .. placeId .. ")在黑名单中，跳过所有脚本加载。")
            break
        end
    end
    if isBlacklisted then
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

-- ================ 新增：带重试机制的加载函数 ================
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

-- 延迟启动，避免与其他脚本冲突
task.wait(3)

-- 捕获整个加载过程的错误
local mainSuccess, mainError = pcall(MainLoader)
if not mainSuccess then
    warn("[Loader] 主加载流程发生致命错误: " .. mainError)
end

print("[Loader] 加载器完成运行")

-- ================ 新增：全局控制函数（可选） ================
-- 在游戏控制台中可以调用这些函数来动态控制
_G.ToggleUniversalScript = function(enabled)
    UniversalConfig.Enabled = enabled
    print("[Loader] 通用脚本功能已" .. (enabled and "启用" : "禁用"))
end

_G.LoadUniversalScriptNow = function()
    if UniversalConfig.Enabled then
        print("[Loader] 手动触发加载通用脚本...")
        LoadScriptWithRetry(UniversalConfig.Script, "手动触发-通用")
    else
        warn("[Loader] 通用脚本功能未启用，无法手动加载。")
    end
end
