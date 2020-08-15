#' Q-learning reward functions that are defined specifically for deterministic forecasting
#' Author: Cong Feng 
#' This function calculates rewards for Q-learning agents
#' @param data_input input data that contains states and actions in time series format
#' @param rwd_strategy reward strategy index
#' @return rewards
#' @export
Reward_function <- function(data_input, rwd_strategy) {
  
  if (rwd_strategy == 1) {# absolute error improvement; !!!issue: the best action could be negative, same for other metrics, e.g., nmae, mape
    states <- data_input[1,]
    actions <- data_input[2,]
    RW_matrix <- NULL
    for (no_state in 1:length(states)) {
      RW_matrix <- rbind(RW_matrix, (rep(states[no_state], length(actions)) - actions))
    }
    rownames(RW_matrix) <- colnames(states)
  }
  
  if (rwd_strategy == 2) {# relative mape
    states <- (data_input[1,] - min(data_input[1,]))/(max(data_input[1,])-min(data_input[1,]))
    actions <- (data_input[2,] -min(data_input[2,]))/(max(data_input[2,])-min(data_input[2,]))
    RW_matrix <- NULL
    for (no_state in 1:length(states)) {
      RW_matrix <- rbind(RW_matrix, (rep(states[no_state], length(actions)) - actions))
    }
    rownames(RW_matrix) <- colnames(states)
  }
  
  if (rwd_strategy == 3) {# rank
    states <- rank(data_input[1,])
    actions <- rank(data_input[2,])
    RW_matrix <- NULL
    for (no_state in 1:length(states)) {
      RW_matrix <- rbind(RW_matrix, (rep(states[no_state], length(actions)) - actions))
    }
    colnames(RW_matrix) <- colnames(data_input)
    rownames(RW_matrix) <- colnames(data_input)
  }
  
  return(RW_matrix)
}
  