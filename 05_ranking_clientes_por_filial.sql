-- Identificar os melhores clientes (Top Spenders) segmentados por filial (store_id),
--  descobrindo qual é a posição de cada cliente no ranking de LTV(soma total) da sua respetiva loja
--  e calculando a distância de faturamento para o líder da mesma unidade.

WITH tab_sumario AS (
SELECT t2.first_name || ' ' || t2.last_name AS cliente, -- juntei o nome completo cliente
       ROUND(SUM(t1.amount), 2) AS faturamento_total, -- cálculo receita total
       t3.store_id 
FROM payment AS t1
LEFT JOIN customer AS t2 -- join para ligar com a tabela de clientes
ON t1.customer_id = t2.customer_id
JOIN store AS t3 -- join para ligar com a tabela da filial
ON t2.store_id = t3.store_id

GROUP BY cliente -- agrupei pelo clientes
),

ranking_tab AS(
SELECT *,
       ROW_NUMBER() OVER (PARTITION BY store_id ORDER BY faturamento_total DESC) AS ranking -- particionei entre os clientes, quem são os melhores
FROM tab_sumario
ORDER BY faturamento_total DESC -- ordenei pelo faturamento
)

SELECT *
FROM ranking_tab
WHERE ranking <= 5 -- filtrei apenas os 5 primeiros de cada filial
ORDER BY store_id
