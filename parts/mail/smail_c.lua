--SJNNET.SMAIL.CLIENT by MC403 (C01WFmZb)

term.clear()
term.setCursorPos(1,1)

local tArgs = {...}
if tArgs[1] == "#firstrun#" or not fs.exists("SJNNET/smail/settings") then
	print("Starting SMAIL")
	textutils.slowWrite("......")
	
	local sides = {"left","right","bottom","top","back","front"}
	local modem = nil
	for i=1,6 do
		if peripheral.getType(sides[i]) == "modem" then
			modem = sides[i]
		end
	end
	if modem == nil then
		print("WARNING: Please attach a wireless modem on one side of the computer!")
	else
		rednet.open(modem)
		term.clear()
		term.setCursorPos(1,1)
		print("Searching online servers...")
		
		result_id = {}
		result_msg = {}
		result_dis = {}
		
		for i=1,10 do
			notinlist = true
			rednet.broadcast("$SJN.NET.SMAIL.findServer")
			sleep(0.1)
			local id, msg, dis = rednet.receive(1)
			for i=1,#result_id do
				for j=1,#result_id do
					if result_id[i] == result_id[j] then
						notinlist = false
					end
				end
			end
			if msg == "$SJN.NET.SMAIL.iAmAServer" then
				if notinlist then
					table.insert(result_id,id)
					table.insert(result_msg,msg)
					table.insert(result_dis,dis)
					print(i.."/10: Server found: "..id)
					rednet.send(id,"$SJN.NET.SMAIL.thanksForAnswer")
				else
					print(i.."/10: NO SERVER FOUND")
				end
			elseif msg ~= nil then
				print(i.."/10: A computer send: "..msg)
			else
				print(i.."/10: NO SERVER FOUND")
			end
		end
		
		print("")
		print("")
		print("+++Press any key to continue+++")
		
		os.pullEvent("key")
		
		term.clear()
		term.setCursorPos(1,1)
		
		print("Connect with...")
		print("> none")
		for i=1,#result_id do
			write("  "..result_id[i])
			term.setCursorPos(30,i+2)
			print("("..result_dis[i].." Blocks away)")
		end
		
		local solved = false local selected = 1 local maxnr = #result_id +1 local xOffset = 0 local yOffset = 1
		while not solved do for i=1,maxnr do term.setCursorPos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
		end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
		then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end
		
		term.clear()
		term.setCursorPos(1,1)
		
		if selected == 1 then
			print("OK, but thanks for using SJNNET!")
			os.reboot()
		else
			serverID = result_id[selected-1]
			print("Connecting to "..serverID)
			
			rednet.send(serverID,"$SJN.NET.SMAIL.isItOKForYouIfIConnectToYou")
			local id, msg, dis = rednet.receive(10)
			if id == serverID and string.find(msg,"$SJN.NET.SMAIL.yesItIsOK") ~= nil then
				local packageStart = string.find(msg,"#") + 1
				local package = string.sub(msg,packageStart)
				local packageEnd = string.find(package,"#") - 1
				local marker = string.find(msg,",")
				
				local sinfo_users = string.sub(msg,packageStart,marker-1)
				local sinfo_text = string.sub(msg,marker+1,packageEnd)
				
				print("Connected to "..id)
				print("")
				print("INFORMATIONS:")
				print("Connected Users: "..sinfo_users)
				print("Text:"..sinfo_text)
				print("")
				print("+++Press any key to continue+++")
				os.pullEvent("key")
				
				f = fs.open("SJNNET/smail/settings","w")
				f.write("server="..serverID)
				f.close()
			else
				print("WARNING: The Server "..result_id[selected-1].." does not response!")
				print("-Make sure, that this server is online now")
				print("-Try again!")
				print("-If it does not work a second time, try another server or setup your own one with sEEKJEQc")
				print("")
				print("+++Press any key to continue+++")
				os.pullEvent("key")
				os.reboot()
			end
		end
	end
end

local f = fs.open("SJNNET/smail/settings","r")
local c1 = f.readLine()
local c2 = string.find(c1,"=")
serverID = string.sub(c1,c2+1)
serverID = tonumber(serverID)
f.close()

if term.isColor() then
	local on = true
	local dlg = 0
	local selected = 1
	local notifications = {0,1,10,19,3,36,0,0,0,0,0,0}
	
	function clear()
		term.setTextColor(colors.cyan)
		term.setBackgroundColor(colors.white)
		term.clear()
		term.setCursorPos(1,1)
	end
	function drawTitleInner(text)
		term.setCursorPos(1,1)
		term.setTextColor(colors.white)
		term.setBackgroundColor(colors.cyan)
		term.clearLine()
		print(text)
		term.setBackgroundColor(colors.white)
		term.setTextColor(colors.cyan)
	end
	function drawTitle()
		drawTitleInner(" SMail")
	end
	
	function drawMenu()
		term.setBackgroundColor(colors.gray)
		term.setTextColor(colors.white)
		for i=2,19 do
			term.setCursorPos(1,i)
			write("            ")
		end
		texts = {"Welcome","Mails   ","Sent    ","Drafts  ","Deleted ","Files   ","Contacts","New Mail","Refresh ","About   ","I am ...","Settings"}

		notifications[selected] = 0
		
		for i=1,#texts do
			term.setTextColor(colors.white)
			term.setCursorPos(1,i+1)
			if notifications[i] > 0 then
				write(" "..texts[i])
				for i=2,#tostring(notifications[i]), -1 do
					write(" ")
				end
				term.setTextColor(colors.red)
				write(notifications[i])
			else
				write(" "..texts[i].."   ")
			end
		end
		
		term.setCursorPos(1,selected+1)
		term.setBackgroundColor(colors.lightGray)
		write(" "..texts[selected].."    ")
		
	end
	function drawContent()
		
	end
	
	function desktop()
		clear()
		drawTitle()
		drawMenu()
		drawContent()
	end
	
	desktop()
	while on do
		local event, button, x, y = os.pullEvent()
		if dlg == 0 then
			--Normal
			if event == "mouse_click" and button==1 then
				if x<=12 and y==10 then
					--Check
					rednet.send(serverID,"$SJN.NET.SMAIL.user.check")
					solved = false
					result = nil
					maininfo = nil
					transinfo = nil
					counter = 0
					
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.lightGray)
					for i=1,7 do
						term.setCursorPos(15,7+i)
						write("                    ")
					end
					
					function answer(text1,text2,text3)
						term.setCursorPos(17,9)
						write(text1)
						term.setCursorPos(17,10)
						write(text2)
						term.setCursorPos(17,11)
						write(text3)
						term.setCursorPos(19,13)
						write("OK")
					end
					
					while not solved do
						dlg = 1
						counter = counter + 1
						if counter > 5 then
							solved = true
							result = "error_c"
							answer("","No connection","")
						end
						local id, msg, dis = rednet.receive(1)
						local gotTime = textutils.formatTime(os.time(),true)
						if id==serverID then
							solved = true
							if msg=="$SJN.NET.SMAIL.user.check.false" then
								result = "mail_0"
								answer("","No mail received.","")
							elseif string.find(msg,"$SJN.NET.SMAIL.user.check.true") then
								--$SJN.NET.SMAIL.user.check.true#<SENDER>s2|1|<DESTINATION>|2|<TITLE>|3|<TIME>|4|<CONTENT>#
								result = "mail_1"
								
								local packageStart = string.find(msg,"#")+1
								local package = string.sub(msg,packageStart)
								
								local senderM = string.find(package,"|1|")
								local destM = string.find(package,"|2|")
								local titleM = string.find(package,"|3|")
								local timerM = string.find(package,"|4|")
								local packageEnd = string.find(package,"#")-1
								
								local sender = string.sub(msg,packageStart,senderM-1)
								local dest = string.sub(msg,senderM+3,destM-1)
								local title = string.sub(msg,destM+3,titleM-1)
								local timer = string.sub(msg,titleM+3,timerM-1)
								local content = string.sub(msg,timerM+3,packageEnd)
								
								maininfo = {sender, dest, title, timer, content}
								transinfo = {id, dis, gotTime}
								
								answer("New mail received!","From   "..sender,"Title  "..title)
							else
								result = "error_s"
								answer("Server error!")
							end
						end
					end
				end
			end
		elseif dlg==1 then
			--Check
			if event=="mouse_click" and button==1 and x>=19 and x<=20 and y==13 then
				if result == "mail_1" then
					clear()
					drawTitleInner(" SMail - "..maininfo[3])
					term.setBackgroundColor(colors.gray)
					term.setTextColor(colors.lightGray)
					for i=2,6 do
						term.setCursorPos(1,i)
						term.clearLine()
					end
					term.setCursorPos(1,3)
					print(" From     "..maininfo[1])
					print(" Title    "..maininfo[3])
					print(" Sended   "..maininfo[4])
					
					term.setCursorPos(1,8)
					term.setTextColor(colors.gray)
					term.setBackgroundColor(colors.white)
					print(maininfo[5])
				end
			end
		end
	end
else
	print("The SMAIL.CLIENT.NOCOLOR version will come later!")
end