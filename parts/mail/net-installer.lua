--SJNNET installer by MC403 (sEEKJEQc)

term.clear()
term.setCursorPos(1,1)

if fs.exists("SJNNET") then
	print("#SJNNET / INSTALL WARNING #")
	print("A version of SJNNET was found. What do you want to do?")
	print("> Reinstall")
	print("  Do nothing")
	print("  Exit")
	
	local solved = false local selected = 1 local maxnr = 3 local xOffset = 0 local yOffset = 3
	while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
	end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
	then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end
	
	if selected==1 then
		print("Deleting SJNNET...")
		sleep(0.5)
		fs.delete("SJNNET")
		print("Deleted!")
	elseif selected==3 then
		print("Press STRG + T for 5 seconds to terminate!")
		sleep(5000)
	end
end


term.clear()
term.setCursorPos(1,1)


print("#SJNNET#")
print("Which SJNNET program do you want to install?")
print("> SMail")
print("  SFile")
print("  SChat")
print("  STurtle")

local solved = false local selected = 1 local maxnr = 4 local xOffset = 0 local yOffset = 2
while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end

if selected == 1 then
	term.clear()
	term.setCursorPos(1,1)
	
	print("#SJNNET / SMail#")
	print("Which version of SMail do you want to install?")
	print("> Server")
	print("  Client")
	print("  Router")
	
	local solved = false local selected = 1 local maxnr = 3 local xOffset = 0 local yOffset = 2
	while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
	end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
	then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end
	
	if fs.exists("SJNNET/smail/launcher") then
		fs.delete("SJNNET/smail/launcher")
	end
	
	fs.makeDir("SJNNET/smail")
	
	term.clear()
	term.setCursorPos(1,1)
	if selected == 1 then
		print("Loading Software: smail.server")
		shell.run("pastebin","get","","SJNNET/smail/launcher") -- TODO: INSERT CODE
	elseif selected == 2 then
		print("Loading Software: smail.client")
		shell.run("pastebin","get","C01WFmZb","SJNNET/smail/launcher")
	elseif selected == 3 then
		print("Loading Software: smail.router")
		shell.run("pastebin","get","","SJNNET/smail/launcher") -- TODO: INSERT CODE
	end
	if fs.exists("SJNNET/smail/launcher") then
		print("Success!")
		print("Executing software...")
		sleep(1)
		shell.run("SJNNET/smail/launcher","#firstrun#")
	else
		term.clear()
		term.setCursorPos(1,1)
		print("Sorry, something went completly wrong!")
		print("DevInfo:")
		print("S: "..selected)
		print("F: SJNNET/smail/launcher")
		print("P: true")
		print("E: file.notLoadedCorrectly")
	end
else
	print("We are sorry to tell you that these programs are not programmed yet.")
end