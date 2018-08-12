library(ggplot2)
library(ggalt)
library(scales)

isqplot <- function(course, width = 15, height = 8) {
  df <- read.csv(paste0(course, ".csv"))
  
  # Graph one professor and many courses or one course and many professors
  if (startsWith(course, "N") && nchar(course) == 9) {
    feature <- "Course"
    df$feature <- df$course
  } else {
    feature <- "Instructor"
    df$feature <- df$instructor
  }

  # Scatterplot of GPA vs rating (upper right = "better" professors)
  p <- ggplot(df, aes(x = rating, y = average_gpa, color = feature, size = pmin(response_rate / 100, 1))) +
    geom_encircle(aes(fill = feature), s_shape = 0.7, expand = 0.02, spread = 0.015, alpha = 0.1) +
    geom_text(aes(label = feature), nudge_y = -0.035, size = 3) +
    geom_point() +
    scale_size_continuous(labels = percent, range = c(1, 2.5)) +
    theme(plot.margin = margin(2, 2, 2, 2, "cm")) +
    guides(size = guide_legend(override.aes = list(linetype = 0))) +
    labs(
      title = course,
      subtitle = "University of North Florida",
      color = feature,
      fill = feature,
      size = "Response rate",
      x = "Rating",
      y = "Average GPA"
    )
  
  # Preview in RStudio
  print(p)
  
  # Save the previous plot to an image
  ggsave(
    paste0(course, ".png"),
    width = width,
    height = height,
    dpi = 100
  )
}
