#' ### Dependencies
#' Figures are drawn using ggplot2.
#+ message=FALSE
library(ggplot2)
library(ggplot2bdc)
library(ggalt)
library(scales)
library(plyr)
library(dplyr)

#' ### Data
#' This example uses data from Computer Science 1 from 2012-2018, available at
#' [`data/COP2220.csv`](data/COP2220.csv). The code can be adapted to use data
#' from any source so long as all the required columns are satisfied. Check out
#' [ISQool](https://github.com/rothso/isqool) to learn how to generate CSVs for
#' other UNF courses.
fileName <- "STA4321"
read_data <- function(fileName) {
  read.csv(paste0("data/", fileName, ".csv")) %>%
    select(course, term, instructor, rating, average_gpa) %>%
    na.omit()
}
df <- read_data(fileName)

#' `r knitr::kable(head(df), row.names = FALSE)`

#' Based on the file name, we can determine if the file represents one course
#' and various professors, like above, or one professor and various courses.
#' We're plotting the *feature* that varies (as the other will be constant).
add_feature <- function(df, fileName) {
  isProfessor <- startsWith(fileName, "N") && nchar(fileName) == 9
  if(isProfessor) {
    df$feature = df$course
    comment(df$feature) <- "Course"
  } else {
    df$feature = df$instructor
    comment(df$feature) <- "Instructor"
  }
  df
}
df <- add_feature(df, fileName)

#' ### Scatter Plot
#+ scatterplot
ggplot(df, aes(x = rating, y = average_gpa, color = feature)) +
geom_encircle(aes(fill = feature), s_shape = 0.7, expand = 0.02, spread = 0.015, alpha = 0.1) +
geom_text(aes(label = feature), nudge_y = -0.035, size = 3) +
geom_point() +
guides(size = guide_legend(override.aes = list(linetype = 0))) +
labs(
  title = fileName,
  subtitle = paste0("Course evaluation results from ", nrow(df), " classes"),
  caption = "Source: UNF ISQ Departmental Data Summary",
  color = comment(df$feature),
  fill = comment(df$feature),
  x = "Average Student Rating",
  y = "Average GPA"
) +
theme_bdc_grey(grid.x = TRUE, grid.y = TRUE) +
theme(legend.position = "right", legend.direction = "vertical", legend.title.align = 0)

#' ### Focused Scatter Plot
#+ echo=FALSE
fileName <- "ENC1143"
df <- read_data(fileName) %>%
  add_feature(fileName)

#' If a plot contains a lot of data (400+ points), it would be nice to
#' differentiate only those points which we care about. We can highlight a
#' specific professor we're interested in by reducing our feature to just two
#' levels.
highlight <- "Berry"
df$feature <- ifelse(df$feature == highlight, highlight, "Other")

#' Let's gray out the other data points and use blue as our accent color.
palette <- c("#003886", "#CCD7E7")
names(palette) <- c(highlight, "Other")

#highlight <- tail(levels(df$feature), 4)
highlight <- c("Summer 2018", "Spring 2018", "Fall 2017", "Summer 2017")
df$feature <- df$term
df$feature <- factor(df$feature, levels = c(levels(df$feature), "Other"))
df$feature[!df$feature %in% highlight] <- "Other"
df$feature <- ordered(df$feature, levels = c(highlight, "Other"))

library(RColorBrewer)
palette <- c(rev(brewer.pal(8, "BuPu"))[1:4], "#CCD7E7")

#' We'll then adjust the `geom_text` to hide superfluous labels and move the
#' `geom_points` behind the text.
#+ focusplot
ggplot(df, aes(rating, average_gpa, color = feature, order = -as.numeric(feature))) +
  geom_encircle(aes(fill = feature), s_shape = 0.7, expand = 0.02, spread = 0.015, alpha = 0.1) +
  geom_point() +
  geom_text(data = subset(df, feature != "Other"), aes(label = instructor), nudge_y = -0.035, size = 3) +
  geom_point(alpha = 0.2) +
  scale_color_manual(values = palette) +
  scale_fill_manual(values = palette) +
  labs(
    title = fileName,
    subtitle = paste0("Course evaluation results from ", nrow(df), " classes"),
    caption = "Source: UNF ISQ Departmental Data Summary",
    color = comment(df$feature),
    fill = comment(df$feature),
    x = "Average Student Rating",
    y = "Average GPA"
  ) +
  theme_bdc_grey(grid.x = TRUE, grid.y = TRUE) +
  theme(legend.position = "right", legend.direction = "vertical", legend.title.align = 0)

# Reorder terms
df$feature <- df$term %>% 
  reorder(as.character(.), function(term) { 
    s <- strsplit(term, " ")[[1]]
    suffix <- switch(s[1], Spring = 1, Summer = 2, Fall = 3)
    prefix <- as.numeric(s[2])
    prefix * 10 + suffix
  })

# Combine multiple observations for the same instructor and semester
df2 <- df %>% 
  group_by(feature, instructor) %>% 
  summarize(average_gpa = mean(average_gpa))

sp18 <- which(levels(df$feature) %in% "Spring 2018") - 0.3

ggplot(df2, aes(feature, average_gpa, color = instructor, group = instructor)) +
  geom_line() +
  geom_point() +
  geom_vline(xintercept = sp18, linetype = "dotted") +
  annotate(geom="text", label="Introduced Recitation", angle = 90, x= sp18, y = 3.2, vjust= -1) +
  scale_x_discrete(breaks = levels(df$feature)[c(F, T, F)]) +
  labs(
    title = fileName,
    subtitle = paste0("Course evaluation results from ", nrow(df), " classes"),
    caption = "Source: UNF ISQ Departmental Data Summary",
    color = comment(df$feature),
    fill = comment(df$feature),
    x = "Semester",
    y = "Average GPA"
  ) +
  theme_bdc_grey(grid.x = TRUE, grid.y = TRUE) +
  theme(legend.position = "right", legend.direction = "vertical", legend.title.align = 0)


#' #### Saving to an image
#+ eval=FALSE
# Add a plot margin to make it look pretty
last_plot() + theme(plot.margin = margin(2, 2, 2, 2, "cm"))

# Save as a 15 x 8 inch image
ggsave(paste0(fileName, ".png"), width = 12, height = 8, dpi = 100)
 