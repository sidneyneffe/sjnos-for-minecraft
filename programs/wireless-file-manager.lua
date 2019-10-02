--SJNOS by MC403. wfm.exe (8JdUff3c)

local tArgs = {...} --wfm.exe <USERNAME> <DOMAIN> <WFM_USER> <WFM_PASS>

local COLOR_TEXT = colors.orange
local COLOR_BG = colors.gray
local COLOR_HEAD_TEXT = colors.orange
local COLOR_HEAD_BG = colors.gray

local function start()


if (not term.isColor()) then
	return true
elseif (#tArgs[1] < 4) then
	error("Invalid Parameters.")
end

os.loadAPI("SJNOS/system/SJNOS/sjn")

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
local width, height = term.getSize()

local USERNAME = tArgs[1]
local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

local REDNET, REDNETSIDE = sjn.getRednet(true)

local DNS_SERVER = tonumber(sjn.getConfigFileContent("SJNOS/settings/net.set").dns)

local REFRESH_COUNTER = 100

local wfm_user = tostring(tArgs[3])
local wfm_pass = tostring(tArgs[4])
local wfm_id = -1

local KEY = -1
local SERVER = -1

local selection = 1

local FILES_homePath = 'SJNOS/users/' .. USERNAME .. "/home"
local FILES_userPath = ''
local FILES_serverPath = ''

local FILES_serverData = {}

local FILES_elements = {['y']={}, ['c']={}}

local last_refresh_string = ''

local function warning(header, text)
	local array = sjn.splitStringWithNumber('', text, 30, 18)
	sjn.showDialog(header, array, colors.lightGray, colors.white, colors.white, colors.lightGray, {{colors.lime, colors.white, "Okay"}})
end
local function showInputDialog(header, texts)
	local success, input = sjn.showInputDialog(header, texts, colors.lightGray, colors.white, colors.white, colors.lightGray, colors.orange, colors.gray, {{colors.lime, colors.white, "Okay"},{colors.red, colors.white, "Cancel"}}, nil, nil, true)
	return (success == 1), input
end

local function checkArgs()
	if (tonumber(tArgs[2]) == nil) then
		local target = tArgs[2]

		rednet.send(DNS_SERVER, "~SJN@SWEBCLIENT:GETIDOF#" .. target)

		local responded, success, result = sjn.receive(DNS_SERVER, 2, function(msg)
			if (string.find(msg, "~SJN@SWEBDNS:IDIS#")) then
				local p1, p2 = string.find(msg, "~SJN@SWEBDNS:IDIS#")
				if (#msg > p2) then
					local result = string.sub(msg, p2 + 1)
					if (tonumber(result)) then
						return true, true, math.floor(math.abs(tonumber(result)))
					end
				end
			elseif (string.find(msg, "~SJN@SWEBDNS:SERVER_NOT_REGISTERED")) then
				return true, false
			end
		end)

		if (responded) then
			if (success) then
				wfm_id = result
			else
				warning('WFM Message', "This domain is not registered on your connected DNS (#"..DNS_SERVER..").")
			end
		else
			warning('WFM Message', "No responce by the DNS. Are you sure this DNS exists and isn't busy?")
		end
	else
		wfm_id = math.floor(math.abs(tonumber(tArgs[2])))
	end

	if (wfm_id >= 0) then
		rednet.send(wfm_id, "~SJN@WFMCLIENT:LOGIN#" .. wfm_user .. '#' .. wfm_pass)
		local responded, success, key = sjn.receive(wfm_id, 2, function(msg)
			if (string.find(msg, "~SJN@WFMSERVER:LOGIN_SUCCESS#")) then
				local p1, p2 = string.find(msg, "~SJN@WFMSERVER:LOGIN_SUCCESS#")
				if (#msg > p2) then
					return true, true, string.sub(msg, p2 + 1)
				end
			elseif (string.find(msg, "~SJN@WFMSERVER:LOGIN_WRONG")) then
				return true, false
			end
		end)

		if (responded) then
			if (success) then
				KEY = key
				SERVER = wfm_id
				return true
			else
				sjn.showDialog('WFM Message', {"Username or Password wrong!"}, colors.orange, colors.gray, colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
			end
		else
			sjn.showDialog('WFM Message', {"The computer doesn't respond."}, colors.orange, colors.gray, colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
		end
	end
	return false
end

local r1, r2, r3 = checkArgs()

local ADMIN = r2 and r3 == 'true'

if (not r1 or KEY == -1 or SERVER == -1) then
	return true --True heißt hier, dass das Programm beendet wird.
end


local function sendToServer(cmd, data, data2, data3)
	local pack = {
		['data'] = data,
		['data2'] = data2,
		['data3'] = data3,
		['user'] = wfm_user,
		['password'] = wfm_pass
	}
	rednet.send(SERVER, '~SJN@WFMCLIENT:' .. cmd .. '#' .. textutils.serialize(pack))
end

local function receiveFromServer(cmd, time)
	return sjn.receive(SERVER, time or 1, function (msg)
		local _, p = string.find(msg, '~SJN@WFMSERVER:' .. cmd ..'#')
		if (p and #msg > p) then
			return true, string.sub(msg, p + 1)
		end
	end)
end

local function refresh()
	REDNET, REDNETSIDE = sjn.getRednet(true)

	if (not REDNET) then
		error('Please attach a rednet modem!')
	end

	sendToServer('GETDATA', FILES_serverPath)
	local success, raw = receiveFromServer('DATA', 2)

	last_refresh_string = sjn.getTime()

	if (success) then
		local data = textutils.unserialize(raw)
		FILES_serverData = data
		--[[
		data = {
			['list'] = {
				{['isDir']=false, ['name']='test.stp'}
			}
			['msg'] = 'Dieser Pfad existiert niacht!'
		}
		]]
		if
			false
			then
			error('Received invalid data from your WFM-Server.')
		end
	else
		error('The synchronisazion failed because your WFM-Server stopped responding.')
	end
end

local function serverPathDown(name)
	if (FILES_serverPath == "") then
		FILES_serverPath = name
	else
		FILES_serverPath = FILES_serverPath .. "/" .. name
	end
	refresh()
end

local function serverPathUp()
	local nonsense = string.reverse(FILES_serverPath)
	local p = string.find(nonsense,"/")

	if (p) then
		local sense = string.reverse(string.sub(nonsense, p + 1))
		FILES_serverPath = sense
	else
		FILES_serverPath = ""
	end
	refresh()
end

local function userPathDown(name)
	if (FILES_userPath == "") then
		FILES_userPath = name
	else
		FILES_userPath = FILES_userPath .. "/" .. name
	end
	refresh()
end

local function userPathUp()
	if (FILES_userPath == '') then
		return
	end

	local nonsense = string.reverse(FILES_userPath)
	local p = string.find(nonsense,"/")

	if (p) then
		local sense = string.reverse(string.sub(nonsense, p + 1))
		FILES_userPath = sense
	else
		FILES_userPath = ""
	end
end

local function drawMenu()
	cpos(1,1)
	tcolor(COLOR_HEAD_TEXT)
	bcolor(COLOR_HEAD_BG)
	term.clearLine()
	cpos(1, 1)
	write("WFM #"..SERVER)

	tcolor(colors.lightGray)
	if (selection == 1) then
		tcolor(colors.lime)
	end
	cpos(36, 1)
	write("Terminal")

	tcolor(colors.lightGray)
	if (selection == 2) then
		tcolor(colors.lime)
	end
	cpos(45, 1)
	write("Files")

	cpos(51, 1)
	tcolor(colors.red)
	write("X")
end

local function drawMain()
	tcolor(COLOR_TEXT)
	bcolor(COLOR_BG)
	if (selection == 1) then
		--Terminal
		cpos(1, 19)
		tcolor(colors.lightGray)
		write("Click anywhere to enter a command.")
	elseif (selection == 2) then
		--Files
		local width_left = 25
		local pos_right = width_left + 2
		local width_right = width - pos_right

		tcolor(colors.white)
		bcolor(colors.gray)
		for y=2, height do
			cpos(1, y)
			write(string.rep(" ", width_left))
		end
		local temp = 'Your PC'
		cpos((width_left - #temp) / 2 + 1, 2)
		write(temp)

		cpos(1, 3)
		if (FILES_userPath == '') then
			write("H:/")
		else
			write(string.sub("H:/" .. FILES_userPath, 1, width_left - 1))
		end
		cpos(width_left, 3)
		write("^")

		FILES_elements.y = {}
		local y_elements = {["dir"]={}, ["file"]={}}
		local list = fs.list(FILES_homePath .. "/" .. FILES_userPath)

		for i=1, #list do
			if (fs.isDir(FILES_homePath .. "/" .. FILES_userPath .. "/" .. list[i])) then
				table.insert(y_elements.dir, list[i])
			else
				table.insert(y_elements.file, list[i])
			end
		end

		for i=1, #y_elements.dir do
			cpos(1, i + 3)
			write("[=] " .. y_elements.dir[i])
			table.insert(FILES_elements.y, {['name'] = y_elements.dir[i], ['isDir'] = true})
		end
		for i=1, #y_elements.file do
			cpos(1, i + 3 + #y_elements.dir)
			write("-~- " .. y_elements.file[i])
			table.insert(FILES_elements.y, {['name'] = y_elements.file[i], ['isDir'] = false})
		end


		tcolor(colors.yellow)
		bcolor(colors.gray)
		for y=2, height do
			cpos(pos_right, y)
			write(string.rep(" ", width_right))
		end
		local temp = 'Connected PC'
		cpos((width_right - #temp) / 2 + pos_right, 2)
		write(temp)

		cpos(pos_right, 3)
		write(string.sub("S:/" .. FILES_serverPath, 1, width_right - 1))
		cpos(pos_right + width_right, 3)
		write("^")


		local data = FILES_serverData

		if (data.msg) then
			local array = sjn.splitStringWithNumber('', data.msg, width_right - 2, 16)
			for i=1, #array do
				cpos(pos_right + 1, i + 3)
				write(array[i])
			end
		else
			FILES_elements.c = {}
			local c_elements = {["d"]={}, ["f"]={}}

			for i=1, #data.list do
				if (data.list[i].isDir) then
					table.insert(c_elements.d, data.list[i])
				else
					table.insert(c_elements.f, data.list[i])
				end
			end

			for i=1, #c_elements.d do
				cpos(pos_right, i + 3)
				write("[=] " .. c_elements.d[i].name)
				table.insert(FILES_elements.c, c_elements.d[i])
			end
			for i=1, #c_elements.f do
				cpos(pos_right, i + 3 + #c_elements.d)
				write("-~- " .. c_elements.f[i].name)
				table.insert(FILES_elements.c, c_elements.f[i])
			end
		end


		cpos(1, 19)
		tcolor(colors.lightGray)
		write("Last update: " ..last_refresh_string)
	end
end

local function draw()
	bcolor(COLOR_BG)
	clear()
	drawMenu()
	drawMain()
end

refresh()
draw()

local running = true

local timer = os.startTimer(1)

while running do
	if (selection == 2) then
		draw()
	end

	local event, p1, p2, p3, p4, p5 = os.pullEventRaw()
	if (event=="mouse_click") then
		local btn, x, y = p1, p2, p3
		if (x == 51 and y == 1) then
			--Quit
			break
		elseif (x>=36 and x<=43 and y==1 and selection ~= 1) then
			--Terminal
			selection = 1
		elseif (x>=45 and x<=50 and y==1 and selection ~= 2) then
			--Files
			selection = 2
		elseif (selection == 1) then
			--Terminal Inner
			if btn == 1 then
				term.scroll(1)
				drawMenu()
				cpos(1, 19)
				tcolor(colors.orange)
				bcolor(colors.gray)
				write("$ ")
				local input = read()

				tcolor(colors.lightGray)
				if (input == 'help') then
					print("$update      Updates your Server.                  ")
				  --print("                                                   ")
				elseif (input == 'update') then
					print('Sending request...')
					sendToServer('UPDATE')
					local success, raw = receiveFromServer('RESULT')
					if (success) then
						tcolor(colors.lime)
						print('Server: ' .. (textutils.unserialize(raw).result or '%'))
						tcolor(colors.yellow)
						print('This PC will idle for 10 seconds now. Please do nothing!')
						receiveFromServer('RESULT', 10)

						refresh()
						tcolor(colors.lime)
						print('\nUpdated!')
					else
						tcolor(colors.red)
						print('No response. Maybe the update has failed.')
					end
				end

				drawMenu()
			end
		elseif (selection == 2) then
			--Files Inner
			if (x < 26) then
				--Your PC
				if (y == 3) then
					if (x == 25) then
						-- Pfad einen höher
						userPathUp()
					end
				elseif (y > 3 and y <= #FILES_elements.y + 3) then
					local element = FILES_elements.y[y - 3]
					if (element.isDir) then
						if (btn == 1) then
							userPathDown(element.name)
						end
					else
						if (btn == 1) then

						elseif (btn == 2) then
							local menu = {" Upload     "," Edit       "," Rename     "," Delete     "," Execute    "}
							bcolor(colors.orange)
							tcolor(colors.white)
							cpos(5, y)
							local t = element.name
							write(t .. string.rep(" ", 25 - 5 - #t))

							local xa = x
							local ya = y

							if (x > 25 - #menu[1]) then xa = 25 - #menu[1] end
							if (x < 5) then xa = 5 end
							if (y > 19 - #menu) then ya = 19 - #menu end

							bcolor(colors.white)
							tcolor(colors.orange)

							for i=1, #menu do
								cpos(xa, ya + i)
								write(menu[i])
							end

							local active = true

							while active do
								local event, btn, x2, y2 = os.pullEventRaw()
								if (event=="mouse_click") then
									if (x2 >= xa and x2 <= xa + 12) then
										if (y2 > ya and y2 <= ya + #menu) then
											if (y2 == ya + 1) then
												--Upload
												local content = sjn.getFileAll(FILES_homePath .. "/" .. FILES_userPath .. '/' .. element.name)

												sendToServer('UPLOAD', FILES_serverPath .. "/" .. element.name, content)
												local success, raw = receiveFromServer('RESULT')
												if (success) then
													warning("Upload", 'Server: ' .. textutils.unserialize(raw).msg)
													refresh()
												else
													warning("Upload", 'Upload failed.')
												end
											elseif (y2 == ya + 2) then
												--Edit
												shell.run("edit", FILES_homePath .. "/" .. FILES_userPath .. "/" .. element.name)
											elseif (y2 == ya + 3) then
												--Rename
												draw()
												cpos(5, y)
												tcolor(colors.white)
												bcolor(colors.gray)
												write(string.rep(" ", 25-5))
												cpos(5, y)
												local input = read()

												if input and input ~= '' then
													if not string.find(input, '%.%.') then
														if not (string.find(input, '/') or string.find(input, '\\')) then
															local old_path = FILES_homePath .. '/' .. FILES_userPath .. '/' .. element.name
															local path = FILES_homePath .. '/' .. FILES_userPath .. '/' .. input
															if not fs.exists(path) then
																fs.move(old_path, path)
															else
																warning("Rename", "File exists!")
															end
														else
															warning("Rename", "Please don't use '/' and '\\'!")
														end
													else
														warning("Rename", "Please don't use '..'!")
													end
												end
											elseif (y2 == ya + 4) then
												--Delete
												fs.delete(FILES_homePath .. "/" .. FILES_userPath .. "/" .. element.name)
											elseif (y2 == ya + 5) then
												--Execute
												sjn.consoleStart('$ run H:/' .. FILES_userPath .. '/' .. element.name)

												shell.run(FILES_homePath .. "/" .. FILES_userPath .. "/" .. element.name)

												sjn.consoleEnd()
											end
											active = false
										else
											active = false
										end
									else
										active = false
									end
								end
							end
						end
					end
				else
					if btn == 2 then
						local menu = {" New File   "," New Folder "}
						bcolor(colors.orange)
						tcolor(colors.white)
						cpos(5, y)

						local xa = x
						local ya = y - 1

						if (x > 25 - #menu[1]) then xa = 25 - #menu[1] end
						if (x < 5) then xa = 5 end
						if (y > 19 - #menu) then ya = 19 - #menu end

						bcolor(colors.white)
						tcolor(colors.orange)

						for i=1, #menu do
							cpos(xa, ya + i)
							write(menu[i])
						end

						local active = true

						while active do
							local event, btn, x2, y2 = os.pullEventRaw()
							if (event=="mouse_click") then
								if (x2 >= xa and x2 <= xa + 12) then
									if (y2 > ya and y2 <= ya + #menu) then
										if (y2 == ya + 1) then
											--New File
											local success, input = showInputDialog('New File', {'Create a new file:'})

											if success and input ~= '' then
												if not (string.find(input, '%.%.') or string.find(input, '/') or string.find(input, '\\')) then
													local path = FILES_homePath .. '/' .. FILES_userPath .. '/' .. input
													if not fs.exists(path) then
														local f = fs.open(path, 'w')
														f.close()
													else
														warning("New File", "File exists!")
													end
												else
													warning("New File", "Please don't use '..' and '/' and '\\'!")
												end
											end
										elseif (y2 == ya + 2) then
											--New Folder
											local success, input = showInputDialog('New Folder', {'Create a new folder:'})
											if success and input and input ~= '' then
												if not (string.find(input, '%.%.') or string.find(input, '/') or string.find(input, '\\')) then
													local path = FILES_homePath .. '/' .. FILES_userPath .. '/' .. input
													if not fs.exists(path) then
														fs.makeDir(path)
													else
														warning("New Folder", "File exists!")
													end
												else
													warning("New Folder", "Please don't use '..' and '/' and '\\'!")
												end
											end
										end
										active = false
									else
										active = false
									end
								else
									active = false
								end
							end
						end
					end
				end
			elseif (x > 26) then
				--Connected PC
				if (y == 3) then
					if (x == 51) then
						-- Pfad einen höher
						serverPathUp()
					end
				elseif (not FILES_serverData.msg) then
					if (y > 3 and y <= #FILES_elements.c + 3) then
						local element = FILES_elements.c[y - 3]
						if (element.isDir) then
							if (btn == 1) then
								serverPathDown(element.name)
							end
						else
							if (btn == 1) then
							elseif (btn == 2) then
								local menu = {" Download   "," Edit       "," Rename     "," Delete     "," Execute    "}
								bcolor(colors.orange)
								tcolor(colors.white)
								cpos(27 + 4, y)
								local t = element.name
								write(t .. string.rep(" ", 51 - 27 - 4 - #t))

								local xa = x + 0
								local ya = y + 0

								if (x > 51 - #menu[1]) then xa = 51 - #menu[1] end
								if (x < 27 + 4) then xa = 27 + 4 end
								if (y > 19 - #menu) then ya = 19 - #menu end

								bcolor(colors.white)
								tcolor(colors.orange)

								for i=1, #menu do
									cpos(xa, ya + i)
									write(menu[i])
								end

								local active = true

								while active do
									local event, btn, x2, y2 = os.pullEventRaw()
									if (event=="mouse_click") then
										if (x2 >= xa and x2 <= xa + 12) then
											if (y2 > ya and y2 <= ya + #menu) then
												if (y2 == ya + 1) then
													--Download
													sendToServer('DOWNLOAD', FILES_serverPath .. '/' .. element.name)
													local success, raw = receiveFromServer('CONTENT')
													if (success) then
														local download_path = FILES_homePath .. '/' .. FILES_userPath .. '/' .. element.name

														if (not fs.isReadOnly(download_path)) then
															download_path = sjn.getAltFileName(download_path)

															local f = fs.open(download_path, "w")
															f.write(textutils.unserialize(raw).content)
															f.close()
														else
															warning("Download", 'Can\'t download in a read-only path. Please select a path that isn\'t in \'C:/rom/\'')
														end
													else
														warning("Download", 'Download failed. Try again.')
													end
												elseif (y2 == ya + 2) then
													--Edit
													sendToServer('DOWNLOAD', FILES_serverPath .. '/' .. element.name)
													local success, raw = receiveFromServer('CONTENT')
													if (success) then
														local download_path = 'SJNOS/users/' .. USERNAME ..'/temp/.wfm_download'

														local f = fs.open(download_path, "w")
														f.write(textutils.unserialize(raw).content)
														f.close()
														if (shell.run("edit", download_path)) then
															local f = fs.open(download_path, "r")
															local c = f.readAll()
															f.close()

															if (c ~= textutils.unserialize(raw).content) then
																--Es wurde etwas geändert.
																sendToServer('UPLOAD', FILES_serverPath .. '/' .. element.name, c)
																local success, raw = receiveFromServer('RESULT')
																if (success) then
																	warning("Edit", 'Server: ' .. textutils.unserialize(raw).msg)
																else
																	warning("Edit", 'Upload failed.')
																end
															end
														end
													else
														warning("Edit", 'Can\'t edit because the download failed. Try again.')
													end
												elseif (y2 == ya + 3) then
													--Rename
													draw()
													cpos(31, y)
													tcolor(colors.yellow)
													bcolor(colors.gray)
													write(string.rep(" ", 51-31))
													cpos(31, y)
													local input = read()

													if input and input ~= '' then
														if not string.find(input, '%.%.') then
															if not (string.find(input, '/') or string.find(input, '\\')) then
																local path = FILES_serverPath .. '/' .. input

																sendToServer('MOVE', FILES_serverPath .. '/' .. element.name, FILES_serverPath .. '/' .. input)
																local success, raw = receiveFromServer('RESULT')
																if (success) then
																	if (textutils.unserialize(raw).result) then
																		warning("Rename", 'Server: ' .. textutils.unserialize(raw).result)
																		refresh()
																	else
																		warning("Rename", 'Invalid response.')
																	end
																else
																	warning("Rename", "No response.")
																end
															else
																warning("Rename", "Please don't use '/' and '\\'!")
															end
														else
															warning("Rename", "Please don't use '..'!")
														end
													end
												elseif (y2 == ya + 4) then
													--Delete
													sendToServer('DELETE', FILES_serverPath .. '/' .. element.name)
													local success, raw = receiveFromServer('RESULT')
													if (success) then
														if (textutils.unserialize(raw).msg) then
															warning("Delete", 'Server: ' .. textutils.unserialize(raw).msg)
															refresh()
														end
													else
														warning("Delete", "No response.")
													end
												elseif (y2 == ya + 5) then
													--Execute
													if sjn.showConfirmDialog('Execute', {"Do you really want to run", "'"..element.name.."'?", "It may damage your server!", "Maybe you will lose this connection."}, colors.lightGray, colors.white, colors.white, colors.lightGray, 2) then
														sendToServer('EXECUTE', FILES_serverPath .. '/' .. element.name)
														local success, raw = receiveFromServer('RESULT')
														if (success) then
															if (textutils.unserialize(raw).result) then
																warning("Execute", 'Server: ' .. textutils.unserialize(raw).result)
															else
																warning("Execute", 'Invalid response.')
															end
														else
															warning("Execute", "No response.")
														end
													end
												end
												active = false
											else
												active = false
											end
										else
											active = false
										end
									end
								end
							end
						end
					end
				end
				timer = os.startTimer(1)
			end
		end
	elseif (event == 'modem_message') then
		local side, channel, id, msg, dis = p1, p2, p3, p4, p5
		if (id == SERVER) then

		end
	elseif (event == 'timer' and timer == p1) then
		timer = os.startTimer(1)
		refresh()
	end
end

return true
end

sjn.program(start)
os.unloadAPI("SJNOS/system/SJNOS/sjn")
