--QuarzDiamonsPROGRAM for myTurtleOS by MC403 (vz10Xn1s)

tArgs = {...}

if #tArgs == 2 then
	bedrock = tArgs[1]
	bedrock = bedrock - 2
	
	host = tArgs[2]
	host = host + 0
	
	os.loadAPI("m")

	m.refuel()
	
	turtle.select(1)

	score = 0

	m.setText("Quartz & Diamonds: "..score)
	
	rednet.send(host,"Starting")

	local c = 1
	for i=1,bedrock do
		m.digDown()
		m.down()
		c = c + 1
		
		for i=1,4 do
			m.turnRight()
			for j=1,16 do
				turtle.select(j)
				if turtle.compare() then
					m.dig()
					score = score + 1
					m.setText("Quarz & Diamonds: "..score)
					rednet.send(host,"Found something!")
				end
			end
		end
		
	end
	rednet.send(host,"Half-Done with "..score)
	
	for i=1,3 do
		m.dig()
		m.forward()
	end
	
	for t=1,c-1 do
		m.digUp()
		m.up()
		
		for i=1,4 do
			m.turnRight()
			for j=1,16 do
				turtle.select(j)
				if turtle.compare() then
					m.dig()
					score = score + 1
					m.setText("Quarz & Diamonds: "..score)
					rednet.send(host,"Found something!")
				end
			end
		end
	end
	rednet.send(host,"Going home!")
	m.gohome()
	
	rednet.send(host,"Finished with "..score)
end

