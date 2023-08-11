function openBank()
    
    SendNUIMessage({
        action = true,
        type = 'show:interfaz:bank',
    })

    SetNuiFocus(true, true)
end

RegisterNUICallback('update', function()
    data = getDataUser()

    SendNUIMessage({
        action = true,
        type = 'update:interfaz:bank',
        data_info = data
    })
end)

function getDataUser()
    local data = ESX.GetPlayerData()
    local result = {}
    local result_users = nil
    local result_transactions = nil
    local money = 0
    local bank = 0

    for k,v in pairs(data.accounts) do

        if(v.name ~= 'black_money' and v.name ~= 'bank') then
            money = v.money
        end

        if(v.name ~= 'black_money' and v.name ~= 'money') then
            bank = v.money
        end
    end
 
    local streetA, streetB = GetStreetNameAtCoord(GetEntityCoords(PlayerPedId()).x, GetEntityCoords(PlayerPedId()).y, GetEntityCoords(PlayerPedId()).z)

    street = {}

    if not ((streetA == lastStreetA or streetA == lastStreetB) and (streetB == lastStreetA or streetB == lastStreetB)) then
        lastStreetA = streetA
        lastStreetB = streetB
    end

    if lastStreetA ~= 0 then
        table.insert(street, GetStreetNameFromHashKey(lastStreetA))
    end

    street = table.concat(street)

    ESX.TriggerServerCallback('jav_bank:getUsersAccounts', function(cards, transactions)
        result_users = cards
        result_transactions = transactions
    end)

    while (result_users == nil or result_transactions == nil) do
        Wait(0)
    end
    
    table.insert(result, {
        title = street,
        name = data.firstName.. ' '..data.lastName,
        accounts = {money = money, bank = bank},
        result_users = result_users,
        result_transactions = result_transactions
    })

    return result
    
end

function getUserPin()

    local pin = nil

    ESX.TriggerServerCallback('jav_bank:getPinCode', function(result)
        pin = result
    end)

    Wait(100)

    return pin
end

function openPin()

    local pin = getUserPin()

    SetNuiFocus(true, true)

    SendNUIMessage({
        action = true,
        type = 'show:interfaz:pin',
        pin_code = pin
    })
end
