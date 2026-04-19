# Model Validation Summary

## Model Purpose
Predict likelihood of loan default for Home Credit applicants.

## Methodology
- Data: Home Credit Default Risk dataset
- Target: TARGET
- Models evaluated: Logistic Regression, Random Forest, XGBoost
- Final model: XGBoost
- Key engineered features: credit-to-income ratio, annuity-to-income ratio, external score aggregates, bureau aggregates

## Performance
- Test AUROC
- Gini
- KS
- AUPRC
- Cross-validation mean and std

## Explainability
- SHAP summary plot
- Top features
- Example adverse action reasons

## Limitations
- Performance may shift under economic stress
- Missingness patterns may reflect application process behavior
- Some segments may be underrepresented

## Monitoring Plan
- Track AUROC, PSI, and feature distributions
- Retrain or review if PSI exceeds 0.25 on key features