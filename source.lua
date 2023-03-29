    --[[|||||]   [||||||]   [||]    [|] [|]    [|] [|||||||||] [|||||||]   [||||||] [|||||||||] [||||||]
    [|]    [|] [|]    [|]  [|||]   [|] [|]   [|]  [|]         [|]    [|] [|]    [|]    [|]    [|]    [|]
  [|]        [|]      [|] [||||]  [|] [|]  [|]   [|]         [|]    [|] [|]           [|]   [|]      [|]
 [|]        [|]      [|] [|] [|] [|] [|] [|]    [|||||||||] [|||||||]   [||||||]     [|]   [|]      [|]
[|]        [|]      [|] [|]  [||||] [||||]     [|]         [|]    [|]        [|]    [|]   [|]      [|]
[|]    [|] [|]    [|]  [|]   [|||] [|||]      [|]         [|]    [|] [|]    [|]    [|]    [|]    [|]
[||||||]   [||||||]   [|]    [||] [||]       [|||||||||] [|]    [|]  [||||||] [|||||||||] [|||||]]

local environment = getgenv()
if environment.conversioLoaded then
	return
end
environment.conversioLoaded = true
local function checkCompatibility(paths: string, replacement)
	paths = paths:split()
	local Function
	for Count, Path in paths do
		Path = Path:split(".")
		Function = environment[Path[1]]
		for Depth = 2, #Path do
			if Function then
				Function = Function[Path[Depth]]
			end
		end
		if Function or replacement and Count == #paths then
			for _, NewPathName in paths do
				NewPathName = NewPathName:split(".")
				local NewPath = environment
				for Depth = 1, #NewPathName - 1 do
					if not NewPath[NewPathName[Depth]] then
						NewPath[NewPathName[Depth]] = {}
					end
					NewPath = NewPath[NewPathName[Depth]]
				end
				if not NewPath[NewPathName[#NewPathName]] then
					NewPath[NewPathName[#NewPathName]] = Function or replacement
				end
			end
			break
		end
	end
end
for _, functionNames: string in
	{
		"getsenv,getmenv",
		"getreg,getregistry",
		"getgc,get_gc_objects",
		"getinfo,debug.getinfo",
		"isreadonly,is_readonly",
		"getproto,debug.getproto",
		"getstack,debug.getstack",
		"iscclosure,is_c_closure",
		"setstack,debug.setstack",
		"getprotos,debug.getprotos",
		"consoleinput,rconsoleinput",
		"getcustomasset,getsynasset",
		"isrbxactive,iswindowactive",
		"makereadonly,make_readonly",
		"dumpstring,getscriptbytecode",
		"hookfunction,detour_function",
		"makewriteable,make_writeable",
		"getconnections,get_signal_cons",
		"request,http.request,syn.request",
		"getrawmetatable,debug_getmetatable",
		"getcallingscript,get_calling_script",
		"getloadedmodules,get_loaded_modules",
		"getscriptclosure,get_script_function",
		"getupvalue,getupval,debug.getupvalue",
		"setupvalue,setupval,debug.setupvalue",
		"getnamecallmethod,get_namecall_method",
		"getconstant,getconst,debug.getconstant",
		"is_cached,cache.iscached,syn.is_cached",
		"setconstant,setconst,debug.setconstant",
		"consoleprint,writeconsole,rconsoleprint",
		"getupvalues,getupvals,debug.getupvalues",
		"queue_on_teleport,syn.queue_on_teleport",
		"WebSocket.connect,syn.websocket.connect",
		"crypt.hash,syn.crypt.hash,syn.crypto.hash",
		"getconstants,getconsts,debug.getconstants",
		"consolecreate,createconsole,rconsolecreate",
		"closeconsole,consoledestroy,rconsoledestroy",
		"unprotectgui,unprotect_gui,syn.unprotect_gui",
		"cache_replace,cache.replace,syn.cache_replace",
		"rconsolename,consolesettitle,rconsolesettitle",
		"cache_invalidate,cache.invalidate,syn.cache_invalidate",
		"crypt.generatebytes,syn.crypt.random,syn.crypto.random",
		"crypt.hash,syn.crypt.custom.hash,syn.crypto.custom.cash",
		"decrypt,crypt.decrypt,syn.crypt.decrypt,syn.crypto.decrypt",
		"encrypt,crypt.encrypt,syn.crypt.encrypt,syn.crypto.encrypt",
		"crypt.custom_encrypt,syn.crypt.custom.encrypt,syn.crypto.custom.encrypt",
		"crypt.custom_decrypt,syn.crypt.custom.decrypt,syn.crypto.custom.decrypt",
		"base64encode,crypt.base64encode,syn.crypt.base64.encode,syn.crypto.base64.encode",
		"base64decode,crypt.base64decode,syn.crypt.base64.decode,syn.crypto.base64.decode",
		"getidentity,getthreadcontext,getthreadidentity,get_thread_identity,syn.get_thread_identity",
		"setidentity,setthreadcontext,setthreadidentity,set_thread_identity,syn.set_thread_identity",
		"setclipboard,writeclipboard,write_clipboard,toclipboard,set_clipboard,Clipboard.set,syn.write_clipboard",
		"checkclosure,istempleclosure,issentinelclosure,iselectronfunction,is_synapse_function,is_protosmasher_closure",
	}
do
	checkCompatibility(functionNames)
end
--- @diagnostic disable: undefined-global
for paths: string, replacement: ((...any) -> ...any) | number in
	{
		["protectgui,protect_gui,syn.protect_gui"] = function() end,
		setreadonly = makewriteable and function(table, readOnly)
			(readOnly and makereadonly or makewriteable)(table)
		end or 0,
		hookmetamethod = hookfunction
				and getrawmetatable
				and function(object, method: string, hook: (...any) -> ...any)
					return hookfunction(getrawmetatable(object)[method], hook)
				end
			or 0,
		setparentinternal = protectgui and function(object: Instance, parent: Instance?)
			protectgui(object)
			object.Parent = parent
		end or 0,
		["gethui,get_hidden_gui"] = protectgui and (function()
			local hiddenGui = Instance.new("Folder")
			protectgui(hiddenGui)
			hiddenGui.Parent = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
			return function()
				return hiddenGui
			end
		end)() or function()
			return cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
		end,
		["islclosure,is_l_closure"] = iscclosure and function(closure)
			return not iscclosure(closure)
		end or 0,
		cloneref = getreg and (function()
			local testPart = Instance.new("Part")
			local instanceList
			for _, instanceTable in getreg() do
				if type(instanceTable) == "table" and #instanceTable then
					if rawget(instanceTable, "__mode") == "kvs" then
						for _, partCheck in instanceTable do
							if partCheck == testPart then
								instanceList = instanceTable
								pcall(game.Destroy, testPart)
								break
							end
						end
					end
				end
			end
			if instanceList then
				return function(object: Instance): Instance
					for index, value in instanceList do
						if value == object then
							instanceList[index] = nil
							return object
						end
					end
				end
			end
		end)() or 0,
		["consoleclear,rconsoleclear"] = consoleprint and function()
			consoleprint(("\b"):rep(1e6))
		end or 0,
	}
do
	checkCompatibility(paths, if type(replacement) == "function" then replacement else nil)
end
--- @diagnostic enable: undefined-global
