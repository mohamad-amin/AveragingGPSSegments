draw_route <- function(set) {

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

  model = training_result$model
  target = training_result$target
  predictor = training_result$predictor
  predictor_name = training_result$predictor_name

  knots = training_result$knots
  target_knots = training_result$target_knots
  knots_count = training_result$knots_count

  if (predictor_name == "x") {
    original_predictor = dataset$x
    original_target = dataset$y
  } else {
    original_predictor = dataset$y
    original_target = dataset$x
  }

  xs = seq(min(predictor), max(predictor), by=0.03)
  ys = predict(model, data.frame(predictor=xs))
  
  par(mfrow=c(1, 2), mai=c(0.5, 0.1, 0.1, 0.1))
  par(pty="s")
  colors = unlist(Map(function(t) {
    if (t %in% outlier_segments) "red" else "black"
  }, dataset$t))

  if (predictor_name == "x") {
    plot(original_target ~ original_predictor, xlim=c(0, 1), ylim=c(0, 1), col=colors)
    lines(xs, ys, col="blue")
    plot(target_knots ~ knots, xlim=c(0, 1), ylim=c(0, 1))
    lines(knots, target_knots, col="blue")
    result = list("knots"=knots, "target_knots"=target_knots, "model"=model, "count"=knots_count)
  } else {
    plot(original_predictor ~ original_target, xlim=c(0, 1), ylim=c(0, 1), col=colors)
    lines(ys, xs, col="blue")
    plot(knots ~ target_knots, xlim=c(0, 1), ylim=c(0, 1))
    lines(target_knots, knots, col="blue")
    result = list("knots"=target_knots, "target_knots"=knots, "model"=model, "count"=knots_count)
  }

  return(result)
  
}