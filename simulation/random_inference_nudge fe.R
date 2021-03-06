rm(list = ls())

library(plyr)
library(dplyr)
library(randomizr)
library(sandwich) #cluster standard errors after lm
library(lmtest)
library(ggplot2)
library(lattice)
library(devtools) #developers tools
library(extrafont)
library(reshape)
library(lme4) #linear mixed models
library(lmerTest) #test in linear mixed models
library(wesanderson) #Color palette
library(QuantPsyc)
library(ri2) #Randomization inference
library(plm) #Panel data linear models
library(xts) #Panel data
# For linear combinations
library(foreign)
library(mvtnorm)
library(multcomp) #linear combination
#graph coefficients
library(coefplot)
#Tables in LATEx
library(stargazer)
library(tidyverse) #Read csv
library(blockTools) ## Multivariate randomization

detach(data)
setwd("~/Documents/GitHub/spreading_the_word") #mac
data<- read_csv("data_adjusted.csv") #Load data
data <- pdata.frame(data, index=c("hh","time_bi"))
attach(data)
setwd("~/Documents/GitHub/spreading_the_word/simulation")

#Observed Effects  -------------------------------------------------------------
## Pooled Model ----------------------------------------------------------------
## Homogeneous treatment effects on the treated.
obs.all <- plm(cons_adj_bi ~ d_post + i_post +
                 as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill), 
               data=data, model = "within")
summary(obs.all)
### Saving coefficients and standard errors
beta.obs.all <- matrix(NA, nrow=2, ncol = 1) #Save estimates
colnames(beta.obs.all) <- c("estimate")
rownames(beta.obs.all) <- c("Direct","Spillover")

se.obs.all <- matrix(NA, nrow=2, ncol = 1) #Save estimates
colnames(se.obs.all) <- c("se")
rownames(se.obs.all) <- c("Direct","Spillover")

for (l in 1:2){
  beta.obs.all[l,1] <- summary(obs.all)$coefficients[l,1]
  se.obs.all[l,1] <- summary(obs.all)$coefficients[l,2]
}

## Sloped Model ----------------------------------------------------------------
## Treatment effects by level of saturation.

obs.all.sat <- plm(cons_adj_bi ~ + d_sat1 + d_sat2 + d_sat3 +
                     i_sat1 + i_sat2 + i_sat3 +
                     as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),
                   data = data, model = "within")

coef.all.sat<- coeftest(obs.all.sat, vcov = vcovHC(obs.all.sat, "HC1", method="white2"), cluster="village")

### Saving coefficients and standard errors
beta.obs.all.sat <- matrix(NA, nrow=6, ncol = 1) #Save estimates
colnames(beta.obs.all.sat) <- c("estimate")
rownames(beta.obs.all.sat) <- c("Direct 25", "Direct 50","Direct 75",
                                "Spillover 25","Spillover 50","Spillover 75")
se.obs.all.sat <- matrix(NA, nrow=6, ncol = 1) #Save se
colnames(se.obs.all.sat) <- c("se")
rownames(se.obs.all.sat) <- c("Direct 25", "Direct 50","Direct 75",
                                "Spillover 25","Spillover 50","Spillover 75")

for (l in 1:6) {
  beta.obs.all.sat[l,1] <- summary(obs.all.sat)$coefficients[l,1]
  se.obs.all.sat[l,1] <- summary(obs.all.sat)$coefficients[l,2]
}

## Pooled Model by Billing frequency-------------------------------------------------------
## Treatment effects by billing frequency group.

obs.bill <- plm(cons_adj_bi ~ d_post_bill1 +i_post_bill1 +
                  d_post_bill2 + i_post_bill2 + post_bill +
                  as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),
                data=data, model = "within")

coef.bill <- coeftest(obs.bill, vcov = vcovHC(obs.bill, "HC1", method="white2"), cluster="village")

### Saving coefficients and standard errors
beta.obs.bill <- matrix(NA, nrow=4, ncol = 1) #Save estimates
colnames(beta.obs.bill) <- c("estimate")
rownames(beta.obs.bill) <- c("Direct M","Spillover M","Direct B","Spillover B")

se.obs.bill <- matrix(NA, nrow=4, ncol = 1) #Save estimates
colnames(se.obs.bill) <- c("se")
rownames(se.obs.bill) <- c("Direct M","Spillover M","Direct B","Spillover B")

for (l in 1:4) {
  beta.obs.bill[l,1] <- summary(obs.bill)$coefficients[l,1]
  se.obs.bill[1,] <- summary(obs.bill)$coefficients[l,2]
}

## Sloped Model by billing frequency -------------------------------------------
## Treatment effects by billing frequency group and level of saturation.

obs.bill.sat <- plm(cons_adj_bi ~ d_sat_bill2  + i_sat_bill2 +
                        d_sat_bill3  + i_sat_bill3 +
                        d_sat_bill4  + i_sat_bill4 +
                        d_sat_bill5  + i_sat_bill5 +
                        d_sat_bill6  + i_sat_bill6 +
                        d_sat_bill7  + i_sat_bill7 + post_bill +
                        as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),
                      data = data, model = "within")

summary(obs.bill.sat)
coef.bill.sat <- coeftest(obs.bill.sat, vcov = vcovHC(obs.bill.sat, "HC1", method="white2"), cluster="village")

### Saving coefficients and se
beta.obs.bill.sat <- matrix(NA, nrow=12, ncol = 1) #Save estimates
colnames(beta.obs.bill.sat) <- c("estimate")
rownames(beta.obs.bill.sat) <- c("Direct M 25","Spillover M 25", "Direct M 50",
                                 "Spillover M 50","Direct M 75","Spillover M 75",
                                 "Direct B 25","Spillover B 25","Direct B 50",
                                 "Spillover B 50","Direct B 75","Spillover B 75")

se.obs.bill.sat <- matrix(NA, nrow=12, ncol = 1) #Save estimates
colnames(se.obs.bill.sat) <- c("se")
rownames(se.obs.bill.sat) <- c("Direct M 25","Spillover M 25", "Direct M 50",
                               "Spillover M 50","Direct M 75","Spillover M 75",
                               "Direct B 25","Spillover B 25","Direct B 50",
                               "Spillover B 50","Direct B 75","Spillover B 75")

for (l in 1:12) {
  beta.obs.bill.sat[l,] <- coef.bill.sat[l,1]
  se.obs.bill.sat[l,] <- coef.bill.sat[l,2] #direct 25
}

# Creating variables and matrix to save results of the simulation --------------
sims <- 20000

## Matrix of saturation
pi <- matrix(c(1,0,0,    
                 0,0.25,0.75,    
                 0,0.501,0.499, 
                 0,0.75,0.25),
               nrow = 4, byrow=T)
### Pooled Estimates
beta.all <- matrix(NA, nrow=sims, ncol = 2) #coeficients
colnames(beta.all) <- c("Direct","Spillover")
se.all <- matrix(NA, nrow=sims, ncol = 2) #p-values
colnames(se.all) <- c("Direct","Spillover")
### Pooled Bill Estimates
beta.bill <- matrix(NA, nrow=sims, ncol = 4) #coeficients
colnames(beta.bill) <- c("Direct M","Spillover M","Direct B","Spillover B")
se.bill <- matrix(NA, nrow=sims, ncol = 4) #coeficients
colnames(se.bill) <- c("Direct M","Spillover M","Direct B","Spillover B")
### Sloped Estimates
beta.all.sat <- matrix(NA, nrow=sims, ncol = 6) #Save estimates
colnames(beta.all.sat) <- c("Direct 25", "Direct 50","Direct 75",
                            "Spillover 25","Spillover 50","Spillover 75")
se.all.sat <- matrix(NA, nrow=sims, ncol = 6) #Save estimates
colnames(se.all.sat) <-  c("Direct 25", "Direct 50","Direct 75",
                             "Spillover 25","Spillover 50","Spillover 75")
### Sloped Bill Estimates
beta.bill.sat <- matrix(NA, nrow=sims, ncol = 12) #coeficients
colnames(beta.bill.sat) <- c("Direct M 25", "Direct M 50","Direct M 75",
                             "Spillover M 25","Spillover M 50","Spillover M 75",
                             "Direct B 25", "Direct B 50","Direct B 75",
                             "Spillover B 25","Spillover B 50","Spillover B 75")
se.bill.sat <- matrix(NA, nrow=sims, ncol = 12) #coeficients
colnames(se.bill.sat) <- c("Direct M 25", "Direct M 50","Direct M 75",
                             "Spillover M 25","Spillover M 50","Spillover M 75",
                             "Direct B 25", "Direct B 50","Direct B 75",
                             "Spillover B 25","Spillover B 50","Spillover B 75")
### Number of Observations
nobs <-matrix(NA, nrow=sims, ncol = 3) #Number of observations per treatment status 
colnames(nobs) <- c("PC","T","S")

### Matrix to save simulated coefficients
all.test.stat <- matrix(NA, nrow=2, ncol = 1)
colnames(all.test.stat) <- c("ttest")
rownames(all.test.stat) <- c("Direct","Spillover")

all.sat.test.stat <- matrix(NA, nrow=6, ncol = 1)
colnames(all.sat.test.stat) <- c("ttest")
rownames(all.sat.test.stat) <- c("Direct 25", "Direct 50","Direct 75",
                                 "Spillover 25","Spillover 50","Spillover 75")
bill.test.stat <- matrix(NA, nrow=4, ncol = 1)
colnames(bill.test.stat) <- c("ttest")
rownames(bill.test.stat) <- c("Direct M","Spillover M","Direct B","Spillover B")

bill.sat.test.stat <- matrix(NA, nrow=12, ncol = 1)
colnames(bill.sat.test.stat) <- c("ttest")
rownames(bill.sat.test.stat) <- c("Direct M 25", "Direct M 50","Direct M 75",
                                  "Spillover M 25","Spillover M 50","Spillover M 75",
                                  "Direct B 25", "Direct B 50","Direct B 75",
                                  "Spillover B 25","Spillover B 50","Spillover B 75")

## Simulation ------------------------------------------------------------
set.seed(10111)

for(l in 1:sims){
  
  # Village level randomization. It is a block and cluster design, where the
  # block variable is the billing frequency and the cluster variable is villages
  # The are four levels of saturation: 0%, 25% 50%, and 75%, with equal probabilities.
  
  declaration_level_1 <- declare_ra(blocks=bill,clusters=village,
                                    conditions=c("0%","25%","50%","75%"))
  
  assignment_village <- conduct_ra(declaration_level_1) 
  
  # Subset of villages to assign treatment to households according to the level of
  # saturation in the first stage of the experiment and stratified by SES distribution.
  
  m_0 <- 
    data %>%
    filter(assignment_village=="0%" & bill==0) %>%
    mutate(t_status="C")
  
  m_25 <- 
    data %>%
    filter(assignment_village=="25%" & bill==0)
  declare_m_25 <- 
    with(m_25,{declare_ra(blocks=ses, prob_each = c(.75, .25),conditions = c("T","S"))
    })
  t_m_25 <- conduct_ra(declare_m_25)
  table(t_m_25,m_25$ses)
  m_25 <- m_25 %>%
    mutate(t_status=t_m_25)
  
  m_50 <- 
    data %>%
    filter(assignment_village=="50%" & bill==0)
  declare_m_50 <- 
    with(m_50,{declare_ra(blocks=ses, prob_each = c(.5, .5),conditions = c("T","S"))
    })
  t_m_50 <- conduct_ra(declare_m_50)
  table(t_m_50,m_50$ses)
  m_50 <- m_50 %>%
    mutate(t_status=t_m_50)
  
  m_75 <- 
    data %>%
    filter(assignment_village=="75%" & bill==0)
  declare_m_75 <-
    with(m_75,{declare_ra(blocks=ses, prob_each = c(.25, .75),conditions = c("T","S"))
    })
  t_m_75 <- conduct_ra(declare_m_75)
  table(t_m_75,m_75$ses)
  m_75 <- m_75 %>%
    mutate(t_status=t_m_75)
  
      ### Every 60 days
  b_0 <- 
    data %>%
    filter(assignment_village=="0%" & bill==1) %>%
    mutate(t_status="C")
  
  b_25 <- 
    data %>%
    filter(assignment_village=="25%" & bill==1)
  declare_b_25 <- 
    with(b_25,{declare_ra(blocks=ses, prob_each = c(.75, .25),conditions = c("T","S"))
    })
  t_b_25 <- conduct_ra(declare_b_25)
  table(t_b_25,b_25$ses)
  b_25 <- b_25 %>%
    mutate(t_status=t_b_25)
  
  b_50 <- 
    data %>%
    filter(assignment_village=="50%" & bill==1)
  declare_b_50 <-
    with(b_50,{declare_ra(blocks=ses, prob_each = c(.5, .5),conditions = c("T","S")) 
    })
  t_b_50 <- conduct_ra(declare_b_50)
  table(t_b_50,b_50$ses)
  b_50 <- b_50 %>%
    mutate(t_status=t_b_50)
  
  b_75 <- 
    data %>%
    filter(assignment_village=="75%" & bill==1)
  declare_b_75 <- 
    with(b_75,{
      declare_ra(blocks=ses, prob_each = c(.25, .75),conditions = c("T","S"))
      })
  t_b_75 <- conduct_ra(declare_b_75)
  table(t_b_75,b_75$ses)
  b_75 <- b_75 %>%
    mutate(t_status=t_b_75)
  
  data_treatment <- bind_rows(m_0,m_25,m_50,m_75,b_0,b_25,b_50,b_75)
  
  ## Treatment indicators
  direct <- with(data_treatment,{as.numeric(t_status=="T")})
  spill <- with(data_treatment,{as.numeric(t_status=="S")})
  
  ## Post-Treatment indicators
  direct_post <- post*direct
  spill_post <- post*spill

  ## Pooled Model
  ### Given that de random assignments are infinite, I adjusted the regression by IPW
  model.all <- plm(cons_adj_bi ~ direct_post + spill_post +
                     as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),  
                      data=data_treatment, model = "within")

  beta.all[l,1] <- summary(model.all)$coefficients[1,1]
  beta.all[l,2] <- summary(model.all)$coefficients[2,1]
  se.all[l,1] <- summary(model.all)$coefficients[1,2]
  se.all[l,2] <- summary(model.all)$coefficients[2,2]
  
  ## all with saturation
  ### Post-Treatment indicators
  direct_post_sat1 <- post*direct*as.numeric(assignment_village=="25%")
  direct_post_sat2 <- post*direct*as.numeric(assignment_village=="50%")
  direct_post_sat3 <- post*direct*as.numeric(assignment_village=="75%")
  
  spill_post_sat1 <- post*spill*as.numeric(assignment_village=="25%")
  spill_post_sat2 <- post*spill*as.numeric(assignment_village=="50%")
  spill_post_sat3 <- post*spill*as.numeric(assignment_village=="75%")
  
  ### Estimation
  model.all.sat <- plm(cons_adj_bi ~ + direct_post_sat1 + direct_post_sat2 +
                         direct_post_sat3 + spill_post_sat1 + spill_post_sat2 +
                         spill_post_sat3 + as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill), 
                       data = data_treatment, model = "within")
  
  beta.all.sat[l,1] <- coef(model.all.sat)[[1]] #direct 25
  beta.all.sat[l,2] <- coef(model.all.sat)[[2]]  #direct 50
  beta.all.sat[l,3] <- coef(model.all.sat)[[3]] #direct 75
  beta.all.sat[l,4] <- coef(model.all.sat)[[4]]  #spill 25
  beta.all.sat[l,5] <- coef(model.all.sat)[[5]]  #spill 50
  beta.all.sat[l,6] <- coef(model.all.sat)[[6]] #spill 75
  
  se.all.sat[l,1] <- summary(model.all.sat)$coefficients[1,2] #direct 25
  se.all.sat[l,2] <- summary(model.all.sat)$coefficients[2,2] #direct 50
  se.all.sat[l,3] <- summary(model.all.sat)$coefficients[3,2] #direct 75
  se.all.sat[l,4] <- summary(model.all.sat)$coefficients[4,2] #spill 25
  se.all.sat[l,5] <- summary(model.all.sat)$coefficients[5,2] #spill 50
  se.all.sat[l,6] <- summary(model.all.sat)$coefficients[6,2] #spill 75
  
  ## Billing Frequency
  # Post-Treatment indicators
  direct_post_bill1 <- post*direct*(bill==0)
  direct_post_bill2 <- post*direct*(bill==1)
  
  spill_post_bill1 <- post*spill*(bill==0)
  spill_post_bill2 <- post*spill*(bill==1)
  ## Estimates
  model.bill <- plm(cons_adj_bi ~ direct_post_bill1 +spill_post_bill1 +
                      direct_post_bill2 + spill_post_bill2 + post_bill +
                      as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),
                    data=data_treatment, model = "within")
  
  beta.bill[l,1] <- coef(model.bill)[[1]] #direct M
  beta.bill[l,2] <- coef(model.bill)[[2]] #Spill M
  beta.bill[l,3] <- coef(model.bill)[[3]] #direct B
  beta.bill[l,4] <- coef(model.bill)[[4]] #Spill B
  
  se.bill[l,1] <- summary(model.bill)$coefficients[1,2] #direct M
  se.bill[l,2] <- summary(model.bill)$coefficients[2,2] #Spill M
  se.bill[l,3] <- summary(model.bill)$coefficients[3,2] #direct B
  se.bill[l,4] <- summary(model.bill)$coefficients[4,2] #Spill B
  
  ##Billing Frequency with saturation
  # Post-Treatment indicators
  direct_post_satbill1 <- post*direct*as.numeric(assignment_village=="25%")*(bill==0)
  direct_post_satbill2 <- post*direct*as.numeric(assignment_village=="50%")*(bill==0)
  direct_post_satbill3 <- post*direct*as.numeric(assignment_village=="75%")*(bill==0)
  
  direct_post_satbill4 <- post*direct*as.numeric(assignment_village=="25%")*(bill==1)
  direct_post_satbill5 <- post*direct*as.numeric(assignment_village=="50%")*(bill==1)
  direct_post_satbill6 <- post*direct*as.numeric(assignment_village=="75%")*(bill==1)
  
  spill_post_satbill1 <- post*spill*as.numeric(assignment_village=="25%")*(bill==0)
  spill_post_satbill2 <- post*spill*as.numeric(assignment_village=="50%")*(bill==0)
  spill_post_satbill3 <- post*spill*as.numeric(assignment_village=="75%")*(bill==0)
  
  spill_post_satbill4 <- post*spill*as.numeric(assignment_village=="25%")*(bill==1)
  spill_post_satbill5 <- post*spill*as.numeric(assignment_village=="50%")*(bill==1)
  spill_post_satbill6 <- post*spill*as.numeric(assignment_village=="75%")*(bill==1)
  
  ## Estimates
  model.bill.sat <- plm(cons_adj_bi ~ direct_post_satbill1  + spill_post_satbill1 +
                          direct_post_satbill2 + spill_post_satbill2 +
                          direct_post_satbill3 + spill_post_satbill3 +
                          direct_post_satbill4 + spill_post_satbill4 +
                          direct_post_satbill5 + spill_post_satbill5 + 
                          direct_post_satbill6 + spill_post_satbill6 +
                          post_bill + as.factor(time_bi)+as.factor(time_bi_ses)+as.factor(time_bi_bill),
                          data = data, model = "within")
  
  beta.bill.sat[l,1] <- coef(model.bill.sat)[[1]] #direct 25m
  beta.bill.sat[l,2] <- coef(model.bill.sat)[[3]] #direct 50m
  beta.bill.sat[l,3] <- coef(model.bill.sat)[[5]] #direct 75m
  beta.bill.sat[l,4] <- coef(model.bill.sat)[[2]] #spill 25m
  beta.bill.sat[l,5] <- coef(model.bill.sat)[[4]] #spill 50m
  beta.bill.sat[l,6] <- coef(model.bill.sat)[[6]] #spill 75m
  
  beta.bill.sat[l,7] <- coef(model.bill.sat)[[7]] #direct 25b
  beta.bill.sat[l,8] <- coef(model.bill.sat)[[9]] #direct 50b
  beta.bill.sat[l,9] <- coef(model.bill.sat)[[11]] #direct 75b
  beta.bill.sat[l,10] <- coef(model.bill.sat)[[8]] #spill 25b
  beta.bill.sat[l,11] <- coef(model.bill.sat)[[10]] #spill 50b
  beta.bill.sat[l,12] <- coef(model.bill.sat)[[12]] #spill 75b
  
  se.bill.sat[l,1] <- summary(model.bill.sat)$coefficients[1,2] #direct 25m
  se.bill.sat[l,2] <- summary(model.bill.sat)$coefficients[3,2] #direct 50m
  se.bill.sat[l,3] <- summary(model.bill.sat)$coefficients[5,2] #direct 75m
  se.bill.sat[l,4] <- summary(model.bill.sat)$coefficients[2,2] #spill 25m
  se.bill.sat[l,5] <- summary(model.bill.sat)$coefficients[4,2] #spill 50m
  se.bill.sat[l,6] <- summary(model.bill.sat)$coefficients[6,2] #spill 75m
  
  se.bill.sat[l,7] <- summary(model.bill.sat)$coefficients[7,2] #direct 25m
  se.bill.sat[l,8] <- summary(model.bill.sat)$coefficients[9,2] #direct 50m
  se.bill.sat[l,9] <- summary(model.bill.sat)$coefficients[11,2] #direct 75m
  se.bill.sat[l,10] <- summ  ary(model.bill.sat)$coefficients[8,2] #spill 25m
  se.bill.sat[l,11] <- summary(model.bill.sat)$coefficients[10,2] #spill 50m
  se.bill.sat[l,12] <- summary(model.bill.sat)$coefficients[12,2] #spill 75m
  
  #Number of observations
  nobs[l,] <- table(T)
}

# Save results ------------------------------------------------------------
save.image("~/Documents/GitHub/spreading_the_word/simulation/simulation_ses_20000.RData")
