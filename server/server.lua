ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('luke_atm:GetBankMoney', function(source, callback)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local playerMoney = xPlayer.getAccount('bank').money

    callback(playerMoney)
end)

RegisterNetEvent('luke_atm:WithdrawMoney')
AddEventHandler('luke_atm:WithdrawMoney', function(withdrawAmount, comment, type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if comment == '' then
        comment = nil
    end

    if xPlayer.getAccount('bank').money >= tonumber(withdrawAmount) then
        xPlayer.removeAccountMoney('bank', tonumber(withdrawAmount))
        xPlayer.addMoney(tonumber(withdrawAmount))
        TriggerClientEvent('luke_atm:Refresh', src)
        MySQL.Async.execute('INSERT INTO `transactions` (`identifier`, `amount`, `comment`, `type`) VALUES (@identifier, @amount, @comment, @type)', {
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@amount'] = withdrawAmount,
            ['@comment'] = comment,
            ['@type'] = type
        }, function()
        
        end)
    else
        TriggerClientEvent('esx:showHelpNotification', src, "You do not have enough money in your bank to withdraw that much.")
    end
end)

RegisterNetEvent('luke_atm:DepositMoney')
AddEventHandler('luke_atm:DepositMoney', function(depositAmount, comment, type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if comment == '' then
        comment = nil
    end

    if xPlayer.getMoney() < tonumber(depositAmount) then
        TriggerClientEvent('esx:showHelpNotification', src, "You don't have that much to deposit.")
    else
        xPlayer.removeMoney(tonumber(depositAmount))
        xPlayer.addAccountMoney('bank', tonumber(depositAmount))
        TriggerClientEvent('luke_atm:Refresh', src)
        MySQL.Async.execute('INSERT INTO `transactions` (`identifier`, `amount`, `comment`, `type`) VALUES (@identifier, @amount, @comment, @type)', {
            ['@identifier'] = xPlayer.getIdentifier(),
            ['@amount'] = depositAmount,
            ['@comment'] = comment,
            ['@type'] = type
        }, function()
        
        end)
    end
end)

RegisterNetEvent('luke_atm:TransferMoney')
AddEventHandler('luke_atm:TransferMoney', function(id, comment, amount)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(id)
    
    if xTarget == nil then
        TriggerClientEvent('esx:showHelpNotification', src, "That player does not exist.")
    else
        amount = tonumber(amount)
        if xPlayer.getAccount('bank').money >= amount then
            -- Igrac ima dosta novca
            xPlayer.removeAccountMoney('bank', amount)
            xTarget.addAccountMoney('bank', amount)
            TriggerClientEvent('luke_atm:Refresh', src)
            MySQL.Async.execute('INSERT INTO `transactions` (`identifier`, `amount`, `comment`, `recipient`, `type`) VALUES (@identifier, @amount, @comment, @recipient, @type)', {
                ['@identifier'] = xPlayer.getIdentifier(),
                ['@amount'] = amount,
                ['@comment'] = comment,
                ['@recipient'] = xTarget.getIdentifier(),
                ['@type'] = 'transfer'
            }, function()
            
            end)
        else
            -- Igrac prenosi vise novca nego sto ima
            TriggerClientEvent('esx:showHelpNotification', src, "You do not have that much money in your account.")
        end
    end
end)

ESX.RegisterServerCallback('luke_atm:FetchTransactions', function(source, callback)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local transactions = {}

    MySQL.Async.fetchAll('SELECT * FROM `transactions` WHERE `identifier` = @identifier OR `recipient` = @identifier', {
        ['@identifier'] = xPlayer.getIdentifier(),
    }, function(data)
        for k, v in pairs(data) do
            table.insert(transactions, {comment = v.comment, amount = v.amount, transactionType = v.type, identifier = v.identifier, recipient = v.recipient})
        end
        callback(transactions)
    end)
end)