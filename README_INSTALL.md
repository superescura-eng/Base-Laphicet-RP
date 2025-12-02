# Instalação dos Novos Scripts Modernos

Você escolheu o caminho "Moderno/Ox". Os scripts foram baixados em `server/resources/[ Modern ]`.

## ⚠️ AÇÃO NECESSÁRIA: Banco de Dados

Para que os scripts funcionem (especialmente o de roupas), você precisa executar os seguintes arquivos SQL no seu banco de dados (via HeidiSQL ou similar):

### 1. Illenium Appearance (Roupas)
Execute todos os arquivos dentro de:
`server/resources/[ Modern ]/illenium-appearance/sql/`

- `management_outfits.sql`
- `player_outfit_codes.sql`
- `player_outfits.sql`
- `playerskins.sql`

### 2. QB Multicharacter & Garages
**CRÍTICO:** Você deve criar a tabela de veículos do QBCore.
Execute o arquivo:
`server/resources/[ Modern ]/qb-garages/player_vehicles.sql`

Isso corrigirá o erro `Table 'rbn_base.player_vehicles' doesn't exist`.

## Scripts Instalados

1.  **illenium-appearance**: Sistema de roupas avançado.
2.  **qb-multicharacter**: Tela de login e seleção de personagens.
3.  **qb-garages**: Sistema de garagens.
4.  **Popcornrp-Customs**: Sistema de Tuning (Oficina).
5.  **qb-simplefarming**: Sistema de Farm (Rotas).
6.  **qb-management**: Gestão de Facções/Sociedade.
7.  **qb-territories**: Dominação de Território.

## ⚠️ AÇÃO NECESSÁRIA: Banco de Dados

Para evitar erros, execute os SQLs abaixo:

### 1. Roupas (Obrigatório)
Pasta: `server/resources/[ Modern ]/illenium-appearance/sql/`
- Execute TODOS os arquivos .sql desta pasta.

### 3. Celular (Obrigatório)
Pasta: `server/resources/[ Modern ]/qb-phone/`
- Execute `qb-phone.sql`

### 4. Veículos (Obrigatório)
Pasta: `server/resources/[ Modern ]/qb-garages/`
- Execute `player_vehicles.sql`

*Os outros scripts (Customs, Farm, Management, Territories) usam as tabelas acima ou salvam em JSON/Config, não precisando de SQL adicional.*

## Próximos Passos
1.  Reinicie o servidor.
2.  Verifique o console (F8) para erros.
3.  Configure os preços e locais no `config.lua` de cada script conforme necessário.
