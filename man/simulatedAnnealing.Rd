% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/simulated_annealing.R
\name{simulatedAnnealing}
\alias{simulatedAnnealing}
\title{An adaptation of the simulated annealing algorithm for psychometric models.}
\usage{
simulatedAnnealing(initialModel, originalData, maxSteps, fitStatistic = "cfi",
  temperature = "linear", maximize = TRUE, Kirkpatrick = TRUE,
  randomNeighbor = TRUE, lavaan.model.specs = list(model.type = "cfa",
  auto.var = TRUE, estimator = "default", ordered = NULL, int.ov.free = TRUE,
  int.lv.free = FALSE, std.lv = TRUE, auto.fix.first = FALSE, auto.fix.single =
  TRUE, auto.cov.lv.x = TRUE, auto.th = TRUE, auto.delta = TRUE, auto.cov.y =
  TRUE), maxChanges = 5, restartCriteria = "consecutive",
  maximumConsecutive = 25, maxItems = NULL, items = NULL,
  bifactor = FALSE, progress = "bar", ...)
}
\arguments{
\item{initialModel}{The initial model as a character vector with lavaan model.syntax.}

\item{originalData}{The original data frame with variable names.}

\item{maxSteps}{The number of iterations for which the algorithm will run.}

\item{fitStatistic}{Either a single model fit statistic produced by lavaan, or a user-defined fit statistic function.}

\item{temperature}{Either an acceptable character value, or a user-defined temperature function. The acceptable values are "linear", "quadratic", or "logistic".}

\item{maximize}{Logical indicating if the goal is to maximize (TRUE) the fitStatistic for model selection.}

\item{Kirkpatrick}{Either TRUE to use Kirkpatrick et al. (1983) acceptance probability, or a user-defined function for accepting proposed models.}

\item{randomNeighbor}{Either TRUE to use the included function for randomNeighbor selection, or a user-defined function for creating random models.}

\item{lavaan.model.specs}{A list which contains the specifications for the
lavaan model. The default values are the defaults for lavaan to perform a
CFA. See \link[lavaan]{lavaan} for more details.}

\item{maxChanges}{An integer value greater than 1 setting the maximum number of parameters to change within randomNeighbor.}

\item{restartCriteria}{Either "consecutive" to restart after maxConsecutiveSelection times with the same model chosen in a row, or a user-defined function.}

\item{maximumConsecutive}{A numeric value used with restartCriteria.}

\item{maxItems}{When creating a short form, a vector of the number of items per factor you want the short form to contain. Defaults to `NULL`.}

\item{items}{A character vector of item names. Defaults to `NULL`. Ignored if `maxItems==FALSE`.}

\item{bifactor}{Logical. Indicates if the latent model is a bifactor model. If `TRUE`, assumes that the last latent variable in the provided model syntax is the bifactor (i.e., all of the retained items will be set to load on the last latent variable). Ignored if `maxItems==FALSE`.}

\item{progress}{Character. If `'bar'`, the function prints a progress bar indicating how far along it is. If `'text'`, prints the current step value. Otherwise, nothing is printed to indicate the progress of the function.}

\item{...}{Further arguments to be passed to other functions. Not implemented for any of the included functions.}
}
\value{
A named list: the 'bestModel' found, the 'bestFit', and 'allFit' values found by the algorithm.
}
\description{
Simulated annealing mimics the physical process of annealing metals together. [Kirkpatrick et al. (1983)](http://science.sciencemag.org/content/220/4598/671) introduces this analogy and demonstrates its use; the implementation here follows this demonstration closely, with some modifications to make it better suited for psychometric models.
}
\details{
##### Simulated Annealing Outline ####
initialModel - the initial, full form
currentModel - the model of the current step
maxSteps - the number of steps (iterations)
currentStep - the current step
currentTemp - the current temperature. A function of the number of steps (such that temp = 0 at maxSteps), and values that control the shape of the overall temperature. Should be modifiable. At the least, needs a maxTemp value and values that control the shape (up to a cubic value, maybe?)
randomNeighbor - a function that determines how the form is changed at each step. Probably similar to the Tabu model. Should be able to change one or more parameters
goal - a function that determines the "goodness" of the currentModel. Typically in SA goodness is defined as minimization! Sometimes called an energ function
selectionFunction - a function that determines if a randomNeighbor change is accepted. Uses the goal function that determines the "goodness" of the currentModel and the "goodness" of the randomNeighbor, and the currentTemp to generate a probability of acceptance, then compares this probability to a U[0,1] variable to determine if accepted or not. A standard version of this is P(goal, goal', currentTemp) = [(1 if goal' better than goal), (exp(-(goal' - goal)/currentTemp) if goal' worse than goal)] (citation: Kirkpatrick et al., 1983). Allowing other functions would be ideal.
bestModel - the model with the best value of the goal function achieved so far
bestGoal - the best value of the goal function achieved so far
restartCriteria - if allowed, this would "restart" the SA process by changing currentModel to bestModel and continuing the process. Could be based on (1) the currentStep value, (2) the difference between goal(currentModel) and goal(bestModel), (3) randomness (i.e., could randomly restart, could randomly restart based on some values, etc), (4) other critera.
}
\examples{
\dontrun{
data(exampleAntModel)
data(simulated_test_data)
trial1 <- simulatedAnnealing(initialModel = lavaan::cfa(model = exampleAntModel,
                                                        data = simulated_test_data),
                             originalData = simulated_test_data, maxSteps = 3,
                             fitStatistic = 'rmsea', maximize = FALSE)
# lavaan::summary(trial1[[1]]) # shows the resulting model

trial2 <- simulatedAnnealing(initialModel = exampleAntModel,
originalData = simulated_test_data,
maxSteps = 2, maxItems = 30, items = paste0("Item", 1:56))
# lavaan::summary(trial2[[1]]) # shows the resulting model
}
}
