--Easymine for myTurtleOS by MC403

const_width = nil
const_height = nil
const_length = nil

if fs.exists("mine") then
	fs.delete("mine")
end

shell.run("pastebin","get","G196Ysnr","mine")
os.loadAPI("mine")

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

clear()

print("EASYMINE for MYTURTLEOS by MC403")
print("-Easymine is ONLY for turtles!")
print("-Put a chest on the left of the turtle!")
print("-Fuel the Turtle before using it!")

textutils.slowWrite("Width:  ",50)
const_width = tonumber(read())

textutils.slowWrite("Length: ",50)
const_length = tonumber(read())

textutils.slowWrite("Height: ",50)
const_height = tonumber(read())

clear()

if const_width==nil or const_height==nil or const_length==nil then
	print("Please enter a number for these Parameters!")
end

mine.drawTitle()
mine.forward()

for y=1,const_height do
	mine.drawTitle()	
	for z=1, const_width do
		for x=1, const_length-1 do
			mine.dig()
			mine.forward()
		end
		if z%2 == 1then
			mine.turnRight()
			mine.dig()
			mine.forward()
			mine.turnRight()
		else
			mine.turnLeft()
			mine.dig()
			mine.forward()
			mine.turnLeft()
		end
	end
	
	mine.gohomeX()
	mine.gohomeZ()
	mine.gohomeDir()
	
	if not y == const_height then
		mine.digDown()
		mine.down()
	else
		print("FINISHED!")
	end
end

mine.gohome()



