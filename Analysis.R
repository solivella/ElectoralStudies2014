####################################
## This script estimates models
## for the Slovakia Votes-Discipline
## tradeoff paper.
##
## Author: Santiago Olivella
##         (olivella@wustl.edu)
## Date: March 2012
####################################
rm(list=ls())
setwd("~/Dropbox/Slovakia/")
library(MASS)
library(lme4)

par(mar=c(c(7, 7, 4, 2) + 0.1))

confint <- function(model,level=0.95,s4=FALSE){
  if(s4==TRUE){
    return(apply(summary(model)@coefs,1,function(x){x[1]+c(-1,+1)*qnorm(level)*x[2]}))
  }else{
    return(apply(summary(model)$coef,1,function(x){x[1]+c(-1,+1)*qnorm(level)*x[2]}))
  }
}



# Get data
ElecLegis <- read.csv("newSlovakiaFull.csv")
meanDisc <- tapply(scale(ElecLegis$Discipline),list(Party=ElecLegis$Party,Term=ElecLegis$Term),mean,na.rm=TRUE)
meanDiscLong <- data.frame(MeanDisc=do.call(rbind,as.list(meanDisc)))
meanDiscLong$Party<-rep(rownames(meanDisc),times=2) 
meanDiscLong$Term <- rep(c(2002,2006),each=12)
ElecLegis <- merge(ElecLegis,meanDiscLong)
ElecLegis$PartyTerm <- with(ElecLegis,paste(PartyName,Term,sep=" "))
ElecLegis$RiceDesposato[ElecLegis$PartyName=="PSNS"&ElecLegis$Term==2002] <-1

ElecLegis <- subset(ElecLegis,rownames(ElecLegis)!=6&rownames(ElecLegis)!=19&rownames(ElecLegis)!=61)
ElecLegis$LogPrefVotes <- log(ElecLegis$PrefVotes)
ElecLegis$PartySeats_next <- ave(ElecLegis$PartySeats_next,ElecLegis$PartyTerm,FUN=function(x)mean(x,na.rm=TRUE))

# From Preference Votes to list ranks
# Ordered Probit:
ElecLegis$cut.Rank_next <- cut(ElecLegis$InitialRank_next,
                              c(0,5,13,26,150)
                              ,ordered_result=TRUE)
placeModelOP <- polr(cut.Rank_next  
                  ~scale(LogPrefVotes)
                   +scale(Discipline)
                   + PartyName
                   + as.factor(Term)
                   + scale(InitialRank)
                   #+ scale(GearysC)
                   + scale(things.sponsored)
                   ,Hess=TRUE
                   ,method="probit"
                   ,data=subset(ElecLegis,Switched==0)
                   )
  summary(placeModelOP)

##Negative Binomial
placeModelNB <- glm.nb(InitialRank_next
                     ~ scale(LogPrefVotes)
                       + scale(Discipline)
                     + PartyName
                     + as.factor(Term)
                     + scale(InitialRank)
                     #+ scale(GearysC)
                     + scale(things.sponsored)
                    #,family=poisson()
                     ,data=subset(ElecLegis,Switched==0)
                     )
summary(placeModelNB)

###For reviewer purposes:
## Negative Binomial: Retirees assigned 1+ previous seats
ElecLegisC1 <- ElecLegis
ElecLegisC1$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC1$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),ElecLegis$PartySeats+1,ElecLegis$InitialRank_next)
placeModelNBC1 <- glm.nb(InitialRank_next
                       ~ scale(LogPrefVotes)
                       + scale(Discipline)
                       + PartyName
                       + as.factor(Term)
                       + scale(InitialRank)
                       #+ scale(GearysC)
                       + scale(things.sponsored)
                       #,family=poisson()
                       ,data=subset(ElecLegisC1,Switched==0)
)
summary(placeModelNBC1)

## Negative Binomial: Retirees assigned 1 + next party seats
ElecLegisC3 <- ElecLegis
ElecLegisC3$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC3$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),ElecLegis$PartySeats_next+1,ElecLegis$InitialRank_next)
placeModelNBC3 <- glm.nb(InitialRank_next
                         ~ scale(LogPrefVotes)
                         + scale(Discipline)
                         + PartyName
                         + as.factor(Term)
                         + scale(InitialRank)
                         #+ scale(GearysC)
                         + scale(things.sponsored)
                         #,family=poisson()
                         ,data=subset(ElecLegisC3,Switched==0)
)
summary(placeModelNBC3)


## Negative Binomial: Retirees assigned 75
ElecLegisC2 <- ElecLegis
ElecLegisC2$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC2$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),75,ElecLegis$InitialRank_next)
placeModelNBC2 <- glm.nb(InitialRank_next
                       ~ scale(LogPrefVotes)
                       + scale(Discipline)
                       + PartyName
                       + as.factor(Term)
                       + scale(InitialRank)
                      # + scale(GearysC)
                       + scale(things.sponsored)
                       #,family=poisson()
                       ,data=subset(ElecLegisC2,Switched==0)
)
summary(placeModelNBC2)

# Ordered Probit: Retirees assigned 1+ previous seats
ElecLegisC4 <- ElecLegis
ElecLegisC4$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC4$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),ElecLegis$PartySeats+1,ElecLegis$InitialRank_next)
ElecLegisC4$cut.Rank_next <- cut(ElecLegisC4$InitialRank_next,
                               c(0,5,13,26,150)
                               ,ordered_result=TRUE)
placeModelOPC4 <- polr(cut.Rank_next  
                     ~scale(LogPrefVotes)
                     +scale(Discipline)
                     + PartyName
                     + as.factor(Term)
                     + scale(InitialRank)
                     #+ scale(GearysC)
                     + scale(things.sponsored)
                     ,Hess=TRUE
                     ,method="probit"
                     ,data=subset(ElecLegisC4,Switched==0)
)
summary(placeModelOPC4)
# Ordered Probit: Retirees assigned 1+ next party seats
ElecLegisC6 <- ElecLegis
ElecLegisC6$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC6$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),ElecLegis$PartySeats_next+1,ElecLegis$InitialRank_next)
ElecLegisC6$cut.Rank_next <- cut(ElecLegisC6$InitialRank_next,
                               c(0,5,13,26,150)
                               ,ordered_result=TRUE)
placeModelOPC6 <- polr(cut.Rank_next  
                     ~scale(LogPrefVotes)
                     +scale(Discipline)
                     + PartyName
                     + as.factor(Term)
                     + scale(InitialRank)
                     #+ scale(GearysC)
                     + scale(things.sponsored)
                     ,Hess=TRUE
                     ,method="probit"
                     ,data=subset(ElecLegisC6,Switched==0)
)
summary(placeModelOPC6)
# Ordered Probit: Retirees assigned 75th position
ElecLegisC5 <- ElecLegis
ElecLegisC5$Switched <- ifelse(is.na(ElecLegis$InitialRank_next),0,ElecLegis$Switched)
ElecLegisC5$InitialRank_next <- ifelse(is.na(ElecLegis$InitialRank_next),75,ElecLegis$InitialRank_next)
ElecLegisC5$cut.Rank_next <- cut(ElecLegisC5$InitialRank_next,
                               c(0,5,13,26,150)
                               ,ordered_result=TRUE)
placeModelOPC5 <- polr(cut.Rank_next  
                     ~scale(LogPrefVotes)
                     +scale(Discipline)
                     + PartyName
                     + as.factor(Term)
                     + scale(InitialRank)
                     #+ scale(GearysC)
                     + scale(things.sponsored)
                     ,Hess=TRUE
                     ,method="probit"
                     ,data=subset(ElecLegisC5,Switched==0)
)
summary(placeModelOPC5)


coefs <- cbind(coef(placeModelNBC1)
               ,coef(placeModelNBC2)
               ,coef(placeModelNBC3)
               ,c(NA,coef(placeModelOPC4))
               ,c(NA,coef(placeModelOPC5))
               ,c(NA,coef(placeModelOPC6)))
ses <- cbind(summary(placeModelNBC1)$coefficients[,2]
             ,summary(placeModelNBC2)$coefficients[,2]
             ,summary(placeModelNBC3)$coefficients[,2]
             ,c(NA,summary(placeModelOPC4)$coefficients[-c(13:15),2])
             ,c(NA,summary(placeModelOPC5)$coefficients[-c(13:15),2])
             ,c(NA,summary(placeModelOPC6)$coefficients[-c(13:15),2]))
extra.names <-c("(Intercept)"
                                ,"log(Preference Votes)"
                                ,"Discipline"
                                ,"\\qquad HZDS"
                                ,"\\qquad KDH"
                                ,"\\qquad KSS"
                                ,"\\qquad SDK\'U"
                                ,"\\qquad SMK"
                                ,"\\qquad SNS"
                                ,"\\qquad Smer"
                                ,"2006 Legislature"
                                ,"Previous List Position"
                                ,"Nr. of Bills Sponsored")
allcoefs <- array(NA,c(dim(coefs)[1]*2,6))
rownames.coefs <- array(NA,c(26,1))
for(i in 1:dim(coefs)[1]){
  allcoefs[i*2-1,] <- round(coefs[i,],2)
  allcoefs[i*2,] <- paste("(",round(ses[i,],2),")",sep="")
  rownames.coefs[i*2-1] <- extra.names[i]
  rownames.coefs[i*2] <- i
}
colnames(allcoefs) <- rep(c("1+ Previous Party Seats","75th","1+ Next Party Seats"),2)
allcoefs <-rbind(allcoefs,c(round(summary(placeModelNBC1)$theta,2)
                            ,round(summary(placeModelNBC2)$theta,2)
                            ,round(summary(placeModelNBC3)$theta,2),NA,NA,NA))
allcoefs <-rbind(allcoefs,c(round(summary(placeModelNBC1)$SE.theta,2)
                            ,round(summary(placeModelNBC2)$SE.theta,2)
                            ,round(summary(placeModelNBC3)$SE.theta,2),NA,NA,NA))
allcoefs <- rbind(allcoefs,rep(307,6))
allcoefs <- rbind(allcoefs,c(round(AIC(placeModelNBC1),2)
                             ,round(AIC(placeModelNBC2),2)
                             ,round(AIC(placeModelNBC3),2)
                             ,round(AIC(placeModelOPC4),2)
                             ,round(AIC(placeModelOPC5),2)
                             ,round(AIC(placeModelOPC6),2)))
allcoefs <- rbind(allcoefs,c(round(deviance(placeModelNBC1),2)
                              ,round(deviance(placeModelNBC2),2)
                              ,round(deviance(placeModelNBC3),2)
                              ,round(deviance(placeModelOPC4),2)
                              ,round(deviance(placeModelOPC5),2)
                              ,round(deviance(placeModelOPC6),2)))
rownames(allcoefs) <- c(rownames.coefs,"Dispersion $\theta$",14,"N","AIC","Residual Deviance")
xtable(allcoefs)
  
##Plot
unstd.pref <- function(x){
  with(ElecLegis,round(exp(x*sd(LogPrefVotes,na.rm=TRUE)+mean(LogPrefVotes,na.rm=TRUE))))
}

simPref <- seq(min(scale(ElecLegis$LogPrefVotes),na.rm=TRUE)
               ,max(scale(ElecLegis$LogPrefVotes),na.rm=TRUE)
               ,length.out=1000)
new.data <- cbind(simPref
                  ,0
                       ,0
                       ,0
                       ,0
                       ,0
                       ,0
                       ,0
                       ,1
                       ,0
                       ,0
                       ,0
                       ,0
                  )
pred.means <- new.data%*%placeModelOP$coefficients
pred.probs1 <- apply(t(pred.means),2,function(x){pnorm(placeModelOP$zeta[1],x,1)})
pred.probs2 <- apply(t(pred.means),2,function(x){pnorm(placeModelOP$zeta[2],x,1)})
pred.probs3 <- apply(t(pred.means),2,function(x){pnorm(placeModelOP$zeta[3],x,1)})

plot(pred.probs1~simPref
     ,type="n"
     ,ylim=c(0,1)
     ,xlab="Preference Votes"
     ,ylab="Cumulative Probability"
     ,axes=FALSE
     ,mgp=c(4,1,0)
     )
polygon(c(simPref,rev(simPref)),
        c(rep(0,1000),rev(pred.probs1)),
        col="gray60",border="black")
polygon(c(simPref,rev(simPref)),
        c(pred.probs1,rev(pred.probs2)),
        col="gray40",border="black")
polygon(c(simPref,rev(simPref)),
        c(pred.probs2,rev(pred.probs3)),
        col="gray60",border="black")
polygon(c(simPref,rev(simPref)),
        c(pred.probs3,rep(1,1000)),
        col="gray40",border="black")
axis(1,at=c(-2,-1,0,1,2,3)
     ,labels=unstd.pref(c(-2,-1,0,1,2,3)))
axis(2,las=1)
text(x=c(-1,0,1.8,2.1)
     ,y=c(.83,.5,.35,.08),
     ,labels=c("Position > 27","14 < Position < 26","6 < Position < 13","Position < 5")
     ,col="white"
     ,font=2
     ,cex=1.35)


## Plot negative binomial model
coef.samples <- mvrnorm(2000,coef(placeModelNB),vcov(placeModelNB))
pred.locs <- cbind(1,new.data)%*%t(coef.samples)
point.est.pos <- exp(apply(pred.locs,1,quantile,probs=c(0.5)))
lo.est.pos <- exp(apply(pred.locs,1,quantile,probs=c(0.05)))
hi.est.pos <- exp(apply(pred.locs,1,quantile,probs=c(0.95)))
plot(point.est.pos~simPref
     ,type="n"
     ,ylim=c(min(lo.est.pos),max(hi.est.pos))
     ,xlab="Preference Votes"
     ,ylab="List Position"
     ,axes=FALSE
     ,mgp=c(4,1,0)
     )
polygon(c(simPref,rev(simPref)),
        c(hi.est.pos,rev(lo.est.pos)),
        col="gray70",border=NA)
axis(1,at=c(-2,-1,0,1,2,3)
     ,labels=unstd.pref(c(-2,-1,0,1,2,3)))
axis(2,las=2)
lines(point.est.pos~simPref,
      type='l',
      lwd=2.3,
      col="white")


### MLM: From Discipline to Preference votes   
ElecLegis$PartyTerm_next <- with(ElecLegis,paste(PartyName,(Term+4),sep=" "))

mean.discipline <- with(subset(ElecLegis#,Switched==0
                               ),tapply(RiceDesposato,PartyTerm_next,mean,na.rm=TRUE))
mean.prefvotes <- with(subset(ElecLegis#,Switched==0
                              ),tapply(log(PrefVotes_next),PartyTerm_next,mean,na.rm=TRUE))
cor(mean.discipline,mean.prefvotes)


prefModel <- lmer(log(PrefVotes_next)~                     
                     scale(RiceDesposato) #PartyTerm level predictor
                     + (1|PartyTerm)
                    + scale(Discipline)
                  + scale(things.sponsored)
                    + scale(InitialRank_next)
                    + scale(GearysC_next)
                    + Switched
                    - 1
                     ,data=subset(ElecLegis
                                  )
                     )
summary(prefModel)

rand.int <- lme4::ranef(prefModel)$PartyTerm[,1]
plot(rand.int~mean.discipline
     ,type="n"
     ,xlim=c(0.6,1.05)
     ,xlab="Party Discipline (Size-Adjusted Rice Score)"
     ,ylab="Average Nr. of Preference Votes"
     ,log="y"
     ,axes=FALSE
     ,mgp=c(5,1,0)
     )
axis(1)
axis(2,labels=round(exp(c(6.5,7,8,9,10)))
     ,at=c(6.5,7,8,9,10)
     ,cex.axis=1
     ,las=2
     )
lines(loess.smooth(mean.discipline
                   ,rand.int,degree=2)
      ,lwd=2
      ,col="gray70"
      )
text(mean.discipline
     ,rand.int
     ,labels=names(mean.discipline)
     ,cex=0.8
     )
text(mean.discipline
     ,rand.int
     ,labels=names(mean.discipline)
     ,cex=0.8
     )


##### Plot Effect of Discipline
unstd.disc <- function(x){
  with(ElecLegis,x*sd(Discipline,na.rm=TRUE)+mean(Discipline,na.rm=TRUE))
}
sim.disc <- with(ElecLegis,seq(min(scale(Discipline),na.rm=TRUE)
                                   ,max(scale(Discipline),na.rm=TRUE)
                                        ,length.out=1e3))
sim.x <- cbind(lme4::ranef(prefModel)$PartyTerm[6,1]
                  ,0
                  ,sim.disc
                  #,sim.disc^2
                  ,0
                  ,0
                  ,0
               ,0
                  )
samp.betas <- cbind(1,mvrnorm(2e3,lme4::fixef(prefModel),vcov(prefModel)))

samp.preds <- sim.x%*%t(samp.betas)

point.pred <- exp(apply(samp.preds,1,quantile,probs=c(0.5)))
lo.pred <- exp(apply(samp.preds,1,quantile,probs=c(0.1)))
hi.pred <- exp(apply(samp.preds,1,quantile,probs=c(0.9)))
plot(point.pred~sim.disc
  ,type="n"
  ,ylim=c(min(lo.pred),max(hi.pred))
  ,xlab="Individual Discipline"
  ,ylab="Nr. of Preference Votes"
  ,axes=FALSE
  ,mgp=c(5,1,0)
     )
polygon(c(sim.disc,rev(sim.disc)),
  c(hi.pred,rev(lo.pred)),
  col="gray70",border=NA)
axis(1,at=c(-3,-2,-1,0,1)
     ,labels=round(unstd.disc(c(-3,-2,-1,0,1)),2))
axis(2,las=2)
lines(point.pred~sim.disc,
  type='l',
  lwd=2.3,
  col="white"
      )


#### Formal model
ind.curves <- function(p,seats){
  return(seats/p)
}

curve(ind.curves(x,seats=2)
      ,from=0
      ,to=1
      ,ylim=c(2,150)
      ,xlim=c(0,1.1)
      ,axes=FALSE
      ,xlab="Average Discipline"
      ,ylab="Number of Seats")
for(i in seq(12,75,by=10)){
  curve(ind.curves(x,seats=i),from=0,to=1,add=TRUE)
}
axis(1)
axis(2)
text(rep(1.02,9),seq(2,75,by=10),seq(2,75,by=10),cex=0.6)
