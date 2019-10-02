-- myTurtleOS by MC403 installer.exe

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

function start()
	clear()
	textutils.slowPrint("MYTURTLEOS by MC403. What do you want to do?")
	textutils.slowPrint("WARNING: ONLY FOR TURTLES!")
	textutils.slowPrint("> Install")
	textutils.slowPrint("  Deinstall")
	textutils.slowPrint("  Update")
	textutils.slowPrint("  Nothing")

	local solved = false
	local selected = 1
	local maxnr = 4
	while not solved do
		for i=1,maxnr do
			term.setCursorPos(1,i+2)
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
		clear()
		print("SJN DataExport (TurtleEdition)")
		print("--------")
		textutils.slowPrint("> Export all data to User Account")
		textutils.slowPrint("  Delete data")
		textutils.slowPrint("  Export data to a disk")
		textutils.slowPrint("  Cancel Installation")
		local solved = false
		local selected = 1
		local maxnr = 4
		while not solved do
			for i=1,maxnr do
				term.setCursorPos(1,i+2)
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
			--Export to User
			list = fs.list("")
			fs.makeDir("myTurtleOS/user/data/exported")
			clear()
			print("To Copy: "..textutils.serialize(list))
			for i=1, #list do
				if not fs.isReadOnly(list[i]) then
					if not list[i] == shell.getRunningProgram() then
						fs.copy(list[i],"myTurtleOs/user/data/exported/"..list[i])
						fs.delete(list[i])
						print("Copying "..list[i])
					end
				end
			end
			print("Finished!")
		elseif selected == 2 then
			--Delete Data
			if not fs.isReadOnly(list[i]) then
				fs.delete(list[i])
			end
		elseif selected == 3 then
			--Export to Disk
			clear()
			local copied = false
			
			function refresh()
				local sides = {"left","right","top","bottom","front","back"}
				local text = {"LEFT  >","RIGHT >","TOP   >","BOTTOM>","FRONT >","BACK  >"}
				for i=1,6 do
					if peripheral.isPresent(sides[i]) then
						if peripheral.getType(sides[i]) == "drive" then
							if disk.isPresent(sides[i]) then
								if disk.hasData(sides[i]) then
									print("Exporting...")
									sleep(1)
									dest = disk.getMountPath(sides[i])
									list = fs.list("")
									fs.makeDir(dest.."/exported")
									for i=1, #list do
										if not fs.isReadOnly(list[i]) then
											fs.copy(list[i],dest.."/exported/"..list[i])
											fs.delete(list[i])
										end
									end
									print("Export finished successfully! You can find your data now in '"..dest.."/exported' !")
									copied = true
									sleep(2)
								else
									textutils.slowPrint(text[i].." No floppy disk in disk drive!")
								end
							else
								textutils.slowPrint(text[i].." No disk in disk drive!")
							end
						else
							textutils.slowPrint(text[i].." No drive attached!")
						end
					else
						textutils.slowPrint(text[i].." No peripheral attached!")
					end
				end
			end
			
			while not copied do
			textutils.slowPrint("Press ENTER to cancel")
			textutils.slowPrint("Press SPACE to refresh")
				event, button = os.pullEvent("key")
				if button == 57 then
					clear()
					textutils.slowPrint("Refreshing...")
					refresh()
				elseif button == 28 then
					start()
				end
			end
		elseif selected == 4 then
			--Cancel Installation
			clear()
			print("Canceled Installation!")
			sleep(2)
			print("Rebooting...")
			sleep(1)
			os.reboot()
		end
		
		clear()
		function wait()
			sleep(math.floor(math.random(10,15)/10))
			clear()
			print("MYTURTLE OS - INSTALLING")
			print("--------")
			write("Installing Data: ")
		end
		if not fs.exists("myTurtleOS/system") then
			textutils.slowPrint("Starting Instalation...")
			wait()
			
			print("myTurtleOS")
				fs.makeDir("myTurtleOS")
			wait()
			
			print("myTurtleOS/system")
				fs.makeDir("myTurtleOS/system")
			wait()
			print("myTurtleOS/system/mto")
				fs.makeDir("myTurtleOS/system")
			wait()
			
			print("myTurtleOS/system/boot")
			wait()
			
			print("myTurtleOS/system/programs")
			wait()
			
			print("myTurtleOS/data")
			wait()
			
			print("myTurtleOS/data/programs")
			wait()
			
			print("myTurtleOS/settings")
			wait()
			
			print("myTurtleOS/user")
			wait()
			
			print("myTurtleOS/user/data")
			wait()
			
			print("myTurtleOS/user/programs")
			wait()
			
			print("myTurtleOS/plugins")
			wait()
			
			print("myTurtleOS/help")
			wait()
			
			print("myTurtleOS/start.exe")
			
			sleep(1)
			clear()
			textutils.slowPrint("Finished Successfully!")
			textutils.slowPrint("Rebooting...")
			sleep(2)
			os.reboot()

		else
			print("MYTURTLEOS was installed before!")
			sleep(2)
			start()
		end
	elseif selected == 2 then
		
	elseif selected == 3 then
		clear()
		textutils.slowPrint("Loading Updates...")
		sleep(2)
		clear()
		print("No updates found.")
		sleep(2)
		start()
	elseif selected == 4 then
		clear()
		textutils.slowPrint("OK, exiting myTurtleOS...")
		sleep(4)
		textutils.slowPrint("Rebooting...")
		sleep(2)
		os.reboot()
	end
end

start()
os.reboot()