Sys.setlocale("LC_MESSAGES", 'en_GB.UTF-8')
Sys.setenv(LANG = "en_US.UTF-8")
library(h2o)
library(tidyverse)

# Tworzymy połączenie z H2O
localH2O <- h2o.init(ip = "localhost", # domyślnie
                     port = 54321, # domyślnie
                     nthreads = -1, # użyj wszystkich dostepnych rdzeni
                     min_mem_size = "20g") # własne ustawienia

# Wczytujemy dane
# 1. Wczytaj do H2O dane z pliku 'credicard.csv'. Ustaw nazwę pos stronie R na 'card'
# 2. Zmień typ zmiennej 'Class' na factor.
dim(card)
summary(card)
h2o.table(card$Class)

# Dzielimy na zbiór treningowy, walidaycjny i testowy
h2o.splitFrame(card,
               ratios = c(0.7, 0.15),
               destination_frames = c("creditcard_train", "creditcard_valid", "creditcard_test"),
               seed = 1234)
h2o.ls()
# 3. Używając funkcji h2o.getFrame() utwórz w R przypisanie: 'card_train', 'card_valid' i 'card_test'

# Random forest
rf1 <- h2o.randomForest(
  x = 2:29, # Predyktory
  y = "Class", # Zmianna objaśniana
  training_frame = card_train, # Zbiór testowy
  validation_frame = card_valid, # Zbiór walidacyjny
  model_id = "rf1", # Klucz modelu w H2O
  ntrees = 10, # Ilość dzrzew klasyfikacyjnych
  max_depth = 10, # Maksymalna wielkość drzewa
  mtries = 2, # Procent losowo wybranych kolumn w splicie
  sample_rate = 0.6320000291, # Prawdopodbieństwo ponownego wylosowania danej obserwacji,
  min_rows = 1, # Minimum obserwacji per liść
  seed = 1234
)

rf1_perf <- h2o.performance(rf1, newdata = card_test)
# 4. Z powyzszego obiektu wyciągnij miarę 'auc'
# 5. ... oraz Confusion Matrix dla metryki 'f2'

rf2 <- h2o.randomForest(
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  model_id = "rf2",
  ntrees = 200, # Zwiększamy
  max_depth = 30, # Zwiększamy
  mtries = 5,
  sample_rate = 0.6320000291,
  min_rows = 1,
  seed = 1234,
  balance_classes = TRUE, # Over/under-sampling
  nfolds = 5, # Walidacja CV5
  fold_assignment = "Modulo", # Co piąta obserwacja do innego foldu
  keep_cross_validation_predictions = TRUE
)

rf2_perf <- h2o.performance(rf2, newdata = card_test)
h2o.auc(rf2_perf)
h2o.confusionMatrix(rf2_perf, metrics = "f2")

# Grid search
hyper_params <- list(
  ntrees = c(10, 50),
  max_depth =  c(5, 10, 20, 30),
  mtries = c(2, 5, 10, 20)
)

rf_grid <- h2o.grid(
  algorithm = "randomForest",
  grid_id = "rf_grid",
  hyper_params = hyper_params,
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  seed = 1234,
  balance_classes = TRUE,
  nfolds = 5,
  fold_assignment = "Modulo",
  keep_cross_validation_predictions = TRUE,
  stopping_metric = "logloss",
  stopping_tolerance = 0.01,
  stopping_rounds = 2 # Jeśli logloss nie zmieni się średnio o 0.005 po dodaniu
  # kolejnych 2 drzew to przestajemy dodawać.
)

# 6. Posortuj powyzszy grid malejąco względem miary 'f2' (funkcja h2o.getGrid())

# rf_grid@model_ids %>% map(~ h2o.saveModel(h2o.getModel(.x), path = "models/"))

# Gradient Boosted Machines
gbm1 <- h2o.gbm(
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  model_id = "gbm1",
  ntrees = 10, # Ilość iteracji dzrzew klasyfikacyjnych
  max_depth = 10,
  learn_rate = 0.1, # Jak ważne są kolejne dodane predykcje na gradientach:
  learn_rate_annealing = 1, # f_0 + 1^1*0.1*f_1 + 1^2*0.1*f_2 + 1^3*0.1*f_3 + ...
  seed = 1234
)

gbm1_perf <- h2o.performance(gbm1, newdata = card_test)
h2o.auc(gbm1_perf)
h2o.confusionMatrix(gbm1_perf, metrics = "f2")

gbm2 <- h2o.gbm(
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  model_id = "gbm2",
  balance_classes = TRUE,
  nfolds = 5,
  fold_assignment = "Modulo",
  keep_cross_validation_predictions = TRUE,
  ntrees = 100, # Zwiększamy
  max_depth = 10,
  learn_rate = 0.15, # Zwiększamy
  learn_rate_annealing = 0.1, # Zmniejszamy
  stopping_rounds = 2, # Dodajemy stopowanie
  stopping_tolerance = 0.01,
  seed = 1234
)

gbm2_perf <- h2o.performance(gbm2, newdata = card_test)
h2o.auc(gbm2_perf)
h2o.confusionMatrix(gbm2_perf, metrics = "f2")

# Grid search
hyper_params <- list(
  ntrees = c(20, 50),
  max_depth =  c(5, 10, 20, 30),
  learn_rate = seq(0.05, 0.2, by = 0.05),
  learn_rate_annealing = seq(0.05, 1, by = 0.05)
)

gbm_grid <- h2o.grid(
  algorithm = "gbm",
  grid_id = "gbm_grid",
  hyper_params = hyper_params,
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  seed = 1234,
  balance_classes = TRUE,
  nfolds = 5,
  fold_assignment = "Modulo",
  keep_cross_validation_predictions = TRUE,
  stopping_metric = "logloss",
  stopping_tolerance = 0.01,
  stopping_rounds = 2,
  search_criteria = list(strategy = "RandomDiscrete", # Random Search
                         max_runtime_secs = 600, 
                         max_models = 100, 
                         seed = 1234)
)

h2o.getGrid("gbm_grid",
            sort_by = "f2",
            decreasing = TRUE)

# gbm_grid@model_ids %>% map(~ h2o.saveModel(h2o.getModel(.x), path = "models/"))

# Stacking
stack1 <- h2o.stackedEnsemble(
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  model_id = "stack1",
  base_models = list("rf2", "gbm2") # Lista modelu do stackingu
)

stack1_perf <- h2o.performance(stack1, newdata = card_test)
h2o.auc(stack1_perf)
h2o.confusionMatrix(stack1_perf, metrics = "f2")

# models_ids <- append(rf_grid@model_ids, gbm_grid@model_ids)
models_ids <- # 7. Wyciągnij nazwy modeli z folderu 'models/'
models_ids %>% map(~ h2o.loadModel(path = paste0("models/", .x)))
stack2 <- h2o.stackedEnsemble(
  x = 2:29,
  y = "Class",
  training_frame = card_train,
  validation_frame = card_valid,
  model_id = "stack2",
  base_models = models_ids
)

stack2_perf <- h2o.performance(stack2, newdata = card_test)
h2o.auc(stack2_perf)
h2o.confusionMatrix(stack2_perf, metrics = "f2")

# AutoML
aml <- h2o.automl(x = 2:19,
                  y = "Class",
                  training_frame = card_train,
                  validation_frame = card_valid,
                  leaderboard_frame = card_test,
                  nfolds = 5,
                  seed = 1234,
                  max_runtime_secs = 30
)

aml@leaderboard
aml@leader
