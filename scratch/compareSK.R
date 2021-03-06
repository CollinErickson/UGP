#library(R6)

#' UGP
#' Class providing object with methods for fitting a GP model
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
# @keywords data, kriging, Gaussian process, regression
#' @return Object of \code{\link{R6Class}} with methods for fitting GP model.
#' @format \code{\link{R6Class}} object.
#' @examples
#' n <- 40
#' d <- 2
#' n2 <- 20
#' f1 <- function(x) {sin(2*pi*x[1]) + sin(2*pi*x[2])}
#' X1 <- matrix(runif(n*d),n,d)
#' Z1 <- apply(X1,1,f1) + rnorm(n, 0, 1e-3)
#' X2 <- matrix(runif(n2*d),n2,d)
#' Z2 <- apply(X2,1,f1)
#' XX1 <- matrix(runif(10),5,2)
#' ZZ1 <- apply(XX1, 1, f1)
#' u <- UGP$new(package='laGP',X=X1,Z=Z1, corr.power=2)
#' cbind(u$predict(XX1), ZZ1)
#' u$predict.se(XX1)
#' u$update(Xnew=X2,Znew=Z2)
#' u$predict(XX1)
#' u$delete()
#' @field X Design matrix
#' @field Z Responses
#' @field N Number of data points
#' @field D Dimension of data
#' @section Methods:
#' \describe{
#'   \item{Documentation}{For full documentation of each method go to https://github.com/CollinErickson/UGP/}
#'   \item{\code{new(X=NULL, Z=NULL, package=NULL, corr.power=2,
#'   estimate.nugget=T, set.nugget=F, ...)}}{This method
#'   is used to create object of this class with \code{X} and \code{Z} as the data.
#'   The package tells it which package to fit the GP model.}
#'   \item{\code{Xall=NULL, Zall=NULL, Xnew=NULL, Znew=NULL, ...}}{This method
#'   updates the model, adding new data if given, then running optimization again.}}
SKcompare <- R6::R6Class(classname="SKcompare",
         public=list(
           D=NULL,
           reps=NULL,
           input.ss=NULL,
           test.ss=NULL,
           func=NULL,
           X0=NULL,
           Xs=NULL,
           Zs=NULL,
           Xpreds=NULL,
           Zpreds=NULL,
           n0=NULL,
           n0reps=NULL,
           n2=NULL,
           varss=NULL,
           nugprops=NULL,
           packages=NULL,
           storage_names=NULL,
           plot_names=NULL,
           init_lists=NULL,
           outputlist=NULL,
           outputdf=NULL,
           runnable=NULL,

           initialize = function(D, reps, input.ss, test.ss, func, packages, X0=NULL, n0,n0reps,n2) {#browser()

             self$D <- D
             self$reps <- reps
             self$input.ss <- input.ss
             self$test.ss <- test.ss
             self$func <- func
             self$Xs <- list()
             self$Zs <- list()
             self$Xpreds <- list()
             self$Zpreds <- list()
             self$varss <- list()
             self$nugprops <- list()
             self$X0 <- X0
             self$n0 <- n0
             self$n0reps <- n0reps
             self$n2 <- n2
             if (is.character(packages)) {
               self$packages <- packages
               self$storage_names <- packages
               self$plot_names <- packages
               self$init_lists <- NULL
             } else { # list input, first of each is package, second is name, after that is options
               #browser()
               self$packages <- sapply(packages, function(xx) xx[[1]])
               self$storage_names <- sapply(packages, function(xx) if (length(xx)>1) xx[[2]] else xx[[1]])
               self$plot_names <- sapply(packages, function(xx) if (length(xx)>2) xx[[3]] else xx[[1]])
               self$init_lists <- lapply(packages, function(xx) if (length(xx)>3) xx[[4]] else list())
             }
             self$outputlist <- list()
             self$outputdf <- data.frame()
             self$runnable <- TRUE
           },
           create_data = function(n2=self$n2) {

             for (rep in 1:self$reps) {browser()
               #Xnew <- lhs::maximinLHS(self$input.ss, self$D)
               if (is.null(self$X0)) {
                 X0 <- MaxPro::MaxProLHD(self$n0, self$D)
               }
               I1 <- sort(rep(1:length(X0), n0reps))
               #X1 <- rbind(X0, X0, X0, X0)
               X1 <- X0[I1,, drop=F]
               Z1 <- func.sample(X1)
               vars1 <- sapply(split(x=Z1, f=as.factor(I1)), var)
               n2props <- sqrt(vars1)/sum(sqrt(vars1))
               n2s <- round(n2*n2props)
               sum(n2s)
               I2 <- rep(1:length(X0), n2s)
               X2 <- X0[I2,, drop=F]
               Z2 <- self$func.sample(X2)
               I <- c(I1, I2)
               X <- rbind(X1, X2)
               Z <- c(Z1, Z2)
               vars <- sapply(split(x=Z, f=as.factor(X)), var)
               nugprop <- vars[I]





               #Xnew <- lhs::maximinLHS(self$input.ss, self$D)
               #Znew <- apply(Xnew, 1, self$func)
               self$X1s <- c(self$X1s, list(X1new))
               self$Z1s <- c(self$Z1s, list(Z1new))
               self$X2s <- c(self$X2s, list(X2new))
               self$Z2s <- c(self$Z2s, list(Z2new))
               self$Xs <- c(self$Xs, list(Xnew))
               self$Zs <- c(self$Zs, list(Znew))
               self$varss <- c(self$varss, list(vars))
               self$nugprops <- c(self$nugprops, list(nugprops))
               # prediction points
               Xprednew <- lhs::maximinLHS(self$input.ss, self$D)
               Zprednew <- apply(Xprednew, 1, self$func)
               self$Xpreds <- c(self$Xpreds, list(Xprednew))
               self$Zpreds <- c(self$Zpreds, list(Zprednew))
             }
           },
           run_fits = function() {#browser()
             if (!self$runnable) {stop("This is not runnable")}
             #init_list <- NULL
             for (rep in 1:self$reps) {
               for (ipackage in seq_along(self$packages)) {
                 #init_list <- self$init_lists[[ipackage]]
                 package <- self$packages[ipackage]
                 storage_name <- self$storage_names[ipackage]
                 plot_name <- self$plot_names[ipackage]
                 #package.use <- strsplit(package, '-')[[1]][1] # lets you add identifying name after a hyphen

                 fit.time <- system.time({
                   u <- do.call(UGP::UGP2,
                                c(list(X=self$Xs[[rep]], Z=self$Zs[[rep]], package=package),
                                  self$init_lists[[ipackage]]))
                 })[3]

                 predict.time <- system.time(up <- do.call(u$predict, list(self$Xpreds[[rep]], se.fit=T)))[3]

                 mse <- mean((up$fit - self$Zpreds[[rep]])^2)
                 pmse <- mean((up$se)^2)
                 rmse <- sqrt(mse)
                 prmse <- sqrt(pmse)
                 #browser()
                 out.new <- data.frame(package=package, storage_name=storage_name, plot_name=plot_name,
                                       rep=rep, fit.time=fit.time, predict.time=predict.time,
                                       mse=mse, pmse=pmse, rmse=rmse, prmse=prmse)
                 #out <- rbind(out, out.new)
                 self$outputlist[[storage_name]][[rep]] <- out.new
                 u$delete()
               }
             }
           },
           process_output = function() {#browser()
             self$outputdf <- data.frame()
             for (i in self$outputlist) {
               for (j in i) {
                 self$outputdf <- rbind(self$outputdf, j)
               }
             }
           },
           plot_output = function() {

             stripchart(rmse ~ package, data=out)
           },
           plot_rmseprmse = function() {#browser()
             com2 <- reshape::melt.data.frame(self$outputdf, measure.var=c('rmse', 'prmse'), id.vars=c('plot_name','rep'), variable_name="rmseprmse")

             rmseprmse_plot <- (ggplot2::ggplot(com2, ggplot2::aes_(x=~value, y=~rmseprmse, color=~plot_name, shape=~as.factor(rep)))
                                + ggplot2::geom_point(ggplot2::aes_(shape=~as.factor(rep)),size=3) + ggplot2::facet_grid(plot_name ~ .)
                                + ggplot2::guides(shape=F,color=F)
                                + ggplot2::ylab(NULL) + ggplot2::xlab(NULL)
                                +  ggplot2::geom_line(ggplot2::aes(x=value, y=rmseprmse, group=rep)))
             print(rmseprmse_plot)
           }
         )
) # End GPcompare R6 class
