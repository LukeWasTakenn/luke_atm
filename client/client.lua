local atmFound = false
local inATM = false
local show = false
local refresh = false
local isAtBank = false
local notified = false
local hidden = true
PlayerData = {}
ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    end
end)

Citizen.CreateThread(function()
    playerPed = PlayerPedId()
    playerCoords = GetEntityCoords(playerPed)
    if Config.EnableBankBlips == true then
        BankBlips()
    end
    while true do
        Citizen.Wait(500)
        playerPed = PlayerPedId()
        playerCoords = GetEntityCoords(playerPed)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if Config.EnableBanks == true then
            for k, v in pairs(Config.Banks) do
                local coords = vector3(v.x, v.y, v.z)
                local distance = #(playerCoords - coords)

                if distance < 1.3 then
                    currentBank = v
                    isAtBank = true
                    hidden = false
                    break
                else
                    isAtBank = false
                end
            end
        end
        for k, v in pairs(Config.Models) do
            local model = GetHashKey(v)
            entity = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 1.0, model, false, false, false)
    
            if entity ~= 0 then
                atmFound = true
                atmCoords = GetEntityCoords(entity)
                hidden = false
                break
            else
                atmFound = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if isAtBank == true or atmFound == true and inATM == false then
            if isAtBank == true and inATM == false and Config.EnableBanks == true then
                wait = 0
                if not notified then
                    TriggerEvent('luke_textui:ShowUI', 'E - Access Bank')
                    notified = true
                end
                if IsControlJustReleased(0, 51) then
                    AccessBank(currentBank.h)
                end
            elseif atmFound == true and inATM == false then
                wait = 0
                if IsControlJustReleased(0, 51) then
                    EnterATM(entity)
                end
                if not notified then
                    TriggerEvent('luke_textui:ShowUI', 'E - Use ATM')
                    notified = true
                end
            end
        else
            wait = 500
            if notified and not hidden then
                hidden = true
                notified = false
                TriggerEvent('luke_textui:HideUI')
            end
        end
        Citizen.Wait(wait)
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
    end
end)

RegisterNetEvent('luke_atm:Refresh')
AddEventHandler('luke_atm:Refresh', function()
    ESX.TriggerServerCallback('luke_atm:GetBankMoney', function(playerMoney)
    SendNUIMessage({
        type = 'refresh',
        playerMoney = playerMoney,
    })
    end)
end)

RegisterNUICallback('luke_atm:GetPlayerCash', function(data)
    ESX.TriggerServerCallback('luke_atm:FetchPlayerCash', function(cash)
        SendNUIMessage({
            type = 'depositCash',
            cash = cash
        })
    end)
end)

RegisterNUICallback('luke_atm:CloseATM', function(data)
    if inATM == true then
        SetNuiFocus(false, false)
        ClearPedTasksImmediately(playerPed)
        CloseATM()
    else
        return
    end
end)

RegisterNUICallback('luke_atm:Withdraw', function(data)
    TriggerServerEvent('luke_atm:WithdrawMoney', data.amount, data.comment, data.type)
end)

RegisterNUICallback('luke_atm:Deposit', function(data)
    TriggerServerEvent('luke_atm:DepositMoney', data.amount, data.comment, data.type)
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

function AccessBank(heading)
    inATM = true
    SetEntityHeading(playerPed, heading)
    exports['mythic_progbar']:Progress({
        name = "luke_atm:AccessBank",
        duration = 1500,
        label = 'Showing Information',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_atm@male@enter",
            anim = "enter",
            flags = 49,
        },
    }, function(cancelled)
        if not cancelled then
            LoadAnim("amb@prop_human_atm@male@idle_a")
            TaskPlayAnim(playerPed, "amb@prop_human_atm@male@idle_a", "idle_a", 8.0, -8.0, -1, 3, 0, false, false, false)
            ESX.TriggerServerCallback('luke_atm:GetBankMoney', function(playerMoney)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = 'UI',
                    show = true,
                    playerMoney = playerMoney,
                })
            end)
        else
            
        end
    end)
end

function EnterATM(entity)
    inATM = true
    TaskTurnPedToFaceEntity(playerPed, entity, -1)
    exports['mythic_progbar']:Progress({
        name = "luke_atm:AccessATM",
        duration = 1500,
        label = 'Inserting Card',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_atm@male@enter",
            anim = "enter",
            flags = 49,
        },
    }, function(cancelled)
        if not cancelled then
            LoadAnim("amb@prop_human_atm@male@idle_a")
            TaskPlayAnim(playerPed, "amb@prop_human_atm@male@idle_a", "idle_a", 8.0, -8.0, -1, 3, 0, false, false, false)
            ESX.TriggerServerCallback('luke_atm:GetBankMoney', function(playerMoney)
                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = 'UI',
                    show = true,
                    playerMoney = playerMoney,
                })
            end)
        else
            
        end
    end)
end

function CloseATM()
    inATM = false
    exports['mythic_progbar']:Progress({
        name = "luke_atm:AccessBank",
        duration = 1000,
        label = 'Retrieving Card',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
            disableMovement = false,
            disableCarMovement = false,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@prop_human_bbq@male@exit",
            anim = "exit",
            flags = 49,
        },
    }, function(cancelled)
        if not cancelled then

        else
            
        end
    end)
end

function BankBlips()
    for k, v in pairs(Config.Banks) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 207)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipDisplay(blip, 2)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Bank')
        EndTextCommandSetBlipName(blip)
    end
end

function LoadAnim(dict)
    RequestAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        Citizen.Wait(0)
    end
end