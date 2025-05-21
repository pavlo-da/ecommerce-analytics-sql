-- CTE to aggregate account data by date and other dimensions
WITH accounts_data AS (
  SELECT
    DATE(s.date) AS date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    COUNT(a.id) AS account_cnt,
    0 AS sent_msg,
    0 AS open_msg,
    0 AS visit_msg
  FROM
    `data-analytics-mate.DA.account` a
  JOIN
    `data-analytics-mate.DA.account_session` acs ON a.id = acs.account_id
  JOIN
    `data-analytics-mate.DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN
    `data-analytics-mate.DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
  GROUP BY
    1, 2, 3, 4, 5
),

-- CTE to aggregate email data by date and other dimensions
emails_data AS (
  SELECT
    DATE_ADD(s.date, INTERVAL es.sent_date DAY) AS date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    0 AS account_cnt,
    COUNT(DISTINCT es.id_message) AS sent_msg,
    COUNT(DISTINCT eo.id_message) AS open_msg,
    COUNT(DISTINCT ev.id_message) AS visit_msg
  FROM
    `data-analytics-mate.DA.email_sent` es
  JOIN
    `data-analytics-mate.DA.account` a ON es.id_account = a.id
  JOIN
    `data-analytics-mate.DA.account_session` acs ON a.id = acs.account_id
  JOIN
    `data-analytics-mate.DA.session` s ON acs.ga_session_id = s.ga_session_id
  JOIN
    `data-analytics-mate.DA.session_params` sp ON s.ga_session_id = sp.ga_session_id
  LEFT JOIN
    `data-analytics-mate.DA.email_open` eo ON es.id_message = eo.id_message
  LEFT JOIN
    `data-analytics-mate.DA.email_visit` ev ON es.id_message = ev.id_message
  GROUP BY
    1, 2, 3, 4, 5
),

-- Combine account and email metrics into one dataset
combined_data AS (
  SELECT * FROM accounts_data
  UNION ALL
  SELECT * FROM emails_data
),

-- Add total metrics per country using window functions
with_totals AS (
  SELECT
    *,
    SUM(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    SUM(sent_msg) OVER (PARTITION BY country) AS total_country_sent_cnt
  FROM
    combined_data
),

-- Add ranking for countries based on total metrics
with_ranks AS (
  SELECT
    *,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt
  FROM
    with_totals
)

-- Final result: filter top 10 countries by account or email activity
SELECT
  date,
  country,
  send_interval,
  is_verified,
  is_unsubscribed,
  account_cnt,
  sent_msg,
  open_msg,
  visit_msg,
  total_country_account_cnt,
  total_country_sent_cnt,
  rank_total_country_account_cnt,
  rank_total_country_sent_cnt
FROM
  with_ranks
WHERE
  rank_total_country_account_cnt <= 10
  OR rank_total_country_sent_cnt <= 10
ORDER BY
  date,
  total_country_account_cnt DESC,
  total_country_sent_cnt DESC,
  rank_total_country_account_cnt DESC,
  rank_total_country_sent_cnt DESC
