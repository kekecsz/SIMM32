
# you need to enter the path to the data file here. For example: path = "C:\\Documents\\data_bully_slope.csv"
# the data file needs to be in a .csv format
# you can get this by exporting the dataset in spss to this .csv format, or by save as... csv in Excel
path = "..."

# this line reads files that are in .csv format.
# specifically, read.csv2() reads csv files that where the delimiter is a semicolon ";" (this is usual in Europe)
# while read.csv() reads files where the delimiter is coma ","
# if you are not sure which one is used on your computer, try the code with both functions
# and see which oen produces a no error message
data = read.csv2(path)

# correcting the first variable name, because it had an error in it
names(data)[1] = "sandwich_taken"

# loading packages
# you need to install these packages first if you do not have them yet
# by running the install.packages("lme4") and install.packages("MuMin") commands
library(lme4)
library(MuMIn)

# random intercept model
mod_int = lmer(sandwich_taken ~ weight + (1|class), data = data)

# output of the random intercept model
summary(mod_int)

# marginal and conditional R^2 of the random intercept model
r.squaredGLMM(mod_int)

# random slope model
mod_slope = lmer(sandwich_taken ~ weight + (weight|class), data = data)

# output of the random slope model
summary(mod_slope)

# marginal and conditional R^2 of the random slope model
r.squaredGLMM(mod2)
