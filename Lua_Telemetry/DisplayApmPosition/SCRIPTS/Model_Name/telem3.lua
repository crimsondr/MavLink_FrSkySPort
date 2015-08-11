--
--  Copyright (c) Scott Simpson
--
-- 	This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  A copy of the GNU General Public License is available at <http://www.gnu.org/licenses/>.

---------------------------------------------------------------------------------------------------      

local FlightMode = {
            "Stabilize",
            "Acro",
            "Altitude Hold",
            "Auto",
            "Guided",
            "Loiter",
            "Return to launch",
            "Circle",
            "Invalid Mode",
            "Land",
            "Optical Loiter",
            "Drift",
            "Invalid Mode",
            "Sport",
            "Flip Mode",
            "Auto Tune",
            "Position Hold"}
local AsciiMap = {
            "A",
            "B",
            "C",
            "D",
            "E",
            "F",
            "G",
            "H",
            "I",
            "J",
            "K",
            "L",
            "M",
            "N",
            "O",
            "P",
            "Q",
            "R",
            "S",
            "T",
            "U",
            "V",
            "W",
            "X",
            "Y",
            "Z"}

local MESSAGEBUFFERSIZE = 5
local messageArray = {}
local messageFirst = 0
local messageNext = 0
local messageLatestTimestamp = 0
local messageBuffer = ""
local messageBufferSize = 0
local previousMessageWord = 0
local footerMessage = ""
local messagePriority = -1

local function char(c) 
    if c >= 48 and c <= 57 then
      return "0" + (c - 48)
    elseif c >= 65 and c <= 90 then
      return AsciiMap[c - 64]
    elseif c >= 97 and c <= 122 then 
      return AsciiMap[c - 96]    
    elseif c == 32 then
      return " "
    elseif c == 46 then
      return "."
    else
      return ""
    end
end

local function getLatestMessage()
    if messageFirst == messageNext then
        return ""
    end
    return messageArray[((messageNext - 1) % MESSAGEBUFFERSIZE) + 1]
end

local function checkForNewMessage()
    local msg = getTextMessage()
    if msg ~= "" then
        if msg ~= getLatestMessage() then
            messageArray[(messageNext % MESSAGEBUFFERSIZE) + 1] = msg
            messageNext = messageNext + 1
            if (messageNext - messageFirst) >= MESSAGEBUFFERSIZE then
                messageFirst = messageNext - MESSAGEBUFFERSIZE
            end
            messageLatestTimestamp = getTime()
        end
    end
end

function getTextMessage()
    local returnValue = ""
    local messageWord = getValue("rpm")

    if messageWord ~= previousMessageWord then
        local highByte = bit32.rshift(messageWord, 7)
        highByte = bit32.band(highByte, 127)
        local lowByte = bit32.band(messageWord, 127)

        if highByte ~= 0 then
            if highByte >= 48 and highByte <= 57 and messageBuffer == "" then
                messagePriority = highByte - 48
            else
              messageBuffer = messageBuffer .. char(highByte)
              messageBufferSize = messageBufferSize + 1
            end
            if lowByte ~= 0 then
                messageBuffer = messageBuffer .. char(lowByte)
                messageBufferSize = messageBufferSize + 1
            end
        end
        if highByte == 0 or lowByte == 0 then
          returnValue = messageBuffer
          messageBuffer = ""
          messageBufferSize = 0
        end
        previousMessageWord = messageWord        
    end
    return returnValue
end

local function drawTopPanel()
    local apmarmed = getValue(210)%0x02

    lcd.drawFilledRectangle(0, 0, 212, 9, 0)
  
    local flightModeNumber = getValue("fuel") + 1
    if flightModeNumber < 1 or flightModeNumber > 17 then
        flightModeNumber = 13
    end

      if apmarmed==1 then
        lcd.drawText(1, 0, (FlightMode[flightModeNumber]), INVERS)
      else
        lcd.drawText(1, 0, (FlightMode[flightModeNumber]), INVERS+BLINK)
      end

    lcd.drawTimer(lcd.getLastPos() + 10, 0, model.getTimer(0).value, INVERS)

    lcd.drawText(134, 0, "TX:", INVERS)
    lcd.drawNumber(160, 0, getValue(189)*10,0+PREC1+INVERS)
    lcd.drawText(lcd.getLastPos(), 0, "v", INVERS)
      
    lcd.drawText(172, 0, "rssi:", INVERS)
    lcd.drawNumber(lcd.getLastPos()+10, 0, getValue(200),0+INVERS)   
end

local function drawBottomPanel()
    local footerMessage = getTextMessage()
    lcd.drawFilledRectangle(0, 54, 212, 63, 0)
    lcd.drawText(2, 55, footerMessage, INVERS)
end
    
local function background() 
    checkForNewMessage()
end

local function run(event)
    background()
   
    lcd.clear()
    drawTopPanel()
    local i
    local row = 1
    for i = messageFirst, messageNext - 1, 1 do
--            lcd.drawText(1, row * 10 + 2, "abc " .. i .. " " .. messageFirst .. " " .. messageNext, 0)
        lcd.drawText(1, row * 10 + 2, messageArray[(i % MESSAGEBUFFERSIZE) + 1], 0)
        row = row + 1
    end
end

return {run=run, background=background}