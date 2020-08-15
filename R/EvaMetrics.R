#' Forecasting evaluation metrics
#' Author: Cong Feng 
#' This function calculates deterministic forecasting evaluation metrics
#'
#' @param anly input data in the [forecasts, actual] format
#' @return six error metrics: mape, mae, nmae, mse, rmse, and nrmse
#' @export
EvaMetrics <- function(anly) {
  library("stats")
  library("fBasics")
  #do the forecast error calculation and normalization
  cap <- max(anly[,2])
  fe1 <- as.matrix((anly[,1]-anly[,2])/anly[,2]) # different normalization standards
  fe2 <- as.matrix((anly[,1]-anly[,2])/cap)
  # remove the NAs
  fe1 <- fe1[!is.infinite(fe1)]
  fe1 <- fe1[!is.na(fe1)]
  fe2 <- fe2[!is.na(fe2)]
  
  #-------------------- error evaluation metrics ------------------
  mape <- mean(abs(fe1))     # mean absolute percentage error
  mae <- mean(abs(fe2))*cap  # mean absolute error
  nmae <- mean(abs(fe2))     # normalized mean absolute error
  mse <- mean((fe2*cap)^2)   # mean square error
  rmse <- sqrt(mse)          # root mean square error
  nrmse <- rmse/cap          # normalized root mean square error
 
  result <- data.frame(mape,mae,nmae,mse,rmse,nrmse)
  colnames(result) <- c('mape','mae','nmae','mse','rmse','nrmse')
  return(result)
}