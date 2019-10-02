-- SWEBINT API (Bex5SsgL)

--[[
@public
@doctype=stp
<text=Hallo color=blue>
]]

local function tcolor(color) term.setTextColor(color) end
local function bcolor(color) term.setBackgroundColor(color) end
local function clear() term.clear() end
local function cpos(x,y) term.setCursorPos(x,y) end
local function clearL() term.clearLine() end

function getColor(color)
	if (color == "white") then
		return colors.white
	elseif (color == "orange") then
		return colors.orange
	elseif (color == "magenta") then
		return colors.magenta
	elseif (color == "lightblue" or color == "lightBlue") then
		return colors.lightBlue
	elseif (color == "yellow") then
		return colors.yellow
	elseif (color == "lime") then
		return colors.lime
	elseif (color == "pink") then
		return colors.pink
	elseif (color == "gray") then
		return colors.gray
	elseif (color == "lightgray" or color == "lightGray") then
		return colors.lightGray
	elseif (color == "cyan") then
		return colors.cyan
	elseif (color == "purple") then
		return colors.purple
	elseif (color == "blue") then
		return colors.blue
	elseif (color == "brown") then
		return colors.brown
	elseif (color == "green") then
		return colors.green
	elseif (color == "red") then
		return colors.red
	elseif (color == "black") then
		return colors.black
	elseif (tonumber(color) ~= nil) then
		local num = tonumber(color)
		if (num < 32738) then
			local rest = num
			local result = true
			while (rest > 1 and result) do
				rest = rest / 2
				if (rest % 1 ~= 0) then
					result = false
				end
			end

			if (result) then
				return num
			end
		end
	end

	return nil
end

function getCommand(cmd, STANDARTTEXT, STANDARTBG)
	local text, color, bg, link

	local rest = cmd
	local lastPos = 1

	local running = true

	local buffer = true

	while (running or buffer) do

		local pos, newLastPos = string.find(rest, " ")
		pos = pos or lastPos
		lastPos = newLastPos or #rest

		local element = string.sub(rest, 1, lastPos)..""
		if (string.sub(element, #element, #element) == " ") then
			element = string.sub(element, 1, #element - 1)
		end

		lastPos = lastPos + 1

		rest = string.sub(rest, lastPos) .. ""

		if (string.find(element, "=") == nil) then
			break
		end

		local name = string.sub(element, 1, string.find(element, "=")-1)
		local value = string.sub(element, string.find(element, "=")+1)
		if (name == "text") then
			local newText = value..""

			while true do
				local pos = string.find(newText, "#")
				if (pos ~= nil) then
					newText = string.sub(newText, 1, pos-1) .. " " .. string.sub(newText, pos+1)
				else
					break
				end
			end

			text = newText
		elseif (name == "color") then
			color = getColor(value)
		elseif (name == "bg") then
			bg = getColor(value)
		elseif (name == "link") then
			link = value
		end

		if (not running and buffer) then
			buffer = false
		end

		running = string.find(rest, " ") ~= nil
	end

	return {["text"] = text or "", ["tcolor"] = color or STANDARTTEXT, ["bcolor"] = bg or STANDARTBG, ["link"] = link or ""}
end

local function getPathContent(path)
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
end


local function intInner(CONTENT, USERNAME, DNS, SURFTYPE, STANDARTTEXT, STANDARTBG)
	local content = CONTENT.."<>"
	local chars = {
		["opened"] = {},
		["closed"] = {}
	}

	for i=1, #content do
		if (string.sub(content, i, i) == "<") then
			chars.opened[#chars.opened+1] = i
		elseif (string.sub(content, i, i) == ">") then
			chars.closed[#chars.closed+1] = i
		end
	end

	local result = {{["text"] = content, ["tcolor"] = STANDARTTEXT, ["bcolor"] = STANDARTBG}}

	if (#chars.opened == #chars.closed) then
		local tags = {}

		for i=1, #chars.opened do
			tags[#tags+1] = {
				["tag"] = string.sub(content, chars.opened[i]+1, chars.closed[i]-1).."",
				["pos1"] = chars.opened[i],
				["pos2"] = chars.closed[i]
			}
		end

		local newContent = {}
		for i=1, #tags do
			local index = 0
			if (tags[i - 1] ~= nil) then
				index = tags[i - 1].pos2 or 0
			end

			newContent[#newContent+1] = {
				["text"] = string.sub(content, index + 1, tags[i].pos1 - 1).."",
				["tcolor"] = STANDARTTEXT,
				["bcolor"] = STANDARTBG
			}

			newContent[#newContent+1] = getCommand(tags[i].tag, STANDARTTEXT, STANDARTBG)
		end

		if (#tags ~= 0) then
			result = newContent
		end
	end

	return result
end

function int(CONTENT, DOCTYPE, USERNAME, DNS, SURFTYPE, STANDARTTEXT, STANDARTBG)
	tcolor(STANDARTTEXT)
	bcolor(STANDARTBG)
	clear()
	cpos(1, 1)

	local returnObject = {
		["link"] = {}
	}

	if (DOCTYPE == "stp") then
		local result = intInner(CONTENT, USERNAME, DNS, SURFTYPE, STANDARTTEXT, STANDARTBG)
		for i=1,#result do
			local r = result[i]
			tcolor(r.tcolor)
			bcolor(r.bcolor)
			local x, y = term.getCursorPos()
			write(r.text)

			if (r.link ~= "") then
				table.insert(returnObject.link, {
					["x"] = x,
					["y"] = y,
					["width"] = #r.text,
					["target"] = r.link
				})
			end
		end
	elseif (DOCTYPE == "img") then
		local temp = "SJNOS/users/"..USERNAME.."/config/.temp"
		local f = fs.open(temp, "w")
		f.write(CONTENT)
		f.close()

		local image = paintutils.loadImage(temp)

		local f = fs.open(temp, "w")
		f.close()

		paintutils.drawImage(image, 1, 1)
	else
		write(CONTENT)
	end

	return true, returnObject
end
