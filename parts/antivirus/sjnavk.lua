-- SJNAVK for SJNOS and more by MC403

local tArgs = {...}
local color = term.isColor()

if color then
	term.setTextColor(colors.red)
else

end

local keywords = ""
local pastebin = ""
local text = ""

if #tArgs == 1 then
	--Check program
	local path = tArgs[1]
	if fs.exists(path) then
		term.setCursorPos(1,1)
		
		-------------------------------------------------
		--Declaration
		local check_RES_result = false
		local check_RES_keywords = 0
		local check_RES_pastebin = 0
		local check_RES_text = ""

		--Get Keys
		if fs.exists("SJNAVK/key") then fs.delete("SJNAVK/key") end
		shell.run("pastebin","get","Cp5tyw2c","SJNOS/key")
		local h = fs.open("SJNOS/key","r")
		local check_LOC_keys = {}
		local finished = false
		while not finished do
			local c = h.readLine()
			if not c == nil then
				table.insert(check_LOC_keys,c)
			else
				finished = true
			end
		end
		h.close()
		fs.delete("SJNAVK/key")

		--Get File
		local h = fs.open(path)
		local check_LOC_file = h.readAll()

		--Comparing Keys with File Content

		for i=1, #check_LOC_keys do
			local check_LOC_result = string.find(check_LOC_file,check_LOC_keys[i])
			if not check_LOC_result == nil then
				check_RES_keywords = check_RES_keywords + 1
				if check_LOC_keys[i] == "pastebin" then
					RESULT_pastebin = RESULT_pastebin + 1
				end
			end
		end

		--Calculate Result
		if RESULT_keywords >= 20 then
			RESULT_result = true
			RESULT_text = "WARNING: VERY DANGEROUS! IF YOU DON'T TRUST THE DEVELOPERS, YOU SHOULD DELETE THIS FILE!"
		elseif RESULT_keywords >= 15 then
			RESULT_result = true
			RESULT_text = "WARNING: DANGEROUS!"
		elseif RESULT_keywords >= 10 then
			RESULT_result = true
			RESULT_text = "WARNING: VERY UNSAFE"
		elseif RESULT_keywords >= 5 then
			RESULT_result = true
			RESULT_text = "Warning: UNSAFE"
		elseif Result_keywords > 0 then
			RESULT_result = true
			RESULT_text = "This program can be a virus, but is pretty safe. You can debug it."
		else
			RESULT_result = false
			RESULT_text = "This program is not dangerous :)"
		end
		-------------------------------------------------
		
		
		
		if result then
			--Virus
			if color then
				local function colormenu()
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.red)
					print("SJNAVK: ["..path.."]")
					term.setCursorPos(51,1)
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.gray)
					print("X")
					
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.red)
					term.setCursorPos(1,3)
					print("Keywords: "..keywords)
					term.setCursorPos(40,3)
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.gray)
					print("See them")
					
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.red)
					term.setCursorPos(1,4)
					print("Pastebin: "..pastebin)
					term.setCursorPos(40,4)
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.gray)
					print("See them")
					
					term.setTextColor(colors.black)
					term.setBackgroundColor(colors.red)
					print("")
					print(text)
					print("")
					
					local x, y = term.getCursorPos()
					term.setCursorPos(1,y)
				end
				colormenu()
			else
				--No color
				local function nocolormenu()
					print("SJNAVK")
					print("Keywords: "..keywords)
					print("Pastebin: "..pastebin)
					print("")
					print(text)
					print("")
					print("> Edit Code")
					print("  Remove File")
					print("  Run File")
					print("  Save Debug")
					print("  Reboot")
					print("  SJNAVK")
					
					local x, y = term.getCursorPos()
					local solved = false
					local selected = 1
					local maxnr = 6
					local linenr = y-maxnr
					while not solved do
						for i=1,maxnr do
							term.setCursorPos(1,i+linenr)
							if i==selected then
								print(">")
							else
								print(" ")
							end
						end
						local event, button = os.pullEvent("key")
						if button==208 then
							if selected<maxnr then
								selected = selected + 1
							else
								selected = 1
							end
						elseif button==200 then
							if selected>1 then
								selected = selected - 1
							else
								selected = maxnr
							end
						elseif button==28 then
							solved = true
						end
					end
					if selected == 1 then
						--Edit code
						shell.run("edit",path)
					elseif selected == 2 then
						--Remove File
						fs.delete(path)
						print("File has been deleted!")
					elseif selected == 3 then
						--Run File
						term.clear()
						term.setCursorPos(1,1)
						print("ARE YOU SURE TO RUN THIS FILE ("..path..") ?")
						print("> Yes")
						print("  No")
						local done = false
						local select = 1
						
						while not done do
							local event, button = os.pullEvent("key")
							if button == 208 or button == 200 then
								if select == 1 then select = 2
								else select = 1	end
								term.setCursorPos(1,2)
								if selected == 2 then
									print("  Yes")
									print("> No")
								else
									print("> Yes")
									print("  No")
								end
							elseif button == 28 then
								done = true
							end
						end
						if select == 1 then
							for i=15, 0, -1 do
								term.clear()
								term.setCursorPos(1,1)
								print("You have "..i.." Seconds to press Strg+T for 4 seconds to terminate, then then "..path.." will run!")
								sleep(1)
							end
							shell.run(path)
						else
							nocolormenu()
						end
						
					elseif selected == 4 then
						--Save Debug
						function saveDebug(path)
							print("SAVEDEBUG is not written yet.")
						end
						nocolormenu()
					elseif selected == 5 then
						--Reboot
						term.clear()
						term.setCursorPos(1,1)
						textutils.slowPrint("Thanks for using SJNOS")
						textutils.slowPrint("Rebooting...")
						sleep(0.5)
						os.reboot()
					elseif selected == 6 then
						--SJNAVK
						shell.run(shell.getRunningProgram())
					end
				end
				nocolormenu()
			end
		else
			--No Virus
			if color then
				print("COLOR")
			else
				term.clear()
				term.setCursorPos(1,1)
				print("SJNAVK")
				print("No Virus detected, "..keywords.." Keywords, "..pastebin.." Pastebin, Text: "..text.." !")
				print("")
				print("> SJNAVK")
				print("  Exit")
				local done = false
				local select = 1
				while not done do
					local event, button = os.pullEvent("key")
					if button == 208 or button == 200 then
						if select == 1 then select = 2
						else select = 1	end
						term.setCursorPos(1,4)
						if select == 2 then
							print("  SJNAVK")
							print("> Exit")
						else
							print("> SJNAVK")
							print("  Exit")
						end
					elseif button == 28 then
						done = true
					end
				end
				
				if select == 1 then
					shell.run(shell.getRunningProgram())
				else
					print("The program will end in 5 seconds.")
				end
			end
		end
	else
		print("The path '"..path.."' does not exist!")
	end
else
	--Normal Program
	print("NORMAL SJNAVK")
end

if color then
	term.setTextColor(colors.cyan)
	term.setBackgroundColor(colors.white)
	sleep(1)
end
term.clear()
term.setCursorPos(1,1)
textutils.slowPrint("Thanks for using SJNAVK!!! (by MC403)")
