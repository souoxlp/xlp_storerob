local locale_file = ('locales/%s.json'):format(GetConvar('ox:locale', 'pt'))
local locale_data = json.decode(LoadResourceFile(GetCurrentResourceName(), locale_file) or '{}')

local function locale(str, ...)
    local translation = locale_data[str] or str
    if ... then
        return string.format(translation, ...)
    end
    return translation
end

local robbedStores = {}
local robbedSafes = {}
local robbedComputers = {}

-- Função para enviar logs ao Discord
local function SendDiscordLog(title, description, color, fields)
    if not Config.EnableDiscordLogs or Config.DiscordWebhook == 'YOUR_WEBHOOK_URL_HERE' then
        return
    end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or Config.DiscordColor,
            ["fields"] = fields or {},
            ["footer"] = {
                ["text"] = os.date("%d/%m/%Y %H:%M:%S"),
            },
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({
        username = Config.DiscordBotName,
        avatar_url = Config.DiscordAvatar,
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end

-- Callback: Verificar se player tem item
lib.callback.register('xlp_storerob:hasItem', function(source, item)
    local hasItem = exports.ox_inventory:GetItem(source, item, nil, true)
    return hasItem and hasItem > 0
end)

-- Callback: Contar polícias online
lib.callback.register('xlp_storerob:getPoliceCount', function(source)
    local policeCount = 0
    local players = exports.qbx_core:GetQBPlayers()
    
    for _, player in pairs(players) do
        if player.PlayerData.job.name == 'police' and player.PlayerData.job.onduty then
            policeCount = policeCount + 1
        end
    end
    
    return policeCount
end)

-- Evento: Completar assalto
RegisterNetEvent('xlp_storerob:complete', function(zoneId, storeName)
    ---@diagnostic disable-next-line: assign-type-mismatch
    local src = source ---@type number
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar se loja já foi roubada
    if robbedStores[zoneId] then
        return
    end
    
    -- Marcar como roubada
    robbedStores[zoneId] = true
    
    -- Sincronizar com todos os clientes
    TriggerClientEvent('xlp_storerob:syncRobbedStore', -1, zoneId)
    
    -- Dar recompensa
    local reward = math.random(Config.MinReward, Config.MaxReward)
    exports.ox_inventory:AddItem(src, Config.RewardItem, reward)
    
    -- Notificar player
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('title_robbery'),
        description = string.format(locale('robbery_reward'), reward),
        type = 'success'
    })
    
    -- Log
    local playerName = GetPlayerName(src) or 'Desconhecido'
    local identifier = Player.PlayerData.citizenid or 'N/A'
    
    print(string.format('^2[Store Robbery]^7 %s assaltou %s e recebeu $%s', 
        playerName, 
        storeName or 'loja desconhecida', 
        reward
    ))
    
    -- Discord Log
    SendDiscordLog(
        '🏪 Assalto à Loja',
        string.format('**%s** assaltou uma loja com sucesso!', playerName),
        3066993, -- Verde
        {
            {name = '👤 Player', value = playerName, inline = true},
            {name = '🆔 Citizen ID', value = identifier, inline = true},
            {name = '🏪 Loja', value = storeName or 'Desconhecida', inline = false},
            {name = '💰 Recompensa', value = string.format('$%s (%s)', reward, Config.RewardItem), inline = true},
            {name = '📍 Zona ID', value = tostring(zoneId), inline = true}
        }
    )
    
    -- Reset após cooldown
    SetTimeout(Config.ResetTime * 60 * 1000, function()
        robbedStores[zoneId] = false
        TriggerClientEvent('xlp_storerob:resetStore', -1, zoneId)
        print(string.format('^2[Store Robbery]^7 %s foi resetada', storeName or 'Loja'))
    end)
end)

-- Evento: Alertar polícia
RegisterNetEvent('xlp_storerob:policeAlert', function(storeName)
    local players = exports.qbx_core:GetQBPlayers()
    for _, cop in pairs(players) do
        if cop.PlayerData.job.name == 'police' and cop.PlayerData.job.onduty then
            TriggerClientEvent('xlp_storerob:policeAlert', cop.PlayerData.source, storeName)
        end
    end
end)

-- Evento: Completar assalto ao cofre
RegisterNetEvent('xlp_storerob:completeSafe', function(safeId, storeName)
    ---@diagnostic disable-next-line: assign-type-mismatch
    local src = source ---@type number
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar se cofre já foi roubado
    if robbedSafes[safeId] then
        return
    end
    
    -- Marcar como roubado
    robbedSafes[safeId] = true
    
    -- Sincronizar com todos os clientes
    TriggerClientEvent('xlp_storerob:syncRobbedSafe', -1, safeId)
    
    -- Dar recompensa maior
    local reward = math.random(Config.SafeMinReward, Config.SafeMaxReward)
    exports.ox_inventory:AddItem(src, Config.RewardItem, reward)
    
    -- Notificar player
    TriggerClientEvent('ox_lib:notify', src, {
        title = locale('title_robbery'),
        description = string.format(locale('safe_reward'), reward),
        type = 'success'
    })
    
    -- Log
    local playerName = GetPlayerName(src) or 'Desconhecido'
    local identifier = Player.PlayerData.citizenid or 'N/A'
    
    print(string.format('^2[Store Robbery]^7 %s assaltou o cofre de %s e recebeu $%s', 
        playerName, 
        storeName or 'loja desconhecida', 
        reward
    ))
    
    -- Discord Log
    SendDiscordLog(
        '🔐 Assalto ao Cofre',
        string.format('**%s** assaltou um cofre com sucesso!', playerName),
        15844367, -- Ouro
        {
            {name = '👤 Player', value = playerName, inline = true},
            {name = '🆔 Citizen ID', value = identifier, inline = true},
            {name = '🏪 Loja', value = storeName or 'Desconhecida', inline = false},
            {name = '💰 Recompensa', value = string.format('$%s (%s)', reward, Config.RewardItem), inline = true},
            {name = '📍 Safe ID', value = tostring(safeId), inline = true}
        }
    )
    
    -- Reset após cooldown
    SetTimeout(Config.ResetTime * 60 * 1000, function()
        robbedSafes[safeId] = false
        TriggerClientEvent('xlp_storerob:resetSafe', -1, safeId)
        print(string.format('^2[Store Robbery]^7 Cofre de %s foi resetado', storeName or 'Loja'))
    end)
end)

-- Evento: Remover lockpick
RegisterNetEvent('xlp_storerob:removeLockpick', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.RequiredItem, 1)
end)

-- Evento: Remover USB
RegisterNetEvent('xlp_storerob:removeUsb', function()
    local src = source
    exports.ox_inventory:RemoveItem(src, Config.HackRequiredItem, 1)
end)

-- Evento: Completar hack do computador
RegisterNetEvent('xlp_storerob:completeHack', function(computerId, storeName)
    ---@diagnostic disable-next-line: assign-type-mismatch
    local src = source ---@type number
    local Player = exports.qbx_core:GetPlayer(src)
    
    if not Player then return end
    
    -- Verificar se computador já foi hackeado
    if robbedComputers[computerId] then
        return
    end
    
    -- Marcar como hackeado
    robbedComputers[computerId] = true
    
    -- Sincronizar com todos os clientes
    TriggerClientEvent('xlp_storerob:syncRobbedComputer', -1, computerId)
    
    -- 50% de chance de conseguir transferir dinheiro limpo
    local hackSuccess = math.random(100) <= Config.HackSuccessChance
    
    local playerName = GetPlayerName(src) or 'Desconhecido'
    
    if hackSuccess then
        -- Sucesso: Dinheiro limpo para a conta bancária
        local reward = math.random(Config.HackMinReward, Config.HackMaxReward)
        Player.Functions.AddMoney('bank', reward)
        
        -- Notificar player
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title_hacking'),
            description = string.format(locale('hack_success'), reward),
            type = 'success'
        })
        
        -- Log
        local identifier = Player.PlayerData.citizenid or 'N/A'
        
        print(string.format('^2[Store Robbery]^7 %s hackeou com sucesso %s e transferiu $%s', 
            playerName, 
            storeName or 'loja desconhecida', 
            reward
        ))
        
        -- Discord Log
        SendDiscordLog(
            '💻 Hack Bem-Sucedido',
            string.format('**%s** hackeou um computador e transferiu dinheiro!', playerName),
            5763719, -- Azul ciano
            {
                {name = '👤 Player', value = playerName, inline = true},
                {name = '🆔 Citizen ID', value = identifier, inline = true},
                {name = '🏪 Loja', value = storeName or 'Desconhecida', inline = false},
                {name = '💰 Transferido', value = string.format('$%s (Dinheiro Limpo)', reward), inline = true},
                {name = '📍 Computer ID', value = tostring(computerId), inline = true}
            }
        )
    else
        -- Falhou: Sem recompensa
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('title_hacking'),
            description = locale('hack_failed_transfer'),
            type = 'error'
        })
        
        -- Log
        local identifier = Player.PlayerData.citizenid or 'N/A'
        
        print(string.format('^3[Store Robbery]^7 %s tentou hackear %s mas falhou na transferência', 
            playerName, 
            storeName or 'loja desconhecida'
        ))
        
        -- Discord Log
        SendDiscordLog(
            '⚠️ Hack Falhado',
            string.format('**%s** tentou hackear mas falhou na transferência.', playerName),
            15105570, -- Laranja
            {
                {name = '👤 Player', value = playerName, inline = true},
                {name = '🆔 Citizen ID', value = identifier, inline = true},
                {name = '🏪 Loja', value = storeName or 'Desconhecida', inline = false},
                {name = '📍 Computer ID', value = tostring(computerId), inline = true}
            }
        )
    end
    
    -- Reset após cooldown
    SetTimeout(Config.ResetTime * 60 * 1000, function()
        robbedComputers[computerId] = false
        TriggerClientEvent('xlp_storerob:resetComputer', -1, computerId)
        print(string.format('^2[Store Robbery]^7 Computador de %s foi resetado', storeName or 'Loja'))
    end)
end)
