# QLearningForecast
**This is a package that implements forecasting model dynamic selection via Q-learning.**

As described in:
**Reinforced Deterministic and Probabilistic Load Forecasting via  Q-Learning Dynamic Model Selection**, Cong Feng, Mucun Sun, and Jie Zhang, IEEE Transactions on Smart Grid, 11(2), pp.1377-1386. [https://ieeexplore.ieee.org/abstract/document/8813103]
**Reinforcement learning based dynamic model selection for short-term load forecasting**, Cong Feng and Jie Zhang, 2019 IEEE Power & Energy Society Innovative Smart Grid Technologies Conference (ISGT) (pp. 1-5). IEEE. [https://ieeexplore.ieee.org/abstract/document/8791671]


## How to use
Ideally, Q-learning could be used to dynamically select forecasting models from any model pool for any forecasting task. In this repo, we demonstrate selecting models from a model pool with 10 machine learning models for 1-houar-ahead electricity load forecasting problem.

### Dataset
The example dataset in this repo contains load forecasts from the 10 machine learning with a length of 5 days. Q-learning agents will learn from previous four days' forecasts and make decisions of selecting models for the last day.

### Environment
```
# Install packages within R
install.packages(c("zoo"))
```

### Execute example code
```
# Specify directories in qlearning_load_forecasting.R in R
root_code <- '~/R'
root_data <- '~/data'
root_save <- '~/results'
# run R script
Rscript qlearning_load_forecasting.R
```
## Publications

If you use this software in your research, please cite our publications:

Feng, C. and Zhang, J., 2019, February. Reinforcement learning based dynamic model selection for short-term load forecasting. In 2019 IEEE Power & Energy Society Innovative Smart Grid Technologies Conference (ISGT) (pp. 1-5). IEEE.

Feng, C., Sun, M. and Zhang, J., 2019. Reinforced Deterministic and Probabilistic Load Forecasting via Q-Learning Dynamic Model Selection. IEEE Transactions on Smart Grid, 11(2), pp.1377-1386. 


## License
MIT License, Copyright (c) 2020 Cong Feng

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


