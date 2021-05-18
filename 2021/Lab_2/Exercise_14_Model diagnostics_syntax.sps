* Encoding: UTF-8.
* Model diagnostics

* Build a regression model

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade 
  /SCATTERPLOT=(*ZRESID ,*ZPRED) 
  /RESIDUALS NORMPROB(ZRESID) 
  /SAVE PRED COOK RESID.

* Visualize relationships

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sqft_living price MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: sqft_living=col(source(s), name("sqft_living")) 
  DATA: price=col(source(s), name("price")) 
  GUIDE: axis(dim(1), label("sqft_living")) 
  GUIDE: axis(dim(2), label("price")) 
  ELEMENT: point(position(sqft_living*price)) 
  ELEMENT: line(position(smooth.linear(sqft_living*price)))
END GPL.

* Cook's distance plot

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=case_number COO_1 MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: case_number=col(source(s), name("case_number"), unit.category()) 
  DATA: COO_1=col(source(s), name("COO_1")) 
  GUIDE: axis(dim(1), label("case_number")) 
  GUIDE: axis(dim(2), label("Cook's Distance")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: point(position(case_number*COO_1)) 
END GPL.

* Normality of unstandardized residuals

EXAMINE VARIABLES=RES_1 
  /PLOT BOXPLOT HISTOGRAM NPPLOT 
  /COMPARE GROUPS 
  /STATISTICS DESCRIPTIVES 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.

* Bootstrap regression

BOOTSTRAP
  /SAMPLING METHOD=SIMPLE
  /VARIABLES TARGET=price INPUT=  sqft_living grade  
  /CRITERIA CILEVEL=95 CITYPE=PERCENTILE  NSAMPLES=1000
  /MISSING USERMISSING=EXCLUDE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT price
  /METHOD=ENTER sqft_living grade
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS NORMPROB(ZRESID).


GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sqft_living price MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: sqft_living=col(source(s), name("sqft_living")) 
  DATA: price=col(source(s), name("price")) 
  GUIDE: axis(dim(1), label("sqft_living")) 
  GUIDE: axis(dim(2), label("price")) 
  ELEMENT: point(position(sqft_living*price)) 
  ELEMENT: line(position(smooth.loess(sqft_living*price)))
END GPL.



GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=grade price MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: grade=col(source(s), name("grade")) 
  DATA: price=col(source(s), name("price")) 
  GUIDE: axis(dim(1), label("grade")) 
  GUIDE: axis(dim(2), label("price")) 
  ELEMENT: point(position(grade*price)) 
  ELEMENT: line(position(smooth.loess(grade*price)))
END GPL.


REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT Residuals_sqared 
  /METHOD=ENTER sqft_living grade.


* Generalized linear model with robust estimators

GENLIN price WITH sqft_living grade 
  /MODEL sqft_living grade INTERCEPT=YES 
 DISTRIBUTION=NORMAL LINK=IDENTITY 
  /CRITERIA SCALE=MLE COVB=ROBUST PCONVERGE=1E-006(ABSOLUTE) SINGULAR=1E-012 ANALYSISTYPE=3(WALD) 
    CILEVEL=95 CITYPE=WALD LIKELIHOOD=FULL 
  /MISSING CLASSMISSING=EXCLUDE 
  /PRINT CPS DESCRIPTIVES MODELINFO FIT SUMMARY SOLUTION.

* Regression with wild bootstrapping

BOOTSTRAP
  /SAMPLING METHOD=WILD(RESIDUALS=RES_1)
  /VARIABLES TARGET=Fare INPUT=  Age  
  /CRITERIA CILEVEL=95 CITYPE=BCA  NSAMPLES=2000
  /MISSING USERMISSING=EXCLUDE.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT Fare
  /METHOD=ENTER Age
  /SCATTERPLOT=(*ZRESID ,*ZPRED).


* Regression with main effect of longitude and latitude

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade long lat.


* Regression with main effect of longitude and latitude AND interaction

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade long lat INT_lat_long.

* Centering the variables of longitude and latitude and computing the interaction term again based on these centered values

COMPUTE lat_cntr=lat - 47.57. 
EXECUTE. 
COMPUTE long_cntr=long + 122.2. 
EXECUTE. 
COMPUTE INT_long_lat_cntr=lat_cntr * long_cntr. 
EXECUTE.

* Regression with main effect of centered longitude and latitude AND interaction to avoid multicollinearity

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade lat_cntr long_cntr INT_long_lat_cntr.

* Example of data multicollinearity

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade sqft_above.

