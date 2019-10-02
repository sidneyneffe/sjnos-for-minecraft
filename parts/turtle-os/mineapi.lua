--SJN MINE API for MYTURTLEOS by MC403 (vy8e1EJs)

local xpos = 0
local ypos = 200
local zpos = 0
local dir = 0

local status_text = "> Waiting"
local status = -1

local bedrock = false

local autoFuelOn = true
local autoFuelLevel = 10
local autoFuelNewFuel = 2

draw = true

local text = ""

local home_x = 0
local home_y = 200
local home_z = 0

local function clear()
	term.clear()
	term.setCursorPos(1,1)
end

function drawTitle()
	if autoFuelOn then
		autofuel()
	end
	
	if draw then
		clear()
		print("SJN MINE API")
		print("X:        "..xpos)
		print("Y:        "..ypos)
		print("Z:        "..zpos)
		print("          ")
		print("DIR:      "..dir)
		print("FUEL:     "..turtle.getFuelLevel())
		write("AUTOFUEL: ")
			if autoFuelOn then
				print("true")
			else
				print("false")
			end
		print("          ")
		print("Status:   "..status_text)
		print("Text:     "..text)
	end
end
function setText(aText)
	text = aText
	drawTitle()
end
function setFuel(active,warning,fuelPerRefuel)
	autoFuelOn = active
	autoFuelLevel = warning
	autoFuelNewFuel = fuelPerRefuel
end

function getX()
	return xpos
end
function getY()
	return ypos
end
function getZ()
	return zpos
end
function getDir()
	return dir
end
function getStatus()
	return status
end
function getHomes()
	return home_x, home_y, home_z
end
function getBedrock()
	return bedrock
end

function turnLeft(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.turnLeft() then
			if dir == 0 then
				dir = 3
			else
				dir = dir - 1
			end
		else
			i = i-1
		end
		drawTitle()
	end
end
function turnRight(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.turnRight() then
			if dir == 3 then
				dir = 0
			else
				dir = dir + 1
			end
		else
			i = i-1
		end
		drawTitle()
	end
end

function dig()
	while turtle.detect() do
		turtle.dig()
		sleep(0.2)
	end
end
function digUp()
	while turtle.detectUp() do
		turtle.digUp()
		sleep(0.2)
	end
end
function digDown()
	bedrock = false
	while turtle.detectDown() do
		if not turtle.digDown() then
			bedrock = true
			return
		end
	end
end

function up(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.up() then
			ypos = ypos + 1
		else
			up()
		end
		drawTitle()
	end
end
function down(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.down() then
			ypos = ypos - 1
		else
			down()
		end
		drawTitle()
	end
end
function forward(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.forward() then
			if dir==0 then
				xpos = xpos + 1
			elseif dir==1 then
				zpos = zpos + 1
			elseif dir==2 then
				xpos = xpos - 1
			else
				zpos = zpos - 1
			end
		else
			forward()
		end
		drawTitle()
	end
end
function back(nr)
	if nr == nil then nr = 1 end
	for i=1,nr do
		if turtle.back() then
			if dir==0 then
				xpos = xpos - 1
			elseif dir==1 then
				zpos = zpos - 1
			elseif dir==2 then
				xpos = xpos + 1
			else
				zpos = zpos + 1
			end
		else
			back()
		end
		drawTitle()
	end
end

function left()
	if nr == nil then nr = 1 end
	turnLeft()
	forward(nr)
	turnRight()
end
function right(nr)
	if nr == nil then nr = 1 end
	turnRight()
	forward(nr)
	turnLeft()
end

function gohomeX()
	local atHomeX = false
	while not atHomeX do
		drawTitle()
		if home_x>xpos then
			if dir == 0 then
			elseif dir == 1 then
				turnLeft()
			elseif dir == 2 then
				turnRight(2)
			else
				turnRight()
			end
			dig()
			forward()
		elseif home_x<xpos then
			if dir == 0 then
				turnRight(2)
			elseif dir == 1 then
				turnRight()
			elseif dir == 2 then
			else
				turnLeft()
			end
			dig()
			forward()
		else
			atHomeX = true
		end
	end
end
function gohomeY()
	local atHomeY = false
	while not atHomeY do
		drawTitle()
		if home_y>ypos then
			digUp()
			up()
		elseif home_y<ypos then
			digDown()
			down()
		else
			atHomeY = true
		end
	end
end
function gohomeZ()
	local atHomeZ = false
	while not atHomeZ do
		drawTitle()
		if home_z>zpos then
			if dir == 0 then
				turnRight()
			elseif dir == 1 then
			elseif dir == 2 then
				turnLeft()
			else
				turnRight(2)
			end
			dig()
			forward()
		elseif home_z<zpos then
			if dir == 0 then
				turnLeft()
			elseif dir == 1 then
				turnRight(2)
			elseif dir == 2 then
				turnRight()
			else
			end
			dig()
			forward()
		else
			atHomeZ = true
		end
	end
end
function gohomeDir()
	if dir == 1 then
			turnLeft()
		elseif dir == 2 then
			turnLeft(2)
		elseif dir == 3 then
			turnRight()
		end
	end
function gohome()
	status_text = "Working > Going home"
	drawTitle()
	
	gohomeY()
	gohomeX()
	gohomeZ()
	gohomeDir()
	
	
	status_text = "Arrived at home > Waiting"
end
function sethome(x,y,z)
	home_x = x
	home_y = y
	home_z = z
end

function autofuel()
	if turtle.getFuelLevel() < autoFuelLevel then
		turtle.refuel(autoFuelNewFuel)
	end
end

function refuel()
	for i=1,16 do
		turtle.select(i)
		turtle.refuel(64)
	end
end
