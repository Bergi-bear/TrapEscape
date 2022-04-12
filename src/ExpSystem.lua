---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bergi.
--- DateTime: 02.01.2022 19:14
---
ExpTable = {
    0,
    230,
    600,
    1080,
    1660,
    2260,
    2980,
    3730,
    4510,
    5320,
    6160,
    7030,
    7930,
    9155,
    10405,
    11680,
    12980,
    14305,
    15805,
    17395,
    18995,
    20845,
    22945,
    25295,
    27895,
    31395,
    35895,
    41395,
    47895,
    55395,
}
function InitExpSystem(data)
    if not data.curExp then
        data.curExp = 0
    end
    if not data.curHeroLvl then
        data.curHeroLvl = 1
    end
    CreateLevelInfo(data)
end

function AddExp(data, exp)
    FlyTextTagManaBurn(data.UnitHero, "+ " .. R2I(exp) .. " exp", Player(data.pid))
    data.curExp = data.curExp + exp
    if data.curExp >= ExpTable[data.curHeroLvl + 1] then
        --print("повышение уровня")
        --SuspendHeroXP(data.UnitHero, false)
        data.curHeroLvl = data.curHeroLvl + 1
        SetHeroLevel(data.UnitHero, data.curHeroLvl, true)
        BlzFrameSetText(data.FHHeroLvl,"Level "..data.curHeroLvl)
        --SuspendHeroXP(data.UnitHero, true)
    end
end

function CreateLevelInfo(data)
    local ico = "UI\\Widgets\\Console\\Human\\CommandButton\\human-button-lvls-overlay"
    local frame = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), '', 0)
    BlzFrameSetParent(frame, BlzGetFrameByName("ConsoleUIBackdrop", 0))
    BlzFrameSetTexture(frame, ico, 0, true)
    BlzFrameSetSize(frame, GNext *1.8, GNext / 2)
    BlzFrameSetAbsPoint(frame, FRAMEPOINT_CENTER, -0.107, 0.545)
    local text = BlzCreateFrameByType("TEXT", "ButtonChargesText", frame, "", 0)
    BlzFrameSetPoint(text, FRAMEPOINT_CENTER, frame, FRAMEPOINT_CENTER, 0.0, 0.0)
    BlzFrameSetText(text, "Noope")
    BlzFrameSetParent(text, BlzGetFrameByName("ConsoleUIBackdrop", 0))
    data.FHHeroLvl=text
    BlzFrameSetVisible(frame, GetLocalPlayer() == Player(data.pid))
end