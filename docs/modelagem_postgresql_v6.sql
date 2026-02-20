-- ==============================================================================
-- Sistema Integrado de Gestão de Almoxarifado (SIGA) - CBM MT
-- Versão 6.0 - Modelagem de Dados PostgreSQL COMPLETA
-- Data: 17 de junho de 2025
-- Autor: Manus AI
-- ==============================================================================

-- ==============================================================================
-- INÍCIO: DEFINIÇÕES DE DOMÍNIOS E TIPOS ENUMERADOS
-- ==============================================================================

-- Domínios para validação de formatos específicos
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

-- Tipos enumerados para validação de estados
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
  'DISPONIVEL', 'EM_USO', 'MANUTENCAO', 'BAIXADO', 'RESERVADO'
);
COMMENT ON TYPE situacao_material_enum IS
'Estados possíveis para situação de materiais. Exemplo: DISPONIVEL';

CREATE TYPE tipo_movimentacao_enum AS ENUM (
  'ENTRADA', 'SAIDA', 'TRANSFERENCIA', 'DEVOLUCAO', 'CONCESSAO',
  'CAUTELA', 'BAIXA', 'MANUTENCAO', 'RESERVA'
);
COMMENT ON TYPE tipo_movimentacao_enum IS
'Tipos de movimentação de materiais. Exemplo: ENTRADA';

CREATE TYPE prioridade_notificacao_enum AS ENUM (
  'BAIXA', 'MEDIA', 'ALTA', 'CRITICA'
);
COMMENT ON TYPE prioridade_notificacao_enum IS
'Níveis de prioridade para notificações. Exemplo: ALTA';

-- ==============================================================================
-- TABELAS DE CONFIGURAÇÃO E SEGURANÇA
-- ==============================================================================

-- Tabela de unidades do CBM
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
COMMENT ON COLUMN unidade_cbm.comandante_id IS 'ID do militar comandante da unidade. Exemplo: 15';
COMMENT ON COLUMN unidade_cbm.unidade_superior_id IS 'ID da unidade hierarquicamente superior. Exemplo: 2';
COMMENT ON COLUMN unidade_cbm.ativa IS 'Indica se a unidade está ativa. Exemplo: true';
COMMENT ON COLUMN unidade_cbm.informacoes_complementares IS 'Dados adicionais em formato JSON. Exemplo: {"especialidade": "combate_urbano", "efetivo": 120}';
COMMENT ON COLUMN unidade_cbm.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN unidade_cbm.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela de militares
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
COMMENT ON COLUMN militar.informacoes_complementares IS 'Informações adicionais em JSON. Exemplo: {"especialidades": ["resgate", "mergulho"], "cursos": ["CBMMT-001", "CBMMT-002"]}';
COMMENT ON COLUMN militar.ativo IS 'Indica se o registro está ativo. Exemplo: true';
COMMENT ON COLUMN militar.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN militar.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela de almoxarifados
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
COMMENT ON COLUMN almoxarifado.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela de localizações dentro dos almoxarifados
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

-- ==============================================================================
-- TABELAS DE CATEGORIZAÇÃO DINÂMICA
-- ==============================================================================

-- Tabela de categorias de materiais (dinâmica)
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
COMMENT ON COLUMN categoria_material.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela de tipos de viaturas (dinâmica)
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
COMMENT ON COLUMN tipo_viatura.requisitos_operacionais IS 'Requisitos em JSON. Exemplo: {"tripulacao_minima": 4, "habilitacao_requerida": ["CNH_D"], "treinamento": ["combate_incendio"]}';
COMMENT ON COLUMN tipo_viatura.ativo IS 'Indica se está ativo. Exemplo: true';
COMMENT ON COLUMN tipo_viatura.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN tipo_viatura.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- ==============================================================================
-- TABELAS DE MATERIAIS
-- ==============================================================================

-- Tabela base de materiais
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
COMMENT ON COLUMN material_base.situacao IS 'Situação atual. Exemplo: DISPONIVEL';
COMMENT ON COLUMN material_base.localizacao_padrao_id IS 'ID da localização padrão. Exemplo: 5';
COMMENT ON COLUMN material_base.observacoes IS 'Observações gerais. Exemplo: Verificar pressão antes do uso';
COMMENT ON COLUMN material_base.atributos_adicionais IS 'Atributos em JSON. Exemplo: {"cor": "vermelha", "fabricante": "ABC Ltda", "certificacao": "INMETRO"}';
COMMENT ON COLUMN material_base.ativo IS 'Indica se está ativo. Exemplo: true';
COMMENT ON COLUMN material_base.data_criacao IS 'Data de criação do registro. Exemplo: 2025-01-15 10:30:00';
COMMENT ON COLUMN material_base.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela de materiais de consumo
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

COMMENT ON COLUMN material_consumo.id_material_consumo IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN material_consumo.material_base_id IS 'ID do material base. Exemplo: 15';
COMMENT ON COLUMN material_consumo.data_validade IS 'Data de validade. Exemplo: 2026-12-31';
COMMENT ON COLUMN material_consumo.lote IS 'Número do lote. Exemplo: LT2025001';
COMMENT ON COLUMN material_consumo.fabricante IS 'Nome do fabricante. Exemplo: Química Industrial ABC Ltda';
COMMENT ON COLUMN material_consumo.data_fabricacao IS 'Data de fabricação. Exemplo: 2025-01-15';
COMMENT ON COLUMN material_consumo.instrucoes_uso IS 'Instruções de uso. Exemplo: Aplicar em superfície limpa e seca, aguardar 5 minutos';
COMMENT ON COLUMN material_consumo.restricoes_armazenamento IS 'Restrições de armazenamento. Exemplo: Manter em local seco, temperatura entre 10°C e 30°C';

-- Tabela de materiais permanentes
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
  FOREIGN KEY (material_base_id) REFERENCES material_base(id_material) ON DELETE CASCADE
);

COMMENT ON TABLE material_permanente IS 'Tabela específica para materiais permanentes';

COMMENT ON COLUMN material_permanente.id_material_permanente IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN material_permanente.material_base_id IS 'ID do material base. Exemplo: 25';
COMMENT ON COLUMN material_permanente.numero_patrimonio IS 'Número patrimonial. Exemplo: CBM-MT-2025-001234';
COMMENT ON COLUMN material_permanente.data_aquisicao IS 'Data de aquisição. Exemplo: 2025-03-15';
COMMENT ON COLUMN material_permanente.valor_aquisicao IS 'Valor de aquisição. Exemplo: 15000.00';
COMMENT ON COLUMN material_permanente.vida_util_anos IS 'Vida útil em anos. Exemplo: 10';
COMMENT ON COLUMN material_permanente.estado_conservacao IS 'Estado de conservação. Exemplo: BOM';
COMMENT ON COLUMN material_permanente.necessita_manutencao IS 'Indica se precisa manutenção. Exemplo: false';
COMMENT ON COLUMN material_permanente.proxima_manutencao IS 'Data da próxima manutenção. Exemplo: 2025-09-15';
COMMENT ON COLUMN material_permanente.historico_manutencao IS 'Histórico em JSON. Exemplo: [{"data": "2025-03-20", "tipo": "preventiva", "descricao": "Revisão geral"}]';

-- Tabela de equipamentos
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

COMMENT ON COLUMN equipamento.id_equipamento IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN equipamento.material_base_id IS 'ID do material base. Exemplo: 35';
COMMENT ON COLUMN equipamento.numero_serie IS 'Número de série. Exemplo: EQ2025ABC123456';
COMMENT ON COLUMN equipamento.modelo IS 'Modelo do equipamento. Exemplo: Bomba Centrífuga BC-150';
COMMENT ON COLUMN equipamento.fabricante IS 'Fabricante. Exemplo: Equipamentos Industriais XYZ Ltda';
COMMENT ON COLUMN equipamento.ano_fabricacao IS 'Ano de fabricação. Exemplo: 2025';
COMMENT ON COLUMN equipamento.especificacoes_tecnicas IS 'Especificações em JSON. Exemplo: {"potencia": "15 HP", "vazao": "1500 L/min", "pressao": "150 PSI"}';
COMMENT ON COLUMN equipamento.manual_operacao IS 'Manual de operação. Exemplo: 1. Verificar nível de óleo 2. Conectar mangueiras 3. Ligar equipamento';
COMMENT ON COLUMN equipamento.certificacoes IS 'Certificações em JSON. Exemplo: {"inmetro": "12345", "iso": "ISO9001", "validade": "2027-12-31"}';

-- Tabela de viaturas
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

COMMENT ON COLUMN viatura.id_viatura IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN viatura.material_base_id IS 'ID do material base. Exemplo: 45';
COMMENT ON COLUMN viatura.tipo_viatura_id IS 'ID do tipo de viatura. Exemplo: 1';
COMMENT ON COLUMN viatura.placa IS 'Placa da viatura. Exemplo: ABC1D23';
COMMENT ON COLUMN viatura.chassi IS 'Número do chassi. Exemplo: 9BWZZZ377VT004251';
COMMENT ON COLUMN viatura.renavam IS 'Número RENAVAM. Exemplo: 12345678901';
COMMENT ON COLUMN viatura.ano_fabricacao IS 'Ano de fabricação. Exemplo: 2024';
COMMENT ON COLUMN viatura.ano_modelo IS 'Ano do modelo. Exemplo: 2025';
COMMENT ON COLUMN viatura.cor IS 'Cor da viatura. Exemplo: Vermelho';
COMMENT ON COLUMN viatura.combustivel IS 'Tipo de combustível. Exemplo: Diesel';
COMMENT ON COLUMN viatura.quilometragem IS 'Quilometragem atual. Exemplo: 15000';
COMMENT ON COLUMN viatura.capacidade_tanque IS 'Capacidade do tanque em litros. Exemplo: 200.00';
COMMENT ON COLUMN viatura.documentacao_regular IS 'Documentação em dia. Exemplo: true';
COMMENT ON COLUMN viatura.proxima_revisao IS 'Data da próxima revisão. Exemplo: 2025-12-15';
COMMENT ON COLUMN viatura.seguro_vigente IS 'Seguro vigente. Exemplo: true';
COMMENT ON COLUMN viatura.vencimento_seguro IS 'Vencimento do seguro. Exemplo: 2025-11-30';
COMMENT ON COLUMN viatura.observacoes_viatura IS 'Observações específicas. Exemplo: Equipada com escada mecânica de 30 metros';

-- ==============================================================================
-- TABELAS DE ESTOQUE E MOVIMENTAÇÃO
-- ==============================================================================

-- Tabela de estoque atual
CREATE TABLE estoque_atual (
  id_estoque SERIAL PRIMARY KEY,
  material_id INTEGER NOT NULL,
  almoxarifado_id INTEGER NOT NULL,
  localizacao_id INTEGER,
  quantidade_disponivel INTEGER NOT NULL DEFAULT 0,
  quantidade_reservada INTEGER DEFAULT 0,
  quantidade_em_manutencao INTEGER DEFAULT 0,
  valor_total NUMERIC(15,2),
  data_ultima_movimentacao TIMESTAMP,
  data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material),
  FOREIGN KEY (almoxarifado_id) REFERENCES almoxarifado(id_almoxarifado),
  FOREIGN KEY (localizacao_id) REFERENCES localizacao(id_localizacao),
  UNIQUE(material_id, almoxarifado_id, localizacao_id)
);

COMMENT ON TABLE estoque_atual IS 'Tabela que mantém o estoque atual de materiais por localização';

COMMENT ON COLUMN estoque_atual.id_estoque IS 'Identificador único do registro de estoque. Exemplo: 1';
COMMENT ON COLUMN estoque_atual.material_id IS 'ID do material. Exemplo: 10';
COMMENT ON COLUMN estoque_atual.almoxarifado_id IS 'ID do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN estoque_atual.localizacao_id IS 'ID da localização específica. Exemplo: 5';
COMMENT ON COLUMN estoque_atual.quantidade_disponivel IS 'Quantidade disponível para uso. Exemplo: 50';
COMMENT ON COLUMN estoque_atual.quantidade_reservada IS 'Quantidade reservada. Exemplo: 5';
COMMENT ON COLUMN estoque_atual.quantidade_em_manutencao IS 'Quantidade em manutenção. Exemplo: 2';
COMMENT ON COLUMN estoque_atual.valor_total IS 'Valor total do estoque. Exemplo: 6275.00';
COMMENT ON COLUMN estoque_atual.data_ultima_movimentacao IS 'Data da última movimentação. Exemplo: 2025-06-15 14:30:00';
COMMENT ON COLUMN estoque_atual.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 14:20:00';

-- Tabela principal de operações (particionada)
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
COMMENT ON COLUMN operacao.almoxarifado_origem_id IS 'ID do almoxarifado de origem. Exemplo: 1';
COMMENT ON COLUMN operacao.almoxarifado_destino_id IS 'ID do almoxarifado de destino. Exemplo: 2';
COMMENT ON COLUMN operacao.militar_responsavel_id IS 'ID do militar responsável. Exemplo: 5';
COMMENT ON COLUMN operacao.militar_recebedor_id IS 'ID do militar recebedor. Exemplo: 8';
COMMENT ON COLUMN operacao.quantidade IS 'Quantidade movimentada. Exemplo: 10';
COMMENT ON COLUMN operacao.valor_unitario IS 'Valor unitário. Exemplo: 125.50';
COMMENT ON COLUMN operacao.valor_total IS 'Valor total da operação. Exemplo: 1255.00';
COMMENT ON COLUMN operacao.data_operacao IS 'Data e hora da operação. Exemplo: 2025-06-17 14:30:00';
COMMENT ON COLUMN operacao.data_prevista_devolucao IS 'Data prevista para devolução. Exemplo: 2025-07-17';
COMMENT ON COLUMN operacao.status IS 'Status atual da operação. Exemplo: CONCLUIDA';
COMMENT ON COLUMN operacao.documento_tipo IS 'Tipo de documento. Exemplo: NOTA_FISCAL';
COMMENT ON COLUMN operacao.numero_documento IS 'Número do documento. Exemplo: NF-123456';
COMMENT ON COLUMN operacao.observacoes IS 'Observações da operação. Exemplo: Material para operação de combate a incêndio florestal';
COMMENT ON COLUMN operacao.detalhes_adicionais IS 'Detalhes em JSON. Exemplo: {"urgencia": "alta", "operacao_especial": "combate_florestal", "autorizacao": "CMD-001"}';
COMMENT ON COLUMN operacao.data_criacao IS 'Data de criação do registro. Exemplo: 2025-06-17 14:30:00';
COMMENT ON COLUMN operacao.data_atualizacao IS 'Data da última atualização. Exemplo: 2025-06-17 15:45:00';

-- ==============================================================================
-- TABELAS DE DETALHES DE OPERAÇÕES
-- ==============================================================================

-- Tabela de detalhes de entrada
CREATE TABLE entrada_detalhe (
  id_entrada_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  fornecedor VARCHAR(200),
  nota_fiscal VARCHAR(50),
  data_nota_fiscal DATE,
  valor_nota_fiscal NUMERIC(15,2),
  condicoes_armazenamento TEXT,
  data_validade DATE,
  lote VARCHAR(50),
  certificado_qualidade VARCHAR(100),
  detalhes_adicionais_entrada JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE entrada_detalhe IS 'Detalhes específicos para operações de entrada';

COMMENT ON COLUMN entrada_detalhe.id_entrada_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN entrada_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1001';
COMMENT ON COLUMN entrada_detalhe.fornecedor IS 'Nome do fornecedor. Exemplo: Equipamentos de Segurança ABC Ltda';
COMMENT ON COLUMN entrada_detalhe.nota_fiscal IS 'Número da nota fiscal. Exemplo: 123456';
COMMENT ON COLUMN entrada_detalhe.data_nota_fiscal IS 'Data da nota fiscal. Exemplo: 2025-06-15';
COMMENT ON COLUMN entrada_detalhe.valor_nota_fiscal IS 'Valor total da nota fiscal. Exemplo: 15000.00';
COMMENT ON COLUMN entrada_detalhe.condicoes_armazenamento IS 'Condições de armazenamento. Exemplo: Local seco, temperatura entre 15°C e 25°C';
COMMENT ON COLUMN entrada_detalhe.data_validade IS 'Data de validade do material. Exemplo: 2027-06-15';
COMMENT ON COLUMN entrada_detalhe.lote IS 'Número do lote. Exemplo: LT2025001';
COMMENT ON COLUMN entrada_detalhe.certificado_qualidade IS 'Número do certificado. Exemplo: CQ-2025-001';
COMMENT ON COLUMN entrada_detalhe.detalhes_adicionais_entrada IS 'Detalhes em JSON. Exemplo: {"inspecao_recebimento": "aprovado", "responsavel_inspecao": "João Silva"}';

-- Tabela de detalhes de saída
CREATE TABLE saida_detalhe (
  id_saida_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  finalidade VARCHAR(200) NOT NULL,
  local_utilizacao VARCHAR(200),
  data_prevista_retorno DATE,
  responsavel_retirada_id INTEGER,
  autorizacao_superior VARCHAR(100),
  condicoes_uso TEXT,
  detalhes_adicionais_saida JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE,
  FOREIGN KEY (responsavel_retirada_id) REFERENCES militar(id_militar)
);

COMMENT ON TABLE saida_detalhe IS 'Detalhes específicos para operações de saída';

COMMENT ON COLUMN saida_detalhe.id_saida_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN saida_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1002';
COMMENT ON COLUMN saida_detalhe.finalidade IS 'Finalidade da retirada. Exemplo: Operação de combate a incêndio florestal';
COMMENT ON COLUMN saida_detalhe.local_utilizacao IS 'Local de utilização. Exemplo: Fazenda São João, Chapada dos Guimarães';
COMMENT ON COLUMN saida_detalhe.data_prevista_retorno IS 'Data prevista de retorno. Exemplo: 2025-06-20';
COMMENT ON COLUMN saida_detalhe.responsavel_retirada_id IS 'ID do responsável pela retirada. Exemplo: 15';
COMMENT ON COLUMN saida_detalhe.autorizacao_superior IS 'Autorização do superior. Exemplo: AUT-CMD-001-2025';
COMMENT ON COLUMN saida_detalhe.condicoes_uso IS 'Condições de uso. Exemplo: Utilizar conforme manual técnico, verificar equipamentos antes do uso';
COMMENT ON COLUMN saida_detalhe.detalhes_adicionais_saida IS 'Detalhes em JSON. Exemplo: {"urgencia": "alta", "equipe": ["Silva", "Santos", "Oliveira"]}';

-- Tabela de detalhes de transferência
CREATE TABLE transferencia_detalhe (
  id_transferencia_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  motivo_transferencia VARCHAR(200) NOT NULL,
  responsavel_origem_id INTEGER NOT NULL,
  responsavel_destino_id INTEGER NOT NULL,
  data_envio TIMESTAMP,
  data_recebimento TIMESTAMP,
  condicoes_transporte TEXT,
  documento_transferencia VARCHAR(100),
  detalhes_adicionais_transferencia JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE,
  FOREIGN KEY (responsavel_origem_id) REFERENCES militar(id_militar),
  FOREIGN KEY (responsavel_destino_id) REFERENCES militar(id_militar)
);

COMMENT ON TABLE transferencia_detalhe IS 'Detalhes específicos para operações de transferência';

COMMENT ON COLUMN transferencia_detalhe.id_transferencia_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN transferencia_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1003';
COMMENT ON COLUMN transferencia_detalhe.motivo_transferencia IS 'Motivo da transferência. Exemplo: Redistribuição de estoque entre unidades';
COMMENT ON COLUMN transferencia_detalhe.responsavel_origem_id IS 'ID do responsável na origem. Exemplo: 10';
COMMENT ON COLUMN transferencia_detalhe.responsavel_destino_id IS 'ID do responsável no destino. Exemplo: 20';
COMMENT ON COLUMN transferencia_detalhe.data_envio IS 'Data e hora do envio. Exemplo: 2025-06-17 08:00:00';
COMMENT ON COLUMN transferencia_detalhe.data_recebimento IS 'Data e hora do recebimento. Exemplo: 2025-06-17 14:30:00';
COMMENT ON COLUMN transferencia_detalhe.condicoes_transporte IS 'Condições de transporte. Exemplo: Transporte em viatura oficial, material protegido contra umidade';
COMMENT ON COLUMN transferencia_detalhe.documento_transferencia IS 'Documento da transferência. Exemplo: GT-001-2025';
COMMENT ON COLUMN transferencia_detalhe.detalhes_adicionais_transferencia IS 'Detalhes em JSON. Exemplo: {"veiculo_transporte": "ABC1234", "motorista": "José Silva"}';

-- Tabela de detalhes de devolução
CREATE TABLE devolucao_detalhe (
  id_devolucao_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  operacao_origem_id BIGINT,
  motivo_devolucao VARCHAR(200) NOT NULL,
  estado_material VARCHAR(50) DEFAULT 'BOM',
  avarias_identificadas TEXT,
  necessita_manutencao BOOLEAN DEFAULT FALSE,
  valor_desconto NUMERIC(12,2) DEFAULT 0,
  detalhes_adicionais_devolucao JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE,
  FOREIGN KEY (operacao_origem_id) REFERENCES operacao(id_operacao)
);

COMMENT ON TABLE devolucao_detalhe IS 'Detalhes específicos para operações de devolução';

COMMENT ON COLUMN devolucao_detalhe.id_devolucao_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN devolucao_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1004';
COMMENT ON COLUMN devolucao_detalhe.operacao_origem_id IS 'ID da operação original. Exemplo: 1002';
COMMENT ON COLUMN devolucao_detalhe.motivo_devolucao IS 'Motivo da devolução. Exemplo: Fim da operação, material não utilizado';
COMMENT ON COLUMN devolucao_detalhe.estado_material IS 'Estado do material devolvido. Exemplo: BOM';
COMMENT ON COLUMN devolucao_detalhe.avarias_identificadas IS 'Avarias identificadas. Exemplo: Pequeno risco na lateral, sem comprometer funcionalidade';
COMMENT ON COLUMN devolucao_detalhe.necessita_manutencao IS 'Indica se precisa manutenção. Exemplo: false';
COMMENT ON COLUMN devolucao_detalhe.valor_desconto IS 'Valor de desconto por avarias. Exemplo: 50.00';
COMMENT ON COLUMN devolucao_detalhe.detalhes_adicionais_devolucao IS 'Detalhes em JSON. Exemplo: {"inspecao_devolucao": "aprovado", "responsavel_inspecao": "Maria Santos"}';

-- Tabela de detalhes de concessão
CREATE TABLE concessao_detalhe (
  id_concessao_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  tipo_concessao VARCHAR(50) NOT NULL,
  prazo_concessao_dias INTEGER,
  valor_concessao NUMERIC(12,2),
  garantia_exigida NUMERIC(12,2),
  condicoes_concessao TEXT,
  documento_concessao VARCHAR(100),
  detalhes_adicionais_concessao JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE concessao_detalhe IS 'Detalhes específicos para operações de concessão';

COMMENT ON COLUMN concessao_detalhe.id_concessao_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN concessao_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1005';
COMMENT ON COLUMN concessao_detalhe.tipo_concessao IS 'Tipo de concessão. Exemplo: TEMPORARIA';
COMMENT ON COLUMN concessao_detalhe.prazo_concessao_dias IS 'Prazo em dias. Exemplo: 30';
COMMENT ON COLUMN concessao_detalhe.valor_concessao IS 'Valor da concessão. Exemplo: 500.00';
COMMENT ON COLUMN concessao_detalhe.garantia_exigida IS 'Valor da garantia. Exemplo: 1000.00';
COMMENT ON COLUMN concessao_detalhe.condicoes_concessao IS 'Condições da concessão. Exemplo: Uso exclusivo para atividades institucionais, devolução em perfeito estado';
COMMENT ON COLUMN concessao_detalhe.documento_concessao IS 'Documento da concessão. Exemplo: TC-001-2025';
COMMENT ON COLUMN concessao_detalhe.detalhes_adicionais_concessao IS 'Detalhes em JSON. Exemplo: {"finalidade": "treinamento", "local_uso": "Centro de Treinamento"}';

-- Tabela de detalhes de cautela
CREATE TABLE cautela_detalhe (
  id_cautela_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  tipo_cautela VARCHAR(50) NOT NULL,
  prazo_cautela_dias INTEGER,
  responsabilidade_civil BOOLEAN DEFAULT TRUE,
  responsabilidade_penal BOOLEAN DEFAULT TRUE,
  condicoes_cautela TEXT,
  documento_cautela VARCHAR(100),
  detalhes_adicionais_cautela JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE cautela_detalhe IS 'Detalhes específicos para operações de cautela';

COMMENT ON COLUMN cautela_detalhe.id_cautela_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN cautela_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1006';
COMMENT ON COLUMN cautela_detalhe.tipo_cautela IS 'Tipo de cautela. Exemplo: INDIVIDUAL';
COMMENT ON COLUMN cautela_detalhe.prazo_cautela_dias IS 'Prazo em dias. Exemplo: 90';
COMMENT ON COLUMN cautela_detalhe.responsabilidade_civil IS 'Responsabilidade civil. Exemplo: true';
COMMENT ON COLUMN cautela_detalhe.responsabilidade_penal IS 'Responsabilidade penal. Exemplo: true';
COMMENT ON COLUMN cautela_detalhe.condicoes_cautela IS 'Condições da cautela. Exemplo: Uso pessoal e intransferível, conservação adequada, devolução ao final do período';
COMMENT ON COLUMN cautela_detalhe.documento_cautela IS 'Documento da cautela. Exemplo: CAU-001-2025';
COMMENT ON COLUMN cautela_detalhe.detalhes_adicionais_cautela IS 'Detalhes em JSON. Exemplo: {"equipamento_individual": true, "treinamento_obrigatorio": true}';

-- Tabela de detalhes de baixa
CREATE TABLE baixa_detalhe (
  id_baixa_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  motivo_baixa VARCHAR(200) NOT NULL,
  tipo_baixa VARCHAR(50) NOT NULL,
  valor_residual NUMERIC(12,2) DEFAULT 0,
  destino_material VARCHAR(200),
  documento_baixa VARCHAR(100),
  aprovacao_superior VARCHAR(100),
  laudo_tecnico TEXT,
  detalhes_adicionais_baixa JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE baixa_detalhe IS 'Detalhes específicos para operações de baixa';

COMMENT ON COLUMN baixa_detalhe.id_baixa_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN baixa_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1007';
COMMENT ON COLUMN baixa_detalhe.motivo_baixa IS 'Motivo da baixa. Exemplo: Material danificado irreversivelmente em operação';
COMMENT ON COLUMN baixa_detalhe.tipo_baixa IS 'Tipo de baixa. Exemplo: INUTILIZACAO';
COMMENT ON COLUMN baixa_detalhe.valor_residual IS 'Valor residual. Exemplo: 0.00';
COMMENT ON COLUMN baixa_detalhe.destino_material IS 'Destino do material. Exemplo: Descarte ambientalmente correto';
COMMENT ON COLUMN baixa_detalhe.documento_baixa IS 'Documento da baixa. Exemplo: TB-001-2025';
COMMENT ON COLUMN baixa_detalhe.aprovacao_superior IS 'Aprovação superior. Exemplo: AUT-CMD-002-2025';
COMMENT ON COLUMN baixa_detalhe.laudo_tecnico IS 'Laudo técnico. Exemplo: Material apresenta danos estruturais que impedem uso seguro';
COMMENT ON COLUMN baixa_detalhe.detalhes_adicionais_baixa IS 'Detalhes em JSON. Exemplo: {"comissao_baixa": ["João Silva", "Maria Santos"], "data_inspecao": "2025-06-15"}';

-- Tabela de detalhes de manutenção
CREATE TABLE manutencao_detalhe (
  id_manutencao_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  tipo_manutencao VARCHAR(50) NOT NULL,
  empresa_manutencao VARCHAR(200),
  data_inicio_manutencao DATE,
  data_fim_manutencao DATE,
  custo_manutencao NUMERIC(12,2),
  descricao_servicos TEXT,
  garantia_servico_dias INTEGER,
  documento_manutencao VARCHAR(100),
  detalhes_adicionais_manutencao JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE manutencao_detalhe IS 'Detalhes específicos para operações de manutenção';

COMMENT ON COLUMN manutencao_detalhe.id_manutencao_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN manutencao_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1008';
COMMENT ON COLUMN manutencao_detalhe.tipo_manutencao IS 'Tipo de manutenção. Exemplo: PREVENTIVA';
COMMENT ON COLUMN manutencao_detalhe.empresa_manutencao IS 'Empresa responsável. Exemplo: Manutenção Técnica ABC Ltda';
COMMENT ON COLUMN manutencao_detalhe.data_inicio_manutencao IS 'Data de início. Exemplo: 2025-06-10';
COMMENT ON COLUMN manutencao_detalhe.data_fim_manutencao IS 'Data de fim. Exemplo: 2025-06-12';
COMMENT ON COLUMN manutencao_detalhe.custo_manutencao IS 'Custo da manutenção. Exemplo: 1500.00';
COMMENT ON COLUMN manutencao_detalhe.descricao_servicos IS 'Descrição dos serviços. Exemplo: Revisão geral, troca de filtros, calibração de equipamentos';
COMMENT ON COLUMN manutencao_detalhe.garantia_servico_dias IS 'Garantia em dias. Exemplo: 180';
COMMENT ON COLUMN manutencao_detalhe.documento_manutencao IS 'Documento da manutenção. Exemplo: OS-001-2025';
COMMENT ON COLUMN manutencao_detalhe.detalhes_adicionais_manutencao IS 'Detalhes em JSON. Exemplo: {"pecas_trocadas": ["filtro_ar", "oleo_motor"], "proxima_manutencao": "2025-12-10"}';

-- Tabela de detalhes de reserva
CREATE TABLE reserva_detalhe (
  id_reserva_detalhe SERIAL PRIMARY KEY,
  operacao_id BIGINT NOT NULL,
  motivo_reserva VARCHAR(200) NOT NULL,
  data_inicio_reserva DATE NOT NULL,
  data_fim_reserva DATE NOT NULL,
  prioridade_reserva VARCHAR(20) DEFAULT 'NORMAL',
  condicoes_reserva TEXT,
  documento_reserva VARCHAR(100),
  detalhes_adicionais_reserva JSONB,
  FOREIGN KEY (operacao_id) REFERENCES operacao(id_operacao) ON DELETE CASCADE
);

COMMENT ON TABLE reserva_detalhe IS 'Detalhes específicos para operações de reserva';

COMMENT ON COLUMN reserva_detalhe.id_reserva_detalhe IS 'Identificador único. Exemplo: 1';
COMMENT ON COLUMN reserva_detalhe.operacao_id IS 'ID da operação principal. Exemplo: 1009';
COMMENT ON COLUMN reserva_detalhe.motivo_reserva IS 'Motivo da reserva. Exemplo: Operação especial programada para combate a incêndio florestal';
COMMENT ON COLUMN reserva_detalhe.data_inicio_reserva IS 'Data de início da reserva. Exemplo: 2025-07-01';
COMMENT ON COLUMN reserva_detalhe.data_fim_reserva IS 'Data de fim da reserva. Exemplo: 2025-07-15';
COMMENT ON COLUMN reserva_detalhe.prioridade_reserva IS 'Prioridade da reserva. Exemplo: ALTA';
COMMENT ON COLUMN reserva_detalhe.condicoes_reserva IS 'Condições da reserva. Exemplo: Material deve permanecer disponível para uso imediato';
COMMENT ON COLUMN reserva_detalhe.documento_reserva IS 'Documento da reserva. Exemplo: RES-001-2025';
COMMENT ON COLUMN reserva_detalhe.detalhes_adicionais_reserva IS 'Detalhes em JSON. Exemplo: {"operacao_especial": "combate_florestal_2025", "comandante_operacao": "Major Silva"}';

-- ==============================================================================
-- TABELAS DE HISTÓRICO E AUDITORIA (PARTICIONADAS)
-- ==============================================================================

-- Tabela de histórico de estoque (particionada)
CREATE TABLE historico_estoque (
  id_historico BIGSERIAL,
  material_id INTEGER NOT NULL,
  almoxarifado_id INTEGER NOT NULL,
  data_snapshot DATE NOT NULL,
  quantidade_disponivel INTEGER NOT NULL,
  quantidade_reservada INTEGER DEFAULT 0,
  quantidade_em_manutencao INTEGER DEFAULT 0,
  valor_unitario NUMERIC(12,2),
  valor_total NUMERIC(15,2),
  observacoes TEXT,
  data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (material_id) REFERENCES material_base(id_material),
  FOREIGN KEY (almoxarifado_id) REFERENCES almoxarifado(id_almoxarifado)
) PARTITION BY RANGE (data_snapshot);

COMMENT ON TABLE historico_estoque IS 'Histórico de estoque com snapshots periódicos (particionada por trimestre)';

COMMENT ON COLUMN historico_estoque.id_historico IS 'Identificador único do histórico. Exemplo: 1';
COMMENT ON COLUMN historico_estoque.material_id IS 'ID do material. Exemplo: 10';
COMMENT ON COLUMN historico_estoque.almoxarifado_id IS 'ID do almoxarifado. Exemplo: 1';
COMMENT ON COLUMN historico_estoque.data_snapshot IS 'Data do snapshot. Exemplo: 2025-06-30';
COMMENT ON COLUMN historico_estoque.quantidade_disponivel IS 'Quantidade disponível na data. Exemplo: 45';
COMMENT ON COLUMN historico_estoque.quantidade_reservada IS 'Quantidade reservada na data. Exemplo: 5';
COMMENT ON COLUMN historico_estoque.quantidade_em_manutencao IS 'Quantidade em manutenção na data. Exemplo: 2';
COMMENT ON COLUMN historico_estoque.valor_unitario IS 'Valor unitário na data. Exemplo: 125.50';
COMMENT ON COLUMN historico_estoque.valor_total IS 'Valor total na data. Exemplo: 6525.00';
COMMENT ON COLUMN historico_estoque.observacoes IS 'Observações do período. Exemplo: Período de alta demanda devido à temporada seca';
COMMENT ON COLUMN historico_estoque.data_criacao IS 'Data de criação do registro. Exemplo: 2025-06-30 23:59:59';

-- Tabela de log de auditoria (particionada)
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
COMMENT ON COLUMN log_auditoria.tabela_afetada IS 'Nome da tabela afetada. Exemplo: material_base';
COMMENT ON COLUMN log_auditoria.operacao_tipo IS 'Tipo de operação. Exemplo: UPDATE';
COMMENT ON COLUMN log_auditoria.registro_id IS 'ID do registro afetado. Exemplo: 15';
COMMENT ON COLUMN log_auditoria.usuario_id IS 'ID do usuário responsável. Exemplo: 5';
COMMENT ON COLUMN log_auditoria.dados_anteriores IS 'Dados antes da alteração. Exemplo: {"nome": "Mangueira Antiga", "valor": 100.00}';
COMMENT ON COLUMN log_auditoria.dados_novos IS 'Dados após a alteração. Exemplo: {"nome": "Mangueira Nova", "valor": 125.50}';
COMMENT ON COLUMN log_auditoria.ip_origem IS 'IP de origem da operação. Exemplo: 192.168.1.100';
COMMENT ON COLUMN log_auditoria.user_agent IS 'User agent do navegador. Exemplo: Mozilla/5.0 (Windows NT 10.0; Win64; x64)';
COMMENT ON COLUMN log_auditoria.data_operacao IS 'Data e hora da operação. Exemplo: 2025-06-17 14:30:00';
COMMENT ON COLUMN log_auditoria.contexto_operacao IS 'Contexto da operação. Exemplo: {"modulo": "gestao_materiais", "funcao": "atualizar_material"}';

-- ==============================================================================
-- TABELAS DE NOTIFICAÇÕES (PARTICIONADA)
-- ==============================================================================

-- Tabela de notificações (particionada)
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
COMMENT ON COLUMN notificacao.tipo_notificacao IS 'Tipo da notificação. Exemplo: ESTOQUE_CRITICO';
COMMENT ON COLUMN notificacao.titulo IS 'Título da notificação. Exemplo: Estoque Crítico - Mangueira 2.5 pol';
COMMENT ON COLUMN notificacao.mensagem IS 'Mensagem completa. Exemplo: O estoque de Mangueira 2.5 pol está abaixo do nível mínimo (5 unidades)';
COMMENT ON COLUMN notificacao.prioridade IS 'Prioridade da notificação. Exemplo: ALTA';
COMMENT ON COLUMN notificacao.destinatario_id IS 'ID do destinatário. Exemplo: 5';
COMMENT ON COLUMN notificacao.remetente_id IS 'ID do remetente. Exemplo: 1';
COMMENT ON COLUMN notificacao.lida IS 'Indica se foi lida. Exemplo: false';
COMMENT ON COLUMN notificacao.data_leitura IS 'Data de leitura. Exemplo: 2025-06-17 15:30:00';
COMMENT ON COLUMN notificacao.data_criacao IS 'Data de criação. Exemplo: 2025-06-17 14:30:00';
COMMENT ON COLUMN notificacao.data_expiracao IS 'Data de expiração. Exemplo: 2025-06-24 14:30:00';
COMMENT ON COLUMN notificacao.dados_contexto IS 'Dados de contexto. Exemplo: {"material_id": 10, "estoque_atual": 3, "estoque_minimo": 5}';
COMMENT ON COLUMN notificacao.canal_notificacao IS 'Canal de notificação. Exemplo: EMAIL';

-- ==============================================================================
-- CRIAÇÃO DE PARTIÇÕES INICIAIS
-- ==============================================================================

-- Partições para operacao (mensais)
CREATE TABLE operacao_p2025_06 PARTITION OF operacao
  FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE operacao_p2025_07 PARTITION OF operacao
  FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

CREATE TABLE operacao_p2025_08 PARTITION OF operacao
  FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');

-- Partições para historico_estoque (trimestrais)
CREATE TABLE historico_estoque_p2025_q2 PARTITION OF historico_estoque
  FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

CREATE TABLE historico_estoque_p2025_q3 PARTITION OF historico_estoque
  FOR VALUES FROM ('2025-07-01') TO ('2025-10-01');

-- Partições para log_auditoria (mensais)
CREATE TABLE log_auditoria_p2025_06 PARTITION OF log_auditoria
  FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE log_auditoria_p2025_07 PARTITION OF log_auditoria
  FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

-- Partições para notificacao (mensais)
CREATE TABLE notificacao_p2025_06 PARTITION OF notificacao
  FOR VALUES FROM ('2025-06-01') TO ('2025-07-01');

CREATE TABLE notificacao_p2025_07 PARTITION OF notificacao
  FOR VALUES FROM ('2025-07-01') TO ('2025-08-01');

-- ==============================================================================
-- ÍNDICES ESPECIALIZADOS
-- ==============================================================================

-- Índices B-tree tradicionais
CREATE INDEX idx_militar_matricula ON militar(matricula);
CREATE INDEX idx_militar_unidade ON militar(unidade_id);
CREATE INDEX idx_material_codigo ON material_base(codigo_material);
CREATE INDEX idx_material_categoria ON material_base(categoria_id);
CREATE INDEX idx_estoque_material_almox ON estoque_atual(material_id, almoxarifado_id);
CREATE INDEX idx_operacao_data ON operacao(data_operacao);
CREATE INDEX idx_operacao_material ON operacao(material_id);
CREATE INDEX idx_operacao_tipo ON operacao(tipo_movimentacao);
CREATE INDEX idx_operacao_status ON operacao(status);

-- Índices GIN para colunas JSONB
CREATE INDEX idx_material_base_attr_gin ON material_base USING gin (atributos_adicionais);
CREATE INDEX idx_operacao_det_gin ON operacao USING gin (detalhes_adicionais);
CREATE INDEX idx_tipo_viatura_espec_gin ON tipo_viatura USING gin (especificacoes_tecnicas);
CREATE INDEX idx_categoria_material_config_gin ON categoria_material USING gin (configuracoes_especificas);
CREATE INDEX idx_militar_info_comp_gin ON militar USING gin (informacoes_complementares);
CREATE INDEX idx_unidade_cbm_info_comp_gin ON unidade_cbm USING gin (informacoes_complementares);
CREATE INDEX idx_almoxarifado_config_gin ON almoxarifado USING gin (configuracoes_especificas);
CREATE INDEX idx_localizacao_restricoes_gin ON localizacao USING gin (restricoes_especiais);
CREATE INDEX idx_notificacao_dados_contexto_gin ON notificacao USING gin (dados_contexto);

-- Índices compostos para consultas frequentes
CREATE INDEX idx_estoque_material_situacao ON estoque_atual(material_id, quantidade_disponivel) WHERE quantidade_disponivel > 0;
CREATE INDEX idx_operacao_data_tipo ON operacao(data_operacao, tipo_movimentacao);
CREATE INDEX idx_notificacao_destinatario_lida ON notificacao(destinatario_id, lida, data_criacao);

-- ==============================================================================
-- FUNÇÕES DE PARTICIONAMENTO AUTOMÁTICO
-- ==============================================================================

-- Função para criar próxima partição de operacao
CREATE OR REPLACE FUNCTION criar_proxima_particao_operacao()
RETURNS TRIGGER AS $$
DECLARE
    data_particao DATE;
    particao_nome TEXT;
    data_inicio DATE;
    data_fim DATE;
BEGIN
    data_particao := DATE_TRUNC('month', NEW.data_operacao);
    particao_nome := 'operacao_p' || TO_CHAR(data_particao, 'YYYY_MM');
    data_inicio := data_particao;
    data_fim := data_particao + INTERVAL '1 month';

    BEGIN
        EXECUTE format('CREATE TABLE %I PARTITION OF operacao FOR VALUES FROM (%L) TO (%L)',
                       particao_nome, data_inicio, data_fim);
        RAISE NOTICE 'Partição % criada com sucesso.', particao_nome;
    EXCEPTION
        WHEN duplicate_table THEN
            RAISE NOTICE 'Partição % já existe, ignorando criação.', particao_nome;
        WHEN OTHERS THEN
            RAISE WARNING 'Erro ao criar partição %: %', particao_nome, SQLERRM;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para criar próxima partição de historico_estoque
CREATE OR REPLACE FUNCTION criar_proxima_particao_historico_estoque()
RETURNS TRIGGER AS $$
DECLARE
    data_particao DATE;
    particao_nome TEXT;
    data_inicio DATE;
    data_fim DATE;
    trimestre INTEGER;
BEGIN
    data_particao := DATE_TRUNC('quarter', NEW.data_snapshot);
    trimestre := EXTRACT(quarter FROM data_particao);
    particao_nome := 'historico_estoque_p' || TO_CHAR(data_particao, 'YYYY') || '_q' || trimestre;
    data_inicio := data_particao;
    data_fim := data_particao + INTERVAL '3 months';

    BEGIN
        EXECUTE format('CREATE TABLE %I PARTITION OF historico_estoque FOR VALUES FROM (%L) TO (%L)',
                       particao_nome, data_inicio, data_fim);
        RAISE NOTICE 'Partição % criada com sucesso.', particao_nome;
    EXCEPTION
        WHEN duplicate_table THEN
            RAISE NOTICE 'Partição % já existe, ignorando criação.', particao_nome;
        WHEN OTHERS THEN
            RAISE WARNING 'Erro ao criar partição %: %', particao_nome, SQLERRM;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para criar próxima partição de log_auditoria
CREATE OR REPLACE FUNCTION criar_proxima_particao_log_auditoria()
RETURNS TRIGGER AS $$
DECLARE
    data_particao DATE;
    particao_nome TEXT;
    data_inicio DATE;
    data_fim DATE;
BEGIN
    data_particao := DATE_TRUNC('month', NEW.data_operacao);
    particao_nome := 'log_auditoria_p' || TO_CHAR(data_particao, 'YYYY_MM');
    data_inicio := data_particao;
    data_fim := data_particao + INTERVAL '1 month';

    BEGIN
        EXECUTE format('CREATE TABLE %I PARTITION OF log_auditoria FOR VALUES FROM (%L) TO (%L)',
                       particao_nome, data_inicio, data_fim);
        RAISE NOTICE 'Partição % criada com sucesso.', particao_nome;
    EXCEPTION
        WHEN duplicate_table THEN
            RAISE NOTICE 'Partição % já existe, ignorando criação.', particao_nome;
        WHEN OTHERS THEN
            RAISE WARNING 'Erro ao criar partição %: %', particao_nome, SQLERRM;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Função para criar próxima partição de notificacao
CREATE OR REPLACE FUNCTION criar_proxima_particao_notificacao()
RETURNS TRIGGER AS $$
DECLARE
    data_particao DATE;
    particao_nome TEXT;
    data_inicio DATE;
    data_fim DATE;
BEGIN
    data_particao := DATE_TRUNC('month', NEW.data_criacao);
    particao_nome := 'notificacao_p' || TO_CHAR(data_particao, 'YYYY_MM');
    data_inicio := data_particao;
    data_fim := data_particao + INTERVAL '1 month';

    BEGIN
        EXECUTE format('CREATE TABLE %I PARTITION OF notificacao FOR VALUES FROM (%L) TO (%L)',
                       particao_nome, data_inicio, data_fim);
        RAISE NOTICE 'Partição % criada com sucesso.', particao_nome;
    EXCEPTION
        WHEN duplicate_table THEN
            RAISE NOTICE 'Partição % já existe, ignorando criação.', particao_nome;
        WHEN OTHERS THEN
            RAISE WARNING 'Erro ao criar partição %: %', particao_nome, SQLERRM;
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- TRIGGERS DE PARTICIONAMENTO
-- ==============================================================================

-- Trigger para criação automática de partições de operacao
CREATE TRIGGER trigger_criar_particao_operacao
    BEFORE INSERT ON operacao
    FOR EACH ROW
    EXECUTE FUNCTION criar_proxima_particao_operacao();

-- Trigger para criação automática de partições de historico_estoque
CREATE TRIGGER trigger_criar_particao_historico_estoque
    BEFORE INSERT ON historico_estoque
    FOR EACH ROW
    EXECUTE FUNCTION criar_proxima_particao_historico_estoque();

-- Trigger para criação automática de partições de log_auditoria
CREATE TRIGGER trigger_criar_particao_log_auditoria
    BEFORE INSERT ON log_auditoria
    FOR EACH ROW
    EXECUTE FUNCTION criar_proxima_particao_log_auditoria();

-- Trigger para criação automática de partições de notificacao
CREATE TRIGGER trigger_criar_particao_notificacao
    BEFORE INSERT ON notificacao
    FOR EACH ROW
    EXECUTE FUNCTION criar_proxima_particao_notificacao();

-- ==============================================================================
-- FUNÇÕES DE NEGÓCIO E AUTOMAÇÃO
-- ==============================================================================

-- Função para atualizar estoque após operação
CREATE OR REPLACE FUNCTION atualizar_estoque_operacao()
RETURNS TRIGGER AS $$
DECLARE
    estoque_record RECORD;
BEGIN
    -- Buscar registro de estoque
    SELECT * INTO estoque_record
    FROM estoque_atual
    WHERE material_id = NEW.material_id
      AND almoxarifado_id = COALESCE(NEW.almoxarifado_origem_id, NEW.almoxarifado_destino_id);

    -- Atualizar estoque baseado no tipo de movimentação
    CASE NEW.tipo_movimentacao
        WHEN 'ENTRADA' THEN
            UPDATE estoque_atual
            SET quantidade_disponivel = quantidade_disponivel + NEW.quantidade,
                valor_total = valor_total + (NEW.quantidade * NEW.valor_unitario),
                data_ultima_movimentacao = NEW.data_operacao,
                data_atualizacao = CURRENT_TIMESTAMP
            WHERE material_id = NEW.material_id
              AND almoxarifado_id = NEW.almoxarifado_destino_id;

        WHEN 'SAIDA' THEN
            UPDATE estoque_atual
            SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade,
                data_ultima_movimentacao = NEW.data_operacao,
                data_atualizacao = CURRENT_TIMESTAMP
            WHERE material_id = NEW.material_id
              AND almoxarifado_id = NEW.almoxarifado_origem_id;

        WHEN 'RESERVA' THEN
            UPDATE estoque_atual
            SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade,
                quantidade_reservada = quantidade_reservada + NEW.quantidade,
                data_ultima_movimentacao = NEW.data_operacao,
                data_atualizacao = CURRENT_TIMESTAMP
            WHERE material_id = NEW.material_id
              AND almoxarifado_id = NEW.almoxarifado_origem_id;
    END CASE;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualização automática de estoque
CREATE TRIGGER trigger_atualizar_estoque
    AFTER INSERT ON operacao
    FOR EACH ROW
    EXECUTE FUNCTION atualizar_estoque_operacao();

-- Função para verificar estoque crítico
CREATE OR REPLACE FUNCTION verificar_estoque_critico()
RETURNS TRIGGER AS $$
DECLARE
    material_record RECORD;
BEGIN
    -- Buscar informações do material
    SELECT mb.nome_material, mb.estoque_minimo
    INTO material_record
    FROM material_base mb
    WHERE mb.id_material = NEW.material_id;

    -- Verificar se estoque está crítico
    IF NEW.quantidade_disponivel <= material_record.estoque_minimo THEN
        -- Enviar notificação via LISTEN/NOTIFY
        PERFORM pg_notify('estoque_critico',
            json_build_object(
                'material_id', NEW.material_id,
                'nome_material', material_record.nome_material,
                'quantidade_atual', NEW.quantidade_disponivel,
                'estoque_minimo', material_record.estoque_minimo,
                'almoxarifado_id', NEW.almoxarifado_id
            )::text
        );

        -- Inserir notificação na tabela
        INSERT INTO notificacao (
            tipo_notificacao, titulo, mensagem, prioridade,
            dados_contexto
        ) VALUES (
            'ESTOQUE_CRITICO',
            'Estoque Crítico - ' || material_record.nome_material,
            'O estoque de ' || material_record.nome_material || ' está abaixo do nível mínimo (' || material_record.estoque_minimo || ' unidades). Quantidade atual: ' || NEW.quantidade_disponivel,
            'ALTA',
            json_build_object(
                'material_id', NEW.material_id,
                'quantidade_atual', NEW.quantidade_disponivel,
                'estoque_minimo', material_record.estoque_minimo
            )
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificação de estoque crítico
CREATE TRIGGER trigger_verificar_estoque_critico
    AFTER UPDATE OF quantidade_disponivel ON estoque_atual
    FOR EACH ROW
    EXECUTE FUNCTION verificar_estoque_critico();

-- Função para auditoria automática
CREATE OR REPLACE FUNCTION auditoria_automatica()
RETURNS TRIGGER AS $$
DECLARE
    dados_antigos JSONB;
    dados_novos JSONB;
BEGIN
    -- Preparar dados para auditoria
    IF TG_OP = 'DELETE' THEN
        dados_antigos := to_jsonb(OLD);
        dados_novos := NULL;
    ELSIF TG_OP = 'UPDATE' THEN
        dados_antigos := to_jsonb(OLD);
        dados_novos := to_jsonb(NEW);
    ELSIF TG_OP = 'INSERT' THEN
        dados_antigos := NULL;
        dados_novos := to_jsonb(NEW);
    END IF;

    -- Inserir log de auditoria
    INSERT INTO log_auditoria (
        tabela_afetada, operacao_tipo, registro_id,
        dados_anteriores, dados_novos, contexto_operacao
    ) VALUES (
        TG_TABLE_NAME, TG_OP,
        CASE WHEN TG_OP = 'DELETE' THEN OLD.id_material ELSE NEW.id_material END,
        dados_antigos, dados_novos,
        json_build_object('trigger', TG_NAME, 'timestamp', CURRENT_TIMESTAMP)
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Triggers de auditoria para tabelas críticas
CREATE TRIGGER trigger_auditoria_material_base
    AFTER INSERT OR UPDATE OR DELETE ON material_base
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

CREATE TRIGGER trigger_auditoria_operacao
    AFTER INSERT OR UPDATE OR DELETE ON operacao
    FOR EACH ROW
    EXECUTE FUNCTION auditoria_automatica();

-- ==============================================================================
-- PROCEDURES PARA OPERAÇÕES ESPECIALIZADAS
-- ==============================================================================

-- Procedure para entrada rápida de material
CREATE OR REPLACE FUNCTION entrada_rapida_material(
    p_material_id INTEGER,
    p_almoxarifado_id INTEGER,
    p_quantidade INTEGER,
    p_valor_unitario NUMERIC,
    p_responsavel_id INTEGER,
    p_fornecedor VARCHAR DEFAULT NULL,
    p_nota_fiscal VARCHAR DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_operacao_id BIGINT;
    v_numero_operacao VARCHAR(50);
BEGIN
    -- Gerar número da operação
    v_numero_operacao := 'OP-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
                        LPAD(nextval('seq_numero_operacao')::TEXT, 6, '0');

    -- Inserir operação
    INSERT INTO operacao (
        numero_operacao, tipo_movimentacao, material_id,
        almoxarifado_destino_id, militar_responsavel_id,
        quantidade, valor_unitario, valor_total, status
    ) VALUES (
        v_numero_operacao, 'ENTRADA', p_material_id,
        p_almoxarifado_id, p_responsavel_id,
        p_quantidade, p_valor_unitario, p_quantidade * p_valor_unitario, 'CONCLUIDA'
    ) RETURNING id_operacao INTO v_operacao_id;

    -- Inserir detalhes de entrada se fornecidos
    IF p_fornecedor IS NOT NULL OR p_nota_fiscal IS NOT NULL THEN
        INSERT INTO entrada_detalhe (
            operacao_id, fornecedor, nota_fiscal
        ) VALUES (
            v_operacao_id, p_fornecedor, p_nota_fiscal
        );
    END IF;

    -- Atualizar ou inserir estoque
    INSERT INTO estoque_atual (
        material_id, almoxarifado_id, quantidade_disponivel, valor_total
    ) VALUES (
        p_material_id, p_almoxarifado_id, p_quantidade, p_quantidade * p_valor_unitario
    ) ON CONFLICT (material_id, almoxarifado_id) DO UPDATE SET
        quantidade_disponivel = estoque_atual.quantidade_disponivel + p_quantidade,
        valor_total = estoque_atual.valor_total + (p_quantidade * p_valor_unitario),
        data_atualizacao = CURRENT_TIMESTAMP;

    RETURN v_operacao_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure para saída rápida de material
CREATE OR REPLACE FUNCTION saida_rapida_material(
    p_material_id INTEGER,
    p_almoxarifado_id INTEGER,
    p_quantidade INTEGER,
    p_responsavel_id INTEGER,
    p_recebedor_id INTEGER,
    p_finalidade VARCHAR DEFAULT NULL
)
RETURNS BIGINT AS $$
DECLARE
    v_operacao_id BIGINT;
    v_numero_operacao VARCHAR(50);
    v_estoque_disponivel INTEGER;
BEGIN
    -- Verificar estoque disponível
    SELECT quantidade_disponivel INTO v_estoque_disponivel
    FROM estoque_atual
    WHERE material_id = p_material_id AND almoxarifado_id = p_almoxarifado_id;

    IF v_estoque_disponivel IS NULL OR v_estoque_disponivel < p_quantidade THEN
        RAISE EXCEPTION 'Estoque insuficiente. Disponível: %, Solicitado: %',
                       COALESCE(v_estoque_disponivel, 0), p_quantidade;
    END IF;

    -- Gerar número da operação
    v_numero_operacao := 'OP-' || TO_CHAR(CURRENT_DATE, 'YYYY') || '-' ||
                        LPAD(nextval('seq_numero_operacao')::TEXT, 6, '0');

    -- Inserir operação
    INSERT INTO operacao (
        numero_operacao, tipo_movimentacao, material_id,
        almoxarifado_origem_id, militar_responsavel_id, militar_recebedor_id,
        quantidade, status
    ) VALUES (
        v_numero_operacao, 'SAIDA', p_material_id,
        p_almoxarifado_id, p_responsavel_id, p_recebedor_id,
        p_quantidade, 'CONCLUIDA'
    ) RETURNING id_operacao INTO v_operacao_id;

    -- Inserir detalhes de saída se fornecidos
    IF p_finalidade IS NOT NULL THEN
        INSERT INTO saida_detalhe (
            operacao_id, finalidade
        ) VALUES (
            v_operacao_id, p_finalidade
        );
    END IF;

    RETURN v_operacao_id;
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- GESTÃO DO CICLO DE VIDA DE PARTIÇÕES
-- ==============================================================================

-- Procedure para manutenção de partições de operacao
CREATE OR REPLACE FUNCTION manter_particoes_operacao(
    p_meses_retencao INTEGER DEFAULT 60
)
RETURNS TEXT AS $$
DECLARE
    particao_record RECORD;
    data_limite DATE;
    resultado TEXT := '';
BEGIN
    data_limite := CURRENT_DATE - INTERVAL '1 month' * p_meses_retencao;

    FOR particao_record IN
        SELECT schemaname, tablename
        FROM pg_tables
        WHERE tablename LIKE 'operacao_p%'
          AND tablename < 'operacao_p' || TO_CHAR(data_limite, 'YYYY_MM')
    LOOP
        -- Exportar dados antes de remover
        EXECUTE format('COPY %I.%I TO ''/tmp/%I.csv'' WITH CSV HEADER',
                      particao_record.schemaname, particao_record.tablename, particao_record.tablename);

        -- Desanexar partição
        EXECUTE format('ALTER TABLE operacao DETACH PARTITION %I.%I',
                      particao_record.schemaname, particao_record.tablename);

        -- Remover partição
        EXECUTE format('DROP TABLE %I.%I',
                      particao_record.schemaname, particao_record.tablename);

        resultado := resultado || 'Partição ' || particao_record.tablename || ' arquivada e removida. ';
    END LOOP;

    RETURN COALESCE(resultado, 'Nenhuma partição removida.');
END;
$$ LANGUAGE plpgsql;

-- ==============================================================================
-- VIEWS ORIENTADAS AO USUÁRIO
-- ==============================================================================

-- View para consulta simplificada de materiais
CREATE VIEW vw_materiais_disponiveis AS
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
    a.nome_almoxarifado,
    l.codigo_localizacao,
    mb.situacao
FROM material_base mb
JOIN categoria_material cm ON mb.categoria_id = cm.id_categoria
LEFT JOIN estoque_atual ea ON mb.id_material = ea.material_id
LEFT JOIN almoxarifado a ON ea.almoxarifado_id = a.id_almoxarifado
LEFT JOIN localizacao l ON ea.localizacao_id = l.id_localizacao
WHERE mb.ativo = TRUE
  AND mb.situacao = 'DISPONIVEL';

COMMENT ON VIEW vw_materiais_disponiveis IS 'View simplificada para consulta de materiais disponíveis';

-- View para operações recentes
CREATE VIEW vw_operacoes_recentes AS
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
    ad.nome_almoxarifado as almoxarifado_destino
FROM operacao o
JOIN material_base mb ON o.material_id = mb.id_material
JOIN militar mr ON o.militar_responsavel_id = mr.id_militar
LEFT JOIN almoxarifado ao ON o.almoxarifado_origem_id = ao.id_almoxarifado
LEFT JOIN almoxarifado ad ON o.almoxarifado_destino_id = ad.id_almoxarifado
WHERE o.data_operacao >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY o.data_operacao DESC;

COMMENT ON VIEW vw_operacoes_recentes IS 'View para consulta de operações dos últimos 30 dias';

-- ==============================================================================
-- SEQUENCES AUXILIARES
-- ==============================================================================

-- Sequence para numeração de operações
CREATE SEQUENCE seq_numero_operacao START 1;

COMMENT ON SEQUENCE seq_numero_operacao IS 'Sequence para geração de números sequenciais de operações';

-- ==============================================================================
-- CONFIGURAÇÕES DE SISTEMA
-- ==============================================================================

-- Configurações específicas para JSONB
ALTER SYSTEM SET gin_pending_list_limit = '4MB';
ALTER SYSTEM SET gin_fuzzy_search_limit = 0;

-- Configurações para particionamento
ALTER SYSTEM SET constraint_exclusion = partition;
ALTER SYSTEM SET enable_partition_pruning = on;
ALTER SYSTEM SET enable_partitionwise_join = on;
ALTER SYSTEM SET enable_partitionwise_aggregate = on;

-- ==============================================================================
-- FIM DA MODELAGEM POSTGRESQL V6.0
-- ==============================================================================

-- Comentário final sobre a versão
COMMENT ON DATABASE postgres IS 'Sistema Integrado de Gestão de Almoxarifado (SIGA) - CBM MT - Versão 6.0 - Implementação completa com particionamento expandido, índices GIN especializados, validações de domínio aprimoradas e gestão automatizada do ciclo de vida de dados';
