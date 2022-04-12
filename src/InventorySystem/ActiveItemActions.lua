---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bergi.
--- DateTime: 21.12.2021 1:45
---

function ActiveItemActions(data, m)
    local name = data.ItemSlotName[m]
    if BDItems[name] then
        if BDItems[name].canUsed then
            --print("Предмет можно использовать")

            ItemActivatorList(data,name)

            local item=data.ItemSlotTexture[m]
            local ch = GetFrameCharges(item)
            ch=ch-1
            if ch<=0 then
                ClearSlot(data,m)
            else
                SetFrameCharges(item,ch)
            end
        end
    else
        --print("клик по пустому слоту")
    end
end

function ClearSlot(data,m)
    data.ItemSlotName[m] ="empty_slot"
    BlzFrameSetText(data.ItemSlotText[m],"Пусто")
    BlzFrameSetTexture(data.ItemSlotTexture[m], "empty_slot", 0, true)
    local _,f1,f2=GetFrameCharges(data.ItemSlotTexture[m])
    BlzDestroyFrame(f1)
    BlzDestroyFrame(f2)
end

function ItemActivatorList(data,name)
    if name=="Apple" then
        HealUnit(data.UnitHero,10)
    elseif name=="Slime Jelly" then
        HealUnit(data.UnitHero,50)
    else
        print("попытка активировать предмет не из базы данных",name)
    end
end