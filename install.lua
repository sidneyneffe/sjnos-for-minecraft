--SJNOS by MC403. installer.exe (A343Rqi6)

local WIDTH, HEIGHT = term.getSize()

local tArgs = {...}

local install_result = false


fs.makeDir("SJNOS")
local INSTALLATION_PATH = "SJNOS/.install"
fs.delete(INSTALLATION_PATH)
fs.makeDir(INSTALLATION_PATH)

print("Preparing for installation...")
shell.run("pastebin get Ab5cy6F2 " .. INSTALLATION_PATH .."/sjn")


local function start()


local function FUNC_downloadPart(code)
	tcolor(colors.lightGray)
	bcolor(colors.gray)
	clear()
	function w(text)
		term.scroll(1)
		cpos(1,19)
		write(text)
		sleep(0.2)
	end

	w("Starting Download...")
	w("Downloading...")
	fs.delete("SJNOS")
	fs.makeDir("SJNOS")
	fs.makeDir("SJNOS/api")
	shell.run("pastebin get "..code.." SJNOS/partinstaller.exe")
	shell.run("pastebin get Ab5cy6F2 SJNOS/api/sjn")
	sleep(0.5)
	w("Download finished.")
	sleep(1)
	w("Installing...")


	shell.run("SJNOS/partinstaller.exe install")
	if (fs.exists("SJNOS/.installed")) then
		fs.delete("SJNOS/.installed")
		tcolor(colors.lime)
		w("Installation finished successfully!")
		tcolor(colors.lightGray)
		sleep(1)
		os.reboot()
	else
		tcolor(colors.red)
		w("Error in installation.")
		tcolor(colors.yellow)
		sleep(0.3)
		w("Cleaning up downloaded files...")
		sleep(0.5)
		fs.delete("SJNOS/partinstaller.exe")
		w("Downloaded files removed.")
		w("Try to install the part of SJNOS again. If it won't succeed this time, message our developers. Thanks!")
		sleep(1)
		w("Press any key to exit the installation.")
		os.pullEvent("key")
	end
end

if (not term.isColor()) then
	clear()
	cpos(1,1)
	local input = string.lower(read())
	textutils.slowWrite("DEVELOPER-INSTALL\n$ ")
	local code = nil

	if (input == "turtle server") then
		code = "xnVe5jHD"
	elseif (input == "turtle turtle") then
		code = "GzQAcQpf"
	elseif (input == "web dns") then
		code = "cu5YT97U"
	elseif (input == "web server") then
		code = "f5Arw7GJ"
	end

	if (code) then
		FUNC_downloadPart(code)
	else
		print("Does not exist.")
	end
end

local WIDTH, HEIGHT = term.getSize()
local cpos, clear, tcolor, bcolor, getTime = sjn.getStandardFunctions()

local function showDialog(head, texts, buttons, enterButton, delay)
	return sjn.showDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, buttons, enterButton, delay)
end
local function showInputDialog(head, texts, buttons, enterButton, delay, autoFocus, alternative)
	return sjn.showInputDialog(head, texts, colors.orange, colors.gray, colors.gray, colors.orange, colors.cyan, colors.lightGray, buttons, enterButton, delay, autoFocus, alternative)
end




local f = fs.open(INSTALLATION_PATH .. "/sjn.img","w")
f.writeLine("999909999090090111101111")
f.writeLine("900000009099090100101000")
f.writeLine("999900009090990100101111")
f.writeLine("000900009090090100100001")
f.writeLine("999909999090090111101111")
f.close()

local img = paintutils.loadImage(INSTALLATION_PATH .. "/sjn.img")

if fs.exists("SJNOS/users") or fs.exists("SJNOS/system") or fs.exists("SJNOS/data") then
	bcolor(colors.white)
	tcolor(colors.cyan)
	clear()
	cpos(1,1)
	write("SJNOS")
	cpos(47,1)
	write(getTime())


	paintutils.drawImage(img,14,5)

	bcolor(colors.white)
	tcolor(colors.cyan)
	local text = "Deinstall SJNOS?"
	cpos(math.floor((WIDTH-string.len(text))/2),12)
	write(text)
	tcolor(colors.cyan)
	bcolor(colors.orange)
	cpos(21,14)
	write("Yes")
	cpos(26,14)
	write("No")

	local solved = false
	while not solved do
		local event, btn, x, y = os.pullEventRaw()
		if event=="mouse_click" and btn==1 and y==14 then
			if x>=21 and x<=23 then
				solved = true
				fs.delete("SJNOS")
				fs.delete("startup")
			elseif x>=26 and x<=27 then
				solved = true
				bcolor(colors.black)
				clear()
				cpos(1,1)
				return true
			end
		end
	end
end

local installer_first = true

function drawMain()
	tcolor(colors.cyan)
	bcolor(colors.white)
	cpos(1,1)
	clear()
	write("SJNOS")
	cpos(47,1)
	write(getTime())

	paintutils.drawImage(img, 14,5)

	bcolor(colors.white)
	tcolor(colors.cyan)

	if (installer_first) then
		cpos(17,12)
		textutils.slowWrite("Hello! Do you want")
		cpos(17,13)
		textutils.slowWrite("to install SJNOS?")
		installer_first = false
	else
		cpos(17,12)
		write("Hello! Do you want")
		cpos(17,13)
		write("to install SJNOS?")
	end

	cpos(17,15)
	tcolor(colors.cyan)
	bcolor(colors.orange)
	write("Yes")
	cpos(23,15)
	write("No")
	cpos(29,15)
	write("Parts")
	cpos(1,19)

	while true do
		local event, btn, x, y = os.pullEventRaw()
		if event == "mouse_click" and btn == 1 and y == 15 then
			if x>=17 and x<=19 then
				return 1
			elseif x>=23 and x<=25 then
				return 2
			elseif x>=29 and x<=34 then
				return 3
			end
		end
	end
end


local installer_running = true

function installer_run()
	local selected = drawMain()

	if selected == 1 then
		--Install
		tcolor(colors.cyan)
		bcolor(colors.white)
		clear()
		cpos(1,1)

		local pclabel = ""
		local pcname = ""
		local isRednet = sjn.getRednet(true)
		local dnsServer = nil

		local function installer1()
			bcolor(colors.white)
			clear()
			tcolor(colors.orange)
			bcolor(colors.cyan)
			cpos(1,1)
			term.clearLine()
			write("SJNOS - Installer: 1/2")
			cpos(47,1)
			write(getTime())

			cpos(1,19)
			term.clearLine()
			cpos(2,19)
			write("Cancel")
			cpos(WIDTH - 4,19)
			write("Next")

			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(math.floor((WIDTH-string.len("PC-Settings"))/2),3)
			write("PC-Settings")


			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(15,5)
			write("PC-Label: ")
			bcolor(colors.gray)
			tcolor(colors.orange)
			write("            ")
			cpos(25,5)
			write(pclabel)
			bcolor(colors.white)
			cpos(15,7)
			tcolor(colors.cyan)
			write("PC-Name:  ")
			bcolor(colors.gray)
			write("            ")
			tcolor(colors.orange)
			cpos(25,7)
			write(pcname)

			tcolor(colors.cyan)
			bcolor(colors.white)
		end

		local function installer2()
			isRednet = sjn.getRednet(true)

			bcolor(colors.white)
			clear()
			tcolor(colors.orange)
			bcolor(colors.cyan)
			cpos(1,1)
			term.clearLine()
			write("SJNOS - Installer: 2/2")
			cpos(47,1)
			write(getTime())

			cpos(1,19)
			term.clearLine()
			cpos(2,19)
			write("Cancel")
			cpos(WIDTH - 4, 19)
			write("Next")

			tcolor(colors.cyan)
			bcolor(colors.white)
			local text = "Rednet"
			cpos(math.floor((WIDTH-string.len("Rednet"))/2) + 1, 4)
			write("Rednet")
			if (isRednet) then
				--Rednet
				bcolor(colors.white)
				tcolor(colors.cyan)
				cpos(5,7)
				write("Internet Server (DNS):    ")
				if dnsServer==nil then
					tcolor(colors.red)
					write("None")
				else
					tcolor(colors.lime)
					write(dnsServer)
				end
				cpos(39,7)
				tcolor(colors.cyan)
				bcolor(colors.orange)
				write("Search")
			else
				--No Rednet
				cpos(9,6)
				write("You have no wireless modem installed")
				cpos(9,7)
				write("on your PC. If you want to install a")
				cpos(9,8)
				write("modem, just attach it to this PC.")
			end
		end


		installer1()
		while true do
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				if y==19 then
					if x >= 1 and x <= 2+6 then
						--Cancel
						return false
					elseif  x>= WIDTH-5 and x <= WIDTH then
						--Next
						if pclabel~="" and pcname~="" then
							break
						else
							showDialog("Installer", {'Please enter a name and a label.', 'A label saves your files if you', 'break your PC. The name will', 'be displayed inside SJNOS.'}, {{colors.lime, colors.gray, "Okay"}})
							installer1()
						end
					end
				elseif x>=25 and x<=47 and y==5 then
					cpos(25,5)
					bcolor(colors.gray)
					write("            ")
					tcolor(colors.orange)
					cpos(25,5)

					pclabel = read()
				elseif x>=25 and x<=47 and y==7 then
					cpos(25,7)
					bcolor(colors.gray)
					write("            ")
					tcolor(colors.orange)
					cpos(25,7)

					pcname = read()
				end
			end
		end

		local timer = os.startTimer(1)

		installer2()

		while true do
			installer2()
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				if (isRednet) then
					--Rednet
					if y==19 then
						if x >= 1 and x <= 2+6  then
							--Cancel
							return false
						elseif x >= WIDTH-5 and x <= WIDTH then
							--Next
							if (dnsServer == nil) then
								if 1 == showDialog("Installer", {'Do you really want to continue', 'without internet?', '(You can do this later as well.)'}, {{colors.lime, colors.gray, "Continue"}, {colors.red, colors.gray, "Stay"}}, 2) then
									break
								end
							else
								break
							end
						end
					elseif y==7 and x>=39 and x<=44 then
						--Search for DNS Server
						tcolor(colors.cyan)
						bcolor(colors.white)
						clear()
						cpos(1,1)
						textutils.slowPrint("Searching...", 60)

						local dns = {}

						rednet.broadcast("~SJN@SWEBCLIENT:GETDNSSERVER")
						sleep(0.1)
						for i=1, 17 do
							local id, msg, dis = rednet.receive(0.1)
							if (id~=nil) then
								if (string.find(msg,"~SJN@SWEBDNS:GETDNSSERVER:TRUE")==1) then
									local p1, p2 = string.find(msg,"~SJN@SWEBDNS:GETDNSSERVER:TRUE")
									local info = string.sub(msg,p2+2)

									table.insert(dns,{id=id, msg=msg, info=info})
								end
							end
						end

						if (#dns == 0) then
							tcolor(colors.red)
							print("Failed.\n")
							sleep(1)

							tcolor(colors.cyan)
							print("You can setup a DNS-Server yourself:")
							print("1. Run the SJNOS-Installer")
							print("2. Click 'Parts' and install SJNWEB -> S-Web -> DNS Server")
							print("3. Hit 'DOWNLOAD' and wait for the installation to finish.")
							print("Now you have a DNS Server!\n\n")
							print("Press any key to return to the installer.")
							os.pullEventRaw("key")
							return false
						end

						tcolor(colors.cyan)
						bcolor(colors.white)
						cpos(1,1)
						clear()
						print("Avalible DNS-SERVERS:")

						for i=1,#dns do
							cpos(1,i+1)
							tcolor(colors.orange)
							write("  #")
							tcolor(colors.cyan)
							write(dns[i].id)
							tcolor(colors.orange)
							write(" - ")
							tcolor(colors.cyan)
							write(string.sub(dns[i].info,0,30))
						end

						cpos(1, #dns + 2)
						tcolor(colors.red)
						write("  CANCEL")
						tcolor(colors.cyan)

						cpos(1,2)
						write(">")

						local solved = false local selected = 1 local maxnr = #dns + 1 local xOffset = 0 local yOffset = 1
						while not solved do for i=1,maxnr do cpos(1+xOffset,i+yOffset) if i==selected then print(">") else print(" ") end
						end local event, button = os.pullEvent("key") if button==208 then if selected<maxnr then selected = selected + 1 else selected = 1 end elseif button==200
						then if selected>1 then selected = selected - 1 else selected = maxnr end elseif button==28 then solved = true end end

						if (selected <= #dns) then
							local DNS = dns[selected].id
							dnsServer = DNS
						else
							dnsServer = nil
						end

						installer2()
					end
				else
					--Kein Rednet
					if y==19 then
						if x >= 1 and x <= 2+6 then
							--Cancel
							return false
						elseif x >= WIDTH-5 and x <= WIDTH then
							--Next
							if 1 == showDialog("Installer", {'Do you really want to continue', 'without internet?', '(You can do this later as well.)'}, {{colors.lime, colors.gray, "Continue"}, {colors.red, colors.gray, "Stay"}}, 2) then
								break
							end
						end
					end
				end
			end
			timer = os.startTimer(1)
		end


		local f = fs.open(INSTALLATION_PATH .. "/netconfig", "w")
		if (f) then
			if (dnsServer ~= nil and tonumber(dnsServer) and tonumber(dnsServer) > 0) then
				local text = "dns=" .. dnsServer
				f.writeLine(text)
			else
				f.writeLine("dns=-1")
			end
			f.close()
		else
			sjn.showInfoDialogDESIGN("DNS", {"Warning: DNS Server could not be saved!", "Please reboot your PC and restart", "the installation."}, DESIGN_BLUE)
		end

		local f = fs.open(INSTALLATION_PATH .. "/name","w")
		f.writeLine("pcname="..pcname)
		f.close()

		os.setComputerLabel(pclabel)

		function draw()
			bcolor(colors.white)
			clear()
			cpos(1,1)
			bcolor(colors.cyan)
			tcolor(colors.orange)
			term.clearLine()
			write("SJNOS - Installer")
			cpos(47,1)
			write(getTime())
			cpos(1, HEIGHT)
			term.clearLine()
			cpos(2, HEIGHT)
			write("Cancel")
			cpos(WIDTH-7, HEIGHT)
			write("Install")

			tcolor(colors.cyan)
			bcolor(colors.white)
			cpos(10,5)
			write("SJNOS is now ready for the Instal-")
			cpos(10,6)
			write("lation. With pressing 'Install' you")
			cpos(10,7)
			write("agree to the ")
			tcolor(colors.cyan)
			bcolor(colors.orange)
			write("terms&conditions")
			tcolor(colors.cyan)
			bcolor(colors.white)
			write(".")
			cpos(10,8)
			write("Have fun with SJNOS!!!")
		end

		draw()

		while true do
			local event, btn, x, y = os.pullEventRaw()
			if event=="mouse_click" and btn==1 then
				if y==19 then
					if x >= 1 and x <= 1+7 then
						--Cancel
						return false
					elseif x >= WIDTH-8 and x <= WIDTH then
						--Install
						break
					end
				elseif y==7 and x>=26 and x<=41 then
					--AGB
					bcolor(colors.white)
					clear()
					cpos(1,1)
					bcolor(colors.cyan)
					tcolor(colors.orange)
					term.clearLine()
					term.write("SJNOS - Terms & Conditions")
					cpos(51,1)
					tcolor(colors.black)
					bcolor(colors.red)
					write("X")
					tcolor(colors.cyan)
					bcolor(colors.white)
					cpos(1,3)
					print("SJNOS was made by Sidney Neffe (MC403) in 2014-16.")
					print("It is made for ComputerCraft. I made this program")
					print("only for fun and do not take responsibility for any")
					print("damage.\n")
					print("You can do basicly everything with SJNOS e.g. view")
					print("it or changing code, as long as you mention")
					print("my name within your program.\n")
					print("I would like to thank NitrogenFingers and NDFJay")
					print("for inspiring me during this project.\n")
					print("Have fun with SJNOS!\n")
					print("Sidney Neffe, 12.2.2016")

					while true do
						local event, btn, x, y = os.pullEventRaw()
						if event=="mouse_click" and btn==1 and x==51 and y==1 then
							break
						end
					end

					draw()
				end
			end
		end

		local done = 0

		function draw(file, text)
			bcolor(colors.white)
			tcolor(colors.cyan)
			clear()

			cpos(1,1)
			write("SJNOS")
			cpos(47, 1)
			write(getTime())

			cpos(10,7)
			term.clearLine()
			write("C:/"..file)

			cpos(10,10)
			bcolor(colors.lightGray)
			write("                                 ")

			bcolor(colors.orange)
			cpos(10,10)
			for i=1,done do
				write(" ")
			end

			bcolor(colors.white)
			cpos(10,13)
			if text~= nil then
				write(text)
			end

			cpos(1,19)
		end


		function import(path,code)
			if (code ~= '--------') then
				draw(path,"Importing Data...")
				shell.run("pastebin","get",code,path)
			end
		end
		function makeDir(path)
			draw(path,"Making Directory...")
			fs.makeDir(path)
		end
		function makeFile(path, content)
			draw(path, "Making a new File...")
			local h = fs.open(path,"w")
			for i=1, #content do
				h.writeLine(content[i])
			end
			h.close()
			sleep(0.1)
		end

		function changeDone()
			done = done + 1
		end

		draw("","Starting Installation...")changeDone()
		makeDir("SJNOS")changeDone()
		makeDir("SJNOS/system")changeDone()
			makeDir("SJNOS/system/about")changeDone()
				makeFile("SJNOS/system/about/ver.txt",{"ver=1.4.3","status=Alpha"})
			makeDir("SJNOS/system/SJNOS")changeDone()
				import("SJNOS/system/SJNOS/desktop.sys","qK1cVg8R")changeDone()
				import("SJNOS/system/SJNOS/login.sys","ztDHMfrm")
				import("SJNOS/system/SJNOS/applications.sys","gNEADRX9")changeDone()
				import("SJNOS/system/SJNOS/network.sys","vpwucSht")
				import("SJNOS/system/SJNOS/deinstall.sys","i8DykZUj")changeDone()
				import("SJNOS/system/SJNOS/rednet.sys","pQbhxiMi")changeDone()
				import("SJNOS/system/SJNOS/peripherals.sys","46bGWX3t")changeDone()
				import("SJNOS/system/SJNOS/sjn","Ab5cy6F2")changeDone()
		makeDir("SJNOS/net")changeDone()
			makeDir("SJNOS/net/web")changeDone()
				import("SJNOS/net/web/sweb","Bex5SsgL")changeDone()
		makeDir("SJNOS/data")changeDone()
			makeDir("SJNOS/data/icons")changeDone()
				makeFile("SJNOS/data/icons/sjn.img",{"9999 9999 9  9 1111 1111","9       9 99 9 1  1 1   ","9999    9 9 99 1  1 1111","   9    9 9  9 1  1    1","9999 9999 9  9 1111 1111"})changeDone()
				makeDir("SJNOS/data/icons/desktop")changeDone()
					makeFile("SJNOS/data/icons/desktop/desktop.img",{"00000000","ffffffff","f999999f","f999999f","ffffffff","000ff000","0ffffff0"})
					makeFile("SJNOS/data/icons/desktop/apps.img",{"77777777","77999177","79777917","79777917","79999917","79777917","77777777"})
					makeFile("SJNOS/data/icons/desktop/files.img",{"88888888","87777778","88888888","87777778","88888888","87777778","88888888"})
					makeFile("SJNOS/data/icons/desktop/plugins.img",{"44444444","44444444","4ff44f44","ff44efff","4ff44f44","44444444","44444444"})changeDone()
					makeFile("SJNOS/data/icons/desktop/settings.img",{"aaaaaaaa","aaa00aaa","aa0000aa","a00aa00a","aa0000aa","aaa00aaa","aaaaaaaa"})
					makeFile("SJNOS/data/icons/desktop/peripheral.img",{"ffffffff","f777777f","f788888f","f777777f","f777777f","f7775e7f","ffffffff"})
					makeFile("SJNOS/data/icons/desktop/network.img",{"88888888","88788788","87888878","87877878","87888878","88788788","88888888"})changeDone()
					makeFile("SJNOS/data/icons/desktop/help.img",{"11111111","11777111","17111711","11111711","11177111","11111111","11171111"})
				makeDir("SJNOS/data/icons/users")changeDone()
					makeFile("SJNOS/data/icons/users/img.cfg",{"cc.img=ComputerCraft","football.img=Football","flower.img=Flower","tree.img=Tree","book.img=Book","money.img=Money","cactus.img=Cactus","spider.img=Spider","boat.img=Boat"})
					makeFile("SJNOS/data/icons/users/cc.img",{"fffffffffffff","f77777777777f","f7f0fffffff7f","f7ff0ff00ff8f","f8f0fffffff8f","f88888888888f","f888888885e8f","fffffffffffff"})changeDone()
					makeFile("SJNOS/data/icons/users/football.img",{"   7777777","  70ffff007"," 70000000007"," 700000fff07"," 7fff00fff07"," 7fff0000007","  7ff00fff7","   7777777"})
					makeFile("SJNOS/data/icons/users/flower.img",{"4443333333333","4443344433333","3333411143333","3333344433333","3333535353333","3333355533333","3333335333333","ddddddddddddd"})
					makeFile("SJNOS/data/icons/users/tree.img",{"3333333333444","3333555553444","3333555553333","3333555553555","555333c333555","555333c3333d3","3c3333c3333c3","ddddddddddddd"})changeDone()
					makeFile("SJNOS/data/icons/users/book.img",{"ccccccccccccc","cccfffffffccc","cccf33433fccc","cccf34143fccc","cccf33533fccc","cccfdddddfccc","cccfffffffccc","ccccccccccccc"})
					makeFile("SJNOS/data/icons/users/money.img",{"","    11111","   1474471","  147747471","  174747471","   1474471","    11111",""})changeDone()
					makeFile("SJNOS/data/icons/users/cactus.img",{"4433333333333","443ddd3333333","333d8d3ddd333","333ddd3ddd333","333ddddd8d333","33333d8ddd333","33333ddd33333","4444444444444"})
					makeFile("SJNOS/data/icons/users/spider.img",{"ccccccccccccc","ccfccfffccfcc","cffcfffffcffc","ffcfffffffcff","fccfefffefccf","fcccfffffcccf","ccccccccccccc","ccccccccccccc"})
					makeFile("SJNOS/data/icons/users/boat.img",{"3333000033444","3330000003444","3300000000333","333333c333333","3888888888883","bb888888888bb","bbbb88888bbbb","bbbbbbbbbbbbb"})
				makeDir("SJNOS/data/icons/system")changeDone()
					makeFile("SJNOS/data/icons/system/boot.img",{"  11111111"," 999999991","0000000091","000000009","00000000"})
			makeDir("SJNOS/data/programs")changeDone()
				import("SJNOS/data/programs/terminal.exe","GdZsddz6")
				import("SJNOS/data/programs/filemgr.exe","3FEeWeG8")changeDone()
				import("SJNOS/data/programs/internet.exe","tCzfDtdK")
				import("SJNOS/data/programs/wfm.exe","8JdUff3c")changeDone()
				import("SJNOS/data/programs/p+.exe","rFhpFNrU")
		makeDir("SJNOS/settings")changeDone()
			makeFile("SJNOS/settings/settings.set",{"--------"})changeDone()
			fs.copy(INSTALLATION_PATH .."/name", "SJNOS/settings/name.set")
			if (fs.exists(INSTALLATION_PATH .. "/netconfig")) then --TODO: Fix this Problem!
				fs.copy(INSTALLATION_PATH .. "/netconfig","SJNOS/settings/net.set")
			end
		makeDir("SJNOS/users")changeDone()
		makeDir("SJNOS/plugins")changeDone()
		makeFile("startup",{"--SJNOS: Auto genered startup. It will run SJNOS.","if fs.exists('SJNOS/start.exe') then","shell.run('SJNOS/start.exe')","else print('Error! Please reinstall SJNOS!') end"})
		import("SJNOS/start.exe","XBSAvvxB")changeDone()
		makeFile("SJNOS/firstrun",{"true"})

		draw("","Installing...")

		draw("","Finished!")

		sleep(0.5)

		bcolor(colors.white)
		tcolor(colors.cyan)
		clear()
		sleep(2)
		cpos(1,1)
		write("SJNOS")
		cpos(47,1)
		write(getTime())

		paintutils.drawImage(img,14,5)

		bcolor(colors.white)
		tcolor(colors.cyan)

		local text = "Rebooting..."
		cpos(math.floor((WIDTH - #text)/2 + 1), 14)
		textutils.slowWrite(text)

		sleep(0.8)

		bcolor(colors.gray)
		clear()
		sleep(1)
		install_result = true
		installer_running = false
		return true
	elseif selected == 2 then
		--Exit
		tcolor(colors.cyan)
		bcolor(colors.white)
		cpos(1,1)
		clear()
		write("SJNOS")
		cpos(47,1)
		write(getTime())


		paintutils.drawImage(img,14,5)

		bcolor(colors.white)
		tcolor(colors.cyan)

		cpos(17,12)
		textutils.slowWrite("Okay, but you can")
		cpos(17,13)
		textutils.slowWrite("install SJNOS at")
		cpos(17,14)
		textutils.slowWrite("any time. Bye!")
		sleep(1.5)
		bcolor(colors.black)
		tcolor(colors.white)
		clear()
		cpos(1,1)

		installer_running = false
	elseif selected == 3 then
		--Parts
		local COLOR_LEFT_BG = colors.lightGray
		local COLOR_LEFT_TEXT = colors.cyan
		local COLOR_LEFT_SEL_BG = colors.orange
		local COLOR_LEFT_SEL_TEXT = colors.white

		local COLOR_MIDDLE_BG = colors.lightGray
		local COLOR_MIDDLE_TEXT = colors.cyan
		local COLOR_MIDDLE_SEL_BG = colors.orange
		local COLOR_MIDDLE_SEL_TEXT = colors.white

		local COLOR_BG = colors.white
		local COLOR_TEXT = colors.cyan
		local COLOR_HEAD_BG = colors.cyan
		local COLOR_HEAD_TEXT = colors.orange

		local left = {" SJNOS        "," SJNWEB       "}
		local middle = {{" %            "},{" Internet     "," Turtles      "}}
		local right = {{{" %"}},{{" Server"," DNS Server"},{" Server"," Turtle"}}}
		local text = {{
				{"%"}
			},{
				{"Server Version for S-Web. Write a website and put in on the server!","DNS Server for S-Web. It allows you to write a webserver name (for example 'website.com') instead of using a id (for example '25')."},
				{"Turtle Server. Connect many turtles!","Turtle program for connecting with a turtle server."}
			}}
		local safety = {{
				{"%"}
			},{
				{"This Computer is with S-Web only useable as a server, not as a client. The following paths are needed: 'SJNOS','startup'",""},
				{"This Computer is with the Turtle Server only useable as a server. We need these places: 'SJNOS','startup'",""}
			}}
		local link = {{{""}},{{"f5Arw7GJ","cu5YT97U"}, {"xnVe5jHD", "GzQAcQpf"}}}
		local selected = {1,1}


		local function draw()
			bcolor(COLOR_BG)
			clear()
			bcolor(COLOR_HEAD_BG)
			tcolor(COLOR_HEAD_TEXT)
			cpos(1,1)

			term.clearLine()
			cpos(1,1)
			write(" SJNOS - Install Parts")
			cpos(51,1)
			tcolor(colors.white)
			bcolor(colors.red)
			write("X")

			tcolor(COLOR_LEFT_TEXT)
			bcolor(COLOR_LEFT_BG)
			for i=1,18 do
				cpos(1,1+i)
				if (selected[1] == i) then
					bcolor(COLOR_LEFT_SEL_BG)
					tcolor(COLOR_LEFT_SEL_TEXT)
				end

				write(left[i] or '              ')

				if (selected[1] == i) then
					bcolor(COLOR_LEFT_BG)
					tcolor(COLOR_LEFT_TEXT)
				end
			end

			tcolor(COLOR_MIDDLE_TEXT)
			bcolor(COLOR_MIDDLE_BG)
			for i=1,18 do
				cpos(15,i+1)
				if (selected[2] == i) then
					bcolor(COLOR_MIDDLE_SEL_BG)
					tcolor(COLOR_MIDDLE_SEL_TEXT)
				end

				write(middle[selected[1]][i] or '              ')

				if (selected[2] == i) then
					tcolor(COLOR_MIDDLE_TEXT)
					bcolor(COLOR_MIDDLE_BG)
				end
			end

			tcolor(COLOR_TEXT)
			bcolor(COLOR_BG)
			for i=1,18 do
				cpos(29,i+1)
				write(right[selected[1]][selected[2]][i] or '              ')
			end
		end

		draw()

		local r = true
		local cancel = false

		while r do
			local event, btn, x, y = os.pullEventRaw()
			if (event=="mouse_click" and btn==1) then
				if (y==1) then
					--MENU BAR
					if (x==51) then
						--Exit
						r = false
						cancel = true
					end
				else
					if (x<=14) then
						--LEFT
						for i=1,#left do
							if (y-1==i) then
								selected[1] = i
								break
							end
						end
						selected[2] = 1
						draw()
					elseif (x<=28) then
						--MIDDLE
						for i=1,#middle[selected[1]] do
							if (y-1==i) then
								selected[2] = i
								break
							end
						end
						draw()
					else
						--Right
						for i=1,#right[selected[1]][selected[2]] do
							if (y-1==i) then
								cpos(29,y)
								tcolor(COLOR_MIDDLE_SEL_TEXT)
								bcolor(COLOR_MIDDLE_SEL_BG)

								local t = right[selected[1]][selected[2]][i]

								for i=#t,22 do
									t = t.." "
								end
								write(t)
								sleep(0.25)

								bcolor(COLOR_BG)
								clear()
								cpos(1,1)
								tcolor(COLOR_HEAD_TEXT)
								bcolor(COLOR_HEAD_BG)
								term.clearLine()
								write(" Install"..right[selected[1]][selected[2]][i].." for"..middle[selected[1]][selected[2]])

								cpos(51,1)
								tcolor(colors.white)
								bcolor(colors.red)
								write("X")

								tcolor(COLOR_TEXT)
								bcolor(COLOR_BG)
								cpos(1,3)
								print("Informations:")
								print(text[selected[1]][selected[2]][i])
								print("")
								print("Safety/Data:")
								print(safety[selected[1]][selected[2]][i])
								print("")
								write("Download: ")
								if (link[selected[1]][selected[2]][i]=="") then
									tcolor(colors.red)
									print("Not avalible!")
								else
									tcolor(colors.lime)
									print(link[selected[1]][selected[2]][i])
								end

								cpos(21,17)
								if (link[selected[1]][selected[2]][i]=="") then
									tcolor(colors.gray)
									bcolor(colors.red)
								else
									tcolor(colors.gray)
									bcolor(colors.lime)
								end
								write("DOWNLOAD")

								local a = true
								while a do
									local event, btn, x, y = os.pullEventRaw()
									if (event=="mouse_click" and btn==1) then
										if (y==1 and x==51) then
											--Close
											a = false
										elseif (y==17 and x>=21 and x<=29) then
											--Download
											if (link[selected[1]][selected[2]][i]~="") then
												a = false
												FUNC_downloadPart(link[selected[1]][selected[2]][i])
											end
										end
									end
								end

								break
							end
						end
						draw()
					end
				end
			end
		end
	end
end


while (installer_running) do
	installer_run()
end


return true
end





if (os.loadAPI("SJNOS/.install/sjn")) then
	sjn.program(start)

	if install_result then
		fs.delete(INSTALLATION_PATH)
		os.reboot()
	end

	os.unloadAPI("SJNOS/.install/sjn")
else
	error('Bummer. We could not install SJNOS because of a invalid API.')
end
