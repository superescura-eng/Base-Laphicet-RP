# Documentação Completa - BaseReborn 6.8.1

## Índice
1. [Visão Geral da Arquitetura](#visão-geral-da-arquitetura)
2. [Como a Base Suporta Múltiplos Frameworks](#como-a-base-suporta-múltiplos-frameworks)
3. [Análise dos Scripts Proprietários (Will)](#análise-dos-scripts-proprietários-will)
4. [Guia Completo para Criar uma Base Virgem](#guia-completo-para-criar-uma-base-virgem)
5. [Links e Referências](#links-e-referências)

---

## Visão Geral da Arquitetura

### Estrutura do Projeto

```
BaseReborn-6.8.1/
├── server/
│   ├── resources/
│   │   ├── [ System ]       # Core framework e dependências
│   │   ├── [ Gerais ]       # Scripts gerais e farms
│   │   ├── [ QBCore ]       # Extensões QBCore
│   │   ├── [ Scripts ]      # Scripts compartilhados (ox_inventory, etc.)
│   │   ├── [ Reborn ]       # Scripts proprietários (Will)
│   │   ├── [ Smartphone ]   # Sistema de smartphone
│   │   └── [ Addons ]       # Addons adicionais
│   ├── server.cfg           # Configuração principal
│   └── ox.cfg              # Configurações oxmysql e ox_lib
├── Database/
│   └── DBRebornBase.sql    # Schema do banco de dados
└── README.md
```

### Framework Core: vRP Modificado

A BaseReborn utiliza **vRP** como framework base, mas foi **extensivamente modificado** para suportar múltiplos frameworks através de camadas de compatibilidade.

**Componentes Principais:**
- **vRP Core** (`[ System ]/vrp/`)
- **oxmysql** - Driver de banco de dados otimizado
- **ox_lib** - Biblioteca de funções reutilizáveis
- **ox_inventory** - Sistema de inventário moderno
- **ox_target** - Sistema de interação 3D

---

## Como a Base Suporta Múltiplos Frameworks

### Mecanismo de Compatibilidade

A BaseReborn consegue suportar scripts de **vRP**, **ESX** e **QBCore** através de um sistema inteligente de adaptadores e "provides":

#### 1. **Arquivo `fxmanifest.lua` do vRP**

```lua
provide 'taskbar'
provide 'qb-core'
provide 'es_extended'
provide 'spawnmanager'
provide 'sessionmanager'
```

Estas declarações `provide` fazem com que o vRP **emule** outros frameworks, permitindo que scripts escritos para QBCore ou ESX funcionem sem modificações.

#### 2. **Arquivo `Esx-Qbcore.lua`**

Este arquivo contém:
- **Configurações do QBCore** (`QBConfig`)
- **Configurações do ESX** (`Config`)
- **Tabelas de compatibilidade** (contas, notificações, etc.)

```lua
QBConfig = {}
Config = {}
ESX = {}

-- Configurações simulam ambiente QBCore/ESX
QBConfig.Money.MoneyTypes = { cash = 500, bank = 5000, crypto = 0 }
Config.OxInventory = GlobalState['Inventory'] == "ox_inventory"
```

#### 3. **Adaptadores Server e Client**

Arquivos como:
- `server-side/esx_adapter.lua`
- `server-side/qbcore_adapter.lua`
- `client-side/esx_adapter.lua`
- `client-side/qbcore_adapter.lua`

Estes arquivos **interceptam** chamadas de funções ESX/QBCore e as **traduzem** para funções vRP equivalentes.

#### 4. **Tabelas Similares no Banco de Dados**

O arquivo `Base_Config.lua` contém `Reborn.frameworkTables()` que mapeia tabelas ESX/QBCore para vRP:

```lua
Reborn.frameworkTables = function()
    return {
        -- ESX
        ['users'] = true,
        ['owned_vehicles'] = true,
        -- QBCore
        ['players'] = true,
        ['player_vehicles'] = true,
    }
end
```

### Fluxo de Compatibilidade

```mermaid
graph TD
    A[Script ESX/QBCore] --> B{Tipo de Chamada}
    B -->|Função ESX| C[esx_adapter.lua]
    B -->|Função QBCore| D[qbcore_adapter.lua]
    C --> E[Tradução para vRP]
    D --> E
    E --> F[vRP Core]
    F --> G[oxmysql + ox_lib]
    G --> H[Banco de Dados]
```

---

## Análise dos Scripts Proprietários (Will)

### Visão Geral dos Scripts Will

Todos os scripts "Will" utilizam `@vrp/lib/utils.lua` para compatibilidade com o core vRP. Eles são **proprietários** da Reborn Studios.

### Lista Completa de Scripts Will

#### 1. **will_login**
- **Função**: Sistema de login e seleção de personagens
- **Características**:
  - Suporte multi-personagem
  - Interface HTML/CSS/JS
- **Dependências**: `@vrp/lib/utils.lua`, `mysql-async`
- **Configuração**: `config.lua`

#### 2. **will_creator**
- **Função**: Criador de personagens
- **Características**: Customização completa de aparência do personagem

#### 3. **will_garages_v2**
- **Função**: Sistema de garagens
- **Características**:
  - Gerenciamento de veículos
  - Múltiplas garagens configuráveis
- **Arquivos**: `Garages.lua` (lista de garagens), `Vehicles.lua` (lista de veículos)
- **Comando admin**: `/addgarage` para criar garagens in-game

#### 4. **will_conce_v2**
- **Função**: Concessionária de veículos
- **Configuração**: `config.lua > config.veiculos`

#### 5. **will_homes**
- **Função**: Sistema de propriedades/casas
- **Banco de Dados**: Tabela `will_homes`

#### 6. **will_jobs**
- **Função**: Sistema de empregos
- **Configuração**: `Config.lua > levelRewards` (recompensas por nível)
- **Banco de Dados**: Tabela `will_jobs`

#### 7. **will_ficha_v3**
- **Função**: Sistema de ficha criminal/identidade
- **Banco de Dados**: Tabela `will_ficha`

#### 8. **will_shops**
- **Função**: Sistema de lojas
- **Banco de Dados**: `will_shops`, `will_shops_jobs`, `will_shops_stock`

#### 9. **will_skinshop**
- **Função**: Loja de roupas/customização

#### 10. **will_bateponto**
- **Função**: Sistema de ponto de trabalho

#### 11. **will_battlepass**
- **Função**: Sistema de passe de batalha
- **Banco de Dados**: Tabela `will_battlepass`

#### 12. **will_cassino_v2**
- **Função**: Sistema de cassino
- **Recursos**: Jogos de cassino diversos

#### 13. **will_grafite**
- **Função**: Sistema de grafite/spray

#### 14. **will_drugsales**
- **Função**: Sistema de venda de drogas

### Categoria [Robbery] (Roubos)

Dentro de `[ Reborn ]` há uma pasta `[Robbery]` com scripts de assaltos.

### Outros Scripts Reborn

#### **ld_factions**
- **Função**: Painel de facções
- **Configuração**: `config/config.lua`

#### **ld_routes**
- **Função**: Sistema de rotas e crafts
- **Configuração**: `config.lua`

#### **ld_tunners**
- **Função**: Sistema de tunagem

#### **domination**
- **Função**: Sistema de dominação de territórios

---

## Guia Completo para Criar uma Base Virgem

### Pré-Requisitos

#### Software Necessário

1. **Sistema Operacional**
   - Windows Server 2019+ ou Linux (Ubuntu 20.04+)

2. **Banco de Dados**
   - **MariaDB 10.5+** (recomendado) ou MySQL 8.0+
   - Download: https://mariadb.org/download/
   - **HeidiSQL** ou **MySQL Workbench** para gerenciamento

3. **FiveM Server Artifacts**
   - Download: https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/
   - Use sempre a versão recomendada mais recente

4. **Ferramentas de Desenvolvimento**
   - **Visual Studio Code**: https://code.visualstudio.com/
   - **Git** (opcional): https://git-scm.com/

5. **Chaves Necessárias**
   - **FiveM License Key**: https://keymaster.fivem.net/
   - **Steam Web API Key**: https://steamcommunity.com/dev/apikey

### Passo 1: Instalação do FiveM Server

#### Windows

1. Baixe o FiveM Server Artifacts
2. Extraia para `C:\FXServer\`
3. Estrutura esperada:
   ```
   C:\FXServer\
   ├── FXServer.exe
   ├── server.cfg (você criará)
   └── resources/
   ```

#### Linux

```bash
mkdir -p ~/FXServer/server
cd ~/FXServer/server
wget https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/[versão]/fx.tar.xz
tar xf fx.tar.xz
```

### Passo 2: Configuração do Banco de Dados

#### 2.1 Instalação do MariaDB

**Windows:**
1. Baixe e instale MariaDB
2. Durante instalação, defina senha do root
3. Inicie o serviço MariaDB

**Linux:**
```bash
sudo apt update
sudo apt install mariadb-server mariadb-client
sudo mysql_secure_installation
```

#### 2.2 Criar Banco de Dados

1. Abra HeidiSQL ou MySQL Workbench
2. Conecte ao servidor local:
   - Host: `localhost` ou `127.0.0.1`
   - User: `root`
   - Password: (sua senha)
   - Port: `3306`

3. Execute:
```sql
CREATE DATABASE rbn_base CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'fivem'@'localhost' IDENTIFIED BY 'senha_forte_aqui';
GRANT ALL PRIVILEGES ON rbn_base.* TO 'fivem'@'localhost';
FLUSH PRIVILEGES;
```

#### 2.3 Importar Schema

1. Localize `Database/DBRebornBase.sql`
2. Importe para o banco `rbn_base`
3. Verifique se todas as tabelas foram criadas

### Passo 3: Instalação dos Resources Essenciais

#### 3.1 Estrutura de Pastas

```
resources/
├── [mysql]/
│   └── oxmysql/
├── [ System ]/
│   ├── ox_lib/
│   ├── vrp/
│   ├── mapmanager/
│   ├── PolyZone/
│   └── loadingscreen_v2/
├── [ Scripts ]/
│   ├── ox_inventory/
│   ├── ox_doorlock/
│   ├── chat/
│   ├── hud/
│   └── ...
├── [ QBCore ]/
│   └── ox_target/
├── [ Gerais ]/
├── [ Reborn ]/
├── [ Smartphone ]/
└── [ Addons ]/
```

#### 3.2 Download dos Resources Base

**oxmysql:**
- GitHub: https://github.com/overextended/oxmysql/releases
- Extrair para `resources/[mysql]/oxmysql/`

**ox_lib:**
- GitHub: https://github.com/overextended/ox_lib/releases
- Extrair para `resources/[ System ]/ox_lib/`

**ox_inventory:**
- GitHub: https://github.com/overextended/ox_inventory/releases
- Extrair para `resources/[ Scripts ]/ox_inventory/`

**ox_target:**
- GitHub: https://github.com/overextended/ox_target/releases
- Extrair para `resources/[ QBCore ]/ox_target/`

**vRP:**
- BaseReborn já inclui o vRP modificado em `[ System ]/vrp/`

### Passo 4: Configuração do server.cfg

Crie `server.cfg` na raiz do servidor:

```cfg
##########################
## SYSTEM
##########################
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

##########################
## RESOURCES
##########################
ensure "[ System ]"
ensure "[ Gerais ]"
ensure "[ QBCore ]"
ensure "[ Scripts ]"
ensure "[ Smartphone ]"
ensure "[ Reborn ]"
ensure "[ Addons ]"

##########################
## ESSENTIAL
##########################
sv_scriptHookAllowed 0
sets locale pt-BR
sets tags "rp, roleplay, reborn, br, brasil, brazil"

# Configurar IP do servidor
set sv_listingIPOverride "SEU_IP_PUBLICO"
set sv_enforcegamebuild 3258

##########################
## INFORMAÇÕES DO SERVIDOR
##########################
sv_hostname "Meu Servidor BaseReborn"
sets sv_projectName "Meu Servidor"
set qb_locale pt-br
set 'esx:locale' pt-br
sv_maxclients 32

##########################
## ONESYNC
##########################
set onesync on
set sv_endpointprivacy true
set onesync_population true
set onesync_enableInfinity true
set onesync_enableBeyond true
set onesync_forceMigration true
set onesync_distanceCullVehicles true

##########################
## PERMISSION
##########################
add_ace group.admin command allow
add_ace group.admin command.quit deny
add_ace resource.vrp command.quit allow

##########################
## KEYS
##########################
set steam_webApiKey "SUA_STEAM_KEY"
sv_licenseKey SUA_FIVEM_KEY

exec ox.cfg
```

### Passo 5: Configuração do ox.cfg

Crie `ox.cfg` na raiz do servidor:

```cfg
############################
## OX MYSQL
############################

set mysql_connection_string "mysql://fivem:senha_forte_aqui@127.0.0.1/rbn_base?charset=utf8mb4"
set mysql_slow_query_warning 200
set mysql_ui true

############################
## OX LIB
############################

set 'ox:locale' 'pt-br'
setr ox:primaryColor violet
setr ox:primaryShade 5
setr ox:userLocales 1

## Permissoes
add_ace resource.ox_lib command.add_ace allow
add_ace resource.ox_lib command.remove_ace allow
add_ace resource.ox_lib command.add_principal allow
add_ace resource.ox_lib command.remove_principal allow

############################
## OX INVENTORY
############################

setr inventory:framework "qb"
setr inventory:slots 50
setr inventory:weight 30000
setr inventory:screenblur true
setr inventory:autoreload true
setr inventory:itemnotify true
setr inventory:weaponnotify true
set inventory:versioncheck true
set inventory:loglevel 1
set inventory:randomprices true
set inventory:randomloot true
```

### Passo 6: Configuração Específica da BaseReborn

#### 6.1 Configurar `Base_Config.lua`

Editar `resources/[ System ]/vrp/Base_Config.lua`:

```lua
Reborn.license = function()
    return {
        ['license'] = "SUA_LICENCA_TOKEN",
        ['ip'] = "http://SEU_IP/",
        ['porta'] = "30120",
    }
end

GlobalState['Basics'] = {
    ['ServerName'] = "Meu Servidor RP",
    ['Discord'] = "https://discord.gg/SEU_DISCORD",
    ['MaxHealth'] = 400,
    ['CityLogo'] = "URL_DO_SEU_LOGO",
    ['Identifier'] = "license",  -- ou "steam"
    ['Whitelist'] = false,
    ['Debug'] = false
}
```

#### 6.2 Configurar Webhooks (Opcional)

Editar `resources/[ System ]/vrp/config/webhooks.lua`:

- Adicione webhooks do Discord para logs

### Passo 7: Primeiro Início do Servidor

#### Windows
```cmd
cd C:\FXServer
FXServer.exe +exec server.cfg
```

#### Linux
```bash
cd ~/FXServer/server
./run.sh +exec server.cfg
```

### Passo 8: Configuração In-Game

1. **Conecte ao servidor** via FiveM
2. **Você será automaticamente admin** (se seu ID for 1)
3. **Comandos essenciais**:
   ```
   /adm - Painel de admin
   /adm2 - Configurações
   /addgarage - Criar garagens
   /group [id] [grupo] - Dar permissões
   ```

4. **Configurar grupos** em `resources/[ System ]/vrp/config/Groups.lua`

### Passo 9: Customização e Ajustes

#### 9.1 Economia

- **Salários**: `[ System ]/vrp/config/Groups.lua > (salary)`
- **Empregos**: `[ Reborn ]/will_jobs/Config.lua > (levelRewards)`
- **Veículos**: `[ Reborn ]/will_conce_v2/config.lua`

#### 9.2 Farms e Rotas

- **Farms gerais**: `[ Gerais ]/Farms/Config.lua`
- **Rotas facções**: `[ Reborn ]/ld_routes/config.lua`

#### 9.3 Inventário

- **Itens**: `[ Scripts ]/ox_inventory/data/items.lua`
- **Stashes**: `[ Scripts ]/ox_inventory/data/stashes.lua`

### Passo 10: Testes e Validação

1. **Teste criação de personagem**
2. **Teste sistema de empregos**
3. **Teste garagens e veículos**
4. **Teste inventário**
5. **Teste facções e farms**

---

## Links e Referências

### Documentação Oficial FiveM

- **FiveM Docs**: https://docs.fivem.net/docs/
- **FiveM Forum**: https://forum.cfx.re/
- **CFX Keymaster**: https://keymaster.fivem.net/
- **FiveM Artifacts**: https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/

### Frameworks

#### QBCore
- **Site Oficial**: https://qbcore.net/
- **Documentação**: https://docs.qbcore.org/qbcore-documentation
- **GitHub**: https://github.com/qbcore-framework/qb-core
- **Discord**: https://discord.gg/qbcore

#### vRP
- **Documentação Dev**: https://vrp-framework.github.io/vRP/dev/index.html
- **Documentação Estável**: https://vrp-framework.github.io/vRP/
- **GitHub Docs**: https://github.com/vRP-framework/vRP-Docs

#### ESX
- **Documentação**: https://docs.esx-framework.org/en
- **ESX Legacy**: https://docs.esx-legacy.com/en
- **Site**: https://esxfivem.com/

### Overextended (ox_lib, ox_inventory, oxmysql)

- **Documentação ox_lib**: https://overextended.dev/ox_lib
- **Documentação ox_inventory**: https://overextended.dev/ox_inventory
- **Documentação ox_target**: https://overextended.dev/ox_target
- **Documentação oxmysql**: https://coxdocs.dev/oxmysql ou https://oxmysql.com/
- **GitHub oxmysql**: https://github.com/overextended/oxmysql
- **Forum oxmysql**: https://forum.cfx.re/t/free-oxmysql-asynchronous-mysql-wrapper/4755120

### BaseReborn Específico

- **GitHub BaseReborn**: https://github.com/Reborn-Studios/BaseReborn
- **Documentação Reborn**: https://reborns-organization.gitbook.io/reborn-studios/produtos/base-reborn
- **Discord Reborn Studios**: https://discord.gg/8unYr9MUdx

### Ferramentas e Utilitários

- **FiveM Artifacts Auto-Update**: https://github.com/jgscripts/fivem-artifacts-db
- **Forum Auto-Update**: https://forum.cfx.re/t/auto-update-fivem-artifact/5170248

### Banco de Dados

- **MariaDB**: https://mariadb.org/download/
- **MySQL**: https://dev.mysql.com/downloads/mysql/
- **HeidiSQL**: https://www.heidisql.com/
- **MySQL Workbench**: https://dev.mysql.com/downloads/workbench/

### Editores e IDEs

- **Visual Studio Code**: https://code.visualstudio.com/
- **Notepad++**: https://notepad-plus-plus.org/

---

## Apêndice: Comandos de Admin

### Comandos Essenciais

| Comando | Descrição |
|---------|-----------|
| `/adm` | Painel de administração |
| `/adm2` | Painel de configurações |
| `/doorlock` | Controle de portas |
| `/debug` | Modo debug |
| `/item (item) (qtd)` | Pegar item |
| `/money (qtd)` | Pegar dinheiro |

### Comandos de Player

| Comando | Descrição |
|---------|-----------|
| `/rg (id)` | Informações do ID |
| `/group (id) (grupo)` | Setar grupo |
| `/ungroup (id) (grupo)` | Remover grupo |
| `/kick (id)` | Kickar player |
| `/ban (id)` | Banir player |
| `/wl (id)` | Liberar whitelist |

### Comandos de Veículos

| Comando | Descrição |
|---------|-----------|
| `/car (veiculo)` | Spawnar veículo |
| `/dv` | Deletar veículo próximo |
| `/fix` | Reparar veículo |
| `/addcar (id) (veiculo)` | Adicionar veículo permanente |
| `/addtempcar (id) (veiculo) (dias)` | Adicionar veículo temporário |

### Comandos de Teleporte

| Comando | Descrição |
|---------|-----------|
| `/tpcds` | TP para coordenadas |
| `/tptome (id)` | Puxar player |
| `/tpto (id)` | IR até player |
| `/tpway` | TP para marcação do mapa |

---

## Conclusão

Esta documentação fornece uma visão completa da BaseReborn e permite criar uma base virgem do zero. A arquitetura multi-framework é possível graças aos adaptadores e ao sistema de "provides" do vRP modificado.

Para suporte adicional, consulte a documentação oficial da Reborn Studios ou entre no Discord da comunidade.

**Última atualização**: Dezembro 2025  
**Versão documentada**: BaseReborn 6.8.1
