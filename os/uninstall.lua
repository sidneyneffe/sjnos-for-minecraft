--SJNOS by MC403. deinstall.sys (i8DykZUj)

local tArgs = {...}

local function tcolor(color) term.setTextColor(color) end
local function bcolor(color) term.setBackgroundColor(color) end
local function cpos(x, y) term.setCursorPos(x, y) end
local function clear() term.clear() end

if (tArgs[1] == "wk234iajFAA234kse995oasdif" and tArgs[2] == "laof9234kasdjferr4kaw" and tArgs[3] == "asdfLLLLkk###123asdf") then
	cpos(1, 1)
	tcolor(colors.cyan)
	bcolor(colors.white)
	textutils.slowPrint("Deinstalling...")
	sleep(2)
	local new_startup_name = "startup"
	if (fs.exists("startup")) then
		local c = 1
		while (fs.exists("startup"..c)) do
			c = c + 1
		end
		new_startup_name = "startup"..c
		fs.move("startup", new_startup_name)
	end
	local f = fs.open("startup","w")
	f.writeLine("term.clear()")
	f.writeLine("term.setCursorPos(1, 1)")
	f.writeLine("fs.delete(\"SJNOS\")")
	f.writeLine("textutils.slowPrint(\"SJNOS has been deinstalled.\")")
	if (new_startup_name ~= "startup") then
		f.writeLine("textutils.slowPrint(\"Your old startup is now called '"..new_startup_name.."'.\")")
	end
	f.writeLine("textutils.slowPrint(\"You can install SJNOS at any time with the\\npastebin code 'A343Rqi6'.\")")
	f.writeLine("textutils.slowPrint(\"This File deletes itself after rebooting. Goodbye!\\n\")")
	f.writeLine("textutils.slowPrint(\"[Press any key to reboot.]\")")
	f.writeLine("os.pullEvent(\"key\")")
	f.writeLine("fs.delete(\"startup\")")
	f.writeLine("os.reboot()")
	f.close()

	os.reboot()
else
	cpos(1, 1)
	tcolor(colors.cyan)
	bcolor(colors.white)
	clear()
	print("THIS IS NO VALID DEINSTALLATION. PLEASE DEINSTALL SJNOS VIA ADMIN-TOOLS!")
end