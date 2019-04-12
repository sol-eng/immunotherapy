# https://blogs.rstudio.com/tensorflow/posts/2018-01-29-dl-for-cancer-immunotherapy/

# # Keras + TensorFlow and it's dependencies
# install.packages("keras")
# library(keras)
# install_keras()
#
# # Tidyverse (readr, ggplot2, etc.)
# install.packages("tidyverse")
#

library(keras)
library(tfdeploy)
library(tidyverse)
library(PepTools)

use_implementation("keras")

pep_file <- get_file(
  "ran_peps_netMHCpan40_predicted_A0201_reduced_cleaned_balanced.tsv",
  origin = "https://git.io/vb3Xa"
)
pep_dat <- read_tsv(file = pep_file)

pep_dat %>% head()


x_train <- pep_dat %>%
  filter(data_type == "train") %>%
  pull(peptide) %>%
  pep_encode()

y_train <- pep_dat %>%
  filter(data_type == "train") %>%
  pull(label_num) %>%
  array()

x_test <- pep_dat %>%
  filter(data_type == "test") %>%
  pull(peptide) %>%
  pep_encode()

y_test <- pep_dat %>%
  filter(data_type == "test") %>%
  pull(label_num) %>%
  array()

dim(x_train)


x_train <- array_reshape(x_train, c(nrow(x_train), 9 * 20))
x_test <- array_reshape(x_test, c(nrow(x_test), 9 * 20))

y_train <- to_categorical(y_train, num_classes = 3)
y_test <- to_categorical(y_test, num_classes = 3)

model <- keras_model_sequential() %>%
  layer_dense(units = 180, activation = "relu", input_shape = 180) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 90, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 3, activation = "softmax")

summary(model)

model %>%
  compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_rmsprop(),
    metrics = c("accuracy")
  )

history <- model %>%
  fit(
    x_train, y_train,
    epochs = 20,
    batch_size = 64,
    validation_split = 0.2
  )



library(ggplot2)
plot(history)

perf <- model %>%
  evaluate(x_test, y_test)
perf


y_pred <- model %>%
  predict_classes(x_test)

y_real <- y_test %>%
  apply(1, function(x) {
    return(which(x == 1) - 1) %>%
  })

results <- tibble(
  y_real = y_real %>% factor(levels = 2:0),
  y_pred = y_pred %>% factor(levels = 0:2),
  Correct = if_else(y_real == y_pred, "yes", "no") %>% factor()
)

library(glue)

results %>%
  ggplot(aes(x = y_pred, y = y_real, fill = Correct)) +
  # geom_point() +
  geom_tile(aes(fill = Correct), stat = "sum") +
  geom_jitter(alpha = 0.5) +
  ggtitle(
    label = "Performance on 10% unseen data - Feed Forward Neural Network",
    subtitle = glue::glue("Accuracy = {round(perf$acc, 3) * 100}%")
  ) +
  xlab(
    "Measured\n(Real class, as predicted by netMHCpan-4.0)"
  ) +
  ylab(
    "Predicted\n(Class assigned by Keras / TensorFlow model)"
  ) +
  scale_fill_manual(
    labels = c("No", "Yes"),
    values = c("red", "blue")
  ) +
  theme_bw()


# save model for deployment -----------------------------------------------

model %>% tensorflow::export_savedmodel(export_dir_base =  "saved_models")
