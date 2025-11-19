local locale_file = ('locales/%s.json'):format(GetConvar('ox:locale', 'pt'))
local locale_data = json.decode(LoadResourceFile(GetCurrentResourceName(), locale_file) or '{}')

local function locale(str, ...)
    local translation = locale_data[str] or str
    if ... then
        return string.format(translation, ...)
    end
    return translation
end

local robbing = false
local robbedStores = {}
local robbedSafes = {}
local robbedComputers = {}

-- Criar zonas ox_target para cada loja
CreateThread(function()
    Wait(1000)
    
    local zoneId = 1
    
    for storeIndex, store in ipairs(Config.Stores) do
        -- Caixas registadoras
        if store.registers then
            for regIndex, register in ipairs(store.registers) do
                local currentZoneId = zoneId
                print(string.format('[Store Robbery] Criando zona %d para caixa %d da loja: %s', currentZoneId, regIndex, store.name))
                
                exports.ox_target:addBoxZone({
                    coords = register.coords,
                    size = vec3(0.8, 0.8, 1.5),
                    rotation = register.heading,
                    options = {
                        {
                            name = 'rob_store_' .. currentZoneId,
                            icon = 'fas fa-mask',
                            label = 'Assaltar Loja',
                            onSelect = function()
                                print(string.format('[Store Robbery] Tentando assaltar zona %d', currentZoneId))
                                RobStore(currentZoneId, store.name)
                            end,
                            canInteract = function()
                                local canRob = not robbing and not robbedStores[currentZoneId]
                                if not canRob then
                                    print(string.format('[Store Robbery] Zona %d bloqueada - robbing: %s, robbedStores[%d]: %s', 
                                        currentZoneId, tostring(robbing), currentZoneId, tostring(robbedStores[currentZoneId])))
                                end
                                return canRob
                            end
                        }
                    }
                })
                zoneId = zoneId + 1
            end
        end
        
        -- Cofre
        if store.safe then
            exports.ox_target:addBoxZone({
                coords = store.safe.coords,
                size = vec3(1.0, 1.0, 1.5),
                rotation = store.safe.heading,
                options = {
                    {
                        name = 'rob_safe_' .. storeIndex,
                        icon = 'fas fa-vault',
                        label = 'Assaltar Cofre',
                        onSelect = function()
                            RobSafe(storeIndex, store.name)
                        end,
                        canInteract = function()
                            return not robbing and not robbedSafes[storeIndex]
                        end
                    }
                }
            })
        end
        
        -- Computador
        if store.computer then
            exports.ox_target:addBoxZone({
                coords = store.computer.coords,
                size = vec3(0.6, 0.6, 1.2),
                rotation = store.computer.heading,
                options = {
                    {
                        name = 'hack_computer_' .. storeIndex,
                        icon = 'fas fa-laptop-code',
                        label = 'Hackear Computador',
                        onSelect = function()
                            HackComputer(storeIndex, store.name)
                        end,
                        canInteract = function()
                            return not robbing and not robbedComputers[storeIndex]
                        end
                    }
                }
            })
        end
    end
end)

function RobStore(zoneId, storeName)
    print(string.format('[Store Robbery] RobStore chamada - zoneId: %d, storeName: %s', zoneId, storeName))
    
    -- Verificar se já está a roubar
    if robbing then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('already_robbing'),
            type = 'error'
        })
        return
    end

    -- Verificar se tem lockpick
    local hasItem = lib.callback.await('xlp_storerob:hasItem', false, Config.RequiredItem)
    if not hasItem then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('need_lockpick'),
            type = 'error'
        })
        return
    end

    -- Verificar polícia
    local policeCount = lib.callback.await('xlp_storerob:getPoliceCount', false)
    if policeCount < Config.MinPolice then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('not_enough_police'),
            type = 'error'
        })
        return
    end

    robbing = true

    -- Minigame de lockpick
    local success = lib.skillCheck(Config.Difficulty, {'w', 'a', 's', 'd'})

    if not success then
        -- Falhou o minigame
        robbing = false
        
        -- Chance de quebrar o lockpick
        if math.random(100) <= Config.LockpickBreakChance then
            TriggerServerEvent('xlp_storerob:removeLockpick')
            lib.notify({
                title = locale('title_robbery'),
                description = locale('lockpick_broke'),
                type = 'error'
            })
        else
            lib.notify({
                title = locale('title_robbery'),
                description = locale('failed_open_register'),
                type = 'error'
            })
        end
        return
    end

    -- Passou no minigame, iniciar roubo
    local ped = PlayerPedId()
    
    -- Alertar polícia imediatamente
    TriggerServerEvent('xlp_storerob:policeAlert', storeName)
    
    -- Criar props de dinheiro (uma em cada mão)
    lib.requestModel(`prop_anim_cash_pile_01`)
    
    -- Mão direita (bone 57005)
    local moneyProp1 = CreateObject(`prop_anim_cash_pile_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(moneyProp1, ped, GetPedBoneIndex(ped, 57005), 0.13, 0.05, 0.02, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Mão esquerda (bone 18905)
    local moneyProp2 = CreateObject(`prop_anim_cash_pile_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(moneyProp2, ped, GetPedBoneIndex(ped, 18905), 0.13, 0.05, 0.02, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Animação
    lib.requestAnimDict('oddjobs@shop_robbery@rob_till')
    TaskPlayAnim(ped, 'oddjobs@shop_robbery@rob_till', 'loop', 8.0, 8.0, -1, 1, 0, false, false, false)

    -- Progress circle
    if lib.progressCircle({
        duration = Config.RobberyTime,
        label = locale('robbing_store'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        -- Completou o roubo
        ClearPedTasks(ped)
        DeleteObject(moneyProp1)
        DeleteObject(moneyProp2)
        
        -- Marcar localmente para evitar roubar de novo antes do servidor responder
        robbedStores[zoneId] = true
        print(string.format('[Store Robbery] Marcado robbedStores[%d] = true', zoneId))
        
        -- Notificar servidor (ele vai sincronizar o estado)
        TriggerServerEvent('xlp_storerob:complete', zoneId, storeName)
        
        lib.notify({
            title = locale('title_robbery'),
            description = locale('robbery_success'),
            type = 'success'
        })
    else
        -- Cancelou
        ClearPedTasks(ped)
        DeleteObject(moneyProp1)
        DeleteObject(moneyProp2)
        lib.notify({
            title = locale('title_robbery'),
            description = locale('robbery_cancelled'),
            type = 'error'
        })
    end

    robbing = false
end

function RobSafe(safeId, storeName)
    -- Verificar se já está a roubar
    if robbing then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('already_robbing'),
            type = 'error'
        })
        return
    end

    -- Verificar se tem lockpick
    local hasItem = lib.callback.await('xlp_storerob:hasItem', false, Config.RequiredItem)
    if not hasItem then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('need_lockpick'),
            type = 'error'
        })
        return
    end

    -- Verificar polícia
    local policeCount = lib.callback.await('xlp_storerob:getPoliceCount', false)
    if policeCount < Config.MinPolice then
        lib.notify({
            title = locale('title_robbery'),
            description = locale('not_enough_police'),
            type = 'error'
        })
        return
    end

    robbing = true

    -- Minigame mais difícil para cofre
    local success = lib.skillCheck(Config.SafeDifficulty, {'w', 'a', 's', 'd'})

    if not success then
        -- Falhou o minigame
        robbing = false
        
        -- Maior chance de quebrar o lockpick no cofre
        if math.random(100) <= 50 then
            TriggerServerEvent('xlp_storerob:removeLockpick')
            lib.notify({
                title = locale('title_robbery'),
                description = locale('lockpick_broke_safe'),
                type = 'error'
            })
        else
            lib.notify({
                title = locale('title_robbery'),
                description = locale('failed_open_safe'),
                type = 'error'
            })
        end
        return
    end

    -- Passou no minigame, iniciar roubo do cofre
    local ped = PlayerPedId()
    
    -- Alertar polícia imediatamente
    TriggerServerEvent('xlp_storerob:policeAlert', storeName)
    
    -- Criar props de dinheiro (uma em cada mão)
    lib.requestModel(`prop_anim_cash_pile_01`)
    
    -- Mão direita (bone 57005)
    local moneyProp1 = CreateObject(`prop_anim_cash_pile_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(moneyProp1, ped, GetPedBoneIndex(ped, 57005), 0.13, 0.05, 0.02, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Mão esquerda (bone 18905)
    local moneyProp2 = CreateObject(`prop_anim_cash_pile_01`, 0, 0, 0, true, true, true)
    AttachEntityToEntity(moneyProp2, ped, GetPedBoneIndex(ped, 18905), 0.13, 0.05, 0.02, -90.0, 0.0, 0.0, true, true, false, true, 1, true)
    
    -- Animação
    lib.requestAnimDict('oddjobs@shop_robbery@rob_till')
    TaskPlayAnim(ped, 'oddjobs@shop_robbery@rob_till', 'loop', 8.0, 8.0, -1, 1, 0, false, false, false)

    -- Progress circle (mais tempo para cofre)
    if lib.progressCircle({
        duration = Config.SafeRobberyTime,
        label = locale('opening_safe'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        -- Completou o roubo
        ClearPedTasks(ped)
        DeleteObject(moneyProp1)
        DeleteObject(moneyProp2)
        
        -- Marcar localmente para evitar roubar de novo antes do servidor responder
        robbedSafes[safeId] = true
        
        -- Notificar servidor (ele vai sincronizar o estado)
        TriggerServerEvent('xlp_storerob:completeSafe', safeId, storeName)
        
        lib.notify({
            title = locale('title_robbery'),
            description = locale('safe_robbery_success'),
            type = 'success'
        })
    else
        -- Cancelou
        ClearPedTasks(ped)
        DeleteObject(moneyProp1)
        DeleteObject(moneyProp2)
        lib.notify({
            title = locale('title_robbery'),
            description = locale('safe_robbery_cancelled'),
            type = 'error'
        })
    end

    robbing = false
end

function HackComputer(computerId, storeName)
    -- Verificar se já está a roubar
    if robbing then
        lib.notify({
            title = locale('title_hacking'),
            description = locale('already_hacking'),
            type = 'error'
        })
        return
    end

    -- Verificar se tem USB
    local hasItem = lib.callback.await('xlp_storerob:hasItem', false, Config.HackRequiredItem)
    if not hasItem then
        lib.notify({
            title = locale('title_hacking'),
            description = locale('need_usb'),
            type = 'error'
        })
        return
    end

    -- Verificar polícia
    local policeCount = lib.callback.await('xlp_storerob:getPoliceCount', false)
    if policeCount < Config.MinPolice then
        lib.notify({
            title = locale('title_hacking'),
            description = locale('not_enough_police'),
            type = 'error'
        })
        return
    end

    robbing = true

    -- Minigame de hacking
    local success = lib.skillCheck(Config.HackDifficulty, {'w', 'a', 's', 'd'})

    if not success then
        -- Falhou o minigame
        robbing = false
        
        -- Chance de partir a USB
        if math.random(100) <= Config.UsbBreakChance then
            TriggerServerEvent('xlp_storerob:removeUsb')
            lib.notify({
                title = locale('title_hacking'),
                description = locale('usb_broke'),
                type = 'error'
            })
        else
            lib.notify({
                title = locale('title_hacking'),
                description = locale('failed_hack'),
                type = 'error'
            })
        end
        return
    end

    -- Passou no minigame, iniciar hack
    local ped = PlayerPedId()
    
    -- Alertar polícia imediatamente
    TriggerServerEvent('xlp_storerob:policeAlert', storeName)
    
    -- Animação de digitação
    lib.requestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    TaskPlayAnim(ped, 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 8.0, 8.0, -1, 1, 0, false, false, false)

    -- Progress circle para hacking
    if lib.progressCircle({
        duration = Config.HackTime,
        label = locale('hacking_system'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        }
    }) then
        -- Completou o hack
        ClearPedTasks(ped)
        
        -- Marcar localmente para evitar hackear de novo antes do servidor responder
        robbedComputers[computerId] = true
        
        -- Notificar servidor (ele vai sincronizar o estado e decidir se teve sucesso com 50%)
        TriggerServerEvent('xlp_storerob:completeHack', computerId, storeName)
    else
        -- Cancelou
        ClearPedTasks(ped)
        lib.notify({
            title = locale('title_hacking'),
            description = locale('hack_cancelled'),
            type = 'error'
        })
    end

    robbing = false
end

-- Sincronização de estado entre clientes
RegisterNetEvent('xlp_storerob:syncRobbedStore', function(zoneId)
    robbedStores[zoneId] = true
end)

RegisterNetEvent('xlp_storerob:syncRobbedSafe', function(safeId)
    robbedSafes[safeId] = true
end)

RegisterNetEvent('xlp_storerob:syncRobbedComputer', function(computerId)
    robbedComputers[computerId] = true
end)

-- Reset da loja após cooldown
RegisterNetEvent('xlp_storerob:resetStore', function(zoneId)
    robbedStores[zoneId] = false
end)

-- Reset do cofre após cooldown
RegisterNetEvent('xlp_storerob:resetSafe', function(safeId)
    robbedSafes[safeId] = false
end)

-- Reset do computador após cooldown
RegisterNetEvent('xlp_storerob:resetComputer', function(computerId)
    robbedComputers[computerId] = false
end)

-- Alerta para polícia
RegisterNetEvent('xlp_storerob:policeAlert', function(storeName)
    lib.notify({
        title = locale('police_alert'),
        description = locale('robbery_in_progress', storeName),
        type = 'info',
        duration = 7000
    })
end)
