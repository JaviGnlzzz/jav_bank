function formatDate(timestamp)
    local formattedDate = os.date("%Y-%m-%d", timestamp / 1000)
    return formattedDate
end

function updatePin(source, code)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.getIdentifier()
    local pin_code = getPin(source)
    local price = tonumber(Shared.PinPrice)
    local balance = xPlayer.getAccount('bank').money 

    if (price <= balance) then
        if(code ~= 0 and code ~= '') then
            if(pin_code == code) then
                xPlayer.showNotification('Ya estas usando ese PIN!', 'warning')
            else
                MySQL.Async.execute('UPDATE users SET pin_code = ? WHERE identifier = ?' , {code, identifier})
            
                xPlayer.removeAccountMoney('bank', price)
                xPlayer.showNotification('Cambiaste tu PIN a : ~g~'..code..' ~w~ - se te cobro la cantidad de ~g~'..price..' $', 'success')
            end
        else
            xPlayer.showNotification('Debes poner un número válido!', 'warning')
        end
    else
        xPlayer.showNotification('No tienes suficiente dinero en tu cuenta!', 'error')
    end
end

function getPin(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    local pin_code = MySQL.query.await('SELECT pin_code FROM users WHERE identifier = ?', {xPlayer.getIdentifier()})

    return pin_code
end

function addTransaction(identifier, title, other_info, amount, type)
    MySQL.Async.execute('INSERT INTO jav_bank (identifier, title, other_info, amount, type) VALUES (?, ?, ?, ?, ?)', {identifier, title, other_info, amount, type})
end