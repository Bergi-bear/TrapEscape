---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bergi.
--- DateTime: 11.12.2021 17:41
---
function EarthStrike(data, angle, x, y)
    local effModel = "Doodads\\LordaeronSummer\\Rocks\\Lords_Rock\\Lords_Rock4"
    local block = CreateDestructable(FourCC("YTpc"), x, y, angle, 1, 1) --YTfb малый
    local nx, ny = GetDestructableX(block), GetDestructableY(block)
    local eff = CreateEffectFromDeep(data, effModel, -200, nx, ny)
    BlzSetSpecialEffectYaw(eff, math.rad(angle))
    --print(GetHandleId(eff))
    PathBlock[GetHandleId(eff)]=block
    DelayRemoveEarthStrike(eff, 5)
    table.insert(AllRocks,eff)
end

PathBlock={}
function CreateEffectFromDeep(data, effModel, deep, x, y)
    local eff = AddSpecialEffect(effModel, x, y)
    BlzSetSpecialEffectZ(eff, deep)
    TimerStart(CreateTimer(), TIMER_PERIOD64, true, function()
        deep = deep + 15
        BlzSetSpecialEffectZ(eff, deep)
        if deep > GetTerrainZ(x, y) then
            DestroyTimer(GetExpiredTimer())
            DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", x, y))
            UnitDamageArea(data.UnitHero, 10, x, y, 100)
        end
    end)
    return eff
end
AllRocks={}
function DelayRemoveEarthStrike(eff, delay)
    local block=PathBlock[GetHandleId(eff)]
    local x,y= BlzGetLocalSpecialEffectX(eff), BlzGetLocalSpecialEffectY(eff)
    local period=TIMER_PERIOD
    TimerStart(CreateTimer(), period, true, function()
        delay = delay - period
        if delay <= 0 then
            DestroyTimer(GetExpiredTimer())
            RemoveDestructable(block)
            DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl",x,y))
            local deep=BlzGetLocalSpecialEffectZ(eff)
            DestroyEffect(eff)
            TimerStart(CreateTimer(), TIMER_PERIOD64, true, function()
                deep = deep - 10
                BlzSetSpecialEffectZ(eff, deep)
                --print("погружение")
                if deep<=-300 then
                    --print("погрузился")
                    DestroyTimer(GetExpiredTimer())
                end
            end)
        end
    end)
end