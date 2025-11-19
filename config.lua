Config = {}

-- Idioma / Language
-- IMPORTANTE: Adicione no seu server.cfg a linha: setr ox:locale pt (ou en)
-- IMPORTANT: Add to your server.cfg the line: setr ox:locale pt (or en)

-- Discord Webhook Logs
Config.EnableDiscordLogs = true -- Ativar/Desativar logs no Discord
Config.DiscordWebhook = 'https://discordapp.com/api/webhooks/1440483986370596894/2bkoT3HaxLlu9f-k83CG91Vf9qDjfCowVRQ0c49RfE2zWiT-1t_VJVg_OseAbqkEZUUp' -- Cole aqui o webhook do Discord
Config.DiscordBotName = 'Store Robbery Logs' -- Nome do bot
Config.DiscordAvatar = '' -- Avatar do bot (opcional)
Config.DiscordColor = 3447003 -- Cor do embed (azul por padrão)

-- Configurações gerais
Config.RequiredItem = 'lockpick' -- Item necessário para roubar
Config.HackRequiredItem = 'usb_black' -- Item necessário para hackear
Config.ResetTime = 30 -- Tempo em minutos para resetar o roubo
Config.MinPolice = 0 -- Número mínimo de polícias online
Config.LockpickBreakChance = 40 -- Chance de quebrar o lockpick (%)
Config.UsbBreakChance = 40 -- Chance de quebrar a USB (%)

-- Recompensas
Config.MinReward = 500
Config.MaxReward = 1500
Config.RewardItem = 'black_money' -- Item que o jogador recebe

-- Recompensas do Cofre
Config.SafeMinReward = 2000
Config.SafeMaxReward = 5000

-- Recompensas do Computador (Hack)
Config.HackMinReward = 1000
Config.HackMaxReward = 3000
Config.HackSuccessChance = 50 -- Chance de sucesso em %

-- Progresso e Minigame
Config.RobberyTime = 15000 -- Tempo de roubo em ms (15 segundos)
Config.SafeRobberyTime = 25000 -- Tempo de roubo do cofre em ms (25 segundos)
Config.HackTime = 20000 -- Tempo de hack em ms (20 segundos)
Config.Difficulty = {'easy', 'easy', 'medium'} -- Dificuldade do minigame
Config.SafeDifficulty = {'easy', 'easy', 'easy'} -- Dificuldade do minigame do cofre
Config.HackDifficulty = {'easy', 'easy', 'easy'}  -- Dificuldade do hack

-- Lojas 24/7
Config.Stores = {
    {
        name = "24/7 Supermarket - Grove Street", -- Innocence Blvd
        registers = {
            {coords = vector3(24.4791, -1344.9016, 29.4970), heading = 270.0},
            {coords = vector3(24.5, -1347.37, 29.5), heading = 270.0}
        },
        safe = {coords = vector3(28.1588, -1338.7192, 28.8068), heading = 0.0},
        computer = {coords = vector3(29.5590, -1338.3704, 29.3723), heading = 180.0}
    },
    {
        name = "LTD Gasoline - Inseno Road",
        registers = {
            {coords = vector3(-3038.92, 585.71, 7.91), heading = 20.0},
            {coords = vector3(-3041.14, 583.87, 7.91), heading = 20.0}
        },
        safe = {coords = vector3(-3048.2958, 585.4102, 7.2009), heading = 0.0},
        computer = {coords = vector3(-3049.0339, 586.6518, 7.7842), heading = 200.0}
    },
    {
        name = "24/7 Supermarket - Barbareno Road",
        registers = {
            {coords = vector3(-3242.41, 1000.14, 12.83), heading = 355.0},
            {coords = vector3(-3244.56, 1000.48, 12.83), heading = 355.0}
        },
        safe = {coords = vector3(-3250.5161, 1004.4418, 12.1558), heading = 0.0},
        computer = {coords = vector3(-3250.736, 1005.8194, 12.7060), heading = 355.0}
    },
    {
        name = "24/7 Supermarket - Great Ocean Highway",
        registers = {
            {coords = vector3(1727.3, 6414.27, 35.04), heading = 245.0},
            {coords = vector3(1728.79, 6416.02, 35.04), heading = 245.0}
        },
        safe = {coords = vector3(1734.9835, 6421.3173, 34.3080), heading = 0.0},
        computer = {coords = vector3(1736.3864, 6420.9741, 34.9125), heading = 245.0}
    },
    {
        name = "LTD Gasoline - Grape Seed Main Street",
        registers = {
            {coords = vector3(1697.23, 4922.77, 42.06), heading = 325.0},
            {coords = vector3(1698.56, 4923.47, 42.06), heading = 325.0}
        },
        safe = {coords = vector3(1708.1695, 4920.8208, 41.3514), heading = 0.0},
        computer = {coords = vector3(1707.3872, 4921.6953, 42.0722), heading = 325.0}
    },
    {
        name = "24/7 Supermarket - Alhambra Drive",
        registers = {
            {coords = vector3(1959.26, 3740.0, 32.34), heading = 300.0},
            {coords = vector3(1960.13, 3741.98, 32.34), heading = 300.0}
        },
        safe = {coords = vector3(1959.0202, 3749.3291, 31.6847), heading = 0.0},
        computer = {coords = vector3(1960.0263, 3750.2978, 32.2190), heading = 300.0}
    },
    {
        name = "24/7 Supermarket - Route 68",
        registers = {
            {coords = vector3(548.05, 2671.39, 42.16), heading = 100.0},
            {coords = vector3(549.03, 2669.05, 42.16), heading = 100.0}
        },
        safe = {coords = vector3(546.5106, 2662.3266, 41.5089), heading = 0.0},
        computer = {coords = vector3(545.1868, 2661.8115, 42.0318), heading = 100.0}
    },
    {
        name = "24/7 Supermarket - Senora Freeway",
        registers = {
            {coords = vector3(2677.47, 3279.76, 55.24), heading = 330.0},
            {coords = vector3(2678.88, 3280.36, 55.24), heading = 330.0}
        },
        safe = {coords = vector3(2672.3398, 3286.8269, 54.6214), heading = 0.0},
        computer = {coords = vector3(2672.7070, 3288.2045, 55.1164), heading = 330.0}
    },
    {
        name = "Rob's Liquor - Palomino Freeway",
        registers = {
            {coords = vector3(2555.24, 380.88, 108.62), heading = 355.0},
            {coords = vector3(2557.23, 380.84, 108.62), heading = 355.0}
        },
        safe = {coords = vector3(2548.7395, 384.8841, 107.9211), heading = 0.0},
        computer = {coords = vector3(2548.4802, 386.2579, 108.4982), heading = 355.0}
    },
    {
        name = "24/7 Supermarket - Clinton Avenue",
        registers = {
            {coords = vector3(372.87, 326.86, 103.57), heading = 255.0},
            {coords = vector3(373.11, 328.64, 103.57), heading = 255.0}
        },
        safe = {coords = vector3(378.2658, 333.8557, 102.9076), heading = 0.0},
        computer = {coords = vector3(379.6751, 333.8492, 103.4417), heading = 255.0}
    },
    {
        name = "Rob's Liquor - North Rockford Drive",
        registers = {
            {coords = vector3(-1821.85, 793.84, 138.08), heading = 135.0},
            {coords = vector3(-1820.12, 792.09, 138.08), heading = 135.0}
        },
        safe = {coords = vector3(-1829.5384, 798.4634, 137.5601), heading = 0.0},
        computer = {coords = vector3(-1828.9333, 797.3793, 138.2624), heading = 135.0}
    },
    {
        name = "LTD Gasoline - Grove Street",
        registers = {
            {coords = vector3(-47.52, -1757.58, 29.42), heading = 50.0},
            {coords = vector3(-46.19, -1759.14, 29.42), heading = 50.0}
        },
        safe = {coords = vector3(-43.8009, -1748.0804, 28.7776), heading = 0.0},
        computer = {coords = vector3(-44.7806, -1748.8189, 29.4642), heading = 50.0}
    },
    {
        name = "Rob's Liquor - Ginger Street",
        registers = {
            {coords = vector3(-706.12, -913.65, 19.22), heading = 90.0},
            {coords = vector3(-706.08, -915.42, 19.22), heading = 90.0}
        },
        safe = {coords = vector3(-710.1920, -904.1401, 18.5740), heading = 0.0},
        computer = {coords = vector3(-710.4782, -905.2836, 19.2711), heading = 90.0}
    },
    {
        name = "24/7 Supermarket - Mirror Park Blvd",
        registers = {
            {coords = vector3(1164.67, -323.76, 69.21), heading = 100.0},
            {coords = vector3(1165.28, -322.78, 69.21), heading = 100.0}
        },
        safe = {coords = vector3(1159.0540, -314.1202, 68.5665), heading = 0.0},
        computer = {coords = vector3(1158.9605, -315.2624, 69.2748), heading = 100.0}
    }
}
