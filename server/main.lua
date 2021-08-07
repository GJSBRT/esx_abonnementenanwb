ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_abonnementen:anwb:afgesloten')
AddEventHandler('esx_abonnementenen:anwb:afgesloten', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.removeAccountMoney('bank', 5000)
    TriggerEvent('esx_license:addLicense', source, 'anwb', function()
    end)
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mechanic', function(account)
        account.addMoney(5000)
    end)
end)