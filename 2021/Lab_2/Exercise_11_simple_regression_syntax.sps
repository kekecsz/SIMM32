* Encoding: UTF-8.
*Frequencies

FREQUENCIES VARIABLES=gender height shoe_size hours_of_practice_per_week exam_score
  /ORDER=ANALYSIS.

*Describe

DESCRIPTIVES VARIABLES=height shoe_size hours_of_practice_per_week exam_score
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

*Explore

EXAMINE VARIABLES=height shoe_size hours_of_practice_per_week exam_score
  /PLOT BOXPLOT STEMLEAF HISTOGRAM
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*scatterplot

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=height shoe_size MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: height=col(source(s), name("height")) 
  DATA: shoe_size=col(source(s), name("shoe_size")) 
  GUIDE: axis(dim(1), label("height")) 
  GUIDE: axis(dim(2), label("shoe_size")) 
  ELEMENT: point(position(height*shoe_size)) 
END GPL.

*simple regression

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT shoe_size 
  /METHOD=ENTER height. 

*scatterplot with regression line

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=height shoe_size MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: height=col(source(s), name("height")) 
  DATA: shoe_size=col(source(s), name("shoe_size")) 
  GUIDE: axis(dim(1), label("height")) 
  GUIDE: axis(dim(2), label("shoe_size")) 
  ELEMENT: point(position(height*shoe_size)) 
  ELEMENT: line(position(smooth.linear(height*shoe_size)))
END GPL.

*compute predicted value

COMPUTE predicted_value=3.37 + 0.21 * new_height_data.
EXECUTE.

*get predicted values and residuals

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT shoe_size 
  /METHOD=ENTER height 
  /SAVE PRED RESID.

*RSS

COMPUTE res_sq=RES_1 * RES_1.
EXECUTE.

DESCRIPTIVES VARIABLES=res_sq
  /STATISTICS=MEAN SUM STDDEV MIN MAX.

*TSS

DESCRIPTIVES VARIABLES=shoe_size
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE pred_mean=39.571429.
EXECUTE.

COMPUTE res_mean=shoe_size - pred_mean.
EXECUTE.

COMPUTE res_mean_sq=res_mean * res_mean.
EXECUTE.


DESCRIPTIVES VARIABLES=res_mean_sq
  /STATISTICS=MEAN SUM STDDEV MIN MAX.

*R squared

COMPUTE R_sq = 1-(91.15 / 341.71).
EXECUTE.

*Regression model summary

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT shoe_size
  /METHOD=ENTER height.
