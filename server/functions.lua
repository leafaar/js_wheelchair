local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

local nurses = {} 
local permissions = {'admin.permissao', 'ems.permissao'}

function AddNurse(user_id)
    local max = table.maxn(nurses) + 1
    table.insert(nurses, max, user_id)
end

function RemoveNurse(user_id)
    for w, nurse_id in ipairs(nurses) do
        if nurse_id == user_id then
            table.remove(nurses, w)
            break 
        end
    end
end

function CheckNurses(user_id)
    for w, nurse_id in ipairs(nurses) do
        if nurse_id == user_id then
            return true
        else
            return false
        end
    end
end

function CheckPermissions(user_id)
    if vRP.hasPermission(user_id, permissions[1]) or vRP.hasPermission(user_id, permissions[2]) then
        return true
    else
        return false
    end
end