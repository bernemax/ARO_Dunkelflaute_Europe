## InfraTrain Project
## Make synthetized years including TDY, EHCF and ELCF for wind & solar CF in Germany
## Call dataset in xlsx format
library("readxl")
G_sol_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_DE.xlsx",sheet = "sol")
G_won_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_DE.xlsx",sheet = "won")
G_wof_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_DE.xlsx",sheet = "wof")
# rows include years from 1950 to 2020 and columns include hourly data in each year
G_sol = matrix(NA,nrow=71,ncol=8760) 
G_won = matrix(NA,nrow=71,ncol=8760)
G_wof = matrix(NA,nrow=71,ncol=8760)

for(i in 2:72){
    G_sol[(i-1),] = G_sol_data[[i]]
    G_won[(i-1),] = G_won_data[[i]]
    G_wof[(i-1),] = G_wof_data[[i]] 
}
annual_mean_G_sol = rowMeans(G_sol)
annual_mean_G_won = rowMeans(G_won)
annual_mean_G_wof = rowMeans(G_wof)

plot(G_sol[1,], type = 'l')
points(G_sol[2,], type = 'l', col = 'blue')
## To make a single vector of sol, won and wof
sol = vector("numeric",621960)
won = vector("numeric",621960)
wof = vector("numeric",621960)
for(i in 1:71){
    sol[((i-1)*8760+1):(i*8760)] = G_sol[i,]
    won[((i-1)*8760+1):(i*8760)] = G_won[i,]
    wof[((i-1)*8760+1):(i*8760)] = G_wof[i,]
}

## Boxplot to show the median and quartiles of sol, won and wof in 71 years (24*365*71=621960 datapoints)
library(tidyverse)
library(hrbrthemes)
library(viridis) 
## To complete dataframe and boxplot
data <- data.frame(name=c(rep("sol",621960), rep("won",621960), rep("wof",621960)),
  value=c( sol, won, wof))

data %>%
ggplot( aes(x=name, y=value, fill=name)) +
    geom_boxplot() +
    scale_fill_viridis(discrete = TRUE, alpha=0.6) +
    geom_jitter(color="black", size=0.4, alpha=0.9) +
    theme_ipsum() +
    theme(
      legend.position="none",
      plot.title = element_text(size=11)
    ) +
    ggtitle("A boxplot with jitter") +
    xlab("")
data %>%
  ggplot( aes(x=name, y=value, fill=name)) +
    geom_boxplot() +
    scale_fill_viridis(discrete = TRUE, alpha=0.6, option="A") +
    theme_ipsum() +
    theme(
      legend.position="none",
      plot.title = element_text(size=11)
    ) +
    ggtitle("Basic boxplot") +
    xlab("")
boxplot(Temp~Month,
data=airquality,
main="Different boxplots for each month",
xlab="Month Number",
ylab="Degree Fahrenheit",
col="orange",
border="brown"
)


## Monthly and annualy CDF from January to December (Assumption: equal days in each month) --> FS statistics
M_CDF_sol = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_sol = matrix(NA, nrow = 1, ncol = (100*12))
x_sol = matrix(NA, nrow = 12, ncol = 2) # To fix range of data for CDF calculations
x_won = matrix(NA, nrow = 12, ncol = 2)
x_wof = matrix(NA, nrow = 12, ncol = 2)
for(i in 1:12){
    x_sol[i,1] = min(G_sol[,((i-1)*720+1):(i*720)])
    x_sol[i,2] = max(G_sol[,((i-1)*720+1):(i*720)])
    x_won[i,1] = min(G_won[,((i-1)*720+1):(i*720)])
    x_won[i,2] = max(G_won[,((i-1)*720+1):(i*720)])
    x_wof[i,1] = min(G_wof[,((i-1)*720+1):(i*720)])
    x_wof[i,2] = max(G_wof[,((i-1)*720+1):(i*720)])

}
for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(G_sol[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol[i,1],x_sol[i,2],length=100)
        #x_n = seq(min(G_sol_new[j,((i-1)*720+1):(i*720)]),max(G_sol_new[j,((i-1)*720+1):(i*720)]),length=100)
        t_n = Fn(x_n)
        M_CDF_sol[j,((i-1)*100+1):(i*100)] = t_n }
}
for(i in 1:12){
    Fn = ecdf(G_sol[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol[i,1],x_sol[i,2],length=100)
    #x_n = seq(min(G_sol_new[1:71,((i-1)*720+1):(i*720)]),max(G_sol_new[1:71,((i-1)*720+1):(i*720)]),length=100)
    t_n = Fn(x_n)
    A_CDF_sol[1,((i-1)*100+1):(i*100)] = t_n
}

plot(seq(x_sol[1,1],x_sol[1,2],length=100),A_CDF_sol[1,1:100])
points(seq(x_sol[1,1],x_sol[1,2],length=100),M_CDF_sol[2,1:100],col='red')
points(seq(x_sol[1,1],x_sol[1,2],length=100),M_CDF_sol[3,1:100],col='blue')
points(seq(x_sol[1,1],x_sol[1,2],length=100),M_CDF_sol[50,1:100],col='green')
points(seq(x_sol[1,1],x_sol[1,2],length=100),M_CDF_sol[70,1:100],col='yellow')
plot(seq(x_sol[2,1],x_sol[2,2],length=100),A_CDF_sol[1,(1*100+1):(2*100)])
points(seq(x_sol[2,1],x_sol[2,2],length=100),M_CDF_sol[2,(1*100+1):(2*100)],col='red')
points(seq(x_sol[2,1],x_sol[2,2],length=100),M_CDF_sol[3,(1*100+1):(2*100)],col='blue')
points(seq(x_sol[2,1],x_sol[2,2],length=100),M_CDF_sol[50,(1*100+1):(2*100)],col='green')
points(seq(x_sol[2,1],x_sol[2,2],length=100),M_CDF_sol[70,(1*100+1):(2*100)],col='yellow')

M_CDF_won = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_won = matrix(NA, nrow = 1, ncol = (100*12))

for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(G_won[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won[i,1],x_won[i,2],length=100)
        #x_n = seq(min(G_won_new[j,((i-1)*720+1):(i*720)]),max(G_won_new[j,((i-1)*720+1):(i*720)]),length=100)
        t_n = Fn(x_n)
        M_CDF_won[j,((i-1)*100+1):(i*100)] = t_n }
}
for(i in 1:12){
    Fn = ecdf(G_won[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won[i,1],x_won[i,2],length=100)
    #x_n = seq(min(G_won_new[1:71,((i-1)*720+1):(i*720)]),max(G_won_new[1:71,((i-1)*720+1):(i*720)]),length=100)
    t_n = Fn(x_n)
    A_CDF_won[1,((i-1)*100+1):(i*100)] = t_n
}

plot(seq(x_won[1,1],x_won[1,2],length=100),A_CDF_won[1,1:100])
points(seq(x_won[1,1],x_won[1,2],length=100),M_CDF_won[2,1:100],col='red')
points(seq(x_won[1,1],x_won[1,2],length=100),M_CDF_won[3,1:100],col='blue')
points(seq(x_won[1,1],x_won[1,2],length=100),M_CDF_won[50,1:100],col='green')
points(seq(x_won[1,1],x_won[1,2],length=100),M_CDF_won[70,1:100],col='yellow')
plot(seq(x_won[2,1],x_won[2,2],length=100),A_CDF_won[1,(1*100+1):(2*100)])
points(seq(x_won[2,1],x_won[2,2],length=100),M_CDF_won[2,(1*100+1):(2*100)],col='red')
points(seq(x_won[2,1],x_won[2,2],length=100),M_CDF_won[3,(1*100+1):(2*100)],col='blue')
points(seq(x_won[2,1],x_won[2,2],length=100),M_CDF_won[50,(1*100+1):(2*100)],col='green')
points(seq(x_won[2,1],x_won[2,2],length=100),M_CDF_won[70,(1*100+1):(2*100)],col='yellow')

M_CDF_wof = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_wof = matrix(NA, nrow = 1, ncol = (100*12))

for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(G_wof[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof[i,1],x_wof[i,2],length=100)
        #x_n = seq(min(G_wof_new[j,((i-1)*720+1):(i*720)]),max(G_wof_new[j,((i-1)*720+1):(i*720)]),length=100)
        t_n = Fn(x_n)
        M_CDF_wof[j,((i-1)*100+1):(i*100)] = t_n }
}
for(i in 1:12){
    Fn = ecdf(G_wof[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof[i,1],x_wof[i,2],length=100)
    #x_n = seq(min(G_wof_new[1:71,((i-1)*720+1):(i*720)]),max(G_wof_new[1:71,((i-1)*720+1):(i*720)]),length=100)
    t_n = Fn(x_n)
    A_CDF_wof[1,((i-1)*100+1):(i*100)] = t_n
}
plot(seq(x_wof[1,1],x_wof[1,2],length=100),A_CDF_wof[1,1:100])
points(seq(x_wof[1,1],x_wof[1,2],length=100),M_CDF_wof[2,1:100],col='red')
points(seq(x_wof[1,1],x_wof[1,2],length=100),M_CDF_wof[3,1:100],col='blue')
points(seq(x_wof[1,1],x_wof[1,2],length=100),M_CDF_wof[50,1:100],col='green')
points(seq(x_wof[1,1],x_wof[1,2],length=100),M_CDF_wof[70,1:100],col='yellow')

## Synthetize years with typical & extreme wind & solar power in Germany
G_abs_sol = matrix(NA, nrow = 71, ncol = 12)
G_abs_won = matrix(NA, nrow = 71, ncol = 12)
G_abs_wof = matrix(NA, nrow = 71, ncol = 12)

G_real_sol = matrix(NA, nrow = 71, ncol = 12)
G_real_won = matrix(NA, nrow = 71, ncol = 12)
G_real_wof = matrix(NA, nrow = 71, ncol = 12)

for(i in 1:71){
    for(j in 1:12){
        G_abs_sol[i,j] = abs(mean(A_CDF_sol[1,((j-1)*100+1):(j*100)]-M_CDF_sol[i,((j-1)*100+1):(j*100)]))
        G_abs_won[i,j] = abs(mean(A_CDF_won[1,((j-1)*100+1):(j*100)]-M_CDF_won[i,((j-1)*100+1):(j*100)]))
        G_abs_wof[i,j] = abs(mean(A_CDF_wof[1,((j-1)*100+1):(j*100)]-M_CDF_wof[i,((j-1)*100+1):(j*100)]))
    }
}

for(i in 1:71){
    for(j in 1:12){
        G_real_sol[i,j] = (mean(A_CDF_sol[1,((j-1)*100+1):(j*100)]-M_CDF_sol[i,((j-1)*100+1):(j*100)]))
        G_real_won[i,j] = (mean(A_CDF_won[1,((j-1)*100+1):(j*100)]-M_CDF_won[i,((j-1)*100+1):(j*100)]))
        G_real_wof[i,j] = (mean(A_CDF_wof[1,((j-1)*100+1):(j*100)]-M_CDF_wof[i,((j-1)*100+1):(j*100)]))
    }
}
ylim1_sol = min(G_abs_sol)
ylim2_sol = max(G_abs_sol)
ylim1_won = min(G_abs_won)
ylim2_won = max(G_abs_won)
ylim1_wof = min(G_abs_wof)
ylim2_wof = max(G_abs_wof)

ylim12_sol = min(G_real_sol)
ylim22_sol = max(G_real_sol)
ylim12_won = min(G_real_won)
ylim22_won = max(G_real_won)
ylim12_wof = min(G_real_wof)
ylim22_wof = max(G_real_wof)

## Synthetize TDY, EHCF and ELCF for sol
pdf("~/Desktop/FS_sol.pdf")
par(mfrow=c(1,2))
plot(G_abs_sol[1,], ylim = c(ylim1_sol,ylim2_sol), ylab = "G_abs_FS_sol",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_abs_sol[i,], ylab = "",xlab="",xaxt="n")
}

plot(G_real_sol[1,], ylim = c(ylim12_sol,ylim22_sol), ylab = "G_real_FS_sol",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_real_sol[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_sol = vector("numeric",12)
min_real_sol = vector("numeric",12)
max_real_sol = vector("numeric",12)
for(i in 1:12){
    min_abs_sol[i] = which.min(G_abs_sol[,i])
    min_real_sol[i] = which.min(G_real_sol[,i])
    max_real_sol[i] = which.max(G_real_sol[,i])
}

TDY = vector("numeric",(12*720))
EHCF = vector("numeric",(12*720))
ELCF = vector("numeric",(12*720))
for(i in 1:12){
    TDY[((i-1)*720+1):(i*720)] = G_sol[min_abs_sol[i], ((i-1)*720+1):(i*720)]
    EHCF[((i-1)*720+1):(i*720)] = G_sol[min_real_sol[i], ((i-1)*720+1):(i*720)]
    ELCF[((i-1)*720+1):(i*720)] = G_sol[max_real_sol[i], ((i-1)*720+1):(i*720)]
}
pdf("~/Desktop/CDF_sol.pdf")
Fn = ecdf(G_sol[1,])
x_min = min(G_sol)
x_max = max(G_sol)
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="G_sol_capacity_factor",ylab="CDF",col='grey')
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(G_sol[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY)
x_min = min(TDY)
x_max = max(TDY)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="black")
Fn = ecdf(EHCF)
x_min = min(EHCF)
x_max = max(EHCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l')
Fn = ecdf(ELCF)
x_min = min(ELCF)
x_max = max(ELCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l')
dev.off()

pdf("~/Desktop/sol.pdf")
plot(G_sol[1,],xlab='',ylab="G_sol_capacity_factor",col='grey',xaxt="n")
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
axis(1, at = seq(720,(12*720),by=720), labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
for(i in 2:71){
    points(G_sol[i,],col='grey',xlab='',ylab='')
}
points(TDY,col='black')
points(EHCF,col='red')
points(ELCF,col="blue")
dev.off()
#####################################
## Synthetize TDY, EHCF and ELCF for won
pdf("~/Desktop/FS_won.pdf")
par(mfrow=c(1,2))
plot(G_abs_won[1,], ylim = c(ylim1_won,ylim2_won), ylab = "G_abs_FS_won",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(5, 0.2, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_abs_won[i,], ylab = "",xlab="",xaxt="n")
}

plot(G_real_won[1,], ylim = c(ylim12_won,ylim22_won), ylab = "G_real_FS_won",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(5, 0.2, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_real_won[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_won = vector("numeric",12)
min_real_won = vector("numeric",12)
max_real_won = vector("numeric",12)
for(i in 1:12){
    min_abs_won[i] = which.min(G_abs_won[,i])
    min_real_won[i] = which.min(G_real_won[,i])
    max_real_won[i] = which.max(G_real_won[,i])
}

TDY = vector("numeric",(12*720))
EHCF = vector("numeric",(12*720))
ELCF = vector("numeric",(12*720))
for(i in 1:12){
    TDY[((i-1)*720+1):(i*720)] = G_won[min_abs_won[i], ((i-1)*720+1):(i*720)]
    EHCF[((i-1)*720+1):(i*720)] = G_won[min_real_won[i], ((i-1)*720+1):(i*720)]
    ELCF[((i-1)*720+1):(i*720)] = G_won[max_real_won[i], ((i-1)*720+1):(i*720)]
}
pdf("~/Desktop/CDF_won.pdf")
Fn = ecdf(G_won[1,])
x_min = min(G_won)
x_max = max(G_won)
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="G_won_capacity_factor",ylab="CDF",col='grey')
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(G_won[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY)
x_min = min(TDY)
x_max = max(TDY)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="black")
Fn = ecdf(EHCF)
x_min = min(EHCF)
x_max = max(EHCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l')
Fn = ecdf(ELCF)
x_min = min(ELCF)
x_max = max(ELCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l')
dev.off()

pdf("~/Desktop/won.pdf")
plot(G_won[1,],xlab='',ylab="G_won_capacity_factor",col='grey',xaxt="n")
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
axis(1, at = seq(720,(12*720),by=720), labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
for(i in 2:71){
    points(G_won[i,],col='grey',xlab='',ylab='')
}
points(TDY,col='black')
points(EHCF,col='red')
points(ELCF,col="blue")
dev.off()
#########################
## Synthetize TDY, EHCF and ELCF for wof
pdf("~/Desktop/FS_wof.pdf")
par(mfrow=c(1,2))
plot(G_abs_wof[1,], ylim = c(ylim1_wof,ylim2_wof), ylab = "G_abs_FS_wof",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(5, 0.3, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_abs_wof[i,], ylab = "",xlab="",xaxt="n")
}

plot(G_real_wof[1,], ylim = c(ylim12_wof,ylim22_wof), ylab = "G_real_FS_wof",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(5, -0.2, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(G_real_wof[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_wof = vector("numeric",12)
min_real_wof = vector("numeric",12)
max_real_wof = vector("numeric",12)
for(i in 1:12){
    min_abs_wof[i] = which.min(G_abs_wof[,i])
    min_real_wof[i] = which.min(G_real_wof[,i])
    max_real_wof[i] = which.max(G_real_wof[,i])
}

TDY = vector("numeric",(12*720))
EHCF = vector("numeric",(12*720))
ELCF = vector("numeric",(12*720))
for(i in 1:12){
    TDY[((i-1)*720+1):(i*720)] = G_wof[min_abs_wof[i], ((i-1)*720+1):(i*720)]
    EHCF[((i-1)*720+1):(i*720)] = G_wof[min_real_wof[i], ((i-1)*720+1):(i*720)]
    ELCF[((i-1)*720+1):(i*720)] = G_wof[max_real_wof[i], ((i-1)*720+1):(i*720)]
}
pdf("~/Desktop/CDF_wof.pdf")
Fn = ecdf(G_wof[1,])
x_min = min(G_wof)
x_max = max(G_wof)
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="G_wof_capacity_factor",ylab="CDF",col='grey')
legend(0., 0.8, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(G_wof[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY)
x_min = min(TDY)
x_max = max(TDY)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="black")
Fn = ecdf(EHCF)
x_min = min(EHCF)
x_max = max(EHCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l')
Fn = ecdf(ELCF)
x_min = min(ELCF)
x_max = max(ELCF)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l')
dev.off()

pdf("~/Desktop/wof.pdf")
plot(G_wof[1,],xlab='',ylab="G_wof_capacity_factor",col='grey',xaxt="n")
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
axis(1, at = seq(720,(12*720),by=720), labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
for(i in 2:71){
    points(G_wof[i,],col='grey',xlab='',ylab='')
}
points(TDY,col='black')
points(EHCF,col='red')
points(ELCF,col="blue")
dev.off()
###########################################################

## Make synthetized years including TDY, EHCF and ELCF for wind & solar CF in EU
## Call dataset in xlsx format
library("readxl")
EU_sol_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_EU.xlsx",sheet = "sol")
# rows include years from 1950 to 2020 and columns include hourly data in each year
#EU_sol = matrix(NA,nrow=11*71,ncol=8760) 
#EU_won = matrix(NA,nrow=11*71,ncol=8760)
#EU_wof = matrix(NA,nrow=11*71,ncol=8760)
sol_at = matrix(NA, nrow=71, ncol=8760)
sol_balt = matrix(NA, nrow=71, ncol=8760)
sol_be = matrix(NA, nrow=71, ncol=8760)
sol_de = matrix(NA, nrow=71, ncol=8760)
sol_dk = matrix(NA, nrow=71, ncol=8760)
sol_es = matrix(NA, nrow=71, ncol=8760)
sol_fr = matrix(NA, nrow=71, ncol=8760)
sol_nl = matrix(NA, nrow=71, ncol=8760)
sol_no = matrix(NA, nrow=71, ncol=8760)
sol_se = matrix(NA, nrow=71, ncol=8760)
sol_uk = matrix(NA, nrow=71, ncol=8760)

for(i in 1:71){
    sol_at[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+2)]))
    sol_balt[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+3)]))
    sol_be[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+4)]))
    sol_de[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+5)]))
    sol_dk[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+6)]))
    sol_es[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+7)]))
    sol_fr[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+8)]))
    sol_nl[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+9)]))
    sol_no[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+10)]))
    sol_se[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+11)]))
    sol_uk[i,1:8760] = as.numeric(unlist(EU_sol_data[2:8761,((i-1)*11+12)]))
    }
## To show monthly capacity factor of solar
sol_de_month = matrix(NA, nrow = 71, ncol = 12)
for(i in 1:71){
    for(j in 1:12){
        sol_de_month[i,j] = mean(sol_de[i,((j-1)*730+1):(j*730)])
    }
}
max_value = max(sol_de_month)
png('~/Desktop/mean_CF_sol_de.png')
plot(sol_de_month[1,],type='l',col='gray', ylab='CF(solar)',ylim=c(0,0.25), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2)
title("Solar Capacity Factor (Germany)")
axis(1, at = c(1:12), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
for(i in 2:70){
    points(sol_de_month[i,],type='l',col='gray', lwd=2)
}
points(sol_de_month[21,],type='l',col='red',lwd=2)
points(sol_de_month[51,],type='l',col='green',lwd=2)
points(sol_de_month[70,],type='l',col='blue',lwd=2)
legend(x = 8, y = 0.25, legend = c("year 1950-2020", "year 1970","year 2000", "year 2020"), lty = c(1,1,1,1), col = c('gray','red','green','blue'), lwd = 2)
dev.off()
## Monthly and annualy CDF from January to December for EU-sol (Assumption: equal days in each month) --> FS statistics
M_CDF_sol_at = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_balt = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_be = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_de = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_dk = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_es = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_fr = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_nl = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_no = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_se = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_sol_uk = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_sol_at = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_balt = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_be = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_de = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_dk = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_es = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_fr = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_nl = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_no = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_se = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_sol_uk = matrix(NA, nrow = 1, ncol = (100*12))
x_sol_at = matrix(NA, nrow = 12, ncol = 2) # To fix range of data for CDF calculations
x_sol_balt = matrix(NA, nrow = 12, ncol = 2)
x_sol_be = matrix(NA, nrow = 12, ncol = 2)
x_sol_de = matrix(NA, nrow = 12, ncol = 2)
x_sol_dk = matrix(NA, nrow = 12, ncol = 2)
x_sol_es = matrix(NA, nrow = 12, ncol = 2)
x_sol_fr = matrix(NA, nrow = 12, ncol = 2)
x_sol_nl = matrix(NA, nrow = 12, ncol = 2)
x_sol_no = matrix(NA, nrow = 12, ncol = 2)
x_sol_se = matrix(NA, nrow = 12, ncol = 2)
x_sol_uk = matrix(NA, nrow = 12, ncol = 2)

for(i in 1:12){
    x_sol_at[i,1] = min(sol_at[,((i-1)*720+1):(i*720)])
    x_sol_at[i,2] = max(sol_at[,((i-1)*720+1):(i*720)])
    x_sol_balt[i,1] = min(sol_balt[,((i-1)*720+1):(i*720)])
    x_sol_balt[i,2] = max(sol_balt[,((i-1)*720+1):(i*720)])
    x_sol_be[i,1] = min(sol_be[,((i-1)*720+1):(i*720)])
    x_sol_be[i,2] = max(sol_be[,((i-1)*720+1):(i*720)])
    x_sol_de[i,1] = min(sol_de[,((i-1)*720+1):(i*720)])
    x_sol_de[i,2] = max(sol_de[,((i-1)*720+1):(i*720)])
    x_sol_dk[i,1] = min(sol_dk[,((i-1)*720+1):(i*720)])
    x_sol_dk[i,2] = max(sol_dk[,((i-1)*720+1):(i*720)])
    x_sol_es[i,1] = min(sol_es[,((i-1)*720+1):(i*720)])
    x_sol_es[i,2] = max(sol_es[,((i-1)*720+1):(i*720)])
    x_sol_fr[i,1] = min(sol_fr[,((i-1)*720+1):(i*720)])
    x_sol_fr[i,2] = max(sol_fr[,((i-1)*720+1):(i*720)])
    x_sol_nl[i,1] = min(sol_nl[,((i-1)*720+1):(i*720)])
    x_sol_nl[i,2] = max(sol_nl[,((i-1)*720+1):(i*720)])
    x_sol_no[i,1] = min(sol_no[,((i-1)*720+1):(i*720)])
    x_sol_no[i,2] = max(sol_no[,((i-1)*720+1):(i*720)])
    x_sol_se[i,1] = min(sol_se[,((i-1)*720+1):(i*720)])
    x_sol_se[i,2] = max(sol_se[,((i-1)*720+1):(i*720)])
    x_sol_uk[i,1] = min(sol_uk[,((i-1)*720+1):(i*720)])
    x_sol_uk[i,2] = max(sol_uk[,((i-1)*720+1):(i*720)])   

}
for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(sol_at[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_at[i,1],x_sol_at[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_at[j,((i-1)*100+1):(i*100)] = t_n 
        Fn = ecdf(sol_balt[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_balt[i,1],x_sol_balt[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_balt[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_be[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_be[i,1],x_sol_be[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_be[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_de[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_de[i,1],x_sol_de[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_de[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_dk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_dk[i,1],x_sol_dk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_dk[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_es[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_es[i,1],x_sol_es[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_es[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_fr[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_fr[i,1],x_sol_fr[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_fr[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_nl[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_nl[i,1],x_sol_nl[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_nl[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_no[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_no[i,1],x_sol_no[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_no[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_se[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_se[i,1],x_sol_se[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_se[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(sol_uk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_sol_uk[i,1],x_sol_uk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_sol_uk[j,((i-1)*100+1):(i*100)] = t_n
        }
}
for(i in 1:12){
    Fn = ecdf(sol_at[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_at[i,1],x_sol_at[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_at[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_balt[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_balt[i,1],x_sol_balt[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_balt[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_be[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_be[i,1],x_sol_be[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_be[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_de[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_de[i,1],x_sol_de[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_de[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_dk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_dk[i,1],x_sol_dk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_dk[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_es[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_es[i,1],x_sol_es[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_es[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_fr[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_fr[i,1],x_sol_fr[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_fr[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_nl[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_nl[i,1],x_sol_nl[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_nl[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_no[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_no[i,1],x_sol_no[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_no[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_se[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_se[i,1],x_sol_se[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_se[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(sol_uk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_sol_uk[i,1],x_sol_uk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_sol_uk[1,((i-1)*100+1):(i*100)] = t_n
}

plot(seq(x_sol_at[1,1],x_sol_at[1,2],length=100),A_CDF_sol_at[1,1:100])
points(seq(x_sol_at[1,1],x_sol_at[1,2],length=100),M_CDF_sol_at[2,1:100],col='red')
points(seq(x_sol_at[1,1],x_sol_at[1,2],length=100),M_CDF_sol_at[3,1:100],col='blue')
points(seq(x_sol_at[1,1],x_sol_at[1,2],length=100),M_CDF_sol_at[50,1:100],col='green')
points(seq(x_sol_at[1,1],x_sol_at[1,2],length=100),M_CDF_sol_at[70,1:100],col='yellow')
plot(seq(x_sol_uk[2,1],x_sol_uk[2,2],length=100),A_CDF_sol_uk[1,(1*100+1):(2*100)])
points(seq(x_sol_uk[2,1],x_sol_uk[2,2],length=100),M_CDF_sol_uk[2,(1*100+1):(2*100)],col='red')
points(seq(x_sol_uk[2,1],x_sol_uk[2,2],length=100),M_CDF_sol_uk[3,(1*100+1):(2*100)],col='blue')
points(seq(x_sol_uk[2,1],x_sol_uk[2,2],length=100),M_CDF_sol_uk[50,(1*100+1):(2*100)],col='green')
points(seq(x_sol_uk[2,1],x_sol_uk[2,2],length=100),M_CDF_sol_uk[70,(1*100+1):(2*100)],col='yellow')

## Synthetize years with typical & extreme solar power in EU
at_abs_sol = matrix(NA, nrow = 71, ncol = 12)
balt_abs_sol = matrix(NA, nrow = 71, ncol = 12)
be_abs_sol = matrix(NA, nrow = 71, ncol = 12)
de_abs_sol = matrix(NA, nrow = 71, ncol = 12)
dk_abs_sol = matrix(NA, nrow = 71, ncol = 12)
es_abs_sol = matrix(NA, nrow = 71, ncol = 12)
fr_abs_sol = matrix(NA, nrow = 71, ncol = 12)
nl_abs_sol = matrix(NA, nrow = 71, ncol = 12)
no_abs_sol = matrix(NA, nrow = 71, ncol = 12)
se_abs_sol = matrix(NA, nrow = 71, ncol = 12)
uk_abs_sol = matrix(NA, nrow = 71, ncol = 12)
at_real_sol = matrix(NA, nrow = 71, ncol = 12)
balt_real_sol = matrix(NA, nrow = 71, ncol = 12)
be_real_sol = matrix(NA, nrow = 71, ncol = 12)
de_real_sol = matrix(NA, nrow = 71, ncol = 12)
dk_real_sol = matrix(NA, nrow = 71, ncol = 12)
es_real_sol = matrix(NA, nrow = 71, ncol = 12)
fr_real_sol = matrix(NA, nrow = 71, ncol = 12)
nl_real_sol = matrix(NA, nrow = 71, ncol = 12)
no_real_sol = matrix(NA, nrow = 71, ncol = 12)
se_real_sol = matrix(NA, nrow = 71, ncol = 12)
uk_real_sol = matrix(NA, nrow = 71, ncol = 12)

for(i in 1:71){
    for(j in 1:12){
        at_abs_sol[i,j] = abs(mean(A_CDF_sol_at[1,((j-1)*100+1):(j*100)]-M_CDF_sol_at[i,((j-1)*100+1):(j*100)]))
        balt_abs_sol[i,j] = abs(mean(A_CDF_sol_balt[1,((j-1)*100+1):(j*100)]-M_CDF_sol_balt[i,((j-1)*100+1):(j*100)]))
        be_abs_sol[i,j] = abs(mean(A_CDF_sol_be[1,((j-1)*100+1):(j*100)]-M_CDF_sol_be[i,((j-1)*100+1):(j*100)]))
        de_abs_sol[i,j] = abs(mean(A_CDF_sol_de[1,((j-1)*100+1):(j*100)]-M_CDF_sol_de[i,((j-1)*100+1):(j*100)]))
        dk_abs_sol[i,j] = abs(mean(A_CDF_sol_dk[1,((j-1)*100+1):(j*100)]-M_CDF_sol_dk[i,((j-1)*100+1):(j*100)]))
        es_abs_sol[i,j] = abs(mean(A_CDF_sol_es[1,((j-1)*100+1):(j*100)]-M_CDF_sol_es[i,((j-1)*100+1):(j*100)]))
        fr_abs_sol[i,j] = abs(mean(A_CDF_sol_fr[1,((j-1)*100+1):(j*100)]-M_CDF_sol_fr[i,((j-1)*100+1):(j*100)]))
        nl_abs_sol[i,j] = abs(mean(A_CDF_sol_nl[1,((j-1)*100+1):(j*100)]-M_CDF_sol_nl[i,((j-1)*100+1):(j*100)]))
        no_abs_sol[i,j] = abs(mean(A_CDF_sol_no[1,((j-1)*100+1):(j*100)]-M_CDF_sol_no[i,((j-1)*100+1):(j*100)]))
        se_abs_sol[i,j] = abs(mean(A_CDF_sol_se[1,((j-1)*100+1):(j*100)]-M_CDF_sol_se[i,((j-1)*100+1):(j*100)]))
        uk_abs_sol[i,j] = abs(mean(A_CDF_sol_uk[1,((j-1)*100+1):(j*100)]-M_CDF_sol_uk[i,((j-1)*100+1):(j*100)]))       
    }
}

for(i in 1:71){
    for(j in 1:12){
        at_real_sol[i,j] = (mean(A_CDF_sol_at[1,((j-1)*100+1):(j*100)]-M_CDF_sol_at[i,((j-1)*100+1):(j*100)]))
        balt_real_sol[i,j] = (mean(A_CDF_sol_balt[1,((j-1)*100+1):(j*100)]-M_CDF_sol_balt[i,((j-1)*100+1):(j*100)]))
        be_real_sol[i,j] = (mean(A_CDF_sol_be[1,((j-1)*100+1):(j*100)]-M_CDF_sol_be[i,((j-1)*100+1):(j*100)]))
        de_real_sol[i,j] = (mean(A_CDF_sol_de[1,((j-1)*100+1):(j*100)]-M_CDF_sol_de[i,((j-1)*100+1):(j*100)]))
        dk_real_sol[i,j] = (mean(A_CDF_sol_dk[1,((j-1)*100+1):(j*100)]-M_CDF_sol_dk[i,((j-1)*100+1):(j*100)]))
        es_real_sol[i,j] = (mean(A_CDF_sol_es[1,((j-1)*100+1):(j*100)]-M_CDF_sol_es[i,((j-1)*100+1):(j*100)]))
        fr_real_sol[i,j] = (mean(A_CDF_sol_fr[1,((j-1)*100+1):(j*100)]-M_CDF_sol_fr[i,((j-1)*100+1):(j*100)]))
        nl_real_sol[i,j] = (mean(A_CDF_sol_nl[1,((j-1)*100+1):(j*100)]-M_CDF_sol_nl[i,((j-1)*100+1):(j*100)]))
        no_real_sol[i,j] = (mean(A_CDF_sol_no[1,((j-1)*100+1):(j*100)]-M_CDF_sol_no[i,((j-1)*100+1):(j*100)]))
        se_real_sol[i,j] = (mean(A_CDF_sol_se[1,((j-1)*100+1):(j*100)]-M_CDF_sol_se[i,((j-1)*100+1):(j*100)]))
        uk_real_sol[i,j] = (mean(A_CDF_sol_uk[1,((j-1)*100+1):(j*100)]-M_CDF_sol_uk[i,((j-1)*100+1):(j*100)]))
    }
}
ylim1_sol_at = min(at_abs_sol)
ylim2_sol_at = max(at_abs_sol)
ylim1_sol_balt = min(balt_abs_sol)
ylim2_sol_balt = max(balt_abs_sol)
ylim1_sol_be = min(be_abs_sol)
ylim2_sol_be = max(be_abs_sol)
ylim1_sol_de = min(de_abs_sol)
ylim2_sol_de = max(de_abs_sol)
ylim1_sol_dk = min(dk_abs_sol)
ylim2_sol_dk = max(dk_abs_sol)
ylim1_sol_es = min(es_abs_sol)
ylim2_sol_es = max(es_abs_sol)
ylim1_sol_fr = min(fr_abs_sol)
ylim2_sol_fr = max(fr_abs_sol)
ylim1_sol_nl = min(nl_abs_sol)
ylim2_sol_nl = max(nl_abs_sol)
ylim1_sol_no = min(no_abs_sol)
ylim2_sol_no = max(no_abs_sol)
ylim1_sol_se = min(se_abs_sol)
ylim2_sol_se = max(se_abs_sol)
ylim1_sol_uk = min(uk_abs_sol)
ylim2_sol_uk = max(uk_abs_sol)

ylim12_sol_at = min(at_real_sol)
ylim22_sol_at = max(at_real_sol)
ylim12_sol_balt = min(balt_real_sol)
ylim22_sol_balt = max(balt_real_sol)
ylim12_sol_be = min(be_real_sol)
ylim22_sol_be = max(be_real_sol)
ylim12_sol_de = min(de_real_sol)
ylim22_sol_de = max(de_real_sol)
ylim12_sol_dk = min(dk_real_sol)
ylim22_sol_dk = max(dk_real_sol)
ylim12_sol_es = min(es_real_sol)
ylim22_sol_es = max(es_real_sol)
ylim12_sol_fr = min(fr_real_sol)
ylim22_sol_fr = max(fr_real_sol)
ylim12_sol_nl = min(nl_real_sol)
ylim22_sol_nl = max(nl_real_sol)
ylim12_sol_no = min(no_real_sol)
ylim22_sol_no = max(no_real_sol)
ylim12_sol_se = min(se_real_sol)
ylim22_sol_se = max(se_real_sol)
ylim12_sol_uk = min(uk_real_sol)
ylim22_sol_uk = max(uk_real_sol)


## Synthetize TDY, EHCF and ELCF for EU-sol
pdf("~/Desktop/FS_sol.pdf")
par(mfrow=c(1,2))
plot(at_abs_sol[1,], ylim = c(ylim1_sol_at,ylim2_sol_at), ylab = "at_abs_FS_sol",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(at_abs_sol[i,], ylab = "",xlab="",xaxt="n")
}

plot(at_real_sol[1,], ylim = c(ylim12_sol_at,ylim22_sol_at), ylab = "at_real_FS_sol",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(at_real_sol[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_sol_at = vector("numeric",12)
min_real_sol_at = vector("numeric",12)
max_real_sol_at = vector("numeric",12)
min_abs_sol_balt = vector("numeric",12)
min_real_sol_balt = vector("numeric",12)
max_real_sol_balt = vector("numeric",12)
min_abs_sol_be = vector("numeric",12)
min_real_sol_be = vector("numeric",12)
max_real_sol_be = vector("numeric",12)
min_abs_sol_de = vector("numeric",12)
min_real_sol_de = vector("numeric",12)
max_real_sol_de = vector("numeric",12)
min_abs_sol_dk = vector("numeric",12)
min_real_sol_dk = vector("numeric",12)
max_real_sol_dk = vector("numeric",12)
min_abs_sol_es = vector("numeric",12)
min_real_sol_es = vector("numeric",12)
max_real_sol_es = vector("numeric",12)
min_abs_sol_fr = vector("numeric",12)
min_real_sol_fr = vector("numeric",12)
max_real_sol_fr = vector("numeric",12)
min_abs_sol_nl = vector("numeric",12)
min_real_sol_nl = vector("numeric",12)
max_real_sol_nl = vector("numeric",12)
min_abs_sol_no = vector("numeric",12)
min_real_sol_no = vector("numeric",12)
max_real_sol_no = vector("numeric",12)
min_abs_sol_se = vector("numeric",12)
min_real_sol_se = vector("numeric",12)
max_real_sol_se = vector("numeric",12)
min_abs_sol_uk = vector("numeric",12)
min_real_sol_uk = vector("numeric",12)
max_real_sol_uk = vector("numeric",12)
for(i in 1:12){
    min_abs_sol_at[i] = which.min(at_abs_sol[,i])
    min_real_sol_at[i] = which.min(at_real_sol[,i])
    max_real_sol_at[i] = which.max(at_real_sol[,i])
    min_abs_sol_balt[i] = which.min(balt_abs_sol[,i])
    min_real_sol_balt[i] = which.min(balt_real_sol[,i])
    max_real_sol_balt[i] = which.max(balt_real_sol[,i])
    min_abs_sol_be[i] = which.min(be_abs_sol[,i])
    min_real_sol_be[i] = which.min(be_real_sol[,i])
    max_real_sol_be[i] = which.max(be_real_sol[,i])
    min_abs_sol_de[i] = which.min(de_abs_sol[,i])
    min_real_sol_de[i] = which.min(de_real_sol[,i])
    max_real_sol_de[i] = which.max(de_real_sol[,i])
    min_abs_sol_dk[i] = which.min(dk_abs_sol[,i])
    min_real_sol_dk[i] = which.min(dk_real_sol[,i])
    max_real_sol_dk[i] = which.max(dk_real_sol[,i])
    min_abs_sol_es[i] = which.min(es_abs_sol[,i])
    min_real_sol_es[i] = which.min(es_real_sol[,i])
    max_real_sol_es[i] = which.max(es_real_sol[,i])
    min_abs_sol_fr[i] = which.min(fr_abs_sol[,i])
    min_real_sol_fr[i] = which.min(fr_real_sol[,i])
    max_real_sol_fr[i] = which.max(fr_real_sol[,i])
    min_abs_sol_nl[i] = which.min(nl_abs_sol[,i])
    min_real_sol_nl[i] = which.min(nl_real_sol[,i])
    max_real_sol_nl[i] = which.max(nl_real_sol[,i])
    min_abs_sol_no[i] = which.min(no_abs_sol[,i])
    min_real_sol_no[i] = which.min(no_real_sol[,i])
    max_real_sol_no[i] = which.max(no_real_sol[,i])
    min_abs_sol_se[i] = which.min(se_abs_sol[,i])
    min_real_sol_se[i] = which.min(se_real_sol[,i])
    max_real_sol_se[i] = which.max(se_real_sol[,i])
    min_abs_sol_uk[i] = which.min(uk_abs_sol[,i])
    min_real_sol_uk[i] = which.min(uk_real_sol[,i])
    max_real_sol_uk[i] = which.max(uk_real_sol[,i])
}

TDY_at = vector("numeric",(12*720))
EHCF_at = vector("numeric",(12*720))
ELCF_at = vector("numeric",(12*720))
TDY_balt = vector("numeric",(12*720))
EHCF_balt = vector("numeric",(12*720))
ELCF_balt = vector("numeric",(12*720))
TDY_be = vector("numeric",(12*720))
EHCF_be = vector("numeric",(12*720))
ELCF_be = vector("numeric",(12*720))
TDY_de = vector("numeric",(12*720))
EHCF_de = vector("numeric",(12*720))
ELCF_de = vector("numeric",(12*720))
TDY_dk = vector("numeric",(12*720))
EHCF_dk = vector("numeric",(12*720))
ELCF_dk = vector("numeric",(12*720))
TDY_es = vector("numeric",(12*720))
EHCF_es = vector("numeric",(12*720))
ELCF_es = vector("numeric",(12*720))
TDY_fr = vector("numeric",(12*720))
EHCF_fr = vector("numeric",(12*720))
ELCF_fr = vector("numeric",(12*720))
TDY_nl = vector("numeric",(12*720))
EHCF_nl = vector("numeric",(12*720))
ELCF_nl = vector("numeric",(12*720))
TDY_no = vector("numeric",(12*720))
EHCF_no = vector("numeric",(12*720))
ELCF_no = vector("numeric",(12*720))
TDY_se = vector("numeric",(12*720))
EHCF_se = vector("numeric",(12*720))
ELCF_se = vector("numeric",(12*720))
TDY_uk = vector("numeric",(12*720))
EHCF_uk = vector("numeric",(12*720))
ELCF_uk = vector("numeric",(12*720))
for(i in 1:12){
    TDY_at[((i-1)*720+1):(i*720)] = sol_at[min_abs_sol_at[i], ((i-1)*720+1):(i*720)]
    EHCF_at[((i-1)*720+1):(i*720)] = sol_at[min_real_sol_at[i], ((i-1)*720+1):(i*720)]
    ELCF_at[((i-1)*720+1):(i*720)] = sol_at[max_real_sol_at[i], ((i-1)*720+1):(i*720)]
    TDY_balt[((i-1)*720+1):(i*720)] = sol_balt[min_abs_sol_balt[i], ((i-1)*720+1):(i*720)]
    EHCF_balt[((i-1)*720+1):(i*720)] = sol_balt[min_real_sol_balt[i], ((i-1)*720+1):(i*720)]
    ELCF_balt[((i-1)*720+1):(i*720)] = sol_balt[max_real_sol_balt[i], ((i-1)*720+1):(i*720)]
    TDY_be[((i-1)*720+1):(i*720)] = sol_be[min_abs_sol_be[i], ((i-1)*720+1):(i*720)]
    EHCF_be[((i-1)*720+1):(i*720)] = sol_be[min_real_sol_be[i], ((i-1)*720+1):(i*720)]
    ELCF_be[((i-1)*720+1):(i*720)] = sol_be[max_real_sol_be[i], ((i-1)*720+1):(i*720)]
    TDY_de[((i-1)*720+1):(i*720)] = sol_de[min_abs_sol_de[i], ((i-1)*720+1):(i*720)]
    EHCF_de[((i-1)*720+1):(i*720)] = sol_de[min_real_sol_de[i], ((i-1)*720+1):(i*720)]
    ELCF_de[((i-1)*720+1):(i*720)] = sol_de[max_real_sol_de[i], ((i-1)*720+1):(i*720)]
    TDY_dk[((i-1)*720+1):(i*720)] = sol_dk[min_abs_sol_dk[i], ((i-1)*720+1):(i*720)]
    EHCF_dk[((i-1)*720+1):(i*720)] = sol_dk[min_real_sol_dk[i], ((i-1)*720+1):(i*720)]
    ELCF_dk[((i-1)*720+1):(i*720)] = sol_dk[max_real_sol_dk[i], ((i-1)*720+1):(i*720)]
    TDY_es[((i-1)*720+1):(i*720)] = sol_es[min_abs_sol_es[i], ((i-1)*720+1):(i*720)]
    EHCF_es[((i-1)*720+1):(i*720)] = sol_es[min_real_sol_es[i], ((i-1)*720+1):(i*720)]
    ELCF_es[((i-1)*720+1):(i*720)] = sol_es[max_real_sol_es[i], ((i-1)*720+1):(i*720)]
    TDY_fr[((i-1)*720+1):(i*720)] = sol_fr[min_abs_sol_fr[i], ((i-1)*720+1):(i*720)]
    EHCF_fr[((i-1)*720+1):(i*720)] = sol_fr[min_real_sol_fr[i], ((i-1)*720+1):(i*720)]
    ELCF_fr[((i-1)*720+1):(i*720)] = sol_fr[max_real_sol_fr[i], ((i-1)*720+1):(i*720)]
    TDY_nl[((i-1)*720+1):(i*720)] = sol_nl[min_abs_sol_nl[i], ((i-1)*720+1):(i*720)]
    EHCF_nl[((i-1)*720+1):(i*720)] = sol_nl[min_real_sol_nl[i], ((i-1)*720+1):(i*720)]
    ELCF_nl[((i-1)*720+1):(i*720)] = sol_nl[max_real_sol_nl[i], ((i-1)*720+1):(i*720)]
    TDY_no[((i-1)*720+1):(i*720)] = sol_no[min_abs_sol_no[i], ((i-1)*720+1):(i*720)]
    EHCF_no[((i-1)*720+1):(i*720)] = sol_no[min_real_sol_no[i], ((i-1)*720+1):(i*720)]
    ELCF_no[((i-1)*720+1):(i*720)] = sol_no[max_real_sol_no[i], ((i-1)*720+1):(i*720)]
    TDY_se[((i-1)*720+1):(i*720)] = sol_se[min_abs_sol_se[i], ((i-1)*720+1):(i*720)]
    EHCF_se[((i-1)*720+1):(i*720)] = sol_se[min_real_sol_se[i], ((i-1)*720+1):(i*720)]
    ELCF_se[((i-1)*720+1):(i*720)] = sol_se[max_real_sol_se[i], ((i-1)*720+1):(i*720)]
    TDY_uk[((i-1)*720+1):(i*720)] = sol_uk[min_abs_sol_uk[i], ((i-1)*720+1):(i*720)]
    EHCF_uk[((i-1)*720+1):(i*720)] = sol_uk[min_real_sol_uk[i], ((i-1)*720+1):(i*720)]
    ELCF_uk[((i-1)*720+1):(i*720)] = sol_uk[max_real_sol_uk[i], ((i-1)*720+1):(i*720)]
}

png("~/Desktop/cdf_sol_de.png")
Fn = ecdf(sol_de[1,])
x_min = min(sol_de)
x_max = max(sol_de)
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="CF",ylab="CDF",col='grey')
title('Solar Germany')
legend(0.6, 0.9, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "yellow4","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(sol_de[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY_de)
x_min = min(TDY_de)
x_max = max(TDY_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="yellow4",lwd=2)
Fn = ecdf(EHCF_de)
x_min = min(EHCF_de)
x_max = max(EHCF_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l',lwd=2)
Fn = ecdf(ELCF_de)
x_min = min(ELCF_de)
x_max = max(ELCF_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l',lwd=2)
dev.off()

png("~/Desktop/syn_sol_de")
max_value = max(sol_de)
plot(sol_de[1,],type='l',col='gray', ylab='CF',ylim=c(0,max_value), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2) # nolint
axis(1, at = seq(1,12*730,by=730), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
title("Solar Capacity Factor (Germany)")
#library(RColorBrewer)
for(i in 2:70){
    points(sol_de[i,],type='l',col='gray', lwd=2)
}
points(TDY_de,type='l',col='yellow4',lwd=2)
points(EHCF_de,type='l',col='blue',lwd=2)
points(ELCF_de,type='l',col='red',lwd=2)
legend(x = 8*730, y = 0.8, legend = c("year 1950-2020", "TDY","EHCF","ELCF"), lty = c(1,1,1,1), col = c('gray','yellow4','red','blue'), lwd = 2)
dev.off()


syn_at = matrix(NA, ncol=3, nrow=12*30*24)
syn_balt = matrix(NA, ncol=3, nrow=12*30*24)
syn_be = matrix(NA, ncol=3, nrow=12*30*24)
syn_de = matrix(NA, ncol=3, nrow=12*30*24)
syn_dk = matrix(NA, ncol=3, nrow=12*30*24)
syn_es = matrix(NA, ncol=3, nrow=12*30*24)
syn_fr = matrix(NA, ncol=3, nrow=12*30*24)
syn_nl = matrix(NA, ncol=3, nrow=12*30*24)
syn_no = matrix(NA, ncol=3, nrow=12*30*24)
syn_se = matrix(NA, ncol=3, nrow=12*30*24)
syn_uk = matrix(NA, ncol=3, nrow=12*30*24)

# To save data as table
tab_sol_TDY <- matrix(c(TDY_at,TDY_balt,TDY_be,TDY_de,TDY_dk,TDY_es,TDY_fr,TDY_nl,TDY_no,TDY_se,TDY_uk), ncol=11, byrow=FALSE)
colnames(tab_sol_TDY) <- c('sol_TDY_at','sol_TDY_balt','sol_TDY_be','sol_TDY_de','sol_TDY_dk','sol_TDY_es','sol_TDY_fr','sol_TDY_nl','sol_TDY_no','sol_TDY_se','sol_TDY_uk')
tab_sol_TDY <- as.table(tab_sol_TDY)

tab_sol_EHCF<- matrix(c(EHCF_at,EHCF_balt,EHCF_be,EHCF_de,EHCF_dk,EHCF_es,EHCF_fr,EHCF_nl,EHCF_no,EHCF_se,EHCF_uk), ncol=11, byrow=FALSE)
colnames(tab_sol_EHCF) <- c('sol_EHCF_at','sol_EHCF_balt','sol_EHCF_be','sol_EHCF_de','sol_EHCF_dk','sol_EHCF_es','sol_EHCF_fr','sol_EHCF_nl','sol_EHCF_no','sol_EHCF_se','sol_EHCF_uk')
tab_sol_EHCF <- as.table(tab_sol_EHCF)

tab_sol_ELCF<- matrix(c(ELCF_at,ELCF_balt,ELCF_be,ELCF_de,ELCF_dk,ELCF_es,ELCF_fr,ELCF_nl,ELCF_no,ELCF_se,ELCF_uk), ncol=11, byrow=FALSE)
colnames(tab_sol_ELCF) <- c('sol_ELCF_at','sol_ELCF_balt','sol_ELCF_be','sol_ELCF_de','sol_ELCF_dk','sol_ELCF_es','sol_ELCF_fr','sol_ELCF_nl','sol_ELCF_no','sol_ELCF_se','sol_ELCF_uk')
tab_sol_ELCF <- as.table(tab_sol_ELCF)

write.table(tab_sol_TDY,"~/Documents/InfraTrain_School/Project/syn_sol_TDY.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_sol_EHCF,"~/Documents/InfraTrain_School/Project/syn_sol_EHCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_sol_ELCF,"~/Documents/InfraTrain_School/Project/syn_sol_ELCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
###################################################################

## Make synthetized years including TDY, EHCF and ELCF for wind & solar CF in EU
## Call dataset in xlsx format
library("readxl")
EU_won_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_EU.xlsx",sheet = "windon")
# rows include years from 1950 to 2020 and columns include hourly data in each year
won_at = matrix(NA, nrow=71, ncol=8760)
won_balt = matrix(NA, nrow=71, ncol=8760)
won_be = matrix(NA, nrow=71, ncol=8760)
won_de = matrix(NA, nrow=71, ncol=8760)
won_dk = matrix(NA, nrow=71, ncol=8760)
won_es = matrix(NA, nrow=71, ncol=8760)
won_fr = matrix(NA, nrow=71, ncol=8760)
won_nl = matrix(NA, nrow=71, ncol=8760)
won_no = matrix(NA, nrow=71, ncol=8760)
won_se = matrix(NA, nrow=71, ncol=8760)
won_uk = matrix(NA, nrow=71, ncol=8760)

for(i in 1:71){
    won_at[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+2)]))
    won_balt[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+3)]))
    won_be[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+4)]))
    won_de[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+5)]))
    won_dk[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+6)]))
    won_es[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+7)]))
    won_fr[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+8)]))
    won_nl[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+9)]))
    won_no[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+10)]))
    won_se[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+11)]))
    won_uk[i,1:8760] = as.numeric(unlist(EU_won_data[2:8761,((i-1)*11+12)]))
    }
## To show monthly capacity factor of onshore-wind
won_de_month = matrix(NA, nrow = 71, ncol = 12)
for(i in 1:71){
    for(j in 1:12){
        won_de_month[i,j] = mean(won_de[i,((j-1)*730+1):(j*730)])
    }
}
max_value = max(won_de_month)
png('~/Desktop/mean_CF_won_de.png')
plot(won_de_month[1,],type='l',col='gray', ylab='CF(won)',ylim=c(0,max_value), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2)
axis(1, at = c(1:12), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
title("Onshore Wind Capacity Factor (Germany)")
for(i in 2:70){
    points(won_de_month[i,],type='l',col='gray', lwd=2)
}
points(won_de_month[21,],type='l',col='red',lwd=2)
points(won_de_month[51,],type='l',col='green',lwd=2)
points(won_de_month[70,],type='l',col='blue',lwd=2)
legend(x = 5, y = 0.5, legend = c("year 1950-2020", "year 1970","year 2000", "year 2020"), lty = c(1,1,1,1), col = c('gray','red','green','blue'), lwd = 2)
dev.off()
## plot all hourly years
max_value = max(won_de)
png("~/Desktop/CF_won_de.png")
plot(won_de[1,],type='l',col='gray', ylab='CF',ylim=c(0,max_value), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2)
axis(1, at = seq(1,12*730,by=730), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
title("Onshore Wind Capacity Factor (Germany)")
#library(RColorBrewer)
for(i in 2:70){
    points(won_de[i,],type='l',col='gray', lwd=2)
}
points(won_de[21,],type='l',col='black',lwd=2)
points(won_de[51,],type='l',col='darkgreen',lwd=2)
abline(v = seq(1,13*730,by=730), col='red', lwd=2)
legend(x = 4*730, y = 0.9, legend = c("year 1950-2020", "year 1970","year 2000"), lty = c(1,1,1), col = c('gray','black','darkgreen'), lwd = 2)
dev.off()
## Monthly and annualy CDF from January to December for EU-won (Assumption: equal days in each month) --> FS statistics
M_CDF_won_at = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_balt = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_be = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_de = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_dk = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_es = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_fr = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_nl = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_no = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_se = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_won_uk = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_won_at = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_balt = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_be = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_de = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_dk = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_es = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_fr = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_nl = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_no = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_se = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_won_uk = matrix(NA, nrow = 1, ncol = (100*12))
x_won_at = matrix(NA, nrow = 12, ncol = 2) # To fix range of data for CDF calculations
x_won_balt = matrix(NA, nrow = 12, ncol = 2)
x_won_be = matrix(NA, nrow = 12, ncol = 2)
x_won_de = matrix(NA, nrow = 12, ncol = 2)
x_won_dk = matrix(NA, nrow = 12, ncol = 2)
x_won_es = matrix(NA, nrow = 12, ncol = 2)
x_won_fr = matrix(NA, nrow = 12, ncol = 2)
x_won_nl = matrix(NA, nrow = 12, ncol = 2)
x_won_no = matrix(NA, nrow = 12, ncol = 2)
x_won_se = matrix(NA, nrow = 12, ncol = 2)
x_won_uk = matrix(NA, nrow = 12, ncol = 2)

for(i in 1:12){
    x_won_at[i,1] = min(won_at[,((i-1)*720+1):(i*720)])
    x_won_at[i,2] = max(won_at[,((i-1)*720+1):(i*720)])
    x_won_balt[i,1] = min(won_balt[,((i-1)*720+1):(i*720)])
    x_won_balt[i,2] = max(won_balt[,((i-1)*720+1):(i*720)])
    x_won_be[i,1] = min(won_be[,((i-1)*720+1):(i*720)])
    x_won_be[i,2] = max(won_be[,((i-1)*720+1):(i*720)])
    x_won_de[i,1] = min(won_de[,((i-1)*720+1):(i*720)])
    x_won_de[i,2] = max(won_de[,((i-1)*720+1):(i*720)])
    x_won_dk[i,1] = min(won_dk[,((i-1)*720+1):(i*720)])
    x_won_dk[i,2] = max(won_dk[,((i-1)*720+1):(i*720)])
    x_won_es[i,1] = min(won_es[,((i-1)*720+1):(i*720)])
    x_won_es[i,2] = max(won_es[,((i-1)*720+1):(i*720)])
    x_won_fr[i,1] = min(won_fr[,((i-1)*720+1):(i*720)])
    x_won_fr[i,2] = max(won_fr[,((i-1)*720+1):(i*720)])
    x_won_nl[i,1] = min(won_nl[,((i-1)*720+1):(i*720)])
    x_won_nl[i,2] = max(won_nl[,((i-1)*720+1):(i*720)])
    x_won_no[i,1] = min(won_no[,((i-1)*720+1):(i*720)])
    x_won_no[i,2] = max(won_no[,((i-1)*720+1):(i*720)])
    x_won_se[i,1] = min(won_se[,((i-1)*720+1):(i*720)])
    x_won_se[i,2] = max(won_se[,((i-1)*720+1):(i*720)])
    x_won_uk[i,1] = min(won_uk[,((i-1)*720+1):(i*720)])
    x_won_uk[i,2] = max(won_uk[,((i-1)*720+1):(i*720)])   

}

for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(won_at[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_at[i,1],x_won_at[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_at[j,((i-1)*100+1):(i*100)] = t_n 
        Fn = ecdf(won_balt[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_balt[i,1],x_won_balt[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_balt[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_be[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_be[i,1],x_won_be[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_be[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_de[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_de[i,1],x_won_de[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_de[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_dk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_dk[i,1],x_won_dk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_dk[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_es[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_es[i,1],x_won_es[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_es[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_fr[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_fr[i,1],x_won_fr[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_fr[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_nl[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_nl[i,1],x_won_nl[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_nl[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_no[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_no[i,1],x_won_no[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_no[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_se[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_se[i,1],x_won_se[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_se[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(won_uk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_won_uk[i,1],x_won_uk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_won_uk[j,((i-1)*100+1):(i*100)] = t_n
        }
}
for(i in 1:12){
    Fn = ecdf(won_at[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_at[i,1],x_won_at[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_at[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_balt[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_balt[i,1],x_won_balt[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_balt[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_be[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_be[i,1],x_won_be[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_be[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_de[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_de[i,1],x_won_de[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_de[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_dk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_dk[i,1],x_won_dk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_dk[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_es[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_es[i,1],x_won_es[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_es[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_fr[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_fr[i,1],x_won_fr[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_fr[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_nl[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_nl[i,1],x_won_nl[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_nl[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_no[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_no[i,1],x_won_no[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_no[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_se[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_se[i,1],x_won_se[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_se[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(won_uk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_won_uk[i,1],x_won_uk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_won_uk[1,((i-1)*100+1):(i*100)] = t_n
}
plot(seq(x_won_at[1,1],x_won_at[1,2],length=100),A_CDF_won_at[1,1:100])
points(seq(x_won_at[1,1],x_won_at[1,2],length=100),M_CDF_won_at[2,1:100],col='red')
points(seq(x_won_at[1,1],x_won_at[1,2],length=100),M_CDF_won_at[3,1:100],col='blue')
points(seq(x_won_at[1,1],x_won_at[1,2],length=100),M_CDF_won_at[50,1:100],col='green')
points(seq(x_won_at[1,1],x_won_at[1,2],length=100),M_CDF_won_at[70,1:100],col='yellow')
plot(seq(x_won_uk[2,1],x_won_uk[2,2],length=100),A_CDF_won_uk[1,(1*100+1):(2*100)])
points(seq(x_won_uk[2,1],x_won_uk[2,2],length=100),M_CDF_won_uk[2,(1*100+1):(2*100)],col='red')
points(seq(x_won_uk[2,1],x_won_uk[2,2],length=100),M_CDF_won_uk[3,(1*100+1):(2*100)],col='blue')
points(seq(x_won_uk[2,1],x_won_uk[2,2],length=100),M_CDF_won_uk[50,(1*100+1):(2*100)],col='green')
points(seq(x_won_uk[2,1],x_won_uk[2,2],length=100),M_CDF_won_uk[70,(1*100+1):(2*100)],col='yellow')

## Synthetize years with typical & extreme won power in EU
at_abs_won = matrix(NA, nrow = 71, ncol = 12)
balt_abs_won = matrix(NA, nrow = 71, ncol = 12)
be_abs_won = matrix(NA, nrow = 71, ncol = 12)
de_abs_won = matrix(NA, nrow = 71, ncol = 12)
dk_abs_won = matrix(NA, nrow = 71, ncol = 12)
es_abs_won = matrix(NA, nrow = 71, ncol = 12)
fr_abs_won = matrix(NA, nrow = 71, ncol = 12)
nl_abs_won = matrix(NA, nrow = 71, ncol = 12)
no_abs_won = matrix(NA, nrow = 71, ncol = 12)
se_abs_won = matrix(NA, nrow = 71, ncol = 12)
uk_abs_won = matrix(NA, nrow = 71, ncol = 12)
at_real_won = matrix(NA, nrow = 71, ncol = 12)
balt_real_won = matrix(NA, nrow = 71, ncol = 12)
be_real_won = matrix(NA, nrow = 71, ncol = 12)
de_real_won = matrix(NA, nrow = 71, ncol = 12)
dk_real_won = matrix(NA, nrow = 71, ncol = 12)
es_real_won = matrix(NA, nrow = 71, ncol = 12)
fr_real_won = matrix(NA, nrow = 71, ncol = 12)
nl_real_won = matrix(NA, nrow = 71, ncol = 12)
no_real_won = matrix(NA, nrow = 71, ncol = 12)
se_real_won = matrix(NA, nrow = 71, ncol = 12)
uk_real_won = matrix(NA, nrow = 71, ncol = 12)

for(i in 1:71){
    for(j in 1:12){
        at_abs_won[i,j] = abs(mean(A_CDF_won_at[1,((j-1)*100+1):(j*100)]-M_CDF_won_at[i,((j-1)*100+1):(j*100)]))
        balt_abs_won[i,j] = abs(mean(A_CDF_won_balt[1,((j-1)*100+1):(j*100)]-M_CDF_won_balt[i,((j-1)*100+1):(j*100)]))
        be_abs_won[i,j] = abs(mean(A_CDF_won_be[1,((j-1)*100+1):(j*100)]-M_CDF_won_be[i,((j-1)*100+1):(j*100)]))
        de_abs_won[i,j] = abs(mean(A_CDF_won_de[1,((j-1)*100+1):(j*100)]-M_CDF_won_de[i,((j-1)*100+1):(j*100)]))
        dk_abs_won[i,j] = abs(mean(A_CDF_won_dk[1,((j-1)*100+1):(j*100)]-M_CDF_won_dk[i,((j-1)*100+1):(j*100)]))
        es_abs_won[i,j] = abs(mean(A_CDF_won_es[1,((j-1)*100+1):(j*100)]-M_CDF_won_es[i,((j-1)*100+1):(j*100)]))
        fr_abs_won[i,j] = abs(mean(A_CDF_won_fr[1,((j-1)*100+1):(j*100)]-M_CDF_won_fr[i,((j-1)*100+1):(j*100)]))
        nl_abs_won[i,j] = abs(mean(A_CDF_won_nl[1,((j-1)*100+1):(j*100)]-M_CDF_won_nl[i,((j-1)*100+1):(j*100)]))
        no_abs_won[i,j] = abs(mean(A_CDF_won_no[1,((j-1)*100+1):(j*100)]-M_CDF_won_no[i,((j-1)*100+1):(j*100)]))
        se_abs_won[i,j] = abs(mean(A_CDF_won_se[1,((j-1)*100+1):(j*100)]-M_CDF_won_se[i,((j-1)*100+1):(j*100)]))
        uk_abs_won[i,j] = abs(mean(A_CDF_won_uk[1,((j-1)*100+1):(j*100)]-M_CDF_won_uk[i,((j-1)*100+1):(j*100)]))       
    }
}

for(i in 1:71){
    for(j in 1:12){
        at_real_won[i,j] = (mean(A_CDF_won_at[1,((j-1)*100+1):(j*100)]-M_CDF_won_at[i,((j-1)*100+1):(j*100)]))
        balt_real_won[i,j] = (mean(A_CDF_won_balt[1,((j-1)*100+1):(j*100)]-M_CDF_won_balt[i,((j-1)*100+1):(j*100)]))
        be_real_won[i,j] = (mean(A_CDF_won_be[1,((j-1)*100+1):(j*100)]-M_CDF_won_be[i,((j-1)*100+1):(j*100)]))
        de_real_won[i,j] = (mean(A_CDF_won_de[1,((j-1)*100+1):(j*100)]-M_CDF_won_de[i,((j-1)*100+1):(j*100)]))
        dk_real_won[i,j] = (mean(A_CDF_won_dk[1,((j-1)*100+1):(j*100)]-M_CDF_won_dk[i,((j-1)*100+1):(j*100)]))
        es_real_won[i,j] = (mean(A_CDF_won_es[1,((j-1)*100+1):(j*100)]-M_CDF_won_es[i,((j-1)*100+1):(j*100)]))
        fr_real_won[i,j] = (mean(A_CDF_won_fr[1,((j-1)*100+1):(j*100)]-M_CDF_won_fr[i,((j-1)*100+1):(j*100)]))
        nl_real_won[i,j] = (mean(A_CDF_won_nl[1,((j-1)*100+1):(j*100)]-M_CDF_won_nl[i,((j-1)*100+1):(j*100)]))
        no_real_won[i,j] = (mean(A_CDF_won_no[1,((j-1)*100+1):(j*100)]-M_CDF_won_no[i,((j-1)*100+1):(j*100)]))
        se_real_won[i,j] = (mean(A_CDF_won_se[1,((j-1)*100+1):(j*100)]-M_CDF_won_se[i,((j-1)*100+1):(j*100)]))
        uk_real_won[i,j] = (mean(A_CDF_won_uk[1,((j-1)*100+1):(j*100)]-M_CDF_won_uk[i,((j-1)*100+1):(j*100)]))
    }
}
ylim1_won_at = min(at_abs_won)
ylim2_won_at = max(at_abs_won)
ylim1_won_balt = min(balt_abs_won)
ylim2_won_balt = max(balt_abs_won)
ylim1_won_be = min(be_abs_won)
ylim2_won_be = max(be_abs_won)
ylim1_won_de = min(de_abs_won)
ylim2_won_de = max(de_abs_won)
ylim1_won_dk = min(dk_abs_won)
ylim2_won_dk = max(dk_abs_won)
ylim1_won_es = min(es_abs_won)
ylim2_won_es = max(es_abs_won)
ylim1_won_fr = min(fr_abs_won)
ylim2_won_fr = max(fr_abs_won)
ylim1_won_nl = min(nl_abs_won)
ylim2_won_nl = max(nl_abs_won)
ylim1_won_no = min(no_abs_won)
ylim2_won_no = max(no_abs_won)
ylim1_won_se = min(se_abs_won)
ylim2_won_se = max(se_abs_won)
ylim1_won_uk = min(uk_abs_won)
ylim2_won_uk = max(uk_abs_won)

ylim12_won_at = min(at_real_won)
ylim22_won_at = max(at_real_won)
ylim12_won_balt = min(balt_real_won)
ylim22_won_balt = max(balt_real_won)
ylim12_won_be = min(be_real_won)
ylim22_won_be = max(be_real_won)
ylim12_won_de = min(de_real_won)
ylim22_won_de = max(de_real_won)
ylim12_won_dk = min(dk_real_won)
ylim22_won_dk = max(dk_real_won)
ylim12_won_es = min(es_real_won)
ylim22_won_es = max(es_real_won)
ylim12_won_fr = min(fr_real_won)
ylim22_won_fr = max(fr_real_won)
ylim12_won_nl = min(nl_real_won)
ylim22_won_nl = max(nl_real_won)
ylim12_won_no = min(no_real_won)
ylim22_won_no = max(no_real_won)
ylim12_won_se = min(se_real_won)
ylim22_won_se = max(se_real_won)
ylim12_won_uk = min(uk_real_won)
ylim22_won_uk = max(uk_real_won)

## Synthetize TDY, EHCF and ELCF for EU-won
pdf("~/Desktop/FS_won.pdf")
par(mfrow=c(1,2))
plot(de_abs_won[1,], ylim = c(ylim1_won_de,ylim2_won_de), ylab = "FS",xlab="",xaxt="n",col='black',cex=0.8)
title("Onshore Wind (Germany)")
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(at_abs_won[i,], ylab = "",xlab="",xaxt="n")
}

plot(at_real_won[1,], ylim = c(ylim12_won_at,ylim22_won_at), ylab = "at_real_FS_won",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(at_real_won[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_won_at = vector("numeric",12)
min_real_won_at = vector("numeric",12)
max_real_won_at = vector("numeric",12)
min_abs_won_balt = vector("numeric",12)
min_real_won_balt = vector("numeric",12)
max_real_won_balt = vector("numeric",12)
min_abs_won_be = vector("numeric",12)
min_real_won_be = vector("numeric",12)
max_real_won_be = vector("numeric",12)
min_abs_won_de = vector("numeric",12)
min_real_won_de = vector("numeric",12)
max_real_won_de = vector("numeric",12)
min_abs_won_dk = vector("numeric",12)
min_real_won_dk = vector("numeric",12)
max_real_won_dk = vector("numeric",12)
min_abs_won_es = vector("numeric",12)
min_real_won_es = vector("numeric",12)
max_real_won_es = vector("numeric",12)
min_abs_won_fr = vector("numeric",12)
min_real_won_fr = vector("numeric",12)
max_real_won_fr = vector("numeric",12)
min_abs_won_nl = vector("numeric",12)
min_real_won_nl = vector("numeric",12)
max_real_won_nl = vector("numeric",12)
min_abs_won_no = vector("numeric",12)
min_real_won_no = vector("numeric",12)
max_real_won_no = vector("numeric",12)
min_abs_won_se = vector("numeric",12)
min_real_won_se = vector("numeric",12)
max_real_won_se = vector("numeric",12)
min_abs_won_uk = vector("numeric",12)
min_real_won_uk = vector("numeric",12)
max_real_won_uk = vector("numeric",12)
for(i in 1:12){
    min_abs_won_at[i] = which.min(at_abs_won[,i])
    min_real_won_at[i] = which.min(at_real_won[,i])
    max_real_won_at[i] = which.max(at_real_won[,i])
    min_abs_won_balt[i] = which.min(balt_abs_won[,i])
    min_real_won_balt[i] = which.min(balt_real_won[,i])
    max_real_won_balt[i] = which.max(balt_real_won[,i])
    min_abs_won_be[i] = which.min(be_abs_won[,i])
    min_real_won_be[i] = which.min(be_real_won[,i])
    max_real_won_be[i] = which.max(be_real_won[,i])
    min_abs_won_de[i] = which.min(de_abs_won[,i])
    min_real_won_de[i] = which.min(de_real_won[,i])
    max_real_won_de[i] = which.max(de_real_won[,i])
    min_abs_won_dk[i] = which.min(dk_abs_won[,i])
    min_real_won_dk[i] = which.min(dk_real_won[,i])
    max_real_won_dk[i] = which.max(dk_real_won[,i])
    min_abs_won_es[i] = which.min(es_abs_won[,i])
    min_real_won_es[i] = which.min(es_real_won[,i])
    max_real_won_es[i] = which.max(es_real_won[,i])
    min_abs_won_fr[i] = which.min(fr_abs_won[,i])
    min_real_won_fr[i] = which.min(fr_real_won[,i])
    max_real_won_fr[i] = which.max(fr_real_won[,i])
    min_abs_won_nl[i] = which.min(nl_abs_won[,i])
    min_real_won_nl[i] = which.min(nl_real_won[,i])
    max_real_won_nl[i] = which.max(nl_real_won[,i])
    min_abs_won_no[i] = which.min(no_abs_won[,i])
    min_real_won_no[i] = which.min(no_real_won[,i])
    max_real_won_no[i] = which.max(no_real_won[,i])
    min_abs_won_se[i] = which.min(se_abs_won[,i])
    min_real_won_se[i] = which.min(se_real_won[,i])
    max_real_won_se[i] = which.max(se_real_won[,i])
    min_abs_won_uk[i] = which.min(uk_abs_won[,i])
    min_real_won_uk[i] = which.min(uk_real_won[,i])
    max_real_won_uk[i] = which.max(uk_real_won[,i])
}
which.min(de_abs_won[,1])
png("~/Desktop/FS_abs_won2.png")
plot(de_abs_won[1,], ylim = c(ylim1_won_de,ylim2_won_de), ylab = "FS",xlab="",xaxt="n",col='black',cex=0.8)
title("Onshore Wind (Germany)")
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
for(i in 2:71){
    points(de_abs_won[i,], ylab = "",xlab="",xaxt="n")
}
new = vector("numeric",12)
for(i in 1:12){
    new[i] = de_abs_won[min_abs_won_de[i],i]
}
points(new,col='yellow4',pch=4,cex=2)
legend(4, 0.25, legend=c("1950-2020 year","min(FS)"),col=c("black","yellow4"), lty=1:2, cex=1)
dev.off()

png("~/Desktop/FS_abs_won3.png")
plot(de_real_won[1,], ylim = c(ylim12_won_de,ylim22_won_de), ylab = "FS2", col='black',xlab="",xaxt="n",cex=0.8)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
title("Onshore Wind (Germany)")
for(i in 2:71){
    points(de_real_won[i,], ylab = "",xlab="",xaxt="n",col='black')
}
new2 = vector("numeric",12)
new3 = vector("numeric",12)
for(i in 1:12){
    new2[i] = de_real_won[min_real_won_de[i],i]
    new3[i] = de_real_won[max_real_won_de[i],i]
}
points(new2,col='blue',pch=4,cex=2)
points(new3,col='red',pch=4,cex=2)
legend(4, 0.25, legend=c("1950-2020 year","min(FS2)","max(FS2)"),col=c("black","blue","red"), lty=1:3, cex=1)

dev.off()
TDY_at = vector("numeric",(12*720))
EHCF_at = vector("numeric",(12*720))
ELCF_at = vector("numeric",(12*720))
TDY_balt = vector("numeric",(12*720))
EHCF_balt = vector("numeric",(12*720))
ELCF_balt = vector("numeric",(12*720))
TDY_be = vector("numeric",(12*720))
EHCF_be = vector("numeric",(12*720))
ELCF_be = vector("numeric",(12*720))
TDY_de = vector("numeric",(12*720))
EHCF_de = vector("numeric",(12*720))
ELCF_de = vector("numeric",(12*720))
TDY_dk = vector("numeric",(12*720))
EHCF_dk = vector("numeric",(12*720))
ELCF_dk = vector("numeric",(12*720))
TDY_es = vector("numeric",(12*720))
EHCF_es = vector("numeric",(12*720))
ELCF_es = vector("numeric",(12*720))
TDY_fr = vector("numeric",(12*720))
EHCF_fr = vector("numeric",(12*720))
ELCF_fr = vector("numeric",(12*720))
TDY_nl = vector("numeric",(12*720))
EHCF_nl = vector("numeric",(12*720))
ELCF_nl = vector("numeric",(12*720))
TDY_no = vector("numeric",(12*720))
EHCF_no = vector("numeric",(12*720))
ELCF_no = vector("numeric",(12*720))
TDY_se = vector("numeric",(12*720))
EHCF_se = vector("numeric",(12*720))
ELCF_se = vector("numeric",(12*720))
TDY_uk = vector("numeric",(12*720))
EHCF_uk = vector("numeric",(12*720))
ELCF_uk = vector("numeric",(12*720))
for(i in 1:12){
    TDY_at[((i-1)*720+1):(i*720)] = won_at[min_abs_won_at[i], ((i-1)*720+1):(i*720)]
    EHCF_at[((i-1)*720+1):(i*720)] = won_at[min_real_won_at[i], ((i-1)*720+1):(i*720)]
    ELCF_at[((i-1)*720+1):(i*720)] = won_at[max_real_won_at[i], ((i-1)*720+1):(i*720)]
    TDY_balt[((i-1)*720+1):(i*720)] = won_balt[min_abs_won_balt[i], ((i-1)*720+1):(i*720)]
    EHCF_balt[((i-1)*720+1):(i*720)] = won_balt[min_real_won_balt[i], ((i-1)*720+1):(i*720)]
    ELCF_balt[((i-1)*720+1):(i*720)] = won_balt[max_real_won_balt[i], ((i-1)*720+1):(i*720)]
    TDY_be[((i-1)*720+1):(i*720)] = won_be[min_abs_won_be[i], ((i-1)*720+1):(i*720)]
    EHCF_be[((i-1)*720+1):(i*720)] = won_be[min_real_won_be[i], ((i-1)*720+1):(i*720)]
    ELCF_be[((i-1)*720+1):(i*720)] = won_be[max_real_won_be[i], ((i-1)*720+1):(i*720)]
    TDY_de[((i-1)*720+1):(i*720)] = won_de[min_abs_won_de[i], ((i-1)*720+1):(i*720)]
    EHCF_de[((i-1)*720+1):(i*720)] = won_de[min_real_won_de[i], ((i-1)*720+1):(i*720)]
    ELCF_de[((i-1)*720+1):(i*720)] = won_de[max_real_won_de[i], ((i-1)*720+1):(i*720)]
    TDY_dk[((i-1)*720+1):(i*720)] = won_dk[min_abs_won_dk[i], ((i-1)*720+1):(i*720)]
    EHCF_dk[((i-1)*720+1):(i*720)] = won_dk[min_real_won_dk[i], ((i-1)*720+1):(i*720)]
    ELCF_dk[((i-1)*720+1):(i*720)] = won_dk[max_real_won_dk[i], ((i-1)*720+1):(i*720)]
    TDY_es[((i-1)*720+1):(i*720)] = won_es[min_abs_won_es[i], ((i-1)*720+1):(i*720)]
    EHCF_es[((i-1)*720+1):(i*720)] = won_es[min_real_won_es[i], ((i-1)*720+1):(i*720)]
    ELCF_es[((i-1)*720+1):(i*720)] = won_es[max_real_won_es[i], ((i-1)*720+1):(i*720)]
    TDY_fr[((i-1)*720+1):(i*720)] = won_fr[min_abs_won_fr[i], ((i-1)*720+1):(i*720)]
    EHCF_fr[((i-1)*720+1):(i*720)] = won_fr[min_real_won_fr[i], ((i-1)*720+1):(i*720)]
    ELCF_fr[((i-1)*720+1):(i*720)] = won_fr[max_real_won_fr[i], ((i-1)*720+1):(i*720)]
    TDY_nl[((i-1)*720+1):(i*720)] = won_nl[min_abs_won_nl[i], ((i-1)*720+1):(i*720)]
    EHCF_nl[((i-1)*720+1):(i*720)] = won_nl[min_real_won_nl[i], ((i-1)*720+1):(i*720)]
    ELCF_nl[((i-1)*720+1):(i*720)] = won_nl[max_real_won_nl[i], ((i-1)*720+1):(i*720)]
    TDY_no[((i-1)*720+1):(i*720)] = won_no[min_abs_won_no[i], ((i-1)*720+1):(i*720)]
    EHCF_no[((i-1)*720+1):(i*720)] = won_no[min_real_won_no[i], ((i-1)*720+1):(i*720)]
    ELCF_no[((i-1)*720+1):(i*720)] = won_no[max_real_won_no[i], ((i-1)*720+1):(i*720)]
    TDY_se[((i-1)*720+1):(i*720)] = won_se[min_abs_won_se[i], ((i-1)*720+1):(i*720)]
    EHCF_se[((i-1)*720+1):(i*720)] = won_se[min_real_won_se[i], ((i-1)*720+1):(i*720)]
    ELCF_se[((i-1)*720+1):(i*720)] = won_se[max_real_won_se[i], ((i-1)*720+1):(i*720)]
    TDY_uk[((i-1)*720+1):(i*720)] = won_uk[min_abs_won_uk[i], ((i-1)*720+1):(i*720)]
    EHCF_uk[((i-1)*720+1):(i*720)] = won_uk[min_real_won_uk[i], ((i-1)*720+1):(i*720)]
    ELCF_uk[((i-1)*720+1):(i*720)] = won_uk[max_real_won_uk[i], ((i-1)*720+1):(i*720)]
}

Fn = ecdf(won_de[1,])
x_min = min(won_de)
x_max = max(won_de)
png("~/Desktop/cdf_won_de.png")
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="CF",ylab="CDF",col='grey')
title("Onshore Wind Germany")
legend(0.6, 0.7, legend=c("1950-2020 year", "TDY","EHCF","ELCF"),col=c("grey", "yellow4","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(won_de[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY_de)
x_min = min(TDY_de)
x_max = max(TDY_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="yellow4",lwd=2)
Fn = ecdf(EHCF_de)
x_min = min(EHCF_de)
x_max = max(EHCF_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l',lwd=2)
Fn = ecdf(ELCF_de)
x_min = min(ELCF_de)
x_max = max(ELCF_de)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l',lwd=2)
dev.off()

png("~/Desktop/syn_won_de")
max_value = max(won_de)
plot(won_de[1,],type='l',col='gray', ylab='CF',ylim=c(0,max_value), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2)
axis(1, at = seq(1,12*730,by=730), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
title("Onshore Wind Capacity Factor (Germany)")
#library(RColorBrewer)
for(i in 2:70){
    points(won_de[i,],type='l',col='gray', lwd=2)
}
points(TDY_de,type='l',col='yellow4',lwd=2)
points(EHCF_de,type='l',col='blue',lwd=2)
points(ELCF_de,type='l',col='red',lwd=2)
legend(x = 4*730, y = 0.9, legend = c("year 1950-2020", "TDY","EHCF","ELCF"), lty = c(1,1,1,1), col = c('gray','yellow4','red','blue'), lwd = 2)
dev.off()


syn_at = matrix(NA, ncol=3, nrow=12*30*24)
syn_balt = matrix(NA, ncol=3, nrow=12*30*24)
syn_be = matrix(NA, ncol=3, nrow=12*30*24)
syn_de = matrix(NA, ncol=3, nrow=12*30*24)
syn_dk = matrix(NA, ncol=3, nrow=12*30*24)
syn_es = matrix(NA, ncol=3, nrow=12*30*24)
syn_fr = matrix(NA, ncol=3, nrow=12*30*24)
syn_nl = matrix(NA, ncol=3, nrow=12*30*24)
syn_no = matrix(NA, ncol=3, nrow=12*30*24)
syn_se = matrix(NA, ncol=3, nrow=12*30*24)
syn_uk = matrix(NA, ncol=3, nrow=12*30*24)

# save data as table
tab_won_TDY <- matrix(c(TDY_at,TDY_balt,TDY_be,TDY_de,TDY_dk,TDY_es,TDY_fr,TDY_nl,TDY_no,TDY_se,TDY_uk), ncol=11, byrow=FALSE)
colnames(tab_won_TDY) <- c('won_TDY_at','won_TDY_balt','won_TDY_be','won_TDY_de','won_TDY_dk','won_TDY_es','won_TDY_fr','won_TDY_nl','won_TDY_no','won_TDY_se','won_TDY_uk')
tab_won_TDY <- as.table(tab_won_TDY)

tab_won_EHCF<- matrix(c(EHCF_at,EHCF_balt,EHCF_be,EHCF_de,EHCF_dk,EHCF_es,EHCF_fr,EHCF_nl,EHCF_no,EHCF_se,EHCF_uk), ncol=11, byrow=FALSE)
colnames(tab_won_EHCF) <- c('won_EHCF_at','won_EHCF_balt','won_EHCF_be','won_EHCF_de','won_EHCF_dk','won_EHCF_es','won_EHCF_fr','won_EHCF_nl','won_EHCF_no','won_EHCF_se','won_EHCF_uk')
tab_won_EHCF <- as.table(tab_won_EHCF)

tab_won_ELCF<- matrix(c(ELCF_at,ELCF_balt,ELCF_be,ELCF_de,ELCF_dk,ELCF_es,ELCF_fr,ELCF_nl,ELCF_no,ELCF_se,ELCF_uk), ncol=11, byrow=FALSE)
colnames(tab_won_ELCF) <- c('won_ELCF_at','won_ELCF_balt','won_ELCF_be','won_ELCF_de','won_ELCF_dk','won_ELCF_es','won_ELCF_fr','won_ELCF_nl','won_ELCF_no','won_ELCF_se','won_ELCF_uk')
tab_won_ELCF <- as.table(tab_won_ELCF)

write.table(tab_won_TDY,"~/Documents/InfraTrain_School/Project/syn_won_TDY.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_won_EHCF,"~/Documents/InfraTrain_School/Project/syn_won_EHCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_won_ELCF,"~/Documents/InfraTrain_School/Project/syn_won_ELCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
###########################################################

## Make synthetized years including TDY, EHCF and ELCF for wind & wofar CF in EU
## Call dataset in xlsx format
library("readxl")
EU_wof_data <- read_excel("~/Documents/InfraTrain_School/Project/Capacity_factors_EU.xlsx",sheet = "windoff")
# rows include years from 1950 to 2020 and columns include hourly data in each year
wof_at = matrix(NA, nrow=71, ncol=8760)
wof_balt = matrix(NA, nrow=71, ncol=8760)
wof_be = matrix(NA, nrow=71, ncol=8760)
wof_de = matrix(NA, nrow=71, ncol=8760)
wof_dk = matrix(NA, nrow=71, ncol=8760)
wof_es = matrix(NA, nrow=71, ncol=8760)
wof_fr = matrix(NA, nrow=71, ncol=8760)
wof_nl = matrix(NA, nrow=71, ncol=8760)
wof_no = matrix(NA, nrow=71, ncol=8760)
wof_se = matrix(NA, nrow=71, ncol=8760)
wof_uk = matrix(NA, nrow=71, ncol=8760)

for(i in 1:71){
    wof_at[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+2)]))
    wof_balt[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+3)]))
    wof_be[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+4)]))
    wof_de[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+5)]))
    wof_dk[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+6)]))
    wof_es[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+7)]))
    wof_fr[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+8)]))
    wof_nl[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+9)]))
    wof_no[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+10)]))
    wof_se[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+11)]))
    wof_uk[i,1:8760] = as.numeric(unlist(EU_wof_data[2:8761,((i-1)*11+12)]))
    }
## To plot mean of capacity factor    
wof_de_month = matrix(NA, nrow = 71, ncol = 12)
for(i in 1:71){
    for(j in 1:12){
        wof_de_month[i,j] = mean(wof_de[i,((j-1)*730+1):(j*730)])
    }
}
max_value = max(wof_de_month)
png('~/Desktop/mean_CF_wof_de.png')
plot(wof_de_month[1,],type='l',col='gray', ylab='CF(solar)',ylim=c(0,max_value), xlab='', xaxt='n',cex.lab = 1.2, cex.axis = 1,lwd=2)
title("Offshore Wind Capacity Factor (Germany)")
axis(1, at = c(1:12), labels = c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'), las=2)
for(i in 2:70){
    points(wof_de_month[i,],type='l',col='gray', lwd=2)
}
points(wof_de_month[21,],type='l',col='red',lwd=2)
points(wof_de_month[51,],type='l',col='green',lwd=2)
points(wof_de_month[70,],type='l',col='blue',lwd=2)
legend(x = 5, y = 0.85, legend = c("year 1950-2020", "year 1970","year 2000", "year 2020"), lty = c(1,1,1,1), col = c('gray','red','green','blue'), lwd = 2)
dev.off()
## Monthly and annualy CDF from January to December for EU-wof (Assumption: equal days in each month) --> FS statistics
M_CDF_wof_at = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_balt = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_be = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_de = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_dk = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_es = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_fr = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_nl = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_no = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_se = matrix(NA, nrow = 71, ncol = (100*12))
M_CDF_wof_uk = matrix(NA, nrow = 71, ncol = (100*12))
A_CDF_wof_at = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_balt = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_be = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_de = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_dk = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_es = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_fr = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_nl = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_no = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_se = matrix(NA, nrow = 1, ncol = (100*12))
A_CDF_wof_uk = matrix(NA, nrow = 1, ncol = (100*12))
x_wof_at = matrix(NA, nrow = 12, ncol = 2) # To fix range of data for CDF calculations
x_wof_balt = matrix(NA, nrow = 12, ncol = 2)
x_wof_be = matrix(NA, nrow = 12, ncol = 2)
x_wof_de = matrix(NA, nrow = 12, ncol = 2)
x_wof_dk = matrix(NA, nrow = 12, ncol = 2)
x_wof_es = matrix(NA, nrow = 12, ncol = 2)
x_wof_fr = matrix(NA, nrow = 12, ncol = 2)
x_wof_nl = matrix(NA, nrow = 12, ncol = 2)
x_wof_no = matrix(NA, nrow = 12, ncol = 2)
x_wof_se = matrix(NA, nrow = 12, ncol = 2)
x_wof_uk = matrix(NA, nrow = 12, ncol = 2)

for(i in 1:12){
    x_wof_at[i,1] = min(wof_at[,((i-1)*720+1):(i*720)])
    x_wof_at[i,2] = max(wof_at[,((i-1)*720+1):(i*720)])
    x_wof_balt[i,1] = min(wof_balt[,((i-1)*720+1):(i*720)])
    x_wof_balt[i,2] = max(wof_balt[,((i-1)*720+1):(i*720)])
    x_wof_be[i,1] = min(wof_be[,((i-1)*720+1):(i*720)])
    x_wof_be[i,2] = max(wof_be[,((i-1)*720+1):(i*720)])
    x_wof_de[i,1] = min(wof_de[,((i-1)*720+1):(i*720)])
    x_wof_de[i,2] = max(wof_de[,((i-1)*720+1):(i*720)])
    x_wof_dk[i,1] = min(wof_dk[,((i-1)*720+1):(i*720)])
    x_wof_dk[i,2] = max(wof_dk[,((i-1)*720+1):(i*720)])
    x_wof_es[i,1] = min(wof_es[,((i-1)*720+1):(i*720)])
    x_wof_es[i,2] = max(wof_es[,((i-1)*720+1):(i*720)])
    x_wof_fr[i,1] = min(wof_fr[,((i-1)*720+1):(i*720)])
    x_wof_fr[i,2] = max(wof_fr[,((i-1)*720+1):(i*720)])
    x_wof_nl[i,1] = min(wof_nl[,((i-1)*720+1):(i*720)])
    x_wof_nl[i,2] = max(wof_nl[,((i-1)*720+1):(i*720)])
    x_wof_no[i,1] = min(wof_no[,((i-1)*720+1):(i*720)])
    x_wof_no[i,2] = max(wof_no[,((i-1)*720+1):(i*720)])
    x_wof_se[i,1] = min(wof_se[,((i-1)*720+1):(i*720)])
    x_wof_se[i,2] = max(wof_se[,((i-1)*720+1):(i*720)])
    x_wof_uk[i,1] = min(wof_uk[,((i-1)*720+1):(i*720)])
    x_wof_uk[i,2] = max(wof_uk[,((i-1)*720+1):(i*720)])   

}
for(i in 1:12){
    for(j in 1:71){
        Fn = ecdf(wof_at[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_at[i,1],x_wof_at[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_at[j,((i-1)*100+1):(i*100)] = t_n 
        Fn = ecdf(wof_balt[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_balt[i,1],x_wof_balt[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_balt[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_be[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_be[i,1],x_wof_be[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_be[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_de[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_de[i,1],x_wof_de[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_de[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_dk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_dk[i,1],x_wof_dk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_dk[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_es[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_es[i,1],x_wof_es[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_es[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_fr[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_fr[i,1],x_wof_fr[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_fr[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_nl[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_nl[i,1],x_wof_nl[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_nl[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_no[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_no[i,1],x_wof_no[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_no[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_se[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_se[i,1],x_wof_se[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_se[j,((i-1)*100+1):(i*100)] = t_n
        Fn = ecdf(wof_uk[j,((i-1)*720+1):(i*720)])
        x_n = seq(x_wof_uk[i,1],x_wof_uk[i,2],length=100)
        t_n = Fn(x_n)
        M_CDF_wof_uk[j,((i-1)*100+1):(i*100)] = t_n
        }
}
for(i in 1:12){
    Fn = ecdf(wof_at[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_at[i,1],x_wof_at[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_at[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_balt[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_balt[i,1],x_wof_balt[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_balt[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_be[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_be[i,1],x_wof_be[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_be[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_de[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_de[i,1],x_wof_de[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_de[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_dk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_dk[i,1],x_wof_dk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_dk[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_es[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_es[i,1],x_wof_es[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_es[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_fr[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_fr[i,1],x_wof_fr[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_fr[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_nl[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_nl[i,1],x_wof_nl[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_nl[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_no[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_no[i,1],x_wof_no[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_no[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_se[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_se[i,1],x_wof_se[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_se[1,((i-1)*100+1):(i*100)] = t_n
    Fn = ecdf(wof_uk[1:71,((i-1)*720+1):(i*720)])
    x_n = seq(x_wof_uk[i,1],x_wof_uk[i,2],length=100)
    t_n = Fn(x_n)
    A_CDF_wof_uk[1,((i-1)*100+1):(i*100)] = t_n
}

plot(seq(x_wof_at[1,1],x_wof_at[1,2],length=100),A_CDF_wof_at[1,1:100])
points(seq(x_wof_at[1,1],x_wof_at[1,2],length=100),M_CDF_wof_at[2,1:100],col='red')
points(seq(x_wof_at[1,1],x_wof_at[1,2],length=100),M_CDF_wof_at[3,1:100],col='blue')
points(seq(x_wof_at[1,1],x_wof_at[1,2],length=100),M_CDF_wof_at[50,1:100],col='green')
points(seq(x_wof_at[1,1],x_wof_at[1,2],length=100),M_CDF_wof_at[70,1:100],col='yellow')
plot(seq(x_wof_uk[2,1],x_wof_uk[2,2],length=100),A_CDF_wof_uk[1,(1*100+1):(2*100)])
points(seq(x_wof_uk[2,1],x_wof_uk[2,2],length=100),M_CDF_wof_uk[2,(1*100+1):(2*100)],col='red')
points(seq(x_wof_uk[2,1],x_wof_uk[2,2],length=100),M_CDF_wof_uk[3,(1*100+1):(2*100)],col='blue')
points(seq(x_wof_uk[2,1],x_wof_uk[2,2],length=100),M_CDF_wof_uk[50,(1*100+1):(2*100)],col='green')
points(seq(x_wof_uk[2,1],x_wof_uk[2,2],length=100),M_CDF_wof_uk[70,(1*100+1):(2*100)],col='yellow')

## Synthetize years with typical & extreme wofar power in EU
at_abs_wof = matrix(NA, nrow = 71, ncol = 12)
balt_abs_wof = matrix(NA, nrow = 71, ncol = 12)
be_abs_wof = matrix(NA, nrow = 71, ncol = 12)
de_abs_wof = matrix(NA, nrow = 71, ncol = 12)
dk_abs_wof = matrix(NA, nrow = 71, ncol = 12)
es_abs_wof = matrix(NA, nrow = 71, ncol = 12)
fr_abs_wof = matrix(NA, nrow = 71, ncol = 12)
nl_abs_wof = matrix(NA, nrow = 71, ncol = 12)
no_abs_wof = matrix(NA, nrow = 71, ncol = 12)
se_abs_wof = matrix(NA, nrow = 71, ncol = 12)
uk_abs_wof = matrix(NA, nrow = 71, ncol = 12)
at_real_wof = matrix(NA, nrow = 71, ncol = 12)
balt_real_wof = matrix(NA, nrow = 71, ncol = 12)
be_real_wof = matrix(NA, nrow = 71, ncol = 12)
de_real_wof = matrix(NA, nrow = 71, ncol = 12)
dk_real_wof = matrix(NA, nrow = 71, ncol = 12)
es_real_wof = matrix(NA, nrow = 71, ncol = 12)
fr_real_wof = matrix(NA, nrow = 71, ncol = 12)
nl_real_wof = matrix(NA, nrow = 71, ncol = 12)
no_real_wof = matrix(NA, nrow = 71, ncol = 12)
se_real_wof = matrix(NA, nrow = 71, ncol = 12)
uk_real_wof = matrix(NA, nrow = 71, ncol = 12)

for(i in 1:71){
    for(j in 1:12){
        at_abs_wof[i,j] = abs(mean(A_CDF_wof_at[1,((j-1)*100+1):(j*100)]-M_CDF_wof_at[i,((j-1)*100+1):(j*100)]))
        balt_abs_wof[i,j] = abs(mean(A_CDF_wof_balt[1,((j-1)*100+1):(j*100)]-M_CDF_wof_balt[i,((j-1)*100+1):(j*100)]))
        be_abs_wof[i,j] = abs(mean(A_CDF_wof_be[1,((j-1)*100+1):(j*100)]-M_CDF_wof_be[i,((j-1)*100+1):(j*100)]))
        de_abs_wof[i,j] = abs(mean(A_CDF_wof_de[1,((j-1)*100+1):(j*100)]-M_CDF_wof_de[i,((j-1)*100+1):(j*100)]))
        dk_abs_wof[i,j] = abs(mean(A_CDF_wof_dk[1,((j-1)*100+1):(j*100)]-M_CDF_wof_dk[i,((j-1)*100+1):(j*100)]))
        es_abs_wof[i,j] = abs(mean(A_CDF_wof_es[1,((j-1)*100+1):(j*100)]-M_CDF_wof_es[i,((j-1)*100+1):(j*100)]))
        fr_abs_wof[i,j] = abs(mean(A_CDF_wof_fr[1,((j-1)*100+1):(j*100)]-M_CDF_wof_fr[i,((j-1)*100+1):(j*100)]))
        nl_abs_wof[i,j] = abs(mean(A_CDF_wof_nl[1,((j-1)*100+1):(j*100)]-M_CDF_wof_nl[i,((j-1)*100+1):(j*100)]))
        no_abs_wof[i,j] = abs(mean(A_CDF_wof_no[1,((j-1)*100+1):(j*100)]-M_CDF_wof_no[i,((j-1)*100+1):(j*100)]))
        se_abs_wof[i,j] = abs(mean(A_CDF_wof_se[1,((j-1)*100+1):(j*100)]-M_CDF_wof_se[i,((j-1)*100+1):(j*100)]))
        uk_abs_wof[i,j] = abs(mean(A_CDF_wof_uk[1,((j-1)*100+1):(j*100)]-M_CDF_wof_uk[i,((j-1)*100+1):(j*100)]))       
    }
}

for(i in 1:71){
    for(j in 1:12){
        at_real_wof[i,j] = (mean(A_CDF_wof_at[1,((j-1)*100+1):(j*100)]-M_CDF_wof_at[i,((j-1)*100+1):(j*100)]))
        balt_real_wof[i,j] = (mean(A_CDF_wof_balt[1,((j-1)*100+1):(j*100)]-M_CDF_wof_balt[i,((j-1)*100+1):(j*100)]))
        be_real_wof[i,j] = (mean(A_CDF_wof_be[1,((j-1)*100+1):(j*100)]-M_CDF_wof_be[i,((j-1)*100+1):(j*100)]))
        de_real_wof[i,j] = (mean(A_CDF_wof_de[1,((j-1)*100+1):(j*100)]-M_CDF_wof_de[i,((j-1)*100+1):(j*100)]))
        dk_real_wof[i,j] = (mean(A_CDF_wof_dk[1,((j-1)*100+1):(j*100)]-M_CDF_wof_dk[i,((j-1)*100+1):(j*100)]))
        es_real_wof[i,j] = (mean(A_CDF_wof_es[1,((j-1)*100+1):(j*100)]-M_CDF_wof_es[i,((j-1)*100+1):(j*100)]))
        fr_real_wof[i,j] = (mean(A_CDF_wof_fr[1,((j-1)*100+1):(j*100)]-M_CDF_wof_fr[i,((j-1)*100+1):(j*100)]))
        nl_real_wof[i,j] = (mean(A_CDF_wof_nl[1,((j-1)*100+1):(j*100)]-M_CDF_wof_nl[i,((j-1)*100+1):(j*100)]))
        no_real_wof[i,j] = (mean(A_CDF_wof_no[1,((j-1)*100+1):(j*100)]-M_CDF_wof_no[i,((j-1)*100+1):(j*100)]))
        se_real_wof[i,j] = (mean(A_CDF_wof_se[1,((j-1)*100+1):(j*100)]-M_CDF_wof_se[i,((j-1)*100+1):(j*100)]))
        uk_real_wof[i,j] = (mean(A_CDF_wof_uk[1,((j-1)*100+1):(j*100)]-M_CDF_wof_uk[i,((j-1)*100+1):(j*100)]))
    }
}
ylim1_wof_at = min(at_abs_wof)
ylim2_wof_at = max(at_abs_wof)
ylim1_wof_balt = min(balt_abs_wof)
ylim2_wof_balt = max(balt_abs_wof)
ylim1_wof_be = min(be_abs_wof)
ylim2_wof_be = max(be_abs_wof)
ylim1_wof_de = min(de_abs_wof)
ylim2_wof_de = max(de_abs_wof)
ylim1_wof_dk = min(dk_abs_wof)
ylim2_wof_dk = max(dk_abs_wof)
ylim1_wof_es = min(es_abs_wof)
ylim2_wof_es = max(es_abs_wof)
ylim1_wof_fr = min(fr_abs_wof)
ylim2_wof_fr = max(fr_abs_wof)
ylim1_wof_nl = min(nl_abs_wof)
ylim2_wof_nl = max(nl_abs_wof)
ylim1_wof_no = min(no_abs_wof)
ylim2_wof_no = max(no_abs_wof)
ylim1_wof_se = min(se_abs_wof)
ylim2_wof_se = max(se_abs_wof)
ylim1_wof_uk = min(uk_abs_wof)
ylim2_wof_uk = max(uk_abs_wof)

ylim12_wof_at = min(at_real_wof)
ylim22_wof_at = max(at_real_wof)
ylim12_wof_balt = min(balt_real_wof)
ylim22_wof_balt = max(balt_real_wof)
ylim12_wof_be = min(be_real_wof)
ylim22_wof_be = max(be_real_wof)
ylim12_wof_de = min(de_real_wof)
ylim22_wof_de = max(de_real_wof)
ylim12_wof_dk = min(dk_real_wof)
ylim22_wof_dk = max(dk_real_wof)
ylim12_wof_es = min(es_real_wof)
ylim22_wof_es = max(es_real_wof)
ylim12_wof_fr = min(fr_real_wof)
ylim22_wof_fr = max(fr_real_wof)
ylim12_wof_nl = min(nl_real_wof)
ylim22_wof_nl = max(nl_real_wof)
ylim12_wof_no = min(no_real_wof)
ylim22_wof_no = max(no_real_wof)
ylim12_wof_se = min(se_real_wof)
ylim22_wof_se = max(se_real_wof)
ylim12_wof_uk = min(uk_real_wof)
ylim22_wof_uk = max(uk_real_wof)


## Synthetize TDY, EHCF and ELCF for EU-wof
pdf("~/Desktop/FS_wof.pdf")
par(mfrow=c(1,2))
plot(uk_abs_wof[1,], ylim = c(ylim1_wof_uk,ylim2_wof_uk), ylab = "uk_abs_FS_wof",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(uk_abs_wof[i,], ylab = "",xlab="",xaxt="n")
}

plot(uk_real_wof[1,], ylim = c(ylim12_wof_uk,ylim22_wof_uk), ylab = "uk_real_FS_wof",xlab="",xaxt="n",pch=4,col='red',cex=2)
axis(1, at = 1:12, labels = c("Jan","Feb","Mar","April","May","June","Jul","Aug","Sep","Oct","Nov","Dec"))
legend(1, 0.06, legend=c("1950", "...","2020"),col=c("red","black","black"), lty=1:2, cex=0.8)
for(i in 2:71){
    points(uk_real_wof[i,], ylab = "",xlab="",xaxt="n")
}
dev.off()

min_abs_wof_at = vector("numeric",12)
min_real_wof_at = vector("numeric",12)
max_real_wof_at = vector("numeric",12)
min_abs_wof_balt = vector("numeric",12)
min_real_wof_balt = vector("numeric",12)
max_real_wof_balt = vector("numeric",12)
min_abs_wof_be = vector("numeric",12)
min_real_wof_be = vector("numeric",12)
max_real_wof_be = vector("numeric",12)
min_abs_wof_de = vector("numeric",12)
min_real_wof_de = vector("numeric",12)
max_real_wof_de = vector("numeric",12)
min_abs_wof_dk = vector("numeric",12)
min_real_wof_dk = vector("numeric",12)
max_real_wof_dk = vector("numeric",12)
min_abs_wof_es = vector("numeric",12)
min_real_wof_es = vector("numeric",12)
max_real_wof_es = vector("numeric",12)
min_abs_wof_fr = vector("numeric",12)
min_real_wof_fr = vector("numeric",12)
max_real_wof_fr = vector("numeric",12)
min_abs_wof_nl = vector("numeric",12)
min_real_wof_nl = vector("numeric",12)
max_real_wof_nl = vector("numeric",12)
min_abs_wof_no = vector("numeric",12)
min_real_wof_no = vector("numeric",12)
max_real_wof_no = vector("numeric",12)
min_abs_wof_se = vector("numeric",12)
min_real_wof_se = vector("numeric",12)
max_real_wof_se = vector("numeric",12)
min_abs_wof_uk = vector("numeric",12)
min_real_wof_uk = vector("numeric",12)
max_real_wof_uk = vector("numeric",12)
for(i in 1:12){
    min_abs_wof_at[i] = which.min(at_abs_wof[,i])
    min_real_wof_at[i] = which.min(at_real_wof[,i])
    max_real_wof_at[i] = which.max(at_real_wof[,i])
    min_abs_wof_balt[i] = which.min(balt_abs_wof[,i])
    min_real_wof_balt[i] = which.min(balt_real_wof[,i])
    max_real_wof_balt[i] = which.max(balt_real_wof[,i])
    min_abs_wof_be[i] = which.min(be_abs_wof[,i])
    min_real_wof_be[i] = which.min(be_real_wof[,i])
    max_real_wof_be[i] = which.max(be_real_wof[,i])
    min_abs_wof_de[i] = which.min(de_abs_wof[,i])
    min_real_wof_de[i] = which.min(de_real_wof[,i])
    max_real_wof_de[i] = which.max(de_real_wof[,i])
    min_abs_wof_dk[i] = which.min(dk_abs_wof[,i])
    min_real_wof_dk[i] = which.min(dk_real_wof[,i])
    max_real_wof_dk[i] = which.max(dk_real_wof[,i])
    min_abs_wof_es[i] = which.min(es_abs_wof[,i])
    min_real_wof_es[i] = which.min(es_real_wof[,i])
    max_real_wof_es[i] = which.max(es_real_wof[,i])
    min_abs_wof_fr[i] = which.min(fr_abs_wof[,i])
    min_real_wof_fr[i] = which.min(fr_real_wof[,i])
    max_real_wof_fr[i] = which.max(fr_real_wof[,i])
    min_abs_wof_nl[i] = which.min(nl_abs_wof[,i])
    min_real_wof_nl[i] = which.min(nl_real_wof[,i])
    max_real_wof_nl[i] = which.max(nl_real_wof[,i])
    min_abs_wof_no[i] = which.min(no_abs_wof[,i])
    min_real_wof_no[i] = which.min(no_real_wof[,i])
    max_real_wof_no[i] = which.max(no_real_wof[,i])
    min_abs_wof_se[i] = which.min(se_abs_wof[,i])
    min_real_wof_se[i] = which.min(se_real_wof[,i])
    max_real_wof_se[i] = which.max(se_real_wof[,i])
    min_abs_wof_uk[i] = which.min(uk_abs_wof[,i])
    min_real_wof_uk[i] = which.min(uk_real_wof[,i])
    max_real_wof_uk[i] = which.max(uk_real_wof[,i])
}

TDY_at = vector("numeric",(12*720))
EHCF_at = vector("numeric",(12*720))
ELCF_at = vector("numeric",(12*720))
TDY_balt = vector("numeric",(12*720))
EHCF_balt = vector("numeric",(12*720))
ELCF_balt = vector("numeric",(12*720))
TDY_be = vector("numeric",(12*720))
EHCF_be = vector("numeric",(12*720))
ELCF_be = vector("numeric",(12*720))
TDY_de = vector("numeric",(12*720))
EHCF_de = vector("numeric",(12*720))
ELCF_de = vector("numeric",(12*720))
TDY_dk = vector("numeric",(12*720))
EHCF_dk = vector("numeric",(12*720))
ELCF_dk = vector("numeric",(12*720))
TDY_es = vector("numeric",(12*720))
EHCF_es = vector("numeric",(12*720))
ELCF_es = vector("numeric",(12*720))
TDY_fr = vector("numeric",(12*720))
EHCF_fr = vector("numeric",(12*720))
ELCF_fr = vector("numeric",(12*720))
TDY_nl = vector("numeric",(12*720))
EHCF_nl = vector("numeric",(12*720))
ELCF_nl = vector("numeric",(12*720))
TDY_no = vector("numeric",(12*720))
EHCF_no = vector("numeric",(12*720))
ELCF_no = vector("numeric",(12*720))
TDY_se = vector("numeric",(12*720))
EHCF_se = vector("numeric",(12*720))
ELCF_se = vector("numeric",(12*720))
TDY_uk = vector("numeric",(12*720))
EHCF_uk = vector("numeric",(12*720))
ELCF_uk = vector("numeric",(12*720))
for(i in 1:12){
    TDY_at[((i-1)*720+1):(i*720)] = wof_at[min_abs_wof_at[i], ((i-1)*720+1):(i*720)]
    EHCF_at[((i-1)*720+1):(i*720)] = wof_at[min_real_wof_at[i], ((i-1)*720+1):(i*720)]
    ELCF_at[((i-1)*720+1):(i*720)] = wof_at[max_real_wof_at[i], ((i-1)*720+1):(i*720)]
    TDY_balt[((i-1)*720+1):(i*720)] = wof_balt[min_abs_wof_balt[i], ((i-1)*720+1):(i*720)]
    EHCF_balt[((i-1)*720+1):(i*720)] = wof_balt[min_real_wof_balt[i], ((i-1)*720+1):(i*720)]
    ELCF_balt[((i-1)*720+1):(i*720)] = wof_balt[max_real_wof_balt[i], ((i-1)*720+1):(i*720)]
    TDY_be[((i-1)*720+1):(i*720)] = wof_be[min_abs_wof_be[i], ((i-1)*720+1):(i*720)]
    EHCF_be[((i-1)*720+1):(i*720)] = wof_be[min_real_wof_be[i], ((i-1)*720+1):(i*720)]
    ELCF_be[((i-1)*720+1):(i*720)] = wof_be[max_real_wof_be[i], ((i-1)*720+1):(i*720)]
    TDY_de[((i-1)*720+1):(i*720)] = wof_de[min_abs_wof_de[i], ((i-1)*720+1):(i*720)]
    EHCF_de[((i-1)*720+1):(i*720)] = wof_de[min_real_wof_de[i], ((i-1)*720+1):(i*720)]
    ELCF_de[((i-1)*720+1):(i*720)] = wof_de[max_real_wof_de[i], ((i-1)*720+1):(i*720)]
    TDY_dk[((i-1)*720+1):(i*720)] = wof_dk[min_abs_wof_dk[i], ((i-1)*720+1):(i*720)]
    EHCF_dk[((i-1)*720+1):(i*720)] = wof_dk[min_real_wof_dk[i], ((i-1)*720+1):(i*720)]
    ELCF_dk[((i-1)*720+1):(i*720)] = wof_dk[max_real_wof_dk[i], ((i-1)*720+1):(i*720)]
    TDY_es[((i-1)*720+1):(i*720)] = wof_es[min_abs_wof_es[i], ((i-1)*720+1):(i*720)]
    EHCF_es[((i-1)*720+1):(i*720)] = wof_es[min_real_wof_es[i], ((i-1)*720+1):(i*720)]
    ELCF_es[((i-1)*720+1):(i*720)] = wof_es[max_real_wof_es[i], ((i-1)*720+1):(i*720)]
    TDY_fr[((i-1)*720+1):(i*720)] = wof_fr[min_abs_wof_fr[i], ((i-1)*720+1):(i*720)]
    EHCF_fr[((i-1)*720+1):(i*720)] = wof_fr[min_real_wof_fr[i], ((i-1)*720+1):(i*720)]
    ELCF_fr[((i-1)*720+1):(i*720)] = wof_fr[max_real_wof_fr[i], ((i-1)*720+1):(i*720)]
    TDY_nl[((i-1)*720+1):(i*720)] = wof_nl[min_abs_wof_nl[i], ((i-1)*720+1):(i*720)]
    EHCF_nl[((i-1)*720+1):(i*720)] = wof_nl[min_real_wof_nl[i], ((i-1)*720+1):(i*720)]
    ELCF_nl[((i-1)*720+1):(i*720)] = wof_nl[max_real_wof_nl[i], ((i-1)*720+1):(i*720)]
    TDY_no[((i-1)*720+1):(i*720)] = wof_no[min_abs_wof_no[i], ((i-1)*720+1):(i*720)]
    EHCF_no[((i-1)*720+1):(i*720)] = wof_no[min_real_wof_no[i], ((i-1)*720+1):(i*720)]
    ELCF_no[((i-1)*720+1):(i*720)] = wof_no[max_real_wof_no[i], ((i-1)*720+1):(i*720)]
    TDY_se[((i-1)*720+1):(i*720)] = wof_se[min_abs_wof_se[i], ((i-1)*720+1):(i*720)]
    EHCF_se[((i-1)*720+1):(i*720)] = wof_se[min_real_wof_se[i], ((i-1)*720+1):(i*720)]
    ELCF_se[((i-1)*720+1):(i*720)] = wof_se[max_real_wof_se[i], ((i-1)*720+1):(i*720)]
    TDY_uk[((i-1)*720+1):(i*720)] = wof_uk[min_abs_wof_uk[i], ((i-1)*720+1):(i*720)]
    EHCF_uk[((i-1)*720+1):(i*720)] = wof_uk[min_real_wof_uk[i], ((i-1)*720+1):(i*720)]
    ELCF_uk[((i-1)*720+1):(i*720)] = wof_uk[max_real_wof_uk[i], ((i-1)*720+1):(i*720)]
}

Fn = ecdf(wof_uk[1,])
x_min = min(wof_uk)
x_max = max(wof_uk)
plot(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="at_wof_capacity_factor",ylab="CDF",col='grey')
legend(0.6, 0.7, legend=c("real", "TDY","EHCF","ELCF"),col=c("grey", "black","red","blue"), lty=1:2, cex=0.8)
for(i in 2:71){
    Fn = ecdf(wof_uk[i,])
    points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col='grey')
}
Fn = ecdf(TDY_uk)
x_min = min(TDY_uk)
x_max = max(TDY_uk)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="black")
Fn = ecdf(EHCF_uk)
x_min = min(EHCF_uk)
x_max = max(EHCF_uk)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="red",type='l')
Fn = ecdf(ELCF_uk)
x_min = min(ELCF_uk)
x_max = max(ELCF_uk)
points(seq(x_min,x_max,length=200),Fn(seq(x_min,x_max,length=200)),xlab="",ylab="",col="blue",type='l')

syn_at = matrix(NA, ncol=3, nrow=12*30*24)
syn_balt = matrix(NA, ncol=3, nrow=12*30*24)
syn_be = matrix(NA, ncol=3, nrow=12*30*24)
syn_de = matrix(NA, ncol=3, nrow=12*30*24)
syn_dk = matrix(NA, ncol=3, nrow=12*30*24)
syn_es = matrix(NA, ncol=3, nrow=12*30*24)
syn_fr = matrix(NA, ncol=3, nrow=12*30*24)
syn_nl = matrix(NA, ncol=3, nrow=12*30*24)
syn_no = matrix(NA, ncol=3, nrow=12*30*24)
syn_se = matrix(NA, ncol=3, nrow=12*30*24)
syn_uk = matrix(NA, ncol=3, nrow=12*30*24)

# save data as table
tab_wof_TDY <- matrix(c(TDY_at,TDY_balt,TDY_be,TDY_de,TDY_dk,TDY_es,TDY_fr,TDY_nl,TDY_no,TDY_se,TDY_uk), ncol=11, byrow=FALSE)
colnames(tab_wof_TDY) <- c('wof_TDY_at','wof_TDY_balt','wof_TDY_be','wof_TDY_de','wof_TDY_dk','wof_TDY_es','wof_TDY_fr','wof_TDY_nl','wof_TDY_no','wof_TDY_se','wof_TDY_uk')
tab_wof_TDY <- as.table(tab_wof_TDY)

tab_wof_EHCF<- matrix(c(EHCF_at,EHCF_balt,EHCF_be,EHCF_de,EHCF_dk,EHCF_es,EHCF_fr,EHCF_nl,EHCF_no,EHCF_se,EHCF_uk), ncol=11, byrow=FALSE)
colnames(tab_wof_EHCF) <- c('wof_EHCF_at','wof_EHCF_balt','wof_EHCF_be','wof_EHCF_de','wof_EHCF_dk','wof_EHCF_es','wof_EHCF_fr','wof_EHCF_nl','wof_EHCF_no','wof_EHCF_se','wof_EHCF_uk')
tab_wof_EHCF <- as.table(tab_wof_EHCF)

tab_wof_ELCF<- matrix(c(ELCF_at,ELCF_balt,ELCF_be,ELCF_de,ELCF_dk,ELCF_es,ELCF_fr,ELCF_nl,ELCF_no,ELCF_se,ELCF_uk), ncol=11, byrow=FALSE)
colnames(tab_wof_ELCF) <- c('wof_ELCF_at','wof_ELCF_balt','wof_ELCF_be','wof_ELCF_de','wof_ELCF_dk','wof_ELCF_es','wof_ELCF_fr','wof_ELCF_nl','wof_ELCF_no','wof_ELCF_se','wof_ELCF_uk')
tab_wof_ELCF <- as.table(tab_wof_ELCF)

write.table(tab_wof_TDY,"~/Documents/InfraTrain_School/Project/syn_wof_TDY.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_wof_EHCF,"~/Documents/InfraTrain_School/Project/syn_wof_EHCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
write.table(tab_wof_ELCF,"~/Documents/InfraTrain_School/Project/syn_wof_ELCF.txt",col.names=TRUE,row.names=FALSE,sep="\t")
