

if myHero.charName ~= "Lissandra" then return end 

require "SxOrbWalk"
require "VPrediction"
local qRange, qSpeed, qDelay = 725, 2.3, .25
local wRange = 450
local eRange, eSpeed, eDelay = 1050, .85, .25
local rRange, rRadius = 550, 575
local aaRange = 550
local ignite, iDMG = nil, 0
local QREADY, WREADY, EREADY, RREADY = false 
local passive = false

function OnLoad() 
 PrintChat("Rancid Lissandra Loaded!, 1.0")
 LMenu()
 IgniteCheck()
 VP = VPrediction()
 end 
 
function OnTick()

  HarrasK = Config.Harrasettings.KHarras
  HarrasT = Config.Harrasettings.THarras
	PasiveHarras = Config.Harrasettings.PasiveQ
	KCombo = Config.ComboM.ComboK
	
 Check()
  
	if Config.Misc.iKS and ValidTarget(target) then
	  AutoIgnite(target)
	end
	
	if KCombo then
	CastW(target)
	CastE(target)
	CastQ(target)
	CastR(target)
	
	end
	
	if HarrasK then
  CastQ(target)
	end
	
	
	if HarrasT then
   CastQ(target)
	end
	
	
	
end



function Check()
 ts:update() 
 target = ts.target 
 SxOrb:ForceTarget(target)
 QREADY = (myHero:CanUseSpell(_Q) == READY)
 WREADY = (myHero:CanUseSpell(_W) == READY)
 EREADY = (myHero:CanUseSpell(_E) == READY)
 RREADY = (myHero:CanUseSpell(_R) == READY)
 IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

function LMenu()
Config = scriptConfig("Rancid Lissandra", "Lissandra")

Config:addSubMenu("Combo Settings", "ComboM")
 Config.ComboM:addParam("ComboK","Combo Key",SCRIPT_PARAM_ONKEYDOWN, false, 32)

Config:addSubMenu("Harras Settings", "Harrasettings")
 Config.Harrasettings:addParam("KHarras", "Harras  Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
  Config.Harrasettings:addParam("THarras", "Harras  Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
 Config.Harrasettings:addParam("PasiveQ", "Use Pasive to Harras",SCRIPT_PARAM_ONOFF, true)
 
Config:addSubMenu("Misc", "Misc")
 Config.Misc:addParam("iKS", "Auto KS using ignite", SCRIPT_PARAM_ONOFF, true)
 Config.Misc:addParam("DoIg", "Avoid double ignite", SCRIPT_PARAM_ONOFF, true)
 Config.Misc:addParam("KSQ", "Auto KS using Q Spell", SCRIPT_PARAM_ONOFF, true)


ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 700)
ts.name = "Focus"

Config:addSubMenu("Target Selector", "TS")
 Config.TS:addTS(ts)

Config:addSubMenu("Orbwalker", "SxOrb")
 SxOrb:LoadToMenu(Config.SxOrb) 
end





function AutoIgnite(enemy)
 iDmg = ((IREADY and getDmg("IGNITE", enemy, myHero)) or 0)
 if enemy.health <= iDmg and GetDistance(enemy) <= 600 and ignite ~= nil then 
  if IREADY then
   if Config.Misc.DoIg and not TargetHaveBuff("SummonerDot", target) then
    CastSpell(ignite, enemy)
   elseif not Config.DoubleIgnite then
   CastSpell(ignite, enemy)
  end
 end
end
end

function IgniteCheck()
if myHero:GetSpellData(SUMMONER_1).name:find("summonerdot") then
ignite = SUMMONER_1 
elseif myHero:GetSpellData(SUMMONER_2).name:find("summonerdot") then 
ignite = SUMMONER_2 
end
end


function CastQ(target)
 if target ~= nil and GetDistance(target) <= qRange then
  TQPredic = getPred(qSpeed, qDelay, target)
  CastSpell(_Q, TQPredic.x, TQPredic.z)
 end
end

function CastW(target)
 if target ~= nil and GetDistance(target) <= wRange then
  CastSpell(_W)
 end
end

function CastE(target)
if target ~= nil and GetDistance(target) <= eRange then
  TEPredic = getPred(eSpeed, eDelay, target)
  CastSpell(_E, TEPredic.x, TEPredic.z)
 end
end

function CastR(target)

 if target ~= nil and GetDistance(target) <= rRange then
   CastSpell(_R, target)
 end
 
end

function getPred(speed, delay, target)
        if target == nil then return nil end
        local travelDuration = (delay + GetDistance(myHero, target)/speed)
        travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
        travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)
        travelDuration = (delay + GetDistance(GetPredictionPos(target, travelDuration))/speed)  
        return GetPredictionPos(target, travelDuration)
end

function OnApplyBuff(unit, source, buff)
if unit.isMe and buff and buff.name == "lissandrapassiveready" then
CastQ(target)
end
end