##' Class \code{"syndromicD"}
##'
##' Syndromic is the main class of the \code{vetsyn} package, but it has been 
##' specified for different types of data streams. \code{syndromicD} is the class
##' used for data that are recorded and monitored DAILY, while \code{syndromicW} is
##' used when the time points for monitoring refer to WEEKS.
##' 
##' The \code{syndromicD} or \code{syndromicW} classes store observed data in 
##' a format appropriate
##' for monitoring, and contain several slots to store input and outputs of 
##' analysis (temporal monitoring).
##' Functions are available to create an object of the class syndromic from data 
##' already cleaned and prepared for monitoring, or alternatively from raw observed data.
##' 
##' @section Slots:
##' \itemize{
##'   \item{observed}{
##'     A \code{matrix} with the number of rows equal to the number of time points available
##' (i.e., the number of DAYS of observed data for syndromicD, or the number of WEEKS
##' for syndromicW); and number of columns equal to the number of 
##' syndromes monitored.
##'   }
##'   \item{dates}{
##'     A \code{DataFrame} which first column contains the dates corresponding to the observations
##' recorded. In syndromicD the dates are recorded in the format "yyyy-mm-dd" in the first columns,
##' and additional columns contain additional information extracted from the date,
##' such as day-of-the-week, month, holidays, etc. For syndromicW the first column
##' contains the week in the ISOweek format, and additional columns give the week and year in the
##' numerical format.
##'   }
##'   \item{baseline}{
##'   A \code{matrix} of dimensions exactly equal to the slot observed, where observed data have been 
##'   cleaned in order to remove excess noise and/or outbreak signals, generating an outbreak-free
##'   time series that should be used as baseline for the detection algorithms.     
##'   }
##'   \item{alarms}{
##'     An \code{array} containing the results of the outbreak-signal detection algorithms, for each
##'     of the time series being monitored (columns in observed). Alarms
##'     can be registered as binary values (0 for no alarm and 1 for alarm) or as a ordinal value 
##'     representing an alarm level (for instance 0-5). The first and second dimensions (rows and columns) 
##'     correspond to the dimensions of the time series monitored, but a third dimension can be added when
##'     multiple detection algorithms are used.
##'   }
##'   \item{UCL}{
##'     An \code{array} containing the upper confidence limit (UCL) of the 
##'     outbreak-signal detection algorithms, 
##'     for each of the time series being monitored (columns in observed).  
##'     The first and second dimensions (rows and columns) correspond to the dimensions of the 
##'     time series monitored, but a third dimension can be added when 
##'     multiple detection algorithms are used. Whether an alarm is registered or not, 
##'     this dimension can be used to record the minimum number that would have generated an alarm.
##'   }
##'   \item{LCL}{
##'     An \code{array} containing the lower confidence limit (LCL) of the outbreak-signal 
##'     detection algorithms, for each of the time series being monitored
##'      ( columns in the slot observed), when detection is based
##'     (also) on the detection of decreases in the number of observations.
##'      The first and second dimensions (rows and columns) 
##'     correspond to the dimensions of the time series monitored, 
##'     but a third dimension can be added when
##'     multiple detection algorithms are used. Whether an alarm is registered or not, 
##'     this dimension can be used
##'     to record the maximum number that would have generated an alarm.
##'   }
##'   \item{formula}{
##'     A formula, or list of formulas, specifying the regression formula to be used
##'     when removing temporal patterns from each of the syndromes in @observed. For instance 
##'     formula=y~dow+mon for a single syndrome, where regression must take into 
##'     account the variables dow (day-of-week) and month;
##'     or formula=c(y~dow, y~dow+mon) specifying two different formulas for two syndromes. 
##'     The names of the variables given should exist in the columns of the slot @dates. 
##'     Make sure that formulas' index match the
##'     columns in observed (for instance the second formula should correspond to the second
##'     syndrome, or second column in the observed matrix).You can provide NA for syndromes
##'     which should not be associated with any formula. This parameter is often only filled after 
##'     some analysis in the data, not at the time of object creation.
##'   }
##'   }
##'   
##'   @name syndromicD-class
##' @export
##' @examples
##' ## Load data
##' data(observed)
##' my.syndromicD <- syndromicD(observed,min.date="01/01/2011",max.date="26/05/2013")
##' my.syndromicD <- syndromicD(observed[1:5,],min.date="01/01/2010",max.date="05/01/2010")
##' my.syndromicD <- syndromicD(observed[1:6,],min.date="01/01/2010",max.date="08/01/2010", 
##'                           weekends=FALSE) 
##' dates = seq(from=as.Date("01/01/2010",format ="%d/%m/%Y" ),
##'               to=as.Date("05/01/2010",format ="%d/%m/%Y" ), 
##'               by="days")
##' my.syndromicD <- syndromicD(observed[1:5,],dates=dates) 
##'
setClass('syndromicD',
         representation(observed  = 'matrix',
                        dates     = 'data.frame',
                        baseline  = 'matrix',
                        alarms    = 'array',
                        UCL       = 'array',
                        LCL       = 'array',
                        formula   = 'list'),
         validity = function(object) {
             retval <- NULL
             
             if(dim(object@observed)[1]==0) ({
               retval <- 'You cannot create a syndromic object without 
               supplying observed data'
             }) else ({
                     

             l1 <-dim(object@observed)[1]
             if(length(object@dates)>1L)    (l1 <- c(l1,dim(object@dates)[1]))
             if(length(object@baseline)>1L) (l1 <- c(l1,dim(object@baseline)[1]))
             if(length(object@alarms)>1L)   (l1 <- c(l1,dim(object@alarms)[1]))
             if(length(object@UCL)>1L)      (l1 <- c(l1,dim(object@UCL)[1]))
             if(length(object@LCL)>1L)      (l1 <- c(l1,dim(object@LCL)[1]))
             
             l2 <-dim(object@observed)[2]
             if(length(object@baseline)>1L) (l2 <- c(l2,dim(object@baseline)[2]))
             if(length(object@alarms)>1L)   (l2 <- c(l2,dim(object@alarms)[2]))
             if(length(object@UCL)>1L)      (l2 <- c(l2,dim(object@UCL)[2]))
             if(length(object@LCL)>1L)      (l2 <- c(l2,dim(object@LCL)[2]))
             if(length(object@formula)>1L)  (l2 <- c(l2,length(object@formula)[2]))
             
             l1 <- unique(l1)
             l2 <- unique(l2)
             
             if(!identical(length(l1), 1L)||!identical(length(l2), 1L)) {
                 retval <- 'Dimensions of observed, dates (only number of rows in date), 
                            baseline, alarms, UCL and LCL should be the same; and 
                            length of formula should be the same as the number of
                            columns in those datasets (number of syndromes).'
             }
                  })
         }
)




