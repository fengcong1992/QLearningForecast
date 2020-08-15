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
Install within R:
* Install dependencies
```
docker build -t bvlc/caffe:gpu ./gpu
# check if working
docker run -ti bvlc/caffe:gpu caffe device_query -gpu 0
# get a bash in container to run examples
docker run -ti --volume=$(pwd):/SegNet -u $(id -u):$(id -g) bvlc/caffe:gpu bash
```
install.packages(c("ggplot2", "ggfan", "here", "ncdf4", "pracma", "reshape2", "tibble", "tidyr", "truncnorm" ))
* Install solarbenchmarks
install.packages(<solarbenchmarks_0.1.0.tar.gz in local directory>, repos=NULL)

From command line within the solarbenchmarks directory:
Rscript benchmark_forecast_comparison.R

Example net specification and solver prototext files are given in examples/segnet.
To train a model, alter the data path in the ```data``` layers in ```net.prototxt``` to be your dataset.txt file (as described above).

In the last convolution layer, change ```num_output``` to be the number of classes in your dataset.

### Training

In solver.prototxt set a path for ```snapshot_prefix```. Then in a terminal run
```./build/tools/caffe train -solver ./examples/segnet/solver.prototxt```

## Publications

If you use this software in your research, please cite our publications:

Feng, C. and Zhang, J., 2019, February. Reinforcement learning based dynamic model selection for short-term load forecasting. In 2019 IEEE Power & Energy Society Innovative Smart Grid Technologies Conference (ISGT) (pp. 1-5). IEEE.

Feng, C., Sun, M. and Zhang, J., 2019. Reinforced Deterministic and Probabilistic Load Forecasting via Q-Learning Dynamic Model Selection. IEEE Transactions on Smart Grid, 11(2), pp.1377-1386. 


## License
This extension to the Caffe library is released under a creative commons license which allows for personal and research use only. For a commercial license please contact the authors. You can view a license summary here:
http://creativecommons.org/licenses/by-nc/4.0/
