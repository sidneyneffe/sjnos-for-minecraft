--SJNOS by MC403. dev_installer.exe (wfj0Htpa)

term.setCursorPos(1,1)
term.setBackgroundColor(colors.gray)
term.setTextColor(colors.orange)
term.clear()

print("SJNOS DEV-Installer. Please reboot before using!\n\n")
print("NORMAL = ENTER\nREALFAST = BACKSPACE\nEXIT = CTRL-T (5sec)\n\n")
print("Normal AND Realfast will delete SJNOS!")

local realfast = false

while true do
	local event, btn = os.pullEvent()
	if (btn == 14) then
		realfast = true
		break
	elseif (btn == 28) then
		break
	end
end


fs.delete("SJNOS")


function import(path,code)
	shell.run("pastebin","get",code,path)
end
function makeDir(path)
	fs.makeDir(path)
end
function makeFile(path, content)
	h = fs.open(path,"w")
	for i=1, #content do
		h.writeLine(content[i])
	end
	h.close()
end

makeDir("SJNOS")
makeDir("SJNOS/system")
	makeDir("SJNOS/system/about")
		makeFile("SJNOS/system/about/ver.txt",{"ver=1.4.3","status=Alpha"})
		makeFile("SJNOS/system/about/changelog.txt",{"-Better Graphics","-New SJNOS Core","-New SJNOS System","-More Programs","-Games","-Part-Installer","-MUCH MORE!!!"})
		makeFile("SJNOS/system/about/SJN.txt",{"SJN","SJN is awesome!!!"})
	makeDir("SJNOS/system/boot")
		import("SJNOS/system/boot/setup.sys","--------")
	makeDir("SJNOS/system/SJNOS")
		import("SJNOS/system/SJNOS/desktop.sys","qK1cVg8R")
		import("SJNOS/system/SJNOS/login.sys","ztDHMfrm")
		import("SJNOS/system/SJNOS/logout.sys","--------")
		import("SJNOS/system/SJNOS/games.sys","--------")
		import("SJNOS/system/SJNOS/programs.sys","--------")
		import("SJNOS/system/SJNOS/plugins.sys","--------")
		import("SJNOS/system/SJNOS/settings.sys","--------")
		import("SJNOS/system/SJNOS/network.sys","vpwucSht")
		import("SJNOS/system/SJNOS/help.sys","--------")
		import("SJNOS/system/SJNOS/deinstall.sys","i8DykZUj")
		import("SJNOS/system/SJNOS/applications.sys","gNEADRX9")
		import("SJNOS/system/SJNOS/rednet.sys","pQbhxiMi")
		import("SJNOS/system/SJNOS/peripherals.sys","46bGWX3t")
		import("SJNOS/system/SJNOS/sjn","Ab5cy6F2")
makeDir("SJNOS/net")
	makeDir("SJNOS/net/web")
		import("SJNOS/net/web/sweb","Bex5SsgL")
makeDir("SJNOS/data")
	makeDir("SJNOS/data/icons")
		makeFile("SJNOS/data/icons/sjn.img",{"9999 9999 9  9 1111 1111","9       9 99 9 1  1 1   ","9999    9 9 99 1  1 1111","   9    9 9  9 1  1    1","9999 9999 9  9 1111 1111"})
		makeDir("SJNOS/data/icons/desktop")
			makeFile("SJNOS/data/icons/desktop/desktop.img",{"00000000","ffffffff","f999999f","f999999f","ffffffff","000ff000","0ffffff0"})
			makeFile("SJNOS/data/icons/desktop/apps.img",{"77777777","77999177","79777917","79777917","79999917","79777917","77777777"})
			makeFile("SJNOS/data/icons/desktop/files.img",{"88888888","87777778","88888888","87777778","88888888","87777778","88888888"})
			makeFile("SJNOS/data/icons/desktop/plugins.img",{"44444444","44444444","4ff44f44","ff44efff","4ff44f44","44444444","44444444"})
			makeFile("SJNOS/data/icons/desktop/settings.img",{"aaaaaaaa","aaa0aaaa","aa000aaa","a00a00aa","aa000aaa","aaa0aaaa","aaaaaaaa"})
			makeFile("SJNOS/data/icons/desktop/peripheral.img",{"ffffffff","f777777f","f788888f","f777777f","f777777f","f7775e7f","ffffffff"})
			makeFile("SJNOS/data/icons/desktop/network.img",{"88888888","88788788","87888878","87877878","87888878","88788788","88888888"})
			makeFile("SJNOS/data/icons/desktop/help.img",{"11111111","11777111","17111711","11111711","11177111","11111111","11171111"})
		makeDir("SJNOS/data/icons/users")
			makeFile("SJNOS/data/icons/users/img.cfg",{"files=9","cc.img=ComputerCraft","football.img=Football","flower.img=Flower","tree.img=Tree","book.img=Book","money.img=Money","cactus.img=Cactus","spider.img=Spider","boat.img=Boat"})
			makeFile("SJNOS/data/icons/users/cc.img",{"fffffffffffff","f77777777777f","f7f0fffffff7f","f7ff0ff00ff8f","f8f0fffffff8f","f88888888888f","f888888885e8f","fffffffffffff"})
			makeFile("SJNOS/data/icons/users/football.img",{"   7777777","  70ffff007"," 70000000007"," 700000fff07"," 7fff00fff07"," 7fff0000007","  7ff00fff7","   7777777"})
			makeFile("SJNOS/data/icons/users/flower.img",{"4443333333333","4443344433333","3333411143333","3333344433333","3333535353333","3333355533333","3333335333333","ddddddddddddd"})
			makeFile("SJNOS/data/icons/users/tree.img",{"3333333333444","3333555553444","3333555553333","3333555553555","555333c333555","555333c3333d3","3c3333c3333c3","ddddddddddddd"})
			makeFile("SJNOS/data/icons/users/book.img",{"ccccccccccccc","cccfffffffccc","cccf33433fccc","cccf34143fccc","cccf33533fccc","cccfdddddfccc","cccfffffffccc","ccccccccccccc"})
			makeFile("SJNOS/data/icons/users/money.img",{"","    11111","   1474471","  147747471","  174747471","   1474471","    11111",""})
			makeFile("SJNOS/data/icons/users/cactus.img",{"4433333333333","443ddd3333333","333d8d3ddd333","333ddd3ddd333","333ddddd8d333","33333d8ddd333","33333ddd33333","4444444444444"})
			makeFile("SJNOS/data/icons/users/spider.img",{"ccccccccccccc","ccfccfffccfcc","cffcfffffcffc","ffcfffffffcff","fccfefffefccf","fcccfffffcccf","ccccccccccccc","ccccccccccccc"})
			makeFile("SJNOS/data/icons/users/boat.img",{"3333000033444","3330000003444","3300000000333","333333c333333","3888888888883","bb888888888bb","bbbb88888bbbb","bbbbbbbbbbbbb"})
		makeDir("SJNOS/data/icons/system")
			makeFile("SJNOS/data/icons/system/boot.img",{"  11111111"," 999999991","0000000091","000000009","00000000"})
	makeDir("SJNOS/data/programs")
		import("SJNOS/data/programs/terminal.exe","GdZsddz6")
		import("SJNOS/data/programs/filemgr.exe","3FEeWeG8")
		import("SJNOS/data/programs/stext.exe","--------")
		import("SJNOS/data/programs/spaint.exe","--------")
		import("SJNOS/data/programs/sedit.exe","--------")
		import("SJNOS/data/programs/taskmgr.exe","--------")
	makeDir("SJNOS/data/games")
		import("SJNOS/data/games/jumper.exe")
makeDir("SJNOS/settings")
	makeFile("SJNOS/settings/settings.set",{"/|/|/|/|"})

makeDir("SJNOS/users")
makeDir("SJNOS/plugins")
makeDir("SJNOS/help")
	import("SJNOS/help/help.exe","--------")
import("SJNOS/start.exe","XBSAvvxB")
makeFile("SJNOS/firstrun",{"true"})

term.setCursorPos(1,1)
term.setBackgroundColor(colors.gray)
term.setTextColor(colors.orange)
term.clear()

local pcname = "DEV_PC"
if (not realfast) then
	write("PC_NAME: ")
	pcname = read()
end
f = fs.open("SJNOS/settings/name.set","w")
f.writeLine("pcname="..pcname)
f.close()
os.setComputerLabel(pcname)

local dns = 0
if (not realfast) then
	write("DNS: ")
	dns = read()
end
local f = fs.open("SJNOS/settings/net.set","w")
f.writeLine("dns="..dns)
f.close()

local username = "Developer"
local password = "a"..math.random(50)
if (not realfast) then
	write("Username: ")
	username = read()
	write("Password: ")
	password = read("*")
end
local f = fs.open("SJNOS/settings/net.set","w")
f.writeLine("dns="..dns)
f.close()

local function makeLocDir(path)
	makeDir("SJNOS/users/"..username.."/"..path)
end
local function makeLocFile(path,content)
	local h = fs.open("SJNOS/users/"..username.."/"..path, "w")
	for i=1, #content do
		h.writeLine(content[i])
	end
	h.close()
end

makeLocDir("")
makeLocDir("config")
makeLocDir("home")
makeLocFile("config/.config", {"d1="..username, "d2="..password, "d3=SJNOS/data/icons/users/cc.img", "d4=a"})
makeLocDir("home/apps")
makeLocDir("home/apps/appdata")
makeLocDir("home/files")
makeLocDir("home/programs")


term.setCursorPos(1,1)
term.setBackgroundColor(colors.gray)
term.setTextColor(colors.orange)
term.clear()

if (realfast) then
	print("Your password is: "..password..".\n")
end

print("RUN = ENTER\nEXIT = BACKSPACE")

while true do
	local event, btn = os.pullEvent()
	if (btn == 28) then
		shell.run("SJNOS/start.exe")
		break
	elseif (btn == 14) then
		break
	end
end