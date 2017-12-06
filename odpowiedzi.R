# 1.
card <- h2o.importFile(path = "creditcard.csv",
                       destination_frame = "creditcard")
# 2.
card$Class <- as.factor(card$Class)
# 3.
card_train <- h2o.getFrame("creditcard_train")
card_valid <- h2o.getFrame("creditcard_valid")
card_test <- h2o.getFrame("creditcard_test")
# 4.
h2o.auc(rf1_perf)
# 5.
h2o.confusionMatrix(rf1_perf, metrics = "f2")
# 6.
h2o.getGrid("rf_grid",
            sort_by = "f2",
            decreasing = TRUE)
# 7. 
list.files("models/")