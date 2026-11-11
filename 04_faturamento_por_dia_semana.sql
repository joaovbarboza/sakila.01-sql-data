-- analisar o Volume de Faturamento e Transações por Dia da Semana.

SELECT CASE strftime('%w', (substr(payment_date, 1, 10))) 
        WHEN '0' THEN 'Domingo'
        WHEN '1' THEN 'Segunda-feira'
        WHEN '2' THEN 'Terça-feira'
        WHEN '3' THEN 'quarta-feira'
        WHEN '4' THEN 'quinta-feira'
        WHEN '5' THEN 'sexta-feira'
        WHEN '6' THEN 'sabado'
        END AS dias_semana, -- CASE WHEN para nomear os dias da semana
       COUNT(*) AS qtd_transacoes, -- quantidade de transacoes
       ROUND(SUM(amount), 2) AS receita_bruta, -- cálculo receita total
       ROUND(AVG(amount), 2) AS ticket_medio, -- cálculo ticket medio
       ROUND(SUM(amount) / (SELECT SUM(amount) FROM payment) * 100, 2) AS percentual -- cálculo representatividade percentual
FROM payment 

GROUP BY strftime('%w', (substr(payment_date, 1, 10))) -- agrupei por dias da semana

ORDER BY receita_bruta DESC -- ordenei pela maior quantidade