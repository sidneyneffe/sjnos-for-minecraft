--SJNOS by MC403. filemgr.exe (3FEeWeG8)

local w, h = term.getSize()

local tArgs = {...}

local COLOR_TEXT = colors.cyan
local COLOR_BG = colors.white
local COLOR_MENU_TEXT = colors.orange
local COLOR_MENU_BG = colors.cyan
local COLOR_MENU_ACTIVE_TEXT = colors.orange
local COLOR_MENU_ACTIVE_BG = colors.gray

local COLOR_WD_TEXT = colors.gray
local COLOR_WD_BG = colors.yellow

local COLOR_SIDEBAR_TEXT = colors.cyan
local COLOR_SIDEBAR_BG = colors.lightGray

local COLOR_FILE_TYPE_BG = colors.gray
local COLOR_FILE_TYPE_FILE = colors.lime
local COLOR_FILE_TYPE_DIR = colors.white
local COLOR_FILE_TYPE_MENU = colors.cyan
local COLOR_FILE_TYPE_READONLY = colors.yellow
local COLOR_SELECTED_BG = colors.orange
local COLOR_SELECTED_TEXT = colors.white

local COLOR_SCROLLBAR_ACTIVE = colors.cyan
local COLOR_SCROLLBAR = colors.gray

local COLOR_CONTEXT_TEXT = colors.orange
local COLOR_CONTEXT_BG = colors.gray

local COLOR_DLG_NORMAL_TEXT = colors.orange
local COLOR_DLG_NORMAL_BG = colors.gray
local COLOR_DLG_NORMAL_INPUT = colors.cyan
local COLOR_DLG_NORMAL_OK = colors.lime
local COLOR_DLG_NORMAL_CANCEL = colors.red


local function start()
	if (not term.isColor()) then
		return true
	elseif (tArgs[1] == nil) then
		error("Invalid Parapeters.")
	end

	os.loadAPI("SJNOS/system/SJNOS/sjn")

	local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
	local width, height = term.getSize()

	local USERNAME = tArgs[1]
	local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

	local REDNET, REDNETSIDE = sjn.getRednet(true)

	local function refresh()
		local REDNET, REDNETSIDE = sjn.getRednet(true)
	end

	local function showDialog(head, texts, buttons, enterButton, delay)
		return sjn.showDialog(head, texts, colors.orange, colors.gray,
			colors.gray, colors.orange, buttons, enterButton, delay)
	end

	local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
		return sjn.showInputDialog(head, texts, colors.orange, colors.gray,
			colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
	end

	local workingDir = "SJNOS/users/"..USERNAME.."/home"
	if (tArgs[2] ~= nil) then
		if (USERRANK == "a" and fs.exists(tArgs[2]) and fs.isDir(tArgs[2])) then
			workingDir = tArgs[2]
		elseif (string.find(tArgs[2], workingDir) and fs.exists(tArgs[2]) and fs.isDir(tArgs[2])) then
			workingDir = tArgs[2]
		end
	end
	local workingDirScroll = 0

	local main_scroll = 0
	local main_elements = {}
	
	local clipboard = "SJNOS/users/" .. USERNAME .. "/config/.copy"
	local copy_name = ""
	local source = ""
	local cutting = false
	
	local LEFTBAR = {}

	local function drawTitle()
		tcolor(COLOR_MENU_TEXT)
		bcolor(COLOR_MENU_BG)
		cpos(1,1)
		term.clearLine()
		write("FileManager")
		cpos(47,1)
		write(textutils.formatTime(os.time(),true))
		
		cpos(40,1)
		write("HOME")
		
		if not (USERRANK~="a" and workingDir=="SJNOS/users/"..USERNAME.."/home") and workingDir~="" then
			cpos(36,1)
			write("DIR")
		end
		
		cpos(45,1)
		write("#")
	end
	local function drawLeftBar()
		tcolor(COLOR_SIDEBAR_TEXT)
		bcolor(COLOR_SIDEBAR_BG)
		for y=2,19 do
			cpos(1,y)
			write("             ")
		end
		cpos(2,2)
		write(USERNAME)
		
		local list = fs.list("SJNOS/users/"..USERNAME.."/home")
		local dir = {}
		for i=1,#list do
			if fs.isDir("SJNOS/users/"..USERNAME.."/home/"..list[i]) then
				table.insert(dir,list[i])
			end
		end
		
		for i=1,#dir do
			cpos(2,2+i)
			write("> "..string.sub(dir[i],1,12))
		end
	end
	local function drawWorkingDir()
		tcolor(COLOR_WD_TEXT)
		bcolor(COLOR_WD_BG)
		cpos(14, 2)
		
		local text = " C:/"..workingDir
		
		if (workingDir=="") then text = text.." (@ROOT)"
		elseif (workingDir=="SJNOS/users/"..USERNAME.."/home") then text = text.." (@HOME)" end
		
		while (#text<38) do
			text = text.." "
		end
					
		write(string.sub(text,1 + workingDirScroll, 38 + workingDirScroll))
	end
	local function drawMain()
		main_elements = {}
		local list = fs.list(workingDir)
		local counter = 0
		local successful = 0
		while true do
			cpos(15,successful-main_scroll+3)
			counter = counter + 1
			if (list[counter]~=nil) then
				if (fs.isDir(workingDir.."/"..list[counter])) then
					if (fs.isReadOnly(workingDir.."/"..list[counter])) then
						tcolor(COLOR_FILE_TYPE_READONLY)
					else
						tcolor(COLOR_FILE_TYPE_DIR)
					end
					table.insert(main_elements,{file=false,name=list[counter]})
					if (successful-main_scroll >= 0) then
						bcolor(COLOR_FILE_TYPE_BG)
						write("[=]")
						tcolor(COLOR_TEXT)
						bcolor(COLOR_BG)

						local text = " "..list[counter]
						while (#text<35) do
							text = text.." "
						end
						write(text)
					end
					successful = successful + 1
				end
			else
				break
			end
		end
		local counter2 = 0
		local successful2 = 0
		while true do
			cpos(15,successful+successful2+3-main_scroll)
			counter2 = counter2 + 1
			if (list[counter2]~=nil) then
				if (not fs.isDir(workingDir.."/"..list[counter2])) then
					if (fs.isReadOnly(workingDir.."/"..list[counter2])) then
						tcolor(COLOR_FILE_TYPE_READONLY)
					else
						tcolor(COLOR_FILE_TYPE_FILE)
					end
					table.insert(main_elements,{file=true,name=list[counter2]})
					if (successful+successful2-main_scroll >= 0) then
						bcolor(COLOR_FILE_TYPE_BG)
						write("-~-")
						tcolor(COLOR_TEXT)
						bcolor(COLOR_BG)
						
						local text = " "..list[counter2]
						while (#text<35) do
							text = text.." "
						end							
						write(text)
					end
					successful2 = successful2 + 1
				end
			else
				break
			end
		end
		
		if (#main_elements > 17) then
			bcolor(COLOR_SCROLLBAR)
			for i=3,19 do
				cpos(51,i)
				write(" ")
			end
			
			local height = math.floor(289 / #main_elements)
			
			bcolor(COLOR_SCROLLBAR_ACTIVE)
			for i=main_scroll+3,height+main_scroll+3 do
				cpos(51,i)
				write(" ")
			end
		end
		
	end
	
	function clearAndDrawMain()
		bcolor(COLOR_BG)
		for i=3,19 do
			cpos(14,i)
			write("                                      ")
		end
		drawMain()
	end
	
	function draw()
		bcolor(COLOR_BG)
		clear()
		drawTitle()
		drawLeftBar()
		drawWorkingDir()
		drawMain()
	end
	
	function drawMenu()
		cpos(1,1)
		tcolor(COLOR_MENU_ACTIVE_TEXT)
		bcolor(COLOR_MENU_ACTIVE_BG)
		write("FileManager ")
		
		cpos(1,2)
		tcolor(COLOR_MENU_ACTIVE_TEXT)
		bcolor(COLOR_MENU_ACTIVE_BG)
		print(" HOME        ")
		print(" Settings    ")
		print(" Help        ")
		print(" Restart     ")
		print(" Terminal    ")
		print(" Quit        ")
	end
	
	draw()
	
	local run = true
	
	while (run) do
		draw()
		local event, btn, x, y = os.pullEventRaw()
		if (event=="mouse_click") then
			if (btn==1 and x<=12 and y==1) then
				--MENU
				drawMenu()
				
				local inner = true
				while (inner) do
					local event, btn, x, y = os.pullEventRaw()
					if (event=="mouse_click" and btn==1) then
						if (x<=15) then
							if (y==2) then
								--HOME
								workingDir = "SJNOS/users/"..USERNAME.."/home"
							elseif (y==3) then
								--SETTINGS
							elseif (y==4) then
								--HELP
							elseif (y==5) then
								--Restart
								workingDir = "SJNOS/users/"..USERNAME.."/home"
								main_scroll = 0
								main_elements = {}
							elseif (y==6) then
								--Terminal
								if (fs.exists("SJNOS/data/programs/terminal.exe")) then
									shell.run("SJNOS/data/programs/terminal.exe",USERNAME)
								else
									error("SJNOS Error 918: No Terminal installed!")
								end
							elseif (y==7) then
								--Quit
								run = false
							end
							inner = false
							draw()
						else
							inner = false
							draw()
						end
					end
				end
			elseif (y==1 and x<=45 and x>=36) then
				--HOME & DIR
				if (x>=36 and x<=38) then
					--DIR
					
					if not (workingDir=="SJNOS/users/"..USERNAME.."/home" and USERRANK~="a") then
						if (workingDir~="") then
							local nosense = string.reverse(workingDir)
							local slashPos = string.find(nosense,"/")

							if (slashPos==nil) then
								workingDir = ""
							else
								local nosense2 = string.sub(nosense,slashPos+1)
								local sense = string.reverse(nosense2)
								workingDir = sense
							end
						end
					end
					draw()
				elseif (x>=40 and x<=43) then
					--HOME
					workingDir = "SJNOS/users/"..USERNAME.."/home"
					inner = false
					draw()
				elseif (x==45) then
					--Options (#)
					tcolor(COLOR_MENU_ACTIVE_TEXT)
					bcolor(COLOR_MENU_ACTIVE_BG)
					
					local text = {
					" New File   ",
					" New Folder ",
					" Receive    ",
					" Refresh    ",
					" Paste      ",
					" Search     "
					}
					
					for i=1,#text do
						cpos(40,i+1)
						write(text[i])
					end
					
					local active = true
					while active do
						local event, btn, x, y = os.pullEvent()
						if (event=="mouse_click") then
							active = false
							if (btn==1) then
								if (x>=40) then
									if (y==2) then
										--New File
																					
										local result, input = showInputDialog("New File:", {"Create a new file!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}, {colors.red, COLOR_DLG_NORMAL_BG, "Cancel"}})
										if (result == 1) then
											--Okay
											local function c(text)
												local test = tostring(string.find(input, text)==nil)
												return (string.find(input, text)==nil)
											end

											if (c("/") and c(" ") and c("<") and c(">") and c("~") and c("\"") and c("#") and #input<=17 and input ~= "") then
												local path = workingDir .. "/" .. input

												if (workingDir == "") then
													path = input
												end

												if (not fs.exists(path)) then
													local f = fs.open(path, "w")
													f.close()
												else
													showDialog("New File: ", {"The file must not exist."}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
												end
											else
												showDialog("New File: ", {"Please do not use special characters.", "Input must be smaller than 17."}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
											end
										end
									elseif (y==3) then
										--New Folder
										
										local result, input = showInputDialog("New Folder:", {"Create a new folder!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}, {colors.red, COLOR_DLG_NORMAL_BG, "Cancel"}})
										if (result == 1) then
											local function c(text)
												return (string.find(input, text)==nil)
											end

											if (c("/") and c(" ") and c("<") and c(">") and c("~") and c("\"") and c("#") and #input<=17 and input ~= "") then
												local path = workingDir .. "/" .. input

												if (workingDir == "") then
													path = input
												end

												if (not fs.exists(path)) then
													fs.makeDir(path)
												else
													showDialog("New Folder: ", {"The folder must not exist."}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
												end
											else
												showDialog("New Folder: ", {"Please do not use special characters.", "Input must be smaller than 17."}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
											end
										end
									elseif (y==4) then
										--Receive
										local r = showDialog("FileTransfer", {"How do you want to receive a file?"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Rednet"}, {colors.red, COLOR_DLG_NORMAL_BG, "Cancel"}})
										if (r == 1) then
											--Rednet
											local r, i = showInputDialog("FileTransfer", {"Please enter the ID","of the sender."}, {{colors.lime, colors.gray, "Okay"}, {colors.red, colors.gray, "Cancel"}})
											if (r == 1 and tonumber(i) ~= nil) then
												local sender = tonumber(i)

												tcolor(colors.orange)
												bcolor(colors.black)
												clear()
												cpos(1,1)

												print("$ filemgr.exe -receive "..sender)

												local function print2(text, a)
													if (a == true) then
														tcolor(colors.lime)
													elseif (a == false) then
														tcolor(colors.red)
													else
														tcolor(colors.white)
													end
													print(text)
													tcolor(colors.white)
												end

												print2("Waiting for #"..sender.." to send a file...")
												print2("Press ENTER to cancel.")

												local okay = false

												while (true) do
													local event, id, msg, dis = os.pullEventRaw()
													if (event == "key" and id == keys.enter) then
														print2("Canceled!", false)
														break
													elseif (event == "rednet_message" and id == sender) then
														if (msg == "~SJN@FILEMGR.SENDER:READYFORFILE") then
															print2("Sender asked for transmission permission")
															okay = true
															break
														end
													end
												end

												if (okay) then
													rednet.send(sender, "~SJN@FILEMGR.RECEIVER:READY")
													print2("Permission gave.\n")

													print2("Waiting for file content...")
													print2("Press ENTER to cancel.")

													okay = false

													while (true) do
														local event, id, msg, dis = os.pullEventRaw()
														if (event == "key" and id == keys.enter) then
															print2("Canceled!", false)
															break
														elseif (event == "rednet_message" and id == sender) then
															if (string.find(msg, "~SJN@FILEMGR.SENDER:FILE#") == 1) then

																print2("File received!")
																rednet.send(sender, "~SJN@FILEMGR.RECEIVER:FILE_RECEIVED")

																local _, pos = string.find(msg, "~SJN@FILEMGR.SENDER:FILE#")
																local content = string.sub(msg, pos + 1)

																local path = "SJNOS/users/"..USERNAME.."/home/"

																okay = false

																local dest
																
																while true do
																	print2("Where do you want to store the file?")

																	write("C:/"..path)
																	dest = read()

																	local full_path = path .. dest

																	if (string.find(dest, "%.%.") == nil) then
																		if (not fs.exists(full_path)) then
																			okay = true
																			break
																		else
																			print2("File exists!", false)
																		end
																	else
																		print2("Please don't use two dots in your destination!")
																	end
																end

																if (dest ~= nil) then
																	local full_path = path .. dest

																	local f = fs.open(full_path, "w")
																	f.write(content)
																	f.close()

																	print2("Success!", true)
																end
																break
															else
																print2("Received unknown message: "..msg)
															end
														end
													end
												end

												cpos(1, 19)
												tcolor(colors.orange)
												bcolor(colors.gray)
												term.clearLine()
												write("[SJNOS: Press any key to exit the shell.]")

												while (true) do
													local event = os.pullEvent()
													if (event == "key" or event == "mouse_click") then
														break
													end
												end
											end
										end
									elseif (y==5) then
										--Refresh
										draw()
									elseif (y==6) then
										--Paste

										if (source ~= "") then
											local path = copy_name
											if (workingDir ~= "") then
												path = workingDir.."/"..copy_name
											end
											
											if (not fs.exists(path)) then
												fs.copy(clipboard, path)
											else
												local counter = 1
												while (fs.exists(path..""..counter)) do
													counter = counter + 1
												end
												
												fs.copy(clipboard, path..""..counter)
											end

											if (cutting) then
												fs.delete(source)
											end
										end
									elseif (y==7) then
										--Search
									end
								end
							end
						end
					end
				end
			elseif (x >= 14 and y == 2) then
				--Working Dir
				if (btn == 1) then
					cpos(14, 2)
					tcolor(COLOR_WD_TEXT)
					bcolor(COLOR_WD_BG)
					write("                                      ")
					if (USERRANK == "a") then
						cpos(14, 2)
						write(" C:/")
						local input = read()
						if (fs.exists(input) and fs.isDir(input)) then
							workingDir = input
						end
					else
						cpos(14, 2)
						write(" ~/")
						local input = read()
						local path = "SJNOS/users/"..USERNAME.."/home/"..input
						if (fs.exists(path) and fs.isDir(path) and string.find(input, "%.%.")==nil) then
							workingDir = path
						end
					end
				elseif (btn == 2) then
					--Setting working dir to standard
					workingDir = "SJNOS/users/"..USERNAME.."/home"
				else
					--Setting working dir to root
					if (USERRANK == "a") then
						workingDir = ""
					end
				end
				workingDirScroll = 0
				draw()
			elseif (x>14 and x<=50 and y>=3) then
				for i=1,#main_elements-main_scroll do
					if (y==i+2) then
						local element = main_elements[i+main_scroll]
						if (btn==1) then
							if (element.file) then
								--File
								
							else
								--Directory
								if (workingDir == "") then
									workingDir = element.name
								else
									workingDir = workingDir.."/"..element.name
								end
								main_scroll = 0
								draw()
							end
						elseif (btn==2) then
							if (element.file) then
								
								local install_text = " Install    "
								if (workingDir == "SJNOS/users/" .. USERNAME .. "/home/apps") then
									install_text = " Deinstall  "
								end

								local text = {" Run        "," Open with  "," Edit       "," Rename     "," Delete     "," Copy       "," Cut        "," Send       "," Print      ",install_text}
								cpos(19,y)
								
								bcolor(COLOR_SELECTED_BG)
								tcolor(COLOR_SELECTED_TEXT)
								
								local t = element.name
								while (#t<32) do
									t = t.." "
								end			
								write(t)
								
								bcolor(COLOR_CONTEXT_BG)
								tcolor(COLOR_CONTEXT_TEXT)
								
								if (x>39) then x = 39 end
								if (x<18) then x = 18 end
								if (y>10) then y = 10 end
								
								local xa = x
								local ya = y
								
								for i=1,#text do
									cpos(x+1,y+i)
									write(text[i])
								end
								
								local active = true
								local xx = x
								local yy = y
								
								while active do
									local event, btn, x, y = os.pullEventRaw()
									if (event=="mouse_click") then
										if (btn==1) then
											if (x>=xx and x<=xx+12) then
												if (y==yy+1) then
													--Run
													clear()
													tcolor(COLOR_TEXT)
													cpos(1,1)
													shell.run(workingDir.."/"..element.name)
													print("[Press any key to continue]")
													os.pullEventRaw("key")
													draw()
												elseif (y==yy+2) then
													--Open with
													local open_with_text = {" Editor     ", " Paint      ", " Arguments  ", " Application"}
													
													local xx = xa + 13
													local yy = ya + 2

													if (xx>39) then xx = xa - 11 end

													for i=1, #open_with_text do
														cpos(xx, yy - 1 + i)
														write(open_with_text[i])
													end
													
													local active2 = true

													while active2 do
														local event, bbtn, x, y = os.pullEventRaw()
														if (event=="mouse_click" and btn == 1) then
															if (x >= xx and x <= xx + 12) then
																if (y == yy) then
																	--Open With Editor
																	active2 = false
																	shell.run("edit", workingDir.."/"..element.name)
																elseif (y == yy + 1) then
																	--Open with Paint
																	active2 = false
																	shell.run("paint", workingDir.."/"..element.name)
																elseif (y == yy + 2) then
																	active2 = false

																	cpos(xx + 1, yy + 2)
																	write("           ")
																	cpos(xx + 1, yy + 2)
																	local arguments = read()

																	bcolor(COLOR_BG)
																	clear()
																	tcolor(COLOR_TEXT)
																	cpos(1,1)

																	shell.run(workingDir.."/"..element.name .. " " .. arguments)
																	tcolor(COLOR_TEXT)
																	bcolor(COLOR_BG)
																	print("[Press any key to continue]")
																	os.pullEventRaw("key")
																elseif (y == yy + 3) then
																	--Open with App
																	active2 = false
																	cpos(xx + 1, yy + 3)
																	write("           ")
																	cpos(xx + 1, yy + 3)
																	local input = read()

																	local app_path = "SJNOS/users/" .. USERNAME .. "/home/apps/" .. input
																	if (fs.exists(app_path)) then
																		bcolor(COLOR_BG)
																		clear()
																		tcolor(COLOR_TEXT)
																		cpos(1,1)
																		shell.run(app_path, USERNAME, workingDir.."/"..element.name)
																		tcolor(COLOR_TEXT)
																		bcolor(COLOR_BG)
																		print("[Press any key to continue]")
																		os.pullEventRaw("key")
																	end
																else
																	active2 = false
																end
															else
																active2 = false
															end
														end
													end
													draw()
												elseif (y==yy+3) then
													--Edit
													shell.run("edit",workingDir.."/"..element.name)
													draw()
												elseif (y==yy+4) then
													--Rename
													drawMain()
													tcolor(COLOR_TEXT)
													bcolor(COLOR_BG)
													cpos(19,ya)
													write("                                ")
													cpos(19,ya)
													local name = read()

													if (not string.find(name, "/")) then
														local old_path = workingDir .. "/" .. element.name
														local new_path = workingDir .. "/" .. name
														if (not fs.exists(new_path)) then
															fs.move(old_path, new_path)
														end
													end

													draw()
												elseif (y==yy+5) then
													--Delete
													
													local name = workingDir.."/"..element.name
													if (workingDir=="") then
														name = element.name
													end
													
													if (not fs.isReadOnly(name)) then
														if (fs.exists(name)) then
															fs.delete(name)
														end
													end
													draw()
												elseif (y==yy+6) then
													--Copy
													cutting = false
													
													local path = workingDir.."/"..element.name
													if (workingDir=="") then
														path = element.name
													end
													
													if (fs.exists(path)) then
														source = path
														local r = string.reverse(source)
														local slashPos = string.find(r, "/")
														if (slashPos~=nil) then
															local sub = string.sub(r,0,slashPos-1)
															copy_name = string.reverse(sub)
														else
															copy_name = clipboard
														end

														fs.delete(clipboard)
														fs.copy(source, clipboard)
													end
												elseif (y==yy+7) then
													--Cut
													local path = workingDir.."/"..element.name
													if (workingDir=="") then
														path = element.name
													end
													
													if (fs.exists(path)) then
														source = path
														local r = string.reverse(source)
														local slashPos = string.find(r, "/")
														if (slashPos~=nil) then
															local sub = string.sub(r,0,slashPos-1)
															copy_name = string.reverse(sub)
														else
															copy_name = clipboard
														end
														cutting = true
														fs.delete(clipboard)
														fs.copy(source, clipboard)
													end
												elseif (y==yy+8) then
													--Send
													local open_with_text = {" Rednet     ", " Redstone   "}
													
													local xx = xa + 13
													local yy = ya + 8

													if (xx>39) then xx = xa - 11 end

													for i=1, #open_with_text do
														cpos(xx, yy - 1 + i)
														write(open_with_text[i])
													end
													
													local active2 = true

													while active2 do
														local event, bbtn, x, y = os.pullEventRaw()
														if (event=="mouse_click" and btn == 1) then
															if (x >= xx and x <= xx + 12) then
																if (y == yy) then
																	--Send with Rednet
																	local path = workingDir.."/"..element.name
																	if (workingDir=="") then
																		path = element.name
																	end

																	if (REDNET) then
																		local r, i = showInputDialog("FileTransfer", {"Please enter the ID","of the target PC."}, {{colors.lime, colors.gray, "Okay"}, {colors.red, colors.gray, "Cancel"}})
																		if (r == 1) then
																			if (tonumber(i) ~= nil) then
																				local target = tonumber(i)

																				tcolor(colors.orange)
																				bcolor(colors.black)
																				clear()
																				cpos(1,1)

																				print("$ filemgr.exe -send "..target.." "..element.name.."")

																				local function print2(text, a)
																					if (a == true) then
																						tcolor(colors.lime)
																					elseif (a == false) then
																						tcolor(colors.red)
																					else
																						tcolor(colors.white)
																					end
																					print(text)
																					tcolor(colors.white)
																				end

																				print2("Asking for transmission permission...")

																				rednet.send(target, "~SJN@FILEMGR.SENDER:READYFORFILE")

																				print2("Send message to #"..target)
																				print2("Waiting for response (2)... Press ENTER to cancel.")

																				local timer = os.startTimer(2)

																				local okay = false

																				while (true) do
																					local event, id, msg, dis = os.pullEventRaw()
																					if (event == "timer" and id == timer) then
																						print2("No response received...", false)
																						break
																					elseif (event == "key" and id == keys.enter) then
																						print2("Canceled!", false)
																						break
																					elseif (event == "rednet_message" and id == target) then
																						if (msg == "~SJN@FILEMGR.RECEIVER:READY") then
																							print2("Target is ready for transmission.", true)
																							okay = true
																							break
																						elseif (string.find("~SJN@FILEMGR.RECEIVER:ERROR")==1) then
																							local pos = string.find(msg, "~SJN@FILEMGR.RECEIVER:ERROR#")
																							if (pos == 1) then
																								local e = string.sub(msg, pos + 1)
																								print2("Target sends error message: "..e, false)
																							else
																								print2("Target doesn't accept file transmission.", false)
																							end
																						end
																					end
																				end

																				if (okay) then
																					print2("Getting file content...")
																					local _, content = sjn.getFileContent(path)
																					print2("Content found.", true)

																					print2("Sending file...")
																					rednet.send(target, "~SJN@FILEMGR.SENDER:FILE#"..content)

																					print2("Send file content to #"..target)
																					print2("Waiting for response (2)... Press ENTER to cancel.")

																					local timer = os.startTimer(2)

																					okay = false

																					while (true) do
																						local event, id, msg, dis = os.pullEventRaw()
																						if (event == "timer" and id == timer) then
																							print2("No response received...", false)
																							break
																						elseif (event == "key" and id == keys.enter) then
																							print2("Canceled!", false)
																							break
																						elseif (event == "rednet_message" and id == target) then
																							if (msg == "~SJN@FILEMGR.RECEIVER:FILE_RECEIVED") then
																								print2("Success!", true)
																								okay = true
																								break
																							elseif (string.find(msg, "~SJN@FILEMGR.RECEIVER:ERROR")==1) then
																								local pos = string.find(msg, "~SJN@FILEMGR.RECEIVER:ERROR#")
																								if (pos == 1) then
																									local e = string.sub(msg, pos + 1)
																									print2("Target sends error message: "..e, false)
																								else
																									print2("Target doesn't accept file transmission.", false)
																								end
																							else
																								print2("Received unknown message: "..msg)
																							end
																						end
																					end
																				end

																				cpos(1, 19)
																				tcolor(colors.orange)
																				bcolor(colors.gray)
																				term.clearLine()
																				write("[SJNOS: Press any key to exit the shell.]")

																				while (true) do
																					local event = os.pullEvent()
																					if (event == "key" or event == "mouse_click") then
																						break
																					end
																				end
																			else
																				showDialog("FileTransfer", {"No valid ID!"}, {{colors.lime, colors.gray, "Okay"}})
																			end
																		end
																	else
																		showDialog("FileTransfer", {"No Rednet Modem."}, {{colors.lime, colors.gray, "Okay"}})
																	end
																elseif (y == yy + 1) then
																	--Send with Redstone
																	local path = workingDir.."/"..element.name
																	if (workingDir=="") then
																		path = element.name
																	end
																end
															end
															active2 = false
														end
													end
													draw()
												elseif (y==yy+9) then
													--Print
													local printer = sjn.getPrinter()
													local ink, paper = printer.getInkLevel(), printer.getPaperLevel()

													if (ink > 0) then
														if (paper > 0) then
															local r = showDialog("Printer", {"Are you sure you want to print", "'"..element.name .."'?"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Print"},{colors.red, COLOR_DLG_NORMAL_BG, "Cancel"}})
															draw()
															if (r == 1) then
																local page = printer.newPage()
																local page_width, page_height = printer.getPageSize()
																if (page) then
																	local path = workingDir.."/"..element.name
																	if (workingDir=="") then
																		path = element.name
																	end
																	local f = fs.open(path, "r")
																	local content = {}
																	for i=1, page_height do
																		local line = f.readLine()
																		if (line == nil) then
																			break
																		end
																		content[#content+1] = string.sub(line, 1, page_width)
																	end
																	f.close()

																	for i=1, #content do
																		printer.setCursorPos(1, i)
																		printer.write(content[i])
																	end
																	printer.setPageTitle(element.name)
																	printer.endPage()
																	showDialog("Printer", {"Printed!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
																else
																	showDialog("Printer", {"Unknown Error!!!","Check your Printer, maybe it's full."}, {{colors.red, COLOR_DLG_NORMAL_BG, "Close"}})
																end
															end
														else
															showDialog("Printer", {"You don't have paper in your printer!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
														end
													else
														showDialog("Printer", {"You don't have ink in your printer!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
													end
													draw()
												elseif (y==yy+10) then
													--Install / Deinstall
													local path = workingDir.."/"..element.name
													if (workingDir=="") then
														path = element.name
													end
													if (workingDir ~= "SJNOS/users/" .. USERNAME .. "/home/apps") then
														--Installation
														local result, e = sjn.installApp(path, USERNAME)
														if (result) then
															showDialog("Installation", {"Installation finished!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
														else
															showDialog("Installation", {"Error!", e}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
														end
														draw()
													else
														--Deinstallation
														local install = showDialog("Deinstallation", {"Do you really want to deinstall", "'"..element.name.."'?"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Deinstall"},{colors.red, COLOR_DLG_NORMAL_BG, "Cancel"}}, nil, 2)
														draw()
														if (install == 1) then
															local result, e = sjn.deinstallApp(path)
															draw()
															if (result) then
																showDialog("Deinstallation", {"Deinstallation finished!"}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
															else
																showDialog("Deinstallation", {"Error!", e}, {{colors.lime, COLOR_DLG_NORMAL_BG, "Okay"}})
															end
														end
														draw()
													end
												end
											end
										end
										active = false
										clearAndDrawMain()
									end
									clearAndDrawMain()
								end
							else
								--Directory
								local text = {" Open       "," Rename     "," Delete     "}
								cpos(19,y)
								
								bcolor(COLOR_SELECTED_BG)
								tcolor(COLOR_SELECTED_TEXT)
								
								local t = element.name
								while (#t<32) do
									t = t.." "
								end			
								write(t)
								
								bcolor(COLOR_CONTEXT_BG)
								tcolor(COLOR_CONTEXT_TEXT)
								
								if (x>39) then x = 39 end
								if (x<18) then x = 18 end
								if (y>10) then y = 10 end
								
								local xa = x
								local ya = y
								
								for i=1,#text do
									cpos(x+1,y+i)
									write(text[i])
								end
								
								local active = true
								local xx = x
								local yy = y
								
								while active do
									local event, btn, x, y = os.pullEventRaw()
									if (event=="mouse_click") then
										if (btn==1) then
											if (x>=xx and x<=xx+12) then
												if (y==yy+1) then
													--Open
													workingDir = workingDir .. "/" .. element.name
												elseif (y==yy+2) then
													--Rename
													drawMain()
													tcolor(COLOR_TEXT)
													bcolor(COLOR_BG)
													cpos(19,ya)
													write("                                ")
													cpos(19,ya)
													local name = read()

													if (not string.find(name, "/")) then
														local old_path = workingDir .. "/" .. element.name
														local new_path = workingDir .. "/" .. name
														if (not fs.exists(new_path)) then
															fs.move(old_path, new_path)
														end
													end
												elseif (y==yy+3) then
													--Delete
													local name = workingDir.."/"..element.name
													if (workingDir=="") then
														name = element.name
													end
													
													if (not fs.isReadOnly(name)) then
														if (fs.exists(name)) then
															fs.delete(name)
														end
													end
												end
											end
										end
									end
									active = false
									clearAndDrawMain()
								end
								draw()
							end
						end
					end
				end
			end
		elseif event=="mouse_scroll" then
			if (x>=14 and y>=3) then
				--MAIN
				if (#main_elements > 17) then
					local height = math.floor(289 / #main_elements)
					if (btn==1 and height+main_scroll < 17) then
						main_scroll = main_scroll + 1
						drawMain()
					elseif (btn==-1 and main_scroll > 0) then
						main_scroll = main_scroll - 1
						drawMain()
					end
				end
			end
		end
	end

	tcolor(colors.white)
	bcolor(colors.black)
	clear()
	cpos(1, 1)

	return true
end

local ok, err = pcall(start)
if not ok then
	if (not sjn.drawErrorScreen(err, tArgs[1])) then
		shell.run("SJNOS/start.exe")
	end
end
os.unloadAPI("SJNOS/system/SJNOS/sjn")