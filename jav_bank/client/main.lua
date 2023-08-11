bank = {
    open = false,
    pin_code = nil
}

CreateThread(function()
    
    for k,v in pairs(Shared.Bank) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)

        SetBlipSprite(blip, 108)
        SetBlipDisplay(blip, 2)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.title)
        EndTextCommandSetBlipName(blip)        
    end

    while true do
        local time = 250

        for k,v in pairs(Shared.Bank) do
            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)

            local distance = #(ped_coords - vec3(v.x, v.y, v.z))

            if(distance <= 1.5 and not bank.open and not IsEntityDead(ped)) then
                time = 0

                if (not bank.open) then
                    ESX.ShowHelpNotification('~INPUT_CONTEXT~ para abrir el banco')
                end

                if(IsControlJustReleased(0, 38)) then
                    bank.open = true
                    openBank()
                end
            end
        end

        Wait(time)
    end
end)

CreateThread(function()
    while true do
        local time = 250

        for k,v in pairs(Shared.Models) do

            local ped = PlayerPedId()
            local ped_coords = GetEntityCoords(ped)

            local AtmHash = GetClosestObjectOfType(ped_coords.x, ped_coords.y, ped_coords.z, 1.0, v.model, false, false, false)

            if DoesEntityExist(AtmHash) then

                time = 0

                if(not bank.open and not IsEntityDead(ped)) then
                    ESX.ShowHelpNotification('Pulsa ~INPUT_CONTEXT~ para acceder al ATM')
                end

                if IsControlJustReleased(0, 38) then

                    bank.pin_code = getUserPin()

                    if(bank.pin_code ~= nil) then
                        
                        RequestAnimDict('anim@amb@prop_human_atm@interior@male@enter')
                        while not HasAnimDictLoaded('anim@amb@prop_human_atm@interior@male@enter') do
                            Wait(7)
                        end
                        TaskPlayAnim(ped, 'anim@amb@prop_human_atm@interior@male@enter', 'enter', 8.0, 8.0, -1, 0, 0, 0, 0, 0)

                        Wait(3000)

                        ClearPedTasks(ped)

                        bank.open = true

                        openPin()
                    else
                        ESX.ShowNotification('No te has creado un PIN!', 'warning')
                    end
                end
            end
        end

        Wait(time)
    end
end)

local in_dialog = false 

function openBankDialog(title, count, cb)
    if (not in_dialog) then

        in_dialog = true

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = true,
            type = 'show:interfaz:bank_dialog',
            account = account
        })

        local callbackFired = false

        RegisterNUICallback('bank_dialog', function(data)
            if (not callbackFired) then
                callbackFired = true
                in_dialog = false
                SetNuiFocus(false, false)

                ESX.TriggerServerCallback('jav_bank:useMethodBank', function(result)
                   cb(result)
                end, title, data.account, count)
            end
        end)
    end
end

RegisterNUICallback('close', function()
    bank.open = false
    in_dialog = false
    SetNuiFocus(false, false)
end)

RegisterNUICallback('open_bank', function()
    openBank()
end)

RegisterNUICallback('fast_options', function(data)
    if(bank.open) then
        ESX.TriggerServerCallback('jav_bank:fastOptions', function() end, data)
    end
end)

exports('appendBankDialog', openBankDialog)