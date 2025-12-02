# SmartphoneVRP - Análise Técnica Detalhada

## Visão Geral
O **SmartphoneVRP** (identificado como parte do ecossistema **Reborn System**) é um script de celular avançado e proprietário, desenvolvido com uma arquitetura moderna separando backend (Node.js) e frontend (Web/React).

**Origem**: Reborn Studios (baseado em URLs de API encontradas: `api.rebornsystem.com.br`)
**Versão**: Integrada à BaseReborn 6.8.1

## Arquitetura Técnica

### 1. Backend (Node.js)
- **Arquivo Principal**: `server.js` (204KB, minificado/bundlado)
- **Tecnologia**: Node.js runtime do FiveM.
- **ORM Customizado**: O script implementa seu próprio Object-Relational Mapping (ORM) para interagir com o banco de dados.
  - Classes detectadas: `pe` (Query Builder), `pk` (Table Builder), `pl` (Model Wrapper).
  - **Auto-Migration**: O script possui capacidade de criar tabelas automaticamente (`create` method na classe `pl`), dispensando arquivos `.sql` manuais.
- **API Externa**: Comunica-se com `api.rebornsystem.com.br` para recursos como ringtones e notificações.

### 2. Frontend (Web)
- **Arquivo Principal**: `index.js` (811KB)
- **Tecnologia**: Provavelmente React ou Vue.js (baseado no tamanho e estrutura do bundle).
- **Assets**: Hospedados localmente em `assets/` e remotamente.

### 3. Comunicação
- **NUI Callbacks**: Comunicação bidirecional padrão Client <-> Interface.
- **WebSocket**: Configuração para `videoServer` sugere suporte a chamadas de vídeo ou streaming em tempo real via WebSocket.

## Configuração (`config.json`)

O arquivo de configuração revela integrações profundas e dependência de licenciamento.

```json
{
  "token": "MN295-YJCE4-K6F7S-M5PBE",    // Licença do produto
  "client": {
    "bankType": "fleeca",                 // Integração bancária
    "uploadServer": "Discord_Webhook",    // Upload de fotos (câmera)
    "videoServer": "ws://SeuIP:8080/",    // Servidor de vídeo/chamadas
    "case": "iphone14pro",                // Modelo visual
    "db_driver": "oxmysql"                // Driver de banco
  },
  "call_mode": "pma-voice"                // Sistema de voz utilizado
}
```

### Serviços de Emergência
Configurados manualmente no JSON:
- **Prefeitura**: 4002 8922
- **Polícia**: 190
- **Paramédico**: 192
- **Mecânico**: 0800 042

## Banco de Dados

O sistema utiliza um wrapper inteligente que suporta múltiplos drivers (`oxmysql`, `ghmattimysql`, `mysql-async`).

**Tabelas Prováveis** (Geradas automaticamente pelo ORM):
Devido à ofuscação, os nomes exatos são gerados em tempo de execução, mas a estrutura típica deste script inclui:
- `smartphone_accounts`: Contas e senhas
- `smartphone_contacts`: Lista de contatos
- `smartphone_messages`: SMS/WhatsApp
- `smartphone_instagram_posts`: Posts do Insta
- `smartphone_instagram_likes`: Likes
- `smartphone_calls`: Histórico de chamadas
- `smartphone_gallery`: Fotos tiradas

## Funcionalidades Identificadas

1.  **Sistema de Apps Exclusivos**:
    -   **Weazel News**: App de notícias com permissões de repórter.
    -   **Casino**: Jogos de aposta (limite configurável).
    -   **Instagram**: Com sistema de verificado e contas oficiais.

2.  **Integração de Voz**:
    -   Nativo com `pma-voice`.

3.  **Sistema de Câmera**:
    -   Upload direto para Discord via Webhook.

4.  **Dark Web (TOR)**:
    -   App de mercado ilegal, bloqueável para policiais.

## Dependências
1.  **oxmysql**: Para persistência de dados.
2.  **pma-voice**: Para chamadas de voz.
3.  **Conexão Internet**: Necessária para validar o token e baixar assets de som (`ring.ogg`).

## Conclusão da Análise
O **SmartphoneVRP** é um componente de alta complexidade, operando quase como uma aplicação independente dentro do FiveM. Sua dependência de um backend Node.js e validação de token externa indica ser um produto comercial licenciado (Reborn), com forte segurança contra modificações (código ofuscado). A ausência de arquivos SQL confirma o uso de um sistema moderno de auto-gestão de banco de dados.
