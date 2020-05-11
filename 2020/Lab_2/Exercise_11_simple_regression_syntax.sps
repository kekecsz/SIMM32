* Encoding: UTF-8.
*Frequencies

FREQUENCIES VARIABLES=gender height shoesize 
  /ORDER=ANALYSIS.

*Describe

DESCRIPTIVES VARIABLES=height shoesize 
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

*Explore

EXAMINE VARIABLES=height shoesize 
  /PLOT BOXPLOT HISTOGRAM NPPLOT 
  /COMPARE GROUPS 
  /STATISTICS DESCRIPTIVES 
  /CINTERVAL 95 
  /MISSING LISTWISE 
  /NOTOTAL.

*scatterplot

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=height shoesize MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: height=col(source(s), name("height")) 
  DATA: shoesize=col(source(s), name("shoesize")) 
  GUIDE: axis(dim(1), label("height")) 
  GUIDE: axis(dim(2), label("shoesize")) 
  ELEMENT: point(position(height*shoesize)) 
END GPL.

*simple regression

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT shoesize 
  /METHOD=ENTER height 

*scatterplot with regression line

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=height shoesize MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: height=col(source(s), name("height")) 
  DATA: shoesize=col(source(s), name("shoesize")) 
  GUIDE: axis(dim(1), label("height")) 
  GUIDE: axis(dim(2), label("shoesize")) 
  ELEMENT: point(position(height*shoesize)) 
  ELEMENT: line(position(smooth.linear(height*shoesize)))
END GPL.

*compute predicted value

COMPUTE predicted_value=3.36 + 0.21 * 170.
EXECUTE.

*get predicted values and residuals

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT shoesize 
  /METHOD=ENTER height 
  /SAVE PRED RESID.

