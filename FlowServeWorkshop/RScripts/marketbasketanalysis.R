library("arules")
library("grid")
library("arulesviz")
transactions <- read.transactions("/Users/srram/Downloads/mbadataset21", format = "single", sep=",",cols = c("TransactionID","Itemname"))
summary(transactions)
itemFrequencyPlot(tr, topN=20, type='absolute')

rules <- apriori(transactions, parameter = list(supp=0.001, conf=0.8))
rules <- sort(rules, by='confidence', decreasing = TRUE)
summary(rules)
inspect(head(sort(rules, by ="lift"),3))