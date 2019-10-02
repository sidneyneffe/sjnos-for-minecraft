--SJNOS by MC403. network.sys (vpwucSht)

local tArgs = {...}

local COLOR_TEXT = colors.cyan
local COLOR_BG = colors.white
local COLOR_HEAD_TEXT = colors.orange
local COLOR_HEAD_BG = colors.cyan
local COLOR_SIDE_TEXT = colors.cyan
local COLOR_SIDE_BG = colors.lightGray
local COLOR_SIDE_SEL_TEXT = colors.white
local COLOR_SIDE_SEL_BG = colors.orange


local COLOR_INTERNET_NETINFO_TEXT = colors.gray
local COLOR_INTERNET_NETINFO_BG = colors.yellow
local COLOR_INTERNET_START_TEXT = colors.black
local COLOR_INTERNET_START_BG = colors.orange
local COLOR_INTERNET_HELP_ADRESS = colors.lightGray

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

	local DNS_SERVER = tonumber(sjn.getConfigFileContent("SJNOS/settings/net.set").dns)

	local GPS_POSTION = {}

	local WFM_login_with_domain = true
	local WFM_login_domain = ''
	local WFM_login_id = ''
	local WFM_login_username = ''
	local WFM_login_password = ''

	local REFRESH_COUNTER = 100

	local selected = 1

	local function refresh(a)
		REDNET, REDNETSIDE = sjn.getRednet(true)

		if (selected == 6 and REDNET) then
			--GPS
			REFRESH_COUNTER = REFRESH_COUNTER + 1
			if (REFRESH_COUNTER > 20 or a == true) then
				REFRESH_COUNTER = 0
				local x, y, z = gps.locate(0.1)
				GPS_POSTION = {["x"] = x, ["y"] = y, ["z"] = z}
			end
		end
	end

	refresh()

	local sidebar = {" Network  "," Internet "," Mails    "," Turtles  "," Rednet   "," GPS      "," WFM      "," Help     ",	" Options  "}
	local programmed = {false, true, false, false, true, true, true, false, false}

	local function drawMenu()
		bcolor(COLOR_BG)
		clear()
		cpos(1,1)
		tcolor(COLOR_HEAD_TEXT)
		bcolor(COLOR_HEAD_BG)
		term.clearLine()
		cpos(1,1)
		write("Network")
		cpos(45,1)
		write(getTime())
		cpos(51, 1)
		tcolor(colors.black)
		bcolor(colors.red)
		write("X")
	end

	local function drawSide()

		for i=1,#sidebar do
			cpos(1,i+1)
			if (i==selected) then
				tcolor(COLOR_SIDE_SEL_TEXT)
				bcolor(COLOR_SIDE_SEL_BG)
			elseif (programmed[i]) then
				tcolor(COLOR_SIDE_TEXT)
				bcolor(COLOR_SIDE_BG)
			else
				tcolor(colors.red)
				bcolor(COLOR_SIDE_BG)
			end
			write(sidebar[i])
		end

		for i=#sidebar+2,19 do
			cpos(1,i)
			bcolor(COLOR_SIDE_BG)
			write("          ")
		end
	end

	local function notWithoutRednetAvailable(text)
		cpos(12,3)
		write("Sorry, " .. text .. " is")
		cpos(12,4)
		write("without Rednet not available.")
	end

	local function drawMain()
		tcolor(COLOR_TEXT)
		bcolor(COLOR_BG)
		local s = selected
		if (s==1) then
			--Network
			cpos(11,2)
			write("Network")
		elseif (s==2) then
			--Internet
			if (REDNET) then
				cpos(26,3)
				write("Internet")

				cpos(48,2)
				write("HELP")

				cpos(13,5)
				tcolor(COLOR_TEXT)
				write("Normal Website  ")
				tcolor(COLOR_INTERNET_HELP_ADRESS)
				write("stp://".."domain.com")
				cpos(13,6)
				tcolor(COLOR_TEXT)
				write("Local File      ")
				tcolor(COLOR_INTERNET_HELP_ADRESS)
				write("loc://".."files/hi.stp")
				cpos(13,7)
				tcolor(COLOR_TEXT)

				bcolor(COLOR_INTERNET_START_BG)
				tcolor(COLOR_INTERNET_START_TEXT)
				cpos(22,14)
				write("                ")
				cpos(22,15)
				write(" Start Browsing ")
				cpos(22,16)
				write("                ")

				cpos(11,19)
				bcolor(COLOR_INTERNET_NETINFO_BG)
				tcolor(COLOR_INTERNET_NETINFO_TEXT)
				write("                                         ")
				cpos(11,19)
				write(" NET-INFO: DNS="..DNS_SERVER)
			else
				notWithoutRednetAvailable("Internet")
			end
		elseif (s==3) then
			--Mails
			cpos(11,2)
			write("Mails")
		elseif (s==4) then
			--Turtles
			local text = "Turtles"
			cpos((width-12-#text) / 2 + 12, 3)
			write(text)

			local turtles = 0

			local function advanced_write(text, x, y, condition)
				if (condition) then
					tcolor(colors.lime)
				else
					tcolor(colors.red)
				end
				cpos(x, y)
				write(text)
				tcolor(COLOR_TEXT)
			end

			cpos(25, 5)
			write("Turtles")
			advanced_write(tostring(turtles), 35, 5, (turtles > 0))

			tcolor(colors.cyan)
			bcolor(colors.orange)
			cpos(22, 15)
			write(" Start ")
		elseif (s==5) then
			--Rednet
			local text = "Rednet"
			cpos((width-12-#text) / 2 + 12, 3)
			write(text)

			cpos(12, 5)
			write("Status:   ")
			if (REDNET) then
				tcolor(colors.lime)
				write("online")
			else
				tcolor(colors.red)
				write("offline")
			end
			cpos(12, 6)
			tcolor(COLOR_TEXT)
			write("Side:     " .. REDNETSIDE)
			cpos(12, 7)
			write("ID:       " .. os.getComputerID())
		elseif (s==6) then
			--GPS
			local text = "GPS"
			cpos((51-#text-10)/2+10, 3)
			write(text)

			if (REDNET) then
				local function advanced_write(text, x, y, condition)
					if (condition) then
						tcolor(colors.lime)
					else
						tcolor(colors.red)
					end
					cpos(x, y)
					write(text)
					tcolor(COLOR_TEXT)
				end
				local function write2(text, x, y)
					cpos(x, y)
					write(text)
				end
				local function button(text, x, y)
					cpos(x, y)
					tcolor(colors.cyan)
					bcolor(colors.orange)
					write(text)
					tcolor(COLOR_TEXT)
					bcolor(COLOR_BG)
				end

				write2("X:", 13, 5)
				advanced_write((GPS_POSTION.x or "none"), 16, 5, GPS_POSTION.x ~= nil)
				write2("Y:", 13, 6)
				advanced_write((GPS_POSTION.y or "none"), 16, 6, GPS_POSTION.y ~= nil)
				write2("Z:", 13, 7)
				advanced_write((GPS_POSTION.z or "none"), 16, 7, GPS_POSTION.z ~= nil)

				button(" Advanced ", 25, 10)
				button(" Refresh  ", 25, 12)
			else
				cpos(16, 5)
				write("No Connection! Please put a ")
				cpos(16, 6)
				write("modem next to your computer!")
			end
		elseif (s==7) then
			--WFM

			if (not REDNET) then
				notWithoutRednetAvailable("WFM")
				return
			end

			cpos(20, 3)
			write("Wireless File Manager v1")


			tcolor(colors.cyan)
			bcolor(colors.orange)
			if (WFM_login_with_domain) then
				bcolor(colors.lime)
			end
			cpos(22, 5)
			write(" Domain ")
			bcolor(COLOR_BG)
			write("  ")
			bcolor(colors.orange)
			if (not WFM_login_with_domain) then
				bcolor(colors.lime)
			end
			write("   ID   ")

			tcolor(colors.orange)
			bcolor(colors.gray)
			cpos(22, 6)
			write("                  ")
			cpos(22, 6)
			if (WFM_login_with_domain) then
				write(WFM_login_domain)
			else
				write(WFM_login_id)
			end

			cpos(22, 8)
			if (WFM_login_username == '') then
				write("Username          ")
			else
				write("                  ")
				cpos(22, 8)
				write(WFM_login_username)
			end

			cpos(22, 10)
			if (WFM_login_password == '') then
				write("Password          ")
			else
				write("                  ")
				cpos(22, 10)
				write(string.rep("*", #WFM_login_password))
			end

			bcolor(COLOR_BG)
			tcolor(COLOR_TEXT)

			tcolor(colors.cyan)
			bcolor(colors.lightGray)
			if (WFM_login_username ~= '' and WFM_login_password ~= '' and ((WFM_login_with_domain and WFM_login_domain ~= '') or (not WFM_login_with_domain and WFM_login_id ~= ''))) then
				bcolor(colors.orange)
			end
			cpos(27, 13)
			write(" Login ")

			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
			cpos(12, 16)
			write("Use the this tool to manage another    ")
			cpos(12, 17)
			write("computer or a web-server. Just setup an")
			cpos(12, 18)
			write("account on that PC and login here.")
		elseif (s==8) then
			--Help
			cpos(11,2)
			write("Help")
		elseif (s==9) then
			--Options
			cpos(11,2)
			write("Options")
		end
	end

	local function draw(a)
		drawMenu()
		drawSide()
		drawMain()
		refresh(a)
	end

	local running = true

	local timer = os.startTimer(1)

	while running do
		draw()
		local event, btn, x, y = os.pullEvent()
		if (event=="mouse_click") then
			if (x == 51 and y == 1) then
				--Quit
				running = false
				bcolor(colors.black)
				tcolor(colors.white)
				clear()
				cpos(1, 1)
			elseif (x<=8 and y==1) then
				--Menu
			elseif (x<=10 and y>=1 and y<=#sidebar) then
				--Side
				selected = y-1
				draw((selected == 6))
			elseif (selected==2) then
				--INTERNET
				if (x>=48 and y==2) then
					--help
					bcolor(COLOR_BG)
					clear()
					cpos(1,1)
					tcolor(COLOR_HEAD_TEXT)
					bcolor(COLOR_HEAD_BG)
					term.clearLine()
					write(" Network - HELP!")
					cpos(51,1)
					tcolor(colors.black)
					bcolor(colors.red)
					write("X")
					cpos(1,2)
					tcolor(COLOR_TEXT)
					bcolor(COLOR_BG)
					print("  The Internet is very useful. You can visit sides,")
					print("chat and buy stuff. Now, with SJNOS, the Internet  ")
					print("in Minecraft is invented. Now, you can visit Websi-")
					print("tes. You can do this with an adress. For example   ")
					tcolor(COLOR_INTERNET_HELP_ADRESS)
					write("stp://sjnos.com")
					tcolor(COLOR_TEXT)
					print(" lets you connect to a server which  ")
					print("name is - sjnos.com. You can setup a server with   ")
					print("the SJNOS-Installer, but you also need a DNS.      ")
					print(" You can also access files in your HOME-Directory  ")
					print("(SJNOS/users/<YOURNAME>/home) with 'loc://'.       ")
					print("  S-WEB supports 3 formats. '.stp' (SJN Web File)  ")
					print("is a normal website. '.img' is an image. And '.txt'")
					print("and everything else is text. SWF is an own program-")
					print("ming language and has a very easy syntax. You will ")
					write("learn it very fast. I hope this help helped you :-)")

					while true do
						local event, btn, x, y = os.pullEventRaw()
						if (event=="mouse_click" and btn==1 and x==51 and y==1) then
							break
						end
					end

					draw()

				elseif (x>=22 and x<=38 and y>=14 and y<=16) then
					--start browsing
					shell.run('SJNOS/data/programs/internet.exe', USERNAME)
				end
			elseif (selected == 4) then
				--Turtles
				if (x >= 22 and x < 29 and y == 15) then
					local STATUS_TYPE_NORMAL, STATUS_TYPE_WORKING, STATUS_TYPE_ERROR = 1, 2, 3
					local TYPE_COLORS = {colors.cyan, colors.lime, colors.red}

					local DIALOG_NORMAL, DIALOG_MENU = 1, 2
					local dialog = DIALOG_NORMAL

					local VIEW_LIST, VIEW_SIDEBAR = 1, 2
					local view = VIEW_LIST

					local sidebar_selected = 1
					local sidebar_scroll = 0

					local turtledata = {}

					for i=1, 50 do
						turtledata[i] = {
							["name"]="Test "..i,
							["id"]=0,
							["status"]=tostring(i),
							["stype"]=STATUS_TYPE_NORMAL,
							["modus"]=math.random(4),
							["fuel"]=math.random(2000)-1,
							["position"] = {
								["x"]=math.random(3000)-1500,
								["y"]=math.random(150),
								["z"]=math.random(3000)-1500},
							["type"] = math.random(7)
						}
					end

					local function turtlesRefresh()
					end

					local function turtlesDrawHeader()
						bcolor(colors.white)
						clear()

						cpos(1, 1)
						bcolor(COLOR_HEAD_BG)
						term.clearLine()

						tcolor(COLOR_HEAD_TEXT)
						write("Turtles")

						cpos(47, 1)
						tcolor(COLOR_HEAD_TEXT)
						bcolor(COLOR_HEAD_BG)
						write(getTime())

						tcolor(colors.cyan)
						bcolor(colors.white)
					end

					local function turtlesDrawMain()
						if (#turtledata < sidebar_selected) then
							sidebar_selected = 1
						end

						if (#turtledata < 19) then
							sidebar_scroll = 0
						end
						local sidebar_width = 13
						local scroll = #turtledata > 18

						local scroll_bar_height, scroll_position = 0, 0

						if (scroll) then
							sidebar_width = 12

							scroll_bar_height = math.floor(18/#turtledata * 18)
							scroll_position = math.ceil(sidebar_scroll / #turtledata * (18))
						end

						if (view == VIEW_LIST) then
							if (#turtledata == 0) then
								cpos(1, 2)
								write("No Turtles found.")
							else
								local y = 1
								for i=sidebar_scroll+1, sidebar_scroll+18 do
									if (turtledata[i] == nil) then
										break
									end
									y = y + 1

									local data = turtledata[i]
									cpos(1, y)

									write(string.sub(data.name, 1, 22))

									cpos(23, y)
									write("#"..data.id)

									cpos(30, y)
									tcolor(TYPE_COLORS[data.stype])
									write(data.status)

									tcolor(COLOR_TEXT)
								end

								bcolor(colors.gray)
								for i=1, scroll_bar_height do
									cpos(51, i + 1 + scroll_position)
									write(" ")
								end
							end
						elseif (view == VIEW_SIDEBAR) then
							if (#turtledata == 0) then
								cpos(1, 2)
								write("No Turtles found.")
							else
								if (scroll) then
									bcolor(colors.gray)
									for i=1, scroll_bar_height do
										cpos(sidebar_width + 1, i + 1 + scroll_position)
										write(" ")
									end
								end

								bcolor(colors.lightGray)
								for y=2, 19 do
									cpos(1, y)
									write(string.rep(" ", sidebar_width))
								end

								local y = 1
								for i=sidebar_scroll+1, sidebar_scroll+18 do
									if (turtledata[i] == nil) then
										break
									end

									y = y + 1

									if (i ~= sidebar_selected) then
										tcolor(colors.cyan)
										bcolor(colors.lightGray)
									else
										tcolor(colors.white)
										bcolor(colors.orange)
									end

									local data = turtledata[i]
									cpos(1, y)
									local name = " "..string.sub(data.name, 1, sidebar_width-1)

									if (#name < sidebar_width) then
										name = name .. string.rep(" ", sidebar_width-#name)
									end

									write(name)
								end

								local data = turtledata[sidebar_selected]

								tcolor(COLOR_TEXT)
								bcolor(COLOR_BG)

								cpos((width - #data.name - sidebar_width)/2 + sidebar_width, 3)
								write(data.name)

								local col1, col2 = 20, 30

								local function advanced_write(text, x, y, condition)
									if (condition == true) then
										tcolor(colors.lime)
									elseif (condition == false) then
										tcolor(colors.red)
									else
										tcolor(COLOR_TEXT)
									end
									cpos(x, y)
									write(text)
									tcolor(COLOR_TEXT)
								end


								cpos(col1, 5)
								write("Status")
								tcolor(TYPE_COLORS[data.stype])
								cpos(col2, 5)
								write(data.status)

								tcolor(COLOR_TEXT)
								cpos(col1, 6)
								write("Modus")
								local MODI = {"None", "Control", "Auto", "Job"}
								advanced_write(MODI[data.modus], col2, 6, data.modus~=1)

								cpos(col1, 7)
								write("Fuel")
								advanced_write(data.fuel, col2, 7, (data.fuel~=0))

								cpos(col1, 8)
								write("Position")
								advanced_write(data.position.x .. " / " .. data.position.y .. " / " .. data.position.z, col2, 8)

								cpos(col1, 9)
								write("Type")
								local TYPES = {"Normal", "Melee", "Digging", "Liquid", "Mining", "Felling", "Farming"}
								advanced_write(TYPES[data.type], col2, 9)
							end
						end

						if (dialog == DIALOG_MENU) then
							cpos(1, 1)
							bcolor(colors.gray)
							tcolor(colors.orange)
							write("Turtles ")

							local v = " List View "
							if (view == VIEW_LIST) then
								v = " Side View "
							end

							local head = {v, " Quit      "}
							for i=1, #head do
								cpos(1, i+1)
								write(head[i])
							end
						end
					end

					local function turtlesDraw()
						turtlesRefresh()
						turtlesDrawHeader()
						turtlesDrawMain()
					end

					local turtle = true
					local timer = os.startTimer(1)

					while (turtle) do
						turtlesDraw()

						local event, btn, x, y = os.pullEvent()

						if (dialog == DIALOG_NORMAL) then
							if (y == 1 and x <= 8 and event == "mouse_click") then
								--Menu
								dialog = DIALOG_MENU
							elseif (view == VIEW_LIST) then
								if (event == "mouse_click") then

								elseif (event == "mouse_scroll") then
									if (#turtledata > 18) then
										local new = sidebar_scroll + btn
										if (new >= 0 and new <= #turtledata-18) then
											sidebar_scroll = new
										end
									end
								end
							elseif (view == VIEW_SIDEBAR) then
								if (event == "mouse_click") then
									if (y - 1 <= #turtledata and x <= 13) then
										sidebar_selected = y - 1 + sidebar_scroll
									end
								elseif (event == "mouse_scroll") then
									if (y > 1 and x <= 13) then
										if (#turtledata > 18) then
											local new = sidebar_scroll + btn
											if (new >= 0 and new <= #turtledata-18) then
												sidebar_scroll = new
											end
										end
									end
								end
							end
						elseif (dialog == DIALOG_MENU) then
							if (event == "mouse_click") then
								if (x <= 10 and y > 1 and y <= 3) then
									--Menu
									if (y == 2) then
										--Change View
										if (view == VIEW_LIST) then
											view = VIEW_SIDEBAR
										else
											view = VIEW_LIST
										end
									elseif (y == 3) then
										--Quit
										turtle = false
									end
								end
								dialog = DIALOG_NORMAL
							end
						end
						timer = os.startTimer(3)
					end
				end
			elseif (selected==6) then
				--GPS
				if (x >= 25 and x < 35 and y == 10) then
					--Advanced-Button
					bcolor(colors.black)
					clear()
					cpos(1, 1)
					tcolor(colors.orange)
					print("$ gps locate")
					tcolor(colors.white)
					shell.run("gps locate")
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
				elseif (x >= 25 and x < 35 and y == 12) then
					--Refresh
					refresh(true)
					cpos(1,1)
					cpos(25, 12)
					bcolor(colors.lime)
					for i=1,10 do
						write(" ")
						sleep(0.02)
					end
				end
			elseif (selected == 7) then
				--WFM
				if (y == 5) then
					if (x >= 22 and x < 30) then
						--Select Domain
						WFM_login_with_domain = true
					elseif (x >= 32 and x <= 40) then
						--Select ID
						WFM_login_with_domain = false
					end
				elseif (y == 6) then
					--Domain / ID
					cpos(22, 6)
					tcolor(colors.orange)
					bcolor(colors.gray)
					write("                  ")
					cpos(22, 6)
					local input = read()
					if (not WFM_login_with_domain) then
						if (input == '') then
							WFM_login_id = ''
						elseif (tonumber(input) == nil)  then
							WFM_login_id = 0
						else
							WFM_login_id = math.floor(math.abs(input))
						end
					else
						WFM_login_domain = input;
					end
				elseif (y == 8) then
					--Username
					cpos(22, 8)
					tcolor(colors.orange)
					bcolor(colors.gray)
					write("                  ")
					cpos(22, 8)
					WFM_login_username = read()
				elseif (y == 10) then
					--Password
					cpos(22, 10)
					tcolor(colors.orange)
					bcolor(colors.gray)
					write("                  ")
					cpos(22, 10)
					WFM_login_password = read('*')
				elseif (y == 13 and x >= 27 and x < 34) then
					--Login
					if (WFM_login_username ~= '' and WFM_login_password ~= '' and ((WFM_login_with_domain and WFM_login_domain ~= '') or (not WFM_login_with_domain and WFM_login_id ~= ''))) then
						local username = WFM_login_username .. ''
						local password = WFM_login_password .. ''

						local data = WFM_login_id
						if (WFM_login_with_domain) then
							data = WFM_login_domain
						end

						shell.run("SJNOS/data/programs/wfm.exe", USERNAME, data, username, password)
					end
				end
			end
		end
		timer = os.startTimer(1)
	end
	return true
end

sjn.program(start)
os.unloadAPI("SJNOS/system/SJNOS/sjn")
