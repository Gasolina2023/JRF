-- Criação do banco de dados
CREATE DATABASE empresa_clientes;
USE empresa_clientes;

-- Tabela de Usuários do Sistema
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha_hash VARCHAR(255) NOT NULL,
    nivel_acesso ENUM('admin', 'gerente', 'vendedor', 'atendimento') DEFAULT 'atendimento',
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    status ENUM('ativo', 'inativo') DEFAULT 'ativo'
);

-- Tabela de Clientes
CREATE TABLE clientes (
    cliente_id INT AUTO_INCREMENT PRIMARY KEY,
    nome_completo VARCHAR(100) NOT NULL,
    nome_fantasia VARCHAR(100),
    email VARCHAR(100),
    email_secundario VARCHAR(100),
    cpf_cnpj VARCHAR(20) UNIQUE,
    rg_ie VARCHAR(20),
    data_nascimento DATE,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_cliente ENUM('PF', 'PJ') DEFAULT 'PF',
    status_cliente ENUM('ativo', 'inativo', 'potencial', 'bloqueado') DEFAULT 'ativo',
    indicador VARCHAR(100),
    origem_cadastro ENUM('loja', 'site', 'indicacao', 'feira', 'outros') DEFAULT 'loja',
    observacoes TEXT,
    data_ultima_compra DATE,
    valor_total_compras DECIMAL(12,2) DEFAULT 0,
    usuario_cadastro INT,
    FOREIGN KEY (usuario_cadastro) REFERENCES usuarios(usuario_id)
);

-- Tabela de Tags/Categorias de Clientes
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    nome_tag VARCHAR(50) UNIQUE NOT NULL,
    cor VARCHAR(20) DEFAULT '#3498db',
    descricao TEXT
);

-- Tabela de Relação Cliente-Tag
CREATE TABLE cliente_tags (
    cliente_id INT NOT NULL,
    tag_id INT NOT NULL,
    data_associacao DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_associacao INT,
    PRIMARY KEY (cliente_id, tag_id),
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_associacao) REFERENCES usuarios(usuario_id)
);

-- Tabela de Endereços
CREATE TABLE enderecos (
    endereco_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    tipo_endereco ENUM('residencial', 'comercial', 'cobrança', 'entrega') DEFAULT 'residencial',
    apelido VARCHAR(50),
    logradouro VARCHAR(100) NOT NULL,
    numero VARCHAR(20),
    complemento VARCHAR(50),
    bairro VARCHAR(50),
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    cep VARCHAR(10),
    pais VARCHAR(30) DEFAULT 'Brasil',
    endereco_principal BOOLEAN DEFAULT FALSE,
    observacoes TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE
);

-- Tabela de Telefones
CREATE TABLE telefones (
    telefone_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('celular', 'residencial', 'comercial', 'whatsapp', 'fax') DEFAULT 'celular',
    telefone_principal BOOLEAN DEFAULT FALSE,
    observacao VARCHAR(100),
    permite_whatsapp BOOLEAN DEFAULT TRUE,
    permite_sms BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE
);

-- Tabela de Interações/Contatos
CREATE TABLE interacoes (
    interacao_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    tipo_interacao ENUM('email', 'telefone', 'visita', 'reunião', 'whatsapp', 'campanha') NOT NULL,
    meio_contato ENUM('entrante', 'sainte'),
    assunto VARCHAR(100) NOT NULL,
    descricao TEXT,
    resolvido BOOLEAN DEFAULT FALSE,
    prioridade ENUM('baixa', 'media', 'alta', 'urgente') DEFAULT 'media',
    proxima_acao VARCHAR(100),
    data_proximo_contato DATE,
    lembrete_enviado BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

-- Tabela de Pedidos
CREATE TABLE pedidos (
    pedido_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    usuario_id INT NOT NULL,
    data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    data_entrega DATE,
    valor_total DECIMAL(12,2),
    desconto DECIMAL(10,2) DEFAULT 0,
    valor_final DECIMAL(12,2),
    status ENUM('orcamento', 'aberto', 'processando', 'enviado', 'entregue', 'cancelado') DEFAULT 'aberto',
    forma_pagamento VARCHAR(30),
    parcelas INT DEFAULT 1,
    observacoes TEXT,
    endereco_entrega INT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    FOREIGN KEY (endereco_entrega) REFERENCES enderecos(endereco_id)
);

-- Tabela de Itens de Pedido
CREATE TABLE pedido_itens (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_servico VARCHAR(100) NOT NULL,
    descricao TEXT,
    quantidade DECIMAL(10,3) DEFAULT 1,
    valor_unitario DECIMAL(10,2) NOT NULL,
    desconto_item DECIMAL(10,2) DEFAULT 0,
    valor_total DECIMAL(10,2),
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE
);

-- Tabela de Campanhas de Marketing
CREATE TABLE campanhas (
    campanha_id INT AUTO_INCREMENT PRIMARY KEY,
    nome_campanha VARCHAR(100) NOT NULL,
    descricao TEXT,
    tipo_campanha ENUM('email', 'sms', 'whatsapp', 'outros') NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE,
    orcamento DECIMAL(10,2),
    responsavel_id INT,
    status ENUM('planejada', 'ativa', 'concluida', 'cancelada') DEFAULT 'planejada',
    metricas TEXT,
    FOREIGN KEY (responsavel_id) REFERENCES usuarios(usuario_id)
);

-- Tabela de Clientes em Campanhas
CREATE TABLE campanha_clientes (
    campanha_id INT NOT NULL,
    cliente_id INT NOT NULL,
    data_inclusao DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pendente', 'contatado', 'convertido', 'nao_interessado') DEFAULT 'pendente',
    resposta TEXT,
    PRIMARY KEY (campanha_id, cliente_id),
    FOREIGN KEY (campanha_id) REFERENCES campanhas(campanha_id) ON DELETE CASCADE,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE
);

-- Tabela de Anexos (documentos, contratos, etc.)
CREATE TABLE anexos (
    anexo_id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT,
    pedido_id INT,
    interacao_id INT,
    nome_arquivo VARCHAR(255) NOT NULL,
    tipo_arquivo VARCHAR(50),
    tamanho INT,
    caminho_arquivo VARCHAR(255) NOT NULL,
    data_upload DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_upload INT,
    descricao TEXT,
    FOREIGN KEY (cliente_id) REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id) ON DELETE CASCADE,
    FOREIGN KEY (interacao_id) REFERENCES interacoes(interacao_id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_upload) REFERENCES usuarios(usuario_id)
);

-- Tabela de Histórico de Alterações (auditoria)
CREATE TABLE historico_alteracoes (
    historico_id INT AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    tipo_alteracao ENUM('insercao', 'atualizacao', 'exclusao') NOT NULL,
    dados_anteriores TEXT,
    dados_novos TEXT,
    data_alteracao DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id)
);

-- Índices para melhorar performance
CREATE INDEX idx_clientes_nome ON clientes(nome_completo);
CREATE INDEX idx_clientes_cpf_cnpj ON clientes(cpf_cnpj);
CREATE INDEX idx_clientes_status ON clientes(status_cliente);
CREATE INDEX idx_pedidos_cliente ON pedidos(cliente_id);
CREATE INDEX idx_pedidos_data ON pedidos(data_pedido);
CREATE INDEX idx_interacoes_cliente ON interacoes(cliente_id);