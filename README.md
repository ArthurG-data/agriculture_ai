[Click here to view the PowerPoint slideshow](https://docs.google.com/presentation/d/1WfQIESPRCUSavsE9W9vS7aWTgSwFEz7I/edit?usp=drive_link&ouid=114556454877851613541&rtpof=true&sd=true)

[Click here to download the data. 800mb zipped file](https://drive.google.com/file/d/1gMkG0yZ4GshUnPIovtoaXYVEOeeRqhwk/view?usp=drive_link)

# Grazing into the Future: Pasture Yield Prediction

This project explores pasture yield prediction using statistical and deep learning models, specifically comparing **Vector Autoregression (VAR)** and **Recurrent Neural Networks (RNNs)** with Long Short-Term Memory (LSTM) layers. The focus is on forecasting **Total Standing Dry Matter (TSDM)** using multivariate climate data for better livestock management.

---
## Technologies Used

<p align="center">
  <img src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white" alt="Python"/>
  <img src="https://img.shields.io/badge/R-276DC3?logo=r&logoColor=white" alt="R"/>
</p>

## Introduction
Pasture yield prediction is a critical task for effective livestock management, ensuring adequate feed availability while avoiding overgrazing. This project focuses on forecasting Total Standing Dry Matter (TSDM), an essential metric for assessing pasture productivity. By leveraging statistical and deep learning models, this study aims to improve yield prediction accuracy and provide insights into the applicability of advanced neural network architectures in agricultural contexts. 

---

## Models and Approach

### Vector Autoregression (VAR)
- **Description**: A statistical model suited for multivariate time series analysis.
- **Performance**: 
  - Outperformed RNN models across all prediction horizons.
  - Effective for short- to long-term predictions (1-12 months).
  - Lower computational cost and faster training time.
- **Limitations**:
  - Aggregated data across paddocks; localized variations were not captured.
  - Assumes stationarity, addressed with data preprocessing.

### Recurrent Neural Network (RNN) with LSTM Layers
- **Description**: A deep learning model designed to handle sequential data.
- **Performance**:
  - Comparable to VAR for 12-month predictions, slightly better for shorter horizons.
  - Tested with various architectures (e.g., convolutional layers, autoregressive).
  - Higher variability in predictions (larger MAE compared to VAR).
- **Limitations**:
  - Computationally expensive, with limited benefits due to a small dataset.
  - Does not fully leverage the multivariate data’s potential.

---

## Key Insights
- **VAR Model Superiority**: Consistently accurate and computationally efficient, making it a strong choice for small datasets.
- **Deep Learning Challenges**: Despite their potential, RNNs require larger datasets and advanced architectures to surpass traditional methods.
- **Future Directions**:
  - Experimenting with transformer-based models for better long-term dependencies.
  - Analyzing the importance of individual climate variables to refine predictions.
  - Developing models for specific paddocks to account for localized variations.

---

## Dataset
- **Source**: TSDM data inferred from Sentinel-2 satellite imagery (2017–2023) for paddocks in the Central Tablelands, New South Wales, Australia.
- **Features**: Rainfall, temperature, humidity, evaporation, radiation, and TSDM measurements.


---

## Data and Results
This section will include visualizations of the dataset and model performance. Add your graphs and plots here to provide an overview of the data trends and key results.

<p>
  <img src="assets/img/Screenshot 2025-01-19 094124.png">
  <img src="assets/img/Screenshot 2025-01-19 094143.png">
</p>
---

## Method Summary
This section will include a diagram summarizing the methods used in the project. Add your graphical representation of the workflow here to illustrate the methodology.

<img src="assets/img/Screenshot 2025-01-19 094159.png">
---

## Results Summary

- **Conclusion**: VAR is a robust baseline, while RNNs hold promise with sufficient data and model optimization.

<img src="assets/img/Screenshot 2025-01-19 100228.png">
<img src="assets/img/Screenshot 2025-01-19 094228.png">
---

## Contributors
- **Guillaume Arthur**  
  Developed and analyzed models for pasture yield forecasting.

For questions or contributions, feel free to submit an issue or pull request.
