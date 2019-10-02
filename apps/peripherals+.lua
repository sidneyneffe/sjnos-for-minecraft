--SJNOS by MC403. p+.exe (rFhpFNrU)

local tArgs = {...}
local CODE = ''

local function start()

if (not os.loadAPI("SJNOS/system/SJNOS/sjn")) then
	error("SJN API missing")
end

local function showDialog(head, texts, buttons, delay, enterButton)
	return sjn.showDialog(head, texts, colors.orange, colors.gray,
		colors.gray, colors.orange, buttons, enterButton, delay)
end

local function showInputDialog(head, texts, delay, enterButton, autoFocus, alternative)
	return sjn.showInputDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange,
		colors.cyan, colors.lightGray, {{colors.lime, colors.gray, "Okay"}, {colors.red, colors.gray, "Cancel"}}, enterButton, delay, autoFocus, alternative)
end

local USERNAME = tArgs[1]
local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()

local DATA = nil
local SCROLL = 0
local EDIT_MODE = false
local MONITOR = true

local SIDES = {'left', 'right', 'top', 'bottom', 'front', 'back'}

local function save()
	local f = fs.open('SJNOS/users/'.. USERNAME .. '/config/p+.cfg', 'w')
	f.write(textutils.serialize(DATA))
	f.close()
end

local function load()
	if (fs.exists('SJNOS/users/'.. USERNAME .. '/config/p+.cfg')) then
		local content = sjn.getFileAll('SJNOS/users/'.. USERNAME .. '/config/p+.cfg')
		DATA = textutils.unserialize(content) or {}
	else
		DATA = {}

		for i=1, 25 do
			local name = '' .. math.random()
			local side = math.floor(math.random() * 6) + 1
			local color = math.pow(2, math.floor(math.random() * 16))

			DATA[i] = {['name'] = '' .. math.random(), ['side'] = side, ['color'] = color, ['monitor'] = math.random() * 2 > 1}
		end

		save()
	end
end

function getColor0(color) -- 64->7 also FARBEN von 2^0 bis 2^15 zu 1-16
	return sjn.log(2, color) + 1
end

local function draw()
	tcolor(colors.cyan)
	bcolor(colors.white)
	clear()

	cpos(1, 1)
	tcolor(colors.orange)
	bcolor(colors.cyan)
	term.clearLine()
	write("P+  (" .. #DATA .. ' Entries)')

	cpos(45,1)
	if (sjn.getPeripheralSide('monitor') == nil) then
		tcolor(colors.gray)
		bcolor(colors.cyan)
	elseif (MONITOR) then
		tcolor(colors.white)
		bcolor(colors.lime)
	else
		tcolor(colors.orange)
		bcolor(colors.cyan)
	end
	write("M")

	cpos(47, 1)
	tcolor(colors.orange)
	bcolor(colors.cyan)
	write("+")

	cpos(49, 1)
	if (EDIT_MODE) then
		tcolor(colors.white)
		bcolor(colors.lime)
	else
		tcolor(colors.orange)
		bcolor(colors.cyan)
	end
	write("#")

	cpos(51, 1)
	tcolor(colors.black)
	bcolor(colors.red)
	write("X")

	for i=1, #DATA - SCROLL do
		local element = DATA[i + SCROLL]
		cpos(1, 1 + i)
		bcolor(element.color)
		write(" ")

		tcolor(colors.cyan)
		bcolor(colors.white)
		write(element.name)

		if (EDIT_MODE) then
			cpos(50, 1 + i)
			tcolor(colors.cyan)
			bcolor(colors.white)
			write("x")
		else
			bcolor(colors.white)
			cpos(40, 1 + i)

			local output = sjn.getBoolArrayFromColor(rs.getBundledOutput(SIDES[element.side]))
			local input = sjn.getBoolArrayFromColor(rs.getBundledInput(SIDES[element.side]))

			local color0 = getColor0(element.color)

			if (output[color0]) then
				tcolor(colors.lime)
				write("ONLINE")
			else
				tcolor(colors.red)
				write("off")
			end

			bcolor(colors.white)
			cpos(47, 1 + i)
			if (input[color0]) then
				tcolor(colors.lime)
			else
				tcolor(colors.red)
			end
			write("I")

			bcolor(colors.white)
			cpos(49, 1 + i)
			if (sjn.getPeripheralSide('monitor') == nil) then
				tcolor(colors.gray)
				if (element.monitor) then
					write("M")
				else
					write("-")
				end
			elseif (element.monitor) then
				tcolor(colors.lime)
				write("M")
			else
				tcolor(colors.red)
				write("-")
			end
		end
	end

	if (MONITOR) then
		local mon_sides = {}
		for i=1, 6 do
			if (sjn.getPeripheralType(SIDES[i]) == 'monitor') then
				mon_sides[#mon_sides + 1] = SIDES[i]
			end
		end
		if (#mon_sides > 0) then
			for i=1, #mon_sides do
				local monitor = peripheral.wrap(mon_sides[i])

				local function m_clear()
					monitor.clear()
				end
				local function m_cpos(x, y)
					monitor.setCursorPos(x, y)
				end
				local function m_tcolor(c)
					if (monitor.isColor()) then
						monitor.setTextColor(c)
					end
				end
				local function m_bcolor(c)
					if (monitor.isColor()) then
						monitor.setBackgroundColor(c)
					end
				end
				local function m_write(t)
					monitor.write(t)
				end

				local elements = {}

				for i=1, #DATA do
					if (DATA[i].monitor) then
						table.insert(elements, DATA[i])
					end
				end

				local scale = 5

				while (scale >= 0.5) do
					monitor.setTextScale(scale)
					local w, h = monitor.getSize()

					if (w >= 15 and h >= #elements) then
						break
					end

					scale = scale - 0.5
				end

				local w, h = monitor.getSize()

				m_bcolor(colors.white)
				m_clear()
				m_cpos(1, 1)

				for i=1, #elements do
					if (i > h) then
						break
					end

					local element = elements[i]
					m_tcolor(colors.cyan)
					m_cpos(1, i)
					m_write(element.name)
					m_cpos(w - 3, i)

					local output = sjn.getBoolArrayFromColor(rs.getBundledOutput(SIDES[element.side]))
					local color0 = getColor0(element.color)

					if (output[color0]) then
						m_tcolor(colors.lime)
						m_write(" ON ")
					else
						m_tcolor(colors.red)
						m_write(" OFF")
					end
				end
			end
		end
	end

	if (#DATA > 18) then
		local scrollHeight = math.floor(18 / #DATA * 18)

		if (#DATA > 22) then
			scrollHeight = scrollHeight - 1
		end

		bcolor(colors.cyan)
		for i=1, scrollHeight do
			cpos(51, i + 1 + SCROLL)
			write(" ")
		end
	end
end

load()

while true do
	draw()
	local timer = os.startTimer(4)
	local event, btn, x, y = os.pullEventRaw()

	if (event == 'mouse_click') then
		if (y == 1) then
			if (x == 45) then
				--Monitor
				if (sjn.getPeripheralSide('monitor') == nil) then
					showDialog('Monitor', {'Connect a monitor to this PC', 'to use this feature.'})
				else
					if (MONITOR) then
						local mon_sides = {}
						for i=1, 6 do
							if (sjn.getPeripheralType(SIDES[i]) == 'monitor') then
								mon_sides[#mon_sides + 1] = SIDES[i]
							end
						end
						if (#mon_sides > 0) then
							for i=1, #mon_sides do
								local monitor = peripheral.wrap(mon_sides[i])
								monitor.clear()
							end
						end
					end
					MONITOR = not MONITOR
				end
			elseif (x == 47) then
				--New
				local n, name = showInputDialog('New Entry', {'Name of the Entry'}, nil, nil, true)
				if (n and name ~= '') then
					local s, side = showInputDialog('New Entry', {'Side (relative to computer)'}, nil, nil, true)

					if (side == SIDES[1]) then side = 1
					elseif (side == SIDES[2]) then side = 2
					elseif (side == SIDES[3]) then side = 3
					elseif (side == SIDES[4]) then side = 4
					elseif (side == SIDES[5]) then side = 5
					elseif (side == SIDES[6]) then side = 6
					else
						s = nil
					end

					if (s) then
						local c, color = showInputDialog('New Entry', {'Color (blue, red, etc.)'}, nil, nil, true)
						if (c and color ~= '' and colors[color]) then
							table.insert(DATA, {['name'] = name, ['side'] = side, ['color'] = colors[color]})
							save()
						end
					end
				end
			elseif (x == 49) then
				--EDIT MODE
				EDIT_MODE = not EDIT_MODE
			elseif (x == 51) then
				--Close
				break
			end
		else
			if (y - 1 + SCROLL <= #DATA and y > 1) then
				local id = y - 1 + SCROLL
				local element = DATA[id]

				if (EDIT_MODE) then
					if (x == 50) then
						--Delete Entry

						for i=0, #DATA - id - 1 do
							DATA[id + i] = DATA[id + i + 1]
						end

						table.remove(DATA)

						save()
						load()

						if (SCROLL > #DATA - 18) then
							SCROLL = #DATA - 18
						end

						if (SCROLL < 0) then
							SCROLL = 0
						end
					end
				else
					if (x == 1) then
						--Select Color
					elseif (x >= 1 and x <= 35) then
						--Change Name
						tcolor(colors.cyan)
						bcolor(colors.white)
						cpos(2, y)
						write("                                      ")
						cpos(2, y)
						local input = read()
						if (input and input ~= '') then
							element.name = input
							save()
						end
					elseif (x >= 40 and x < 46) then
						--Toggle Online/Offline

						local color0 = getColor0(element.color)

						local array = sjn.getBoolArrayFromColor(rs.getBundledOutput(SIDES[element.side]))

						array[color0] = not array[color0]

						local new = sjn.getColorFromBoolArray(array)
						rs.setBundledOutput(SIDES[element.side], new)
					elseif (x == 47) then
						--I

						local input = sjn.getBoolArrayFromColor(rs.getBundledInput(SIDES[element.side]))
						local color0 = getColor0(element.color)

						if (input[color0]) then
							showDialog('Input', {'Your computer IS receiving a', 'redstone signal via this', 'side and color.'})
						else
							showDialog('Input', {'Your computer IS NOT receiving a', 'redstone signal via this', 'side and color.'})
						end
					elseif (x == 49) then
						--M (Monitor)
						element.monitor = not element.monitor
						save()
					end
				end
			end
		end
	elseif (event == 'mouse_scroll') then
		if (btn == -1 and SCROLL > 0) then
			SCROLL = SCROLL - 1
		elseif (btn == 1 and SCROLL < #DATA - 18) then
			SCROLL = SCROLL + 1
		end
	elseif (event == 'monitor_touch' and MONITOR) then
		local monitor = peripheral.wrap(btn)
		local w, h = monitor.getSize()
		if (x >= w - 2) then
			local elements = {}
			for i=1, #DATA do
				if (DATA[i].monitor) then
					table.insert(elements, DATA[i])
				end
			end

			local element = elements[y]
			if (element) then
				local color0 = getColor0(element.color)

				local array = sjn.getBoolArrayFromColor(rs.getBundledOutput(SIDES[element.side]))

				array[color0] = not array[color0]

				local new = sjn.getColorFromBoolArray(array)
				rs.setBundledOutput(SIDES[element.side], new)
			end
		end
	end
end


return true
end

local ok, err = pcall(start)
if not ok then
	sjn.drawErrorScreen2(err)
end

term.setCursorPos(1,1)
term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.clear()