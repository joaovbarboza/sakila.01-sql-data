# Análise Financeira e Estratégica de Vendas — Banco de Dados Sakila"

##  Abordagem e Estrutura do Repositório

Para responder a este desafio, a análise foi estruturada de forma progressiva, partindo de agregações fundamentais até consultas avançadas com **CTEs** e **Window Functions**.

* **Foco do README:** Apresentação dos resultados, gráficos mentais e recomendações de negócio geradas por cada consulta.
* **Códigos Completos:** Os scripts `.sql` comentados passo a passo estão organizados na pasta `/Northwind` para rápida consulta e auditoria.

---

## 1º Pergunta: 'Faturamento e Rentabilidade por Categoria de Filme (DRE Comercial)'
* Contexto & Objetivo de Negócio

> "O objetivo desta análise é responder a uma questão fundamental para a gestão estratégica de uma locadora: Quais categorias de filmes geram maior valor financeiro para o negócio? Para isso, avaliamos o faturamento bruto acumulado, a representatividade percentual de cada gênero no total da receita e o ticket médio por transação de aluguel."

```sql
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
```

### Resultado:

| name | receita_bruta | ticket_medio | representatividade_percentual |
| :--- | :--- | :--- | :--- |
| **Sports** | $ 5.314,21 | $ 4,51 | 7,88% |
| **Sci-Fi** | $ 4.756,98 | $ 4,32 | 7,06% |
| **Animation** | $ 4.656,30 | $ 3,99 | 6,91% |
| **Drama** | $ 4.587,39 | $ 4,33 | 6,81% |
| **Comedy** | $ 4.383,58 | $ 4,66 | 6,50% |
| **Action** | $ 4.375,85 | $ 3,94 | 6,49% |
| **New** | $ 4.351,62 | $ 4,63 | 6,46% |
| **Games** | $ 4.281,33 | $ 4,42 | 6,35% |
| **Foreign** | $ 4.270,67 | $ 4,13 | 6,34% |
| **Family** | $ 4.226,07 | $ 3,86 | 6,27% |
| **Documentary** | $ 4.217,52 | $ 4,02 | 6,26% |
| **Horror** | $ 3.722,54 | $ 4,40 | 5,52% |
| **Children** | $ 3.655,55 | $ 3,87 | 5,42% |
| **Classics** | $ 3.639,59 | $ 3,88 | 5,40% |
| **Travel** | $ 3.549,64 | $ 4,24 | 5,27% |
| **Music** | $ 3.417,72 | $ 4,12 | 5,07% |

### Insights Executivos e Leitura de Negócio

* **Genêros Favoritos**: A categoria Sports lidera o ranking absoluto, gerando a maior receita bruta total e representando cerca de 7,88% de todo o faturamento da empresa.

* **Top 3**: Sci-fi e Animation constituem o top 3, somando a representidade, as 3 categoria têm aproximadamente 20% de vendas de todas as categorias.

* **Comportamento do Ticket Médio**: Embora Sports lidere na receita bruta total devido ao volume, categorias como Comedy e New destacam-se com tickets médios unitários ligeiramente superiores por transação.

## 2º Pergunta: 'Performance Financeira por Filial (Store 1 vs Store 2) e Ticket Médio'
* Contexto & Objetivo de Negócio

> "O objetivo desta análise é avaliar o equilíbrio operacional e financeiro entre as unidades físicas da empresa. Analisamos o faturamento acumulado, o volume total de pedidos e o ticket médio de cada filial para entender qual loja gera mais receita e qual tem maior eficiência por venda.."

```sql
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
```

### Resultado:

| filial | qtde_pedidos | faturamento_acumulado | ticket_medio | percentual |
| :--- | :--- | :--- | :--- | :--- |
| **2** | 8121 | $ 33.726,77 | $ 4,15 | 50,03% |
| **1** | 7923 | $ 33.679,79 | $ 4,25 | 49,96% |

### Insights Executivos e Leitura de Negócio

* **Relevância**: A filial 2 obtêm os melhores números, sendo assim, a mais valorizada. Porém a diferença é pouca, ou seja, a empresa contém uma boa distribuição de receita. 

* **Volume x ticket medio**: Por mais que a filial 2 possui o melhor faturamento(mesmo que a diferença seja pouca), a filial 1 possui o maior ticket médio, o que indica que os clientes dessa filial alugam filmes categorias com preços levementes mais altos.

## 3º Pergunta: Análise de LTV (Lifetime Value) e Valor dos Clientes
* Contexto & Objetivo de Negócio

> "O objetivo desta análise é identificar a retenção e o valor de longo prazo (Lifetime Value - LTV) da base de clientes. Identificar os clientes que geram maior faturamento acumulado permite desenhar programas de fidelização, estratégias de retenção VIP e entender o teto de gastos por utilizador."

```sql
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
```

### Resultado:

| cliente | qtde_transacoes | faturamento_ltv | valor_medio |
| :--- | :--- | :--- | :--- |
| **KARL SEAL** | 45 | $ 221,55 | $ 4,92 |
| **ELEANOR HUNT** | 46 | $ 216,54 | $ 4,71 |
| **CLARA SHAW** | 42 | $ 195,58 | $ 4,66 |
| **MARION SNYDER** | 39 | $ 194,61 | $ 4,99 |
| **RHONDA KENNEDY** | 39 | $ 194,61 | $ 4,99 |
| **TOMMY COLLAZO** | 38 | $ 186,62 | $ 4,91 |
| **WESLEY BULL** | 40 | $ 177,60 | $ 4,44 |
| **TIM CARY** | 39 | $ 175,61 | $ 4,50 |
| **MARCIA DEAN** | 42 | $ 175,58 | $ 4,18 |
| **ANA BRADLEY** | 34 | $ 174,66 | $ 5,14 |

### Insights Executivos e Leitura de Negócio

*  **Top 1** O cliente Karl Seal lidera o ranking de LTV acumulado, gerando $221,55 ao longo de 45 locações

* **Frequência vs. Ticket Médio**: A cliente Eleanor Hunt realizou o maior número de transações entre o Top 10, ficando em segundo lugar em LTV.
A cliente Ana Bradley, apesar de estar na 10ª posição em LTV total, destaca-se por possuir o maior ticket médio unitário entre os campeões, alugando filmes com valor unitário mais elevado em menos visitas.

## 4º Pergunta: Volume de Faturamento e Transações por Dia da Semana
* Contexto & Objetivo de Negócio

> "O objetivo desta análise é identificar os padrões de consumo e pico de faturamento da locadora ao longo da semana. Compreender quais dias registam maior volume de locações e faturamento permite otimizar escalas de atendimento, gerir o fluxo de caixa semanal e criar campanhas promocionais focadas em dias de menor movimento.."

```sql
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
```

### Resultado:

| dia_semana | qtd_transacoes | receita_bruta | ticket_medio | percentual |
| :--- | :--- | :--- | :--- | :--- |
| **Terça-feira** | 2465 | $ 10.220,35 | $ 4,15 | 15,16% |
| **Sábado** | 2313 | $ 9.936,87 | $ 4,30 | 14,74% |
| **Domingo** | 2320 | $ 9.745,80 | $ 4,20 | 14,46% |
| **Sexta-feira** | 2273 | $ 9.566,27 | $ 4,21 | 14,19% |
| **Segunda-feira** | 2247 | $ 9.345,53 | $ 4,16 | 13,86% |
| **Quinta-feira** | 2200 | $ 9.336,00 | $ 4,24 | 13,85% |
| **Quarta-feira** | 2231 | $ 9.265,69 | $ 4,15 | 13,74% |

### Insights Executivos e Leitura de Negócio

* **Pico semanal**: Terça-feira é o dia que mais têm vendas, ou seja, o dia mais valioso dentre os outros.

* **Frequência vs. Ticket Médio**: Por mais que a terça seja o dia que mais teve vendas, o ticket medio da sexta-feira e da quinta-feira é maior, significa que nesses dias as vendas são de produtos levemente mais caros.

* **Dia Menor Faturamento**: Na quarta-feira é o pior dia da empresa, é o dia ideal para alavancar com estratégias de obter novos clientes e realizar ações comerciais de incentivo a locação de filmes.

## 5º Pergunta: Ranking de Clientes (Top Spenders) por Filial via Window Functions
* Contexto & Objetivo de Negócio

> "O objetivo desta análise é identificar os clientes de maior valor financeiro (LTV) de forma segmentada por unidade física. Utilizei Funções de Janela e com isso consegui ranquear isoladamente os clientes dentro de cada filial, permitindo que a gerência local crie estratégias regionalizadas de retenção e programas VIP."

```sql
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
```

### Resultado:

| cliente | faturamento_total | store_id | ranking |
| :--- | :--- | :--- | :--- |
| **ELEANOR HUNT** | $ 216,54 | 1 | 1 |
| **CLARA SHAW** | $ 195,58 | 1 | 2 |
| **TOMMY COLLAZO** | $ 186,62 | 1 | 3 |
| **TIM CARY** | $ 175,61 | 1 | 4 |
| **MARCIA DEAN** | $ 175,58 | 1 | 5 |
| **KARL SEAL** | $ 221,55 | 2 | 1 |
| **MARION SNYDER** | $ 194,61 | 2 | 2 |
| **RHONDA KENNEDY** | $ 194,61 | 2 | 3 |
| **WESLEY BULL** | $ 177,60 | 2 | 4 |
| **ANA BRADLEY** | $ 174,66 | 2 | 5 |

### Insights Executivos e Leitura de Negócio

* **Melhores Clientes**: Os melhores clientes da filial 1 e 2 respectivamentes são, Eleanor Hunt(filial 1) e Karl Seal(Filial 2), seria interessanete a empresa parabenizá-los de alguma forma, brindes ou descontos.

* **Concentração de Receita VIP**: O Top 5 da Filial 1 acumula $949,93, enquanto o Top 5 da Filial 2 acumula $963,03, mostrando um nível de consumo dos clientes VIP extremamente equilibrado entre as duas unidades.