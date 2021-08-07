local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
}


--- action functions
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local sleep = 0

--- esx
local GUI = {}
ESX                           = nil
GUI.Time                      = 0
local PlayerData              = {}

Citizen.CreateThread(function ()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(7)
  PlayerData = ESX.GetPlayerData()
  end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

----markers
AddEventHandler('esx_anwbabon:hasEnteredMarker', function (zone)
  if zone ~= nil then
    CurrentAction     = 'onoff'
    CurrentActionMsg = 'Druk op ~INPUT_CONTEXT~ om een abonnement aan te schaffen'
  end
end)

AddEventHandler('esx_anwbabon:hasExitedMarker', function (zone)
  CurrentAction = nil
end)


--keycontrols
Citizen.CreateThread(function ()
    while true do
        sleep = 1500

        local playerPed = GetPlayerPed(-1)
        local coords = GetEntityCoords(GetPlayerPed(-1))
        for k,v in pairs(Config.Zones) do
          if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
            sleep = 2
        if CurrentAction ~= nil then
                    SetTextComponentFormat('STRING')
                    AddTextComponentString(CurrentActionMsg)
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustPressed(0, Keys['E']) then
                      ESX.UI.Menu.CloseAll()
  
                      ESX.UI.Menu.Open(
                        'default', GetCurrentResourceName(), 'ANWB Abonnement',
                        {
                          title    = 'ANWB Abonnement',
                          align    = 'top-right',
                          elements = {
                              {label = "ANWB abonnement afsluiten <span style='color: green;'>€5000</span>",	value = 'aanschaffen'},
                              {label = "ANWB abonnement opzeggen",	value = 'opzeggen'},
                          }
                        },
                        function(data, menu)
                          local inventory = ESX.GetPlayerData().inventory
                          if data.current.value == 'aanschaffen' then

                            ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
                              if hasDriversLicense then
                                exports['mythic_notify']:DoHudText('error', 'Je hebt al een ANWB abonnement')
                              else
                                TriggerServerEvent('esx_abonnementen:anwb:afgesloten')
                              end
                            end, GetPlayerServerId(PlayerId()), 'anwb')
                            ESX.UI.Menu.CloseAll()
                          elseif data.current.value == 'opzeggen' then

                            ESX.TriggerServerCallback('esx_license:checkLicense', function(hasDriversLicense)
                              if hasDriversLicense then
                                TriggerServerEvent('esx_license:removeLicense', GetPlayerServerId(PlayerId()), 'anwb')
                                exports['mythic_notify']:DoHudText('success', 'Je hebt je het ANWB abonnement succesvol opgezegd')
                              else
                                exports['mythic_notify']:DoHudText('error', 'Je hebt geen ANWB abonnement')
                              end
                            end, GetPlayerServerId(PlayerId()), 'anwb')
                            ESX.UI.Menu.CloseAll()
                          end
                          
          
                        end,
                        function(data, menu)
                  
                          menu.close()
                  

                          CurrentActionData = {station = station}
                  
                        end
                      )
                    end   
                  end
                end       
        end
        Citizen.Wait(sleep)
    end       
end)

function DrawText3Ds(x, y, z, text)
  SetTextScale(0.35, 0.35)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 215)
  SetTextEntry("STRING")
  SetTextCentre(true)
  AddTextComponentString(text)
  SetDrawOrigin(x,y,z, 0)
  DrawText(0.0, 0.0)
  local factor = (string.len(text)) / 370
  DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
  ClearDrawOrigin()
end

-- Display markers
Citizen.CreateThread(function ()
  while true do
    sleep = 1500

    local coords = GetEntityCoords(GetPlayerPed(-1))
	
    for k,v in pairs(Config.Zones) do
      if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        sleep = 2
        if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 2.5) then
          DrawText3Ds(v.Pos.x, v.Pos.y, v.Pos.z+1.25, "ANWB Abonnement ")
        end
        DrawMarker(20, v.Pos.x, v.Pos.y, v.Pos.z+1, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.5, 0.5, 0.35, 187, 255, 0, 100, false, true, 2, false, false, false, false)
      end
    end
    Citizen.Wait(sleep)
  end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function ()
  while true do
    sleep = 1500

    local coords      = GetEntityCoords(GetPlayerPed(-1))
    local isInMarker  = false
    local currentZone = nil

    for k,v in pairs(Config.Zones) do
      if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
        sleep = 0
        if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < 1.5) then
          isInMarker  = true
          currentZone = k
        end
      end
    end

    if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
      HasAlreadyEnteredMarker = true
      LastZone                = currentZone
      TriggerEvent('esx_anwbabon:hasEnteredMarker', currentZone)
    end

    if not isInMarker and HasAlreadyEnteredMarker then
      HasAlreadyEnteredMarker = false
      TriggerEvent('esx_anwbabon:hasExitedMarker', LastZone)
    end
    Citizen.Wait(sleep)
  end
end)