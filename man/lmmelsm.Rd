% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/latentMelsm.R
\name{lmmelsm}
\alias{lmmelsm}
\title{Specify and fit the (latent) (multivariate) melsm.}
\usage{
lmmelsm(formula, group, data, ...)
}
\arguments{
\item{formula}{Formula or list of formulas. See section on model specification.}

\item{group}{Raw grouping variable name (not character).}

\item{data}{Data frame.}

\item{...}{Options passed onto \code{\link[rstan]{sampling}}}
}
\value{
lmmelsm object.
}
\description{
Fits a mixed effects location scale model on one or more observed or latent variables.
Currently supports multiple endogenous latent factors or observed outcomes,  and exogenous observed variables.
Data are assumed to be two-level data. I.e., multiple indicators, repeatedly measured within group.
Currently assumes measurement invariance (i.e., the measurement model params are equivalent across groups) and a unit-variance identification for latent variables.
Excludes rows with missing data (and warns the user).
}
\section{Model specification}{


The model is specified as a list of formulas.
LMMELSM supports the specification of latent measurement models, location models, scale models, between-group scale models, and (if latent variables are undesired) observed outcome models.
The covariates do not need to be the same across the location, scale, and between-group models.
The specified covariates will be used to predict the location and scale of \emph{all} latent factors via multivariate regression.

The latent factor model is specified as follows.
In the simplest case, only one formula is required, and a single-factor model is estimated.
The left-hand side (LHS) contains the user-specified latent variable name, and the right-hand side (RHS) contains the indicators.
Let "latent1" and "latent2" be user-chosen names of two latent variables with three indicators each.
Then the formula syntax would be:
\code{list(latent1 ~ y1 + y2 + y3, latent2 ~ y4 + y5 + y6)}

The location model is specified as either a one or two-part formula.
The LHS must be "location" and the RHS contains the covariates.
Random slopes are specified in the optional second part, separated by "|".
Because LMMELSM fits MELSMs, random intercepts are \emph{always} included.
For example, if x1 and x2 are two location predictors, then:

\code{location ~ x1 + x2}

specifies a location model with a random intercept per factor, and no random slopes.

\code{location ~ x1 + x2 | x1}

specifies a location model with a random intercept per factor, a random x1 coefficient per factor, and no random x2 coefficient.

The within-group scale model is specified similarly.
The LHS must be "scale" and the RHS contains the covariates.
Random intercepts are always included, and random slopes are specified in the optional second part of the RHS.
For example, if x2 and x3 are two scale predictors, then:

\code{scale ~ x2 + x3}

specifies a scale model with a random intercept per factor, and no random slopes.

\code{scale ~ x2 + x3 | x3}

specifies a scale model with a random intercept perfactor, a random x3 coefficient per factor, and no random x2 coefficient.

The between-group scale model is specified by a LHS of "between" and RHS containing covariates.
There are no random coefficients permitted in the between-group scale model.
The between-group scale model is responsible for modeling the random effect standard deviations.
\emph{Note:} The between-group model \emph{only} models the SDs of the random location and scale \emph{intercepts}.

\code{between ~ x2}

specifies a between-group scale model on the SDs of the location and scale intercepts for each factor.

If you want to fit a non-latent multivariate MELSM, use "observed" as the LHS:

For example, if y1, y2, and y3 are three observed outcome variables, then

\code{observed ~ y1 + y2 + y3}

would fit an M-MELSM.
Location, scale, and between-group models can still be specified, but they will model the observed variables, rather than latent variables.
You cannot currently have both observed and latent outcomes in the same model.

\emph{Note}: Because \code{location}, \code{scale}, \code{between}, and \code{observed} represent special formulas, latent factors cannot be named location, scale, between, nor observed.
It is assumed that any formula with \code{location}, \code{scale}, or \code{between} on the left-hand side (LHS) is a predictive formula, not a latent variable specification.
}

\examples{
\donttest{
data(sim_data)

# Fit LMMELSM with two latent factors (A and B),
# Location model with one random coefficient
# Scale model with one random coefficient
# Between-group scale model with one covariate
fit <- lmmelsm(list(A ~ A_1 + A_2 + A_3 + A_4 + A_5 + A_6,
                    B ~ N_1 + N_2 + N_3 + N_4 + N_5 + N_6,
                    location ~ x1 + baseline | x1,
                    scale ~ x2 + baseline | x2,
                    between ~ baseline),
               subject, sim_data, cores = 2, iter = 500, chains = 2
              )

# Summarize fit
summary(fit)

# Get random effects
ranef(fit)
# Get group-specific parameter values
coef(fit)
# Get approximate leave-one-out
loo(fit)
}
}
\author{
Stephen R. Martin
}
