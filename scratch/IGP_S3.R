#' Predict for class IGP
#'
#' @param object Object of class IGP
#' @param ... Additional parameters
#'
#' @return Prediction from object at XX
#' @export
#'
#' @examples
#' n <- 12
#' x <- matrix(seq(0,1,length.out = n), ncol=1)
#' y <- sin(2*pi*x) + rnorm(n,0,1e-1)
#' gp <- IGP(package='laGP', X=x, Z=y, parallel=FALSE)
#' predict(gp, .448)
predict.IGP <- function(object, XX, se.fit=F, covmat=F, split_speed=T, ...) {
  object$predict(XX=XX, se.fit=se.fit)
}


#' Plot for class IGP
#'
#' @param x Object of class IGP
#' @param ... Additional parameters
#'
#' @return Nothing
#' @export
#'
#' @examples
#' n <- 12
#' x <- matrix(seq(0,1,length.out = n), ncol=1)
#' y <- sin(2*pi*x) + rnorm(n,0,1e-1)
#' gp <- IGP(package='laGP', X=x, Z=y)
#'
plot.IGP <- function(x,  ...) {
  if (x$D == 1) {
    x$cool1Dplot(...)
  } else {
    stop("No plot method for higher than 1 dimension")
  }
}
