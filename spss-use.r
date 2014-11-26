## Copyright (c) 2012, 2014, University of Rochester
## All rights reserved.

## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are
## met:

##   * Redistributions of source code must retain the above copyright
##     notice, this list of conditions and the following disclaimer.
##   * Redistributions in binary form must reproduce the above copyright
##     notice, this list of conditions and the following disclaimer in
##     the documentation and/or other materials provided with the
##     distribution.
##   * Neither the name of the University of Rochester nor the names of
##     its contributors may be used to endorse or promote products
##     derived from this software without specific prior written
##     permission.

## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
## "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
## LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
## A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
## HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
## LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
## DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
## THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# load the data from the exported CSV
data <- read.csv("spss-usage.csv", header=FALSE)

# filter the SPSS use data by product type
# I'm sure there are cleverer ways to do this!
allspss.data <- subset(data, V1 == 1200)
spss19.data <- subset(data, V1 == 1200 & V2 == "v190")
spss20.data <- subset(data, V1 == 1200 & V2 == "v200")
spss21.data <- subset(data, V1 == 1200 & V2 == "v210")
spss22.data <- subset(data, V1 == 1200 & V2 == "v220")
# further filter Amos by only checked out items
amos.data <- subset(data, V1 == 9005 & (V6 == 0 | V6 == 8))

# make an array with the date (data[,4]) and time (data[,5]) columns
# joined and converted to numerics
allspss.use <- data.frame(datetime=strptime(paste(allspss.data[,4],
                                                  allspss.data[,5]),
                                                  "%m/%d/%Y %H:%M:%S"),
                          users=allspss.data[,7])
spss19.use <- data.frame(datetime=strptime(paste(spss19.data[,4],
                                                 spss19.data[,5]),
                                                 "%m/%d/%Y %H:%M:%S"),
                         users=spss19.data[,7])
spss20.use <- data.frame(datetime=strptime(paste(spss20.data[,4],
                                                 spss20.data[,5]),
                                                 "%m/%d/%Y %H:%M:%S"),
                         users=spss20.data[,7])
spss21.use <- data.frame(datetime=strptime(paste(spss21.data[,4],
                                                 spss21.data[,5]),
                                                 "%m/%d/%Y %H:%M:%S"),
                         users=spss21.data[,7])
spss22.use <- data.frame(datetime=strptime(paste(spss22.data[,4],
                                                 spss22.data[,5]),
                                                 "%m/%d/%Y %H:%M:%S"),
                         users=spss22.data[,7])
amos.use <- data.frame(datetime=strptime(paste(amos.data[,4],
                                               amos.data[,5]),
                                         "%m/%d/%Y %H:%M:%S"),
                       users=amos.data[,7])

# Title the graph with the date range; \u2013 is EM DASH
TITLE = paste("SPSS License Utilization: ",
              strftime(min(allspss.use$datetime), "%b %d, %Y"), " \u2013 ",
              strftime(max(allspss.use$datetime), "%b %d, %Y"), sep="")

# number of purchased licenses
MAXLICENSES <- 40  ## change this
MAXLICENSELABEL <- paste("available (", MAXLICENSES, ")", sep="")

# convenience calculations for the highest utilization
ymax <- max(allspss.use$users)
yearago <- as.Date(Sys.Date() - 365)
lastyear <- subset(allspss.use, as.Date(datetime) >= yearago)
yearmax <- max(lastyear$users)
ymaxlab <- paste("max. SPSS used (", ymax, "/", yearmax, ")", sep="")

# choose output file
png(filename="spss-usage.png", width=800, height=600, bg="white")

# make a line graph with the number of licenses used at a time
plot(allspss.use$datetime, allspss.use$users, type="l", main=TITLE,
     xlab="Month", ylab="Licenses Used", ylim=c(0, MAXLICENSES + 10),
     col="white")

lines(spss19.use$datetime, spss19.use$users, col="blueviolet")
lines(spss20.use$datetime, spss20.use$users, col="brown")
lines(spss21.use$datetime, spss21.use$users, col="cadetblue")
lines(spss22.use$datetime, spss22.use$users, col="darkorange")

# Amos is too sparsely used to be recognizable with a line graph
# (for now)
points(amos.use$datetime, amos.use$users, col="darkgreen", pch=20)

# add a line for the most licenses used at a time
abline(h=ymax, col="blue")
abline(h=yearmax, col="blue", lty=2)

# slightly wider line for maximum licenses available
abline(h=MAXLICENSES, col="red", lwd=1.5)

# add a legend
legend(min(allspss.use$datetime), MAXLICENSES + 11,
       c(MAXLICENSELABEL, ymaxlab, 'SPSS 19',
         'SPSS 20', 'SPSS 21', 'SPSS 22', 'Amos'),
       col=c("red", "blue", "blueviolet",
             "brown", "cadetblue", "darkorange", "darkgreen"),
       cex=0.8, lwd=1.5, lty=1:1)

# save the output file
dev.off()

# Since the data is available, output last hour's use for Nagios monitoring.
lasthour <- max(allspss.use[allspss.use$datetime >= (Sys.time() - 3600),]$users, 0)
cat(lasthour, file="max_spss_use.txt", sep="\n")
