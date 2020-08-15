#' Dynamic model selection using Q-learning for load forecasting
#' Author: Cong Feng
#' Reference: 1. Feng, C. and Zhang, J., 2019, February. Reinforcement learning based
#'               dynamic model selection for short-term load forecasting. In 2019 IEEE
#'               Power & Energy Society Innovative Smart Grid Technologies Conference
#'               (ISGT) (pp. 1-5). IEEE.
#'            2. Feng, C., Sun, M. and Zhang, J., 2019. Reinforced Deterministic and
#'               Probabilistic Load Forecasting via $ Q $-Learning Dynamic Model Selection.
#'               IEEE Transactions on Smart Grid, 11(2), pp.1377-1386.
#' This function performs dynamic model selection using Q-learning for load forecasting
#' @param QMS_no_models state and action space dimension
#' @param QMS_no_episodes number of episodes
#' @param QMS_no_hour update frequency
#' @param QMS_init_md starting state
#' @param QMS_reward_selection reward strategy
#' @param QMS_alpha learning rate
#' @param QMS_gamma discount factor
#' @param df_learn training data frame
#' @param df_select selecting data frame
#' @return the Q-learning forecasting results
#' @references Feng, C. and Zhang, J., 2019, February. Reinforcement learning based
#'               dynamic model selection for short-term load forecasting. In 2019 IEEE
#'               Power & Energy Society Innovative Smart Grid Technologies Conference
#'               (ISGT) (pp. 1-5). IEEE.
#' @export QMS_no_hour
Qlearning_DMS <- function(QMS_no_models, QMS_no_episodes, QMS_no_hour, QMS_init_md, QMS_reward_selection,
                          QMS_alpha, QMS_gamma, df_learn, df_select){
  # Episode loop
  Q_initial <- matrix(0, QMS_no_models, QMS_no_models) # this initial Q matrix is specific to model selection problem
  colnames(Q_initial) <- colnames(df_learn)[2:(QMS_no_models+1)]
  rownames(Q_initial) <- colnames(df_learn)[2:(QMS_no_models+1)]
  Q_table <- Q_initial
  vector_Qvalue <- NULL
  for (iter in 1:QMS_no_episodes) {
    # randomly select a time frame
    row_start <- sample(1:(nrow(df_learn)-QMS_no_hour+1), size = 1)
    data_rf_iter <- rbind(df_learn[nrow(df_learn),], df_learn[row_start:(row_start+QMS_no_hour-1),])# why the first part
    data_rf_iter2 <- abs(data_rf_iter[,2:(ncol(data_rf_iter)-1)]-data_rf_iter[,ncol(data_rf_iter)])/data_rf_iter[,ncol(data_rf_iter)]*100 # mape as reward initial metric

    # loop steps in one episode
    state_step <- QMS_init_md # using the best model in previous step in the training data
    for (no_step in 1:(nrow(data_rf_iter2)-1)) {
      # calculate reward function
      data_rf_step <- data_rf_iter2[no_step:(no_step+1),]
      Reward_matrix <- Reward_function(data_rf_step, QMS_reward_selection) # reward is dynamic regarding to steps and episodes

      # take action by epsilon greedy
      seq_epsilon <- seq(1, 1e-5, by = -1/QMS_no_episodes) # list of epsilon values
      select_epsilon <- sample(c('MaxReward', 'Random'), size = 1, prob = c((1-seq_epsilon[iter]), seq_epsilon[iter]))
      # randomly search
      if (select_epsilon == 'Random') {
        action_step <- sample(colnames(Reward_matrix), size = 1)
      }
      # maximum reward
      if (select_epsilon == 'MaxReward') {
        action_step <- colnames(Reward_matrix)[which.max(Reward_matrix[state_step,])] # check row and column
      }
      # update Q-matrix
      Q_table[state_step, action_step] <- (1-QMS_alpha)*Q_table[state_step, action_step] + QMS_alpha*(Reward_matrix[state_step, action_step]+QMS_gamma*max(Reward_matrix[action_step,]))
      state_step <- action_step # action is the state of next step
    } # end of no_step
    vector_Qvalue <- c(vector_Qvalue, sum(Q_table))
  } # end of iter (episode loop)
  result_dayp <- NULL
  result_dayp_selection <- NULL

  # DMS using optimal policy Q*
  vector_best <- NULL
  for (nr in 1:(nrow(df_select)-1)) {
    data_nr <- df_select[nr,]
    data_mae <- abs(data_nr[,2:(ncol(data_nr)-1)]-data_nr[,ncol(data_nr)])
    data_nr_rk <- t(data.frame(rank(data_mae)))
    vector_best <- c(vector_best, colnames(data_nr_rk)[which.min(data_nr_rk)])
  }

  for (j in 1:no_hour) {
    state_step <- vector_best[j]
    result_dayp <- c(result_dayp, df_select[(j+1), state_step])
    result_dayp_selection <- c(result_dayp_selection, colnames(df_select)[which.max(Q_table[state_step,])+1])
  }

  return_obj <- result_dayp
  return(return_obj)
}
