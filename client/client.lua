local atmFound = false
local inATM = false
local show = false
local refresh = false
PlayerData = {}
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(PlayerData)
    PlayerData = xPlayer
end)

RegisterCommand('atm', function()
    Citizen.CreateThread(function()
        TriggerEvent('luke_atm:ATMCheck')
    end)
end, false)

RegisterCommand('atmclose', function()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'UI',
        show = false
    })
end, false)

RegisterNetEvent('luke_atm:ATMCheck')
AddEventHandler('luke_atm:ATMCheck', function()
    playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for k, v in pairs(Config.Models) do
        local model = GetHashKey(v)
        entity = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 1.5, model, false, false, false)

        if entity ~= 0 then
            atmFound = true
            break
        else
            atmFound = false
        end
    end
    
    if atmFound == true then
        EnterATM(entity)
        if Config.UsePogressBars == true then
            Citizen.Wait(Config.AnimationEnterTime)
        end
        inATM = true
        ESX.TriggerServerCallback('luke_atm:GetBankMoney', function(playerMoney)
            SetNuiFocus(true, true)
            SendNUIMessage({
                type = 'UI',
                show = true,
                playerMoney = playerMoney,
            })
        end)
    end
end)

RegisterNetEvent('luke_atm:Refresh')
AddEventHandler('luke_atm:Refresh', function()
    ESX.TriggerServerCallback('luke_atm:GetBankMoney', function(playerMoney)
    SendNUIMessage({
        refresh = true,
        playerMoney = playerMoney,
    })
    end)
end)

RegisterNUICallback('luke_atm:CloseATM', function(data)
    if inATM == true then
        SetNuiFocus(false, false)
        ClearPedTasks(playerPed)
        CloseATM()
        inATM = false
    else
        return
    end
end)

RegisterNUICallback('luke_atm:Withdraw', function(data)
    TriggerServerEvent('luke_atm:WithdrawMoney', data.withdrawAmount, data.comment, data.type)
end)

RegisterNUICallback('luke_atm:Deposit', function(data)
    TriggerServerEvent('luke_atm:DepositMoney', data.depositAmount, data.comment, data.type)
end)

RegisterNUICallback('luke_atm:OpenTransactions', function(data)
    ESX.TriggerServerCallback('luke_atm:FetchTransactions', function(transactions)
        SendNUIMessage({
            type = 'fetchTransactions',
            playerTransactions = transactions,
        })
    end)
end)

RegisterNUICallback('luke_atm:TransferMoney', function(data)
    TriggerServerEvent('luke_atm:TransferMoney', data.id, data.comment, data.amount)
end)

function EnterATM(entity)
    if Config.UsePogressBars == true then
        TaskTurnPedToFaceEntity(playerPed, entity, -1)
        LoadAnim('amb@prop_human_atm@male@enter')
        TaskPlayAnim(playerPed, "amb@prop_human_atm@male@enter", "enter", 8.0, -8.0, Config.AnimationEnterTime, 120, 0, false, false, false)
        exports['pogressBar']:drawBar(Config.AnimationEnterTime, 'Inserting Card', function()
            LoadAnim("amb@prop_human_atm@male@idle_a")
            TaskPlayAnim(playerPed, "amb@prop_human_atm@male@idle_a", "idle_a", 8.0, -8.0, -1, 3, 0, false, false, false)
        end)
    else
        TaskTurnPedToFaceEntity(playerPed, entity, -1)
        LoadAnim('amb@prop_human_atm@male@enter')
        TaskPlayAnim(playerPed, "amb@prop_human_atm@male@enter", "enter", 8.0, -8.0, Config.AnimationEnterTime, 120, 0, false, false, false)
        Citizen.Wait(Config.AnimationEnterTime)
        LoadAnim("amb@prop_human_atm@male@idle_a")
        TaskPlayAnim(playerPed, "amb@prop_human_atm@male@idle_a", "idle_a", 8.0, -8.0, -1, 3, 0, false, false, false)
    end
end

function CloseATM()
    if Config.UsePogressBars == true then
        LoadAnim("amb@prop_human_bbq@male@exit")
        exports['pogressBar']:drawBar(Config.AnimationExitTime, 'Retrieving Card')
        TaskPlayAnim(playerPed, "amb@prop_human_bbq@male@exit", "exit", 8.0, -8.0, Config.AnimationExitTime, 120, 0, false, false, false)
    else
        LoadAnim("amb@prop_human_bbq@male@exit")
        TaskPlayAnim(playerPed, "amb@prop_human_bbq@male@exit", "exit", 8.0, -8.0, Config.AnimationExitTime, 120, 0, false, false, false)
    end
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        Citizen.Wait(0)
    end
end