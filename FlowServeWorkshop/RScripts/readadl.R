library(RevoScaleR)
rxSetComputeContext("local")
hostName = "adl://srramhdi.azuredatalakestore.net"
#tenantId = <TENANT ID>
#clientId = <CLIENT ID>
username = ""
password = ""
port = 0
file = "/Files/mbadataset11"
oAuth <- rxOAuthParameters(authUri = "https://login.windows.net", resource = "https://management.core.windows.net/", username = username, password = password,useWindowsAuth = FALSE)
#                           tenantId = tenantId, clientId = clientId, 
#                          resource = "https://management.core.windows.net/", username = NULL, password = NULL
#, authToken =<TOKEN>, useWindowsAuth = FALSE)
hdFS <- RxHdfsFileSystem(hostName = hostName, port = port, oAuthParameters = oAuth, verbose = TRUE)
myTextData <- RxTextData(file,
                         fileSystem = hdFS,
                         readDateFormat = "%Y-%m-%d",
                         firstRowIsColNames = FALSE,
                         returnDataFrame = TRUE,
                         quotedDelimiters = TRUE)

head(myTextData)
