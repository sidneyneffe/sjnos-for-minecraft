--SJNOS by MC403. login.sys (ztDHMfrm)

local tArgs = {...}

local function start()


if (not term.isColor()) then
	error('This program needs support for colors.')
end

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
local WIDTH, HEIGHT = term.getSize()

local function showDialog(head, texts, buttons, enterButton, delay)
	return sjn.showDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, buttons, enterButton, delay)
end
local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
	return sjn.showInputDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
end


local IMAGE_PATH = "SJNOS/data/icons/users/"

function CMD_createUser(username, password, image, admin)
	local chars = {'/', '\\', '=', ' ', '#', '%.%.'}

	local result1, msg = sjn.checkStringPlus(username, chars, 1, 12, ' in username')
	if (not result1) then
		return false, msg
	end

	local result2, msg = sjn.checkStringPlus(password, chars, 1, 12, ' in password')
	if (not result2) then
		return false, msg
	end

	local fullPath = IMAGE_PATH .. image
	if (not (fs.exists(fullPath) and not fs.isDir(fullPath))) then
		return false, 'Image file not found.'
	end

	if (fs.exists("SJNOS/users/"..username)) then
		return false, 'Username exists!'
	end


	local path = ("SJNOS/users/"..username)
	fs.makeDir(path)
	fs.makeDir(path.."/home")

	fs.makeDir(path.."/home/files")
	local f = fs.open(path.."/home/files/readme.txt","w")
	f.writeLine("Hello World!")
	f.close()

	fs.makeDir(path.."/home/programs")
	local f = fs.open(path.."/home/programs/hello.lua","w")
	f.writeLine("print('Hello World!')")
	f.close()

	fs.makeDir(path.."/home/apps")
	local f = fs.open(path .. '/home/apps/p+.app', 'w')
	f.writeLine("@SJN.APP.v1")
	f.writeLine("~header")
	f.writeLine("#name=P+")
	f.writeLine("#author=SJNOS")
	f.writeLine("#imagetype=DATA")
	f.writeLine("#imagedata=4:4:0123456789abcdef")
	f.writeLine("~program")
	f.writeLine("shell.run('SJNOS/data/programs/p+.exe " .. username .. "')")
	f.close()

	fs.makeDir(path.."/home/apps/appdata")

	fs.makeDir(path.."/config")
	local f = fs.open(path.."/config/.config","w")
	f.writeLine("d1="..username)
	f.writeLine("d2="..password)
	f.writeLine("d3="..image)
	if (admin == true) then
		f.writeLine("d4=a")
	else
		f.writeLine("d4=u")
	end
	f.close()

	fs.makeDir(path .. '/temp')

	return true, 'Success!'
end

if tArgs[1] == 'create_user' then
	local username = tArgs[2] or ''
	local password = tArgs[3] or ''
	local image = tArgs[4] or ''
	local adminRaw = tArgs[5]
	local admin = false
	if (adminRaw == 'true') then
		admin = true
	end

	sjn.consoleStart('$ create_user ' .. username .. ' [..]')
	local result, msg = CMD_createUser(username, password, image, admin)
	if (result) then
		tcolor(colors.lime)
	end
	print(msg or '')
	sjn.consoleEnd()
	return true
end

local function login()
	local TOTAL_USERS = #fs.list("SJNOS/users")
	if TOTAL_USERS == 0 then
		local username = ""
		local password = ""

		--Username & Password
		local function draw()
			bcolor(colors.white)
			clear()
			tcolor(colors.orange)
			bcolor(colors.cyan)

			cpos(1, 1)
			term.clearLine()
			write("SJNOS - New User: 1/2")
			cpos(WIDTH - 4,1)
			write(getTime())

			cpos(1, 19)
			term.clearLine()
			cpos(2, HEIGHT)
			write("Cancel")

			cpos(WIDTH - 4, HEIGHT)
			write("Next")

			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(math.ceil((WIDTH - string.len("User Informations"))/2 + 1),3)
			write("User Informations")

			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(13, 5)
			write("New Username: ")
			bcolor(colors.gray)
			tcolor(colors.orange)
			write(string.rep(" ", 12))
			cpos(27, 5)
			write(username)
			bcolor(colors.white)
			cpos(13, 7)
			tcolor(colors.cyan)
			write("New Password: ")
			bcolor(colors.gray)
			write(string.rep(" ", 12))
			tcolor(colors.orange)
			cpos(27, 7)
			write(string.rep("*", #password))

			tcolor(colors.cyan)
			bcolor(colors.white)
		end

		local function warning(title, text)
			showDialog(title, {text}, {{colors.lime, colors.gray, "Okay"}})
		end

		local timer = os.startTimer(1)
		while true do
			draw()
			local event, button, x, y = os.pullEventRaw()
			if event=="mouse_click" and button==1 then
				if (y == 19 and x <= 2+6) then
					--Cancel
					os.shutdown()
				elseif x >= WIDTH - 5 and x <= WIDTH and y==19 then
					--Next

					local chars = {'/', '\\', '=', ' ', '#', '%.%.'}

					local result, msg = sjn.checkStringPlus(username, chars, 1, 12)
					if (result) then
						local result, msg = sjn.checkStringPlus(password, chars, 1, 12)
						if (result) then
							break
						else
							warning('Password', msg)
						end
					else
						warning('Username', msg)
					end
				elseif x >= 27 and x <=38  then
					if y==5 then
						--Username
						cpos(27,5)
						bcolor(colors.gray)
						write("            ")
						tcolor(colors.orange)
						cpos(27,5)
						username = read()
					elseif y==7 then
						--Password
						cpos(27,7)
						bcolor(colors.gray)
						write("            ")
						tcolor(colors.orange)
						cpos(27,7)
						password = read("*")
					end
				end
			end
			timer = os.startTimer(1)
		end

		--Userimage
		local selected = 1

		local imagesRaw = sjn.getFileContent("SJNOS/data/icons/users/img.cfg")
		if (not imagesRaw) then
			error("ImageConfig could not be loaded.")
		end

		local images = {}
		for i=1, #imagesRaw do
			local line = imagesRaw[i]
			local p = string.find(line, '=')
			if (p ~= nil) then
				local name = string.sub(line, p + 1)
				local path = string.sub(line, 1, p - 1)

				local fullPath = IMAGE_PATH..path
				if (name ~= '' and path ~= '' and fs.exists(fullPath) and not fs.isDir(fullPath)) then
					table.insert(images, {['name']=name, ['path']=path })
				end
			end
		end

		if #images == 0 then
			error("Images could not be loaded!")
		end

		local function draw()
			bcolor(colors.white)
			clear()
			tcolor(colors.orange)
			bcolor(colors.cyan)

			cpos(1, 1)
			term.clearLine()
			write("SJNOS - New User: 2/2")
			cpos(WIDTH - 4,1)
			write(getTime())

			cpos(1, 19)
			term.clearLine()
			cpos(2, HEIGHT)
			write("Cancel")

			cpos(WIDTH - 4, HEIGHT)
			write("Next")

			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(math.ceil((WIDTH - string.len("User Image"))/2 + 1),3)
			write("User Image")
			bcolor(colors.orange)
			tcolor(colors.cyan)
			cpos(15, 9)
			write("<")
			cpos(35,9)
			write(">")

			local img = paintutils.loadImage(IMAGE_PATH .. images[selected].path)
			paintutils.drawImage(img, 19, 5)
			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(math.ceil((WIDTH - string.len(images[selected].name or '%'))/2 + 1),15)
			write(images[selected].name or '%')
			cpos(math.floor((WIDTH - string.len(selected .."/".. #images))/2),16)
			write(selected .. "/" .. #images)
		end

		local timer = os.startTimer(1)
		while true do
			draw()
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				if (y == 19 and x <= 2+6) then
					--Cancel
					os.shutdown()
				elseif x >= WIDTH - 5 and x <= WIDTH and y==19 then
					--Next
					break
				elseif x==15 and y==9 then
					--Left
					if selected > 1 then
						selected = selected - 1
					else
						selected = #images
					end
				elseif x==35 and y==9 then
					--Right
					if selected < #images then
						selected = selected + 1
					else
						selected = 1
					end
				end
			end
			timer = os.startTimer(1)
		end

		CMD_createUser(username, password, images[selected].path, true)
	end

	function turnOff(event,btn,x,y)
		if (y==19 and x<=3) then
			bcolor(colors.white)
			tcolor(colors.cyan)
			clear()
			cpos((WIDTH - string.len("Goodbye!"))/2 + 1,9)
			textutils.slowWrite("Goodbye!")
			sleep(1)

			os.shutdown()
		end
	end

	bcolor(colors.white)
	clear()
	cpos(1,1)
	tcolor(colors.orange)
	bcolor(colors.cyan)
	term.clearLine()
	write("Login")
	cpos(47,1)
	write(getTime())

	bcolor(colors.white)
	tcolor(colors.red)
	cpos(1,19)
	write("Off")

	tcolor(colors.cyan)
	bcolor(colors.white)

	local users = {}
	local usersRaw = fs.list("SJNOS/users")
	for i=1, #usersRaw do
		local img = sjn.getConfigFileContent("SJNOS/users/".. usersRaw[i] .."/config/.config").d3
		if img ~= nil then
			table.insert(users, {['name'] = usersRaw[i], ['image'] = img})
		end
	end

	local resultId = -1

	if #users==1 then
		local img = paintutils.loadImage(IMAGE_PATH .. users[1].image)
		paintutils.drawImage(img, 19, 5)
		bcolor(colors.white)
		cpos(math.floor((WIDTH - string.len(users[1].name))/2),16)
		write(users[1].name)
		while true do
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				turnOff(event, btn, x,y)
				if (x>=19 and x<=32 and y>=5 and y<=12) then
					resultId = 1
					break
				end
			end
		end
	elseif #users==2 then
		for i=1,2 do
			local img = paintutils.loadImage(IMAGE_PATH .. users[i].image)
			paintutils.drawImage(img, (i-1) *15 +13, 5)
			bcolor(colors.white)
			cpos(math.floor((WIDTH - string.len(users[i].name))/2-6+(i-1)*15), 16)
			write(users[i].name)
		end
		while true do
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				turnOff(event, btn, x, y)
				if (x>=13 and x<=26 and y>=5 and y<=12) then
					resultId = 1
					break
				elseif (x>=28 and x<=41 and y>=5 and y<=12) then
					resultId = 2
					break
				end
			end
		end
	elseif #users==3 then
		for i=1, 3 do
			local img = paintutils.loadImage(IMAGE_PATH .. users[i].image)
			paintutils.drawImage(img, 20+(i-2)*15, 5)
			bcolor(colors.white)
			cpos(15*i-4-((string.len(users[i].name)/2)), 16)
			write(users[i].name)
		end
		while true do
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				turnOff(event,btn,x,y)
				if (x>=5 and x<=18 and y>=5 and y<=12) then
					resultId = 1
					break
				elseif (x>=20 and x<=33 and y>=5 and y<=12) then
					resultId = 2
					break
				elseif (x>=35 and x<=48 and y>=5 and y<=12) then
					resultId = 3
					break
				end
			end
		end
	else
		local username = ""
		local function draw()
			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos((WIDTH - string.len("Username"))/2 + 1,6)
			write("Username")
			bcolor(colors.gray)
			tcolor(colors.orange)
			cpos((WIDTH - 12)/2,8)
			write(string.rep(" ", 12))
			write(username)

			bcolor(colors.orange)
			tcolor(colors.cyan)
			cpos((WIDTH - 7)/2,11)
			write(" Login ")

			tcolor(colors.cyan)
			bcolor(colors.white)
		end

		local finished = false
		while not finished do
			draw()
			local event, button, x, y = os.pullEventRaw()
			if event=="mouse_click" and button==1 then
				turnOff(event,btn,x,y)
				if x>=(WIDTH - 7)/2 and x<=(WIDTH - 7)/2+7 and y==11 then
					--OK
					if fs.exists("SJNOS/users/"..username) and username~="" then
						for i=1,#users do
							if users[i].name == username then
								resultId = i
								finished = true
								break
							end
						end
					end
				elseif x>=(WIDTH - 12)/2 and x<=(WIDTH - 12)/2+12 and y==8 then
					--Username
					cpos((WIDTH - 12)/2,8)
					bcolor(colors.gray)
					write(string.rep(" ", 12))
					tcolor(colors.orange)
					cpos((WIDTH - 12)/2,8)
					username = read()
				end
			end
		end
	end

	if (resultId < 1) then
		error("User does not exist!")
	end

	bcolor(colors.white)
	clear()
	cpos(1,1)
	tcolor(colors.orange)
	bcolor(colors.cyan)
	term.clearLine()
	write("Login")
	cpos(47,1)
	write(getTime())
	tcolor(colors.cyan)
	bcolor(colors.white)

	local user = users[resultId]

	local img = paintutils.loadImage(IMAGE_PATH .. user.image)
	paintutils.drawImage(img, 19, 3)
	bcolor(colors.white)
	cpos((WIDTH - string.len(user.name))/2,13)
	write(user.name)
	cpos((WIDTH - 12)/2,15)
	bcolor(colors.gray)
	tcolor(colors.orange)
	write(string.rep(" ", 13))
	cpos((WIDTH - 12)/2,15)
	local input = read("*")


	local pw = sjn.getConfigFileContent("SJNOS/users/".. user.name .."/config/.config", "=").d2

	if input==pw then
		local TEMP_PATH = "SJNOS/system/temp/.temp"
		fs.makeDir("SJNOS/system/temp")
		local f = fs.open(TEMP_PATH, "w")
		f.write("user="..user.name)
		f.close()
	elseif input ~= '' then
		sjn.showInfoDialogDESIGN("Login", {"Sorry, wrong password. Try again!"}, DESIGN_DARK)
	end
end

login()

return true
end

sjn.program(start)
os.unloadAPI("SJNOS/system/SJNOS/sjn")
