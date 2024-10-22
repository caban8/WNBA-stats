

# Introduction

Sport in general is a domain in which competence is measured by well defined and precisely measured criteria. At the simplest level, winning is a direct reflection of someone's performance.
Team sports follow the same basic principles, although in their context, it is more difficult to assess individual competence. After all, it is the team who wins, and not individual players. However, most team sports consist of a set of different plays and behaviors that can be treated as specific performance measures.
One such sport is basketball in which player's performance is measured by the number of goals, steals, or blocks, to name a few.
The most popular leagues, like NBA, have a long history and been well studied in different aspects.
In contrast, WNBA, women's equivalent, was established relatively recently, in 1996, and as such has been less analyzed.
The goal of the following analysis was to assess which and how women's basketball players performance measures predict their salary. 

The WNBA players' performance stats were imported from the basketball [reference stats](https://www.basketball-reference.com/), while their salaries were scraped from [spotrac](https://www.spotrac.com/wnba/rankings/).
The data spans years from 2017 to 2023. 
In order to account for inflation, salary was adjusted using the CPI index. 
This is an observational study and therefore a clear cause-and-effect relationship cannot be established. Nevertheless, from a theoretical stand point, it makes sense to infer, at least partially, that performance stats translate to salary and to better approximate such relationship, salary was predicted by performance stats from one year earlier.

Given that the data suffered from high multicollinearity and that variables representing a percentage of successful goal attempts posed a methodogolical limitations for players who did not have any attempts in a given performance stats, four versions of data were created. In two versions salary, the dependent variable, was log-transformed, and in each of the pairs - log-transformed and original - one of the datasets was reduced by the four percentage variables. 

Each dataset was trained and then tested using 
Stepwise Selection Linear Regression, 
Lasso Regression, 
Tree model,
Random Forest, and
xgb boosted tree
models.
The analysis revealed that the best prediction was achieved by xgb boosted tree model fitted to the reduced dataset with untransformed salary, followed by the same model fitted to the reduced dataset with log-transformed salary.

The best predictors of salary were number of Field Goals, Games Started, and Two-Point Field Goals, which were associated positively, and number of Games and Personal Fouls, which were associated negatively.




# Datasets

Player stats
https://www.basketball-reference.com/


Salaries
https://www.spotrac.com/wnba/rankings/

CPI:
https://stats.oecd.org




# Discussion



## Data Preparation and Preliminary Findings

1. **Data Characteristics and Challenges**:
   - **Multicollinearity**: The dataset suffered from multicollinearity, especially among performance metrics like field goals and field goal attempts, which made it difficult to separate individual effects. The correlation between such variables was extremely high (|cor| > 0.8).
   - **Methodological Issues**: Percentage variables for goal attempts posed a challenge, especially for players who had no attempts, requiring four different versions of the dataset to address these limitations.
   - **Cleaned Dataset**: The final dataset after cleaning consisted of `r nrow(model_datasets$whole[[1]])` observations. It had a right-skewed distribution for many performance variables, such as field goals, points, and rebounds, with most players having low to mid-range performance stats. This distribution pattern fits a Pareto distribution, common in human performance data.
   - **Player Sample Bias**: The analysis recognized a potential bias because salary information was more readily available for higher-performing players, limiting the generalizability of findings across all WNBA players.

2. **Model Comparisons**:
   Several supervised models were trained, including **linear regression (stepwise selection)**, **Lasso regression**, **decision tree**, **random forest**, and **XGBoost (gradient boosting)**. The **XGBoost model** fitted to the reduced dataset with untransformed salary data produced the best performance overall, closely followed by the same model fitted to the log-transformed reduced dataset.
   
   - **Best Models**: The **XGBoost boosted tree models** performed best, explaining around 32% of the variance in salary. These models utilized performance measures like **field goals**, **games started**, **assists**, and **two-point field goals** as the most important positive predictors of salary. Conversely, **number of games** and **personal fouls** were the strongest negative predictors of salary. Achieving a noticeably better model prediction with models fitted to the reduced data reveals an important limitation of the reliability of percentage metrics, at least when data contains a substantial number of players with zero goal attempts.
   - **Tree Models**: Decision tree models reported to have the worst performance, regardless of the dataset, which might be explained by high correlations of predictors.
   - **Random Forest Models**: These performed better than decision trees, comparably to linear regression models, and worse than boosting models, strongly overlapping with the latter in terms of the most important predictors.
   - **Linear Models (Stepwise and Lasso)**: Like Random Forest models, these also achieved lower predictive power compared to boosted tree models. Stepwise models highlighted variables like **field goals**, **number of games**, and **year** as key predictors. Lasso regression models reduced multicollinearity but still performed slightly worse than tree-based approaches.

3. **Key Predictors of Salary**:
   - **Field Goals (FG)**: This was consistently the most important predictor across models. More field goals led to a higher salary, but the relationship leveled off after reaching around 130–150 goals.
   - **Games Started (GS)**: Players who started more games typically earned higher salaries, with the critical threshold for a noticeable salary increase being around 10–11 games started and leveling off at around 30.
   - **Two-Point Field Goals (2P)**: Similar to field goals, two-point goals had a strong, positive association with salary with a clear, single threshold at around 90 goals.
   - **Personal Fouls (PF)**: More personal fouls were associated with lower salaries with two marked thresholds - at around 10-15 and then at around 55. 
   - **Games Played (G)**: Somewhat surprisingly, a higher number of games was negatively correlated with salary, which could indicate that players with higher workloads earned relatively less for their performance compared to more specialized or less frequent starters.
   - **Assists (Ast)** Players with more assists tended to have a better salary with the optimal number of the former being around 70 and 180 for the models fitted to the full and reduced datasets respectively.

4. **Model Limitations**:
   - **Non-linearity**: The analysis highlighted **non-linearity** in the relationships between predictors and salaries, which made traditional linear models less effective. 
   - **Heteroscedasticity and Multicollinearity**: The models showed signs of **heteroscedasticity** (i.e., the variance of errors was not constant across predictions), particularly in the linear models fitted to the untransformed data. Despite attempts to address this with log transformations, the issue persisted to some degree. The linear models also suffered from multicollinearity, which was partly corrected by obtaining models with the lasso shrinkage method.
   - **Percentage metrics**: Models fitted to the datasets that included goal percentage metrics performed noticeably worse. This further underlies the limitations of the latter as reliable indicators of players' performance which could be explained by two factors. First, it imposes missing values on players who did not have any goal attempts, as you cannot divide zero by zero. Second, it introduces small sample bias making the performance estimation of the players with a small number of attempts more variable, as having just one or two attempts could easily skew the impression to either perfect or inferior with 100% and 0% respectively.
   - **External Validity**: The project acknowledged that due to incomplete salary data (missing for many lower-paid players), the analysis likely favored better-performing players, limiting the external validity of the conclusions for all WNBA players.

5. **Theoretical Considerations**:
  - **COVID-19**: The data consists of players' salaries that were collected from 2018 to 2023, which overlaps with the COVID-19 pandemic. The latter could explain the leveling off of the salary increase in 2021–2022, as teams and their sponsors had to cut costs due to the radical audience restrictions imposed by the government. Moreover, this could overshadow the role of specific performance stats for at least two reasons. First, given the general stop in increasing salaries, players might not have been adequately rewarded relative to their input. Second, without the audience and their morale-boosting potential, among other things, the general game conditions were different from the usual ones, which might affect the behavior and therefore the performance of the players. Taken together, these factors could further limit the generalizability of the data.



## Conclusion

The analysis revealed that the relationship between players' performance and their salary is complex and can be better approximated by non-linear models, specifically the gradient tree boosting model. Among `r ncol(wnba_complete) - 1` variables six were found to be crucial predictors:
field goals, assists, games started, and two-points goals were positively associated with salary,
while personal fouls and games, negatively.

The whole study, however, suffered from two important methodological limitations, namely, a biased sample that favored better earning players and the fact that a large portion of data comes from the COVID-19 pandemic times. These two together confine the generalizability of the results to all WNBA players. 
