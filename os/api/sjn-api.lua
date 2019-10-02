--SJNAPI (Ab5cy6F2)

local width, height = term.getSize()

--STANDARD
function getStandardFunctions()
	--cpos, clear, tcolor, bcolor, time
	return term.setCursorPos,
		term.clear,
		function (color)
			if (term.isColor()) then
				term.setTextColor(color)
			end
		end,
		function (bg)
			if (term.isColor()) then
				term.setBackgroundColor(bg)
			end
		end,
		function ()
			local time = textutils.formatTime(os.time(),true)
			if #time==4 then
				time = "0"..time
			end
			return time
		end
end

cpos, clear, tcolor, bcolor, getTime = getStandardFunctions()

function drawErrorScreen(err, username)
	local function draw()
		f = fs.open(".errimg","w")
		local w,h = term.getSize()
		f.writeLine("000000000000000000000000010000000000000000000000000")
		f.writeLine("000000000000000000000000111000000000000000000000000")
		f.writeLine("0000000000000000000000011f1100000000000000000000000")
		f.writeLine("0000000000000000000000111f1110000000000000000000000")
		f.writeLine("0000000000000000000001111f1111000000000000000000000")
		f.writeLine("000000000000000000001111111111100000000000000000000")
		f.writeLine("0000000000000000000111111f1111110000000000000000000")
		f.writeLine("000000000000000000111111111111111000000000000000000")
		f.close()
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.cyan)
		term.clear()
		local img = paintutils.loadImage(".errimg")
		fs.delete(".errimg")
		paintutils.drawImage(img,1,3)
		term.setBackgroundColor(colors.white)
		term.setCursorPos(1,1)
		write("SJNOS ERROR")
		term.setCursorPos(47,1)
		write(textutils.formatTime(os.time(),true))
		term.setTextColor(colors.black)
		term.setCursorPos((w-string.len("Oh No! Something went horribly wrong! :("))/2,12)
		write("Oh No! Something went horribly wrong :(")
		term.setTextColor(colors.red)

		term.setCursorPos(1, 1)
		local e = {}
		local pos = 1
		local nextpos = 43
		local e_length = #err
		while (pos < e_length) do
			local nextstring = string.sub(err, pos, nextpos-1)

			pos = nextpos
			nextpos = nextpos + 42

			e[#e+1] = nextstring
		end

		for i=1,#e do
			term.setCursorPos((w-#e[i])/2 + 1,  13+i)
			write(e[i])
		end
		term.setBackgroundColor(colors.orange)
		term.setTextColor(colors.black)
		startcoos = 19
		term.setCursorPos(startcoos,18)
		write("Reboot")
		term.setCursorPos(startcoos+8,18)
		write("Exit")
	end
	draw()
	local finished = false
	while not finished do
		local event, btn, x, y = os.pullEvent()
		if event=="mouse_click" and btn==1 and y==18 then
			if x>=startcoos and x<=startcoos+6 then
				finished = true
				os.reboot()
			elseif x>=startcoos+8 and x<=startcoos+12 then
				finished = true

				local craftOS = false

				if (username ~= nil) then
					local file = getConfigFileContent("SJNOS/users/"..username.."/config/.config")
					if (file ~= nil and file.d4 == "a") then
						local btn, input = showInputDialog("Start CraftOS?", {"Hello "..username..",", "please enter your Password!"},
							colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray, {{colors.lime, colors.gray, "CraftOS"},{colors.red, colors.gray, "Cancel"}}, 1, nil, true, "*")

						if (btn == 1) then
							--Okay
							if (file ~= nil and file.d2 == input) then
								craftOS = true
							else
								showDialog("Start CraftOS?", {"Wrong password!"},
									colors.orange, colors.gray, colors.gray, colors.orange, {{colors.red, colors.gray, "Okay"}})
							end
						end
					end
				end

				return craftOS
			end
		end
	end
end

function drawErrorScreen2(err, run_path)
	local array = {'This shouldn\'t happen...'}
	local rest = err .. ''

	while (#rest > 30) do
		table.insert(array, string.sub(rest, 1, 30))
		rest = string.sub(rest, 31) .. ''
	end

	table.insert(array, rest)

	while (#array > 12) do
		array[#array] = nil
	end

	showDialog('Sorry', array, colors.red, colors.white, colors.white, colors.red, {{colors.lime, colors.white, "Okay"}})

	if (run_path) then
		if (fs.exists(run_path) and not fs.isDir(run_path)) then
			shell.run(run_path)
		end
	end
end

function program(start)
	local ok, err = pcall(start)
	if not ok then
		drawErrorScreen2(err)
	end

	if (term.isColor()) then
		tcolor(colors.white)
		bcolor(colors.black)
	end
	clear()
	cpos(1, 1)
end

function consoleStart(cmd)
	cpos(1, 1)
	tcolor(colors.orange)
	bcolor(colors.gray)
	clear()
	print(cmd)
	tcolor(colors.lightGray)
end

function consoleEnd()
	cpos(1, 19)
	bcolor(colors.black)
	tcolor(colors.orange)
	term.clearLine()
	write("[SJNOS: Press any key to exit the console.]")

	while true do
		local event = os.pullEventRaw()
		if (event == 'mouse_click' or event == 'key') then
			break
		end
	end
end

function console(cmd, text)
	consoleStart(cmd)
	print(text)
	consoleEnd()
end

--MATH
function log(base, x)
	return math.log(x) / math.log(base)
end

--PERIPHERALS
function getPrinter()
	local side = getPeripheralSide("printer")
	if (side == nil) then
		return nil
	end
	return peripheral.wrap(side)
end

function getPeripheralSide(p_type)
	local sides = {"left","right","top","bottom","front","back"}
	for i=1,6 do
		if peripheral.isPresent(sides[i]) then
			if peripheral.getType(sides[i])==p_type then
				return sides[i]
			end
		end
	end
	return nil
end

function getPeripheralType(side, alt, display)
	if (peripheral.isPresent(side)) then
		local p_type = peripheral.getType(side)
		if (display == true) then
			local first = string.upper(string.sub(p_type, 1, 1))
			local rest = string.sub(p_type, 2)

			return first..rest
		end

		return p_type
	end
	return alt
end

function getRednet(doOpenRednet)
	local REDNETSIDE = sjn.getPeripheralSide("modem")
	local REDNET = (REDNETSIDE ~= nil)
	if (doOpenRednet and REDNET and (not rednet.isOpen(REDNETSIDE))) then
		rednet.open(REDNETSIDE)
	end
	return REDNET, REDNETSIDE
end


--COMMUNICATION
function receive(targetID, timeout, okayFunction)
	if (tonumber(targetID) == nil or tonumber(timeout) == nil) then
		return false
	end

	local timer = os.startTimer(timeout)
	while (true) do
		local event, side, channel, id, msg, dis = os.pullEventRaw()
		if (event == "modem_message") then
			if (id == targetID) then
				local okay, p1, p2, p3, p4, p5 = okayFunction(msg)
				if (okay) then
					return true, p1, p2, p3, p4, p5
				end
			end
		elseif (event == 'timer' and side == timer) then
			break
		end
	end
	return false
end

--FILES
function getFileContent(path)
	if (fs.exists(path)) then
		local f = fs.open(path, "r")
		local contentArray = {}
		local contentString = ""

		local line = "!"

		while (line ~= nil) do
			line = f.readLine()
			contentArray[#contentArray + 1] = line
		end
		f.close()
		local f = fs.open(path, "r")
		contentString = f.readAll()
		f.close()

		return contentArray, contentString
	end
	return nil
end

function getFileAll(path)
	local content = nil
	if (fs.exists(path) and not fs.isDir(path)) then
		local f = fs.open(path, 'r')
		content = f.readAll()
		f.close()
	end
	return content
end

function getConfigFileContent(path, char)
	if (fs.exists(path)) then
		local array = getFileContent(path)
		local result = {}
		if (char == nil) then char = "=" end
		for i=1, #array do
			local name = string.sub(array[i], 1, string.find(array[i], char)-1)
			local value = string.sub(array[i], string.find(array[i], char)+1)

			result[name] = value
		end
		return result
	end
	return nil
end

function getUserFile(username, text, directory)
	if (directory == nil) then directory = false end
	local btn, input, path = 2, "", ""
	local on = true

	if (#text < 13) then
		for i=1, 13-#text do
			text = text.." "
		end
	end
	while (on) do
		btn, input = showInputDialog("Select a file", {text}, colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray,
			{{colors.lime, colors.gray, "Okay"}, {colors.red, colors.gray, "Cancel"}})

		path = "SJNOS/users/"..username.."/home/"..input

		if (btn == 1) then
			if (fs.exists(path)) then
				if (fs.isDir(path) == directory) then
					on = false
				else
					local atext = "Please select a file!"
					if (directory) then
						atext = "Please select a directory!"
					end
					showDialog("Select a file", {atext}, colors.orange, colors.gray, colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
				end
			else
				showDialog("Select a file", {"File doesn't exists!","C:/"..path}, colors.orange, colors.gray, colors.gray, colors.orange, {{colors.lime, colors.gray, "Okay"}})
			end
		else
			on = false
		end

	end
	if (btn == 1) then
		return true, path
	end
	return false, ""
end

function getAltFileName(path)
	local counter = 1
	local after = ''
	while (fs.exists(path .. after)) do
		if (counter == 1) then
			after = ' - Copy'
		else
			after = ' - Copy ' .. counter
		end
		counter = counter + 1
	end

	return path .. after
end


--STRINGS
function getStringAfterChar(string, char)
	if (char == nil) then char = "=" end
	local a = string.sub(string, string.find(string, char)+1)
	a = a..""
	return a
end

function getPathContent(path)
	local place, name, ending, realName = "", path, "", path

	local s1 = string.reverse(path)
	local p1 = string.find(s1, "/")
	if (p1 ~= nil) then
		place = string.reverse(string.sub(s1, p1+1))
		name = string.reverse(string.sub(s1, 1, p1-1))
	end

	name = name..""

	local p2 = string.find(name, "%.")
	if (p2 ~= nil) then
		ending = string.sub(name, p2+1)
		realName = string.sub(name, 1, p2-1)
	end

	return place, name, ending, realName
	--"SJNOS/test/hallo.app" -> "SJNOS/test", "hallo.app", "app", "hallo"
end

function splitString(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function splitStringWithNumber(pretext, text, maxStringLength, maxArrayLength)
	local array = {string.sub(pretext, 1, maxStringLength)}
	local rest = text .. ''

	while (#rest > 30) do
		table.insert(array, string.sub(rest, 1, maxStringLength))
		rest = string.sub(rest, maxStringLength + 1) .. ''
	end

	table.insert(array, rest)

	while (maxArrayLength ~= nil and #array > maxArrayLength) do
		array[#array] = nil
	end
	return array
end

function checkString(text, chars, minlength, maxlength) -- String text, char[] chars, int minlength, int maxlength
	if (text == nil or text == "") then
		return false, 'EMPTY'
	end

	for i=1, #chars do
		if string.find(text, chars[i]) then
			return false, 'CHAR', chars[i]
		end
	end

	if (minlength ~= nil and string.len(text) < minlength) then
		return false, 'MINLENGHT', minlength
	elseif (maxlength ~= nil and string.len(text) > maxlength) then
		return false, 'MAXLENGHT', maxlength
	end

	return true
end

function checkStringPlus(text, chars, minlength, maxlength, ending)
	local result, type, info = checkString(text, chars, minlength, maxlength)
	if (not result) then
		local msg = ''

		if (type == 'EMPTY') then
			msg = "Please enter something" .. (ending or '') .. '.'
		elseif (type == 'CHAR') then
			if (info == '%.%.') then info = '..' end
			msg = "Please do not use '" .. (info or '') .. "'" .. (ending or '') .. '.'
		elseif (type == 'MINLENGHT') then
			msg = "Please enter a password longer than " .. (info or 0) .. " chars" .. (ending or '') .. '.'
		elseif (type == 'MAXLENGHT') then
			msg = "Please enter a password shorter than " .. (info or 0) .. " chars" .. (ending or '') .. '.'
		else
			msg = "Sorry, this shouldn't happen... Unknown error!"
		end

		return false, msg
	end

	return true
end


--GRAPHICS

function showDialog(head, texts, textColor, backgroundColor, headTextColor, headBackgroundColor, buttons, enterButtonNummer, delay)
	--[[
	texts = {"text1","text2","text3"}
	local buttons = {
		{colors.green, colors.red, "Button!"}
	}
	enterButtonNummer: Button, which is returned after pressing ENTER
	]]

	if (head == nil) then head = "Head" end
	if (texts == nil) then texts = {"Text"} end
	if (textColor == nil) then textColor = colors.white end
	if (backgroundColor == nil) then backgroundColor = colors.black end
	if (headTextColor == nil) then headTextColor = colors.black end
	if (headBackgroundColor == nil) then headBackgroundColor = colors.white end
	if (buttons == nil) then buttons = {{colors.lime, colors.gray, "Okay"}} end
	if (enterButtonNummer == nil) then enterButtonNummer = 1 end
	if (delay == nil and #buttons > 1) then delay = 0.8 end
	if (delay == nil) then delay = 0 end

	for i=1,#buttons do
		buttons[i].textColor = buttons[i][1]
		buttons[i].backgroundColor = buttons[i][2]
		buttons[i].text = buttons[i][3]
	end

	local padding_left = 3
	local padding_top = 1
	local dialog_height = #texts + padding_top + 1 + padding_top + 2 -- Text + Padding + Headline + Buttons
	local dialog_width = 0

	for i=1, #texts do
		if (string.len(texts[i]) > dialog_width) then
			dialog_width = string.len(texts[i])
		end
	end
	dialog_width = dialog_width + 2 * padding_left
	local dialog_x = math.ceil((width - dialog_width) / 2)
	local dialog_y = math.ceil((height - dialog_height) / 2) + 1

	cpos(dialog_x, dialog_y)
	bcolor(headBackgroundColor)
	for i=1, dialog_width do
		write(" ")
	end

	tcolor(textColor)
	bcolor(backgroundColor)

	for i=1, dialog_height-1 do
		cpos(dialog_x, dialog_y + i)
		for j=1, dialog_width do
			write(" ")
		end
	end

	cpos(dialog_x + padding_left - 1, dialog_y)
	tcolor(headTextColor)
	bcolor(headBackgroundColor)
	write(head)

	tcolor(textColor)
	bcolor(backgroundColor)
	for i=1, #texts do
		cpos((width - string.len(texts[i])) / 2, dialog_y + padding_top + i)
		write(texts[i])
	end

	local button_string_length = 0

	for i=1, #buttons do
		button_string_length = button_string_length + string.len(buttons[i].text)
		if (i < #buttons) then
			button_string_length = button_string_length + 1
		end
	end

	local startPos = math.floor((width - button_string_length) / 2)

	local button_string_length2 = 0
	for i=1, #buttons do
		buttons[i].x = startPos + button_string_length2

		button_string_length2 = button_string_length2 + string.len(buttons[i].text)

		if (i < #buttons) then
			button_string_length2 = button_string_length2 + 1
		end
	end

	local button_y = dialog_y + #texts + padding_top + 1 + padding_top

	for i=1, #buttons do
		cpos(buttons[i].x, button_y)
		tcolor(buttons[i].textColor)
		bcolor(buttons[i].backgroundColor)
		write(buttons[i].text)
	end

	local function clickButton(buttonNumber)
		local button = buttons[buttonNumber]
		bcolor(backgroundColor)
		cpos(dialog_x, button_y)
		for i=1, dialog_width do
			write(" ")
		end
		cpos(button.x, button_y)
		tcolor(button.textColor)
		bcolor(button.backgroundColor)
		write(button.text)
		sleep(delay)
	end

	local inner = true
	while inner do
		local event, btn, x, y = os.pullEventRaw()
		cpos(1,1)
		if event=="key" and (btn==28 or btn == 57) then
			clickButton(enterButtonNummer)
			return enterButtonNummer
		elseif event=="mouse_click" and btn==1 and y==button_y then
			for i=1, #buttons do
				if (x >= buttons[i].x and x < buttons[i].x + string.len(buttons[i].text)) then
					clickButton(i)
					return i
				end
			end
		end
	end
end

function showInputDialog(head, texts, textColor, backgroundColor, headTextColor, headBackgroundColor, inputTextColor, inputBackgroundColor, buttons, enterButtonNummer, delay, autoFocus, alternative)
	--[[
	texts = {"text1","text2","text3"}
	local buttons = {
		{colors.green, colors.red, "Button!"}
	}
	enterButtonNummer: Button, which is returned after pressing ENTER
	]]

	if (head == nil) then head = "Head" end
	if (texts == nil) then texts = {"Text"} end
	if (textColor == nil) then textColor = colors.white end
	if (backgroundColor == nil) then backgroundColor = colors.black end
	if (headTextColor == nil) then headTextColor = colors.black end
	if (headBackgroundColor == nil) then headBackgroundColor = colors.white end
	if (inputTextColor == nil) then inputTextColor = colors.orange end
	if (inputBackgroundColor == nil) then inputBackgroundColor = colors.gray end
	if (buttons == nil) then buttoms = {{colors.gray, colors.lightGray, "Okay"}} end
	if (enterButtonNummer == nil) then enterButtonNummer = 1 end
	if (delay == nil and #buttons > 1) then delay = 0.8 end
	if (delay == nil) then delay = 0 end
	if (autoFocus == nil) then autoFocus = true end

	for i=1,#buttons do
		buttons[i].textColor = buttons[i][1]
		buttons[i].backgroundColor = buttons[i][2]
		buttons[i].text = buttons[i][3]
	end

	local padding_left = 3
	local padding_top = 1
	local dialog_height = #texts + padding_top + 1 + padding_top + 2 + 2 -- Text + Padding + Headline + Buttons + Input
	local dialog_width = 0

	local input = ""

	for i=1, #texts do
		if (string.len(texts[i]) > dialog_width) then
			dialog_width = string.len(texts[i])
		end
	end
	dialog_width = dialog_width + 2 * padding_left
	local dialog_x = math.ceil((width - dialog_width) / 2)
	local dialog_y = math.ceil((height - dialog_height) / 2) + 1

	cpos(dialog_x, dialog_y)
	bcolor(headBackgroundColor)
	for i=1, dialog_width do
		write(" ")
	end

	tcolor(textColor)
	bcolor(backgroundColor)

	for i=1, dialog_height-1 do
		cpos(dialog_x, dialog_y + i)
		for j=1, dialog_width do
			write(" ")
		end
	end

	cpos(dialog_x + padding_left - 1, dialog_y)
	tcolor(headTextColor)
	bcolor(headBackgroundColor)
	write(head)

	tcolor(textColor)
	bcolor(backgroundColor)
	for i=1, #texts do
		cpos((width - string.len(texts[i])) / 2, dialog_y + padding_top + i)
		write(texts[i])
	end


	cpos(dialog_x + 2, dialog_y + #texts + padding_top + 1 + padding_top)
	tcolor(inputTextColor)
	bcolor(inputBackgroundColor)
	for i=1, dialog_width-4 do
		write(" ")
	end

	local button_string_length = 0

	for i=1, #buttons do
		button_string_length = button_string_length + string.len(buttons[i].text)
		if (i < #buttons) then
			button_string_length = button_string_length + 1
		end
	end

	local startPos = math.floor((width - button_string_length) / 2)

	local button_string_length2 = 0
	for i=1, #buttons do
		buttons[i].x = startPos + button_string_length2

		button_string_length2 = button_string_length2 + string.len(buttons[i].text)

		if (i < #buttons) then
			button_string_length2 = button_string_length2 + 1
		end
	end

	local button_y = dialog_y + #texts + padding_top + 1 + padding_top + 2

	for i=1, #buttons do
		cpos(buttons[i].x, button_y)
		tcolor(buttons[i].textColor)
		bcolor(buttons[i].backgroundColor)
		write(buttons[i].text)
	end

	if (autoFocus) then
		cpos(dialog_x + 2, dialog_y + #texts + padding_top + 1 + padding_top)
		tcolor(inputTextColor)
		bcolor(inputBackgroundColor)
		input = read(alternative)
	end

	local function clickButton(buttonNumber)
		local button = buttons[buttonNumber]
		bcolor(backgroundColor)
		cpos(dialog_x, button_y)
		for i=1, dialog_width do
			write(" ")
		end
		cpos(button.x, button_y)
		tcolor(button.textColor)
		bcolor(button.backgroundColor)
		write(button.text)
		sleep(delay)
	end

	local inner = true
	while inner do
		local event, btn, x, y = os.pullEventRaw()
		cpos(1,1)
		if event=="key" and (btn==28 or btn == 57) then
			clickButton(enterButtonNummer)
			return enterButtonNummer, input
		elseif event=="mouse_click" and btn==1 then
			if (y == button_y) then
				for i=1, #buttons do
					if (x >= buttons[i].x and x < buttons[i].x + string.len(buttons[i].text)) then
						clickButton(i)
						return i, input
					end
				end
			elseif (y == dialog_y + dialog_height - 4 and x >= dialog_x + 2 and x <= dialog_x + dialog_width - 2) then
				cpos(dialog_x + 2, dialog_y + #texts + padding_top + 1 + padding_top)
				tcolor(inputTextColor)
				bcolor(inputBackgroundColor)
				for i=1, dialog_width-4 do
					write(" ")
				end
				cpos(dialog_x + 2, dialog_y + #texts + padding_top + 1 + padding_top)
				input = read(alternative)
			end
		end
	end
end

function showConfirmDialog(head, texts, textColor, backgroundColor, headTextColor, headBackgroundColor, enterButtonNummer, delay)
	return 1 == showDialog(head, texts, textColor, backgroundColor, headTextColor, headBackgroundColor, {{colors.lime, backgroundColor, "Okay"}, {colors.red, backgroundColor, "Cancel"}}, enterButtonNummer, delay)
end

DESIGN_BRIGHT = 1
DESIGN_DARK = 2
DESIGN_BLUE = 3

function getDlgColorsFromDesign(design)
	local textColor, backgroundColor, headTextColor, headBackgroundColor
	if (design == DESIGN_BRIGHT) then
		textColor = colors.lightGray
		backgroundColor = colors.white
	elseif (design == DESIGN_DARK) then
		textColor = colors.orange
		backgroundColor = colors.gray
	elseif (design == DESIGN_BLUE) then
		textColor = colors.cyan
		backgroundColor = colors.white
		headTextColor = colors.orange
		headBackgroundColor = colors.cyan
	end
	textColor = textColor or colors.orange
	backgroundColor = backgroundColor or colors.gray
	headTextColor = headTextColor or backgroundColor
	headBackgroundColor = headBackgroundColor or textColor
	return textColor, backgroundColor, headTextColor, headBackgroundColor
end
function getDlgColorsFromColor(color1, color2)
	return color1, color2, color2, color1
end

function showInfoDialogDESIGN(head, texts, design)
	local c, b, hc, hb = getDlgColorsFromDesign(design)
	return showDialog(head, texts, c, b, hc, hb, {{colors.lime, b, "Okay"}})
end

function showConfirmDialogDESIGN(head, texts, design, enterButton)
	local c, b, hc, hb = getDlgColorsFromDesign(design)
	return showDialog(head, texts, c, b, hc, hb, {{colors.lime, b, "Okay"}, {colors.red, b, "Cancel"}}, enterButton)
end

function getBoolArrayFromColor(color)
	local boolArray = {}
	local rest = color
	for i=15,0,-1 do
		local num = math.pow(2, i)
		if (rest >= num) then
			rest = rest - num
			boolArray[i+1] = true
		else
			boolArray[i+1] = false
		end
	end
	return boolArray
end

function getColorFromBoolArray(boolArray)
	local color = 0
	for i=0,15 do
		if (boolArray[i+1]) then
			color = color + math.pow(2, i)
		end
	end
	return color
end

function getPaintableFromData(imagedata, maxwidth, maxheight)
	local image = {{}}

	local p1 = string.find(imagedata, ":")
	local w = tonumber(string.sub(imagedata, 1, p1 - 1))
	local rest = string.sub(imagedata, p1 + 1)
	rest = ""..rest
	local p2 = string.find(rest, ":")
	local h = tonumber(string.sub(rest, 1, p2 - 1))
	local data_string = string.sub(rest, p2 + 1)

	if (w > maxwidth) then w = maxwidth end
	if (h > maxheight) then h = maxheight end

	local data = {}

	for i=1,#data_string do
		data[i] = string.sub(data_string, i, i)
	end

	for i=1, h do
		image[i] = {}
	end

	for y=1, h do
		for x=1, w do
			local r
			local d = data[w*(y-1) + x]
			if (tonumber(d) ~= nil) then
				r = tonumber(d)
			else
				d = string.lower(d)
				if (d == "a") then r = 10
				elseif (d == "b") then r = 11
				elseif (d == "c") then r = 12
				elseif (d == "d") then r = 13
				elseif (d == "e") then r = 14
				elseif (d == "f") then r = 15
				else r = -1 end
			end
			image[y][x] = math.floor(math.pow(2, r))
		end
	end

	for i=1, #image do
		if (i > maxheight) then
			image[i] = {}
		end
		for j=1, #image[i] do
			if (j > maxwidth) then
				image[i][j] = 0
			end
		end
	end
	return image
end


--APPS
function isApp(path)
	--Outside Testing
	if (not fs.exists(path)) then
		return false, "File doesn't exists!"
	end
	if (fs.isDir(path)) then
		return false, "File is a directory!"
	end

	local place, name, ending = getPathContent(path)

	if (ending ~= "app") then
		return false, "File-type is not '.app'!"
	end

	--Inside Testing
	local data, content = getFileContent(path)

	if (string.find(data[1], "@SJN.APP.v") == nil) then
		return false, "Version not specified"
	end

	local p1, p2 = string.find(data[1], "@SJN.APP.v")
	local version = string.sub(data[1], p2+1)

	local header, install, program, name = false, false, false, false

	for i=2, #data do
		local line = data[i]
		if (string.find(line,"~header")==1) then
			header = true
		elseif (string.find(line,"~install")==1) then
			install = true
		elseif (string.find(line,"~program")==1) then
			program = true
		elseif (header and string.find(line, "#name=")) then
			local n = getStringAfterChar(line, "=")
			if (string.find(n, "/") == nil and string.find(n, "\\") == nil) then
				name = true
			end
		end
	end

	if (not header) then
		return false, "Header needed!"
	elseif (not name) then
		return false, "Name (#name=AppName) with no slash in header required"
	end

	return true, {["version"]=version, ["header"]=header, ["install"]=install, ["program"]=program}
end

function getApp(path)
	if (isApp(path)) then
		local file, content = getFileContent(path)

		if (string.find(file[1], "@SJN.APP.v") == nil) then
			return false, "Version not specified"
		end

		local p1, p2 = string.find(file[1], "@SJN.APP.v")
		local version = string.sub(file[1], p2+1)

		local HEADER, INSTALL, PROGRAM = 1, 2, 3
		local content_type = 0

		local data = {
			["path"] = path,
			["header"] = {
				["name"] = "",
				["author"] = "",
				["imagetype"] = "",
				["imagedata"] = ""
			},
			["install"] = {},
			["program"] = {
				["code"] = {},
				["lines"] = 0
			}
		}

		for i=2, #file do
			local line = file[i]
			if (string.find(line,"~header")==1) then
				content_type = HEADER
			elseif (string.find(line,"~install")==1) then
				content_type = INSTALL
			elseif (string.find(line,"~program")==1) then
				content_type = PROGRAM

			elseif (content_type == HEADER) then
				if (string.find(line, "#name=")) then
					data.header.name = getStringAfterChar(line, "=")
				elseif (string.find(line, "#author=")) then
					data.header.author = getStringAfterChar(line, "=")
				elseif (string.find(line, "#imagetype=")) then
					local imagetype = getStringAfterChar(line, "=")
					if (imagetype == "DATA") then
						data.header.imagetype = "data"
					elseif (imagetype == "SOURCE") then
						data.header.imagetype = "source"
					elseif (imagetype == "PASTEBIN") then
						data.header.imagetype = "pastebin"
					end

				elseif (string.find(line, "#imagedata=")) then
					local imagedata = getStringAfterChar(line, "=")
					local imagetype = data.header.imagetype

					if (imagetype == "data" or imagetype == "source" or imagetype == "pastebin") then
						data.header.imagedata = imagedata
					end
				end
			elseif (content_type == INSTALL) then
				if (string.find(line, "#get=")) then
					local input = getStringAfterChar(line, "=")

					local code = string.sub(input, 1, 8)
					local p = string.find(input, ":")

					if (p == 9) then
						local path = string.sub(input, p+1)

						data.install[#data.install+1] = {
							["type"] = "get",
							["code"] = code,
							["path"] = path
						}
					end
				elseif (string.find(line, "#run=")) then
					local path = getStringAfterChar(line, "=")
					if (path ~= "") then
						data.install[#data.install+1] = {
							["type"] = "run",
							["path"] = path
						}
					end
				end
			elseif (content_type == PROGRAM) then
				data.program.code[#data.program.code + 1] = line
				data.program.lines = data.program.lines + 1
			end
		end

		return data
	else
		return nil
	end
end

function installApp(src, username, dest)
	if (src == nil) then
		return false, "Source not defined!"
	elseif (username == nil) then
		return false, "Username not defined!"
	elseif (not fs.exists(src)) then
		return false, "Source doesn't exist!"
	elseif (fs.isDir(src)) then
		return false, "Source is a directory!"
	end

	if (dest == nil) then dest = "SJNOS/users/"..username.."/home/apps/" end

	if (not fs.exists(dest)) then
		return false, "Destination directory doesn't exist!"
	elseif (not fs.isDir(dest)) then
		return false, "Destination directory is not a directory!"
	elseif (not isApp(src)) then
		local _, cause = isApp(src)
		return false, "Source is not an application ("..cause..")!"
	end

	local app = getApp(src)
	local place, name, ending = getPathContent(src)

	if (string.find(app.header.name, "/") or string.find(app.header.name, "\\")) then
		return false, "App name contains '/' or '\\'"
	end

	local path = dest..name
	local root = dest.."appdata/"..app.header.name

	if (fs.exists(path) or fs.exists(root)) then
		local a = sjn.showDialog("Installation", {"App exists. What do you want to do?"}, colors.orange, colors.gray, colors.gray, colors.orange,
			{{colors.lime, colors.gray, "Override"}, {colors.red, colors.gray, "Cancel"}}, 1)
		if (a == 1) then
			fs.delete(path)
			fs.delete(root)
			return installApp(src, username, dest)
		else
			return false, "App exists!"
		end
	end

	fs.makeDir(root)

	fs.copy(src, path)

	return true
end

function deinstallApp(path)
	local result, e = isApp(path)
	if (result) then
		local place, name, ending, realName = getPathContent(path)
		local app = getApp(path)
		local root = place.."/"..app.header.name

		fs.delete(path)
		fs.delete(root)

		return true
	else
		return false, e
	end
end
