read_all_segments <- function(root_dir) {
  sets = list()
  for (set in list.files(root_dir)) {
    x = c()
    y = c()
    t = c()
    group = 1
    for (line in readLines(set)) {
      if (line == "") {
        group = group + 1
      } else {
        t = append(t, group)
        xy = as.double(unlist(strsplit(line, " ")))
        x = append(x, xy[1])
        y = append(y, xy[2])
      }
    }
    sets = append(sets, data.frame(t, x, y))
  }
  return(sets)
}

read_segment <- function(file_name) {
  x = c()
  y = c()
  t = c()
  group = 1
  for (line in readLines(file_name)) {
    if (line == "") {
      group = group + 1
    } else {
      t = append(t, group)
      xy = as.double(unlist(strsplit(line, " ")))
      x = append(x, xy[1])
      y = append(y, xy[2])
    }
  }
  return(data.frame(t, x, y))
}