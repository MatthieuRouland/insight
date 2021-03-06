#' @title Get the values from model weights
#' @name get_weights
#'
#' @description Returns weighting variable of a model.
#'
#' @param x A fitted model.
#' @param na_rm Logical, if \code{TRUE}, removes possible missing values.
#' @param ... Currently not used.
#'
#' @return The weighting variable, or \code{NULL} if no weights were specified (or if all weights were 1).
#'
#' @examples
#' data(mtcars)
#' mtcars$weight <- rnorm(nrow(mtcars), 1, .3)
#' m <- lm(mpg ~ wt + cyl + vs, data = mtcars, weights = weight)
#' get_weights(m)
#' @importFrom stats na.omit
#' @export
get_weights <- function(x, na_rm = FALSE, ...) {
  UseMethod("get_weights")
}


#' @export
get_weights.default <- function(x, na_rm = FALSE, ...) {
  w <- NULL
  tryCatch(
    {
      w <- stats::weights(x)
    },
    error = function(x) {
      NULL
    },
    warning = function(x) {
      NULL
    },
    finally = function(x) {
      NULL
    }
  )

  if (is.null(w)) {
    tryCatch(
      {
        w <- stats::model.frame(x)[["(weights)"]]
      },
      error = function(x) {
        NULL
      },
      warning = function(x) {
        NULL
      },
      finally = function(x) {
        NULL
      }
    )
  }

  if (is.null(w)) {
    tryCatch(
      {
        w <- .get_data_from_env(x)[[find_weights(x)]]
      },
      error = function(x) {
        NULL
      },
      warning = function(x) {
        NULL
      },
      finally = function(x) {
        NULL
      }
    )
  }

  # if all weights are 1, set return value to NULL
  if (!is.null(w) && all(w == 1L)) {
    w <- NULL
  }

  if (!is.null(w) && anyNA(w) && isTRUE(na_rm)) {
    w <- stats::na.omit(w)
  }

  w
}


#' @export
get_weights.brmsfit <- function(x, na_rm = FALSE, ...) {
  w <- find_weights(x)

  if (!is.null(w)) {
    w <- get_data(x)[[w]]
  }

  if (!is.null(w) && all(w == 1L)) {
    w <- NULL
  }

  if (!is.null(w) && anyNA(w) && isTRUE(na_rm)) {
    w <- stats::na.omit(w)
  }

  w
}
