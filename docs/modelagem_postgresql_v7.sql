-- ==============================================================================
-- Sistema Integrado de Gestão de Almoxarifado (SIGA) - CBM MT
-- Modelagem de Dados PostgreSQL - Aprimoramentos de Custódia e Eventos
-- Data: 17 de junho de 2025
-- Autor: Sd  4bbm
-- ==============================================================================

-- ==============================================================================
-- INÍCIO: DEFINIÇÕES DE DOMÍNIOS E TIPOS ENUMERADOS (EXISTENTES E NOVOS)
-- ==============================================================================

-- Domínios (mantidos da versão anterior)
CREATE DOMAIN matricula_militar AS VARCHAR(20)
  CHECK (VALUE ~ '^[0-9]{5,10}$');
COMMENT ON DOMAIN matricula_militar IS
'Domínio para matrículas de militares, contendo de 5 a 10 dígitos numéricos. Exemplo: 123456789';

CREATE DOMAIN cpf_militar AS VARCHAR(14)
  CHECK (VALUE ~ '^[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}$');
COMMENT ON DOMAIN cpf_militar IS
'Domínio para CPF no formato XXX.XXX.XXX-XX. Exemplo: 123.456.789-00';

CREATE DOMAIN placa_viatura AS VARCHAR(8)
  CHECK (VALUE ~ '^[A-Z]{3}[0-9][A-Z][0-9]{2}$|^[A-Z]{3}-[0-9]{4}$');
COMMENT ON DOMAIN placa_viatura IS
'Domínio para placas de viaturas nos formatos Mercosul (ABC1D23) ou antigo (ABC-1234). Exemplo: ABC1D23';

CREATE DOMAIN percentual AS NUMERIC(5,2)
  CHECK (VALUE >= 0 AND VALUE <= 100);
COMMENT ON DOMAIN percentual IS
'Domínio para valores percentuais entre 0 e 100. Exemplo: 85.50';

CREATE DOMAIN codigo_material_padrao AS VARCHAR(20)
  CHECK (VALUE ~ '^[A-Z]{3}-[0-9]{4}$');
COMMENT ON DOMAIN codigo_material_padrao IS
'Domínio para códigos de material no formato ABC-1234. Exemplo: MAT-0001';

-- Tipos enumerados (mantidos e novos)
CREATE TYPE situacao_militar_enum AS ENUM (
  'ATIVO', 'LICENCIADO', 'AFASTADO', 'RESERVISTA', 'REFORMADO'
);
COMMENT ON TYPE situacao_militar_enum IS
'Estados possíveis para situação de militares. Exemplo: ATIVO';

CREATE TYPE status_operacao_enum AS ENUM (
  'PENDENTE', 'EM_ANDAMENTO', 'CONCLUIDA', 'CANCELADA', 'FALHA'
);
COMMENT ON TYPE status_operacao_enum IS
'Estados possíveis para status de operações. Exemplo: CONCLUIDA';

CREATE TYPE tipo_documento_enum AS ENUM (
  'NOTA_FISCAL', 'TERMO_DOACAO', 'TERMO_CAUTELA', 'ORDEM_SERVICO', 'OUTRO'
);
COMMENT ON TYPE tipo_documento_enum IS
'Tipos de documentos aceitos no sistema. Exemplo: NOTA_FISCAL';

CREATE TYPE situacao_material_enum AS ENUM (
  'DISPONIVEL', 'EM_USO', 'MANUTENCAO', 'BAIXADO', 'RESERVADO', 'EM_CUSTODIA_EXTERNA'
);
COMMENT ON TYPE situacao_material_enum IS
'Estados possíveis para situação de materiais, incluindo custódia externa. Exemplo: DISPONIVEL';

CREATE TYPE tipo_movimentacao_enum AS ENUM (
  'ENTRADA', 'SAIDA', 'TRANSFERENCIA', 'DEVOLUCAO', 'CONCESSAO',
  'CAUTELA', 'BAIXA', 'MANUTENCAO', 'RESERVA', 'TRANSFERENCIA_CUSTODIA'
);
COMMENT ON TYPE tipo_movimentacao_enum IS
'Tipos de movimentação de materiais, incluindo transferência de custódia. Exemplo: ENTRADA';

CREATE TYPE prioridade_notificacao_enum AS ENUM (
  'BAIXA', 'MEDIA', 'ALTA', 'CRITICA'
);
COMMENT ON TYPE prioridade_notificacao_enum IS
'Níveis de prioridade para notificações. Exemplo: ALTA';

-- NOVOS TIPOS ENUMERADOS
CREATE TYPE tipo_evento_enum AS ENUM (
  'INCIDENTE', 'CAMPANHA', 'ATIVIDADE_ROTINA', 'TREINAMENTO', 'EVENTO_SOCIAL', 'OUTRO'
);
COMMENT ON TYPE tipo_evento_enum IS
'Tipos de eventos operacionais ou atividades. Exemplo: INCIDENTE';

CREATE TYPE status_evento_enum AS ENUM (
  'PLANEJADO', 'EM_ANDAMENTO', 'CONCLUIDO', 'CANCELADO', 'SUSPENSO'
);
COMMENT ON TYPE status_evento_enum IS
'Status de um evento operacional ou atividade. Exemplo: EM_ANDAMENTO';

CREATE TYPE tipo_ocorrencia_material_enum AS ENUM (
  'AVARIA_LEVE', 'AVARIA_MODERADA', 'AVARIA_GRAVE', 'PERDA_TOTAL', 'EXTRAVIO', 'DEFEITO_FABRICACAO', 'DESGASTE_NATURAL', 'OUTRO'
);
COMMENT ON TYPE tipo_ocorrencia_material_enum IS
'Tipos de ocorrências que podem acontecer com um material. Exemplo: AVARIA_LEVE';

CREATE TYPE status_ocorrencia_material_enum AS ENUM (
  'REGISTRADA', 'EM_ANALISE', 'AGUARDANDO_REPARO', 'REPARADO', 'AGUARDANDO_SUBSTITUICAO', 'SUBSTITUIDO', 'BAIXADO_APOS_OCORRENCIA', 'RESOLVIDA_SEM_ACAO', 'ARQUIVADA'
);
COMMENT ON TYPE status_ocorrencia_material_enum IS
'Status do processo de uma ocorrência de material. Exemplo: EM_ANALISE';

-- ==============================================================================
-- TABELAS EXISTENTES (COM AJUSTES NECESSÁRIOS)
-- ==============================================================================

-- Tabela de unidades do CBM (sem alterações diretas nesta fase)
CREATE TABLE unidade_cbm (
  id_unidade SERIAL PRIMARY KEY,
  nome_unidade VARCHAR(100) NOT NULL,
  sigla_unidade VARCHAR(10) NOT NULL UNIQUE,
  endereco TEXT,
  telefone VARCHAR(20),
  email VARCHAR(100),
  comandante_id INTEGER,
  unidade_superior_id INTEGER,
  ativa BOOLEAN DEFAULT TRUE,
  informacoes_complementares JSONB,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE unidade_cbm IS 'Tabela que armazena informações das unidades do Corpo de Bombeiros Militar';
COMMENT ON COLUMN unidade_cbm.id_unidade IS 'Identificador único da unidade. Exemplo: 1';
COMMENT ON COLUMN unidade_cbm.nome_unidade IS 'Nome completo da unidade. Exemplo: 1º Batalhão de Bombeiros Militar';
COMMENT ON COLUMN unidade_cbm.sigla_unidade IS 'Sigla da unidade. Exemplo: 1ºBBM';
COMMENT ON COLUMN unidade_cbm.endereco IS 'Endereço completo da unidade. Exemplo: Rua das Flores, 123, Centro, Cuiabá-MT';
COMMENT ON COLUMN unidade_cbm.telefone IS 'Telefone de contato. Exemplo: (65) 3123-4567';
COMMENT ON COLUMN unidade_cbm.email IS 'Email institucional. Exemplo: 1bbm@bombeiros.mt.gov.br';
COMMENT ON COLUMN unidade_cbm.comandante_id IS 'ID do militar comandante da unidade (referencia militar.id_militar). Exemplo: 15';
COMMENT ON COLUMN unidade_cbm.unidade_superior_id IS 'ID da unidade hierarquicamente superior (referencia unidade_cbm.id_unidade). Exemplo: 2';
COMMENT ON COLUMN unidade_cbm.ativa IS 'Indica se a unidade está ativa. Exemplo: true';
COMMENT ON COLUMN unidade_cbm.informacoes_complementares IS 'Dados adicionais em formato JSON. Exemplo: {"especialidade": "combate_urbano", "efetivo": 120}';
COMMENT ON COLUMN unidade_cbm.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN unidade_cbm.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela de militares (sem alterações diretas nesta fase)
CREATE TABLE militar (
  id_militar SERIAL PRIMARY KEY,
  matricula matricula_militar NOT NULL UNIQUE,
  nome_completo VARCHAR(150) NOT NULL,
  nome_guerra VARCHAR(50) NOT NULL,
  cpf cpf_militar NOT NULL UNIQUE,
  posto_graduacao VARCHAR(30) NOT NULL,
  unidade_id INTEGER NOT NULL,
  situacao situacao_militar_enum DEFAULT 'ATIVO',
  data_nascimento DATE,
  telefone VARCHAR(20),
  email VARCHAR(100),
  endereco TEXT,
  data_incorporacao DATE,
  informacoes_complementares JSONB,
  ativo BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (unidade_id) REFERENCES unidade_cbm(id_unidade)
);
COMMENT ON TABLE militar IS 'Tabela que armazena informações dos militares do CBM';
COMMENT ON COLUMN militar.id_militar IS 'Identificador único do militar. Exemplo: 1';
COMMENT ON COLUMN militar.matricula IS 'Matrícula funcional do militar. Exemplo: 123456789';
COMMENT ON COLUMN militar.nome_completo IS 'Nome completo do militar. Exemplo: João Silva Santos';
COMMENT ON COLUMN militar.nome_guerra IS 'Nome de guerra do militar. Exemplo: Silva';
COMMENT ON COLUMN militar.cpf IS 'CPF do militar. Exemplo: 123.456.789-00';
COMMENT ON COLUMN militar.posto_graduacao IS 'Posto ou graduação. Exemplo: Soldado BM';
COMMENT ON COLUMN militar.unidade_id IS 'ID da unidade de lotação. Exemplo: 1';
COMMENT ON COLUMN militar.situacao IS 'Situação funcional atual. Exemplo: ATIVO';
COMMENT ON COLUMN militar.data_nascimento IS 'Data de nascimento. Exemplo: 1990-05-15';
COMMENT ON COLUMN militar.telefone IS 'Telefone de contato. Exemplo: (65) 99999-8888';
COMMENT ON COLUMN militar.email IS 'Email pessoal. Exemplo: joao.silva@email.com';
COMMENT ON COLUMN militar.endereco IS 'Endereço residencial. Exemplo: Rua A, 100, Bairro B, Cuiabá-MT';
COMMENT ON COLUMN militar.data_incorporacao IS 'Data de incorporação ao CBM. Exemplo: 2015-03-01';
COMMENT ON COLUMN militar.informacoes_complementares IS 'Informações adicionais em JSON. Exemplo: {"especialidades": ["resgate", "mergulho"], "cursos": ["CBMMT-001", "CBMMT-002"]}
';
COMMENT ON COLUMN militar.ativo IS 'Indica se o registro está ativo. Exemplo: true';
COMMENT ON COLUMN militar.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN militar.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela de almoxarifados (sem alterações diretas nesta fase)
CREATE TABLE almoxarifado (
  id_almoxarifado SERIAL PRIMARY KEY,
  nome_almoxarifado VARCHAR(100) NOT NULL,
  descricao TEXT,
  unidade_id INTEGER NOT NULL,
  responsavel_id INTEGER NOT NULL,
  endereco TEXT,
  capacidade_maxima NUMERIC(10,2),
  area_total NUMERIC(8,2),
  configuracoes_especificas JSONB,
  ativo BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (unidade_id) REFERENCES unidade_cbm(id_unidade),
  FOREIGN KEY (responsavel_id) REFERENCES militar(id_militar)
);
COMMENT ON TABLE almoxarifado IS 'Tabela que armazena informações dos almoxarifados';
COMMENT ON COLUMN almoxarifado.id_almoxarifado IS 'Identificador único do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN almoxarifado.nome_almoxarifado IS 'Nome do almoxarifado. Exemplo: Almoxarifado Central 1ºBBM';
COMMENT ON COLUMN almoxarifado.descricao IS 'Descrição detalhada. Exemplo: Almoxarifado principal para materiais de combate a incêndio';
COMMENT ON COLUMN almoxarifado.unidade_id IS 'ID da unidade proprietária. Exemplo: 1';
COMMENT ON COLUMN almoxarifado.responsavel_id IS 'ID do militar responsável. Exemplo: 5';
COMMENT ON COLUMN almoxarifado.endereco IS 'Localização física. Exemplo: Galpão A, Setor Norte, 1ºBBM';
COMMENT ON COLUMN almoxarifado.capacidade_maxima IS 'Capacidade máxima em metros cúbicos. Exemplo: 500.00';
COMMENT ON COLUMN almoxarifado.area_total IS 'Área total em metros quadrados. Exemplo: 200.50';
COMMENT ON COLUMN almoxarifado.configuracoes_especificas IS 'Configurações em JSON. Exemplo: {"temperatura_controlada": true, "umidade_max": 60, "seguranca": "nivel_2"}';
COMMENT ON COLUMN almoxarifado.ativo IS 'Indica se está ativo. Exemplo: true';
COMMENT ON COLUMN almoxarifado.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN almoxarifado.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela de localizações dentro dos almoxarifados (sem alterações diretas nesta fase)
CREATE TABLE localizacao (
  id_localizacao SERIAL PRIMARY KEY,
  almoxarifado_id INTEGER NOT NULL,
  codigo_localizacao VARCHAR(20) NOT NULL,
  descricao_localizacao VARCHAR(200),
  setor VARCHAR(50),
  prateleira VARCHAR(20),
  nivel VARCHAR(10),
  posicao VARCHAR(10),
  capacidade_maxima NUMERIC(8,2),
  restricoes_especiais JSONB,
  ativa BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (almoxarifado_id) REFERENCES almoxarifado(id_almoxarifado),
  UNIQUE(almoxarifado_id, codigo_localizacao)
);
COMMENT ON TABLE localizacao IS 'Tabela que define localizações específicas dentro dos almoxarifados';
COMMENT ON COLUMN localizacao.id_localizacao IS 'Identificador único da localização. Exemplo: 1';
COMMENT ON COLUMN localizacao.almoxarifado_id IS 'ID do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN localizacao.codigo_localizacao IS 'Código da localização. Exemplo: A01-P01-N02';
COMMENT ON COLUMN localizacao.descricao_localizacao IS 'Descrição da localização. Exemplo: Setor A, Prateleira 01, Nível 02';
COMMENT ON COLUMN localizacao.setor IS 'Setor do almoxarifado. Exemplo: A';
COMMENT ON COLUMN localizacao.prateleira IS 'Identificação da prateleira. Exemplo: P01';
COMMENT ON COLUMN localizacao.nivel IS 'Nível da prateleira. Exemplo: N02';
COMMENT ON COLUMN localizacao.posicao IS 'Posição específica. Exemplo: POS01';
COMMENT ON COLUMN localizacao.capacidade_maxima IS 'Capacidade em metros cúbicos. Exemplo: 2.50';
COMMENT ON COLUMN localizacao.restricoes_especiais IS 'Restrições em JSON. Exemplo: {"peso_max": 100, "tipo_material": ["inflamavel"], "acesso_restrito": true}';
COMMENT ON COLUMN localizacao.ativa IS 'Indica se está ativa. Exemplo: true';
COMMENT ON COLUMN localizacao.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';

-- Tabela de categorias de materiais (sem alterações diretas nesta fase)
CREATE TABLE categoria_material (
  id_categoria SERIAL PRIMARY KEY,
  nome_categoria VARCHAR(100) NOT NULL UNIQUE,
  descricao_categoria TEXT,
  categoria_pai_id INTEGER,
  nivel_hierarquia INTEGER DEFAULT 1,
  codigo_categoria VARCHAR(20) UNIQUE,
  configuracoes_especificas JSONB,
  ativa BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_pai_id) REFERENCES categoria_material(id_categoria)
);
COMMENT ON TABLE categoria_material IS 'Tabela para categorização dinâmica de materiais';
COMMENT ON COLUMN categoria_material.id_categoria IS 'Identificador único da categoria. Exemplo: 1';
COMMENT ON COLUMN categoria_material.nome_categoria IS 'Nome da categoria. Exemplo: Equipamentos de Combate a Incêndio';
COMMENT ON COLUMN categoria_material.descricao_categoria IS 'Descrição detalhada. Exemplo: Materiais utilizados especificamente para combate a incêndios urbanos e florestais';
COMMENT ON COLUMN categoria_material.categoria_pai_id IS 'ID da categoria superior. Exemplo: 2';
COMMENT ON COLUMN categoria_material.nivel_hierarquia IS 'Nível na hierarquia. Exemplo: 2';
COMMENT ON COLUMN categoria_material.codigo_categoria IS 'Código único da categoria. Exemplo: ECI-001';
COMMENT ON COLUMN categoria_material.configuracoes_especificas IS 'Configurações em JSON. Exemplo: {"requer_treinamento": true, "vida_util_anos": 10, "manutencao_periodica": "trimestral"}';
COMMENT ON COLUMN categoria_material.ativa IS 'Indica se está ativa. Exemplo: true';
COMMENT ON COLUMN categoria_material.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN categoria_material.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela de tipos de viaturas (sem alterações diretas nesta fase)
CREATE TABLE tipo_viatura (
  id_tipo_viatura SERIAL PRIMARY KEY,
  nome_tipo VARCHAR(100) NOT NULL UNIQUE,
  descricao_tipo TEXT,
  categoria_principal VARCHAR(50),
  subcategoria VARCHAR(50),
  especificacoes_tecnicas JSONB,
  requisitos_operacionais JSONB,
  ativo BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
COMMENT ON TABLE tipo_viatura IS 'Tabela para tipos de viaturas com categorização dinâmica';
COMMENT ON COLUMN tipo_viatura.id_tipo_viatura IS 'Identificador único do tipo. Exemplo: 1';
COMMENT ON COLUMN tipo_viatura.nome_tipo IS 'Nome do tipo de viatura. Exemplo: Auto Bomba Tanque';
COMMENT ON COLUMN tipo_viatura.descricao_tipo IS 'Descrição detalhada. Exemplo: Viatura para combate a incêndio com tanque de água e bomba de alta pressão';
COMMENT ON COLUMN tipo_viatura.categoria_principal IS 'Categoria principal. Exemplo: Combate a Incêndio';
COMMENT ON COLUMN tipo_viatura.subcategoria IS 'Subcategoria específica. Exemplo: Urbano';
COMMENT ON COLUMN tipo_viatura.especificacoes_tecnicas IS 'Especificações em JSON. Exemplo: {"capacidade_agua": 3000, "pressao_bomba": 150, "altura_escada": 30}';
COMMENT ON COLUMN tipo_viatura.requisitos_operacionais IS 'Requisitos em JSON. Exemplo: {"tripulacao_minima": 4, "habilitacao_requerida": ["CNH_D"], "treinamento": ["combate_incendio"]}
';
COMMENT ON COLUMN tipo_viatura.ativo IS 'Indica se está ativa. Exemplo: true';
COMMENT ON COLUMN tipo_viatura.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN tipo_viatura.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela base de materiais (sem alterações diretas nesta fase)
CREATE TABLE material_base (
  id_material SERIAL PRIMARY KEY,
  codigo_material VARCHAR(50) NOT NULL UNIQUE,
  nome_material VARCHAR(200) NOT NULL,
  descricao_material TEXT,
  categoria_id INTEGER NOT NULL,
  unidade_medida VARCHAR(20) NOT NULL,
  valor_unitario NUMERIC(12,2),
  estoque_minimo INTEGER DEFAULT 0,
  estoque_maximo INTEGER,
  situacao situacao_material_enum DEFAULT 'DISPONIVEL',
  localizacao_padrao_id INTEGER,
  observacoes TEXT,
  atributos_adicionais JSONB,
  ativo BOOLEAN DEFAULT TRUE,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (categoria_id) REFERENCES categoria_material(id_categoria),
  FOREIGN KEY (localizacao_padrao_id) REFERENCES localizacao(id_localizacao)
);
COMMENT ON TABLE material_base IS 'Tabela base para todos os tipos de materiais';
COMMENT ON COLUMN material_base.id_material IS 'Identificador único do material. Exemplo: 1';
COMMENT ON COLUMN material_base.codigo_material IS 'Código único do material. Exemplo: MAT-001-2025';
COMMENT ON COLUMN material_base.nome_material IS 'Nome do material. Exemplo: Mangueira de Incêndio 2.5 polegadas';
COMMENT ON COLUMN material_base.descricao_material IS 'Descrição detalhada. Exemplo: Mangueira de borracha sintética para combate a incêndio, diâmetro 2.5 pol, pressão máxima 150 PSI';
COMMENT ON COLUMN material_base.categoria_id IS 'ID da categoria. Exemplo: 1';
COMMENT ON COLUMN material_base.unidade_medida IS 'Unidade de medida. Exemplo: METRO';
COMMENT ON COLUMN material_base.valor_unitario IS 'Valor unitário em reais. Exemplo: 125.50';
COMMENT ON COLUMN material_base.estoque_minimo IS 'Estoque mínimo. Exemplo: 10';
COMMENT ON COLUMN material_base.estoque_maximo IS 'Estoque máximo. Exemplo: 100';
COMMENT ON COLUMN material_base.situacao IS 'Situação atual do material. Exemplo: DISPONIVEL';
COMMENT ON COLUMN material_base.localizacao_padrao_id IS 'ID da localização padrão no almoxarifado. Exemplo: 5';
COMMENT ON COLUMN material_base.observacoes IS 'Observações gerais sobre o material. Exemplo: Verificar pressão antes do uso';
COMMENT ON COLUMN material_base.atributos_adicionais IS 'Atributos em JSON. Exemplo: {"cor": "vermelha", "fabricante": "ABC Ltda", "certificacao": "INMETRO"}';
COMMENT ON COLUMN material_base.ativo IS 'Indica se o registro do material está ativo. Exemplo: true';
COMMENT ON COLUMN material_base.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN material_base.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-18 14:20:00';

-- Tabela de materiais de consumo (sem alterações diretas nesta fase)
CREATE TABLE material_consumo (
  id_material_consumo SERIAL PRIMARY KEY,
  material_base_id INTEGER NOT NULL,
  data_validade DATE,
  lote VARCHAR(50),
  fabricante VARCHAR(100),
  data_fabricacao DATE,
  instrucoes_uso TEXT,
  restricoes_armazenamento TEXT,
  FOREIGN KEY (material_base_id) REFERENCES material_base(id_material) ON DELETE CASCADE
);
COMMENT ON TABLE material_consumo IS 'Tabela específica para materiais de consumo';
COMMENT ON COLUMN material_consumo.id_material_consumo IS 'Identificador único do material de consumo. Exemplo: 1';
COMMENT ON COLUMN material_consumo.material_base_id IS 'ID do material base associado. Exemplo: 15';
COMMENT ON COLUMN material_consumo.data_validade IS 'Data de validade do material. Exemplo: 2026-12-31';
COMMENT ON COLUMN material_consumo.lote IS 'Número do lote de fabricação. Exemplo: LT2025001';
COMMENT ON COLUMN material_consumo.fabricante IS 'Nome do fabricante. Exemplo: Química Industrial ABC Ltda';
COMMENT ON COLUMN material_consumo.data_fabricacao IS 'Data de fabricação. Exemplo: 2025-01-15';
COMMENT ON COLUMN material_consumo.instrucoes_uso IS 'Instruções de uso do material. Exemplo: Aplicar em superfície limpa e seca, aguardar 5 minutos';
COMMENT ON COLUMN material_consumo.restricoes_armazenamento IS 'Restrições de armazenamento. Exemplo: Manter em local seco, temperatura entre 10°C e 30°C';

-- Tabela de materiais permanentes (AJUSTADA)
CREATE TABLE material_permanente (
  id_material_permanente SERIAL PRIMARY KEY,
  material_base_id INTEGER NOT NULL,
  numero_patrimonio VARCHAR(50) UNIQUE,
  data_aquisicao DATE,
  valor_aquisicao NUMERIC(12,2),
  vida_util_anos INTEGER,
  estado_conservacao VARCHAR(20) DEFAULT 'BOM',
  necessita_manutencao BOOLEAN DEFAULT FALSE,
  proxima_manutencao DATE,
  historico_manutencao JSONB,
  possui_ocorrencia_pendente BOOLEAN DEFAULT FALSE, -- NOVO CAMPO
  historico_ocorrencias_jsonb JSONB, -- NOVO CAMPO
  FOREIGN KEY (material_base_id) REFERENCES material_base(id_material) ON DELETE CASCADE
);
COMMENT ON TABLE material_permanente IS 'Tabela específica para materiais permanentes, com controle de ocorrências';
COMMENT ON COLUMN material_permanente.id_material_permanente IS 'Identificador único do material permanente. Exemplo: 1';
COMMENT ON COLUMN material_permanente.material_base_id IS 'ID do material base associado. Exemplo: 25';
COMMENT ON COLUMN material_permanente.numero_patrimonio IS 'Número patrimonial do material. Exemplo: CBM-MT-2025-001234';
COMMENT ON COLUMN material_permanente.data_aquisicao IS 'Data de aquisição do material. Exemplo: 2025-03-15';
COMMENT ON COLUMN material_permanente.valor_aquisicao IS 'Valor de aquisição do material. Exemplo: 15000.00';
COMMENT ON COLUMN material_permanente.vida_util_anos IS 'Vida útil estimada em anos. Exemplo: 10';
COMMENT ON COLUMN material_permanente.estado_conservacao IS 'Estado de conservação atual. Exemplo: BOM';
COMMENT ON COLUMN material_permanente.necessita_manutencao IS 'Indica se o material precisa de manutenção. Exemplo: false';
COMMENT ON COLUMN material_permanente.proxima_manutencao IS 'Data da próxima manutenção programada. Exemplo: 2025-09-15';
COMMENT ON COLUMN material_permanente.historico_manutencao IS 'Histórico de manutenções em JSON. Exemplo: [{"data": "2025-03-20", "tipo": "preventiva", "descricao": "Revisão geral"}]';
COMMENT ON COLUMN material_permanente.possui_ocorrencia_pendente IS 'Indica se há ocorrências pendentes para este material. Exemplo: true';
COMMENT ON COLUMN material_permanente.historico_ocorrencias_jsonb IS 'Histórico de ocorrências em JSON. Exemplo: [{"data": "2025-05-10", "tipo": "AVARIA_LEVE", "descricao": "Risco na pintura"}]';

-- Tabela de equipamentos (sem alterações diretas nesta fase)
CREATE TABLE equipamento (
  id_equipamento SERIAL PRIMARY KEY,
  material_base_id INTEGER NOT NULL,
  numero_serie VARCHAR(100),
  modelo VARCHAR(100),
  fabricante VARCHAR(100),
  ano_fabricacao INTEGER,
  especificacoes_tecnicas JSONB,
  manual_operacao TEXT,
  certificacoes JSONB,
  FOREIGN KEY (material_base_id) REFERENCES material_base(id_material) ON DELETE CASCADE
);
COMMENT ON TABLE equipamento IS 'Tabela específica para equipamentos';
COMMENT ON COLUMN equipamento.id_equipamento IS 'Identificador único do equipamento. Exemplo: 1';
COMMENT ON COLUMN equipamento.material_base_id IS 'ID do material base associado. Exemplo: 35';
COMMENT ON COLUMN equipamento.numero_serie IS 'Número de série do equipamento. Exemplo: EQ2025ABC123456';
COMMENT ON COLUMN equipamento.modelo IS 'Modelo do equipamento. Exemplo: Bomba Centrífuga BC-150';
COMMENT ON COLUMN equipamento.fabricante IS 'Fabricante do equipamento. Exemplo: Equipamentos Industriais XYZ Ltda';
COMMENT ON COLUMN equipamento.ano_fabricacao IS 'Ano de fabricação do equipamento. Exemplo: 2025';
COMMENT ON COLUMN equipamento.especificacoes_tecnicas IS 'Especificações técnicas em JSON. Exemplo: {"potencia": "15 HP", "vazao": "1500 L/min", "pressao": "150 PSI"}';
COMMENT ON COLUMN equipamento.manual_operacao IS 'Manual de operação do equipamento. Exemplo: 1. Verificar nível de óleo 2. Conectar mangueiras 3. Ligar equipamento';
COMMENT ON COLUMN equipamento.certificacoes IS 'Certificações do equipamento em JSON. Exemplo: {"inmetro": "12345", "iso": "ISO9001", "validade": "2027-12-31"}';

-- Tabela de viaturas (sem alterações diretas nesta fase)
CREATE TABLE viatura (
  id_viatura SERIAL PRIMARY KEY,
  material_base_id INTEGER NOT NULL,
  tipo_viatura_id INTEGER NOT NULL,
  placa placa_viatura NOT NULL UNIQUE,
  chassi VARCHAR(50) NOT NULL UNIQUE,
  renavam VARCHAR(20),
  ano_fabricacao INTEGER,
  ano_modelo INTEGER,
  cor VARCHAR(30),
  combustivel VARCHAR(20),
  quilometragem INTEGER DEFAULT 0,
  capacidade_tanque NUMERIC(6,2),
  documentacao_regular BOOLEAN DEFAULT TRUE,
  proxima_revisao DATE,
  seguro_vigente BOOLEAN DEFAULT TRUE,
  vencimento_seguro DATE,
  observacoes_viatura TEXT,
  FOREIGN KEY (material_base_id) REFERENCES material_base(id_material) ON DELETE CASCADE,
  FOREIGN KEY (tipo_viatura_id) REFERENCES tipo_viatura(id_tipo_viatura)
);
COMMENT ON TABLE viatura IS 'Tabela específica para viaturas';
COMMENT ON COLUMN viatura.id_viatura IS 'Identificador único da viatura. Exemplo: 1';
COMMENT ON COLUMN viatura.material_base_id IS 'ID do material base associado. Exemplo: 45';
COMMENT ON COLUMN viatura.tipo_viatura_id IS 'ID do tipo de viatura. Exemplo: 1';
COMMENT ON COLUMN viatura.placa IS 'Placa da viatura. Exemplo: ABC1D23';
COMMENT ON COLUMN viatura.chassi IS 'Número do chassi da viatura. Exemplo: 9BWZZZ377VT004251';
COMMENT ON COLUMN viatura.renavam IS 'Número RENAVAM da viatura. Exemplo: 12345678901';
COMMENT ON COLUMN viatura.ano_fabricacao IS 'Ano de fabricação da viatura. Exemplo: 2024';
COMMENT ON COLUMN viatura.ano_modelo IS 'Ano do modelo da viatura. Exemplo: 2025';
COMMENT ON COLUMN viatura.cor IS 'Cor da viatura. Exemplo: Vermelho';
COMMENT ON COLUMN viatura.combustivel IS 'Tipo de combustível da viatura. Exemplo: Diesel';
COMMENT ON COLUMN viatura.quilometragem IS 'Quilometragem atual da viatura. Exemplo: 15000';
COMMENT ON COLUMN viatura.capacidade_tanque IS 'Capacidade do tanque de combustível em litros. Exemplo: 200.00';
COMMENT ON COLUMN viatura.documentacao_regular IS 'Indica se a documentação da viatura está regular. Exemplo: true';
COMMENT ON COLUMN viatura.proxima_revisao IS 'Data da próxima revisão programada. Exemplo: 2025-12-15';
COMMENT ON COLUMN viatura.seguro_vigente IS 'Indica se o seguro da viatura está vigente. Exemplo: true';
COMMENT ON COLUMN viatura.vencimento_seguro IS 'Data de vencimento do seguro. Exemplo: 2025-11-30';
COMMENT ON COLUMN viatura.observacoes_viatura IS 'Observações específicas sobre a viatura. Exemplo: Equipada com escada mecânica de 30 metros';

-- Tabela de estoque atual (sem alterações diretas nesta fase)
CREATE TABLE estoque_atual (
  id_estoque SERIAL PRIMARY KEY,
  material_id INTEGER NOT NULL,
  almoxarifado_id INTEGER NOT NULL,
  localizacao_id INTEGER,
  quantidade_disponivel INTEGER NOT NULL DEFAULT 0,
  quantidade_reservada INTEGER DEFAULT 0,
  quantidade_em_manutencao INTEGER DEFAULT 0,
  quantidade_em_custodia_externa INTEGER DEFAULT 0, -- NOVO CAMPO
  valor_total NUMERIC(15,2),
  data_ultima_movimentacao TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material),
  FOREIGN KEY (almoxarifado_id) REFERENCES almoxarifado(id_almoxarifado),
  FOREIGN KEY (localizacao_id) REFERENCES localizacao(id_localizacao),
  UNIQUE(material_id, almoxarifado_id, localizacao_id)
);
COMMENT ON TABLE estoque_atual IS 'Tabela que mantém o estoque atual de materiais por localização, incluindo custódia externa';
COMMENT ON COLUMN estoque_atual.id_estoque IS 'Identificador único do registro de estoque. Exemplo: 1';
COMMENT ON COLUMN estoque_atual.material_id IS 'ID do material. Exemplo: 10';
COMMENT ON COLUMN estoque_atual.almoxarifado_id IS 'ID do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN estoque_atual.localizacao_id IS 'ID da localização específica dentro do almoxarifado. Exemplo: 5';
COMMENT ON COLUMN estoque_atual.quantidade_disponivel IS 'Quantidade disponível para uso imediato no almoxarifado. Exemplo: 50';
COMMENT ON COLUMN estoque_atual.quantidade_reservada IS 'Quantidade reservada para operações futuras. Exemplo: 5';
COMMENT ON COLUMN estoque_atual.quantidade_em_manutencao IS 'Quantidade atualmente em processo de manutenção. Exemplo: 2';
COMMENT ON COLUMN estoque_atual.quantidade_em_custodia_externa IS 'Quantidade atualmente em custódia externa (cautelada em campo). Exemplo: 3';
COMMENT ON COLUMN estoque_atual.valor_total IS 'Valor total do estoque (considerando apenas disponível). Exemplo: 6275.00';
COMMENT ON COLUMN estoque_atual.data_ultima_movimentacao IS 'Data da última movimentação registrada para este item de estoque. Exemplo: 2025-06-18 14:30:00';
COMMENT ON COLUMN estoque_atual.data_atualizacao IS 'Data da última atualização deste registro de estoque. Exemplo: 2025-06-18 14:20:00';

-- Tabela principal de operações (particionada, sem alterações diretas nesta fase)
CREATE TABLE operacao (
  id_operacao BIGSERIAL,
  numero_operacao VARCHAR(50) NOT NULL,
  tipo_movimentacao tipo_movimentacao_enum NOT NULL,
  material_id INTEGER NOT NULL,
  almoxarifado_origem_id INTEGER,
  almoxarifado_destino_id INTEGER,
  militar_responsavel_id INTEGER NOT NULL,
  militar_recebedor_id INTEGER,
  quantidade INTEGER NOT NULL,
  valor_unitario NUMERIC(12,2),
  valor_total NUMERIC(15,2),
  data_operacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_prevista_devolucao DATE,
  status status_operacao_enum DEFAULT 'PENDENTE',
  documento_tipo tipo_documento_enum,
  numero_documento VARCHAR(100),
  observacoes TEXT,
  detalhes_adicionais JSONB,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material),
  FOREIGN KEY (almoxarifado_origem_id) REFERENCES almoxarifado(id_almoxarifado),
  FOREIGN KEY (almoxarifado_destino_id) REFERENCES almoxarifado(id_almoxarifado),
  FOREIGN KEY (militar_responsavel_id) REFERENCES militar(id_militar),
  FOREIGN KEY (militar_recebedor_id) REFERENCES militar(id_militar)
) PARTITION BY RANGE (data_operacao);
COMMENT ON TABLE operacao IS 'Tabela principal de operações de movimentação (particionada por data)';
COMMENT ON COLUMN operacao.id_operacao IS 'Identificador único da operação. Exemplo: 1';
COMMENT ON COLUMN operacao.numero_operacao IS 'Número sequencial da operação. Exemplo: OP-2025-000001';
COMMENT ON COLUMN operacao.tipo_movimentacao IS 'Tipo de movimentação. Exemplo: ENTRADA';
COMMENT ON COLUMN operacao.material_id IS 'ID do material movimentado. Exemplo: 10';
COMMENT ON COLUMN operacao.almoxarifado_origem_id IS 'ID do almoxarifado de origem (se aplicável). Exemplo: 1';
COMMENT ON COLUMN operacao.almoxarifado_destino_id IS 'ID do almoxarifado de destino (se aplicável). Exemplo: 2';
COMMENT ON COLUMN operacao.militar_responsavel_id IS 'ID do militar responsável pela operação. Exemplo: 5';
COMMENT ON COLUMN operacao.militar_recebedor_id IS 'ID do militar recebedor (se aplicável). Exemplo: 8';
COMMENT ON COLUMN operacao.quantidade IS 'Quantidade de material movimentada. Exemplo: 10';
COMMENT ON COLUMN operacao.valor_unitario IS 'Valor unitário do material na operação. Exemplo: 125.50';
COMMENT ON COLUMN operacao.valor_total IS 'Valor total da operação. Exemplo: 1255.00';
COMMENT ON COLUMN operacao.data_operacao IS 'Data e hora da operação. Exemplo: 2025-06-18 14:30:00';
COMMENT ON COLUMN operacao.data_prevista_devolucao IS 'Data prevista para devolução (para cautelas, concessões). Exemplo: 2025-07-18';
COMMENT ON COLUMN operacao.status IS 'Status atual da operação. Exemplo: CONCLUIDA';
COMMENT ON COLUMN operacao.documento_tipo IS 'Tipo de documento associado (nota fiscal, termo). Exemplo: NOTA_FISCAL';
COMMENT ON COLUMN operacao.numero_documento IS 'Número do documento associado. Exemplo: NF-123456';
COMMENT ON COLUMN operacao.observacoes IS 'Observações gerais sobre a operação. Exemplo: Material para operação de combate a incêndio florestal';
COMMENT ON COLUMN operacao.detalhes_adicionais IS 'Detalhes adicionais em JSON. Exemplo: {"urgencia": "alta", "operacao_especial": "combate_florestal", "autorizacao": "CMD-001"}';
COMMENT ON COLUMN operacao.data_criacao IS 'Data de criação do registro da operação. Exemplo: 2025-06-18 14:30:00';
COMMENT ON COLUMN operacao.data_atualizacao IS 'Data da última atualização do registro da operação. Exemplo: 2025-06-18 15:45:00';

-- Tabela de detalhes de cautela (AJUSTADA)
CREATE TABLE cautela_detalhe (
  id_cautela_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  tipo_cautela VARCHAR(50) NOT NULL,
  prazo_cautela_dias INTEGER,
  responsabilidade_civil BOOLEAN DEFAULT TRUE,
  responsabilidade_penal BOOLEAN DEFAULT TRUE,
  condicoes_cautela TEXT,
  documento_cautela VARCHAR(100),
  custodia_atual_militar_id INTEGER, -- NOVO CAMPO
  data_ultima_transferencia_custodia TIMESTAMP, -- NOVO CAMPO
  detalhes_adicionais_cautela JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE,
  FOREIGN KEY (custodia_atual_militar_id) REFERENCES militar(id_militar)
);
COMMENT ON TABLE cautela_detalhe IS 'Detalhes específicos para operações de cautela, incluindo custódia atual';
COMMENT ON COLUMN cautela_detalhe.id_cautela_detalhe IS 'Identificador único do detalhe da cautela. Exemplo: 1';
COMMENT ON COLUMN cautela_detalhe.operacao_id IS 'ID da operação de cautela principal. Exemplo: 1006';
COMMENT ON COLUMN cautela_detalhe.tipo_cautela IS 'Tipo de cautela (INDIVIDUAL, COLETIVA). Exemplo: INDIVIDUAL';
COMMENT ON COLUMN cautela_detalhe.prazo_cautela_dias IS 'Prazo da cautela em dias. Exemplo: 90';
COMMENT ON COLUMN cautela_detalhe.responsabilidade_civil IS 'Indica se há responsabilidade civil. Exemplo: true';
COMMENT ON COLUMN cautela_detalhe.responsabilidade_penal IS 'Indica se há responsabilidade penal. Exemplo: true';
COMMENT ON COLUMN cautela_detalhe.condicoes_cautela IS 'Condições específicas da cautela. Exemplo: Uso pessoal e intransferível, conservação adequada, devolução ao final do período';
COMMENT ON COLUMN cautela_detalhe.documento_cautela IS 'Número do documento de cautela. Exemplo: CAU-001-2025';
COMMENT ON COLUMN cautela_detalhe.custodia_atual_militar_id IS 'ID do militar que detém a custódia atualmente (pode ser diferente do militar_recebedor_id da operação). Exemplo: 25';
COMMENT ON COLUMN cautela_detalhe.data_ultima_transferencia_custodia IS 'Data da última transferência de custódia em campo. Exemplo: 2025-06-20 10:00:00';
COMMENT ON COLUMN cautela_detalhe.detalhes_adicionais_cautela IS 'Detalhes adicionais em JSON. Exemplo: {"equipamento_individual": true, "treinamento_obrigatorio": true}';

-- Outras tabelas de detalhes de operação (entrada, saida, transferencia, etc.) mantidas como na v6.0, sem alterações diretas nesta fase.
-- (Para brevidade, não serão repetidas aqui, mas os comentários devem ser mantidos)

-- Tabela de histórico de estoque (particionada, sem alterações diretas nesta fase)
CREATE TABLE historico_estoque (
  id_historico BIGSERIAL,
  material_id INTEGER NOT NULL,
  almoxarifado_id INTEGER NOT NULL,
  data_snapshot DATE NOT NULL,
  quantidade_disponivel INTEGER NOT NULL,
  quantidade_reservada INTEGER DEFAULT 0,
  quantidade_em_manutencao INTEGER DEFAULT 0,
  quantidade_em_custodia_externa INTEGER DEFAULT 0, -- NOVO CAMPO
  valor_unitario NUMERIC(12,2),
  valor_total NUMERIC(15,2),
  observacoes TEXT,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material),
  FOREIGN KEY (almoxarifado_id) REFERENCES almoxarifado(id_almoxarifado)
) PARTITION BY RANGE (data_snapshot);
COMMENT ON TABLE historico_estoque IS 'Histórico de estoque com snapshots periódicos (particionada por trimestre), incluindo custódia externa';
COMMENT ON COLUMN historico_estoque.id_historico IS 'Identificador único do registro de histórico. Exemplo: 1';
COMMENT ON COLUMN historico_estoque.material_id IS 'ID do material. Exemplo: 10';
COMMENT ON COLUMN historico_estoque.almoxarifado_id IS 'ID do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN historico_estoque.data_snapshot IS 'Data do snapshot de estoque. Exemplo: 2025-06-30';
COMMENT ON COLUMN historico_estoque.quantidade_disponivel IS 'Quantidade disponível no almoxarifado na data. Exemplo: 45';
COMMENT ON COLUMN historico_estoque.quantidade_reservada IS 'Quantidade reservada na data. Exemplo: 5';
COMMENT ON COLUMN historico_estoque.quantidade_em_manutencao IS 'Quantidade em manutenção na data. Exemplo: 2';
COMMENT ON COLUMN historico_estoque.quantidade_em_custodia_externa IS 'Quantidade em custódia externa na data. Exemplo: 3';
COMMENT ON COLUMN historico_estoque.valor_unitario IS 'Valor unitário do material na data. Exemplo: 125.50';
COMMENT ON COLUMN historico_estoque.valor_total IS 'Valor total do estoque (disponível) na data. Exemplo: 6525.00';
COMMENT ON COLUMN historico_estoque.observacoes IS 'Observações do período do snapshot. Exemplo: Período de alta demanda devido à temporada seca';
COMMENT ON COLUMN historico_estoque.data_criacao IS 'Data de criação do registro de snapshot. Exemplo: 2025-06-30 23:59:59';

-- Tabela de log de auditoria (particionada, sem alterações diretas nesta fase)
CREATE TABLE log_auditoria (
  id_log BIGSERIAL,
  tabela_afetada VARCHAR(100) NOT NULL,
  operacao_tipo VARCHAR(20) NOT NULL,
  registro_id BIGINT,
  usuario_id INTEGER,
  dados_anteriores JSONB,
  dados_novos JSONB,
  ip_origem INET,
  user_agent TEXT,
  data_operacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  contexto_operacao JSONB,
  FOREIGN KEY (usuario_id) REFERENCES militar(id_militar)
) PARTITION BY RANGE (data_operacao);
COMMENT ON TABLE log_auditoria IS 'Log de auditoria de todas as operações críticas (particionada por mês)';
COMMENT ON COLUMN log_auditoria.id_log IS 'Identificador único do log. Exemplo: 1';
COMMENT ON COLUMN log_auditoria.tabela_afetada IS 'Nome da tabela afetada pela operação. Exemplo: material_base';
COMMENT ON COLUMN log_auditoria.operacao_tipo IS 'Tipo de operação (INSERT, UPDATE, DELETE). Exemplo: UPDATE';
COMMENT ON COLUMN log_auditoria.registro_id IS 'ID do registro afetado na tabela. Exemplo: 15';
COMMENT ON COLUMN log_auditoria.usuario_id IS 'ID do usuário (militar) que realizou a operação. Exemplo: 5';
COMMENT ON COLUMN log_auditoria.dados_anteriores IS 'Dados do registro antes da alteração (para UPDATE e DELETE). Exemplo: {"nome": "Mangueira Antiga", "valor": 100.00}';
COMMENT ON COLUMN log_auditoria.dados_novos IS 'Dados do registro após a alteração (para INSERT e UPDATE). Exemplo: {"nome": "Mangueira Nova", "valor": 125.50}';
COMMENT ON COLUMN log_auditoria.ip_origem IS 'Endereço IP de origem da requisição. Exemplo: 192.168.1.100';
COMMENT ON COLUMN log_auditoria.user_agent IS 'User agent do cliente que realizou a operação. Exemplo: Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
COMMENT ON COLUMN log_auditoria.data_operacao IS 'Data e hora da operação auditada. Exemplo: 2025-06-18 14:30:00';
COMMENT ON COLUMN log_auditoria.contexto_operacao IS 'Contexto adicional da operação em JSON. Exemplo: {"modulo": "gestao_materiais", "funcao": "atualizar_material"}';

-- Tabela de notificações (particionada, sem alterações diretas nesta fase)
CREATE TABLE notificacao (
  id_notificacao BIGSERIAL,
  tipo_notificacao VARCHAR(50) NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  mensagem TEXT NOT NULL,
  prioridade prioridade_notificacao_enum DEFAULT 'MEDIA',
  destinatario_id INTEGER,
  remetente_id INTEGER,
  lida BOOLEAN DEFAULT FALSE,
  data_leitura TIMESTAMP,
  data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  data_expiracao TIMESTAMP,
  dados_contexto JSONB,
  canal_notificacao VARCHAR(20) DEFAULT 'SISTEMA',
  FOREIGN KEY (destinatario_id) REFERENCES militar(id_militar),
  FOREIGN KEY (remetente_id) REFERENCES militar(id_militar)
) PARTITION BY RANGE (data_criacao);
COMMENT ON TABLE notificacao IS 'Sistema de notificações em tempo real (particionada por mês)';
COMMENT ON COLUMN notificacao.id_notificacao IS 'Identificador único da notificação. Exemplo: 1';
COMMENT ON COLUMN notificacao.tipo_notificacao IS 'Tipo da notificação (ESTOQUE_CRITICO, DOCUMENTO_VENCIDO). Exemplo: ESTOQUE_CRITICO';
COMMENT ON COLUMN notificacao.titulo IS 'Título da notificação. Exemplo: Estoque Crítico - Mangueira 2.5 pol';
COMMENT ON COLUMN notificacao.mensagem IS 'Mensagem completa da notificação. Exemplo: O estoque de Mangueira 2.5 pol está abaixo do nível mínimo (5 unidades)';
COMMENT ON COLUMN notificacao.prioridade IS 'Prioridade da notificação. Exemplo: ALTA';
COMMENT ON COLUMN notificacao.destinatario_id IS 'ID do militar destinatário. Exemplo: 5';
COMMENT ON COLUMN notificacao.remetente_id IS 'ID do militar ou sistema remetente. Exemplo: 1 (sistema)';
COMMENT ON COLUMN notificacao.lida IS 'Indica se a notificação foi lida. Exemplo: false';
COMMENT ON COLUMN notificacao.data_leitura IS 'Data e hora da leitura da notificação. Exemplo: 2025-06-18 15:30:00';
COMMENT ON COLUMN notificacao.data_criacao IS 'Data e hora de criação da notificação. Exemplo: 2025-06-18 14:30:00';
COMMENT ON COLUMN notificacao.data_expiracao IS 'Data e hora de expiração da notificação (se aplicável). Exemplo: 2025-06-25 14:30:00';
COMMENT ON COLUMN notificacao.dados_contexto IS 'Dados de contexto da notificação em JSON. Exemplo: {"material_id": 10, "estoque_atual": 3, "estoque_minimo": 5}';
COMMENT ON COLUMN notificacao.canal_notificacao IS 'Canal de envio da notificação (SISTEMA, EMAIL, SMS). Exemplo: EMAIL';

-- ==============================================================================
-- NOVAS TABELAS PARA A VERSÃO 7.0
-- ==============================================================================

-- Tabela para registrar transferências de custódia em campo
CREATE TABLE custodia_campo (
  id_custodia_campo SERIAL PRIMARY KEY,
  operacao_cautela_id BIGINT NOT NULL,
  material_id INTEGER NOT NULL,
  militar_origem_id INTEGER NOT NULL,
  militar_destino_id INTEGER NOT NULL,
  data_transferencia TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  local_transferencia VARCHAR(200),
  condicoes_transferencia TEXT,
  responsabilidade_transferida BOOLEAN DEFAULT TRUE,
  detalhes_adicionais JSONB,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (operacao_cautela_id) REFERENCES operacao(id_operacao) ON DELETE RESTRICT,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material) ON DELETE RESTRICT,
  FOREIGN KEY (militar_origem_id) REFERENCES militar(id_militar) ON DELETE RESTRICT,
  FOREIGN KEY (militar_destino_id) REFERENCES militar(id_militar) ON DELETE RESTRICT
);
COMMENT ON TABLE custodia_campo IS 'Registra transferências de custódia de materiais cautelados diretamente em campo (handover)';
COMMENT ON COLUMN custodia_campo.id_custodia_campo IS 'Identificador único da transferência de custódia em campo. Exemplo: 1';
COMMENT ON COLUMN custodia_campo.operacao_cautela_id IS 'ID da operação de cautela original que retirou o material do almoxarifado. Exemplo: 1006';
COMMENT ON COLUMN custodia_campo.material_id IS 'ID do material específico que está sendo transferido. Exemplo: 25';
COMMENT ON COLUMN custodia_campo.militar_origem_id IS 'ID do militar que está entregando a custódia. Exemplo: 15';
COMMENT ON COLUMN custodia_campo.militar_destino_id IS 'ID do militar que está recebendo a custódia. Exemplo: 25';
COMMENT ON COLUMN custodia_campo.data_transferencia IS 'Data e hora exata da transferência de custódia. Exemplo: 2025-06-20 10:00:00';
COMMENT ON COLUMN custodia_campo.local_transferencia IS 'Descrição do local onde a transferência ocorreu. Exemplo: Posto de Comando Avançado - Incêndio Serra Azul';
COMMENT ON COLUMN custodia_campo.condicoes_transferencia IS 'Condições do material no momento da transferência. Exemplo: Material em perfeito estado de conservação e funcionamento.';
COMMENT ON COLUMN custodia_campo.responsabilidade_transferida IS 'Indica se a responsabilidade formal pelo material foi transferida. Exemplo: true';
COMMENT ON COLUMN custodia_campo.detalhes_adicionais IS 'Informações adicionais em JSON. Exemplo: {"testemunhas": ["Sgt. Oliveira", "Cb. Costa"], "observacao": "Transferência realizada durante revezamento de equipe"}';
COMMENT ON COLUMN custodia_campo.data_criacao IS 'Data de criação do registro desta transferência. Exemplo: 2025-06-20 10:05:00';

-- Tabela para registrar eventos operacionais (incidentes, campanhas, atividades)
CREATE TABLE evento_operacional (
  id_evento SERIAL PRIMARY KEY,
  nome_evento VARCHAR(200) NOT NULL,
  tipo_evento tipo_evento_enum NOT NULL,
  data_inicio TIMESTAMP NOT NULL,
  data_fim TIMESTAMP,
  localizacao_geografica TEXT,
  descricao_evento TEXT,
  responsavel_id INTEGER,
  unidade_responsavel_id INTEGER,
  status_evento status_evento_enum DEFAULT 'PLANEJADO',
  detalhes_adicionais JSONB,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (responsavel_id) REFERENCES militar(id_militar),
  FOREIGN KEY (unidade_responsavel_id) REFERENCES unidade_cbm(id_unidade)
);
COMMENT ON TABLE evento_operacional IS 'Registra incidentes, campanhas, atividades de rotina ou outros eventos que podem demandar materiais';
COMMENT ON COLUMN evento_operacional.id_evento IS 'Identificador único do evento. Exemplo: 1';
COMMENT ON COLUMN evento_operacional.nome_evento IS 'Nome descritivo do evento. Exemplo: Operação Pantanal Seguro 2025 - Fase Julho';
COMMENT ON COLUMN evento_operacional.tipo_evento IS 'Tipo do evento. Exemplo: CAMPANHA';
COMMENT ON COLUMN evento_operacional.data_inicio IS 'Data e hora de início do evento. Exemplo: 2025-07-01 08:00:00';
COMMENT ON COLUMN evento_operacional.data_fim IS 'Data e hora de término do evento (pode ser nulo se em andamento). Exemplo: 2025-07-31 18:00:00';
COMMENT ON COLUMN evento_operacional.localizacao_geografica IS 'Descrição da área geográfica ou local do evento. Exemplo: Municípios de Poconé, Barão de Melgaço e Santo Antônio de Leverger';
COMMENT ON COLUMN evento_operacional.descricao_evento IS 'Descrição detalhada do evento. Exemplo: Campanha de combate a incêndios florestais na região do Pantanal durante o período de seca.';
COMMENT ON COLUMN evento_operacional.responsavel_id IS 'ID do militar responsável geral pelo evento. Exemplo: 50 (Comandante da Operação)';
COMMENT ON COLUMN evento_operacional.unidade_responsavel_id IS 'ID da unidade CBM principal responsável pelo evento. Exemplo: 3 (Comando Regional II)';
COMMENT ON COLUMN evento_operacional.status_evento IS 'Status atual do evento. Exemplo: EM_ANDAMENTO';
COMMENT ON COLUMN evento_operacional.detalhes_adicionais IS 'Informações adicionais em JSON. Exemplo: {"forcas_envolvidas": ["CBM MT", "IBAMA", "SEMA MT"], "recursos_alocados": {"viaturas": 15, "aeronaves": 2}, "objetivo_principal": "Reduzir área queimada em 30%"}';
COMMENT ON COLUMN evento_operacional.data_criacao IS 'Data de criação do registro do evento. Exemplo: 2025-06-15 09:00:00';
COMMENT ON COLUMN evento_operacional.data_atualizacao IS 'Data da última atualização do registro do evento. Exemplo: 2025-07-10 11:00:00';

-- Tabela de ligação para associar operações a eventos operacionais
CREATE TABLE operacao_evento (
  id_operacao_evento SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  evento_id INTEGER NOT NULL,
  data_associacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  observacao_associacao TEXT,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE,
  FOREIGN KEY (evento_id) REFERENCES evento_operacional(id_evento) ON DELETE CASCADE,
  UNIQUE(operacao_id, evento_id)
);
COMMENT ON TABLE operacao_evento IS 'Tabela de ligação para associar movimentações de materiais (operações) a eventos específicos';
COMMENT ON COLUMN operacao_evento.id_operacao_evento IS 'Identificador único da associação. Exemplo: 1';
COMMENT ON COLUMN operacao_evento.operacao_id IS 'ID da operação de movimentação de material. Exemplo: 1050';
COMMENT ON COLUMN operacao_evento.evento_id IS 'ID do evento operacional ao qual a operação está vinculada. Exemplo: 1';
COMMENT ON COLUMN operacao_evento.data_associacao IS 'Data e hora em que a associação foi feita. Exemplo: 2025-07-02 10:00:00';
COMMENT ON COLUMN operacao_evento.observacao_associacao IS 'Observação sobre a associação. Exemplo: Material destinado ao primeiro ciclo da Operação Pantanal Seguro.';

-- Tabela para registrar avaliações de materiais pelos militares
CREATE TABLE avaliacao_material (
  id_avaliacao SERIAL PRIMARY KEY,
  material_id INTEGER NOT NULL,
  militar_id INTEGER NOT NULL,
  operacao_id BIGINT, -- Opcional, para contextualizar o uso
  evento_id INTEGER, -- Opcional, para contextualizar o evento de uso
  data_avaliacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  nota_geral INTEGER NOT NULL CHECK (nota_geral >= 1 AND nota_geral <= 5),
  comentarios TEXT,
  pontos_positivos TEXT,
  pontos_negativos TEXT,
  sugestoes_melhoria TEXT,
  condicoes_uso TEXT, -- Condições em que o material foi usado (clima, terreno, intensidade)
  detalhes_adicionais JSONB,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material) ON DELETE CASCADE,
  FOREIGN KEY (militar_id) REFERENCES militar(id_militar) ON DELETE RESTRICT,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE SET NULL,
  FOREIGN KEY (evento_id) REFERENCES evento_operacional(id_evento) ON DELETE SET NULL
);
COMMENT ON TABLE avaliacao_material IS 'Registra avaliações de materiais feitas por militares após o uso';
COMMENT ON COLUMN avaliacao_material.id_avaliacao IS 'Identificador único da avaliação. Exemplo: 1';
COMMENT ON COLUMN avaliacao_material.material_id IS 'ID do material que foi avaliado. Exemplo: 35 (Bomba Costal XP-20)';
COMMENT ON COLUMN avaliacao_material.militar_id IS 'ID do militar que realizou a avaliação. Exemplo: 15 (Sd. Silva)';
COMMENT ON COLUMN avaliacao_material.operacao_id IS 'ID da operação em que o material foi utilizado (opcional). Exemplo: 1050';
COMMENT ON COLUMN avaliacao_material.evento_id IS 'ID do evento em que o material foi utilizado (opcional). Exemplo: 1 (Operação Pantanal Seguro)';
COMMENT ON COLUMN avaliacao_material.data_avaliacao IS 'Data e hora da avaliação. Exemplo: 2025-07-10 17:00:00';
COMMENT ON COLUMN avaliacao_material.nota_geral IS 'Nota geral para o material (1 a 5 estrelas). Exemplo: 4';
COMMENT ON COLUMN avaliacao_material.comentarios IS 'Comentários gerais sobre a experiência de uso. Exemplo: Equipamento robusto, mas um pouco pesado para longas jornadas.';
COMMENT ON COLUMN avaliacao_material.pontos_positivos IS 'Aspectos positivos destacados pelo militar. Exemplo: Boa autonomia da bateria, fácil de operar.';
COMMENT ON COLUMN avaliacao_material.pontos_negativos IS 'Aspectos negativos destacados pelo militar. Exemplo: Peso excessivo, bico pulverizador entope com facilidade.';
COMMENT ON COLUMN avaliacao_material.sugestoes_melhoria IS 'Sugestões para aprimoramento do material. Exemplo: Reduzir o peso, melhorar o sistema de filtragem do bico.';
COMMENT ON COLUMN avaliacao_material.condicoes_uso IS 'Descrição das condições em que o material foi utilizado. Exemplo: Combate a incêndio em vegetação rasteira, terreno acidentado, temperatura elevada (38°C).';
COMMENT ON COLUMN avaliacao_material.detalhes_adicionais IS 'Informações adicionais em JSON. Exemplo: {"duracao_uso_horas": 6, "tipo_combustivel_usado": "mistura_especifica"}';

-- Tabela para registrar ocorrências com materiais
CREATE TABLE ocorrencia_material (
  id_ocorrencia SERIAL PRIMARY KEY,
  material_id INTEGER NOT NULL,
  militar_reportante_id INTEGER NOT NULL,
  operacao_id BIGINT, -- Opcional, operação durante a qual ocorreu
  evento_id INTEGER, -- Opcional, evento durante o qual ocorreu
  data_ocorrencia TIMESTAMP NOT NULL,
  data_registro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  local_ocorrencia VARCHAR(200),
  tipo_ocorrencia tipo_ocorrencia_material_enum NOT NULL,
  descricao_ocorrencia TEXT NOT NULL,
  causa_provavel TEXT,
  condicoes_operacionais TEXT, -- Condições no momento da ocorrência
  impacto_no_material TEXT,
  providencias_imediatas TEXT,
  status_ocorrencia status_ocorrencia_material_enum DEFAULT 'REGISTRADA',
  militar_responsavel_apuracao_id INTEGER,
  data_inicio_apuracao DATE,
  data_fim_apuracao DATE,
  parecer_apuracao TEXT,
  detalhes_adicionais JSONB, -- Pode incluir fotos, testemunhas, etc.
  FOREIGN KEY (material_id) REFERENCES material_base(id_material) ON DELETE RESTRICT,
  FOREIGN KEY (militar_reportante_id) REFERENCES militar(id_militar) ON DELETE RESTRICT,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE SET NULL,
  FOREIGN KEY (evento_id) REFERENCES evento_operacional(id_evento) ON DELETE SET NULL,
  FOREIGN KEY (militar_responsavel_apuracao_id) REFERENCES militar(id_militar)
);
COMMENT ON TABLE ocorrencia_material IS 'Registra ocorrências (avarias, perdas, defeitos) com materiais durante o uso ou armazenamento';
COMMENT ON COLUMN ocorrencia_material.id_ocorrencia IS 'Identificador único da ocorrência. Exemplo: 1';
COMMENT ON COLUMN ocorrencia_material.material_id IS 'ID do material envolvido na ocorrência. Exemplo: 35 (Bomba Costal XP-20)';
COMMENT ON COLUMN ocorrencia_material.militar_reportante_id IS 'ID do militar que registrou a ocorrência. Exemplo: 15 (Sd. Silva)';
COMMENT ON COLUMN ocorrencia_material.operacao_id IS 'ID da operação em que a ocorrência se deu (opcional). Exemplo: 1050';
COMMENT ON COLUMN ocorrencia_material.evento_id IS 'ID do evento em que a ocorrência se deu (opcional). Exemplo: 1 (Operação Pantanal Seguro)';
COMMENT ON COLUMN ocorrencia_material.data_ocorrencia IS 'Data e hora exata em que a ocorrência aconteceu. Exemplo: 2025-07-09 14:30:00';
COMMENT ON COLUMN ocorrencia_material.data_registro IS 'Data e hora em que a ocorrência foi registrada no sistema. Exemplo: 2025-07-09 16:00:00';
COMMENT ON COLUMN ocorrencia_material.local_ocorrencia IS 'Descrição do local da ocorrência. Exemplo: Linha de combate Setor Alfa - Incêndio Serra Azul';
COMMENT ON COLUMN ocorrencia_material.tipo_ocorrencia IS 'Tipo da ocorrência. Exemplo: AVARIA_MODERADA';
COMMENT ON COLUMN ocorrencia_material.descricao_ocorrencia IS 'Descrição detalhada do que aconteceu. Exemplo: Durante o combate, a bomba costal caiu de uma altura de aproximadamente 1 metro, resultando em uma rachadura na carcaça do motor.';
COMMENT ON COLUMN ocorrencia_material.causa_provavel IS 'Causa provável da ocorrência. Exemplo: Queda acidental devido a terreno irregular e fumaça densa.';
COMMENT ON COLUMN ocorrencia_material.condicoes_operacionais IS 'Condições operacionais no momento. Exemplo: Combate noturno, visibilidade reduzida, equipe exausta.';
COMMENT ON COLUMN ocorrencia_material.impacto_no_material IS 'Descrição do dano ou impacto no material. Exemplo: Rachadura na carcaça do motor, vazamento de combustível. Equipamento inoperante.';
COMMENT ON COLUMN ocorrencia_material.providencias_imediatas IS 'Ações imediatas tomadas após a ocorrência. Exemplo: Equipamento retirado da linha de combate, comunicado ao chefe de equipe.';
COMMENT ON COLUMN ocorrencia_material.status_ocorrencia IS 'Status atual da ocorrência. Exemplo: EM_ANALISE';
COMMENT ON COLUMN ocorrencia_material.militar_responsavel_apuracao_id IS 'ID do militar designado para apurar a ocorrência. Exemplo: 55 (Sgt. Investigador)';
COMMENT ON COLUMN ocorrencia_material.data_inicio_apuracao IS 'Data de início da apuração. Exemplo: 2025-07-10';
COMMENT ON COLUMN ocorrencia_material.data_fim_apuracao IS 'Data de conclusão da apuração. Exemplo: 2025-07-15';
COMMENT ON COLUMN ocorrencia_material.parecer_apuracao IS 'Parecer final da apuração da ocorrência. Exemplo: Avaria acidental sem dolo. Recomenda-se reparo ou substituição.';
COMMENT ON COLUMN ocorrencia_material.detalhes_adicionais IS 'Informações adicionais em JSON. Exemplo: {"fotos_avaria": ["img1.jpg", "img2.jpg"], "testemunha_id": 22}';

-- ==============================================================================
-- CRIAÇÃO DE PARTIÇÕES INICIAIS (SE NECESSÁRIO, AJUSTAR DATAS)
-- ==============================================================================
-- (Mantido da v6.0, para brevidade não repetido, mas deve estar presente no script final)

-- ==============================================================================
-- ÍNDICES ESPECIALIZADOS (EXISTENTES E NOVOS)
-- ==============================================================================
-- (Índices da v6.0 mantidos, para brevidade não repetidos)

-- Novos Índices para as novas tabelas
CREATE INDEX idx_custodia_campo_operacao_cautela ON custodia_campo(operacao_cautela_id);
CREATE INDEX idx_custodia_campo_material ON custodia_campo(material_id);
CREATE INDEX idx_custodia_campo_militar_origem ON custodia_campo(militar_origem_id);
CREATE INDEX idx_custodia_campo_militar_destino ON custodia_campo(militar_destino_id);
CREATE INDEX idx_custodia_campo_data_transferencia ON custodia_campo(data_transferencia);

CREATE INDEX idx_evento_operacional_tipo ON evento_operacional(tipo_evento);
CREATE INDEX idx_evento_operacional_data_inicio ON evento_operacional(data_inicio);
CREATE INDEX idx_evento_operacional_status ON evento_operacional(status_evento);
CREATE INDEX idx_evento_operacional_responsavel ON evento_operacional(responsavel_id);

CREATE INDEX idx_operacao_evento_operacao ON operacao_evento(operacao_id);
CREATE INDEX idx_operacao_evento_evento ON operacao_evento(evento_id);

CREATE INDEX idx_avaliacao_material_material ON avaliacao_material(material_id);
CREATE INDEX idx_avaliacao_material_militar ON avaliacao_material(militar_id);
CREATE INDEX idx_avaliacao_material_data ON avaliacao_material(data_avaliacao);
CREATE INDEX idx_avaliacao_material_nota ON avaliacao_material(nota_geral);

CREATE INDEX idx_ocorrencia_material_material ON ocorrencia_material(material_id);
CREATE INDEX idx_ocorrencia_material_militar_reportante ON ocorrencia_material(militar_reportante_id);
CREATE INDEX idx_ocorrencia_material_data ON ocorrencia_material(data_ocorrencia);
CREATE INDEX idx_ocorrencia_material_tipo ON ocorrencia_material(tipo_ocorrencia);
CREATE INDEX idx_ocorrencia_material_status ON ocorrencia_material(status_ocorrencia);

-- ==============================================================================
-- FUNÇÕES DE PARTICIONAMENTO AUTOMÁTICO (MANTIDAS DA V6.0)
-- ==============================================================================
-- (Funções criar_proxima_particao_* mantidas, para brevidade não repetidas)

-- ==============================================================================
-- TRIGGERS DE PARTICIONAMENTO (MANTIDOS DA V6.0)
-- ==============================================================================
-- (Triggers trigger_criar_particao_* mantidos, para brevidade não repetidos)

-- ==============================================================================
-- FUNÇÕES DE NEGÓCIO E AUTOMAÇÃO (AJUSTADAS E NOVAS)
-- ==============================================================================

-- Função para atualizar estoque após operação (AJUSTADA para custódia externa)
CREATE OR REPLACE FUNCTION atualizar_estoque_operacao_v7()
RETURNS TRIGGER AS $$
DECLARE
    v_almoxarifado_id INTEGER;
BEGIN
    IF NEW.tipo_movimentacao = 'ENTRADA' THEN
        v_almoxarifado_id := NEW.almoxarifado_destino_id;
        UPDATE estoque_atual
        SET quantidade_disponivel = quantidade_disponivel + NEW.quantidade,
            valor_total = valor_total + (NEW.quantidade * NEW.valor_unitario),
            data_ultima_movimentacao = NEW.data_operacao,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE material_id = NEW.material_id AND almoxarifado_id = v_almoxarifado_id;

    ELSIF NEW.tipo_movimentacao = 'SAIDA' THEN
        v_almoxarifado_id := NEW.almoxarifado_origem_id;
        UPDATE estoque_atual
        SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade,
            data_ultima_movimentacao = NEW.data_operacao,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE material_id = NEW.material_id AND almoxarifado_id = v_almoxarifado_id;

    ELSIF NEW.tipo_movimentacao = 'CAUTELA' THEN
        v_almoxarifado_id := NEW.almoxarifado_origem_id;
        UPDATE estoque_atual
        SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade,
            quantidade_em_custodia_externa = quantidade_em_custodia_externa + NEW.quantidade,
            data_ultima_movimentacao = NEW.data_operacao,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE material_id = NEW.material_id AND almoxarifado_id = v_almoxarifado_id;

        -- Atualiza custódia atual na cautela_detalhe
        UPDATE cautela_detalhe
        SET custodia_atual_militar_id = NEW.militar_recebedor_id,
            data_ultima_transferencia_custodia = NEW.data_operacao
        WHERE operacao_id = NEW.id_operacao;

    ELSIF NEW.tipo_movimentacao = 'DEVOLUCAO' AND OLD.tipo_movimentacao = 'CAUTELA' THEN -- Devolução de cautela
        v_almoxarifado_id := NEW.almoxarifado_destino_id;
        UPDATE estoque_atual
        SET quantidade_disponivel = quantidade_disponivel + NEW.quantidade,
            quantidade_em_custodia_externa = quantidade_em_custodia_externa - NEW.quantidade,
            data_ultima_movimentacao = NEW.data_operacao,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE material_id = NEW.material_id AND almoxarifado_id = v_almoxarifado_id;

    ELSIF NEW.tipo_movimentacao = 'RESERVA' THEN
        v_almoxarifado_id := NEW.almoxarifado_origem_id;
        UPDATE estoque_atual
        SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade,
            quantidade_reservada = quantidade_reservada + NEW.quantidade,
            data_ultima_movimentacao = NEW.data_operacao,
            data_atualizacao = CURRENT_TIMESTAMP
        WHERE material_id = NEW.material_id AND almoxarifado_id = v_almoxarifado_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Remover trigger antigo e criar novo
DROP TRIGGER IF EXISTS trigger_atualizar_estoque ON operacao;
CREATE TRIGGER trigger_atualizar_estoque_v7
    AFTER INSERT OR UPDATE OF tipo_movimentacao, status ON operacao
    FOR EACH ROW
    WHEN (NEW.status = 'CONCLUIDA') -- Apenas para operações concluídas
    EXECUTE FUNCTION atualizar_estoque_operacao_v7();

-- Função para verificar estoque crítico (mantida da v6.0)
-- (Para brevidade não repetida)

-- Trigger para verificação de estoque crítico (mantido da v6.0)
-- (Para brevidade não repetido)

-- Função para auditoria automática (mantida da v6.0)
-- (Para brevidade não repetida)

-- Triggers de auditoria para tabelas críticas (mantidos e NOVOS)
-- (Triggers existentes mantidos, para brevidade não repetidos)
CREATE TRIGGER trigger_auditoria_custodia_campo
    AFTER INSERT OR UPDATE OR DELETE ON custodia_campo
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

CREATE TRIGGER trigger_auditoria_evento_operacional
    AFTER INSERT OR UPDATE OR DELETE ON evento_operacional
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

CREATE TRIGGER trigger_auditoria_avaliacao_material
    AFTER INSERT OR UPDATE OR DELETE ON avaliacao_material
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

CREATE TRIGGER trigger_auditoria_ocorrencia_material
    AFTER INSERT OR UPDATE OR DELETE ON ocorrencia_material
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

-- NOVA Função para registrar transferência de custódia em campo
CREATE OR REPLACE FUNCTION registrar_transferencia_custodia_campo(
    p_operacao_cautela_id BIGINT,
    p_material_id INTEGER,
    p_militar_origem_id INTEGER,
    p_militar_destino_id INTEGER,
    p_local_transferencia VARCHAR DEFAULT NULL,
    p_condicoes_transferencia TEXT DEFAULT NULL,
    p_detalhes_adicionais JSONB DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_custodia_campo_id INTEGER;
    v_numero_operacao_transferencia VARCHAR(50);
    v_operacao_transferencia_id BIGINT;
BEGIN
    -- 1. Inserir o registro na tabela custodia_campo
    INSERT INTO custodia_campo (
        operacao_cautela_id, material_id, militar_origem_id, militar_destino_id,
        local_transferencia, condicoes_transferencia, detalhes_adicionais
    ) VALUES (
        p_operacao_cautela_id, p_material_id, p_militar_origem_id, p_militar_destino_id,
        p_local_transferencia, p_condicoes_transferencia, p_detalhes_adicionais
    ) RETURNING id_custodia_campo INTO v_custodia_campo_id;

    -- 2. Atualizar a tabela cautela_detalhe com o novo custodiante
    UPDATE cautela_detalhe
    SET custodia_atual_militar_id = p_militar_destino_id,
        data_ultima_transferencia_custodia = CURRENT_TIMESTAMP
    WHERE operacao_id = p_operacao_cautela_id;

    -- 3. (Opcional) Registrar uma nova "operação" do tipo TRANSFERENCIA_CUSTODIA para log
    -- Isso pode ser útil para relatórios unificados de movimentações
    v_numero_operacao_transferencia := 'TC-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
                                     LPAD(nextval('seq_numero_operacao')::TEXT, 6, '0');
    INSERT INTO operacao (
        numero_operacao, tipo_movimentacao, material_id, militar_responsavel_id,
        militar_recebedor_id, quantidade, status, observacoes, detalhes_adicionais
    ) VALUES (
        v_numero_operacao_transferencia, 'TRANSFERENCIA_CUSTODIA', p_material_id, p_militar_origem_id,
        p_militar_destino_id, (SELECT quantidade FROM operacao WHERE id_operacao = p_operacao_cautela_id), 'CONCLUIDA',
        'Transferência de custódia em campo. Origem Cautela ID: ' || p_operacao_cautela_id,
        jsonb_build_object('custodia_campo_id', v_custodia_campo_id)
    ) RETURNING id_operacao INTO v_operacao_transferencia_id;

    -- 4. (Opcional) Associar esta nova operação de transferência ao mesmo evento da cautela original, se houver
    INSERT INTO operacao_evento (operacao_id, evento_id, observacao_associacao)
    SELECT v_operacao_transferencia_id, oe.evento_id, 'Transferência de custódia em campo associada ao evento original.'
    FROM operacao_evento oe
    WHERE oe.operacao_id = p_operacao_cautela_id;

    RETURN v_custodia_campo_id;
END;
$$ LANGUAGE plpgsql;

-- NOVA Função para registrar ocorrência de material
CREATE OR REPLACE FUNCTION registrar_ocorrencia_material_v7(
    p_material_id INTEGER,
    p_militar_reportante_id INTEGER,
    p_data_ocorrencia TIMESTAMP,
    p_tipo_ocorrencia tipo_ocorrencia_material_enum,
    p_descricao_ocorrencia TEXT,
    p_operacao_id BIGINT DEFAULT NULL,
    p_evento_id INTEGER DEFAULT NULL,
    p_local_ocorrencia VARCHAR DEFAULT NULL,
    p_causa_provavel TEXT DEFAULT NULL,
    p_condicoes_operacionais TEXT DEFAULT NULL,
    p_impacto_no_material TEXT DEFAULT NULL,
    p_providencias_imediatas TEXT DEFAULT NULL,
    p_detalhes_adicionais JSONB DEFAULT NULL
)
RETURNS INTEGER AS $$
DECLARE
    v_ocorrencia_id INTEGER;
BEGIN
    INSERT INTO ocorrencia_material (
        material_id, militar_reportante_id, operacao_id, evento_id, data_ocorrencia,
        local_ocorrencia, tipo_ocorrencia, descricao_ocorrencia, causa_provavel,
        condicoes_operacionais, impacto_no_material, providencias_imediatas, detalhes_adicionais
    ) VALUES (
        p_material_id, p_militar_reportante_id, p_operacao_id, p_evento_id, p_data_ocorrencia,
        p_local_ocorrencia, p_tipo_ocorrencia, p_descricao_ocorrencia, p_causa_provavel,
        p_condicoes_operacionais, p_impacto_no_material, p_providencias_imediatas, p_detalhes_adicionais
    ) RETURNING id_ocorrencia INTO v_ocorrencia_id;

    -- Atualizar status do material permanente, se aplicável
    UPDATE material_permanente
    SET possui_ocorrencia_pendente = TRUE,
        historico_ocorrencias_jsonb = COALESCE(historico_ocorrencias_jsonb, '[]'::jsonb) ||
                                      jsonb_build_object('id_ocorrencia', v_ocorrencia_id, 'data', p_data_ocorrencia, 'tipo', p_tipo_ocorrencia)
    WHERE material_base_id = p_material_id;

    -- (Opcional) Gerar notificação para o setor de logística/manutenção
    PERFORM pg_notify('nova_ocorrencia_material',
        json_build_object(
            'ocorrencia_id', v_ocorrencia_id,
            'material_id', p_material_id,
            'tipo_ocorrencia', p_tipo_ocorrencia,
            'descricao', p_descricao_ocorrencia
        )::text
    );

    RETURN v_ocorrencia_id;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- PROCEDURES PARA OPERAÇÕES ESPECIALIZADAS (EXISTENTES DA V6.0)
-- ==============================================================================
-- (Procedures entrada_rapida_material e saida_rapida_material mantidas, para brevidade não repetidas)

-- ==============================================================================
-- GESTÃO DO CICLO DE VIDA DE PARTIÇÕES (MANTIDA DA V6.0)
-- ==============================================================================
-- (Procedure manter_particoes_operacao mantida, para brevidade não repetida)
-- Adicionar procedures similares para historico_estoque, log_auditoria, notificacao se necessário.

-- ==============================================================================
-- VIEWS ORIENTADAS AO USUÁRIO (AJUSTADAS E NOVAS)
-- ==============================================================================

-- View para consulta simplificada de materiais (AJUSTADA para incluir custódia externa)
CREATE OR REPLACE VIEW vw_materiais_geral AS
SELECT
    mb.id_material,
    mb.codigo_material,
    mb.nome_material,
    mb.descricao_material,
    cm.nome_categoria,
    mb.unidade_medida,
    mb.valor_unitario,
    ea.quantidade_disponivel,
    ea.quantidade_reservada,
    ea.quantidade_em_manutencao,
    ea.quantidade_em_custodia_externa, -- NOVO
    a.nome_almoxarifado,
    l.codigo_localizacao,
    mb.situacao,
    (SELECT AVG(av.nota_geral) FROM avaliacao_material av WHERE av.material_id = mb.id_material) as media_avaliacao, -- NOVO
    (SELECT COUNT(*) FROM ocorrencia_material om WHERE om.material_id = mb.id_material AND om.status_ocorrencia NOT IN ('RESOLVIDA_SEM_ACAO', 'ARQUIVADA')) as ocorrencias_pendentes -- NOVO
FROM material_base mb
JOIN categoria_material cm ON mb.categoria_id = cm.id_categoria
LEFT JOIN estoque_atual ea ON mb.id_material = ea.material_id
LEFT JOIN almoxarifado a ON ea.almoxarifado_id = a.id_almoxarifado
LEFT JOIN localizacao l ON ea.localizacao_id = l.id_localizacao
WHERE mb.ativo = TRUE;
COMMENT ON VIEW vw_materiais_geral IS 'View geral de materiais, incluindo quantidades em custódia externa, média de avaliação e ocorrências pendentes';

-- View para operações recentes (AJUSTADA para incluir eventos)
CREATE OR REPLACE VIEW vw_operacoes_recentes_com_eventos AS
SELECT
    o.id_operacao,
    o.numero_operacao,
    o.tipo_movimentacao,
    mb.nome_material,
    o.quantidade,
    o.valor_total,
    o.data_operacao,
    o.status,
    mr.nome_guerra as responsavel,
    ao.nome_almoxarifado as almoxarifado_origem,
    ad.nome_almoxarifado as almoxarifado_destino,
    eo.nome_evento, -- NOVO
    eo.tipo_evento -- NOVO
FROM operacao o
JOIN material_base mb ON o.material_id = mb.id_material
JOIN militar mr ON o.militar_responsavel_id = mr.id_militar
LEFT JOIN almoxarifado ao ON o.almoxarifado_origem_id = ao.id_almoxarifado
LEFT JOIN almoxarifado ad ON o.almoxarifado_destino_id = ad.id_almoxarifado
LEFT JOIN operacao_evento oe_link ON o.id_operacao = oe_link.operacao_id -- NOVO
LEFT JOIN evento_operacional eo ON oe_link.evento_id = eo.id_evento -- NOVO
WHERE o.data_operacao >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.data_operacao DESC;
COMMENT ON VIEW vw_operacoes_recentes_com_eventos IS 'View para consulta de operações dos últimos 30 dias, incluindo informações de eventos associados';

-- NOVA View para rastreabilidade de custódia em campo
CREATE OR REPLACE VIEW vw_rastreabilidade_custodia_campo AS
SELECT
    cc.id_custodia_campo,
    op_cautela.numero_operacao AS numero_cautela_original,
    mb.codigo_material,
    mb.nome_material,
    m_origem.nome_guerra AS militar_entregou,
    m_destino.nome_guerra AS militar_recebeu,
    cc.data_transferencia,
    cc.local_transferencia,
    cc.condicoes_transferencia,
    cd.custodia_atual_militar_id,
    m_atual.nome_guerra AS militar_custodia_atual
FROM custodia_campo cc
JOIN operacao op_cautela ON cc.operacao_cautela_id = op_cautela.id_operacao
JOIN material_base mb ON cc.material_id = mb.id_material
JOIN militar m_origem ON cc.militar_origem_id = m_origem.id_militar
JOIN militar m_destino ON cc.militar_destino_id = m_destino.id_militar
LEFT JOIN cautela_detalhe cd ON op_cautela.id_operacao = cd.operacao_id
LEFT JOIN militar m_atual ON cd.custodia_atual_militar_id = m_atual.id_militar
ORDER BY cc.operacao_cautela_id, cc.data_transferencia;
COMMENT ON VIEW vw_rastreabilidade_custodia_campo IS 'View para rastrear a cadeia de transferências de custódia de materiais em campo';

-- NOVA View para consumo de materiais por evento
CREATE OR REPLACE VIEW vw_consumo_material_por_evento AS
SELECT
    eo.id_evento,
    eo.nome_evento,
    eo.tipo_evento,
    mb.id_material,
    mb.codigo_material,
    mb.nome_material,
    SUM(op.quantidade) AS quantidade_total_movimentada,
    COUNT(DISTINCT op.id_operacao) AS numero_operacoes_associadas
FROM evento_operacional eo
JOIN operacao_evento oe_link ON eo.id_evento = oe_link.evento_id
JOIN operacao op ON oe_link.operacao_id = op.id_operacao
JOIN material_base mb ON op.material_id = mb.id_material
WHERE op.tipo_movimentacao IN ('SAIDA', 'CAUTELA', 'BAIXA') -- Considerar movimentações de consumo
GROUP BY eo.id_evento, eo.nome_evento, eo.tipo_evento, mb.id_material, mb.codigo_material, mb.nome_material
ORDER BY eo.nome_evento, mb.nome_material;
COMMENT ON VIEW vw_consumo_material_por_evento IS 'View para consolidar o consumo de materiais agrupado por evento operacional';

-- ==============================================================================
-- SEQUENCES AUXILIARES (MANTIDA DA V6.0)
-- ==============================================================================
-- (Sequence seq_numero_operacao mantida, para brevidade não repetida)

-- ==============================================================================
-- CONFIGURAÇÕES DE SISTEMA (MANTIDAS DA V6.0)
-- ==============================================================================
-- (Configurações de JSONB e particionamento mantidas, para brevidade não repetidas)

-- ==============================================================================
-- FIM DA MODELAGEM POSTGRESQL
-- ==============================================================================

-- Comentário final sobre a modelagem
COMMENT ON DATABASE postgres IS 'Sistema Integrado de Gestão de Almoxarifado (SIGA) - CBM MT - Modelagem de Dados PostgreSQL com funcionalidades avançadas de custódia em campo, vinculação a eventos, avaliação de materiais e registro de ocorrências.';
