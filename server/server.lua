local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

RegisterCommand('addcr', function(source)
    local user_id = vRP.getUserId(source)
    if CheckPermissions(user_id) then
        if CheckNurses(user_id) then
            TriggerClientEvent("Notify", source,"aviso","Você já possuí uma cadeira de rodas.")
        else
            TriggerClientEvent('js_wheelchair:Spawn', source)
            AddNurse(user_id)
            TriggerClientEvent("Notify", source,"sucesso","Você adicionou uma cadeira de rodas.")
        end
    end
end)

RegisterCommand('remcr', function(source)
	local user_id = vRP.getUserId(source)
    if CheckPermissions(user_id) then
        if CheckNurses(user_id) then
            TriggerClientEvent('js_wheelchair:Remove', source)
            RemoveNurse(user_id)
            TriggerClientEvent("Notify", source,"importante","Você removeu sua cadeira de rodas.")
        else
            TriggerClientEvent("Notify", source,"aviso","Você não possuí nenhuma cadeira de rodas.")
        end
    end
end)