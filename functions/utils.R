remove_outliers_dbscan <- function(dataset) {

  library(dbscan)

  # Todo: smarter removal of the outliers, dynamic eps	

  count_of_ts = length(unique(dataset$t))
  m_knots = ceiling(mean(table(dataset$t)))
  eps = .05
  
  if (m_knots > 2) {
    repeat {
      db = dbscan(dataset[, c("x", "y")], eps, minPts=count_of_ts)
      outlier_segments = unique(dataset$t[db$cluster != 1])
      if (length(outlier_segments) >= count_of_ts / 2) {
        eps = eps + .01
      } else {
        break
      }
    }
    trimmed = dataset[!(dataset$t %in% outlier_segments),]
  } else {
    trimmed = dataset
    outlier_segments = list()
  }

  return(list("trimmed"=trimmed, "outlier_segments"=outlier_segments))

}

get_outlier_groups_lr <- function(model, dataset, rs = 1.75) {
  hv = hatvalues(model)
  m_hv = mean(hv)
  leverages = unique(dataset$t[hv >= 3*m_hv])
  outliers = unique(dataset$t[abs(rstudent(model)) > rs])
  return(union(leverages, outliers))
}

remove_outliers_linear_regression <- function(dataset) {

  if (m_knots > 3) {
    
    var0 = var(dataset$x)
    var1 = var(dataset$y)
    if (var0 > var1) {
      predictor = dataset$x
      target = dataset$y
    } else {
      predictor = dataset$y
      target = dataset$x
    }

    model = lm(target ~ predictor)

    rs = 1.75
    pow = 1
    repeat {
      outlier_segments = get_outlier_groups_lr(model, dataset, rs)
      if (length(outlier_segments) >= count_of_ts / 2) {
        rs = rs + .1 * pow
        pow = pow + .2
      } else {
        break
      }
    }
    trimmed = dataset[!(dataset$t %in% outlier_segments),]
  
  } else {
    outlier_segments = list()
    trimmed = dataset
  }

  return(list("trimmed"=trimmed, "outlier_segments"=outlier_segments))

}