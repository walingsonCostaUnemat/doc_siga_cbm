# Documentação Técnica - Sistema Integrado de Gestão de Almoxarifado (SIGA)

**Corpo de Bombeiros Militar de Mato Grosso (CBM MT)**
**Modelagem de Dados PostgreSQL**
**Data:** 18 de junho de 2025
**Autor:** Manus AI

## Sumário Executivo

Esta documentação técnica apresenta a modelagem de dados PostgreSQL para o Sistema Integrado de Gestão de Almoxarifado (SIGA) do Corpo de Bombeiros Militar de Mato Grosso. O sistema foi projetado para atender às necessidades específicas de uma organização militar especializada em operações de emergência, combate a incêndios e salvamento, incorporando funcionalidades avançadas de rastreabilidade, gestão de custódia em campo, vinculação a eventos operacionais, avaliação de materiais e registro de ocorrências.

A modelagem apresentada representa uma solução robusta e escalável, capaz de suportar as operações complexas do CBM MT, desde o gerenciamento básico de estoque até o controle detalhado de materiais em operações de campo de longa duração. O banco de dados foi estruturado para garantir a integridade dos dados, a eficiência das consultas e a facilidade de manutenção, utilizando as melhores práticas de engenharia de software e administração de banco de dados.

## 1. Arquitetura Geral do Sistema

### 1.1. Visão Arquitetural

O Sistema Integrado de Gestão de Almoxarifado foi concebido seguindo uma arquitetura de banco de dados relacional híbrida, que combina a robustez e consistência dos modelos relacionais tradicionais com a flexibilidade dos campos JSONB para extensibilidade futura. Esta abordagem permite que o sistema mantenha a integridade referencial e as garantias ACID (Atomicidade, Consistência, Isolamento e Durabilidade) enquanto oferece a capacidade de adaptar-se a novos requisitos sem necessidade de alterações estruturais significativas.

A arquitetura é fundamentada em cinco pilares principais: gestão de entidades organizacionais (unidades, militares, almoxarifados), controle de materiais e equipamentos, rastreamento de operações e movimentações, gestão de eventos operacionais e sistema de auditoria e notificações. Cada pilar é implementado através de conjuntos de tabelas especializadas, interconectadas por relacionamentos bem definidos que garantem a consistência dos dados e facilitam a geração de relatórios complexos.

O sistema utiliza particionamento temporal para tabelas de alto volume, como operações, histórico de estoque, logs de auditoria e notificações. Esta estratégia garante que o desempenho das consultas seja mantido mesmo com o crescimento exponencial dos dados ao longo dos anos de operação. As partições são criadas automaticamente através de triggers e funções especializadas, reduzindo a necessidade de intervenção manual e garantindo a continuidade operacional.

### 1.2. Princípios de Design

O design da modelagem de dados foi guiado por princípios fundamentais que garantem a qualidade, manutenibilidade e evolução do sistema. O primeiro princípio é a normalização controlada, onde as tabelas são normalizadas até a terceira forma normal para eliminar redundâncias, mas com desnormalizações estratégicas em pontos específicos para otimizar consultas frequentes. Esta abordagem equilibra a integridade dos dados com a performance das operações.

O segundo princípio é a extensibilidade através de campos JSONB, que permite a adição de novos atributos sem alterações estruturais no banco de dados. Estes campos são utilizados de forma criteriosa, apenas em situações onde a flexibilidade é mais importante que a estrutura rígida, como em configurações específicas de equipamentos ou detalhes adicionais de operações que podem variar significativamente entre diferentes tipos de atividades.

O terceiro princípio é a rastreabilidade completa, implementada através de um sistema abrangente de auditoria que registra todas as alterações em tabelas críticas. Cada operação é documentada com informações sobre quem realizou a alteração, quando foi feita, quais dados foram modificados e o contexto da operação. Esta funcionalidade é essencial para organizações militares, onde a prestação de contas e a transparência são requisitos fundamentais.

### 1.3. Estratégia de Particionamento

A estratégia de particionamento adotada é baseada em intervalos temporais, adequada para o padrão de acesso aos dados do sistema. As tabelas `operacao`, `historico_estoque`, `log_auditoria` e `notificacao` são particionadas por períodos específicos: operações por trimestre, histórico de estoque por semestre, logs de auditoria por mês e notificações por mês. Esta granularidade foi escolhida com base na análise do volume esperado de dados e nos padrões de consulta típicos.

O particionamento automático é implementado através de funções PL/pgSQL que são executadas por triggers no momento da inserção de novos registros. Quando uma inserção é feita em uma data para a qual não existe partição, o sistema automaticamente cria a nova partição com os índices apropriados. Este mecanismo garante que o sistema continue operando sem interrupções mesmo quando novos períodos são alcançados.

A gestão do ciclo de vida das partições inclui procedimentos para arquivamento e remoção de partições antigas. Partições com mais de cinco anos são automaticamente movidas para um esquema de arquivo, onde permanecem acessíveis para consultas históricas mas não impactam o desempenho das operações correntes. Partições com mais de dez anos podem ser exportadas para armazenamento externo e removidas do banco principal, seguindo políticas de retenção de dados estabelecidas pela organização.

## 2. Estrutura de Entidades Organizacionais

### 2.1. Gestão de Unidades do CBM

A estrutura organizacional do Corpo de Bombeiros Militar de Mato Grosso é representada através da tabela `unidade_cbm`, que modela a hierarquia complexa da organização. Esta tabela suporta uma estrutura hierárquica recursiva, onde cada unidade pode ter uma unidade superior, permitindo a representação de comandos regionais, batalhões, companhias, pelotões e outras subdivisões organizacionais.

A tabela inclui informações essenciais como nome completo da unidade, sigla padronizada, dados de contato e localização física. O campo `comandante_id` estabelece a ligação com o militar responsável pela unidade, permitindo consultas rápidas sobre a cadeia de comando. O campo `unidade_superior_id` implementa a hierarquia organizacional, facilitando consultas que precisam navegar pela estrutura de comando.

O campo `informacoes_complementares` em formato JSONB permite o armazenamento de dados específicos de cada tipo de unidade, como especialidades operacionais, efetivo autorizado, equipamentos principais e outras características que podem variar significativamente entre diferentes tipos de unidades. Esta flexibilidade é crucial para acomodar a diversidade de unidades especializadas dentro do CBM MT.

### 2.2. Cadastro e Gestão de Militares

O sistema de gestão de militares é implementado através da tabela `militar`, que centraliza todas as informações pessoais e funcionais dos membros da corporação. A tabela utiliza domínios personalizados para garantir a consistência de dados críticos como matrícula e CPF, implementando validações automáticas que previnem a inserção de dados malformados.

A estrutura inclui campos para informações básicas como nome completo, nome de guerra (amplamente utilizado no ambiente militar), posto ou graduação, e dados de contato. A ligação com a unidade de lotação é estabelecida através do campo `unidade_id`, permitindo consultas eficientes sobre a distribuição de efetivo e a localização de militares específicos.

O campo `situacao` utiliza um tipo enumerado que define os possíveis estados funcionais de um militar (ativo, licenciado, afastado, reservista, reformado), garantindo consistência nos dados e facilitando consultas estatísticas sobre o efetivo. O campo `informacoes_complementares` em JSONB permite o armazenamento de dados como especialidades, cursos realizados, habilitações especiais e outras informações que podem ser relevantes para a designação de tarefas específicas.

### 2.3. Estrutura de Almoxarifados

A gestão de almoxarifados é implementada através de duas tabelas principais: `almoxarifado` e `localizacao`. A tabela `almoxarifado` define as características gerais de cada depósito, incluindo capacidade, área total, responsável e configurações específicas. Esta estrutura permite que cada unidade do CBM tenha múltiplos almoxarifados especializados, como almoxarifados de materiais de combate a incêndio, equipamentos de resgate, materiais administrativos, entre outros.

A tabela `localizacao` implementa um sistema de endereçamento interno detalhado, permitindo a localização precisa de materiais dentro de cada almoxarifado. O sistema suporta uma estrutura hierárquica de setores, prateleiras, níveis e posições, facilitando tanto o armazenamento organizado quanto a localização rápida de itens específicos. Cada localização pode ter restrições especiais definidas em JSONB, como limitações de peso, tipos de materiais permitidos ou requisitos de acesso restrito.

A integração entre almoxarifados e localizações permite consultas complexas sobre a distribuição espacial de materiais, otimização de rotas de coleta e identificação de localizações subutilizadas ou sobrecarregadas. Esta funcionalidade é essencial para a eficiência operacional, especialmente em situações de emergência onde a rapidez na localização e retirada de materiais pode ser crítica.

## 3. Sistema de Classificação e Gestão de Materiais

### 3.1. Categorização Dinâmica de Materiais

O sistema de categorização de materiais é implementado através da tabela `categoria_material`, que suporta uma hierarquia flexível e extensível de categorias e subcategorias. Esta estrutura permite a organização lógica de materiais de acordo com critérios funcionais, operacionais ou administrativos, facilitando tanto a gestão quanto a localização de itens específicos.

A hierarquia de categorias é implementada através de uma estrutura recursiva, onde cada categoria pode ter uma categoria pai, permitindo múltiplos níveis de classificação. Por exemplo, uma categoria principal "Equipamentos de Combate a Incêndio" pode ter subcategorias como "Mangueiras", "Esguichos", "Equipamentos de Proteção Individual", e cada uma dessas pode ter subdivisões adicionais baseadas em características técnicas ou aplicações específicas.

O campo `configuracoes_especificas` em JSONB permite que cada categoria tenha regras e parâmetros únicos, como requisitos de treinamento para uso, periodicidade de manutenção, condições especiais de armazenamento ou critérios de substituição. Esta flexibilidade é fundamental para acomodar a diversidade de materiais utilizados pelo CBM MT, desde equipamentos altamente especializados até materiais de consumo básico.

### 3.2. Gestão de Tipos de Viaturas

A tabela `tipo_viatura` implementa um sistema de categorização dinâmica para os diferentes tipos de viaturas utilizadas pelo CBM MT. Esta abordagem permite a adição de novos tipos de viaturas conforme a corporação adquire equipamentos especializados ou desenvolve novas capacidades operacionais, sem necessidade de alterações estruturais no banco de dados.

Cada tipo de viatura é caracterizado por informações como categoria principal (combate a incêndio, resgate, transporte, comando), subcategoria específica (urbano, florestal, aquático), e especificações técnicas detalhadas armazenadas em JSONB. Esta estrutura permite consultas sofisticadas sobre capacidades operacionais, como identificar todas as viaturas com capacidade de transporte de água superior a determinado volume ou viaturas equipadas com escadas mecânicas.

O campo `requisitos_operacionais` define os pré-requisitos para operação de cada tipo de viatura, incluindo habilitações necessárias, treinamentos obrigatórios e tamanho mínimo da tripulação. Esta informação é crucial para o planejamento operacional e para garantir que as viaturas sejam operadas apenas por militares devidamente qualificados.

### 3.3. Estrutura Base de Materiais

A tabela `material_base` serve como o núcleo central do sistema de gestão de materiais, concentrando informações comuns a todos os tipos de materiais independentemente de sua natureza específica. Esta abordagem permite consultas unificadas sobre o inventário completo enquanto mantém a flexibilidade para especializações através de tabelas relacionadas.

Cada material é identificado por um código único que segue padrões estabelecidos pela organização, facilitando a integração com sistemas externos e a padronização de procedimentos. O sistema inclui campos para informações básicas como nome, descrição, categoria, unidade de medida e valores financeiros, além de parâmetros operacionais como estoques mínimo e máximo.

O campo `atributos_adicionais` em JSONB permite o armazenamento de características específicas que podem variar significativamente entre diferentes tipos de materiais. Por exemplo, materiais químicos podem ter informações sobre toxicidade e prazo de validade, equipamentos eletrônicos podem ter especificações técnicas detalhadas, e materiais têxteis podem ter informações sobre tamanhos e cores disponíveis.

### 3.4. Especialização por Tipo de Material

O sistema implementa especialização através de tabelas dedicadas para diferentes tipos de materiais: `material_consumo`, `material_permanente`, `equipamento` e `viatura`. Esta abordagem permite que cada tipo de material tenha campos específicos para suas características únicas, mantendo a organização lógica dos dados e otimizando as consultas.

A tabela `material_consumo` inclui informações específicas para materiais que são consumidos durante o uso, como data de validade, lote de fabricação, instruções de uso e restrições de armazenamento. Estes campos são essenciais para o controle de qualidade e para garantir que materiais vencidos ou inadequados não sejam utilizados em operações críticas.

A tabela `material_permanente` foi aprimorada para incluir controle de ocorrências, com campos que indicam se o material possui ocorrências pendentes e um histórico de incidentes em formato JSONB. Esta funcionalidade permite o acompanhamento detalhado do ciclo de vida de materiais permanentes, identificando padrões de problemas e orientando decisões sobre manutenção, substituição ou baixa.

A tabela `equipamento` concentra informações técnicas específicas para equipamentos especializados, incluindo número de série, especificações técnicas detalhadas, manuais de operação e certificações. A tabela `viatura` inclui informações específicas para viaturas, como dados de documentação, quilometragem, manutenção e seguro, essenciais para o controle da frota.

## 4. Sistema de Operações e Movimentações

### 4.1. Estrutura Principal de Operações

A tabela `operacao` constitui o núcleo do sistema de rastreamento de movimentações, registrando todas as transações que envolvem materiais dentro do sistema. A tabela é particionada por data para garantir performance adequada mesmo com grandes volumes de dados, e inclui campos para todos os tipos de movimentação suportados pelo sistema.

Cada operação é identificada por um número sequencial único que facilita a referência e o rastreamento. O campo `tipo_movimentacao` utiliza um tipo enumerado que inclui todas as possibilidades: entrada, saída, transferência, devolução, concessão, cautela, baixa, manutenção, reserva e transferência de custódia. Esta padronização garante consistência nos dados e facilita a geração de relatórios estatísticos.

A estrutura inclui campos para identificar os almoxarifados de origem e destino, os militares responsável e recebedor, quantidades, valores e datas relevantes. O campo `detalhes_adicionais` em JSONB permite o armazenamento de informações específicas para cada tipo de operação, como condições especiais, autorizações necessárias ou observações técnicas.

### 4.2. Gestão de Custódia e Transferências em Campo

Uma das inovações
(Content truncated due to size limit. Use line ranges to read in chunks)
