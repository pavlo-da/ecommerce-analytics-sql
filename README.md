# Account & Email Analytics by Country (Top 10)

This project contains a comprehensive SQL query for analyzing user account creation and email engagement activity across different countries in an e-commerce context. The output can be used to power visualizations in Looker Studio or other BI tools.

## 📊 Goal

To generate a dataset that allows for:
- Monitoring account creation dynamics.
- Evaluating user engagement with emails (sent, opened, clicked).
- Comparing behavior across countries, including:
  - Send interval settings.
  - Verification status.
  - Subscription status.

## 📌 Key Metrics

The query produces the following metrics in the context of account activity and email interactions:

| Metric                        | Description                                         |
|------------------------------|-----------------------------------------------------|
| `account_cnt`                | Number of created accounts                          |
| `sent_msg`                   | Number of emails sent                               |
| `open_msg`                   | Number of emails opened                             |
| `visit_msg`                  | Number of clicks on emails                          |
| `total_country_account_cnt`  | Total accounts created per country                  |
| `total_country_sent_cnt`     | Total emails sent per country                       |
| `rank_total_country_account_cnt` | Rank of country by total accounts created      |
| `rank_total_country_sent_cnt`   | Rank of country by total emails sent           |

## 🧱 Data Breakdown

Data is grouped by:
- `date` — account creation or email sent date
- `country` — user country
- `send_interval` — email sending interval set by user
- `is_verified` — whether the account is verified
- `is_unsubscribed` — whether the user has unsubscribed

## 🛠️ Query Techniques Used

- Common Table Expressions (CTEs) to structure and isolate logic
- `UNION ALL` to merge account and email metrics
- Window functions (`SUM`, `DENSE_RANK`) to calculate totals and rankings by country

## 🎯 Filtering Criteria

The final dataset includes only top 10 countries by:
- Total accounts created
- Total emails sent

## 📈 Suggested Visualizations (Looker Studio)

1. **Bar Charts by Country**:
   - Total Accounts Created
   - Total Emails Sent
   - Rank by Account Creation
   - Rank by Email Sent

2. **Time Series Line Chart**:
   - `sent_msg` over `date` to observe engagement dynamics

## 📌 Notes

- Email and account metrics are handled separately to avoid confusion with the `date` field logic.
- Query uses `DATE_ADD` to align email-sent dates based on session info.
