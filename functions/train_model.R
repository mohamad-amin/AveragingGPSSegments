train_model <- function(dataset) {

  library(lspline)

  # Choosing the predictor and the target
  variance_x = var(dataset$x)
  variance_y = var(dataset$y)
  if (variance_x > variance_y) {
    predictor = dataset$x
    target = dataset$y
    predictor_name = "x"
  } else {
    predictor = dataset$y
    target = dataset$x
    predictor_name = "y"
  }
  
  # Todo: smarter number of knots
  m_knots = round(mean(table(dataset$t)))
  knots_count = m_knots

  # Todo: smarter begin and end
  if (predictor_name == "x") {
    xs = aggregate(dataset, by=list(dataset$t), FUN=min)$x
    start = mean(xs) + sd(xs)
    xe = aggregate(dataset, by=list(dataset$t), FUN=max)$x
    end = mean(xe) - sd(xe)
    if (start > end) {
      start = mean(xs)
      end = mean(xe)
    }
  } else {
    ys = aggregate(dataset, by=list(dataset$t), FUN=min)$y
    start = mean(ys) + sd(ys)
    ye = aggregate(dataset, by=list(dataset$t), FUN=max)$y
    end = mean(ye) - sd(ye)
    if (start > end) {
      start = mean(ys)
      end = mean(ye)
    }
  }
  knots = seq(start, end, by=1/knots_count)
  if (max(knots) < end) {
    knots[[length(knots) + 1]] = end
  }

  # Fitting the model
  if (knots_count < 4) {
    model = lm(target ~ predictor)
    # Todo: smarter begin and end
    knots = c(start, end)
  } else {
    model = lm(target ~ lspline(predictor, knots))
  }
  
  if (predictor_name == "x") {
    knots = append(mean(xs), knots)
    knots = append(knots, mean(xe))
  } else {
    knots = append(mean(ys), knots)
    knots = append(knots, mean(ye))
  }
  target_knots = predict(model, data.frame(predictor=knots))
  
  return(list(
    "model"=model, 
    "predictor_name"=predictor_name,
    "predictor"=predictor,
    "target"=target,
    "knots"=knots,
    "target_knots"=target_knots,
    "knots_count"=knots_count
  ))

}