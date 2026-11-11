-- Comparar o desempenho de caixa entre as duas unidades (Store 1 e Store 2).
-- Queremos entender qual filial gera maior faturamento acumulado
-- o volume total de locações processadas e qual apresenta o melhor ticket médio por transação.


SELECT t4.store_id AS filial,
       COUNT(*) AS qtde_pedidos, -- quantidade de pedidos processados
       ROUND(SUM(t1.amount), 2) AS faturamento_acumulado, -- cálculo do faturamento acumulado
       ROUND(AVG(t1.amount), 2) AS ticket_medio, -- cálculo do ticket médio por transação
       ROUND(SUM(t1.amount) / (SELECT SUM(amount) FROM payment) * 100, 2) AS percentual -- cálculo representativade percentual
FROM payment AS t1
LEFT JOIN rental AS t2 -- join com a tabela rental para obter o id do inventario
ON t1.rental_id = t2.rental_id
JOIN inventory AS t3 -- join para interligar a tabela de inventário
ON t2.inventory_id = t3.inventory_id
JOIN store AS t4 -- join para interligar a tabela de filial
ON t3.store_id= t4.store_id

GROUP BY t4.store_id -- agrupei pela filial

ORDER BY faturamento_acumulado DESC -- ordendei pelo maior faturamento