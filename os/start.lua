--SJNOS by MC403. start.exe (XBSAvvxB)

--os.pullEvent = os.pullEventRaw

local tArgs = {...} --standard.exe <USERNAME>

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


fs.delete("SJNOS/system/local/login")
local function loadingScreen()
	bcolor(colors.white)
	clear()
	local img = paintutils.loadImage("SJNOS/data/icons/sjn.img")
	paintutils.drawImage(img,15,5)

	cpos(10, 15)
	bcolor(colors.lightGray)
	write(string.rep(" ", 31))
	cpos(10, 15)
	bcolor(colors.orange)

	local time = 100
	for i=1, 31 do
		local t = math.random() * 20
		time = time - t
		if (time <= 0) then t = 10 end
		sleep(t / 1000)
		write(" ")
	end
end
local function bootScreen()
	local function draw()
		bcolor(colors.gray)
		clear()
		cpos(2,1)
		tcolor(colors.white)
		write("//system/boot/")
		cpos(2,2)
		tcolor(colors.lightGray)
		write("2048k memory")

		local data = sjn.getConfigFileContent("SJNOS/system/about/ver.txt", "=")
		local v = "v".. (data.ver or '%')

		cpos(WIDTH - string.len(v), 1)
		tcolor(colors.lime)
		write(v)

		local id = "#" .. os.getComputerID()
		cpos(WIDTH - string.len(id), 2)
		tcolor(colors.lightGray)
		write(id)

		local img = paintutils.loadImage("SJNOS/data/icons/system/boot.img")
		paintutils.drawImage(img, 5, 6)

		tcolor(colors.lightGray)
		bcolor(colors.gray)

		tcolor(colors.white)
		local text = "Booting..."
		cpos(math.ceil((WIDTH - string.len(text))/2 + 1), 16)
		write(text)
	end

	draw()

	sleep(1)
end

loadingScreen()
bootScreen()

local login = false

while not login do
	bcolor(colors.white)
	tcolor(colors.cyan)
	clear()
	cpos(1, 1)

	while true do
		local TEMP_PATH = "SJNOS/system/temp/.temp"
		fs.delete(TEMP_PATH)

		shell.run("SJNOS/system/SJNOS/login.sys")

		if fs.exists(TEMP_PATH) then
			local user = sjn.getConfigFileContent(TEMP_PATH).user
			fs.delete(TEMP_PATH)
			login = true

			tcolor(colors.cyan)
			bcolor(colors.white)
			clear()

			local text = "Welcome back, " .. (user or '%') .. "!"
			cpos(math.floor((WIDTH - string.len(text))/2 + 1), 9)
			write(text)

			sleep(1)
			shell.run("SJNOS/system/SJNOS/desktop.sys", user)

			local data = sjn.getConfigFileContent(TEMP_PATH)
			if (data and data.leave == "leave") then
				fs.delete(TEMP_PATH)
				break
			end
		end
	end
end


return true
end

if (os.loadAPI("SJNOS/system/SJNOS/sjn")) then
	sjn.program(start)
	os.unloadAPI("SJNOS/system/SJNOS/sjn")
else
	error('Bummer, we could not find and load needed software (SJNOS/system/SJNOS/sjn)!')
end
