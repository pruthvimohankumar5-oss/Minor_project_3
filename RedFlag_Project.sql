SELECT COUNT(*) AS total_transactions
FROM redflag.transactions;
SELECT COUNT(DISTINCT user_id) AS unique_users
FROM redflag.transactions;
SELECT COUNT(DISTINCT merchant_id) AS unique_merchants
FROM redflag.transactions;
SELECT MIN(txn_time) AS earliest_transaction,
       MAX(txn_time) AS latest_transaction
FROM redflag.transactions;
SELECT 
    status,
    COUNT(*) AS transaction_count
FROM redflag.transactions
GROUP BY status
ORDER BY transaction_count DESC;
SELECT 
    payment_mode,
    COUNT(*) AS transaction_count
FROM redflag.transactions
GROUP BY payment_mode
ORDER BY transaction_count DESC;
SELECT SUM(amount) AS total_amount
FROM redflag.transactions;
SELECT AVG(amount) AS average_amount
FROM redflag.transactions;
SELECT 
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount
FROM redflag.transactions;
SELECT COUNT(*) AS high_value_transactions
FROM redflag.transactions
WHERE amount > 10000;
SELECT *
FROM redflag.transactions
WHERE amount > 10000
ORDER BY amount DESC
LIMIT 10;
SELECT
    payment_mode,
    COUNT(*) AS failed_transactions
FROM redflag.transactions
WHERE status = 'FAILED'
GROUP BY payment_mode
ORDER BY failed_transactions DESC;
SELECT
    payment_mode,
    COUNT(*) AS total_transactions,
    COUNT(CASE WHEN status = 'FAILED' THEN 1 END) AS failed_transactions,
    ROUND(
        COUNT(CASE WHEN status = 'FAILED' THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS failure_rate
FROM redflag.transactions
GROUP BY payment_mode
ORDER BY failure_rate DESC;
SELECT
    user_id,
    merchant_id,
    COUNT(*) AS transaction_count
FROM redflag.transactions
GROUP BY user_id, merchant_id
HAVING COUNT(*) > 10
ORDER BY transaction_count DESC
LIMIT 20;
SELECT
    HOUR(txn_time) AS transaction_hour,
    COUNT(*) AS transaction_count
FROM redflag.transactions
GROUP BY HOUR(txn_time)
ORDER BY transaction_hour;
SELECT *
FROM redflag.transactions
WHERE HOUR(txn_time) BETWEEN 0 AND 5
ORDER BY amount DESC
LIMIT 20;
SELECT
    user_id,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM redflag.transactions
GROUP BY user_id
HAVING COUNT(*) > 50
ORDER BY transaction_count DESC
LIMIT 20;
SELECT
    city,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM redflag.transactions
GROUP BY city
ORDER BY total_amount DESC;
SELECT
    DATE(txn_time) AS transaction_date,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM redflag.transactions
GROUP BY DATE(txn_time)
ORDER BY transaction_date;
SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    status,
    payment_mode,
    city,

    (CASE WHEN amount > 10000 THEN 1 ELSE 0 END
     + CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END
     + CASE WHEN HOUR(txn_time) BETWEEN 0 AND 5 THEN 1 ELSE 0 END)
     AS redflag_score

FROM redflag.transactions
ORDER BY redflag_score DESC, amount DESC
LIMIT 20;
SELECT
    redflag_score,
    COUNT(*) AS transaction_count
FROM (
    SELECT
        txn_id,
        (CASE WHEN amount > 10000 THEN 1 ELSE 0 END
         + CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END
         + CASE WHEN HOUR(txn_time) BETWEEN 0 AND 5 THEN 1 ELSE 0 END)
         AS redflag_score
    FROM redflag.transactions
) AS scored
GROUP BY redflag_score
ORDER BY redflag_score;
SELECT
    CASE
        WHEN redflag_score = 0 THEN 'Low'
        WHEN redflag_score = 1 THEN 'Low'
        WHEN redflag_score = 2 THEN 'Medium'
        WHEN redflag_score = 3 THEN 'High'
    END AS risk_level,
    COUNT(*) AS transaction_count
FROM (
    SELECT
        txn_id,
        (CASE WHEN amount > 10000 THEN 1 ELSE 0 END
         + CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END
         + CASE WHEN HOUR(txn_time) BETWEEN 0 AND 5 THEN 1 ELSE 0 END)
         AS redflag_score
    FROM redflag.transactions
) AS scored
GROUP BY risk_level
ORDER BY transaction_count DESC;
SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    status,
    payment_mode,
    city
FROM redflag.transactions
WHERE amount > 10000
  AND status = 'FAILED'
  AND HOUR(txn_time) BETWEEN 0 AND 5
ORDER BY amount DESC;
SELECT
    user_id,
    COUNT(*) AS high_risk_transactions,
    SUM(amount) AS total_high_risk_amount
FROM redflag.transactions
WHERE amount > 10000
  AND status = 'FAILED'
  AND HOUR(txn_time) BETWEEN 0 AND 5
GROUP BY user_id
ORDER BY high_risk_transactions DESC, total_high_risk_amount DESC;
SELECT
    merchant_id,
    COUNT(*) AS high_risk_transactions,
    SUM(amount) AS total_high_risk_amount
FROM redflag.transactions
WHERE amount > 10000
  AND status = 'FAILED'
  AND HOUR(txn_time) BETWEEN 0 AND 5
GROUP BY merchant_id
ORDER BY high_risk_transactions DESC, total_high_risk_amount DESC;
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) AS successful_transactions,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) AS failed_transactions,
    SUM(CASE WHEN amount > 10000 THEN 1 ELSE 0 END) AS high_value_transactions,
    SUM(CASE WHEN amount > 10000
              AND status = 'FAILED'
              AND HOUR(txn_time) BETWEEN 0 AND 5
             THEN 1 ELSE 0 END) AS high_risk_transactions
FROM redflag.transactions;
USE redflag;

SELECT
    CASE
        WHEN amount > 10000
             AND status = 'FAILED'
             AND HOUR(txn_time) BETWEEN 0 AND 5
            THEN 'HIGH'

        WHEN (amount > 10000 AND status = 'FAILED')
          OR (amount > 10000 AND HOUR(txn_time) BETWEEN 0 AND 5)
          OR (status = 'FAILED' AND HOUR(txn_time) BETWEEN 0 AND 5)
            THEN 'MEDIUM'

        ELSE 'LOW'
    END AS risk_level,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY risk_level
ORDER BY transaction_count DESC;
USE redflag;

SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    status,
    payment_mode,
    city,
    txn_type
FROM transactions
WHERE amount > 10000
  AND status = 'FAILED'
  AND HOUR(txn_time) BETWEEN 0 AND 5
ORDER BY amount DESC;
CREATE OR REPLACE VIEW redflag_risk_analysis AS
SELECT
    txn_id,
    user_id,
    merchant_id,
    amount,
    txn_time,
    status,
    payment_mode,
    city,
    txn_type,

    (
        (amount > 10000)
        + (status = 'FAILED')
        + (HOUR(txn_time) BETWEEN 0 AND 5)
    ) AS redflag_score,

    CASE
        WHEN (
            (amount > 10000)
            + (status = 'FAILED')
            + (HOUR(txn_time) BETWEEN 0 AND 5)
        ) = 3 THEN 'HIGH'

        WHEN (
            (amount > 10000)
            + (status = 'FAILED')
            + (HOUR(txn_time) BETWEEN 0 AND 5)
        ) = 2 THEN 'MEDIUM'

        ELSE 'LOW'
    END AS risk_level

FROM transactions;

SELECT * 
FROM redflag_risk_analysis
LIMIT 20;
SELECT
    risk_level,
    COUNT(*) AS transaction_count
FROM redflag_risk_analysis
GROUP BY risk_level
ORDER BY transaction_count DESC;


