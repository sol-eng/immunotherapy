# https://blogs.rstudio.com/tensorflow/posts/2018-01-29-dl-for-cancer-immunotherapy/

Sys.unsetenv("RETICULATE_PYTHON")

library(keras)
library(tfdeploy)
library(tidyverse)
library(ggplot2)
library(glue)
library(ggseqlogo)
library(PepTools)

use_implementation("keras")

# Download and cache the data locally

pep_file <- get_file(
  "ran_peps_netMHCpan40_predicted_A0201_reduced_cleaned_balanced.tsv",
  origin = "https://git.io/vb3Xa",
  cache_subdir = "~/datasets"
)



# Import the data

pep_dat <- read_tsv(file = pep_file)


# Set up train and test samples

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

# Reshape the data into Python recognized format

x_train <- array_reshape(x_train, c(nrow(x_train), 9 * 20))
x_test  <- array_reshape(x_test, c(nrow(x_test), 9 * 20))

y_train <- to_categorical(y_train, num_classes = 3)
y_test  <- to_categorical(y_test, num_classes = 3)


# Define the model

model <-
  keras_model_sequential() %>%
  layer_dense(units = 180, activation = "relu", input_shape = 180) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 90, activation = "relu") %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 3, activation = "softmax")

summary(model)

model %>%
  compile(
    loss = "categorical_crossentropy",
    optimizer = optimizer_rmsprop(epsilon = 1e-7),
    metrics = c("accuracy")
  )

# Train the model

history <-
  model %>%
  fit(
    x_train, y_train,
    epochs = 10,
    batch_size = 64,
    validation_split = 0.2
  )


# Evaluate model performance

plot(history)

perf <- model %>%
  evaluate(x_test, y_test)
perf


y_pred <- model %>%
  predict_classes(x_test)

y_real <- y_test %>%
  apply(1, function(x) {which(x == 1) - 1 })

peptide_classes <- c("NB", "WB", "SB")
results <- tibble(
  measured  = y_real %>% factor(levels = 0:2, labels = peptide_classes),
  predicted = y_pred %>% factor(levels = 0:2, labels = peptide_classes),
  Correct = if_else(y_real == y_pred, "yes", "no") %>% factor()
)


results %>%
  ggplot(aes(colour = Correct)) +
  geom_jitter(aes(x = 0, y = 0), alpha = 0.5) +
  ggtitle(
    label = "Performance on 10% unseen data",
    subtitle = glue::glue("Accuracy = {round(perf['accuracy'], 3) * 100}%")
  ) +
  xlab(
    "Measured\n(Real class, as predicted by netMHCpan-4.0)"
  ) +
  ylab(
    "Predicted\n(Class assigned by Keras / TensorFlow model)"
  ) +
  scale_colour_manual(
    labels = c("No", "Yes"),
    values = c("red", "blue")
  ) +
  theme_bw() +
  facet_grid(predicted ~ measured, labeller = label_both) +
  ggplot2::theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )


# save model for deployment -----------------------------------------------

model %>%
  export_savedmodel(export_dir_base =  "saved_models")
