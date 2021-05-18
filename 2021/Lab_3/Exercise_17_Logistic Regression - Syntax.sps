* Encoding: UTF-8.

* Exploratory data analysis

* Crosstab

CROSSTABS
  /TABLES=has_heart_disease BY has_cp
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW PROP 
  /COUNT ROUND CELL.

* Stacked bar chart

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=has_heart_disease COUNT()[name="COUNT"] has_cp 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: has_heart_disease=col(source(s), name("has_heart_disease"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: has_cp=col(source(s), name("has_cp"), unit.category())
  GUIDE: axis(dim(1), label("has_heart_disease"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("has_cp"))
  GUIDE: text.title(label("Stacked Bar Count of has_heart_disease by has_cp"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(has_heart_disease*COUNT), color.interior(has_cp), 
    shape.interior(shape.square))
END GPL.

*Explore by group

EXAMINE VARIABLES=trestbps thalach BY has_heart_disease
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

*Box plots

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=has_heart_disease trestbps MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: has_heart_disease=col(source(s), name("has_heart_disease"), unit.category())
  DATA: trestbps=col(source(s), name("trestbps"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("has_heart_disease"))
  GUIDE: axis(dim(2), label("trestbps"))
  GUIDE: text.title(label("Simple Boxplot of trestbps by has_heart_disease"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(has_heart_disease*trestbps)), label(id))
END GPL.


GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=has_heart_disease thalach MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: has_heart_disease=col(source(s), name("has_heart_disease"), unit.category())
  DATA: thalach=col(source(s), name("thalach"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("has_heart_disease"))
  GUIDE: axis(dim(2), label("thalach"))
  GUIDE: text.title(label("Simple Boxplot of thalach by has_heart_disease"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(has_heart_disease*thalach)), label(id))
END GPL.


*Visualize linear regression relationship

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=thalach disease_status MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE 
  /FITLINE TOTAL=NO. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: thalach=col(source(s), name("thalach")) 
  DATA: disease_status=col(source(s), name("disease_status"), unit.category()) 
  GUIDE: axis(dim(1), label("thalach")) 
  GUIDE: axis(dim(2), label("disease_status")) 
  GUIDE: text.title(label("Simple Scatter of disease_status by thalach")) 
  ELEMENT: point(position(thalach*disease_status)) 
END GPL.


*Recode string into binary numeric variable

RECODE disease_status ('heart_disease'=1) ('no_heart_disease'=0) INTO has_heart_disease. 
EXECUTE.

*Recode cp into has_cp

RECODE cp (0=0) (MISSING=SYSMIS) (ELSE=1) INTO has_cp. 
EXECUTE.

*Logistic regression analysis

LOGISTIC REGRESSION VARIABLES has_heart_disease
  /METHOD=ENTER has_cp trestbps thalach
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).
 
*Logistic regression analysis through multinomial regression procedure

NOMREG has_heart_disease (BASE=FIRST ORDER=ASCENDING) WITH has_cp trestbps thalach
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001) 
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.









