--SJNOS by MC403. terminal.exe (GdZsddz6)

local w, h = term.getSize()

local tArgs = {...}

local COLOR_WD = colors.orange
local COLOR_READ = colors.cyan
local COLOR_DOLLAR = colors.cyan
local COLOR_BG = colors.gray
local COLOR_OUTPUT = colors.lightGray
local COLOR_ERROR = colors.red
local COLOR_WARNING = colors.yellow
local COLOR_OK = colors.lime
local COLOR_EXIT = colors.magenta
local COLOR_FILE = colors.white
local COLOR_DIR = colors.lightBlue
local COLOR_READONLY_FILE = colors.yellow
local COLOR_READONLY_DIR = colors.yellow
local COLOR_SHELL = colors.white

local function start()
	if term.isColor() then
		local USERNAME = ""
		for i=1,#fs.list("SJNOS/users") do
			if tArgs[1]==fs.list("SJNOS/users")[i] then
				USERNAME = tArgs[1]
			end
		end
		if USERNAME=="" then
			error("Undifined Username")
		end
		
		f = fs.open("SJNOS/users/"..USERNAME.."/config/.config","r")
		f.readLine()
		f.readLine()
		f.readLine()
		local USERRANK = f.readLine()
		USERRANK = string.sub(USERRANK,string.find(USERRANK,"=")+1)
		
		f = fs.open("SJNOS/settings/name.set","r")
		local PCNAME = f.readLine()
		PCNAME = string.sub(PCNAME,string.find(PCNAME,"=")+1)
				

		term.setBackgroundColor(COLOR_BG)
		term.clear()
		term.setCursorPos(1,1)

		local workingDir = "SJNOS/users/"..USERNAME.."/home"
		local display = "~"
		
		local done = false
		
		while not done do
			if workingDir=="SJNOS/users/"..USERNAME.."/home" then
				display = "~"
			end
			
			term.setTextColor(COLOR_WD)
			write(USERNAME.."@"..PCNAME..":"..display)
			term.setTextColor(COLOR_DOLLAR)
			write(" $ ")
			term.setTextColor(COLOR_READ)
			local input = read()
			
			term.setTextColor(COLOR_OUTPUT)
			if input=="exit" then
				term.setTextColor(COLOR_EXIT)
				write("Exit")
				sleep(0.5)
				done = true
				term.setTextColor(colors.white)
				term.setBackgroundColor(colors.black)
				term.setCursorPos(1,1)
				term.clear()
			elseif input=="terminal" then
				term.setBackgroundColor(COLOR_BG)
				term.setCursorPos(1,1)
				term.clear()
				workingDir = "SJNOS/users/"..USERNAME.."/home"
				display = "~"
			elseif input=="ver" then
				f = fs.open("SJNOS/system/about/ver.txt","r")
				local ver = f.readLine()
				ver = string.sub(ver,string.find(ver,"=")+1)
				local status = f.readLine()
				status = string.sub(status,string.find(status,"=")+1)
				f.close()
				print("v"..ver.." "..status)
			elseif input=="pwd" then
				print(workingDir)
			elseif input=="rednet" or string.find(input,"rednet ")==1 then
				local args = string.sub(input,8)
				
				local arg1End = string.find(args," ")
				if arg1End == nil then arg1End = #args+1 end
				local arg1 = string.sub(args,1,arg1End-1)
				local argRest = string.sub(args,arg1End+1)
				local arg2End = string.find(argRest," ")
				if arg2End == nil then arg2End = #argRest+1 end
				local arg2 = string.sub(argRest,1,arg2End-1)
				local arg3 = string.sub(argRest,arg2End+1)
				
				if arg1=="-s" then
					--Send
					local receiver = tonumber(arg2)
					if receiver ~= nil then
						if receiver >= 0 then
							rednet.send(receiver,arg3)
							print("["..textutils.formatTime(os.time(),true).."]: Message has been send to "..receiver..".")
						else
							term.setTextColor(COLOR_ERROR)
							print("No valid receiver")
						end
					else
						term.setTextColor(COLOR_ERROR)
						print("No valid receiver")
					end
				elseif arg1 == "-r" then
					--Receive
					
					local timer = arg2
					local sender = arg3
					
					if timer ~= nil and timer~="" then
						if tonumber(timer)~=nil then
							--Time limit
							if sender ~= nil and sender ~="" then
								if tonumber(sender)~=nil then
									--Valid sender
									print("Press [C] to terminate!")
									local clocker = os.startTimer(tonumber(timer))
									while true do
										local event, side, channel, id, msg, dis = os.pullEventRaw()
										if event=="key" and side==46 then
											term.setTextColor(COLOR_WARNING)
											print("Canceled.")
											break
										elseif event=="modem_message" and id==sender then
											term.setTextColor(COLOR_OK)
											print("["..textutils.formatTime(os.time(),true).."]: "..id.."> "..msg)
											break
										elseif event=="timer" and side==clocker then
											term.setTextColor(COLOR_WARNING)
											print("Timer finished.")
											break
										end
									end
									clocker = nil
								else
									term.setTextColor(COLOR_ERROR)
									print("Sender not valid")
								end
							else
								--No sender
								print("Press [C] to terminate!")
								local clocker = os.startTimer(tonumber(timer))
								while true do
									local event, side, channel, id, msg, dis = os.pullEventRaw()
									if event=="key" and side==46 then
										term.setTextColor(COLOR_WARNING)
										print("Canceled.")
										break
									elseif event=="modem_message" then
										term.setTextColor(COLOR_OK)
										print("["..textutils.formatTime(os.time(),true).."]: "..id.."> "..msg)
										break
									elseif event=="timer" and side==clocker then
										term.setTextColor(COLOR_WARNING)
										print("Timer finished.")
										break
									end
								end
								clocker = nil
							end
						else
							term.setTextColor(COLOR_ERROR)
							print("Time not valid")
						end
					else
						--No time limit
						if sender ~= nil and sender ~="" then
							if tonumber(sender)~=nil then
								--Valid Sender
								print("Press [C] to terminate!")
								while true do
									local event, side, channel, id, msg, dis = os.pullEventRaw()
									if event=="key" and side==46 then
										term.setTextColor(COLOR_WARNING)
										print("Canceled.")
										break
									elseif event=="modem_message" and id==sender then
										term.setTextColor(COLOR_OK)
										print("["..textutils.formatTime(os.time(),true).."]: "..id.."> "..msg)
										break
									elseif event=="timer" and side==clocker then
										term.setTextColor(COLOR_WARNING)
										print("Timer finished.")
										break
									end
								end
							else
								--No valid sender
								term.setTextColor(COLOR_ERROR)
								print("Sender not valid")
							end
						else
							--No sender
							print("Press [C] to terminate!")
							while true do
								local event, side, channel, id, msg, dis = os.pullEventRaw()
								if event=="key" and side==46 then
									term.setTextColor(COLOR_WARNING)
									print("Canceled.")
									break
								elseif event=="modem_message" then
									term.setTextColor(COLOR_OK)
									print("["..textutils.formatTime(os.time(),true).."]: "..id.."> "..msg)
									break
								end
							end
						end
					end
				else
					term.setTextColor(COLOR_ERROR)
					print("Invalid Arguments. Try $help rednet")
				end
			elseif input=="time" then
				print("Day "..os.day().." "..textutils.formatTime(os.time(),false))
			elseif input=="help" or string.find(input,"help ") then
				if input == "help" then
					print("$cd                 : Change Directory -> $help cd ")
					print("$clear              : Clears the Screen            ")
					print("$exit               : Exit                         ")
					print("$help               : Help                         ")
					print("$ls                 : List -> $help ls             ")
					print("$pwd                : Print Working Directory      ")
					print("$terminal           : Reset the terminal           ")
					print("$ver                : Shows the version of SJNOS   ")
				else
					local args = string.sub(input,6)
					local arg1End = string.find(args," ")
					if arg1End == nil then arg1End = #args+1 end
					local arg1 = string.sub(args,1,arg1End-1)
					local arg2 = string.sub(args,arg1End+1)
					
					if arg1 == "cd" then
						print("CHANGE DIRECTORY")
						print("Usage: $cd <path>")
						print("path: DIRECTORY")
						print("$cd .. -> One Level higher")
						print("")
						print("$cd @ROOT  = Highest Level")
						print("$cd @HOME  = SJNOS/users/<your name>/home")
						print("$cd @USERS = SJNOS/users")
						print("$cd @ROM   = rom")
						print("$cd ~      = @HOME")
						print("$cd /      = @ROOT")
					end
				end
			elseif input=="clear" then
				term.setBackgroundColor(COLOR_BG)
				term.setCursorPos(1,1)
				term.clear()
			elseif input=="run" or string.find(input,"run ")==1 then
				local args = string.sub(input,5)
				local arg1End = string.find(args," ")
				if arg1End == nil then arg1End = #args+1 end
				local arg1 = string.sub(args,1,arg1End-1)
				local arg2 = string.sub(args,arg1End+1)
				
				if arg1~=nil and arg1~="" then
					if fs.exists(workingDir.."/"..arg1) then
						if not fs.isDir(workingDir.."/"..arg1) then
							term.setTextColor(COLOR_WARNING)
							print("Are you sure to run the following File?")
							term.setTextColor(COLOR_OK)
							print('"'..workingDir.."/"..arg1..'"')
							term.setTextColor(COLOR_WD)
							write("[y/n] > ")
							term.setTextColor(COLOR_READ)
							local i = read()
							if i=="y" then
								term.setTextColor(COLOR_SHELL)
								shell.run(workingDir.."/"..arg1)
								term.setTextColor(COLOR_OUTPUT)
								term.setBackgroundColor(COLOR_BG)
								print("[Press any key to continue!]")
								os.pullEventRaw("key")
							end
						else
							term.setTextColor(COLOR_ERROR)
							print("Can't run a directory.")
						end
					else
						term.setTextColor(COLOR_ERROR)
						print("File does not exists!")
					end
				else
					term.setTextColor(COLOR_ERROR)
					print("Usage: $ run <file>")
				end
			elseif string.find(input,"cd ")==1 then
				local args = string.sub(input,4)
				local arg1End = string.find(args," ")
				if arg1End == nil then arg1End = #args+1 end
				local arg1 = string.sub(args,1,arg1End-1)
				local arg2 = string.sub(args,arg1End+1)
				
				
				if arg1=="/" or arg1=="@ROOT" then
					if USERRANK == "a" then
						workingDir = ""
						display = workingDir
					else
						term.setTextColor(COLOR_ERROR)
						print("This path is only accessible for an Administrator.")
					end
				elseif arg1=="~" or arg1=="@HOME" then
					workingDir = "SJNOS/users/"..USERNAME.."/home"
					display = "~"
				elseif arg1=="@USERS" then
					if USERRANK == "a" then
						workingDir = "SJNOS/users"
						display = workingDir
					else
						term.setTextColor(COLOR_ERROR)
						print("This path is only accessible for an Administrator.")
					end
				elseif arg1=="@ROM" then
					workingDir = "rom"
					display = workingDir
				elseif arg1~="" then
					local now = arg1
					local rest = arg1
					local r = true
					while r do
						local i1 = string.find(rest,"/")
						if i1==nil then
							now = string.sub(rest,1)
							r = false
						else
							now = string.sub(rest,1,i1-1)
							rest = string.sub(rest,i1+1)
						end
						
						
						if #now==2 and string.sub(now,1,1)=="." and string.sub(now,2,2)=="." then
							-- ..
							if workingDir=="" then
								term.setTextColor(COLOR_ERROR)
								print("You are at the highest level.")
								r = false
							elseif workingDir=="SJNOS/users/"..USERNAME.."/home" then
								if USERRANK=="a" then
									workingDir = "SJNOS/users/"..USERNAME
									display = workingDir
								else
									term.setTextColor(COLOR_ERROR)
									print("This path is only accessible for an Administrator.")
									r = false
								end
							else
								local s1 = string.reverse(workingDir)
								local i1 = string.find(s1,"/")
								if i1~=nil then
									local i2 = #workingDir
									local i3 = i2 - i1
									local s2 = string.sub(s1,i1+1)
									local s3 = string.reverse(s2)
									workingDir = s3
								else
									workingDir = ""
								end
																	
								if string.find(workingDir,"SJNOS/users/"..USERNAME.."/home")==1 then
									local t1, t2 = string.find(workingDir,"SJNOS/users/"..USERNAME.."/home")
									local t3 = string.sub(workingDir,t2+1)
									display = "~"..t3
								else
									display = workingDir
								end
							end
						else
							-- No ..
							if fs.exists(workingDir.."/"..now) then
								if fs.isDir(workingDir.."/"..now) then
									workingDir = workingDir.."/"..now
									if string.find(workingDir,"SJNOS/users/"..USERNAME.."/home")==1 then
										local t1, t2 = string.find(workingDir,"SJNOS/users/"..USERNAME.."/home")
										local t3 = string.sub(workingDir,t2+1)
										display = "~"..t3
									else
										display = workingDir
									end
								else
									term.setTextColor(COLOR_ERROR)
									print("Not a directory.")
									r = false
								end
							else
								term.setTextColor(COLOR_ERROR)
								print("This path doesnot exists.")
								r = false
							end
						end
					end
				end
			elseif string.find(input,"ls ")==1 or input=="ls" then
				------------------------------------------
				local args = string.sub(input,4)
				local arg1End = string.find(args," ")
				if arg1End == nil then arg1End = #args+1 end
				local arg1 = string.sub(args,1,arg1End-1)
				local arg2 = string.sub(args,arg1End+1)
				
				local function show(path)
					if fs.exists(path) then
						local list = fs.list(path)
						
						local readonlydirs = {}
						local dirs = {}
						local readonlyfiles = {}
						local files = {}

						for i=1,#list do
							local path_list
							if path=="" then
								path_list = list[i]
							else
								path_list = path.."/"..list[i]
							end
							
							if fs.isReadOnly(path_list) then
								if fs.isDir(path_list) then
									table.insert(readonlydirs,list[i])
								else
									table.insert(readonlyfiles,list[i])
								end
							else
								if fs.isDir(path_list) then
									table.insert(dirs,list[i])
								else
									table.insert(files,list[i])
								end
							end
						end
						
						term.setTextColor(COLOR_READONLY_DIR)
						for i=1,#readonlydirs do
							print(readonlydirs[i])
						end

						term.setTextColor(COLOR_DIR)
						for i=1,#dirs do
							print(dirs[i])
						end

						term.setTextColor(COLOR_READONLY_FILE)
						for i=1,#readonlyfiles do
							print(readonlyfiles[i])
						end

						term.setTextColor(COLOR_FILE)
						for i=1,#files do
							print(files[i])
						end
						
						--[[
						for i=1,#list do
							local path_list
							if path=="" then
								path_list = list[i]
							else
								path_list = path.."/"..list[i]
							end
							
							if fs.isReadOnly(path_list) then
								if fs.isDir(path_list) then
									term.setTextColor(COLOR_READONLY_DIR)
								else
									term.setTextColor(COLOR_READONLY_FILE)
								end
							else
								if fs.isDir(path_list) then
									term.setTextColor(COLOR_DIR)
								else
									term.setTextColor(COLOR_FILE)
								end
							end
							print(list[i])
						end--]]
					else
						term.setTextColor(COLOR_ERROR)
						print("Path does not exists!")
					end
				end
				
				if arg1=="/" or arg1=="@ROOT" then
					if USERRANK == "a" then
						show("")
					else
						term.setTextColor(COLOR_ERROR)
						print("This path is only accessible for an Administrator.")
					end
				elseif arg1=="@HOME" then
					show("SJNOS/users/"..USERNAME.."/home")
				elseif arg1=="@USERS" then
					if USERRANK == "a" then
						show("SJNOS/users")
					else
						term.setTextColor(COLOR_ERROR)
						print("This path is only accessible for an Administrator.")
					end
				elseif arg1=="@PLUGINS" then
					if USERRANK == "a" then
						show("SJNOS/plugins")
					else
						term.setTextColor(COLOR_ERROR)
						print("This path is only accessible for an Administrator.")
					end
				elseif arg1=="@ROM" then
					show("rom")
				elseif arg1=="" then
					show(workingDir)
				else
				
					local destination = workingDir
					
					local function setDest(d)
						DESTINATION = d
					end
					
					local now = arg1
					local rest = arg1
					local r = true
					while r do
						local i1 = string.find(rest,"/")
						if i1==nil then
							now = string.sub(rest,1)
							r = false
						else
							now = string.sub(rest,1,i1-1)
							rest = string.sub(rest,i1+1)
						end
						
						
						if #now==2 and string.sub(now,1,1)=="." and string.sub(now,2,2)=="." then
							-- ..
							if workingDir=="" then
								term.setTextColor(COLOR_ERROR)
								print("You are at the highest level.")
								r = false
							elseif workingDir=="SJNOS/users/"..USERNAME.."/home" then
								if USERRANK=="a" then
									setDest("SJNOS/users/"..USERNAME)
								else
									term.setTextColor(COLOR_ERROR)
									print("This path is only accessible for an Administrator.")
									r = false
								end
							else
								local s1 = string.reverse(workingDir)
								local i1 = string.find(s1,"/")
								if i1~=nil then
									local i2 = #workingDir
									local i3 = i2 - i1
									local s2 = string.sub(s1,i1+1)
									local s3 = string.reverse(s2)
									setDest(s3)
								else
									setDest("")
								end																		
							end
						else
							-- No ..
							if fs.exists(workingDir.."/"..now) then
								setDest(workingDir.."/"..now)
							else
								term.setTextColor(COLOR_ERROR)
								print("This path doesnot exists.")
								r = false
							end
						end
					end
					show(destination)
					------------------------------------------
				end
			elseif input~="" and input~=" " then
				term.setTextColor(COLOR_ERROR)
				print("This Command does not exist. Try $help.")
			end
		end
	end
	return true
end

local ok, err = pcall(start)
if not ok then
	local function draw()f = fs.open(".errimg","w") f.writeLine("000000000000000000000000010000000000000000000000000") local w,h = term.getSize()
	f.writeLine("000000000000000000000000111000000000000000000000000") f.writeLine("0000000000000000000000011f1100000000000000000000000")
	f.writeLine("0000000000000000000000111f1110000000000000000000000") f.writeLine("0000000000000000000001111f1111000000000000000000000")
	f.writeLine("000000000000000000001111111111100000000000000000000") f.writeLine("0000000000000000000111111f1111110000000000000000000")
	f.writeLine("000000000000000000111111111111111000000000000000000") f.close() term.setBackgroundColor(colors.white) term.setTextColor(colors.cyan)
	term.clear() img = paintutils.loadImage(".errimg") paintutils.drawImage(img,1,3) term.setBackgroundColor(colors.white) term.setCursorPos(1,1)
	write("SJNOS ERROR") term.setCursorPos(47,1) write(textutils.formatTime(os.time(),true)) term.setTextColor(colors.black) fs.delete(".errimg")
	term.setCursorPos((w-string.len("Oh No! Something went horribly wrong! :("))/2,12) write("Oh No! Something went horribly wrong :(")
	term.setTextColor(colors.red) local error = {err} if #err > 40 then error[1] = string.sub(err,0,39) error[2] = string.sub(err,40) term.setCursorPos(1,1)
	end for i=1,#error do term.setCursorPos((w-string.len(error[i]))/2,13+i) write(error[i]) end term.setBackgroundColor(colors.orange)
	term.setTextColor(colors.black) startcoos = 17 term.setCursorPos(startcoos,18) write("Reboot") term.setCursorPos(startcoos+7,18) write("Edit")
	term.setCursorPos(startcoos+12,18) write("Exit") end draw() local finished = false while not finished do local event, btn, x, y = os.pullEvent()
	if event=="mouse_click" and btn==1 and y==18 then if x>=startcoos and x<=startcoos+6 then finished = true os.reboot()
	elseif x>=startcoos+8 and x<=startcoos+11 then shell.run("edit",shell.getRunningProgram()) draw() elseif x>=startcoos+13 and x<=startcoos+16 then
	finished = true term.setBackgroundColor(colors.white) term.setTextColor(colors.cyan) term.clear() term.setCursorPos(1,1) shell.run("startup") end end end
end
