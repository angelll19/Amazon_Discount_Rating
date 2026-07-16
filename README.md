# Business Problem
Amazon invests heavily in product discounts to attract customers and stimulate sales. However, while discounts can increase product appeal, they also reduce profit margins and require significant promotional investment. It is therefore important to determine whether these discounts effectively improve customer satisfaction or simply increase promotional costs without delivering the expected value.

This analysis aims to assess the effectiveness of Amazon's discount strategy by examining the relationship between discount levels, customer ratings, and review behavior across product categories.


# Objectives
This dashboard evaluates the effectiveness of Amazon's discount strategy by analysing product discounts, customer ratings, and review behaviour across different product categories.

- Compare discount strategies across product categories.
- Evaluate whether higher discounts are associated with higher customer ratings.
- Identify categories containing large numbers of high-discount, low-rating products.
- Highlight products receiving substantially higher discounts than their category average but still underperforming in customer ratings.
- Provide insights to support more effective discount allocation.

# Dashboard Preview
<img width="913" height="524" alt="Screenshot 2026-07-16 132244" src="https://github.com/user-attachments/assets/e35eab8b-8d79-40f6-86be-a16f059e8db2" />

# Dataset

**Source:** https://www.kaggle.com/datasets/karkavelrajaj/amazon-sales-dataset

# 🛠️ Tools Used
- PostgreSQL
- Power BI
- Microsoft Excel


## Key Takeaways

- Average product discount is 46.68%.
- Higher discounts do not consistently result in higher customer ratings.
- Electronics, Home & Kitchen, and Computers & Accessories contain most high-discount, low-rating products.
- Home & Kitchen dominates the list of discount outlier products.
- Product quality and customer experience may be more important drivers of satisfaction than discount size.


# Discount and Customer Rating Analysis

## 1. Overall Findings
### How much is Amazon investing in discounts?
- The overall average product discount is **46.68%**, indicating that discounting is widely used across Amazon products.
This raises an important question:
- **Are these discounts generating better customer outcomes?**

---
## 2. Discount Strategy by Category
### Where is the discount budget concentrated?
- Discounts vary significantly across categories
- Product categories apply different discount strategies, with average discounts ranging from **0% to 57.5%**.
- **Home Improvement (57.5%)** and **Computers & Accessories (53.2%)** receive the highest average discounts.
- In contrast, **Office Products (12.4%)** and **Toys & Games (0%)** receive the lowest average discounts.

---

## 3. Relationship Between Discount and Customer Rating
### Are higher discounts improving customer satisfaction?

- Higher discounts do not necessarily correspond to higher customer ratings.
- **Musical Instruments** and **Car & Motorbike** receive relatively high discounts (46% and 42%) but have the lowest average ratings (below **4.0**).
- Conversely, **Office Products** and **Toys & Games** achieve the highest average ratings (**4.30–4.31**) while receiving the lowest average discounts.
- This suggests that increasing discount levels alone may not be sufficient to improve customer satisfaction.

---
## 4. Relationship Between Reviews and Ratings
### Do review counts reflect customer satisfaction?
- A higher number of customer reviews does not always correspond to higher customer ratings.
- Categories with large review volumes are not necessarily the highest-rated categories.
- Customer engagement and customer satisfaction appear to be different dimensions.

Insight: Review volume alone is insufficient to evaluate customer satisfaction and should be interpreted together with customer ratings.

---
### Which products are underperforming despite heavy discounts?
## 5. High-Discount, Low-Rating Products

- Products with **above-category-average discounts** and **below-category-average ratings** were identified as potential discount outliers.
- These products receive larger discounts than similar products within the same category but still fail to achieve satisfactory customer ratings.
- This may indicate that promotional resources are **not generating the expected return**, as higher discounts do not translate into improved customer satisfaction.

### Two possible explanations include:

1. **Product quality or customer experience issues**  
   The product may have underlying problems that cannot be resolved through discounting alone.

2. **Ineffective discount strategy**  
   Discounts are no longer effective in improving customer perception.
---
### Which categories require immediate attention?
## 6. Category Distribution of High-Discount, Low-Rating Products

- High-discount, low-rating products are concentrated within a small number of product categories.
- Most belong to:
  - Electronics
  - Home & Kitchen
  - Computers & Accessories

Insight: Rather than reviewing every category, Amazon can prioritise investigation within these three categories to identify the underlying causes of poor customer ratings.

---
### Which products should be prioritised for investigation?
## 7. Top 10 Discount Outliers

- The **Top 10 products** with the largest discount difference from their category average, while also having below-category-average ratings, were identified.
- Many of these products belong to the **Home & Kitchen** category.
- These products represent the highest-priority candidates for further investigation because they have the greatest potential to improve:
  - promotional efficiency,
  - customer satisfaction,
  - and overall profitability.
  
# Recommendations

1. **Evaluate the effectiveness of high-discount strategies**, particularly in Electronics, Home & Kitchen, and Computers & Accessories, to determine whether discounts above 40% generate sufficient customer value to justify reduced profit margins.

2. **Prioritise investigation of underperforming products** that receive above-category-average discounts but maintain below-category-average customer ratings, as these may indicate inefficient promotional spending.

3. **Investigate the root causes of low ratings** in categories with high concentrations of high-discount, low-rating products. Focus on factors such as product quality, customer experience, and customer expectations rather than relying solely on larger discounts.

4. **Conduct sentiment analysis on customer reviews**, especially in categories with high review volumes but relatively low ratings, to identify common customer complaints and key drivers of dissatisfaction.
