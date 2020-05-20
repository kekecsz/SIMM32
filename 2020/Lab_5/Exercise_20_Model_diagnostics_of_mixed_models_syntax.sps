* Encoding: UTF-8.
*dummy code location.
RECODE location ('north_wing'=0) ('south_wing'=1) INTO south_wing. 
EXECUTE.

*restructure from wide to long.
VARSTOCASES 
  /MAKE wound_healing FROM day_1 day_2 day_3 day_4 day_5 day_6 day_7 
  /INDEX=time(7) 
  /KEEP=ID distance_window south_wing 
  /NULL=KEEP.

*We center the variable ‘time’ to avoid problems with multicollinearity.
DESCRIPTIVES VARIABLES=time 
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE centered_time=time-4. 
EXECUTE.


*Create a new variable which contains the squared value of the centered time. 
COMPUTE centered_time_sq=centered_time*centered_time.
EXECUTE.

*Build the mixed model with random intercept

MIXED wound_healing WITH distance_window south_wing centered_time centered_time_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=distance_window south_wing centered_time centered_time_sq | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=RESID PRED.

*Examine outliers.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(wound_healing)[name="MEAN_wound_healing"] 
    ID MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: time=col(source(s), name("time"), unit.category()) 
  DATA: MEAN_wound_healing=col(source(s), name("MEAN_wound_healing")) 
  DATA: ID=col(source(s), name("ID"), unit.category()) 
  GUIDE: axis(dim(1), label("time")) 
  GUIDE: axis(dim(2), label("Mean wound_healing")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: line(position(time*MEAN_wound_healing), color.interior(ID), missing.wings()) 
END GPL.

EXAMINE VARIABLES=wound_healing BY ID 
  /PLOT BOXPLOT.

*Examine normality of residuals.
EXAMINE VARIABLES=RESID_1
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Investigate linearity and homoscedasticity using the residuals and the predicted values plot.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PRED_1 RESID_1 MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: PRED_1=col(source(s), name("PRED_1")) 
  DATA: RESID_1=col(source(s), name("RESID_1")) 
  GUIDE: axis(dim(1), label("Predicted Values")) 
  GUIDE: axis(dim(2), label("Residuals")) 
  ELEMENT: point(position(PRED_1*RESID_1)) 
END GPL.


*Investigate linearity using the individuals predictors and residuals plots.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=distance_window RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: distance_window=col(source(s), name("distance_window"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("distance_window"))
  GUIDE: axis(dim(2), label("Residuals"))
  ELEMENT: point(position(distance_window*RESID_1))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=centered_time RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: centered_time=col(source(s), name("centered_time"))
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("centered_time"))
  GUIDE: axis(dim(2), label("Residuals"))
  ELEMENT: point(position(centered_time*RESID_1))
END GPL.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=centered_time_sq RESID_1 MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: centered_time_sq=col(source(s), name("centered_time_sq"), unit.category())
  DATA: RESID_1=col(source(s), name("RESID_1"))
  GUIDE: axis(dim(1), label("centered_time_sq"))
  GUIDE: axis(dim(2), label("Residuals"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(centered_time_sq*RESID_1))
END GPL.


*investigate multicollinearity using the correlation matrix of all predictors.
CORRELATIONS
  /VARIABLES=south_wing centered_time centered_time_sq distance_window
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.

*dummy code ID.
SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

*Compute the squared of the residuals.
COMPUTE RESID_1_sq=RESID_1*RESID_1.
EXECUTE.

*Linear model predicting the residusals squared value with the ID.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RESID_1_sq
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20 ID_dummy_21 ID_dummy_22 ID_dummy_23 ID_dummy_24 
    ID_dummy_25 ID_dummy_26 ID_dummy_27 ID_dummy_28 ID_dummy_29 ID_dummy_30.


*Building a random slope model to check for correlation of random effects

MIXED wound_healing WITH distance_window south_wing time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=distance_window south_wing time | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN).
