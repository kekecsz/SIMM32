* Encoding: UTF-8.
* multiple regression with two predictors
  
  REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT price
  /METHOD=ENTER sqft_living grade
  /METHOD=ENTER lat long.

* multiple regression with multiple predictors

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT price
  /METHOD=ENTER sqft_living grade
  /METHOD=ENTER lat long
  /METHOD=ENTER condition.

