#--------------------------------  NOTE  ----------------------------------------
# 1 This code is to select DLF models using q-learning
# 2 Coder: Cong Feng        Date: 2018/09/19
# 3 References:
#   1. Feng, C. and Zhang, J., 2019, February. Reinforcement learning based
#      dynamic model selection for short-term load forecasting. In 2019 IEEE
#      Power & Energy Society Innovative Smart Grid Technologies Conference
#      (ISGT) (pp. 1-5). IEEE.
#   2. Feng, C., Sun, M. and Zhang, J., 2019. Reinforced Deterministic and
#      Probabilistic Load Forecasting via $ Q $-Learning Dynamic Model Selection.
#      IEEE Transactions on Smart Grid, 11(2), pp.1377-1386.
#--------------------------------------------------------------------------------
# clear R workspace and console
rm(list=ls(all=TRUE))
cat("\014")

# roots
root_code <- '~/R'
root_data <- '~/data'
root_save <- '~/results'

library(zoo)
source(file.path(root_code,'EvaMetrics.R'))
source(file.path(root_code,'Qlearning_DMS.R'))
source(file.path(root_code, 'Reward_function.R'))


#--------------------------- Global Variables ----------------------------
# sliding window parameters
nday_prob <- 7 # number of days for probabilistic modeling
no_day <- 3 # how many days to learn from
no_models <- 10 # how many best models to choose
no_hour <- 4 # update Q-learning model every no_hour hours
# Q-learning parameters
no_episodes <- 100 # episodes number
alpha <- 0.1 # learning rate
gamma <- .8 # discount factor
reward_selection <- 3 # which reward strategy
# setting for duplication
set.seed(1)

# read in data: the DMP
data_raw <- readRDS(file = file.path(root_data, "DeterministicForecastingModelPool.rds"))
data_date <- as.Date(na.approx(data_raw$data_date))
diff_day <- as.numeric(as.Date(data_date[length(data_date)]) - as.Date(data_date[1])) # how many different days
day_fst <- as.Date(data_date[1]) # the date of the first day

#
result_qlearning_forecasting <- NULL
result_qlearning_selection <- NULL
matrix_Qvalue <- NULL
for (i in 1:(diff_day-no_day)) { # update Q-learning training data every day (diff_day-no_day)
  cat('Processing RL for day: #', i, '\n')
  day_begin <- day_fst + i -1
  day_end <- day_begin + no_day
  data_rf_learn <- data_raw[data_raw$data_date >= day_begin &
                            data_raw$data_date <= day_end, 3:ncol(data_raw)] # data to learn policy
  timestamp_learn <- data_raw[data_raw$data_date >= day_begin &
                                data_raw$data_date <= day_end, 2]
  data_rf_process <- data_raw[data_raw$data_date > day_end &
                              data_raw$data_date <= (day_end+1), 3:ncol(data_raw)] # data to use policy to select predictor
  timestamp_process <- data_raw[data_raw$data_date > day_end &
                                data_raw$data_date <= (day_end+1), 2]
  # select proper data
  vector_nmae <- NULL
  for (j in 1:(ncol(data_rf_learn)-1)) { # evaluate each model in this range of days
    nmae <- as.double(EvaMetrics(data.frame(data_rf_learn[,j], data_rf_learn$target))[3])
    vector_nmae <- c(vector_nmae, nmae)
  }
  # select the best no_models models in the history: 10 in this case
  data_rf_learn2 <- data.frame(timestamp_learn, data_rf_learn[,c(which(rank(vector_nmae) %in% seq(1:no_models)), ncol(data_rf_learn))])
  colnames(data_rf_learn2) <- c('Timestamp', colnames(data_rf_learn2)[2:ncol(data_rf_learn2)])
  data_rf_process2 <- data.frame(timestamp_process, data_rf_process[,c(which(rank(vector_nmae) %in% seq(1:no_models)), ncol(data_rf_process))])
  colnames(data_rf_process2) <- c('Timestamp', colnames(data_rf_process2)[2:ncol(data_rf_process2)])

  # rank of each row in training data
  data_rf_rk_learn2 <- NULL
  for (j in 1:nrow(data_rf_learn2)) {
    data_rf_rk_learn2 <- rbind(data_rf_rk_learn2, rank(abs(data_rf_learn2[j,2:(ncol(data_rf_learn2)-1)]-data_rf_learn2[j,ncol(data_rf_learn2)])))
  }
  data_rf_rk_learn2 <- data.frame(data_rf_learn2$Timestamp, data_rf_rk_learn2)

  # update the Q-learning model every no_hour hours
  for (no_dayp in 1:(nrow(data_rf_process2)/no_hour)) {
    data_rf_process3 <- data.frame(rbind(data_rf_learn2[nrow(data_rf_learn2),], data_rf_process2)) # include last hour data in previous day, totally 25 rows of data
    data_rf_process4 <- data_rf_process3[(1+no_hour*(no_dayp-1)):(no_hour*no_dayp+1),]
    init_md <- colnames(data_rf_process4)[(which.min(abs(data_rf_process4[nrow(data_rf_process4),2:(no_models+1)]-
                                                          data_rf_process4[nrow(data_rf_process4),(no_models+2)]))+1)] # initial state, there is one column of Timestamp, thus +1

   #------------------------------ Q-learning DMS-----------------------------
  result_dayp  <- Qlearning_DMS(no_models, no_episodes, no_hour, init_md, reward_selection, alpha, gamma,
                                data_rf_learn2, data_rf_process4)


   result_qlearning_forecasting <- rbind(result_qlearning_forecasting, cbind(as.character(data_rf_process4[2:nrow(data_rf_process4),1]),
                                                                              result_dayp, data_rf_process4[2:nrow(data_rf_process4),ncol(data_rf_process4)]))
   } # end of no_dayp
} # end of i (day)


#----------------------------- evaluate ------------------------------
# forecasting results
result_qlearning_forecasting <- data.frame(result_qlearning_forecasting)
colnames(result_qlearning_forecasting) <- c('Timestamp', 'Qlearning', 'target')
result_qlearning_forecasting$Timestamp <- as.character(result_qlearning_forecasting$Timestamp)
result_qlearning_forecasting$Qlearning <- as.double(as.character(result_qlearning_forecasting$Qlearning))
result_qlearning_forecasting$target <- as.double(as.character(result_qlearning_forecasting$target))
data_raw2 <- data_raw[,2:ncol(data_raw)]
colnames(data_raw2) <- c('Timestamp', colnames(data_raw)[3:ncol(data_raw)])
data_raw2$Timestamp <- as.character(data_raw2$Timestamp)
for (j in 2:ncol(data_raw2)) {
  data_raw2[,j] <- as.double(as.character(data_raw2[,j]))
}

# combine DMP models and Q-learning results
result_compile <- merge(data_raw2, result_qlearning_forecasting, by = c('Timestamp', 'Timestamp'))
result_compile <- result_compile[,-(ncol(result_compile)-2)]

eval_matrix <- NULL
for (j in 2:(ncol(result_compile)-1)) {
  eval_matrix <- rbind(eval_matrix, EvaMetrics(data.frame(result_compile[,j], result_compile[,ncol(result_compile)])))
}
rownames(eval_matrix) <- colnames(result_compile)[2:(ncol(result_compile)-1)]

# write out the results
write.table(result_compile,file = paste0(root_save,'QMS_DLF_ForecastingTimeSeries.csv'),row.names = F,na='',col.names = TRUE,sep = ',')
write.table(eval_matrix,file = paste0(root_save,'QMS_DLF_ForecastingEvaluationMetrics.csv'),row.names = T,na='',col.names = TRUE,sep = ',')

