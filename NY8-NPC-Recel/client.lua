local npcModel = 'u_m_m_streetart_01'
local npcCoords = vector4(1125.08, -1010.39, 44.68, 97.45)
local cam = nil

CreateThread(function()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do Wait(100) end

    local npc = CreatePed(0, npcModel, npcCoords.x, npcCoords.y, npcCoords.z - 1.0, npcCoords.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    exports.ox_target:addLocalEntity(npc, {
        {
            label = 'Vendre des objets',
            icon = 'fas fa-box',
            onSelect = function()
                ShowDealerDialogue(npc)
            end
        }
    })
end)

function ShowDealerDialogue(npc)
    lib.notify({
        title = 'Receleur',
        description = 'T’as quoi à me proposer ?',
        type = 'inform'
    })

    StartCinematicCam(npc)

    Wait(1500)

    TriggerEvent('ny8-recel:openMenu')
end

function StartCinematicCam(npc)
    if cam then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(cam, false)
    end

    local bone = GetPedBoneCoords(npc, 31086, 0.0, 0.0, 0.2)
    local camCoords = GetOffsetFromEntityInWorldCoords(npc, 0.8, 0.8, 0.7)

    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(cam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(cam, bone.x, bone.y, bone.z)
    SetCamFov(cam, 50.0)
    RenderScriptCams(true, false, 0, true, true)
end

function StopCinematicCam()
    if cam then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(cam, false)
        cam = nil
    end
end

local ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('ny8-recel:openMenu', function()
    ESX.TriggerServerCallback('ny8-recel:getReputation', function(rep)
        local level = math.floor(rep / 10000)
        local options = {
            {
                title = "🧪 Réputation : " .. rep .. " pts (Niveau " .. level .. ")",
                icon = 'circle-info',
                disabled = true
            }
        }

        for item, info in pairs(Config.ItemsToSell) do
            local label = item
            table.insert(options, {
                title = ('%s - %s$'):format(label, info.price),
                description = info.dirty and '💰 Argent sale' or '💵 Argent propre',
                icon = 'box',
                onSelect = function()
                    local input = lib.inputDialog('Combien veux-tu vendre ?', {
                        {type = 'number', label = 'Quantité', default = 1}
                    })

                    if input then
                        TriggerServerEvent('ny8-recel:sellItem', item, tonumber(input[1]))
                    end
                end
            })
        end

        lib.registerContext({
            id = 'ny8_recel_menu',
            title = 'Receleur',
            options = options,
            onExit = function()
                StopCinematicCam()
            end
        })

        lib.showContext('ny8_recel_menu')
    end)
end)