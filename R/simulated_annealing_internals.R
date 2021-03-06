

selectionFunction <-
  function(currentModelObject = currentModel,
           randomNeighborModel,
           currentTemp,
           maximize,
           fitStatistic,
           consecutive) {
    # check if the randomNeighborModel is a valid model for use
    if (length(randomNeighborModel[[2]]) > 0 |
        length(randomNeighborModel[[2]]) > 0) {
      return(currentModelObject)
    }
    
    # check that the current model isn't null
    if (is.null(currentModelObject[[1]])) {
      return(randomNeighborModel)
    }
    
    # this is the Kirkpatrick et al. method of selecting between currentModel and randomNeighborModel
    if (goal(randomNeighborModel[[1]], fitStatistic, maximize) < goal(currentModelObject[[1]], fitStatistic, maximize)) {
      consecutive = consecutive + 1
      return(randomNeighborModel)
      
    } else {
      probability = exp(-(
        goal(randomNeighborModel[[1]], fitStatistic, maximize) - goal(currentModelObject[[1]], fitStatistic, maximize)
      ) / currentTemp)
      
      if (probability > runif(1)) {
        newModel = randomNeighborModel
      } else {
        newModel = currentModelObject
      }
      
      consecutive = ifelse(identical(
        lavaan::parameterTable(newModel[[1]]),
        lavaan::parameterTable(currentModelObject[[1]])
      ),
      consecutive + 1,
      0)
      return(newModel)
    }
  }

goal <- function(x, fitStatistic = 'cfi', maximize) {
  # if using lavaan and a singular fit statistic,
  if (class(x) == "lavaan" &
      is.character(fitStatistic) & length(fitStatistic) == 1) {
    energy <- lavaan::fitMeasures(x, fit.measures = fitStatistic)
    
    # if trying to maximize a value, return its negative
    if (maximize == TRUE) {
      return(-energy)
    } else {
      # if minimizing a value, return the value
      return(energy)
    }
  } else {
    if (class(x) == "NULL") {
      if (maximize == TRUE) {
        return(-Inf)
      } else {
        return(Inf)
      }
    }
  }
}

consecutiveRestart <-
  function(maxConsecutiveSelection = 25, consecutive) {
    if (consecutive == maxConsecutiveSelection) {
      currentModel = bestModel
      consecutive = 0
    }
  }

linearTemperature <- function(currentStep, maxSteps) {
  currentTemp <- (maxSteps - (currentStep)) / maxSteps
}

quadraticTemperature <- function(currentStep, maxSteps) {
  currentTemp <- ((maxSteps - (currentStep)) / maxSteps) ^ 2
}

logisticTemperature <- function(currentStep, maxSteps) {
  x = 1:maxSteps
  x.new = scale(x, center = T, scale = maxSteps / 12)
  currentTemp <- 1 / (1 + exp((x.new[(currentStep + 1)])))
}

checkModels <-
  function(currentModel,
           fitStatistic,
           maximize = maximize,
           bestFit = bestFit,
           bestModel) {
    if (class(currentModel) == "list") {
      currentModel <- currentModel[[1]]
    }
    if (is.null(currentModel)) {
      return(bestModel)
    }
    currentFit = tryCatch(
      lavaan::fitmeasures(object = currentModel, fit.measures = fitStatistic),
      error = function(e, checkMaximize = maximize) {
        if (length(e) > 0) {
          if (checkMaximize == TRUE) {
            return(0)
          } else {
            return(Inf)
          }
        }
      }
    )
    if (maximize == TRUE) {
      if (currentFit > bestFit) {
        bestModel = currentModel
      } else {
        bestModel = bestModel
      }
    } else {
      if (currentFit < bestFit) {
        bestModel = currentModel
      } else {
        bestModel = bestModel
      }
    }
    
    return(bestModel)
  }

modelWarningCheck <- function(expr) {
  warn <- err <- c()
  value <- withCallingHandlers(
    tryCatch(
      expr,
      error = function(e) {
        err <<-
          append(err, regmatches(paste(e), gregexpr("ERROR: [A-z ]{1,}", paste(e))))
        NULL
      }
    ),
    warning = function(w) {
      warn <<-
        append(warn, regmatches(paste(w), gregexpr("WARNING: [A-z ]{1,}", paste(w))))
      invokeRestart("muffleWarning")
    }
  )
  list(
    'lavaan.output' = value,
    'warnings' <-
      as.character(unlist(warn)),
    'errors' <- as.character(unlist(err))
  )
}


syntaxExtraction = function(initialModelSyntaxFile, items = allItems) {
  # extract the latent factor syntax
  factors = unique(lavaan::lavaanify(initialModelSyntaxFile)[lavaan::lavaanify(initialModelSyntaxFile)$op ==
                                                               "=~", 'lhs'])
  vectorModelSyntax = stringr::str_split(string = initialModelSyntaxFile,
                                         pattern = '\\n',
                                         simplify = TRUE)
  factorSyntax = c()
  itemSyntax = c()
  for (i in 1:length(factors)) {
    chosenFactorLocation = c(1:length(vectorModelSyntax))[grepl(x = vectorModelSyntax, pattern = paste0(factors[i], " =~ "))]
    factorSyntax[i] = vectorModelSyntax[chosenFactorLocation]
    # remove the factors from the syntax
    itemSyntax[i] <-
      gsub(
        pattern = paste(factors[i], "=~ "),
        replacement = "",
        x = factorSyntax[i]
      )
  }
  
  # extract the items for each factor
  itemsPerFactor = stringr::str_extract_all(string = itemSyntax,
                                            pattern = paste0("(\\b", paste0(
                                              paste0(unlist(items), collapse = "\\b)|(\\b"), "\\b)"
                                            )))
  return(list('factors' = factors, 'itemsPerFactor' = itemsPerFactor))
}

# included to quiet R CMD check note about no glbal binding
if (getRversion() >= "2.15.1") {
  utils::globalVariables(
    c(
      'allItems',
      'auto.cov.lv.x',
      'auto.cov.y',
      'auto.delta',
      'auto.fix.first',
      'auto.fix.single',
      'auto.th',
      'auto.var',
      'bestModel',
      'currentModel',
      'estimator',
      'factors',
      'int.lv.free',
      'int.ov.free',
      'itemsPerFactor',
      'model.type',
      'numItems',
      'runif',
      'std.lv'
    )
  )
}