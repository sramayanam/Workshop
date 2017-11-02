api <- publishService(
  name =   "forecastservice",
code = predictvalues,
     inputs = list(INID1 = "numeric", INID2 = "numeric", INDATE = "character"),
     outputs = list(answer = "numeric"),
     v = "v2.0.1"
)

swagger <- api$swagger()
cat(swagger, file = "swaggerfinal.json", append = FALSE)