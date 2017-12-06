# trigeR_h2o_12.2017
Machine Learning in H2O using R part II - Ensemble methods 

# Przed warsztatem:
Na warsztat każdy przychodzi z własnym laptopem. Należy zainstalować R, Rstudio oraz nastepujące pakiety: tidyverse, h2o. W przypadku zainstalowanego już pakietu h2o należy zrobić upgrade do najnowszej wersji.

```
install.packages("tidyverse")
install.packages("h2o")
```

# Testowanie instalacji h2o

```
h2o.init()
```
W konsoli R powinno pojawić się mniej więcej coś takiego:

```
H2O is not running yet, starting it now...

Note:  In case of errors look at the following log files:
    /tmp/RtmpQidjHm/h2o_maju116_started_from_r.out
    /tmp/RtmpQidjHm/h2o_maju116_started_from_r.err

openjdk version "1.8.0_151"
OpenJDK Runtime Environment (build 1.8.0_151-8u151-b12-0ubuntu0.16.04.2-b12)
OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)

Starting H2O JVM and connecting: ... Connection successful!

R is connected to the H2O cluster: 
    H2O cluster uptime:         3 seconds 22 milliseconds 
    H2O cluster version:        3.16.0.2 
    H2O cluster version age:    6 days  
    H2O cluster name:           H2O_started_from_R_maju116_afg317 
    H2O cluster total nodes:    1 
    H2O cluster total memory:   19.17 GB 
    H2O cluster total cores:    8 
    H2O cluster allowed cores:  8 
    H2O cluster healthy:        TRUE 
    H2O Connection ip:          localhost 
    H2O Connection port:        54321 
    H2O Connection proxy:       NA 
    H2O Internal Security:      FALSE 
    H2O API Extensions:         XGBoost, Algos, AutoML, Core V3, Core V4 
    R Version:                  R version 3.4.2 (2017-09-28)
 ```
 
 Następnie należy wczytać przykladowe dane:
 
 ```
 dane <- as.h2o(data.frame(x = 1:2, y = 1:2))
 ```
 
 Jeśli nie wystąpiły błedy wszystko jest w porządku. W razie wystąpienia błedów nalezy w pierwszej kolejności przeinstalować Java do nowszej wersji.
