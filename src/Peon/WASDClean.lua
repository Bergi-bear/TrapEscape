FREE_CAMERA = false
TIMER_PERIOD = 1 / 32
TIMER_PERIOD64 = 1 / 64
HERO = {}
HeroID = FourCC("O000")

function InitAnimations(hero, data)


    if GetUnitTypeId(data.UnitHero) == FourCC("Ogrh") then
        --print("инициализацию анимацию мастра клинка")
        data.AnimDurationWalk = 0.767 --длительность анимации движения, полный круг, смотрим в retera или редакторе WE
        data.IndexAnimationWalk = 5-- индекс анимации движения
        data.ResetDuration = 3.333 -- время сброса для анимации stand, длительность анимации stand
        data.IndexAnimationQ = 2 -- анимация сплеш удара
        data.IndexAnimationSpace = 2 -- анимация для рывка, если анимации нет, ставь индекс аналогичный бегу
        data.IndexAnimationAttackInDash = 3 --анимация удара в рывке
        data.IndexAnimationThrow = 3 -- индекс анимациии броска чего либо
        data.IndexAnimationAttack1 = 7 --индекс анимации атаки в серии
        data.IndexAnimationAttack2 = 7 --индекс анимации атаки в серии
        data.IndexAnimationAttack3 = 1 --индекс анимации  атаки в серии
        data.IndexAnimationSpin = 3 -- индекс анимации для удара во вращении
    elseif GetUnitTypeId(data.UnitHero) == KazumaID then
        print("else")
    else
        print("Данного героя нет в таблице анимаций")
    end
end

function InitWASD(hero)
    --print("initwasdSTART",GetUnitName(hero))
    local data = HERO[GetPlayerId(GetOwningPlayer(hero))]
    if not data.UnitHero then
        --print("пробуем ещё раз")
        data.UnitHero = hero
    end
    InitAnimations(hero, data)
    BlockMouse(data)
    SelectUnitForPlayerSingle(data.UnitHero, GetOwningPlayer(hero))
    EnableDragSelect(false, false)
    BlzEnableSelections(false, false)

    local angle = 0
    local speed = 5
    local animWalk = 0

    TimerStart(CreateTimer(), 0.005, true, function()
        -- устранение бага залипания
        if UnitAlive(hero) then
            if not IsUnitSelected(hero, GetOwningPlayer(hero)) then
                SelectUnitForPlayerSingle(hero, GetOwningPlayer(hero))
            end

            --ForceUIKeyBJ(GetOwningPlayer(hero), "Q")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "W")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "E")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "R")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "A")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "S")
            --ForceUIKeyBJ(GetOwningPlayer(hero), "D")
            -- ForceUIKeyBJ(GetOwningPlayer(hero), "F")
            ForceUIKeyBJ(GetOwningPlayer(hero), "Z")
            ForceUIKeyBJ(GetOwningPlayer(hero), "X")
            ForceUIKeyBJ(GetOwningPlayer(hero), "C")
            ForceUIKeyBJ(GetOwningPlayer(hero), "V")

            ForceUIKeyBJ(GetOwningPlayer(hero), "M")

        end
    end)
    data.preX = GetPlayerMouseX[data.pid]
    data.preY = GetPlayerMouseY[data.pid]
    if not GetPlayerMouseX[data.pid] then
        GetPlayerMouseX[data.pid] = 0
    end
    if not GetPlayerMouseY[data.pid] then
        GetPlayerMouseY[data.pid] = 0
    end

    local angleCast = AngleBetweenXY(GetUnitX(hero), GetUnitY(hero), GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid]) / bj_DEGTORAD
    local curAngle = angleCast
    local distance = DistanceBetweenXY(GetUnitX(hero), GetUnitY(hero), GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid])
    local cutDistance = distance

    TimerStart(CreateTimer(), TIMER_PERIOD64, true, function()
        -- основной таймер для обработки всего
        hero = data.UnitHero -- костыль для смены героя
        local hx, hy = GetUnitXY(hero)

        if data.preX ~= GetPlayerMouseX[data.pid] or data.preY ~= GetPlayerMouseY[data.pid] then
            --print("курсор движется "..GetPlayerMouseX[data.pid])
            data.MouseMove = true
        else
            data.MouseMove = false
            --print("на месте "..GetPlayerName(GetOwningPlayer(hero)))
        end
        data.preX = GetPlayerMouseX[data.pid]
        data.preY = GetPlayerMouseY[data.pid]
        -- Вот сюда надо интерполировать движение


        angleCast = AngleBetweenXY(hx, hy, GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid]) / bj_DEGTORAD
        curAngle = lerpTheta(curAngle, angleCast, TIMER_PERIOD64 * 8)
        distance = DistanceBetweenXY(hx, hy, GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid])
        cutDistance = math.lerp(cutDistance, distance, TIMER_PERIOD64 * 8)

        ----------------------------------------

        if not data.MouseMove then
            --print("юнит идёт со статичным курсором")

            data.fakeX, data.fakeY = MoveXY(hx, hy, data.DistMouse, data.AngleMouse)
            --InputUpdate(data, data.fakeX, data.fakeY)
        else
            data.DistMouse = DistanceBetweenXY(hx, hy, GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid])
            data.AngleMouse = AngleBetweenXY(hx, hy, GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid]) / bj_DEGTORAD
            --print("пошевелил " .. data.DistMouse)
        end

        if not UnitAlive(hero) then
            local x, y = GetUnitXY(hero)

            if not data.CameraStabUnit then
                --print("Эффект смерти")
                --and not data.CameraOnSaw
                data.CameraStabUnit = CreateUnit(Player(data.pid), FourCC("hdhw"), x, y, 0)
                ShowUnit(data.CameraStabUnit, false)

                --print("death")
                SetUnitAnimation(data.UnitHero, "death")

                TimerStart(CreateTimer(), 3, false, function()
                    DestroyTimer(GetExpiredTimer())
                    ReviveHero(hero, x, y, true)
                    SetUnitInvulnerable(hero, true)
                    TimerStart(CreateTimer(), 2, false, function()
                        SetUnitInvulnerable(hero, false)
                        DestroyTimer(GetExpiredTimer())
                    end)
                end)
            end

            SetCameraQuickPosition(GetUnitX(data.CameraStabUnit), GetUnitY(data.CameraStabUnit))
            SetCameraTargetControllerNoZForPlayer(GetOwningPlayer(data.CameraStabUnit), data.CameraStabUnit, 10, 10, true) -- не дергается


        else
            KillUnit(data.CameraStabUnit)
            data.CameraStabUnit = nil
            if not FREE_CAMERA then
                SetCameraQuickPosition(GetUnitX(hero), GetUnitY(hero))
                SetCameraTargetControllerNoZForPlayer(GetOwningPlayer(hero), hero, 10, 10, true) -- не дергается
                --print(GetCameraField(CAMERA_FIELD_ZOFFSET))
                local z = GetUnitZ(hero)

                SetCameraField(CAMERA_FIELD_ZOFFSET, z, 0.1)


            else
                --print("камера освобождена")
            end
        end
        if true then
            if data.PressSpin then
                data.ChargingAttack = data.ChargingAttack + TIMER_PERIOD64
                --print(data.ChargingAttack)
                if data.ChargingAttack >= data.StarTime2Spin and not data.isSpined then

                    data.isSpined = true
                    --print("start spin")
                    StartAndReleaseSpin(data)
                    if not data.tasks[2] then
                        data.tasks[2] = true
                        --print("Первый раз прокрутился")
                    end
                end
            else
                data.ChargingAttack = 0
                data.isSpined = false
            end
        end

        if data.ResetSeriesTime > 0 then
            data.ResetSeriesTime = data.ResetSeriesTime - TIMER_PERIOD64
        else
            data.ResetSeriesTime = 0
            data.AttackCount = 0
        end
        animWalk = animWalk + TIMER_PERIOD64
        if animWalk >= data.AnimDurationWalk then
            --длительность анимации WALK
            --print(animWalk)
            animWalk = 0
        end

        data.IsMoving = false
        if data.ReleaseW and data.ReleaseD == false and data.ReleaseA == false then
            --print("only w")
            angle = 90
            data.IsMoving = true
            if not data.tasks[11] then
                data.tasks[11] = true
                --print("Первый раз сделал движение")
            end
        end
        if data.ReleaseW and data.ReleaseD then
            --print("w+d")
            angle = 90 - 45
            data.IsMoving = true
        end
        if data.ReleaseW and data.ReleaseA then
            --print("w+s")
            angle = 90 + 45
            data.IsMoving = true
        end

        if data.ReleaseS and data.ReleaseD == false and data.ReleaseA == false then
            angle = 270
            data.IsMoving = true
        end
        if data.ReleaseS and data.ReleaseD then
            angle = 270 + 45
            data.IsMoving = true
        end
        if data.ReleaseS and data.ReleaseA then
            angle = 270 - 45
            data.IsMoving = true
        end

        if data.ReleaseD and data.ReleaseW == false and data.ReleaseS == false then
            angle = 0
            data.IsMoving = true
        end

        if data.ReleaseA and data.ReleaseW == false and data.ReleaseS == false then
            angle = 180
            data.IsMoving = true
        end

        if data.ReleaseW and data.ReleaseS and not data.ReleaseA and not data.ReleaseD then
            --data.ReleaseW = false
            --data.ReleaseS = false
            --data.IsMoving = false
            --print("слишком много кнопок нажато")
            DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", GetUnitXY(data.UnitHero)))
        end

        if not data.ReleaseW and not data.ReleaseS and data.ReleaseA and data.ReleaseD then
            --data.ReleaseA = false
            --data.ReleaseD = false
            --data.IsMoving = false
            DestroyEffect(AddSpecialEffect("Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl", GetUnitXY(data.UnitHero)))
            --print("слишком много кнопок нажато")
        end
        if not UnitAlive(hero) then
            --data.ReleaseW=false
            --data.ReleaseA=false
            --data.ReleaseS=false
            --data.ReleaseD=false
        end
        if not StunSystem[GetHandleId(hero)] then
            StunUnit(hero, 0.2)
        end
        if StunSystem[GetHandleId(data.UnitHero)].Time == 0 and onForces[GetHandleId(hero)] then
            --and
            if UnitAlive(hero) and not data.isShield and not data.isAttacking and not data.ReleaseRMB then


                if data.IsMoving and not UnitHasBow(hero) then
                    -- двигается
                    data.DirectionMove = angle

                    speed = GetUnitMoveSpeed(hero) / 38
                    --print(speed)
                    if data.isAttacking or (data.ReleaseQ and data.CDSpellQ > 0) or data.ReleaseRMB then
                        speed = 0.5
                    end
                    if data.CurrentWeaponType == "pickaxe" and false then
                        SetUnitTimeScale(hero, (speed * 20) / 100) --СКОРОСТЬ ПЕРЕБИРАНИЯ НОГАМИ
                    end

                    if data.ReleaseQ and data.CurrentWeaponType ~= "bow" then
                        --нормализация скорости
                        SetUnitTimeScale(hero, 1)
                    end
                    local x, y = GetUnitXY(hero)
                    local nx, ny = MoveXY(x, y, speed, angle)
                    local dx, dy = nx - x, ny - y

                    if not data.isAttacking then
                        if data.CurrentWeaponType == "pickaxe" or not data.PressSpin then
                            --
                            --print("место для поворота в движении"..angle)
                            SetUnitFacing(hero, angle)
                        else

                        end
                    end

                    SetUnitPositionSmooth(hero, nx, ny)-- блок движения




                    local newX, newY = GetUnitXY(hero)
                    local stator = false
                    if newX == x and newY == y then
                        --print("предположительно упёрся в стенку")

                        if not MiniChargeOnArea(data) then
                            stator = true
                            if true then
                                ResetUnitAnimation(hero) -- сборс в положении стоя
                            end

                        end -- Расталкиваем всех юнитов
                    end
                    if animWalk == 0 and not stator then
                        -- and not data.ReleaseRMB
                        --print("сброс анимации walk")
                        SetUnitAnimationByIndex(hero, data.IndexAnimationWalk)
                        --local r={SoundStep1,SoundStep2,SoundStep3,SoundStep4}
                        data.animStand = 3
                    end
                else
                    -- стоит на месте
                    --if animWalk==0 then
                    data.DirectionMove = GetUnitFacing(hero)
                    data.animStand = data.animStand + TIMER_PERIOD64

                    ---- Блок щита----
                    if not data.AttackShieldCD then
                        data.AttackShieldCD = 0
                    end
                    data.AttackShieldCD = data.AttackShieldCD - TIMER_PERIOD64

                    -------------------------
                    if data.animStand >= 2 and not data.ReleaseQ and not data.ReleaseRMB then
                        --длительность анимации WALK
                        --print(animWalk)
                        if data.CurrentWeaponType == "pickaxe" or true then
                            ResetUnitAnimation(hero) -- сброс в положении стоя
                        end
                        if data.CurrentWeaponType == "shield" or data.CurrentWeaponType == "bow" then
                            if data.PressSpin then
                            else
                                ResetUnitAnimation(hero)
                            end
                        end
                        --print("дефолтный сборс")
                        data.animStand = 0
                    end
                    --end
                    --print("r")--..GetUnitName(mainHero)
                end
            else
                --print("onattaking")
            end
        else
            -- иначе юнит оглушен
            -- SetUnitAnimationByIndex(hero,5)
            --UnitRemoveAbility(hero, FourCC("A003"))
            --UnitRemoveAbility(hero, FourCC("A004")) --ЧТО то очень старое
        end
    end)
end

function CreateWASDActions()
    -----------------------------------------------------------------OSKEY_W
    --print("initwasdactions")
    local gg_trg_EventUpW = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(gg_trg_EventUpW, Player(i), OSKEY_W, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(gg_trg_EventUpW, Player(i), OSKEY_UP, 0, true)
    end
    TriggerAddAction(gg_trg_EventUpW, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        --print("W "..GetUnitName(data.UnitHero))



        if not data.ReleaseW and UnitAlive(data.UnitHero) then


            data.wFast = true
            TimerStart(CreateTimer(), 0.1, false, function()
                data.wFast = false
                DestroyTimer(GetExpiredTimer())
            end)



            --and not data.isAttacking
            data.ReleaseW = true
            --print("W2")
            --SelectUnitForPlayerSingle(data.UnitHero,GetTriggerPlayer())
            if not data.isAttacking and StunSystem[GetHandleId(data.UnitHero)].Time == 0 then
                --print("pressW and short anim")
                UnitAddForceSimple(data.UnitHero, 90, 5, 15)
                data.DirectionMove = 90

                if data.ReleaseW and data.ReleaseD then
                    data.DirectionMove = 90 - 45
                end
                if data.ReleaseW and data.ReleaseA then
                    data.DirectionMove = 90 + 45
                end

                data.animStand = data.ResetDuration --до полной анимации 2 секунды
                if not LockAnimAnimation(data) then
                    SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationWalk)

                end
            end

        end
    end)
    local TrigDepressW = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDepressW, Player(i), OSKEY_W, 0, false)
        BlzTriggerRegisterPlayerKeyEvent(TrigDepressW, Player(i), OSKEY_UP, 0, false)
    end
    TriggerAddAction(TrigDepressW, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        data.ReleaseW = false
    end)
    -----------------------------------------------------------------OSKEY_S
    local gg_trg_EventUpS = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(gg_trg_EventUpS, Player(i), OSKEY_S, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(gg_trg_EventUpS, Player(i), OSKEY_DOWN, 0, true)
    end
    TriggerAddAction(gg_trg_EventUpS, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        if not data.ReleaseS and UnitAlive(data.UnitHero) then
            if data.sFast then
                UnitAddItemById(data.UnitHero, FourCC("I003")) --Bspe бафф
            end
            data.sFast = true
            TimerStart(CreateTimer(), 0.1, false, function()
                data.sFast = false
                DestroyTimer(GetExpiredTimer())
            end)
            -----
            data.ReleaseS = true
            --SelectUnitForPlayerSingle(data.UnitHero,Player(0))
            if not data.isAttacking and StunSystem[GetHandleId(data.UnitHero)].Time == 0 then
                data.animStand = 1.8 --до полной анимации 2 секунды
                UnitAddForceSimple(data.UnitHero, 270, 5, 15)
                data.DirectionMove = 270

                if data.ReleaseS and data.ReleaseD then
                    data.DirectionMove = 270 + 45
                end
                if data.ReleaseS and data.ReleaseA then
                    data.DirectionMove = 270 - 45
                end
                if not LockAnimAnimation(data) then
                    SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationWalk)
                end

            end
        end
    end)
    local TrigDepressS = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDepressS, Player(i), OSKEY_S, 0, false)
        BlzTriggerRegisterPlayerKeyEvent(TrigDepressS, Player(i), OSKEY_DOWN, 0, false)
    end
    TriggerAddAction(TrigDepressS, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        data.ReleaseS = false
    end)
    -----------------------------------------------------------------OSKEY_D
    local TrigPressD = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigPressD, Player(i), OSKEY_D, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(TrigPressD, Player(i), OSKEY_RIGHT, 0, true)
    end
    TriggerAddAction(TrigPressD, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        if not data.ReleaseD and UnitAlive(data.UnitHero) then
            if data.dFast then
                UnitAddItemById(data.UnitHero, FourCC("I003")) --Bspe бафф
            end
            data.dFast = true
            TimerStart(CreateTimer(), 0.1, false, function()
                data.dFast = false
                DestroyTimer(GetExpiredTimer())
            end)

            data.ReleaseD = true
            --SelectUnitForPlayerSingle(data.UnitHero,Player(0))
            if not data.isAttacking and StunSystem[GetHandleId(data.UnitHero)].Time == 0 then
                data.animStand = 1.8 --до полной анимации 2 секунды
                UnitAddForceSimple(data.UnitHero, 0, 5, 15)
                data.DirectionMove = 0
                SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationWalk)

            end
        end
    end)
    local TrigDePressD = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressD, Player(i), OSKEY_D, 0, false)
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressD, Player(i), OSKEY_RIGHT, 0, false)
    end
    TriggerAddAction(TrigDePressD, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        data.ReleaseD = false

    end)
    -----------------------------------------------------------------OSKEY_A
    local TrigPressA = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigPressA, Player(i), OSKEY_A, 0, true)
        BlzTriggerRegisterPlayerKeyEvent(TrigPressA, Player(i), OSKEY_LEFT, 0, true)
    end
    TriggerAddAction(TrigPressA, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        if not data.ReleaseA and UnitAlive(data.UnitHero) and StunSystem[GetHandleId(data.UnitHero)].Time == 0 then
            if data.aFast then
                UnitAddItemById(data.UnitHero, FourCC("I003")) --Bspe бафф
            end
            data.aFast = true
            TimerStart(CreateTimer(), 0.1, false, function()
                data.aFast = false
                DestroyTimer(GetExpiredTimer())
            end)
            ---
            data.ReleaseA = true
            --SelectUnitForPlayerSingle(data.UnitHero,Player(0))
            if not data.isAttacking then
                -- нет проверки на стан
                data.animStand = 1.8 --до полной анимации 2 секунды
                data.DirectionMove = 180
                UnitAddForceSimple(data.UnitHero, 180, 5, 15)
                if not LockAnimAnimation(data) then
                    SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationWalk)

                end
            end
        end
    end)
    local TrigDePressA = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressA, Player(i), OSKEY_A, 0, false)
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressA, Player(i), OSKEY_LEFT, 0, false)
    end
    TriggerAddAction(TrigDePressA, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        data.ReleaseA = false
    end)
    -----------------------------------------------------------------OSKEY_SPACE
    local TrigPressSPACE = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigPressSPACE, Player(i), OSKEY_SPACE, 0, true)
    end
    TriggerAddAction(TrigPressSPACE, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        if data.DashCharges > 0 and not data.ReleaseSPACE and not data.SpaceForce and UnitAlive(data.UnitHero) and StunSystem[GetHandleId(data.UnitHero)].Time == 0 and not data.ReleaseLMB then
            data.ReleaseSPACE = true
            --SelectUnitForPlayerSingle(data.UnitHero,Player(0))
            if not data.SpaceForce then
                data.animStand = 1.8 --до полной анимации 2 секунды
                print("SPACE")

                local dist = 200
                local delay = 0.2
                if data.ReleaseQ and not data.QJump2Pointer then
                    -- print("сплеш в рывке, пробуем прыгнуть прыжок")
                    dist = 400
                    delay = 0.3
                    data.GreatDamageDashQ = true
                    --print("q+space")
                    SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationQ) -- киркой в землю в рывке


                end

                data.DashCharges = data.DashCharges - 1
                if data.DashCharges == 0 then
                    --StartFrameCD(data.DashChargesReloadSec, data.DashChargesCDFH)
                end
                --BlzFrameSetText(data.DashChargesFH, data.DashCharges)
                TimerStart(CreateTimer(), data.DashChargesReloadSec, false, function()
                    data.DashCharges = data.DashCharges + 1
                    --BlzFrameSetText(data.DashChargesFH, data.DashCharges)
                    DestroyTimer(GetExpiredTimer())
                end)

                --UnitAddItemById(data.UnitHero, FourCC("I000")) -- предмет виндволк
                BlzSetUnitFacingEx(data.UnitHero, data.DirectionMove)
                --print("разворот при рывке")


                --------------------------------
                if data.isSpined then
                    --print("Рывок ветра") --Создаёт ураганное торнато впереди себя
                    if not data.tasks[7] then
                        data.tasks[7] = true
                    end
                    data.DirectionMove = -180 + AngleBetweenXY(data.fakeX, data.fakeY, GetUnitX(data.UnitHero), GetUnitY(data.UnitHero)) / bj_DEGTORAD
                    dist = 400
                end

                if data.HasWhirl then
                    --print("спираль")
                    local x, y = GetUnitXY(data.UnitHero)
                    --CreateAndForceBullet(data.UnitHero, data.DirectionMove, 5, "Abilities\\Weapons\\SentinelMissile\\SentinelMissile.mdl", x, y, 5, 350, 350)
                end

                if GetUnitTypeId(data.UnitHero) == KazumaID or GetUnitTypeId(data.UnitHero) == DarknessID or true then
                    local nx, ny = MoveXY(GetUnitX(data.UnitHero), GetUnitY(data.UnitHero), dist, data.DirectionMove)
                    local PerepadZ = GetTerrainZ(MoveXY(GetUnitX(data.UnitHero), GetUnitY(data.UnitHero), 120, data.DirectionMove)) - GetTerrainZ(GetUnitX(data.UnitHero), GetUnitY(data.UnitHero))
                    --print(PerepadZ)
                    if not IsTerrainPathable(nx, ny, PATHING_TYPE_WALKABILITY) and PerepadZ < -1 then
                        -- print("проверка проходимости конечной точки")
                        --DestroyEffect(AddSpecialEffect("Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt", nx, ny))
                        if not Chk2Way(GetUnitX(data.UnitHero), GetUnitY(data.UnitHero), nx, ny) then
                            Blink2Point(data, nx, ny)
                        else
                            print("прыжок вниз?")

                            UnitAddForceSimple(data.UnitHero, data.DirectionMove, 25, dist, "ignore") --САМ рывок при нажатии пробела
                        end
                    else
                        UnitAddForceSimple(data.UnitHero, data.DirectionMove, 25, dist, "ignore") --САМ рывок при нажатии пробела
                    end
                end
                if data.ArrowDamageAfterCharge then
                    data.ArrowDamageAfterChargeReady = true
                    BlzFrameSetVisible(data.ArrowDamageAfterChargePointer, GetLocalPlayer() == Player(data.pid))
                    --print("выстрел заряжен")
                end

                data.SpaceForce = true
                local effModel = "Hive\\Windwalk\\Windwalk Necro Soul\\Windwalk Necro Soul"
                if data.IframesOnDash then
                    effModel = "SystemGeneric\\InkMissile.mdx"
                end
                if data.IframesOnDashInvul then
                    -- неуязвимый рывок 2 уровень теневого
                    SetUnitInvulnerable(data.UnitHero, true)
                    TimerStart(CreateTimer(), 0.2, false, function()
                        SetUnitInvulnerable(data.UnitHero, false)
                        DestroyTimer(GetExpiredTimer())
                    end)
                end
                local eff = AddSpecialEffectTarget(effModel, data.UnitHero, "origin")

                TimerStart(CreateTimer(), delay, false, function()
                    DestroyEffect(eff)
                    data.SpaceForce = false
                    data.AttackInForce = false
                    SetUnitTimeScale(data.UnitHero, 1)
                    DestroyTimer(GetExpiredTimer())
                end)
                if not data.ReleaseQ then
                    -- анимация в обычном рывке
                    if not data.isSpined then
                        -- нельзя сделать во вращении
                        if data.IsMoving then
                            --print("в движении")
                            --SetUnitTimeScale(data.UnitHero, 4)
                        else
                            --print("стоя на месте")
                            --SetUnitTimeScale(data.UnitHero, 4)
                        end
                        SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationSpace)-- Всегда бег
                        --SetUnitAnimationByIndex(data.UnitHero, 27) -- 27 для кувырка -- IndexAnimationWalk -- для бега
                    end
                end
            end
        end
    end)
    local TrigDePressSPACE = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressSPACE, Player(i), OSKEY_SPACE, 0, false)

    end
    TriggerAddAction(TrigDePressSPACE, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        data.ReleaseSPACE = false
    end)
    -----------------------------------------------------------------OSKEY_Q

    local TrigPressQ = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigPressQ, Player(i), OSKEY_Q, 0, true)
    end
    TriggerAddAction(TrigPressQ, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        if not data.ReleaseQ and UnitAlive(data.UnitHero) and StunSystem[GetHandleId(data.UnitHero)].Time == 0 then

            --SelectUnitForPlayerSingle(data.UnitHero,Player(0))
            if not data.ReleaseQ and not data.ReleaseLMB and data.CDSpellQ == 0 and not data.ReleaseRMB and not (data.CurrentWeaponType == "shield" and data.PressSpin) then
                local balance = 1
                if data.isSpined then
                    balance = 6
                end
                data.CDSpellQ = data.SpellQCDTime * balance
                TimerStart(CreateTimer(), 1, true, function()
                    data.CDSpellQ = data.CDSpellQ - 1
                    if data.CDSpellQ <= 0 then
                        data.CDSpellQ = 0
                        DestroyTimer(GetExpiredTimer())
                    end
                end)
                data.animStand = 1.8 --до полной анимации 2 секунды
                --print("Q spell")
                data.ReleaseQ = true
                SetUnitAnimationByIndex(data.UnitHero, data.IndexAnimationQ) -- удар кирки в землю 3

                if data.CurrentWeaponType == "bow" then

                else
                    -- другое оружие, не лук
                    if data.QJump2Pointer then
                        --FIXED может ломать управление
                        --if not data.ReleaseQ then
                        --print("Q в курсор")

                        --StartFrameCD(data.SpellQCDTime * balance, data.cdFrameHandleQ)
                        --SpellSlashQ(data)
                        local angle = -180 + AngleBetweenXY(data.fakeX, data.fakeY, GetUnitX(data.UnitHero), GetUnitY(data.UnitHero)) / bj_DEGTORAD
                        local dist = DistanceBetweenXY(GetPlayerMouseX[data.pid], GetPlayerMouseY[data.pid], GetUnitX(data.UnitHero), GetUnitY(data.UnitHero))
                        if dist >= 500 then
                            dist = 500
                        end
                        BlzSetUnitFacingEx(data.UnitHero, angle)
                        print("разворот при Q  в область курсора")
                        if data.CurrentWeaponType == "shield" then
                            SetUnitAnimationByIndex(data.UnitHero, 26)
                            SetUnitTimeScale(data.UnitHero, 2)
                        end
                        UnitAddForceSimple(data.UnitHero, angle, 20, dist, "qjump")
                        TimerStart(CreateTimer(), 5, false, function()
                            DestroyTimer(GetExpiredTimer())
                            if data.ReleaseQ then
                                --print("выход из зависания")
                                data.ReleaseQ = false
                            end
                        end)
                        --end
                    else
                        local castDelay = 0.8 --задержка каста Q способности
                        if data.CurrentWeaponType == "shield" then
                            castDelay = 0.7
                        end
                        TimerStart(CreateTimer(), castDelay, false, function()
                            --задержка перед ударом
                            DestroyTimer(GetExpiredTimer())
                            --StartFrameCD(data.SpellQCDTime * balance, data.cdFrameHandleQ)
                            --SpellSlashQ(data)
                            print("активация Q")
                            if data.DoubleClap then
                                TimerStart(CreateTimer(), 0.35, false, function()
                                    --SpellSlashQ(data)
                                    DestroyTimer(GetExpiredTimer())
                                end)
                            end
                            data.ReleaseQ = false
                        end)
                    end
                end


            end
        end
    end)
    local TrigDePressQ = CreateTrigger()
    for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
        BlzTriggerRegisterPlayerKeyEvent(TrigDePressQ, Player(i), OSKEY_Q, 0, false)

    end
    TriggerAddAction(TrigDePressQ, function()
        local pid = GetPlayerId(GetTriggerPlayer())
        local data = HERO[pid]
        --data.ReleaseQ = false
    end)

end
---MouseX,MouseY=0,0
function BlockMouse(data)
    local this = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(this, EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER)
    TriggerRegisterAnyUnitEventBJ(this, EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER)
    TriggerAddAction(this, function()
        --  MouseX,MouseY=GetPlayerMouseX
        --print(OrderId2String(GetUnitCurrentOrder(mainHero)))
        if OrderId2String(GetUnitCurrentOrder(data.UnitHero)) == "dropitem" then
            data.DropInventory = false
            TimerStart(CreateTimer(), 2, false, function()
                DestroyTimer(GetExpiredTimer())
                data.DropInventory = true
            end)
        end

        if OrderId2String(GetUnitCurrentOrder(data.UnitHero)) == "smart" or OrderId2String(GetUnitCurrentOrder(data.UnitHero)) == "move" then
            --Строковый список приказов, которые игрок не может выполнить
            if OrderId2String(GetUnitCurrentOrder(data.UnitHero)) == "smart" then
                if not data.Desync and not FirstGoto then
                    print(GetPlayerName(Player(data.pid)) .. L(" Внимание! вы должны использовать классическую схему управления", "Attention!! you must use the classic control scheme"))
                    data.Desync = true
                end
            else
                --print("click LMB")
                -- data.LMBFIRST=true
            end
            --gkm=gkm+1
            --print(gkm)
            --print("STOP")
            BlzPauseUnitEx(data.UnitHero, true)
            IssueImmediateOrder(data.UnitHero, "stop")
            BlzPauseUnitEx(data.UnitHero, false)
        end
    end)
end

function GetUnitData(hero)
    local data = nil
    if HERO[GetPlayerId(GetOwningPlayer(hero))] then
        data = HERO[GetPlayerId(GetOwningPlayer(hero))]
    else
        print("Ошибка при использовании таблицы HERO")
    end
    return data
end

function LockAnimAnimation(data)
    return data.BowReady
end

function StopUnitMoving(data)
    data.ReleaseW = false
    data.ReleaseA = false
    data.ReleaseS = false
    data.ReleaseD = false
end

function PlayUnitAnimationFromChat()
    local this = CreateTrigger()
    TriggerRegisterPlayerChatEvent(this, Player(0), "", true)
    TriggerRegisterPlayerChatEvent(this, Player(1), "", true)
    TriggerAddAction(this, function()
        local s = S2I(GetEventPlayerChatString())
        local data = HERO[GetPlayerId(GetTriggerPlayer())]
        if GetEventPlayerChatString() == "w" then
            --CreateForUnitWayToPoint(mainHero,CQX,CQY)
            return
        end
        SetUnitAnimationByIndex(data.UnitHero, s)
        print(GetUnitName(data.UnitHero) .. " " .. s)
    end)
end

function ControlGameCam()
    TimerStart(CreateTimer(), TIMER_PERIOD64, true, function()
        CameraSetupApplyForPlayer(false, gg_cam_Camera_001, Player(0), 1.00)
    end)
end