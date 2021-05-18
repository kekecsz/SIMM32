* Encoding: UTF-8.
* Descriptives

FREQUENCIES VARIABLES=price sqft_living grade basement 
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=price sqft_living grade 
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

EXAMINE VARIABLES=price sqft_living grade 
  /PLOT BOXPLOT HISTOGRAM NPPLOT 
  /COMPARE GROUPS 
  /STATISTICS DESCRIPTIVES 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.

* Multiple regression

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT price 
  /METHOD=ENTER sqft_living grade.


* Simple regression plots

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
  ELEMENT: line(position(smooth.linear(grade*price)))
END GPL.

* Getting a prediction for new data

COMPUTE predicted_value=-174389.86 + new_sqft_living * 119.17 + new_grade * 57352.79. 
EXECUTE.

* Recoding string variable

RECODE basement ('no basement'=0) ('has basement'=1) INTO has_basement. 
EXECUTE.

