-- Qual é a receita bruta gerada por cada categoria de filme?
-- Qual a sua representatividade percentual no faturamento total da locadora?
-- Qual categoria entrega o maior ticket médio por transação?

WITH tab_sumario AS ( 
SELECT t1.amount,
       t5.name
FROM Payment AS t1
LEFT JOIN rental AS t2 -- join para ligar a tabela de pagamento com a tabela de locação
ON t1.rental_id = t2.rental_id
JOIN inventory AS t3 -- join para ligar a tabela de locação com a tabela de inventário
ON t2.inventory_id = t3.inventory_id
JOIN film_category AS t4 -- join para ligar a tabela de inventário com a tabela de categoria filme
on t3.film_id = t4.film_id
JOIN category AS t5 -- join para interligar a tabela de categoria filme com a tabela de categoria
ON t4.category_id = t5.category_id
)
 
SELECT name,
       ROUND(SUM(amount), 2) AS receita_bruta, -- cálculo receita bruta
       ROUND(AVG(amount), 2) AS ticket_medio, -- cálculo ticket médio
       ROUND(SUM(amount) / (SELECT SUM(amount) FROM tab_sumario) * 100, 2) AS representatividade_percentual -- cálculo percentual representatividade
FROM tab_sumario

GROUP BY name -- agrupei por categoria de filme

ORDER BY receita_bruta DESC -- ordenei por maior receita