minerva.units = minerva.units or {}

function minerva.units:LoadFolder()
    local path = "minervarts/schema/units"
    local bSuccess = false
    
    if ( file.Exists(path, "LUA") ) then
        bSuccess = minerva:LoadFolder("minervarts/schema/units", true)
    end

    if not ( bSuccess ) then
        minerva:PrintError("Units not found!")
        return
    end

    hook.Run("UnitsLoad", path)

    minerva:PrintMessage("Loaded units.")

    hook.Run("UnitsLoaded", path)

    return true
end

function minerva.units:Register(info)
    hook.Run("PreUnitRegister", info)

    local UniqueID = string.lower(string.gsub(info.Name, "%s", "_"))
    UniqueID = "zb_minerva_" .. UniqueID
    UniqueID = info.UniqueID or UniqueID

    if ( ZBaseNPCs and ZBaseNPCs[UniqueID] ) then
        minerva:PrintWarning("Unit " .. info.Name .. " already exists! Overwriting...")
        ZBaseNPCs[UniqueID] = nil
    else
        minerva:PrintMessage("Registered " .. info.Name .. " unit.")
    end

    info.ZBaseStartFaction = info.ZBaseStartFaction or "neutral"

    ZBaseNPCs[UniqueID] = info

    if ( info.Base ) then
        table.Inherit(ZBaseNPCs[UniqueID], self:Get(info.Base))
    end

    table.Inherit(ZBaseNPCs[UniqueID], ZBaseNPCs.npc_zbase)

    ZBaseNPCs[UniqueID].BaseClass = nil

    if ( string.find(string.lower(info.Name), "base") ) then
        ZBaseNPCs[UniqueID].Spawnable = false
    end

    hook.Run("UnitRegistered", info)

    return ZBaseNPCs[UniqueID]
end

function minerva.units:Get(identifier)
    if not ( identifier ) then
        minerva:PrintError("Attempted to get an invalid unit!")
        return
    end

    if ( istable(identifier) ) then
        identifier = identifier.Name
    end

    if ( ZBaseNPCs[identifier] ) then
        return ZBaseNPCs[identifier]
    end

    for k, v in pairs(ZBaseNPCs) do
        if ( string.find(string.lower(v.Name), string.lower(identifier)) ) then
            return v
        end
    end
end