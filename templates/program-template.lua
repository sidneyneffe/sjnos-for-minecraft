--SJNOS by MC403. standard.exe ()

local tArgs = {...} --standard.exe <USERNAME>

local function start()


if (not term.isColor()) then
	error('This program needs support for colors.')
elseif (tArgs[1] == nil or not fs.exists("SJNOS/users/"..tArgs[1].."/config/.config")) then
    error('Invalid parameters.')
end

local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()
local WIDTH, HEIGHT = term.getSize()

local function showDialog(head, texts, buttons, enterButton, delay)
	return sjn.showDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, buttons, enterButton, delay)
end
local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
	return sjn.showInputDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
end


local USERNAME = tArgs[1]
local USERRANK = sjn.getConfigFileContent("SJNOS/users/"..USERNAME.."/config/.config").d4

local REDNET, REDNETSIDE = sjn.getRednet(true)

local DNS_SERVER = tonumber(sjn.getConfigFileContent("SJNOS/settings/net.set").dns)

local REFRESH_COUNTER = 100




return true
end

if (os.loadAPI("SJNOS/system/SJNOS/sjn")) then
	sjn.program(start)
	os.unloadAPI("SJNOS/system/SJNOS/sjn")
else
	error('Bummer, we could not find and load needed software (SJNOS/system/SJNOS/sjn)!')
end
