﻿* Encoding: UTF-8.

DATASET ACTIVATE DataSet3.
* plot with one regression line.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class_rec MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=NO SUBGROUP=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: weight=col(source(s), name("weight")) 
  DATA: sandwich_taken=col(source(s), name("sandwich_taken")) 
  DATA: class_rec=col(source(s), name("class_rec"), unit.category()) 
  GUIDE: axis(dim(1), label("weight")) 
  GUIDE: axis(dim(2), label("sandwich_taken")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class_rec")) 
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class_rec")) 
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class_rec)) 
ELEMENT: line(position(smooth.linear(weight*sandwich_taken)))
END GPL.


* Plot with one line for each class.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class_rec MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=NO SUBGROUP=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: weight=col(source(s), name("weight")) 
  DATA: sandwich_taken=col(source(s), name("sandwich_taken")) 
  DATA: class_rec=col(source(s), name("class_rec"), unit.category()) 
  GUIDE: axis(dim(1), label("weight")) 
  GUIDE: axis(dim(2), label("sandwich_taken")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class_rec")) 
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class_rec")) 
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class_rec)) 
  ELEMENT: line(position(smooth.linear(weight*sandwich_taken)), split(class_rec))
END GPL.

* Plot with one line for each class, extended x and y axis to see intercept.
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class_rec MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=NO SUBGROUP=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: weight=col(source(s), name("weight")) 
  DATA: sandwich_taken=col(source(s), name("sandwich_taken")) 
  DATA: class_rec=col(source(s), name("class_rec"), unit.category()) 
  GUIDE: axis(dim(1), label("weight")) 
  GUIDE: axis(dim(2), label("sandwich_taken")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class_rec")) 
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class_rec")) 
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class_rec)) 
  ELEMENT: line(position(smooth.linear(weight*sandwich_taken)), split(class_rec))
END GPL.

* Same plot for Bully_slpoe dataset. 
GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=weight sandwich_taken class_rec MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=NO SUBGROUP=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: weight=col(source(s), name("weight")) 
  DATA: sandwich_taken=col(source(s), name("sandwich_taken")) 
  DATA: class_rec=col(source(s), name("class_rec"), unit.category()) 
  GUIDE: axis(dim(1), label("weight")) 
  GUIDE: axis(dim(2), label("sandwich_taken")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("class_rec")) 
  GUIDE: text.title(label("Grouped Scatter of sandwich_taken by weight by class_rec")) 
  SCALE: linear(dim(1), min(0)  )
  SCALE: linear(dim(2), max(30)  )
  ELEMENT: point(position(weight*sandwich_taken), color.interior(class_rec)) 
  ELEMENT: line(position(smooth.linear(weight*sandwich_taken)), split(class_rec))
END GPL.


* Simple fixed effect linear regression model.
REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT sandwich_taken
  /METHOD=ENTER weight.

MIXED sandwich_taken WITH weight
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(class) COVTYPE(VC).

MIXED sandwich_taken WITH weight
  /CRITERIA=CIN(95) MXITER(100) MXSTEP(10) SCORING(1) SINGULAR(0.000000000001) HCONVERGE(0, 
    ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)
  /FIXED=weight | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT weight | SUBJECT(class) COVTYPE(UN).


