---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by Bergi.
--- DateTime: 18.03.2022 2:14
---
function AddSpell2DataByName(data, spellName)
    local step = 0.039
    local sx=0.2
    if not data.nextElement then
        data.nextElement = 0
        data.SpellsFH = {}
        data.SpellsName = {}-- таблица содержит фреймы
    end
    data.nextElement = data.nextElement + 1
    data.SpellsName[data.nextElement] = spellName
    data.SpellsFH[data.nextElement] = CreateSimpleFrameGlue(sx+data.nextElement * step, 0.02, spellName, data.SpellPanelContainer)
end

