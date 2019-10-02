--SJNOS by MC403. web_server.exe (f5Arw7GJ)

local tArgs = {...}
local PART_NAME = 'webserver'
local PART_PATH = 'SJNOS/' .. PART_NAME .. '.exe'
local CODE = 'f5Arw7GJ'

local function start()

if (not os.loadAPI("SJNOS/api/sjn")) then
	error("SJN API missing")
end

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()

local function func_rednet()
	local _, rednetside = sjn.getRednet(true)

	while (rednetside == nil) do
		tcolor(colors.red)
		write("No modem found!")
		tcolor(colors.cyan)
		textutils.slowPrint(" Please put a rednet modem on one side. Press any key to refresh.")
		os.pullEventRaw("key")
		_, rednetside = sjn.getRednet(true)
	end

	return rednetside
end

local function func_dns(needed)
	local dns = {}
	rednet.broadcast("~SJN@SWEBSERVER:GETDNSSERVER")
	sleep(0.1)
	for i=1,10 do
		local id, msg, dis = rednet.receive(0.5)
		if (id~=nil) then
			if (string.find(msg,"~SJN@SWEBDNS:GETDNSSERVER:TRUE#")) then
				local p1, p2 = string.find(msg,"~SJN@SWEBDNS:GETDNSSERVER:TRUE#")
				if (#msg > p2) then
					local info = string.sub(msg, p2+1)
					table.insert(dns,{id=id, msg=msg, info=info})
				end
			end
		end
	end

	if (#dns == 0) then
		tcolor(colors.red)
		print("Failed.")
		if (not needed) then return end
		sleep(1.5)

		tcolor(colors.lightGray)
		print("")
		print("You can setup a DNS-Server yourself:")
		print("1. Run the SJNOS-Installer")
		print("2. Click 'Parts' and install SJNWEB > S-Web > DNS Server")
		print("3. Hit 'DOWNLOAD'")
		print("Now you have a DNS Server!")

		tcolor(colors.yellow)
		print("\nPress any key to reboot.")
		os.pullEventRaw("key")
		os.reboot()
	end

	tcolor(colors.lightGray)
	bcolor(colors.gray)
	cpos(1,1)
	clear()
	print("Avalible DNS-SERVERS:")

	for i=1,#dns do
		cpos(1,i+1)
		tcolor(colors.orange)
		write("  ID ")
		tcolor(colors.lightGray)
		write(dns[i].id)
		write("  ")
		tcolor(colors.orange)
		write("INFO ")
		tcolor(colors.lightGray)
		write(string.sub(dns[i].info,0,30))
	end

	cpos(1,2)
	write(">")

	local solved = false local selected = 1 local maxnr = #dns local xOffset = 0 local yOffset = 1
	while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
	end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
	then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end

	return dns[selected].id
end

local function func_domain(needed, DNS, home, webdir)
	tcolor(colors.yellow)
	if (needed) then tcolor(colors.orange) end
	print("Which Domain would you like to own?")
	tcolor(colors.lightGray)
	print("-Don't use: space ! , \\ # /")
	print("-Please use less than 20 chars.")
	print("-You can add .com or something similar.")
	print("Examples: notch, hello.net, shop.sjnos.com")
	print()

	local domain = nil
	while true do
		tcolor(colors.orange)
		local input = read()
		if (#input == 0) then
			print("Your domain needs at least 1 char.")
			if (not needed) then return end
		elseif (string.find(input," ")) then
			print("Dont use ' '!")
		elseif (string.find(input,",")) then
			print("Dont use ','!")
		elseif (string.find(input,"\\")) then
			print("Dont use '\'!")
		elseif (string.find(input,"!")) then
			print("Dont use '!'!")
		elseif (string.find(input,"#")) then
			print("Dont use '#'!")
		elseif (string.find(input,"/")) then
			print("Dont use '/'!")
		elseif (string.find(input,"@")) then
			print("Dont use '@'!")
		elseif (string.find(input,'~')) then
			print("Dont use '~'!")
		elseif (#input > 20) then
			print("Please use less than or equal to 20 chars.")
		else
			domain = input
			break
		end
	end

	rednet.send(DNS,"~SJN@SWEBSERVER:CONNECTTODNSSERVER#"..domain)

	local timer = os.startTimer(2)
	local result = -1
	while true do
		local event, side, channel, id, msg, dis = os.pullEventRaw()
		if (event=="modem_message") then
			if (id == DNS) then
				if (msg=="~SJN@SWEBDNS:INVALIDDOMAIN") then
					result = 0
					timer = nil
					break
				elseif (msg=="~SJN@SWEBDNS:VALIDDOMAIN") then
					result = 1
					timer = nil
					break
				end
			end
		elseif (event=="timer") then
			break
		end
	end

	if (result == 1) then
		tcolor(colors.lime)
		print("\nCongratulations!\nThe domain '" .. domain .. "' is now yours!")

		local f = fs.open("SJNOS/cfg/server.cfg","w")
		f.writeLine("domain="..domain)
		f.writeLine("dns="..DNS)
		f.writeLine("home="..home)
		f.writeLine("webdirectory="..webdir)
		f.close()
		return domain
	else
		tcolor(colors.red)
		if (result == -1) then
			print("\nThe dns doesn't respond.")
		else
			print("\nThis domain is used by another server or doesn't fit the criteria.")
		end
		if (not needed) then return end
		tcolor(colors.yellow)
		print("")
		textutils.slowPrint("Press any key to reboot.")
		os.pullEventRaw("key")
		os.reboot()
	end
end

if tArgs[1]=="install" then
	fs.delete(PART_PATH)
	fs.delete("startup")
	fs.move("SJNOS/partinstaller.exe",PART_PATH)

	local f = fs.open("startup","w")
	f.writeLine("--Autogenerated Startup by SJNOS")
	if (tArgs[2] == 'via_wfm') then
		local computerToMessage = ' ' .. (tArgs[3] or -1)
		f.writeLine('shell.run("'..PART_PATH..' firstrun via_wfm' ..computerToMessage.. '")')
	elseif (tArgs[2] == 'fast') then
		f.writeLine('shell.run("'..PART_PATH..' firstrun fast")')
	else
		f.writeLine('shell.run("'..PART_PATH..' firstrun")')
	end
	f.close()

	local f = fs.open("SJNOS/.installed","w")
	f.close()
elseif tArgs[1]=="firstrun" then
	fs.delete("SJNOS/.installed")

	tcolor(colors.lightGray)
	bcolor(colors.gray)
	clear()
	cpos(1,1)

	if (tArgs[2] == 'via_wfm') then

	else
		if (tArgs[2] == 'fast') then
			print("Hello, welcome to S-WEB Server!")
		else
			textutils.slowPrint("Hello, welcome to S-WEB Server!")
		end

		print("> Start Setup")
		print("  Deinstall")

		local selected = 1

		local c = true

		while c do
			local event, btn = os.pullEventRaw()
			if (event=="key") then
				if (btn==28) then
					--Enter
					c = false
				elseif (btn==208 or btn==200) then
					--Down or Up
					if (selected==1) then
						selected = 2
					else
						selected = 1
					end
					cpos(1,2)
					print("  Start Setup")
					print("  Deinstall")
					cpos(1,1+selected)
					write(">")
				end
			end
		end

		if (selected==2) then
			--Deinstall
			shell.run(PART_PATH, "deinstall")
			return true
		end

	end

	--Setup
	tcolor(colors.lightGray)
	bcolor(colors.gray)
	clear()
	cpos(1,1)

	func_rednet()

	clear()
	cpos(1,1)

	if (not fs.exists("SJNOS/cfg")) then
		fs.makeDir("SJNOS/cfg")
	end

	if (not fs.exists("SJNOS/cfg/server.cfg")) then
		tcolor(colors.lightGray)
		textutils.slowWrite("Searching for DNS...")
		local DNS = func_dns(true)
		print("")
		func_domain(true, DNS, 'index.stp', 'SJNOS/www')

		local f = fs.open("SJNOS/cfg/.access", "w")
		f.writeLine("webaccess=none")	--webaccess: none all
		f.writeLine("wfmaccess=none")		--wfmaccess: none admin all
	else
		local data = sjn.getConfigFileContent("SJNOS/cfg/server.cfg", '=')
		print("Your DNS is " .. data.dns .. '.')
		print("Your domain is '" .. data.domain .. '\'.')
	end

	if (not fs.exists("SJNOS/cfg/wfm.cfg")) then
		local f = fs.open("SJNOS/cfg/wfm.cfg", "w")
		f.close()
	end

	fs.makeDir("SJNOS/www")

	local f = fs.open("SJNOS/www/index.stp", "w")
	f.writeLine("@public")
	f.writeLine("@doctype=stp")
	f.writeLine("Welcome to this new cool website!")
	f.writeLine()
	f.writeLine("Program with stp your own websites.")
	f.writeLine("Need help? Try the <text=Help#Sides color=orange link=STP:@HELP>")
	f.writeLine("Much fun!")
	f.close()


	local f = fs.open("startup","w")
	f.writeLine("--Autogenerated Startup by SJNOS")
	f.writeLine('shell.run("'..PART_PATH..'")')
	f.close()

	if (tArgs[2] ~= 'via_wfm') then
		tcolor(colors.yellow)
		print("\nPress any key to reboot.")
		os.pullEventRaw("key")
	else
		--Message Computer
		local computerToMessage = ' ' .. (tArgs[3] or -1)
		if (tonumber(tArgs[3]) and tonumber(tArgs[3]) > 0) then
			local d = {["result"]='Updated.'}
			rednet.send(tonumber(tArgs[3]), '~SJN@SWEBSERVER:RESULT#' .. textutils.serialize(d))
		end
	end
	sleep(0.5)
	os.reboot()

elseif (tArgs[1] == 'update') then
	bcolor(colors.gray)
	tcolor(colors.lightGray)
	clear()
	cpos(1, 1)
	print("Updating...")
	sleep(1)
	fs.delete("SJNOS/api/sjn")
	shell.run("pastebin get Ab5cy6F2 SJNOS/api/sjn")
	fs.delete(PART_PATH)
	fs.delete("SJNOS/partinstaller.exe")
	shell.run("pastebin", "get", CODE, "SJNOS/partinstaller.exe")

	if (tArgs[2] == 'via_wfm') then
		local computerToMessage = ' ' .. (tArgs[3] or -1)
		shell.run("SJNOS/partinstaller.exe install via_wfm" .. computerToMessage)
	else
		shell.run("SJNOS/partinstaller.exe install fast")
	end

	tcolor(colors.lime)
	print("\nSuccess! Starting setup...")
	sleep(1.5)
	os.reboot()
	return true
elseif (tArgs[1] == 'deinstall') then
	tcolor(colors.lightGray)
	bcolor(colors.gray)
	clear()
	local function w(text)
		term.scroll(1)
		cpos(1,19)
		write(text)
	end
	w("Starting Deinstallation...")
	sleep(0.5)
	fs.delete("startup")
	fs.delete("SJNOS")
	tcolor(colors.lime)
	w("Success!")
	tcolor(colors.lightGray)
	w("Exiting...")
	w("Goodbye!")
	sleep(2)
	tcolor(colors.white)
	bcolor(colors.black)
	clear()
	cpos(1, 1)
else
	--Normal run
	tcolor(colors.lightGray)
	bcolor(colors.gray)
	clear()
	cpos(1,19)

	local function getText(line)
		return string.sub(line, string.find(line, "=")+1)
	end

	local f = fs.open("SJNOS/cfg/server.cfg","r")
	local DOMAIN = getText(f.readLine())
	local DNS = tonumber(getText(f.readLine()))
	local HOME_PATH = getText(f.readLine())
	local WEB_PATH = getText(f.readLine())
	f.close()

	function getWFM_USERS()
		if (not fs.exists("SJNOS/cfg/wfm.cfg")) then
			local f = fs.open("SJNOS/cfg/wfm.cfg", "w")
			f.close()
		end
		local f = fs.open("SJNOS/cfg/wfm.cfg", "r")
		local contentArray = {}
		local line = "!"
		while (line ~= nil) do
			line = f.readLine()
			contentArray[#contentArray + 1] = line
		end
		f.close()

		local WFM_USERS = {}

		for i=1, #contentArray do
		    local t = {}
		    local j = 1
		    for str in string.gmatch(contentArray[i], "([^"..'#'.."]+)") do
	            t[j] = str
	            j = j + 1
		    end

	    	t[3] = string.sub(t[3], 4) .. "" --Wegen 'C:/', was benötigt wird, da in der Datei nicht zwei '#' nebeneinander sein dürfen

		    if (t[4] == 'true') then
		    	t[4] = true
	    	else
	    		t[4] = false
	    	end

		    WFM_USERS[i] = {["user"]=t[1], ["password"]=t[2], ["dir"]=t[3], ["cmd"]=t[4]}
		end

		return WFM_USERS
	end

	function saveWFM_USERS(WFM_USERS)
		local f = fs.open("SJNOS/cfg/wfm.cfg", "w")
		for i=1, #WFM_USERS do
			local w = WFM_USERS[i]
			local dir = w.dir
			if (dir == '') then
				dir = 'C:/'
			end
			f.writeLine(w.user .. '#' .. w.password .. '#' .. dir .. '#' .. tostring(w.cmd))
		end
		f.close()
	end

	local function wfmLogin(msg, message)
		local p1, p2 = string.find(msg, message .. '#')
		if (#msg > p2 and p1 == 1) then
			local data_raw = string.sub(msg, p2 + 1) .. ''
			if (string.find(data_raw, "#")) then
				local q = string.find(data_raw, '#')
				local user = string.sub(data_raw, 1, q - 1)
				local password = string.sub(data_raw, q + 1)

				if (user ~= '' and password ~= '') then
					local WFM_USERS = getWFM_USERS()
					for i=1, #WFM_USERS do
						if (user == WFM_USERS[i].user and password == WFM_USERS[i].password) then
							return true
						end
					end
				end
			end
		end
		return false
	end

	local function wfmLogin2(msg, cmd)
		local p1, p2 = string.find(msg, '~SJN@WFMCLIENT:' .. cmd .. '#')
		if (p1 and #msg > p2 and p1 == 1) then
			local data_raw = string.sub(msg, p2 + 1)
			local data = textutils.unserialize(data_raw)

			if (data.user and data.password) then
				local WFM_USERS = getWFM_USERS()
				for i=1, #WFM_USERS do
					if (data.user == WFM_USERS[i].user and data.password == WFM_USERS[i].password) then
						return true, WFM_USERS[i], data.data or '', data.data2 or '', data.data3 or ''
					end
				end
			end
		end
		return false
	end

	local function hasWebAccess(path)
		if (fs.exists(path)) then
			if (fs.isDir(path)) then
				if (fs.exists(path .. "/.access") and not fs.isDir(path .. "/.access")) then
					local d = sjn.getConfigFileContent(path .. '/.access')
					if (d.webaccess == 'none') then
						return false
					end
				end
			else
				local place = sjn.getPathContent(path)
				if (fs.exists(place .. "/.access") and not fs.isDir(place .. "/.access")) then
					local d = sjn.getConfigFileContent(place .. '/.access')
					if (d.webaccess == 'none') then
						return false
					end
				end
			end
			return true
		end
		return false
	end

	local function save()
		local f = fs.open("SJNOS/cfg/server.cfg","w")
		f.writeLine("domain="..DOMAIN)
		f.writeLine("dns="..DNS)
		f.writeLine("home="..HOME_PATH)
		f.writeLine("webdirectory="..WEB_PATH)
		f.close()
	end


	local REDNET, REDNET_SIDE = sjn.getRednet(true)
	if (REDNET_SIDE==nil) then
		tcolor(colors.red)
		print("No rednet modem found. Please put a modem on one side of the server!")
		tcolor(colors.yellow)
		print("\n-Press any key to refresh-")
		os.pullEvent("key")
		REDNET, REDNET_SIDE = sjn.getRednet(true)
	end


	tcolor(colors.lightGray)
	print("SJNOS SWEB SERVER #"..os.getComputerID())
	print("Press any key to enter the terminal and enter 'help' for help")
	write("The Server is listening now and writes a message, if something happends.")

	while true do
		local timer = os.startTimer(10)
		local event, side, channel, id, msg, dis = os.pullEventRaw()
		if (event=="key") then
			local o = true
			while o do
				term.scroll(1)
				cpos(1, 19)
				tcolor(colors.orange)
				write("$ ")
				input = read()
				tcolor(colors.lightGray)
				if (input=="help") then
					print("$clear                Clears the screen            ")
					print("$dns                  Shows your current DNS")
					print("$dns change           Changes your current DNS.")
					print("$domain               Shows your current Domain.")
					print("$domain change        Changes your current Domain.  ")
					print("$exit                 Exits the menu               ")
					print("$help                 Shows you some help          ")
					print("$home <PATH>          Sets the home path, called   \n                      when client enters no path")
					print("$update               Update to the newest version.\n                      Your data will be kept.")
					print("$webdir <PATH>        Sets the webdirectory path,  \n                      the folder with your pages")
					print("$wfm                  ($help wfm)")
					write("$cos                  Goes back to CraftOS")
				elseif (input == 'help wfm') then
						print("$wfm list           Lists all WFM users on this PC.")
						print("$wfm add <USER>     Adds a new WFM user.           ")
						print("$wfm change <USER>  Changes the selected WFM user. ")
						write("$wfm remove <USER>  Deletes the selected WFM user. ")
				elseif (input=="clear") then
					clear()
				elseif (input=="exit" or input=="" ) then
					o = false
				elseif (input=="domain") then
					tcolor(colors.lightGray)
					write("Your personal domain is: ")
					tcolor(colors.yellow)
					write(DOMAIN)
					tcolor(colors.lightGray)
					write(".")
				elseif (input == "domain change") then
					local d = func_domain(false, DNS, HOME_PATH, WEB_PATH)
					if (d) then
						DOMAIN = d
					end
				elseif (input=="dns") then
					tcolor(colors.lightGray)
					write("Your connected DNS ID is: ")
					tcolor(colors.yellow)
					write(DNS)
					tcolor(colors.lightGray)
					write(".")
				elseif (input == "dns change") then
					clear()
					cpos(1, 1)
					textutils.slowWrite("Searching...")
					local d = func_dns(false)
					if (d) then
						rednet.send(DNS, "~SJN@SWEBSERVER:DISCONNECT")
						DNS = tonumber(d)
						clear()
						cpos(1, 19)

						tcolor(colors.lime)
						print("Your new DNS is " .. DNS .. ".\n")
						func_domain(true, DNS, HOME_PATH, WEB_PATH)
					end
				elseif (input == "home") then
					tcolor(colors.lightGray)
					write("Your home path for every directory is: ")
					tcolor(colors.yellow)
					write(HOME_PATH)
					tcolor(colors.lightGray)
					write(".")
				elseif (string.find(input, "home ")) then
					local p1, p2 = string.find(input,"home ")
					local path = string.sub(input,p2+1)
					local full_path = WEB_PATH .. "/" .. path
					if ((not fs.exists(full_path)) and (not fs.isDir(full_path))) then
						tcolor(colors.red)
						write("Target doesn't exist or is a directory!")
					else
						tcolor(colors.lightGray)
						write("Your new home path for every directory is: ")
						tcolor(colors.yellow)
						write(path)
						tcolor(colors.lightGray)
						write(".")

						HOME_PATH = path
						save()
					end
				elseif (input == 'update') then
					shell.run(PART_PATH, "update")
					return true
				elseif (input == "webdir") then
					tcolor(colors.lightGray)
					write("Your web directory path is: ")
					tcolor(colors.yellow)
					write(WEB_PATH)
					tcolor(colors.lightGray)
					write(".")
				elseif (string.find(input, "webdir ")) then
					local p1, p2 = string.find(input,"webdir ")
					local path = string.sub(input,p2+1)
					if ((not fs.exists(path)) and fs.isDir(path)) then
						tcolor(colors.red)
						write("Target doesn't exist or is not a directory!")
					else
						tcolor(colors.lightGray)
						write("Your new web directory path is: ")
						tcolor(colors.yellow)
						write(path)
						tcolor(colors.lightGray)
						write(".")

						WEB_PATH = path
						save()
					end
				elseif(string.find(input, 'wfm')) then
					if (string.find(input, 'wfm list')) then
						local WFM_USERS = getWFM_USERS()
						for i=1, #WFM_USERS do
							print(WFM_USERS[i].user)
						end
						write(#WFM_USERS .. ' users in total.')
					elseif (string.find(input, 'wfm add')) then
						local _, p = string.find(input, 'wfm add')
						if (#input > p + 1) then
							local user = string.sub(input, p + 2) .. ""

							local exist = false

							local WFM_USERS = getWFM_USERS()
							for i=1, #WFM_USERS do
								if (WFM_USERS[i].user == user) then
									exist = true
									break
								end
							end

							if (not exist) then
								if (string.find(user, '#') == nil and string.find(user, '/') == nil) then
									write("Password:  ")
									local password = read('*')
									if (string.find(password, '#') == nil and password ~= '') then
										write("Directory: C:/")
										local dir = read()
										if (string.find(password, '#') == nil) then
											dir = 'C:/' .. dir

											write("Admin (y): ")
											local i = read('*')
											local cmd = false
											if (i == 'y') then
												cmd = true
											end

											table.insert(WFM_USERS, {["user"]=user, ["password"]=password, ["dir"]=dir, ["cmd"]=cmd})
											saveWFM_USERS(WFM_USERS)

											tcolor(colors.lime)
											write("User '" .. user .. "' created.")
										else
											tcolor(colors.red)
											write("Please use a directory without '#'.")
										end
									else
										tcolor(colors.red)
										write("Please use a password without '#'.")
									end
								else
									tcolor(colors.red)
									write("Please use a name without '#' and '/'.")
								end
							else
								tcolor(colors.red)
								write("Username already exists!")
							end
						else
							tcolor(colors.red)
							write("Usage: $wfm add <USER>")
						end
					elseif (string.find(input, 'wfm change')) then
						local _, p = string.find(input, 'wfm change')
						if (#input > p + 1) then
							local u = string.sub(input, p + 2) .. ""

							local id = -1
							local WFM_USERS = getWFM_USERS()
							for i=1, #WFM_USERS do
								if (WFM_USERS[i].user == u) then
									id = i
									break
								end
							end

							if (id ~= -1) then
								write("Username:  ")
								local user = read()
								if (string.find(user, '#') == nil and string.find(user, '/') == nil) then
									write("Password:  ")
									local password = read('*')
									if (string.find(password, '#') == nil and password ~= '') then
										write("Directory: C:/")
										local dir = read()
										if (string.find(password, '#') == nil) then
											dir = 'C:/' .. dir

											write("Admin (y): ")
											local i = read('*')
											local cmd = false
											if (i == 'y') then
												cmd = true
											end

											WFM_USERS[id] = {["user"]=user, ["password"]=password, ["dir"]=dir, ["cmd"]=cmd}
											saveWFM_USERS(WFM_USERS)

											tcolor(colors.lime)
											write("User '" .. u .. "' changed.")
										else
											tcolor(colors.red)
											write("Please use a directory without '#'.")
										end
									else
										tcolor(colors.red)
										write("Please use a password without '#'.")
									end
								else
										tcolor(colors.red)
										write("Please use a name without '#' and '/'")
								end
							else
								tcolor(colors.red)
								write("This user doesn't exist!")
							end
						end
					elseif (string.find(input, 'wfm remove')) then
						local _, p = string.find(input, 'wfm remove')
						if (#input > p + 1) then
							local user = string.sub(input, p + 2) .. ""

							local id = -1
							local WFM_USERS = getWFM_USERS()
							for i=1, #WFM_USERS do
								if (WFM_USERS[i].user == user) then
									id = i
									break
								end
							end

							if (id ~= -1) then
								local new_array = {}
								for i=1, #WFM_USERS do
									if (i ~= id) then
										new_array[#new_array + 1] = WFM_USERS[i]
									end
								end
								saveWFM_USERS(new_array)

								tcolor(colors.lime)
								write("User '" .. user .. "' deleted.")
							else
								tcolor(colors.red)
								write("This user doesn't exist!")
							end
						end
					else
						tcolor(colors.red)
						write("Usage: $wfm <CMD>. Try $help wfm")
					end
				elseif (input=="cos") then
					return true
				else
					tcolor(colors.red)
					write("This Command does not exist!")
				end
			end
		elseif (event=="modem_message") then
			--ID MSG DIS
			if (string.find(msg, "~SJN@SWEBCLIENT:GETCONTENTFORPATH#")) then
				local p1, p2 = string.find(msg, "~SJN@SWEBCLIENT:GETCONTENTFORPATH#")

				local path = string.sub(msg, p2 + 1)

				local result = ""
				local doctype = "txt"

				if (path == "" or path == nil) then
					path = HOME_PATH
				end

				local full_path = WEB_PATH .. "/" .. path

				if (fs.exists(full_path) and hasWebAccess(full_path)) then
					local okay = false
					if (fs.isDir(full_path)) then
						local alt_path = full_path .. '/' .. HOME_PATH
						if string.find(string.reverse(full_path), '/')==1 then
							alt_path = full_path .. HOME_PATH
						end
						if (fs.exists(alt_path) and hasWebAccess(alt_path)) then
							full_path = alt_path
							okay = true
						end
					else
						okay = true
					end

					if (okay) then
						local f = fs.open(full_path, "r")
						local perm = f.readLine()
						local dtype = f.readLine()
						local content = f.readAll()
						f.close()

						if (string.find(dtype, "@doctype=") == 1) then
							local pos1, pos2 = string.find(dtype, "@doctype=")
							doctype = string.sub(dtype, pos2 + 1)
						else
							content = dtype .. "\n" .. content
						end

						if (perm == "@public") then
							result = content
						elseif (perm == "@hidden") then
							result = "Sorry, this target doesn't exist."
						else
							result = "Sorry, this file is private."
						end
					else
						doctype = 'stp'
						result = "No Access. <text=Homepage#of#this#Server color=orange link=INT:>"
					end
				else
					result = "Sorry, this target doesn't exist."
				end
				write("\n["..getTime().."]: #"..id.." ASKED FOR "..string.sub(path, 0, 100))

				rednet.send(id, "doctype="..doctype.."#"..result)
			elseif (string.find(msg, '~SJN@WFMCLIENT:LOGIN#')) then
				local success = wfmLogin(msg, '~SJN@WFMCLIENT:LOGIN')
				if (success) then
					rednet.send(id, "~SJN@WFMSERVER:LOGIN_SUCCESS#" .. tostring(true))
				else
					rednet.send(id, "~SJN@WFMSERVER:LOGIN_WRONG")
				end
			elseif string.find(msg, '~SJN@WFMCLIENT:GETDATA') then
				local success, userdata, raw_path = wfmLogin2(msg, 'GETDATA')
				local data = {}
				local path = userdata.dir .. "/" .. raw_path
				if (fs.exists(path)) then
					if (fs.exists(path .. "/.access") and not fs.isDir(path .. "/.access")) then
						local d = sjn.getConfigFileContent(path .. '/.access')
						if (d.wfmaccess == 'none') or
							(d.wfmaccess == 'admin' and d.cmd == false) then
							data.msg = 'The directory doesn\'t exist or the access is forbidden.'
						end
					end

					local list = fs.list(path)
					data.list = {}
					for i=1, #list do
						local name = list[i]
						local f_path = path .. "/" .. name
						local isDir = fs.isDir(f_path)

						if (not fs.isReadOnly(f_path)) then
							data.list[i] = {}
							data.list[i].isDir = isDir
							data.list[i].name = name
						end
					end
				else
					data.msg = 'The directory doesn\'t exist or the access is forbidden.'
				end

				if (data.msg) then
					data.list = {}
				end
				rednet.send(id, "~SJN@WFMSERVER:DATA#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:UPDATE') then
				local success, userdata = wfmLogin2(msg, 'UPDATE')

				local data = {['result']='No permission.'}

				if (userdata.cmd) then
					data.result = 'Starting Update...'
					rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
					shell.run(PART_PATH, "update", "via_wfm", id)
					return true
				end
				rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:DOWNLOAD#') then
				local success, userdata, raw_path = wfmLogin2(msg, 'DOWNLOAD')
				local data = {}
				local path = userdata.dir .. "/" .. raw_path
				if (fs.exists(path)) then
					--Needs .access check!!!

					local f = fs.open(path, 'r')
					data.content = f.readAll()
					f.close()
				else
					data.msg = 'The directory doesn\'t exist or the access is forbidden.'
				end

				if (data.msg) then
					data.content = ''
				end
				rednet.send(id, "~SJN@WFMSERVER:CONTENT#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:UPLOAD#') == 1 then
				local success, userdata, raw_path, content = wfmLogin2(msg, 'UPLOAD')
				local data = {}
				local path = userdata.dir .. "/" .. raw_path
				if (not fs.isDir(path) and not fs.isReadOnly(path)) then
					--Needs .access check!!!

					local f = fs.open(path, 'w')
					f.write(content)
					f.close()
					data.msg = 'Upload successfully!'
				else
					data.msg = 'Upload failed.'
				end

				rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:DELETE') == 1 then
				local success, userdata, raw_path = wfmLogin2(msg, 'DELETE')
				local data = {}
				local path = userdata.dir .. "/" .. raw_path
				if (fs.exists(path) and not fs.isReadOnly(path)) then
					--Needs .access check!!!
					fs.delete(path)
				else
					data.msg = 'Failed to delete the file/directory.'
				end

				rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:EXECUTE#') then
				local success, userdata, raw_path = wfmLogin2(msg, 'EXECUTE')

				local data = {['result']='No permission.'}
				local path = userdata.dir .. "/" .. raw_path

				if (userdata.cmd) then
					if (fs.exists(path) and not fs.isDir(path)) then
						--Needs .access check!!!

						local function run()
							tcolor(colors.yellow)
							print("\n\nExecuting " .. path .. "...")
							return shell.run(path)
						end

						if (pcall(run) == true) then
							data.result = 'Executed.'
						else
							data.result = 'An Error has occured!'
						end

					else
						data.result = 'File does not exist.'
					end
				end
				rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
			elseif string.find(msg, '~SJN@WFMCLIENT:MOVE#') then
				local success, userdata, raw_path1, raw_path2  = wfmLogin2(msg, 'MOVE')

				local data = {['result']='Invalid names.'}
				local path1 = userdata.dir .. "/" .. raw_path1
				local path2 = userdata.dir .. "/" .. raw_path2

				if (fs.exists(path1) and not fs.exists(path2) and not fs.isDir(path1)) then
					--Needs .access check!!!

					if not string.find(path1, '%.%.') then
						if not string.find(path2, '%.%.') then
							fs.move(path1, path2)
							data.result = 'Renamed.'
						end
					end
				else
					data.result = 'The 1st file does not exist or is a directory or the 2nd file exists.'
				end
				rednet.send(id, "~SJN@WFMSERVER:RESULT#" .. textutils.serialize(data))
			end
		end
	end
end


return true
end

local ok, err = pcall(start)
if not ok then
	sjn.drawErrorScreen2(err, 'startup')
end

--WARNING: DOWNLOAD & CO REQUIRE A .access CONTROLL!!!!!!!!!!!!!!!
--WARNING: WEBACCESS BRAUCHT EINE KONTROLLE ALLER MUTTERVERZEICHNISSE!
