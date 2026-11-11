-- Medir o valor de longo prazo (Lifetime Value - LTV) dos clientes da locadora
-- Queremos descobrir quanto cada cliente gasta em média no total histórico,
-- quantas transações cada um faz e identificar os clientes de maior valor (Top Clientes) para estratégias de fidelização.

SELECT t2.first_name || '' || t2.last_name AS cliente, -- juntei as 2 colunas para virar o nome completo do cliente
       COUNT(*) AS qtde_transacoes, -- quantidade de transações
       SUM(t1.amount) AS faturamento_ltv, -- valor da receita total
       ROUND(AVG(t1.amount), 2) AS valor_medio -- média da receita
FROM payment AS t1
LEFT JOIN customer AS t2 -- join para interligar com a tabela de clientes
ON t1.customer_id = t2.customer_id

GROUP BY t2.customer_id -- agrupei por clientes

ORDER BY faturamento_ltv DESC -- ordenei por maior faturamento

LIMIT 10 -- limitei os 10 primeiros