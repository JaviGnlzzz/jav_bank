local player_pin_code = nil

ESX.RegisterServerCallback('jav_bank:getUsersAccounts', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentChar = xPlayer.identifier:sub(1, xPlayer.identifier:find(':') - 1)
    local identifier = xPlayer.identifier:sub(xPlayer.identifier:find(':') + 1, -1)
    local result_cards = {}
    local result_transactions = {}

    local queryIdentifier = "%" ..identifier

    local data_cards = MySQL.query.await('SELECT identifier, firstname, lastname, accounts, pin_code FROM users WHERE identifier LIKE ?', {queryIdentifier})
    local data_transactions = MySQL.query.await('SELECT title, other_info, amount, date, type FROM jav_bank WHERE identifier = ? AND date >= DATE_SUB(NOW(), INTERVAL 3 DAY)', {xPlayer.getIdentifier()})
    
    for k,v in pairs(data_cards) do
        if v.identifier ~= currentChar .. ':' .. identifier then

            table.insert(result_cards, {
                identifier = v.identifier,
                name = v.firstname..' '..v.lastname,
                bank = json.decode(v.accounts).bank,
                pin_code = v.pin_code or '----'
            })

        else
            table.insert(result_cards, {
                identifier = v.identifier,
                name = v.firstname..' '..v.lastname,
                bank = xPlayer.getAccount('bank').money,
                pin_code = v.pin_code or '----'
            })

            player_pin_code = v.pin_code
        end
    end

    for k, v in pairs(data_transactions) do
        table.insert(result_transactions, {
            title = v.title,
            other_info = v.other_info,
            amount = v.amount,
            date = formatDate(v.date),
            type = v.type
        })
    end
    
    local total_items = #result_transactions
    local mid_point = math.floor(total_items / 2)
    
    for i = 1, mid_point do
        local opposite_index = total_items - i + 1
        result_transactions[i], result_transactions[opposite_index] = result_transactions[opposite_index], result_transactions[i]
    end

    cb(result_cards, result_transactions)
end)

ESX.RegisterServerCallback('jav_bank:fastOptions', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local amount = tonumber(data.amount)
    local xTarget = nil

    if(data.id ~= nil) then
        xTarget = ESX.GetPlayerFromId(data.id)
    end

    if(data.type == 'deposit') then
        local HandMoney = xPlayer.getMoney()
    
        if amount == nil or amount <= 0 then
          xPlayer.showNotification('Cantidad invalida!', 'error')
        else
            if amount <= HandMoney then
                xPlayer.removeMoney(amount)
                xPlayer.addAccountMoney('bank', amount)
                xPlayer.showNotification('Ha depositado ~g~' .. amount .. '$ ~w~con exito!', 'success')

                addTransaction(identifier, 'Deposito', 'Deposito bancario efectuado', amount, 'add')
            else
              xPlayer.showNotification('No tienes suficiente dinero!', 'error')
            end
        end
    end

    if(data.type == 'withdraw') then
        local balance = xPlayer.getAccount('bank').money 
    
        if amount == nil or amount <= 0 then
          xPlayer.showNotification('Cantidad invalida!', 'error')
        else 
            if amount <= balance then
                xPlayer.removeAccountMoney('bank', amount)
                xPlayer.addMoney(amount)
    
                xPlayer.showNotification('Ha retirado ~g~' .. amount .. '$~w~ con exito!', 'success')

                addTransaction(identifier, 'Retiro', 'Cantidad retirada con exito', amount, 'remove')
            else
              xPlayer.showNotification('No puedes retirar esa cantidad!', 'error')
            end
        end
    end

    if(data.type == 'transfer') then

        local balance = xPlayer.getAccount('bank').money 

        if (xTarget ~= nil) then

            if (tonumber(source) == tonumber(data.id)) then
                xPlayer.showNotification('No puedes tranferirte dinero ti mismo!', 'error')
            else
                if (balance <= 0 or balance < amount or amount <= 0) then
                    xPlayer.showNotification('No tienes suficiente dinero!')
                else
                    xPlayer.removeAccountMoney('bank', amount)
                    xTarget.addAccountMoney('bank', amount)
                    xTarget.showNotification("Recibiste una transferencia de ~g~"..amount.."$  ~w~- "..data.message, 'success')
                    xPlayer.showNotification("Enviaste una transferencia de ~g~"..amount.."$ ~w~- "..data.message, 'success')
                    
                    addTransaction(identifier, 'Transferencia a '..xTarget.getName(), 'Mensaje - '..data.message or 'sin datos', amount, 'remove')
                end
            end
        else
            xPlayer.showNotification('Cuenta no encontrada', 'error')
        end 
    end

    if(data.type == 'update_pin') then
        updatePin(source, data.amount)

        addTransaction(identifier, 'PIN', 'Cambio de PIN efectuado al codigo - '..data.amount, Shared.PinPrice, 'remove')
    end

end)

ESX.RegisterServerCallback('jav_bank:getPinCode', function(source, cb)
    local pin_code = getPin(source)

    for k, v in pairs(pin_code) do 
        cb(v.pin_code)
    end
end)

ESX.RegisterServerCallback('jav_bank:useMethodBank', function(source, cb, title, method, count)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local amount = tonumber(count)

    if(method == 'bank') then
        local balance = xPlayer.getAccount('bank').money 
    
        if amount == nil or amount <= 0 then
          xPlayer.showNotification('Vaya!, ocurrio un error', 'error')
          cb(false)
        else 
            if amount <= balance then
                xPlayer.removeAccountMoney('bank', amount)
                xPlayer.showNotification('Pago completado a ~g~'..title, 'success')
                
                addTransaction(identifier, 'Pago', 'Cantidad retirada con exito a '..title, amount, 'remove')
                cb(true)
            else
                xPlayer.showNotification('No tienes suficiente dinero!', 'error')
                cb(false)
            end
        end
    end

    if(method == 'money') then
        local balance = xPlayer.getMoney()
    
        if amount == nil or amount <= 0 then
            xPlayer.showNotification('Vaya!, ocurrio un error', 'error')
            cb(false)
        else 
            if amount <= balance then
                xPlayer.removeAccountMoney('money', amount)
                xPlayer.showNotification('Pago completado a ~g~'..title, 'success')
                cb(true)
            else
                xPlayer.showNotification('No tienes suficiente dinero!', 'error')
                cb(false)
            end
        end
    end
end)
