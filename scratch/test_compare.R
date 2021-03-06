compare.UGP(packages=c("laGP"), func=TestFunctions::banana, D=2, N=50, Npred = 1e3, reps = 5)
compare.UGP(packages=c("laGP", "mlegp", "GauPro"), func=TestFunctions::banana, D=2, N=50, Npred = 1e3, reps = 5)
compare.UGP(packages=c("GauPro-Par", "GauPro-NP","laGP", "GPy"), func=TestFunctions::RFF_get(D=2), D=2, N=50, Npred = 1e3, reps = 4,
            , init_list = list('1'=list(parallel=T), '2'=list(parallel=F)))
compare.UGP(packages=c("GauPro-Dev", "GauPro-LLH","laGP", "GPy", "sklearn"), func=TestFunctions::RFF_get(D=2), D=2, N=50, Npred = 1e3, reps = 4,
            , init_list = list('1'=list(useLLH=F), '2'=list(useLLH=T)))
compare.UGP(packages=c("GauPro", "GauPro","laGP", "mlegp", "GPy","sklearn"), func=TestFunctions::RFF_get(D=2), D=2, N=40, Npred = 1e3, reps = 5)



library(ggplot2)
com <- data.frame()
(
  ggplot(data=com, aes(x=rmse, y=package)) + geom_point()
 + geom_point(data=com, aes(x=prmse, y=package, color=rep), inherit.aes = F)
)

library(reshape)
com2 <- melt(com, measure.var=c('rmse', 'prmse'), id.vars=c('package','rep'), variable_name="rmseprmse")
com2$y_numeric <- with(com2,
                       as.numeric(package) + ifelse(rmseprmse == "rmse", 0, 0.1)
)
(
  ggplot(data=com2, aes(x=value, y=y_numeric, color=rmseprmse)) + geom_point()
)


# THIS IS THE BEST ONE
(
ggplot(com2,aes(x=value,y=y_numeric,colour=rmseprmse)) +
  geom_point(aes(shape=as.factor(rep)), size=3) +
scale_y_continuous(breaks=c(unique(com2$package)),
                 labels=levels(unique(com2$package)))
)
# This might be better, uses facets
ggplot(com2, aes(x=value, y=rmseprmse, color=as.factor(rep))) + geom_point(aes(shape=rmseprmse),size=3) + facet_grid(package ~ .) + guides(shape=F,color=F)







# For compareR6
gp <- GPcompare$new(D=2,reps=5,input.ss=20, test.ss=200, func=function(xx)sum(sin(2*pi*xx)), packages="GauPro")
gp <- GPcompare$new(D=2,reps=5,input.ss=20, test.ss=200, func=TestFunctions::add_noise(function(xx)sum(sin(2*pi*xx)),noise=.1),
                    packages=list(
                      list("GauPro","Ga","Gap"),
                      list("DiceKriging","DiceMatE","DKME", list(covtype="matern5_2", nugget.estim=T)),
                      list("DiceKriging","DiceMat0","DKM0", list(covtype="matern5_2", nugget.estim=F)),
                      list("DiceKriging","DiceGausE","DK2E", list(covtype="gauss", nugget.estim=T)),
                      list("DiceKriging","DiceGaus0","DK20", list(covtype="gauss", nugget.estim=F))
                      ))
gp$create_data()
gp$run_fits()
gp$process_output()
gp$plot_rmseprmse()
gp$plot_output()
gp <- GPcompare$new(D=20,reps=2,input.ss=200, test.ss=200, func=TestFunctions::morris,
                    packages=list(
                      #list("GauPro","Ga","Gap", list(restarts=0)), # far slower than DK 100s v 2s
                      list("laGP", "laGP", "laGP"),
                      list("DiceKriging","DiceMatE","DKME", list(covtype="matern5_2", nugget.estim=T)),
                      list("DiceKriging","DiceMat0","DKM0", list(covtype="matern5_2", nugget.estim=F)),
                      list("DiceKriging","DiceGausE","DK2E", list(covtype="gauss", nugget.estim=T)),
                      list("DiceKriging","DiceGaus0","DK20", list(covtype="gauss", nugget.estim=F))
                    ))











# Stochastic kriging compare test
gp <- SKcompare$new(D=2,reps=5,input.ss=20, test.ss=200, func=TestFunctions::add_noise(function(xx)sum(sin(2*pi*xx)),noise=.1),
                    packages=list(
                      list("mlegp","mlegp","mlegp", list(covtype="matern5_2", nugget.estim=T)),
                      list("DiceKriging","DiceMat0","DKM0", list(covtype="matern5_2", nugget.estim=F)),
                      list("DiceKriging","DiceGausE","DK2E", list(covtype="gauss", nugget.estim=T)),
                      list("DiceKriging","DiceGaus0","DK20", list(covtype="gauss", nugget.estim=F))
                    ))
gp$create_data()
gp$run_fits()
gp$process_output()
gp$plot_rmseprmse()
gp$plot_output()
