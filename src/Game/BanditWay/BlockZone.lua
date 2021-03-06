---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bergi.
--- DateTime: 23.01.2022 21:40
---
function BlockZone(thisRect)
    DisableTrigger(GetTriggeringTrigger())
    local range = 0
    local rangeY = 300
    --thisRect=nil
    --print(GetUnitName(GetTriggerUnit()), " вошел")
    local x, y = GetRectCenterX(thisRect), GetRectCenterY(thisRect)
    if not thisRect then
        x, y = GetUnitXY(GetTriggerUnit())
    end
    SetRect(GlobalRect, x - range, y - range, x + range, y + rangeY)
    SetCameraBoundsToRect(GlobalRect)
    BlockCameraDestructable=CreateBlockBox(x, y)
    --CreateChainOnScreen(x, y)
    StartBattle(thisRect)
end

function CreateBlockBox(x, y)
    local block = {}
    local xs, ys = x - 800, y + 800
    local angle = 270
    --лево
    for i = 1, 20 do
        angle = angle + 1
        local nx, ny = MoveXY(xs, ys, 128 * i, angle)
        local b = CreateDestructable(FourCC("B001 "), nx, ny, 0, 1, 1)
        table.insert(block, b)
    end
    xs, ys = x + 800, y + 800
    angle = 270
    for i = 1, 20 do
        angle = angle - 1
        local nx, ny = MoveXY(xs, ys, 128 * i, angle)
        local b = CreateDestructable(FourCC("B001 "), nx, ny, 0, 1, 1)
        table.insert(block, b)
    end
    xs, ys = x-800 , y -450
    angle = 0
    for i = 1, 20 do
        --angle = angle - 1
        local nx, ny = MoveXY(xs, ys, 128 * i, angle)
        local b = CreateDestructable(FourCC("B001 "), nx, ny, 0, 1, 1)
        table.insert(block, b)
    end

    return (block)
end

function InitChainFrame()

    AllChain = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), '', 0)
    --ChainUp = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', AllChain, '', 0)
    BlzFrameSetAbsPoint(ChainUp, FRAMEPOINT_CENTER, 0.4, 0.3)
    BlzFrameSetParent(AllChain, BlzGetFrameByName("ConsoleUIBackdrop", 0))
    local chainTable = {}
    --низ
    for i = 1, 8 do
        local chain = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', AllChain, '', 0)
        BlzFrameSetParent(chain, BlzGetFrameByName("ConsoleUIBackdrop", 0))
        BlzFrameSetTexture(chain, "ChainElement", 0, true)
        BlzFrameSetSize(chain, GNext * 4, GNext * 4)
        BlzFrameSetAbsPoint(chain, FRAMEPOINT_CENTER, -0.09 + (i - 1) * GNext * 4, GNext / 4)
        table.insert(chainTable, chain)
    end
    --верх
    for i = 1, 8 do
        local chain = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', AllChain, '', 0)
        BlzFrameSetParent(chain, BlzGetFrameByName("ConsoleUIBackdrop", 0))
        BlzFrameSetTexture(chain, "ChainElement", 0, true)
        BlzFrameSetSize(chain, GNext * 4, GNext * 4)
        BlzFrameSetAbsPoint(chain, FRAMEPOINT_CENTER, -0.09 + (i - 1) * GNext * 4, 0.54)
        table.insert(chainTable, chain)
        local ty = 0.3
        TimerStart(CreateTimer(), 1, true, function()
            BlzFrameSetAbsPoint(ChainUp, FRAMEPOINT_CENTER, 0.4, ty)
            ty = ty + 0.02
        end)
    end
    --лево
    for i = 1, 7 do
        local chain = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', AllChain, '', 0)
        BlzFrameSetParent(chain, BlzGetFrameByName("ConsoleUIBackdrop", 0))
        BlzFrameSetTexture(chain, "ChainElementV", 0, true)
        BlzFrameSetSize(chain, GNext * 4, GNext * 4)
        BlzFrameSetAbsPoint(chain, FRAMEPOINT_CENTER, -0.13, 0.47 - (i - 1) * GNext * 4)
        table.insert(chainTable, chain)
    end
    --право
    for i = 1, 7 do
        local chain = BlzCreateFrameByType('BACKDROP', 'FaceButtonIcon', AllChain, '', 0)
        BlzFrameSetParent(chain, BlzGetFrameByName("ConsoleUIBackdrop", 0))
        BlzFrameSetTexture(chain, "ChainElementV", 0, true)
        BlzFrameSetSize(chain, GNext * 4, GNext * 4)
        BlzFrameSetAbsPoint(chain, FRAMEPOINT_CENTER, 0.92, 0.47 - (i - 1) * GNext * 4)
        table.insert(chainTable, chain)
    end
    BlzFrameSetVisible(AllChain, false)
end

function CreateChainOnScreen(x, y)
    normal_sound("Sound\\Interface\\LeftGlueScreenPopDown", x, y)
    --LeftGlueScreenPopUp
    BlzFrameSetVisible(AllChain, true)
end