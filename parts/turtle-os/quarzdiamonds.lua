--QuarzDiamons for myTurtleOS by MC403 (TNNbcaxp)

term.clear()
term.setCursorPos(1,1)

print("#################")
print("# QuarzDiamonds #")
print("#################")
print("# Am I a turtle?#")
print("# > Turtle      #")
print("#   Computer    #")
print("#################")

local solved = false local selected = 1 local maxnr = 2 local xOffset = 2 local yOffset = 4
while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end


if selected == 1 then
	--TURTLE
	term.clear()
	term.setCursorPos(1,1)
	print("Quartz & Diamonds")
	print("-Put one of a ore (for example diamonds) in the 16 slots!")
	print("-Refuel the Turtle before using it (Your fuel level: "..turtle.getFuelLevel()..")")
	print("")
	print("Press [ENTER] to start!")
	print("Press [R] to refuel!")

	local ok = false
	while not ok do
		local event, btn = os.pullEvent("key")
		if btn == 28 then
			ok = true
		elseif btn == 19 then
			for i=1,16 do
				turtle.select(i)
				turtle.refuel()
			end
			turtle.select(1)
		end
	end
	
	print("Modem attached on right")
	print("Waiting for a host...")
	
	if peripheral.getType("right") == "modem" then
		rednet.open("right")
		local received = false
		local hostID = nil
		
		while not received do
			local id, msg, dis = rednet.receive()
			if string.find(msg,"$SJN.MYTOS.QD.start") ~= nil then
				received = true
				hostID = id
				bedrock = string.sub(msg,string.find(msg,"#")+1,string.find(string.sub(msg,string.find(msg,"#")+1),"#")-1) --"$SJN.MYTOS.QD.start#355#" -> 355
			end
		end
		
		print("Your host is: #"..hostID)
		
		sleep(1)
		
		print("Starting...")
		
		function pastebin(code,file)
			if fs.exists(file) then
				print("Deleting "..file.."...")
				fs.delete(file)
			end
			shell.run("pastebin","get",code,file)
		end
		
		pastebin("G196Ysnr","m")
		sleep(0.1)
		pastebin("vz10Xn1s","p")
		
		sleep(1)
		
		shell.run("p",bedrock,hostID)
	else
		--NO MODEM
		print("!!! Please attach a modem on the right side of the turtle!")
	end
else
	--COMPUTER
	term.clear()
	term.setCursorPos(1,1)
	
	local modem = nil
	local sides = {"left","right","top","bottom","back","front"}
	for i=1,6 do
		if modem == nil then
			if peripheral.getType(sides[i]) == "modem" then
				modem = sides[i]
			end
		end
	end
	
	if modem ~= nil then
		rednet.open(modem)
		
		print("Quarz & Diamonds")
		print("Modem attached on "..modem)
		print("> Start Turtels")
		print("  Exit")
		print("  More Informations")
			
		local solved = false local selected = 1 local maxnr = 3 local xOffset = 0 local yOffset = 2
		while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
		end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
		then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end
		
		if selected == 1 then
			print("Ready turtles...")
			sleep(1.5)
			
			print("1/3: Please put items now into the turtles!")
			
			write("2/3: Y-Pos der Turtles: ")
			yposb = read()
			write("3/3: You need "..(yposb*2+10).." fuel. Please refuel the turtles!")
			
			os.pullEventRaw("key")
			
			
			print("Copying Files on turtles...")
			sleep(1)
			print("Success!")
			sleep(0.2)
			print("Starting QUARTZ&DIAMONDS...")
			
			rednet.broadcast("$SJN.MYTOS.QD.start#"..yposb.."#")
			
			sleep(0.5)
			
			term.clear()
			term.setCursorPos(1,1)
			
			function TIME()
				t = textutils.formatTime(os.time(),true)
				if string.len(t)==4 then
					t = "0"..t
				end
				return t
			end
			function LOG(text)
				term.setCursorPos(1,19)
				term.scroll(1)
				write(text)
			end
			
			local started = TIME()
			LOG(started..": Turtles started.")
			
			for timer=yposb*15,0, -1 do
				term.setCursorPos(1,1)
				term.clearLine()
				term.setCursorPos(1,1)
				print("Quartz & Diamonds - W="..timer.." T="..TIME()..", S="..started)
				
				for times=1,4 do
					local id, msg, dis = rednet.receive(0.25)
					if id ~= nil then
						LOG(TIME()..": "..id.." > "..msg)
					end
				end
			end
			
			sleep(0.5)
			
			print("Finished!")
			textutils.slowPrint("Thanks for using Quarz & Diamonds!")
			print("   by SJN!")
		elseif selected == 2 then
			print("OK, thanks for using Quarz & Diamonds!")
		elseif selected == 3 then
			print("This program is AWESOME!!!")
		end
	else
		--NO MODEM
		print("!!! Please attach a modem to one side!")
	end
end