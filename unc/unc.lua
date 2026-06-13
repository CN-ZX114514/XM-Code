local passes, fails, undefined = 0, 0, 0
local running = 0

local function getGlobal(path)
	local value = getgenv and getgenv() or getfenv(2)

	while value ~= nil and path ~= "" do
		local name, nextValue = string.match(path, "^([^.]+)%.?(.*)$")
		value = value[name]
		path = nextValue
	end

	return value
end

local function test(name, aliases, callback, target)
	running = running + 1

	task.spawn(function()
		if not callback then
			print("⏺️ " .. name)
		elseif not getGlobal(name) then
			fails = fails + 1
			warn("⛔ " .. name)
		else
			local success, message = pcall(callback)
	        name = tostring(name)
			message = tostring(message)
			if success then
				passes = passes + 1
				print("✅ " .. tostring(name) .. (tostring(message) and " • " .. tostring(message) or ""))
			else
				fails = fails + 1
				warn("⛔ " .. name .. " 失败: " .. message)
			end
		end
	
		local undefinedAliases = {}
	
		for _, alias in ipairs(aliases) do
			if getGlobal(alias) == nil then
				table.insert(undefinedAliases, alias)
			end
		end
	
		if #undefinedAliases > 0 then
			undefined = undefined + 1
			warn("⚠️ " .. table.concat(undefinedAliases, ", "))
		end

		running = running - 1
	end)
end

-- 头部和摘要

print("\n")

print("UNC 环境检查")
print("✅ - 通过, ⛔ - 失败, ⏺️ - 无测试, ⚠️ - 缺少别名\n")

task.defer(function()
	repeat task.wait() until running == 0

	local rate = math.round(passes / (passes + fails) * 100)
	local outOf = passes .. " / " .. (passes + fails)

	-- 评级判断
	local rating
	if rate >= 80 then
		rating = "良好"
	elseif rate >= 30 then
		rating = "中等"
	else
		rating = "不建议继续使用"
	end

	print("\n")

	print("UNC 摘要")
	print("✅ 成功率 " .. rate .. "% （" .. outOf .. "）")
	print("⭐ 评级: " .. rating)
	print("⛔ " .. fails .. " 项测试失败")
	print("⚠️ " .. undefined .. " 个全局变量缺少别名")
end)

-- 以下为原测试内容（略，与之前汉化版一致）
-- ... 所有测试用例保持不变 ...

-- 缓存

test("cache.invalidate", {}, function()
	local container = Instance.new("Folder")
	local part = Instance.new("Part", container)
	cache.invalidate(container:FindFirstChild("Part"))
	assert(part ~= container:FindFirstChild("Part"), "引用 `part` 无法失效")
end)

test("cache.iscached", {}, function()
	local part = Instance.new("Part")
	assert(cache.iscached(part), "Part 应该被缓存")
	cache.invalidate(part)
	assert(not cache.iscached(part), "Part 不应该再被缓存")
end)

test("cache.replace", {}, function()
	local part = Instance.new("Part")
	local fire = Instance.new("Fire")
	cache.replace(part, fire)
	assert(part ~= fire, "Part 没有被替换为 Fire")
end)

test("cloneref", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "克隆不应该等于原始对象")
	clone.Name = "Test"
	assert(part.Name == "Test", "克隆应该更新了原始对象的名称")
end)

test("compareinstances", {}, function()
	local part = Instance.new("Part")
	local clone = cloneref(part)
	assert(part ~= clone, "克隆不应该等于原始对象")
	assert(compareinstances(part, clone), "使用 compareinstances() 时克隆应等于原始对象")
end)

-- 闭包

local function shallowEqual(t1, t2)
	if t1 == t2 then
		return true
	end

	local UNIQUE_TYPES = {
		["function"] = true,
		["table"] = true,
		["userdata"] = true,
		["thread"] = true,
	}

	for k, v in pairs(t1) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t2[k] ~= v then
			return false
		end
	end

	for k, v in pairs(t2) do
		if UNIQUE_TYPES[type(v)] then
			if type(t2[k]) ~= type(v) then
				return false
			end
		elseif t1[k] ~= v then
			return false
		end
	end

	return true
end

test("checkcaller", {}, function()
	assert(checkcaller(), "主作用域应返回 true")
end)

test("clonefunction", {}, function()
	local function test()
		return "成功"
	end
	local copy = clonefunction(test)
	assert(test() == copy(), "克隆应返回与原始相同的值")
	assert(test ~= copy, "克隆不应等于原始")
end)

test("getcallingscript", {})

test("getscriptclosure", {"getscriptfunction"}, function()
	local module = game:GetService("CoreGui").RobloxGui.Modules.Common.Constants
	local constants = getrenv().require(module)
	local generated = getscriptclosure(module)()
	assert(constants ~= generated, "生成的模块不应匹配原始")
	assert(shallowEqual(constants, generated), "生成的常量表应与原始浅相等")
end)

test("hookfunction", {"replaceclosure"}, function()
	local function test()
		return true
	end
	local ref = hookfunction(test, function()
		return false
	end)
	assert(test() == false, "函数应返回 false")
	assert(ref() == true, "原始函数应返回 true")
	assert(test ~= ref, "原始函数不应与引用相同")
end)

test("iscclosure", {}, function()
	assert(iscclosure(print) == true, "函数 'print' 应为 C 闭包")
	assert(iscclosure(function() end) == false, "执行器函数不应为 C 闭包")
end)

test("islclosure", {}, function()
	assert(islclosure(print) == false, "函数 'print' 不应为 Lua 闭包")
	assert(islclosure(function() end) == true, "执行器函数应为 Lua 闭包")
end)

test("isexecutorclosure", {"checkclosure", "isourclosure"}, function()
	assert(isexecutorclosure(isexecutorclosure) == true, "未对执行器全局变量返回 true")
	assert(isexecutorclosure(newcclosure(function() end)) == true, "未对执行器 C 闭包返回 true")
	assert(isexecutorclosure(function() end) == true, "未对执行器 Luau 闭包返回 true")
	assert(isexecutorclosure(print) == false, "未对 Roblox 全局变量返回 false")
end)

test("loadstring", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	local func = loadstring(bytecode)
	assert(type(func) ~= "function", "Luau 字节码不应可加载！")
	assert(assert(loadstring("return ... + 1"))(1) == 2, "简单数学运算失败")
	assert(type(select(2, loadstring("f"))) == "string", "loadstring 对于编译错误未返回任何内容")
end)

test("newcclosure", {}, function()
	local function test()
		return true
	end
	local testC = newcclosure(test)
	assert(test() == testC(), "新 C 闭包应返回与原始相同的值")
	assert(test ~= testC, "新 C 闭包不应与原始相同")
	assert(iscclosure(testC), "新 C 闭包应为 C 闭包")
end)

-- 控制台

test("rconsoleclear", {"consoleclear"})

test("rconsolecreate", {"consolecreate"})

test("rconsoledestroy", {"consoledestroy"})

test("rconsoleinput", {"consoleinput"})

test("rconsoleprint", {"consoleprint"})

test("rconsolesettitle", {"rconsolename", "consolesettitle"})

-- 加密

test("crypt.base64encode", {"crypt.base64.encode", "crypt.base64_encode", "base64.encode", "base64_encode"}, function()
	assert(crypt.base64encode("test") == "dGVzdA==", "Base64 编码失败")
end)

test("crypt.base64decode", {"crypt.base64.decode", "crypt.base64_decode", "base64.decode", "base64_decode"}, function()
	assert(crypt.base64decode("dGVzdA==") == "test", "Base64 解码失败")
end)

test("crypt.encrypt", {}, function()
	local key = crypt.generatekey()
	local encrypted, iv = crypt.encrypt("test", key, nil, "CBC")
	assert(iv, "crypt.encrypt 应返回 IV")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "从加密数据解密原始字符串失败")
end)

test("crypt.decrypt", {}, function()
	local key, iv = crypt.generatekey(), crypt.generatekey()
	local encrypted = crypt.encrypt("test", key, iv, "CBC")
	local decrypted = crypt.decrypt(encrypted, key, iv, "CBC")
	assert(decrypted == "test", "从加密数据解密原始字符串失败")
end)

test("crypt.generatebytes", {}, function()
	local size = math.random(10, 100)
	local bytes = crypt.generatebytes(size)
	assert(#crypt.base64decode(bytes) == size, "解码结果应为 " .. size .. " 字节（解码后得到 " .. #crypt.base64decode(bytes) .. "，原始 " .. #bytes .. "）")
end)

test("crypt.generatekey", {}, function()
	local key = crypt.generatekey()
	assert(#crypt.base64decode(key) == 32, "生成的密钥解码后应为 32 字节")
end)

test("crypt.hash", {}, function()
	local algorithms = {'sha1', 'sha384', 'sha512', 'md5', 'sha256', 'sha3-224', 'sha3-256', 'sha3-512'}
	for _, algorithm in ipairs(algorithms) do
		local hash = crypt.hash("test", algorithm)
		assert(hash, "crypt.hash 算法 '" .. algorithm .. "' 应返回哈希值")
	end
end)

--- 调试

test("debug.getconstant", {}, function()
	local function test()
		print("你好，世界！")
	end
	assert(debug.getconstant(test, 1) == "print", "第一个常量必须是 print")
	assert(debug.getconstant(test, 2) == nil, "第二个常量必须是 nil")
	assert(debug.getconstant(test, 3) == "你好，世界！", "第三个常量必须是 '你好，世界！'")
end)

test("debug.getconstants", {}, function()
	local function test()
		local num = 5000 .. 50000
		print("你好，世界！", num, warn)
	end
	local constants = debug.getconstants(test)
	assert(constants[1] == 50000, "第一个常量必须是 50000")
	assert(constants[2] == "print", "第二个常量必须是 print")
	assert(constants[3] == nil, "第三个常量必须是 nil")
	assert(constants[4] == "你好，世界！", "第四个常量必须是 '你好，世界！'")
	assert(constants[5] == "warn", "第五个常量必须是 warn")
end)

test("debug.getinfo", {}, function()
	local types = {
		source = "string",
		short_src = "string",
		func = "function",
		what = "string",
		currentline = "number",
		name = "string",
		nups = "number",
		numparams = "number",
		is_vararg = "number",
	}
	local function test(...)
		print(...)
	end
	local info = debug.getinfo(test)
	for k, v in pairs(types) do
		assert(info[k] ~= nil, "未返回包含 '" .. k .. "' 字段的表")
		assert(type(info[k]) == v, "未返回 " .. k .. " 为 " .. v .. " 类型的表（实际类型 " .. type(info[k]) .. "）")
	end
end)

test("debug.getproto", {}, function()
	local function test()
		local function proto()
			return true
		end
	end
	local proto = debug.getproto(test, 1, true)[1]
	local realproto = debug.getproto(test, 1)
	assert(proto, "获取内部函数失败")
	assert(proto() == true, "内部函数未返回任何值")
	if not realproto() then
		return "此执行器上禁用了原型返回值"
	end
end)

test("debug.getprotos", {}, function()
	local function test()
		local function _1()
			return true
		end
		local function _2()
			return true
		end
		local function _3()
			return true
		end
	end
	for i in ipairs(debug.getprotos(test)) do
		local proto = debug.getproto(test, i, true)[1]
		local realproto = debug.getproto(test, i)
		assert(proto(), "获取内部函数 " .. i .. " 失败")
		if not realproto() then
			return "此执行器上禁用了原型返回值"
		end
	end
end)

test("debug.getstack", {}, function()
	local _ = "a" .. "b"
	assert(debug.getstack(1, 1) == "ab", "栈中第一项应为 'ab'")
	assert(debug.getstack(1)[1] == "ab", "栈表中第一项应为 'ab'")
end)

test("debug.getupvalue", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	assert(debug.getupvalue(test, 1) == upvalue, "debug.getupvalue 返回意外的值")
end)

test("debug.getupvalues", {}, function()
	local upvalue = function() end
	local function test()
		print(upvalue)
	end
	local upvalues = debug.getupvalues(test)
	assert(upvalues[1] == upvalue, "debug.getupvalues 返回意外的值")
end)

test("debug.setconstant", {}, function()
	local function test()
		return "失败"
	end
	debug.setconstant(test, 1, "成功")
	assert(test() == "成功", "debug.setconstant 未设置第一个常量")
end)

test("debug.setstack", {}, function()
	local function test()
		return "失败", debug.setstack(1, 1, "成功")
	end
	assert(test() == "成功", "debug.setstack 未设置第一个栈项")
end)

test("debug.setupvalue", {}, function()
	local function upvalue()
		return "失败"
	end
	local function test()
		return upvalue()
	end
	debug.setupvalue(test, 1, function()
		return "成功"
	end)
	assert(test() == "成功", "debug.setupvalue 未设置第一个上值")
end)

-- 文件系统

if isfolder and makefolder and delfolder then
	if isfolder(".tests") then
		delfolder(".tests")
	end
	makefolder(".tests")
end

test("readfile", {}, function()
	writefile(".tests/readfile.txt", "成功")
	assert(readfile(".tests/readfile.txt") == "成功", "未返回文件内容")
end)

test("listfiles", {}, function()
	makefolder(".tests/listfiles")
	writefile(".tests/listfiles/test_1.txt", "成功")
	writefile(".tests/listfiles/test_2.txt", "成功")
	local files = listfiles(".tests/listfiles")
	assert(#files == 2, "未返回正确的文件数量")
	assert(isfile(files[1]), "未返回文件路径")
	assert(readfile(files[1]) == "成功", "未返回正确的文件")
	makefolder(".tests/listfiles_2")
	makefolder(".tests/listfiles_2/test_1")
	makefolder(".tests/listfiles_2/test_2")
	local folders = listfiles(".tests/listfiles_2")
	assert(#folders == 2, "未返回正确的文件夹数量")
	assert(isfolder(folders[1]), "未返回文件夹路径")
end)

test("writefile", {}, function()
	writefile(".tests/writefile.txt", "成功")
	assert(readfile(".tests/writefile.txt") == "成功", "未写入文件")
	local requiresFileExt = pcall(function()
		writefile(".tests/writefile", "成功")
		assert(isfile(".tests/writefile.txt"))
	end)
	if not requiresFileExt then
		return "此执行器要求 writefile 带有文件扩展名"
	end
end)

test("makefolder", {}, function()
	makefolder(".tests/makefolder")
	assert(isfolder(".tests/makefolder"), "未创建文件夹")
end)

test("appendfile", {}, function()
	writefile(".tests/appendfile.txt", "成")
	appendfile(".tests/appendfile.txt", "功")
	appendfile(".tests/appendfile.txt", "！")
	assert(readfile(".tests/appendfile.txt") == "成功！", "未追加文件")
end)

test("isfile", {}, function()
	writefile(".tests/isfile.txt", "成功")
	assert(isfile(".tests/isfile.txt") == true, "未对文件返回 true")
	assert(isfile(".tests") == false, "未对文件夹返回 false")
	assert(isfile(".tests/不存在.exe") == false, "未对不存在的路径返回 false（得到 " .. tostring(isfile(".tests/不存在.exe")) .. "）")
end)

test("isfolder", {}, function()
	assert(isfolder(".tests") == true, "未对文件夹返回 true")
	assert(isfolder(".tests/不存在.exe") == false, "未对不存在的路径返回 false（得到 " .. tostring(isfolder(".tests/不存在.exe")) .. "）")
end)

test("delfolder", {}, function()
	makefolder(".tests/delfolder")
	delfolder(".tests/delfolder")
	assert(isfolder(".tests/delfolder") == false, "删除文件夹失败（isfolder = " .. tostring(isfolder(".tests/delfolder")) .. "）")
end)

test("delfile", {}, function()
	writefile(".tests/delfile.txt", "你好，世界！")
	delfile(".tests/delfile.txt")
	assert(isfile(".tests/delfile.txt") == false, "删除文件失败（isfile = " .. tostring(isfile(".tests/delfile.txt")) .. "）")
end)

test("dofile", {})

-- 输入

test("isrbxactive", {"isgameactive"}, function()
	assert(type(isrbxactive()) == "boolean", "未返回布尔值")
end)

test("mouse1click", {})

test("mouse1press", {})

test("mouse1release", {})

test("mouse2click", {})

test("mouse2press", {})

test("mouse2release", {})

test("mousemoveabs", {})

test("mousemoverel", {})

test("mousescroll", {})

-- 实例

test("fireclickdetector", {}, function()
	local detector = Instance.new("ClickDetector")
	fireclickdetector(detector, 50, "MouseHoverEnter")
end)

test("getcallbackvalue", {}, function()
	local bindable = Instance.new("BindableFunction")
	local function test()
	end
	bindable.OnInvoke = test
	assert(getcallbackvalue(bindable, "OnInvoke") == test, "未返回正确的值")
end)

test("getconnections", {}, function()
	local types = {
		Enabled = "boolean",
		ForeignState = "boolean",
		LuaConnection = "boolean",
		Function = "function",
		Thread = "thread",
		Fire = "function",
		Defer = "function",
		Disconnect = "function",
		Disable = "function",
		Enable = "function",
	}
	local bindable = Instance.new("BindableEvent")
	bindable.Event:Connect(function() end)
	local connection = getconnections(bindable.Event)[1]
	for k, v in pairs(types) do
		assert(connection[k] ~= nil, "未返回包含 '" .. k .. "' 字段的表")
		assert(type(connection[k]) == v, "未返回 " .. k .. " 为 " .. v .. " 类型的表（实际类型 " .. type(connection[k]) .. "）")
	end
end)

test("getcustomasset", {}, function()
	writefile(".tests/getcustomasset.txt", "成功")
	local contentId = getcustomasset(".tests/getcustomasset.txt")
	assert(type(contentId) == "string", "未返回字符串")
	assert(#contentId > 0, "返回了空字符串")
	assert(string.match(contentId, "rbxasset://") == "rbxasset://", "未返回 rbxasset URL")
end)

test("gethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local property, isHidden = gethiddenproperty(fire, "size_xml")
	assert(property == 5, "未返回正确的值")
	assert(isHidden == true, "未返回属性是否隐藏")
end)

test("sethiddenproperty", {}, function()
	local fire = Instance.new("Fire")
	local hidden = sethiddenproperty(fire, "size_xml", 10)
	assert(hidden, "未对隐藏属性返回 true")
	assert(gethiddenproperty(fire, "size_xml") == 10, "未设置隐藏属性")
end)

test("gethui", {}, function()
	assert(typeof(gethui()) == "Instance", "未返回 Instance")
end)

test("getinstances", {}, function()
	assert(getinstances()[1]:IsA("Instance"), "第一个值不是 Instance")
end)

test("getnilinstances", {}, function()
	assert(getnilinstances()[1]:IsA("Instance"), "第一个值不是 Instance")
	assert(getnilinstances()[1].Parent == nil, "第一个值的父级不为 nil")
end)

test("isscriptable", {}, function()
	local fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "未对不可脚本化的属性（size_xml）返回 false")
	assert(isscriptable(fire, "Size") == true, "未对可脚本化的属性（Size）返回 true")
end)

test("setscriptable", {}, function()
	local fire = Instance.new("Fire")
	local wasScriptable = setscriptable(fire, "size_xml", true)
	assert(wasScriptable == false, "未对不可脚本化的属性（size_xml）返回 false")
	assert(isscriptable(fire, "size_xml") == true, "未设置可脚本化属性")
	fire = Instance.new("Fire")
	assert(isscriptable(fire, "size_xml") == false, "⚠️⚠️ setscriptable 在不同实例间持久化 ⚠️⚠️")
end)

test("setrbxclipboard", {})

-- 元表

test("getrawmetatable", {}, function()
	local metatable = { __metatable = "锁定！" }
	local object = setmetatable({}, metatable)
	assert(getrawmetatable(object) == metatable, "未返回元表")
end)

test("hookmetamethod", {}, function()
	local object = setmetatable({}, { __index = newcclosure(function() return false end), __metatable = "锁定！" })
	local ref = hookmetamethod(object, "__index", function() return true end)
	assert(object.test == true, "钩取元方法并更改返回值失败")
	assert(ref() == false, "未返回原始函数")
end)

test("getnamecallmethod", {}, function()
	local method
	local ref
	ref = hookmetamethod(game, "__namecall", function(...)
		if not method then
			method = getnamecallmethod()
		end
		return ref(...)
	end)
	game:GetService("Lighting")
	assert(method == "GetService", "未获取到正确的方法（GetService）")
end)

test("isreadonly", {}, function()
	local object = {}
	table.freeze(object)
	assert(isreadonly(object), "未对只读表返回 true")
end)

test("setrawmetatable", {}, function()
	local object = setmetatable({}, { __index = function() return false end, __metatable = "锁定！" })
	local objectReturned = setrawmetatable(object, { __index = function() return true end })
	assert(object, "未返回原始对象")
	assert(object.test == true, "更改元表失败")
	if objectReturned then
		return objectReturned == object and "返回了原始对象" or "未返回原始对象"
	end
end)

test("setreadonly", {}, function()
	local object = { success = false }
	table.freeze(object)
	setreadonly(object, false)
	object.success = true
	assert(object.success, "不允许修改表")
end)

-- 杂项

test("identifyexecutor", {"getexecutorname"}, function()
	local name, version = identifyexecutor()
	assert(type(name) == "string", "未返回字符串形式的名称")
	return type(version) == "string" and "返回版本为字符串" or "未返回版本"
end)

test("lz4compress", {}, function()
	local raw = "你好，世界！"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "压缩未返回字符串")
	assert(lz4decompress(compressed, #raw) == raw, "解压未返回原始字符串")
end)

test("lz4decompress", {}, function()
	local raw = "你好，世界！"
	local compressed = lz4compress(raw)
	assert(type(compressed) == "string", "压缩未返回字符串")
	assert(lz4decompress(compressed, #raw) == raw, "解压未返回原始字符串")
end)

test("messagebox", {})

test("queue_on_teleport", {"queueonteleport"})

test("request", {"http.request", "http_request"}, function()
	local response = request({
		Url = "https://httpbin.org/user-agent",
		Method = "GET",
	})
	assert(type(response) == "table", "响应必须是一个表")
	assert(response.StatusCode == 200, "未返回 200 状态码")
	local data = game:GetService("HttpService"):JSONDecode(response.Body)
	assert(type(data) == "table" and type(data["user-agent"]) == "string", "未返回包含 user-agent 键的表")
	return "User-Agent: " .. data["user-agent"]
end)

test("setclipboard", {"toclipboard"})

test("setfpscap", {}, function()
	local renderStepped = game:GetService("RunService").RenderStepped
	local function step()
		renderStepped:Wait()
		local sum = 0
		for _ = 1, 5 do
			sum = sum + 1 / renderStepped:Wait()
		end
		return math.round(sum / 5)
	end
	setfpscap(60)
	local step60 = step()
	setfpscap(0)
	local step0 = step()
	return step60 .. "fps @60 • " .. step0 .. "fps @0"
end)

-- 脚本

test("getgc", {}, function()
	local gc = getgc()
	assert(type(gc) == "table", "未返回表")
	assert(#gc > 0, "未返回包含任何值的表")
end)

test("getgenv", {}, function()
	getgenv().__TEST_GLOBAL = true
	assert(__TEST_GLOBAL, "设置全局变量失败")
	getgenv().__TEST_GLOBAL = nil
end)

test("getloadedmodules", {}, function()
	local modules = getloadedmodules()
	assert(type(modules) == "table", "未返回表")
	assert(#modules > 0, "未返回包含任何值的表")
	assert(typeof(modules[1]) == "Instance", "第一个值不是 Instance")
	assert(modules[1]:IsA("ModuleScript"), "第一个值不是 ModuleScript")
end)

test("getrenv", {}, function()
	assert(_G ~= getrenv()._G, "执行器中的 _G 与游戏中的 _G 相同")
end)

test("getrunningscripts", {}, function()
	local scripts = getrunningscripts()
	assert(type(scripts) == "table", "未返回表")
	assert(#scripts > 0, "未返回包含任何值的表")
	assert(typeof(scripts[1]) == "Instance", "第一个值不是 Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "第一个值不是 ModuleScript 或 LocalScript")
end)

test("getscriptbytecode", {"dumpstring"}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local bytecode = getscriptbytecode(animate)
	assert(type(bytecode) == "string", "未返回字符串形式的 Character.Animate（类型 " .. animate.ClassName .. "）")
end)

test("getscripthash", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate:Clone()
	local hash = getscripthash(animate)
	local source = animate.Source
	animate.Source = "print('你好，世界！')"
	task.defer(function()
		animate.Source = source
	end)
	local newHash = getscripthash(animate)
	assert(hash ~= newHash, "修改后的脚本未返回不同的哈希值")
	assert(newHash == getscripthash(animate), "具有相同源码的脚本未返回相同的哈希值")
end)

test("getscripts", {}, function()
	local scripts = getscripts()
	assert(type(scripts) == "table", "未返回表")
	assert(#scripts > 0, "未返回包含任何值的表")
	assert(typeof(scripts[1]) == "Instance", "第一个值不是 Instance")
	assert(scripts[1]:IsA("ModuleScript") or scripts[1]:IsA("LocalScript"), "第一个值不是 ModuleScript 或 LocalScript")
end)

test("getsenv", {}, function()
	local animate = game:GetService("Players").LocalPlayer.Character.Animate
	local env = getsenv(animate)
	assert(type(env) == "table", "未返回 Character.Animate 的环境表（类型 " .. animate.ClassName .. "）")
	assert(env.script == animate, "脚本全局变量与 Character.Animate 不相同")
end)

test("getthreadidentity", {"getidentity", "getthreadcontext"}, function()
	assert(type(getthreadidentity()) == "number", "未返回数字")
end)

test("setthreadidentity", {"setidentity", "setthreadcontext"}, function()
	setthreadidentity(3)
	assert(getthreadidentity() == 3, "未设置线程标识")
end)

-- 绘图

test("Drawing", {})

test("Drawing.new", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = false
	local canDestroy = pcall(function()
		drawing:Destroy()
	end)
	assert(canDestroy, "Drawing:Destroy() 不应抛出错误")
end)

test("Drawing.Fonts", {}, function()
	assert(Drawing.Fonts.UI == 0, "未返回 UI 的正确 ID")
	assert(Drawing.Fonts.System == 1, "未返回 System 的正确 ID")
	assert(Drawing.Fonts.Plex == 2, "未返回 Plex 的正确 ID")
	assert(Drawing.Fonts.Monospace == 3, "未返回 Monospace 的正确 ID")
end)

test("isrenderobj", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(isrenderobj(drawing) == true, "未对 Image 返回 true")
	assert(isrenderobj(newproxy()) == false, "未对空白表返回 false")
end)

test("getrenderproperty", {}, function()
	local drawing = Drawing.new("Image")
	drawing.Visible = true
	assert(type(getrenderproperty(drawing, "Visible")) == "boolean", "未对 Image.Visible 返回布尔值")
	local success, result = pcall(function()
		return getrenderproperty(drawing, "Color")
	end)
	if not success or not result then
		return "不支持 Image.Color"
	end
end)

test("setrenderproperty", {}, function()
	local drawing = Drawing.new("Square")
	drawing.Visible = true
	setrenderproperty(drawing, "Visible", false)
	assert(drawing.Visible == false, "未设置 Square.Visible 的值")
end)

test("cleardrawcache", {}, function()
	cleardrawcache()
end)

-- WebSocket

test("WebSocket", {})

test("WebSocket.connect", {}, function()
	local types = {
		Send = "function",
		Close = "function",
		OnMessage = {"table", "userdata"},
		OnClose = {"table", "userdata"},
	}
	local ws = WebSocket.connect("ws://echo.websocket.events")
	assert(type(ws) == "table" or type(ws) == "userdata", "未返回表或 userdata")
	for k, v in pairs(types) do
		if type(v) == "table" then
			assert(table.find(v, type(ws[k])), "未返回 " .. table.concat(v, ", ") .. " 类型的 " .. k .. "（实际类型 " .. type(ws[k]) .. "）")
		else
			assert(type(ws[k]) == v, "未返回 " .. v .. " 类型的 " .. k .. "（实际类型 " .. type(ws[k]) .. "）")
		end
	end
	ws:Close()
end)
