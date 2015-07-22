local inputs = { {"O-SET mAh% ", VALUE,-100,100,0}, {"O-SET Wh%", VALUE, -100, 100, 0}, {"BatCap Wh", VALUE, 0, 250, 30}, {"ModelTim Hr", VALUE, 0, 250, 0} }

local oldoffsetmah=0
local oldoffsetwatth=0
local oldbatcapa=0
local oldmodeltime=0

local function run_func(offsetmah, offsetwatth, batcapa, modeltime)
  if oldoffsetmah ~= offsetmah or oldoffsetwatth ~= offsetwatth or oldbatcapa~=batcapa then
    model.setGlobalVariable(8, 0, offsetmah) --mA/h
    model.setGlobalVariable(8, 1, offsetwatth) --Wh
    model.setGlobalVariable(8, 2, batcapa) --Wh
    oldoffsetmah = offsetmah
    oldoffsetwatth = offsetwatth
    oldbatcapa = batcapa
    
  end
  if oldmodeltime~=modeltime then
    --model.setTimer(1,{ mode=0, start=0,value= modeltime*3600, countdownBeep=0, minuteBeep=0, persistent=2 })
    oldmodeltime = modeltime
  end
  
  return model.getTimer(1).value / 360

end

return {run=run_func, input=inputs , output={ "MTimer"}}
