<!--
README WORKING TEMPLATE
- Sections marked [TODO] are still to be written.
- Every number below comes from query output in scripts/eda/. Never estimate figures.
- Sections marked DRAFT are written but should be reviewed before publishing.
- Delete these HTML comments once a section is finished.
-->

<!--
FINAL RESTRUCTURE PLAN (apply after dashboards are done; reference style: github.com/gh-joeyleung/Tech-Hub-E-Commerce-Analysis)
Audience: stakeholders and non-technical readers. Lead with the business story; move technical detail to an appendix.

Target structure:
  1. Background and Overview  - company, decision, stakeholder in plain words (from current Section 2)
  2. Executive Summary        - 3-4 headline numbers, 4 short finding bullets, one-line recommendation
  3. Summary of Insights      - 4 narrative subsections, each with its chart (from current Section 4)
  4. Recommendations          - grouped by team (CRM, E-commerce, Merchandising), each tied to a metric to watch
  5. Dashboard                - screenshot + Tableau Public link
  6. Appendix                 - metric definitions (current Section 3), detail tables, caveats,
                                architecture, data sources, data quality, repo structure, how to run, next steps

Writing style for insights:
  - Put the number and its meaning in the same sentence; bold the key number.
  - Each paragraph moves the story forward (what happened -> what changed -> where it landed -> why).
  - Use only numbers that support the point; detail tables go in collapsible <details> blocks or the appendix.
  - Phrase causes as interpretations ("suggests", "most likely"), since they are hypotheses, not known external events.
  - Keep caveats to one short line in the main text; full caveats live in the appendix.
  - Keep the decision framing and recommendations: they are what set this project apart from descriptive READMEs.
  - The North Star metrics (Section 3) stay as the reference for what each insight must highlight.
-->

# [TODO: Final title]
<!-- Options:
  A) Adventure Works Cycles: Finding the Customers Worth Keeping — a PostgreSQL Warehouse & Retention Analysis
  B) Too Many Bikes in One Basket? Product-Mix Risk at Adventure Works Cycles
  C) An Add-on, Not a Way In: Range Expansion Analysis at Adventure Works Cycles -->

**Tools:** PostgreSQL · PL/pgSQL · SQL window functions · draw.io · Tableau Public
**Data:** AdventureWorks sample data (CRM + ERP CSV exports), orders from 29 Dec 2010 to 28 Jan 2014. All monetary values in US dollars (USD).

---

## 1. Executive Summary
<!-- DRAFT: review wording before publishing. -->
Adventure Works Cycles earns **96.46%** of its revenue from bikes. From December 2012 it began selling a lower-priced Accessories & Clothing range, which brought in many new customers, but in this dataset **none of the 9,350** customers whose first purchase was an accessory or clothing item went on to buy a bike. The range works well as an add-on instead: **87.6%** of bike orders include an accessory or clothing item. **Recommendation:** stop treating Accessories & Clothing as a way to win new customers; invest in keeping bike buyers (VIPs are 8.75% of customers but 35.94% of revenue) and in selling add-ons at the point of the bike purchase.

**Headline numbers**

| Metric | Value |
|---|---|
| Total revenue | $29,356,250 |
| Total orders | 27,659 |
| Customers who purchased | 18,482 |
| Average order value | $1,061.36 |
| Items sold | 60,423 |
| Products sold (of 295 in the catalogue) | 130 |

<!-- Source: scripts/eda/measures_exploration.sql (key metrics report).
     Customers who purchased excludes 2 customers whose only orders have invalid (NULL) dates.
     Customer-level revenue totals $29,351,258; the $4,992 gap to $29,356,250 is sales on the 19 undated order lines. -->

---

## 2. Business Problem & Strategic Context

- **Company context:** Adventure Works Cycles is a bicycle manufacturer selling directly to consumers in several countries. Until late December 2012 its customers bought only high-value Road, Mountain and Touring bikes. From 28 December 2012, a lower-priced range of Accessories and Clothing began appearing in customer orders.
- **Stakeholder:** Director of Sales & Marketing, who decides both which products to invest in and how to spend the customer acquisition and retention budget.
- **The decision:** Should the business keep growing its lower-priced Accessories and Clothing range to attract new customers, or focus on keeping and growing its loyal, high-spending bike buyers?
- **Why it matters:** Bikes generate **96.5%** of revenue, so the business is heavily exposed if bike demand slows. At the same time, **80%** of customers have less than 12 months of purchase history, and **62.9%** buy only once. Meanwhile, fewer than 1 in 10 customers (VIPs) bring in over a third of revenue (**35.9%**). Investing in the wrong area means spending money on customers who won't return, while the core business stays at risk.

### Core business questions
1. **How dependent are we on bikes?** Is the rest of the range growing enough to reduce that risk?
2. **Who are our most valuable customers?** How do loyal, high-spending customers compare with new ones, and are new customers coming back to buy again?
3. **Did adding Accessories & Clothing work?** Did it bring in new customers, and did those customers go on to buy a bike, or stop at a cheap item?
4. **Do bike buyers also buy accessories?** How often does a bike purchase come with accessories, and is the Accessories & Clothing range more valuable as an add-on for existing customers than as a way to attract new ones?

> **Note on timing:** Accessories and Clothing exist in the product catalogue from 2011–2012, but their first recorded sale is 28 Dec 2012. This analysis uses that date as the start of the range's sales and makes no claim about why sales began then. The data ends in January 2014, so customers who arrived with the range have had at most about 13 months to return. Findings on their repeat purchases are early signals rather than final results.

| Question | Answered by |
|---|---|
| Q1 | `scripts/eda/part_to_whole_analysis.sql`, `magnitude_analysis.sql`, `performance_analysis.sql` |
| Q2 | `scripts/eda/data_segmentation.sql`, `customer_report.sql` |
| Q3 | `scripts/eda/range_expansion_analysis.sql` |
| Q4 | `scripts/eda/attach_rate.sql`, `product_report.sql` |

---

## 3. Key Metrics (North Star)
<!-- RESTRUCTURE: move this section to the Appendix as "Metric definitions". Keep it as the checklist of
     numbers the insights, executive summary and recommendations must tie back to. -->

**North Star metrics:** each one measures the outcome of one side of the decision.

| Metric | Business definition | Baseline | Source script |
|---|---|---|---|
| **Bike Revenue Share** | % of total revenue that comes from bikes, i.e. how exposed the business is if bike demand slows | **96.46%** overall; **93.94%** in 2013, the first full year of the range (add-ons 6.06%) | `part_to_whole_analysis.sql`, `gold.report_sales` |
| **6-Month Repeat Rate** | % of customers who ordered again within 6 months of their first order, by join period and entry type (only customers with a full 6 months of data) | After range, Accessory/Clothing-first **20.6%** · After range, Bike-first **3.5%** · Before range, Bike-first **4.0%** | `range_expansion_analysis.sql` |
| **Accessory-to-Bike Conversion** | % of customers whose first purchase was an accessory or clothing item who later bought a bike | **0.0%** (0 of 9,350); 0.0% within 6 months (0 of 5,175) | `range_expansion_analysis.sql` |
| **Bike Attach Rate** | % of orders containing a bike that also contain an accessory or clothing item | **87.6%** (8,560 of 9,775), adding **$47.62** per order | `attach_rate.sql` |

**Supporting metrics:** these back up the argument but don't measure either strategy's outcome.

| Metric | Baseline | Source script |
|---|---|---|
| Loyal customer revenue share | VIP: **8.75%** of customers → **35.94%** of revenue · VIP + Regular: **19.78%** → **59.82%** | `data_segmentation.sql` |
| One-time buyer rate (all time) | **62.86%** (11,617 of 18,482) | `data_segmentation.sql` |

**Definitions**
- **VIP:** at least 12 months of purchase history and total spend over $5,000
- **Regular:** at least 12 months of history and total spend of $5,000 or less
- **New:** less than 12 months of purchase history
- **One-time / Repeat buyer:** exactly one order / two or more orders
- **Bike-first / Accessory-Clothing-first:** whether a bike was bought on the customer's first purchase day
- **Joined before / after range:** first order before / on or after 28 Dec 2012
- **Add-on:** any Accessories or Clothing item

**Calculation rules**
- Revenue totals include every order line. Customer-level and time-based metrics exclude the 19 order lines with invalid (NULL) order dates.
- Ages and recency are measured from the last order date in the data (28 Jan 2014), not today's date.

---

## 4. Insights
<!-- Pattern for each insight: finding (with the number) → why it likely happens → so what. Link the chart underneath. -->
<!-- RESTRUCTURE: rewrite each insight as 2-3 short narrative paragraphs (see example rewrites under Insights 1 and 3).
     Move the detail tables into <details><summary>See the numbers</summary> ... </details> blocks. -->

<!-- EXAMPLE NARRATIVE REWRITE (Insight 1):
### Bikes Carry the Business
Bikes generated **96.5%** of Adventure Works' **$29.4M** revenue. Until late December 2012, bikes were the only products customers bought, so the business grew entirely on one category.

The Accessories & Clothing range, which began selling in December 2012, has not changed that picture. In 2013, its first full year, it contributed **$991K**, just **6.1%** of revenue, while bike sales reached **$15.4M**.

This is a price gap rather than a demand problem. Add-on items sell for tens of dollars against thousands for a bike, so even strong add-on sales barely move the revenue mix.
-->
### Insight 1: Bikes are 96% of revenue, and even the 2013 growth came almost entirely from bikes
- **What:** Bikes $28,316,272 (**96.46%**) · Accessories $700,262 (2.39%) · Clothing $339,716 (1.16%) of $29,356,250 total. *Source: `part_to_whole_analysis.sql`*

  | Year | Revenue | Change | Add-on revenue | Bike share |
  |---|---|---|---|---|
  | 2011 | $7,075,088 | – | $0 | 100.00% |
  | 2012 | $5,842,231 | ▼ 17.4% | $2,788 | 99.95% |
  | 2013 | $16,344,878 | ▲ 179.8% | $991,171 | **93.94%** |

  *Full years only; 2010 (Dec only) and 2014 (Jan only) are excluded. Source: `part_to_whole_analysis.sql` (bike vs add-on share by year)*

  Revenue nearly tripled in 2013 (+$10,502,647), and **bikes drove 90.6% of that growth** (+$9,514,264). Add-ons contributed 9.4% (+$988,383). Add-ons were **81.6% of units sold in 2013 but only 6.06% of revenue**.

  | Year | Bike units | Revenue per bike | Add-on units | Revenue per add-on unit |
  |---|---|---|---|---|
  | 2011 | 2,216 | $3,192.73 | – | – |
  | 2012 | 3,269 | $1,786.31 | 128 | $21.78 |
  | 2013 | 9,704 | $1,582.20 | 43,103 | $23.00 |

  *Source: `part_to_whole_analysis.sql` (units vs revenue by product type and year)*

  The 2013 growth came from selling **almost three times as many bikes** (+196.8%) at a lower average price. In 2012, revenue fell 17.4% even though bike units rose 47.5%, because revenue per bike fell 44.1%.
- **Why:** This is a price-point problem, not a demand problem. Accessories and Clothing only began selling in December 2012 and are low-priced items, so even very high volumes add little revenue (in 2013, revenue per unit was $1,582.20 for a bike against $23.00 for an add-on, so one bike is worth about 69 add-on units).
- **So what:** The range has not diversified revenue. Even in 2013, its first full year, add-ons made up only **6.06%** of revenue. Both the business and its growth depend on bike volume, so any slowdown in bike demand would hit almost all of the business, and the bike customer base is the asset to protect.

![Revenue by year and product group, 2011–2013](tableau/revenue.png)

![2013 share of units vs share of revenue](tableau/units_vs_revenue.png)

<!-- Note: the yearly figures come from gold.report_sales, which excludes the 19 undated order lines;
     the overall category split uses all order lines. The bike share is 96.46% on both bases. -->

### Insight 2: 8.75% of customers (VIP) generate 35.94% of revenue, while 62.86% of customers bought only once
- **What:**

  | Segment | Customers | % of customers | Revenue | % of revenue | Revenue per customer |
  |---|---|---|---|---|---|
  | New | 14,826 | 80.22% | $11,794,065 | 40.18% | $795.50 |
  | Regular | 2,039 | 11.03% | $7,008,044 | 23.88% | $3,437.00 |
  | VIP | 1,617 | 8.75% | $10,549,149 | 35.94% | $6,523.90 |

  | Buyer type | Customers | % of customers | Revenue | % of revenue |
  |---|---|---|---|---|
  | Repeat | 6,865 | 37.14% | $22,604,546 | 77.01% |
  | One-time | 11,617 | 62.86% | $6,746,712 | 22.99% |

  *Source: `data_segmentation.sql`*
- **Why:** Most customers are recent and bikes are rarely bought twice in a short time. On a fair 6-month window, bike buyers who joined after the range came back at about the same rate as earlier bike buyers (**3.5% vs 4.0%**). The high one-time rate most likely reflects how recently most customers joined, rather than a drop in loyalty among bike buyers. *Source: `range_expansion_analysis.sql`*
- **So what:** Repeat buyers bring in over three-quarters of revenue. Keeping customers, and giving them reasons to come back between bike purchases, is worth far more than winning new one-off buyers.

![Share of customers vs share of revenue by customer segment](tableau/customer_segment.png)

![Share of customers vs share of revenue: repeat vs one-time buyers](tableau/repeat_vs_onetime_buyer.png)

<!-- EXAMPLE NARRATIVE REWRITE (Insight 3):
### New Range, New Customers, but Not Bike Buyers
The new range brought in **9,350** first-time customers, but **none of them went on to buy a bike**. About 1 in 5 came back, only to buy more accessories. Each spent **$68** on average, compared with **$1,444** for a customer whose first purchase was a bike.

Comparing every customer over the same six months after their first order, the pattern holds: **21%** of accessory-first customers returned, and **0%** bought a bike.

This suggests the range attracts a different audience, most likely existing riders buying gear, rather than future bike buyers.
-->
### Insight 3: Accessories and Clothing bring in customers, but they don't go on to buy bikes
- **What:** Since Accessories & Clothing started selling (28 Dec 2012), **9,350** customers made an accessory or clothing item their first purchase. In this dataset, **none of them later bought a bike.** 19.9% came back, only to buy more accessories, and each spent **$67.59** on average. A bike-first customer who joined in the same period spent **$1,443.62** (21× more).

  | Join period | Entry type | Customers | Later bought a bike | Came back for anything | Revenue per customer |
  |---|---|---|---|---|---|
  | Joined after range | Accessory/Clothing-first | 9,350 | 0.0% | 19.9% | $67.59 |
  | Joined after range | Bike-first | 3,704 | 2.2% | 2.2% | $1,443.62 |
  | Joined before range | Bike-first | 5,428 | 90.7% | 90.7% | $4,305.86 |

  **Fair comparison (6-month window, customers with a full 6 months of data):**

  | Join period | Entry type | Customers | Came back within 6 months | Bought a bike within 6 months |
  |---|---|---|---|---|
  | Joined after range | Accessory/Clothing-first | 5,175 | 20.6% | **0.0%** |
  | Joined after range | Bike-first | 1,755 | 3.5% | 3.5% |
  | Joined before range | Bike-first | 5,428 | 4.0% | 4.0% |

  *Source: `range_expansion_analysis.sql`*
- **Why:** The two groups behave as separate markets. Accessory buyers never moved up to bikes, and bike buyers who came back almost always did so for bikes. The range most likely attracts people buying gear rather than future bike buyers.
- **So what:** The range isn't working as a way to bring in future bike buyers. Its value is as an add-on (Insight 4).
- **Caveats:** the all-time figures aren't like-for-like (customers who joined before the range had up to about 37 months to return; later customers at most about 13), which is why the 6-month comparison above is the fair test. A perfect 0% may also partly reflect how the AdventureWorks sample data was generated, so it is a finding about this dataset rather than a rule of customer behaviour.

![Return rate within 6 months by join period and entry type](tableau/return_rate_6.png)

  *The interactive dashboard also offers a 3-month window, with the same pattern: accessory-first 11.1% came back and 0.0% bought a bike (7,446 customers); bike-first after range 0.5% (2,708); bike-first before range 0.9% (5,428). Source: `range_expansion_analysis.sql` with `window_months = 3`.*

![Revenue per customer: bike-first vs accessory-first customers who joined after 28 Dec 2012](tableau/revenue_per_customer.png)

  *Customers who joined before the range ($4,305.86 each, 5,428 customers) are left out of this chart because they had up to about 37 months to spend, against about 13 for customers who joined after.*

### Insight 4: Accessories and Clothing work as an add-on to bike sales
- **What:** **87.6%** of bike orders since 28 Dec 2012 (8,560 of 9,775) include an Accessories or Clothing item, adding **$47.62** per order on average. Orders without a bike still bring in 60.8% of add-on revenue ($631,981 vs $407,620), but the whole range is worth only about $1.04M, against $28.3M from bikes. *Source: `attach_rate.sql`*
- **Why:** Bike buyers most likely kit out a new bike at the point of purchase. They almost never come back for accessories later: only $60 of add-on spend by bike buyers happened outside a bike order.
- **So what:** The range adds value by **raising the value of each bike sale**, not by bringing in future bike buyers.
- **Also:** even the most popular add-on, the Water Bottle – 30 oz., is bought with a bike in only 50.4% of its orders. And 165 of the 295 catalogue products never sold, including **15 of 35 Clothing products (43%)**. *Sources: `product_report.sql`, `magnitude_analysis.sql`*

<!-- Chart to add: ![Bike attach rate](tableau/attach_rate.png) -->

> **Overall:** the range works as an add-on, not as a way in. Bike buyers add accessories to almost every order, but accessory buyers never go on to buy bikes.

---

## 5. Recommendations
<!-- DRAFT: expected impact is qualitative; do not add figures that no query produced. -->
<!-- RESTRUCTURE: group recommendations by owning team (e.g. CRM & Retention, E-commerce, Merchandising) as numbered
     lists in plain language, each ending with the metric to watch. The table can move to the Appendix. -->

| Priority | Action | Owner | Expected impact | Metric to track |
|---|---|---|---|---|
| P0 | Retention programme for VIP and Regular bike buyers (loyalty offers, service reminders) | Director of Sales & Marketing (CRM) | Protects the customers who bring in most revenue | 6-Month Repeat Rate; loyal customer revenue share |
| P0 | Bundle and suggest add-ons at bike checkout | Director of Sales & Marketing (e-commerce / merchandising) | Builds on existing demand (87.6% attach) to raise bike order value | Bike Attach Rate (baseline 87.6%); add-on revenue per bike order (baseline $47.62) |
| P1 | Shift acquisition spend away from accessory-led campaigns and towards bike buyers | Director of Sales & Marketing (acquisition) | Stops paying to acquire customers who spend about $68 each and, in this data, never went on to buy bikes | Accessory-to-Bike Conversion within 6 months (baseline 0%) |
| P1 | Test follow-up accessory offers for existing bike owners | Director of Sales & Marketing (CRM) | Hypothesis to test: bike buyers rarely return for accessories today | Add-on revenue from bike buyers outside bike orders |
| P2 | Review the Clothing range | Merchandising | 43% of Clothing products never sold | Clothing products with at least one sale |

---

## 6. Dashboard
<!-- Screenshot of the Tableau dashboard built on the report views, plus the Tableau Public link. -->
[TODO: dashboard screenshot and Tableau Public link]

<!-- DRAFT plan: one view per insight, so the dashboard reads in the same order as Section 4.
| View | Shows | Insight | Source |
|---|---|---|---|
| KPI tiles | Bike Revenue Share, Bike Attach Rate, Accessory-to-Bike Conversion, 6-Month Repeat Rate | All | report_sales, report_customers |
| Bike vs add-on revenue by year | Stacked bars, 2011–2013 (flag 2010/2014 as partial) | 1 | report_sales (order_year, line_type) |
| Customers vs revenue by segment | Side-by-side bars: % of customers vs % of revenue for VIP / Regular / New | 2 | report_customers (customer_segment) |
| Entry path comparison | Customers, came back, later bought a bike, revenue per customer by join_period × entry_type | 3 | report_customers (join_period, entry_type) |
| Bike orders with / without add-ons | Share of bike orders with an add-on; top add-on products | 4 | report_sales (order_type), report_products |
Export each view as PNG to tableau/ and link it under its insight. -->

**Data sources** (exported to CSV for Tableau Public)

| View | Grain | Rows | Script |
|---|---|---|---|
| `gold.report_customers` | One row per customer | 18,482 | `scripts/eda/customer_report.sql` |
| `gold.report_products` | One row per product sold | 130 | `scripts/eda/product_report.sql` |
| `gold.report_sales` | One row per order line | 60,379 | `scripts/eda/sales_report.sql` |

All three views exclude undated order lines and total $29,351,258 in sales.

---

<!-- RESTRUCTURE: everything from here down (Sections 7-12) moves under a single "## Appendix: Technical Details"
     heading, so non-technical readers can stop after the Dashboard section. -->

## 7. Data Warehouse Architecture

![High-level architecture](docs/data_architechture.png)
<!-- TODO: rename file to data_architecture.png and update this link. -->

| Layer | Object type | Load | What happens |
|---|---|---|---|
| **Bronze** | Tables | Truncate & insert (`bronze.load_bronze`) | Raw CSVs loaded as-is |
| **Silver** | Tables | Truncate & insert (`silver.load_silver`) | Cleaning, standardisation, deduplication, derived columns |
| **Gold** | Views | None | Star schema for reporting: `dim_customers`, `dim_products`, `fact_sales` |

### Data flow
![Data flow](docs/data_flow.png)

### Source integration
![Data integration](docs/data_integration.png)

### Star schema
![Data model](docs/data_model.png)

Full column definitions: [`docs/data_catalog.md`](docs/data_catalog.md)

---

## 8. Data Sources

| System | File | Rows | Contents |
|---|---|---|---|
| CRM | `cust_info.csv` | 18,493 | Customer names, marital status, gender, create date |
| CRM | `prd_info.csv` | 396 | Products, cost, product line, validity dates |
| CRM | `sales_details.csv` | 60,398 | Order lines: dates, sales, quantity, price |
| ERP | `CUST_AZ12.csv` | 18,483 | Customer birth date and gender |
| ERP | `LOC_A101.csv` | 18,484 | Customer country |
| ERP | `PX_CAT_G1V2.csv` | 36 | Product category, subcategory, maintenance flag |

<!-- Row counts are raw file rows excluding the header. -->

---

## 9. Data Quality & Cleaning
<!-- Hiring managers value this. Add before/after counts where you have them. -->

| Issue found | Fix applied (silver layer) |
|---|---|
| Duplicate customer records | Kept latest record per `cst_id` using `ROW_NUMBER()` |
| Leading/trailing spaces in names | `TRIM()` |
| Coded values (`M`, `S`, `F`, `R`…) | Mapped to readable labels |
| Invalid integer dates (0 or wrong length) | Set to `NULL`, valid ones cast to `DATE` |
| Missing, negative or inconsistent sales | Recalculated as `quantity × ABS(price)` |
| Missing or invalid price | Derived as `sales / quantity` |
| Future birth dates | Set to `NULL` |
| Inconsistent country codes (`US`, `USA`, `DE`) | Standardised to full names |
| Missing product end dates | Derived with `LEAD(start_date) − 1 day` |

**Known limitations**
- Customer `create_date` values fall in Oct 2025–Jan 2026, after all orders (2010–2014); not used for tenure analysis.
- Gold surrogate keys are generated with `ROW_NUMBER()` and can change if source data changes.
- `dim_products` holds current products only, so sales of historical product versions may have a null `product_key`.
- All monetary values are in US dollars (USD), the base currency of Microsoft's AdventureWorks sample data. Source amounts are whole dollars.
- 19 order lines ($4,992 in sales) have invalid order dates. They are included in revenue totals but excluded from customer-level and time-based metrics.
- 2010 (from 29 Dec) and 2014 (to 28 Jan) are partial years, so year-on-year changes involving them should be read with caution.
- 7 pedal products have category ID `CO_PE`, which has no match in the ERP category file, so their category is NULL. None were sold.
- 165 of the 295 catalogue products were never sold (all 134 Components plus 9 Bikes, 15 Clothing and 7 Accessories), so `product_key` values in the report views have gaps.
- Product line `S` is mapped to `other Sales` (lower-case "o") in the silver layer; it is relabelled in Tableau.
- Birth dates range from 1916 to 1986 (customers aged 27–97 at the end of the data).

Quality checks: [`tests/quality_checks_silver.sql`](tests/quality_checks_silver.sql), [`tests/quality_checks_gold.sql`](tests/quality_checks_gold.sql)

---

## 10. Repository Structure
<!-- TODO: update once the folder cleanup is done. -->

```
sql-data-warehouse-project/
├── datasets/
│   ├── source_crm/          # CRM CSV exports
│   └── source_erp/          # ERP CSV exports
├── docs/                    # Architecture diagrams and data catalog
├── scripts/
│   ├── init_database.sql    # Creates database and schemas
│   ├── bronze/              # Raw load DDL and procedure
│   ├── silver/              # Cleaning DDL and procedure
│   ├── gold/                # Star schema views
│   └── eda/                 # Analysis queries and Tableau report views
│       ├── range_expansion_analysis.sql   # Q3
│       ├── attach_rate.sql                # Q4
│       ├── customer_report.sql            # gold.report_customers
│       ├── product_report.sql             # gold.report_products
│       └── sales_report.sql               # gold.report_sales
├── tests/                   # Data quality checks
├── tableau/                 # Report view CSV exports, Tableau workbook (dw.twbx) and chart images
├── results/                 # Saved query outputs referenced in the README
└── README.md
```

---

## 11. How to Run

**Prerequisites:** PostgreSQL [TODO: version], `psql` or pgAdmin

```bash
# 1. Create database and schemas
psql -U postgres -f scripts/init_database.sql

# 2. Create tables
psql -U postgres -d DataWarehouse -f scripts/bronze/ddl_bronze.sql
psql -U postgres -d DataWarehouse -f scripts/silver/ddl_silver.sql

# 3. Create load procedures
psql -U postgres -d DataWarehouse -f scripts/bronze/proc_load_bronze.sql
psql -U postgres -d DataWarehouse -f scripts/silver/proc_load_silver.sql

# 4. Load data
psql -U postgres -d DataWarehouse -c "CALL bronze.load_bronze();"
psql -U postgres -d DataWarehouse -c "CALL silver.load_silver();"

# 5. Build gold views
psql -U postgres -d DataWarehouse -f scripts/gold/ddl_gold.sql

# 6. Build the Tableau report views (report_customers must come before report_sales)
psql -U postgres -d DataWarehouse -f scripts/eda/customer_report.sql
psql -U postgres -d DataWarehouse -f scripts/eda/product_report.sql
psql -U postgres -d DataWarehouse -f scripts/eda/sales_report.sql
```
<!-- TODO: step 1 creates the schemas while connected to the default database, not DataWarehouse; fix init_database.sql or add a \c DataWarehouse step.
     TODO: proc_load_bronze.sql uses absolute /Users/manaswinid/... paths; explain how to change them. -->

---

## 12. Next Steps
<!-- What you'd do with more time; shows judgement. -->
<!-- DRAFT -->
- **Longer retention window:** re-run the repeat-rate comparison at 12 months once more post-range data is available (today too few post-range customers have a full 12 months).
- **Test the add-on strategy:** measure whether checkout bundles raise add-on revenue per bike order above the $47.62 baseline.
- **Incremental loads:** replace full truncate-and-insert loads with incremental loads for the sales table.
- **Portability:** replace hard-coded file paths in `proc_load_bronze.sql` with a configurable path, and fix `init_database.sql` so the schemas are created inside `DataWarehouse`.

---

## Acknowledgements
Dataset derived from Microsoft's AdventureWorks sample database. [TODO: credit any course or tutorial that informed the project structure.]

## About Me
**Manaswini Doma** · Master of IT (Data Analytics), UTS Sydney
[TODO: LinkedIn] · [TODO: Portfolio] · [TODO: Email]
