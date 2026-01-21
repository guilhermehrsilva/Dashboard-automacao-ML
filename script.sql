-- 1. Criação do Banco de Dados
CREATE DATABASE IF NOT EXISTS olist_db;
USE olist_db;

-- 2. Tabela de Clientes (Quem compra)
CREATE TABLE IF NOT EXISTS clientes (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

-- 3. Tabela de Pedidos (Quando comprou)
CREATE TABLE IF NOT EXISTS pedidos (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

-- 4. Tabela de Pagamentos (Quanto gastou)
CREATE TABLE IF NOT EXISTS pagamentos (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10,2)
    -- Não usei chave primária aqui pois um pedido pode ter múltiplos pagamentos
);

-- INSERINDO DADOS NAS TABELAS-

-- 1. Transferir Clientes (Copiando da tabela bagunçada para a organizada)
INSERT INTO clientes (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
SELECT 
    customer_id, 
    customer_unique_id, 
    customer_zip_code_prefix, 
    customer_city, 
    customer_state 
FROM olist_customers_dataset;

-- 2. Transferir Pedidos (convertendo texto para data se necessário)
INSERT INTO pedidos 
SELECT 
    order_id, customer_id, order_status, 
    order_purchase_timestamp, order_approved_at, 
    order_delivered_carrier_date, order_delivered_customer_date, 
    order_estimated_delivery_date
FROM olist_orders_dataset;

-- 3. Transferir Pagamentos
INSERT INTO pagamentos
SELECT 
    order_id, payment_sequential, payment_type, 
    payment_installments, payment_value
FROM olist_order_payments_dataset;

-- Corrigindo erros da coluna order_delivered_carrier_date

-- 1. Limpando a tabela caso tenha entrado "sujeira"
TRUNCATE TABLE pedidos;

-- 2. Insere tratando os campos vazios com NULLIF
INSERT INTO pedidos (
    order_id, customer_id, order_status, 
    order_purchase_timestamp, order_approved_at, 
    order_delivered_carrier_date, order_delivered_customer_date, 
    order_estimated_delivery_date
)
SELECT 
    order_id, 
    customer_id, 
    order_status,
    NULLIF(order_purchase_timestamp, ''),        -- Trata Data da Compra
    NULLIF(order_approved_at, ''),               -- Trata Data de Aprovação
    NULLIF(order_delivered_carrier_date, ''),    -- Trata Data da Transportadora (Onde deu erro)
    NULLIF(order_delivered_customer_date, ''),   -- Trata Data da Entrega
    NULLIF(order_estimated_delivery_date, '')    -- Trata Estimativa
FROM olist_orders_dataset;

-- Agora todas as tabelas estão criadas e populadas corretamente! --

-- Começando as análises! --

-- Criando a tabela final já com os cálculos prontos para o Power BI
CREATE TABLE IF NOT EXISTS rfm_final AS
WITH base_rfm AS (
    -- 1ª Camada: Agrupando pedidos por Cliente Único (CPF)
    SELECT 
        c.customer_unique_id,
        MAX(p.order_purchase_timestamp) AS data_ultima_compra,
        COUNT(DISTINCT p.order_id) AS frequencia,
        SUM(pag.payment_value) AS monetario
    FROM clientes c
    INNER JOIN pedidos p ON c.customer_id = p.customer_id
    INNER JOIN pagamentos pag ON p.order_id = pag.order_id
    WHERE p.order_status = 'delivered' -- Apenas pedidos entregues contam
    GROUP BY c.customer_unique_id
),
rfm_calculado AS (
    -- 2ª Camada: Aplicando a nota de 1 a 5 (NTILE)
    SELECT 
        customer_unique_id,
        data_ultima_compra,
        frequencia,
        monetario,
        -- Recência: Ordenei data DESC (do mais novo pro velho). O grupo 1 é o mais antigo, 5 o mais recente.
        -- Nota: Alguns analistas invertem (1 é recente), mas vou usar 5 = Melhor Cliente.
        NTILE(5) OVER (ORDER BY data_ultima_compra ASC) AS R_Score,
        
        -- Frequência: Quem comprou mais vezes ganha 5
        NTILE(5) OVER (ORDER BY frequencia ASC) AS F_Score,
        
        -- Monetário: Quem gastou mais ganha 5
        NTILE(5) OVER (ORDER BY monetario ASC) AS M_Score
    FROM base_rfm
)
-- Seleção Final: Criando o "Score Geral" concatenado (ex: "555")
SELECT 
    customer_unique_id,
    data_ultima_compra,
    frequencia,
    monetario,
    R_Score,
    F_Score,
    M_Score,
    CONCAT(R_Score, F_Score, M_Score) as RFM_Geral
FROM rfm_calculado;

-- Verificando se a tabela está correta--   
SELECT * FROM rfm_final LIMIT 20;


-- Fórmulas para o Power BI (DAX):--

-- Saúde do Olist --
Segmento RFM = 
SWITCH(
    TRUE(),
    'olist_db rfm_final'[R_Score] >= 4 && 'olist_db rfm_final'[F_Score] >= 4 && 'olist_db rfm_final'[M_Score] >= 4, "🏆 Campeões",
    'olist_db rfm_final'[R_Score] >= 3 && 'olist_db rfm_final'[F_Score] >= 3, "💎 Leais",
    'olist_db rfm_final'[R_Score] >= 4 && 'olist_db rfm_final'[F_Score] = 1, "🌱 Novos Promissores",
    'olist_db rfm_final'[R_Score] <= 2 && 'olist_db rfm_final'[F_Score] >= 3, "⚠️ Em Risco",
    'olist_db rfm_final'[R_Score] <= 2 && 'olist_db rfm_final'[F_Score] <= 2, "💤 Hibernando",
    "🛒 Cliente Comum"
)

-- Cartões KPI no topo --

% Clientes Fiéis = 
VAR TotalClientes = COUNTROWS('olist_db rfm_final')
VAR Fieis = CALCULATE(COUNTROWS('olist_db rfm_final'), 'olist_db rfm_final'[Segmento RFM] IN {"🏆 Campeões", "💎 Leais"})
RETURN
DIVIDE(Fieis, TotalClientes)

--Cartão 1: Total de Clientes (Contagem distinta de unique_id).

--Cartão 2: Ticket Médio Global (Média de monetario).

--Cartão 3: % de Clientes Fiéis (Essa vamos criar agora!).