# Hospedagem - Documentação SIGA CBM-MT

## Informações do Servidor

| Item | Valor |
|------|-------|
| **IP** | 147.93.10.78 |
| **Porta** | 8090 |
| **URL de Acesso** | http://147.93.10.78:8090/ |
| **Caminho no servidor** | `/opt/siga-docs/` |
| **Container** | `siga-docs` (nginx:alpine) |
| **Docker Compose** | `/opt/siga-docs/docker-compose.yml` |

## Acesso SSH ao Servidor

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78
```

## Arquitetura da Hospedagem

O site de documentação do SIGA roda em um container Docker **completamente independente** do AGI.Smart:

```
┌─────────────────────────────────────────────────┐
│  Servidor Hostinger (147.93.10.78)              │
│                                                  │
│  ┌──────────────────────┐  ┌──────────────────┐ │
│  │  AGI.Smart (Docker)  │  │  SIGA Docs       │ │
│  │  Portas: 80, 443     │  │  Porta: 8090     │ │
│  │  /opt/agismart/      │  │  /opt/siga-docs/ │ │
│  │  Rede própria        │  │  Rede própria    │ │
│  └──────────────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────┘
```

- Redes Docker isoladas (sem comunicação entre eles)
- Volumes independentes
- Nenhuma menção ou dependência do AGI.Smart

## Estrutura no Servidor

```
/opt/siga-docs/
├── docker-compose.yml      # Configuração do container
├── nginx.conf              # Config do Nginx
├── index.html              # Página inicial
├── modulos.html            # Módulos do sistema
├── arquitetura.html        # Arquitetura técnica
├── diagramas.html          # Galeria de diagramas
├── processos.html          # Processos de negócio
├── seguranca.html          # Segurança e LGPD
├── downloads.html          # Central de downloads
├── css/custom.css          # Estilos customizados
├── js/                     # app.js, diagrams.js, processes.js
├── images/                 # 28 diagramas PNG + logo
└── docs/                   # PDFs, SQLs, documentação
```

## Comandos de Operação

### Verificar se o container está rodando

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "docker ps --filter name=siga-docs"
```

### Ver logs do container

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "docker logs siga-docs --tail 50"
```

### Reiniciar o container

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose restart"
```

### Parar o container

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose down"
```

### Subir o container (se estiver parado)

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose up -d"
```

## Atualizar o Site

Quando fizer alterações nos arquivos locais em `002_site_doc_siga/`:

### 1. Enviar todos os arquivos atualizados

```bash
scp -i C:/Users/walin/.ssh/id_ed25519 -r \
  "e:/Users/walin/Documents/siga-website/002_site_doc_siga/"* \
  root@147.93.10.78:/opt/siga-docs/
```

### 2. Reiniciar o container para aplicar

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose restart"
```

### Atualizar apenas um arquivo específico

```bash
# Exemplo: atualizar só o index.html
scp -i C:/Users/walin/.ssh/id_ed25519 \
  "e:/Users/walin/Documents/siga-website/002_site_doc_siga/index.html" \
  root@147.93.10.78:/opt/siga-docs/index.html

# Reiniciar
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose restart"
```

## Repositório GitHub

| Item | Valor |
|------|-------|
| **Repo** | https://github.com/walingsonCostaUnemat/doc_siga_cbm |
| **Branch** | main |

## Troubleshooting

### Container não inicia

```bash
# Ver logs de erro
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "docker logs siga-docs"
```

### Porta 8090 em uso

```bash
# Verificar o que está usando a porta
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "ss -tlnp | grep 8090"
```

### Testar se o site responde internamente

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "curl -s -o /dev/null -w '%{http_code}' http://localhost:8090/"
```

### Reconstruir o container do zero

```bash
ssh -i C:/Users/walin/.ssh/id_ed25519 root@147.93.10.78 \
  "cd /opt/siga-docs && docker compose down && docker compose up -d"
```
