# Análise Detalhada de Componentes - BaseReborn 6.8.1

*Decomposição completa revelando dependências, funções, eventos e interações de cada script.*

## Índice
1. [System Components](#1-system-components)
2. [Scripts Compartilhados](#2-scripts-compartilhados)
3. [Reborn Scripts (Will)](#3-reborn-scripts-will)
4. [Smartphone System](#4-smartphone-system)
5. [Mapa de Dependências](#5-mapa-de-dependências)

---

## 1. SYSTEM COMPONENTS

### 1.1 vRP Core

**Caminho**: `resources/[ System ]/vrp/`  
**Versão**: 6.8.1  
**Tipo**: Server/Client/Shared

#### Estrutura
```
vrp/
├── fxmanifest.lua
├── Base_Config.lua (10KB)
├── Esx-Qbcore.lua (3.5KB)
├── base.lua (16KB)
├── server-side/ (18 arquivos)
├── client-side/ (14 arquivos)
└── config/ (7 arquivos)
```

#### Dependências
- `oxmysql`, `ox_lib`, `/server:6116`, `/onesync`

#### Server-Side (18 arquivos)

| Arquivo | Tamanho | Função |
|---------|---------|--------|
| `esx_adapter.lua` | 55KB | Compatibilidade ESX |
| `qbcore_adapter.lua` | 49KB | Compatibilidade QBCore |
| `inventory.lua` | 17KB | Sistema inventário |
| `identity.lua` | 10KB | Identidades |
| `money.lua` | 7KB | Sistema bancário |
| `group.lua` | 7KB | Permissões |

#### Client-Side (14 arquivos)

| Arquivo | Tamanho | Função |
|---------|---------|--------|
| `esx_adapter.lua` | 69KB | Bridge ESX client |
| `qbcore_adapter.lua` | 49KB | Bridge QBCore client |
| `iplloader.lua` | 36KB | Carregador IPLs |
| `garages.lua` | 16KB | Cliente garagens |

#### Provides (Simulação)
```lua
provide 'qb-core'
provide 'es_extended'
provide 'taskbar'
```

#### Funções Core
```lua
-- Server
vRP.getUserId(source)
vRP.giveInventoryItem(user_id, item, amount)
vRP.giveMoney(user_id, amount)
vRP.hasGroup(user_id, group)
```

#### Tabelas DB
- `accounts`, `characters`, `vrp_user_data`, `permissions`, `vehicles`

---

### 1.2 oxmysql

**Caminho**: `resources/[ System ]/oxmysql/`  
**Autor**: Overextended

#### Config
```cfg
set mysql_connection_string "mysql://user:pass@host/db"
set mysql_slow_query_warning 200
```

#### Exports
```lua
MySQL.query(query, params)
MySQL.insert(query, params)
```

---

### 1.3 ox_lib

**Caminho**: `resources/[ System ]/ox_lib/`

#### Módulos
- `lib.locale`, `lib.notify`, `lib.progressBar`, `lib.skillCheck`, `lib.context`

#### Uso
```lua
shared_script '@ox_lib/init.lua'
lib.notify({title = 'Test'})
```

---

## 2. SCRIPTS COMPARTILHADOS

### 2.1 ox_inventory

**Caminho**: `resources/[ Scripts ]/ox_inventory/`  
**Versão**: 2.44.1

#### Integração vRP
```lua
server_scripts {
    '@vrp/lib/utils.lua',
    '@vrp/config/Item.lua',
    '@vrp/config/Usables.lua',
}
```

#### Config
```cfg
setr inventory:framework "qb"
setr inventory:slots 50
setr inventory:weight 30000
```

#### Exports
```lua
exports.ox_inventory:AddItem(source, item, count)
exports.ox_inventory:RemoveItem(source, item, count)
```

#### Tabela DB
- `ox_inventory`

---

### 2.2 HUD, Chat, Outros

| Script | Caminho | Função |
|--------|---------|--------|
| **hud** | `[ Scripts ]/hud/` | Interface principal |
| **chat** | `[ Scripts ]/chat/` | Sistema chat |
| **ox_doorlock** | `[ Scripts ]/ox_doorlock/` | Portas |
| **bank** | `[ Scripts ]/bank/` | Banco |
| **tattoo** | `[ Scripts ]/tattoo/` | Tatuagens |

---

## 3. REBORN SCRIPTS (WILL)

### 3.1 will_login

**Caminho**: `resources/[ Reborn ]/will_login/`

#### Estrutura
```
will_login/
├── fxmanifest.lua
├── config.lua
├── server.lua
└── html/
```

#### Config
```lua
Config.Mysql = "oxmysql"
Config.Codep = "RBN"
Config.CodeNumber = 6
```

#### Sistema Indicação
```lua
Config.Away = {
    [1] = { price = 2000 },
    [2] = { price = 5000 },
    -- até [11]
}
```

#### Tabela DB
- `will_login`

---

### 3.2 will_jobs

**Caminho**: `resources/[ Reborn ]/will_jobs/`

#### Empregos (10 total)

| Nome | Veículo | XP |
|------|---------|-----|
| Lixeiro | trash | 8-12 |
| Taxi | taxi | 12 |
| Entregador | enduro | 5 |
| Lenhador | ratloader | 8 |
| Caminhoneiro | packer | 16 |
| Bombeiro | firetruk | 13 |

#### Sistema Níveis
```lua
reward = function(level)
    local levelRewards = {
        [0] = math.random(15, 20),
        [1] = math.random(20, 25),
        // ...
    }
    return levelRewards[level], XP
end
```

#### Exports
```lua
exports["will_jobs"]:addUserExp(user_id, "Lixeiro", 10)
```

#### Tabela DB
- `will_jobs`

---

### 3.3 will_garages_v2

**Caminho**: `resources/[ Reborn ]/will_garages_v2/`

#### Arquivos
- `Config.lua` (12KB)
- `Garages.lua` - Lista garagens
- `Vehicles.lua` - Lista veículos

#### Config Principal
```lua
Config.base = "creative"
Config.vehicleDB = "vehicles"
Config.SellCar = { ['Enabled'] = true, ['Porcent'] = 70 }
Config.TransferCar = true
```

#### Interiores
- `Garagem_menor`, `Garagem_media`, `Garagem_maior`, `Garagem_luxo`, `Garagem_gigante`

#### Garagens Trabalho
```lua
Config.workgarage = {
    ["Police"] = { "reborna45", "rebornc7" },
    ["Hospital"] = { "DLRS6EMS" },
}
```

#### Tabela DB
- `vehicles`

---

### 3.4 Outros Will Scripts

| Script | Função | Tabela DB |
|--------|--------|-----------|
| **will_conce_v2** | Concessionária | `vehicles` |
| **will_homes** | Casas | `will_homes` |
| **will_ficha_v3** | Ficha criminal | `will_ficha` |
| **will_shops** | Lojas players | `will_shops*` |
| **will_battlepass** | Battle pass | `will_battlepass` |
| **will_creator** | Criador char | - |
| **will_skinshop** | Loja roupa | - |

---

### 3.5 ld_* Scripts

| Script | Função |
|--------|--------|
| **ld_factions** | Painel facções |
| **ld_routes** | Rotas/crafting |
| **ld_tunners** | Tunagem |

#### Tabelas DB
- `ld_orgs`, `ld_orgs_daily`, `ld_orgs_monthly`

---

## 4. SMARTPHONE SYSTEM

### 4.1 smartphone

**Caminho**: `resources/[ Smartphone ]/smartphone/`

#### Estrutura
```
smartphone/
├── server.js (204KB Node.js!)
├── index.js (811KB bundle!)
├── client.lua
└── assets/
```

#### Apps
- Chamadas, SMS, WhatsApp
- Instagram, Twitter
- Banco, Uber, iFood
- OLX, Cassino, TOR

#### Tabelas DB
- `smartphone_*` (15+ tabelas)

---

### 4.2 pma-voice

**Função**: Voz por proximidade

---

## 5. MAPA DE DEPENDÊNCIAS

```
FiveM Server
├── oxmysql
├── ox_lib
└── vRP Core
    ├── ox_inventory
    ├── ox_target
    ├── will_login
    ├── will_jobs
    ├── will_garages_v2
    ├── will_homes
    ├── smartphone
    └── outros scripts
```

### Tabelas DB Principais

| Tabela | Script |
|--------|--------|
| `accounts` | vRP |
| `characters` | vRP |
| `vehicles` | vRP/garages |
| `ox_inventory` | ox_inventory |
| `will_*` | Will scripts |
| `ld_orgs*` | ld_factions |
| `smartphone_*` | smartphone |

---

**Total Scripts**: 50+  
**Linhas Código**: 500K+  
**Complexidade**: Alta

**Data**: Dez 2025
