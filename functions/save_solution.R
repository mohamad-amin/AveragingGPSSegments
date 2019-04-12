get_predicted_segment <- function(set) {
  
  source('functions/read_segments.R')
  source('functions/utils.R')
  source('functions/train_model.R')
  
  # Reading the dataset
  dataset = read_segment(sprintf('training_data/%d.txt', set-1))
 
  # Todo: remove outliers based on the number of knots
  outlier_removal_result = remove_outliers_dbscan(dataset)
  trimmed = outlier_removal_result$trimmed
  outlier_segments = outlier_removal_result$outlier_segments

  # training the model
  training_result = train_model(trimmed)

  knots = training_result$knots
  target_knots = training_result$target_knots
  predictor_name = training_result$predictor_name
  
  dots = list()
  for (i in 1:length(target_knots)) {
    if (predictor_name == "x") {
      dots[[i]] <- c(knots[i], target_knots[i])
    } else {
      dots[[i]] <- c(target_knots[i], knots[i])
    } 
  }
  
  return(dots)

}

save_predicted_segments <- function(file_name) {

  all_dots = list()
  for (i in 1:100) {
    all_dots[[i]] = get_predicted_segment(i)
  }

  sink(file_name)
  for (i in 1:length(all_dots)) {
    writeLines(unlist(lapply(all_dots[[i]], paste, collapse=" ")))
    writeLines("")
  }
  sink()

}