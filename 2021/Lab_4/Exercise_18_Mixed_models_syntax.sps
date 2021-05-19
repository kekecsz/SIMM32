* Encoding: UTF-8.

* plot with one regression line.

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=YES SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: weight=col(source(s), name("weight"))
  DATA: sandwich_taken=col(source(s), name("sandwich_taken"))
  DATA: class=col(source(s), name("class"), unit.category())
  GUIDE: axis(dim(1), label("weight"))
  GUIDE: axis(dim(2), label("sandwich_taken"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class"))
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class"))
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class))
END GPL.


* Plot with one line for each class.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: weight=col(source(s), name("weight"))
  DATA: sandwich_taken=col(source(s), name("sandwich_taken"))
  DATA: class=col(source(s), name("class"), unit.category())
  GUIDE: axis(dim(1), label("weight"))
  GUIDE: axis(dim(2), label("sandwich_taken"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class"))
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class"))
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: weight=col(source(s), name("weight"))
  DATA: sandwich_taken=col(source(s), name("sandwich_taken"))
  DATA: class=col(source(s), name("class"), unit.category())
  GUIDE: axis(dim(1), label("weight"))
  GUIDE: axis(dim(2), label("sandwich_taken"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class"))
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class"))
  SCALE: linear(dim(1), min(0))
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class))
END GPL.

* Same plot for Bully_slpoe dataset. 
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=YES.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: weight=col(source(s), name("weight"))
  DATA: sandwich_taken=col(source(s), name("sandwich_taken"))
  DATA: class=col(source(s), name("class"), unit.category())
  GUIDE: axis(dim(1), label("weight"))
  GUIDE: axis(dim(2), label("sandwich_taken"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class"))
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class"))
  SCALE: linear(dim(1), min(0))
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class))
END GPL.


* Simple fixed effect linear regression model.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT sandwich_taken
  /METHOD=ENTER weight.

* Random intercept model.
MIXED sandwich_taken WITH weight
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(class) COVTYPE(VC)
  /SAVE=PRED.

* Random slope model.
MIXED sandwich_taken WITH weight
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT weight | SUBJECT(class) COVTYPE(UN)
  /SAVE=PRED.

* Null model for the random slope model.
MIXED sandwich_taken WITH weight
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=| SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT weight | SUBJECT(class) COVTYPE(UN).

*Getting the variances for the conditional and marginal R^2 for a random intercept model

MIXED sandwich_taken WITH weight
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(class) COVTYPE(VC)
  /SAVE=FIXPRED.

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.

*Getting the variances for the conditional and marginal R^2 for a random slope model

MIXED sandwich_taken WITH weight
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT weight | SUBJECT(class) COVTYPE(UN)
  /SAVE=FIXPRED.

DESCRIPTIVES VARIABLES=sandwich_taken FXPRED_2
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.


