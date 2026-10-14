-- Vendedores por estado
SELECT seller_state AS estado, COUNT(*) AS vendedores
FROM sellers
GROUP BY seller_state
ORDER BY vendedores DESC;

-- Os 10 vendedores que mais venderam
SELECT oi.seller_id,
       s.seller_state AS estado,
       COUNT(DISTINCT oi.order_id) AS pedidos,
       ROUND(SUM(oi.price), 2) AS valor_vendido
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY oi.seller_id, s.seller_state
ORDER BY valor_vendido DESC
LIMIT 10;

-- Concentração do faturamento (percentual acumulado por posição)
WITH vendas AS (
    SELECT oi.seller_id, SUM(oi.price) AS valor
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY oi.seller_id
),
acumulado AS (
    SELECT seller_id,
           valor,
           ROW_NUMBER() OVER (ORDER BY valor DESC) AS posicao,
           SUM(valor) OVER (
               ORDER BY valor DESC
               ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
           ) AS valor_acumulado
    FROM vendas
)
SELECT posicao,
       ROUND(valor, 2) AS valor,
       ROUND(100.0 * valor_acumulado / (SELECT SUM(valor) FROM vendas), 1) AS pct_acumulado
FROM acumulado
WHERE posicao IN (1, 10, 50, 100, 300, 500, 1000, 2000)
ORDER BY posicao;

-- Atraso e nota média por vendedor (pelo menos 50 pedidos entregues)
WITH base AS (
    SELECT DISTINCT oi.seller_id, oi.order_id
    FROM order_items oi
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
),
avaliacao AS (
    SELECT order_id,
           review_score,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_answer_timestamp DESC
           ) AS rn
    FROM order_reviews
)
SELECT b.seller_id,
       s.seller_state AS estado,
       COUNT(*) AS pedidos,
       ROUND(100.0 * SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) / COUNT(*), 1) AS pct_atrasados,
       ROUND(AVG(a.review_score), 2) AS nota_media
FROM base b
JOIN orders o ON o.order_id = b.order_id
JOIN sellers s ON s.seller_id = b.seller_id
LEFT JOIN avaliacao a ON a.order_id = b.order_id AND a.rn = 1
GROUP BY b.seller_id, s.seller_state
HAVING COUNT(*) >= 50;

-- Valor vendido por estado do vendedor
SELECT s.seller_state AS estado,
       COUNT(DISTINCT oi.seller_id) AS vendedores,
       ROUND(SUM(oi.price), 2) AS valor_vendido,
       ROUND(100.0 * SUM(oi.price) / SUM(SUM(oi.price)) OVER (), 1) AS pct_do_valor
FROM order_items oi
JOIN orders o ON o.order_id = oi.order_id
JOIN sellers s ON s.seller_id = oi.seller_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY s.seller_state
ORDER BY valor_vendido DESC;