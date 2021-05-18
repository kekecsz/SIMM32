* Encoding: UTF-8.
 
* Dummy code gender

RECODE gender ('male'=1) (ELSE=0) INTO male. 
EXECUTE.

* Dummy code treatment_type

RECODE treatment_type ('pill'=1) (ELSE=0) INTO treatment_pill. 
EXECUTE.

RECODE treatment_type ('psychotherapy'=1) (ELSE=0) INTO treatment_psychotherapy. 
EXECUTE.

RECODE treatment_type ('combined'=1) (ELSE=0) INTO treatment_combined. 
EXECUTE.

* Regression with categorical predictors

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER treatment_pill treatment_psychotherapy treatment_combined.

* Regression with categorical and continuous predictors

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER treatment_pill treatment_psychotherapy treatment_combined motivation.

* Recode string variable to be able to enter into ANOVA

AUTORECODE VARIABLES=treatment_type 
  /INTO treatment_type_num 
  /PRINT. 
 
* One-way ANOVA

 ONEWAY BMI_post_treatment BY treatment_type_num 
  /STATISTICS DESCRIPTIVES HOMOGENEITY 
  /PLOT MEANS 
  /MISSING ANALYSIS 
  /POSTHOC=BONFERRONI ALPHA(0.05).


* Regression model with only first order term of body_acceptance

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER body_acceptance.

* Scatterplot of body_acceptance and BMI, potential quadratic relationship

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=body_acceptance BMI_post_treatment MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: body_acceptance=col(source(s), name("body_acceptance")) 
  DATA: BMI_post_treatment=col(source(s), name("BMI_post_treatment")) 
  GUIDE: axis(dim(1), label("body_acceptance")) 
  GUIDE: axis(dim(2), label("BMI_post_treatment")) 
  ELEMENT: point(position(body_acceptance*BMI_post_treatment))
  ELEMENT: line(position(smooth.quadratic(body_acceptance*BMI_post_treatment)))
  ELEMENT: line(position(smooth.linear(body_acceptance*BMI_post_treatment)))
END GPL.

  * Centering body_acceptance
 
 DESCRIPTIVES VARIABLES=body_acceptance
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE body_acceptance_centered=body_acceptance - -1.88.
EXECUTE.


* Compute the quadratic term of body_acceptance

COMPUTE body_acceptance_centered_quadratic=body_acceptance_centered*body_acceptance_centered. 
EXECUTE.

* Regression model with higher order term

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment
  /METHOD=ENTER body_acceptance_centered body_acceptance_centered_quadratic.


* Explore interaction effect via line chart

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=lowcaldiet 
    MEAN(BMI_post_treatment)[name="MEAN_BMI_post_treatment"] exercise MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: lowcaldiet=col(source(s), name("lowcaldiet"), unit.category())
  DATA: MEAN_BMI_post_treatment=col(source(s), name("MEAN_BMI_post_treatment"))
  DATA: exercise=col(source(s), name("exercise"), unit.category())
  GUIDE: axis(dim(1), label("lowcaldiet"))
  GUIDE: axis(dim(2), label("Mean BMI_post_treatment"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("exercise"))
  GUIDE: text.title(label("Multiple Line Mean of BMI_post_treatment by lowcaldiet by exercise"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(lowcaldiet*MEAN_BMI_post_treatment), color.interior(exercise), 
    missing.wings())
END GPL.


* Compute the interaction term manually

COMPUTE INT_lowcaldiet_x_exercise=lowcaldiet*exercise.
EXECUTE.

* 2x2 ANOVA with linear regression

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment
  /METHOD=ENTER lowcaldiet exercise INT_lowcaldiet_x_exercise.

* 2 x 2 ANOVA

UNIANOVA BMI_post_treatment BY exercise lowcaldiet 
  /METHOD=SSTYPE(3) 
  /INTERCEPT=INCLUDE 
  /PLOT=PROFILE(lowcaldiet*exercise) 
  /EMMEANS=TABLES(exercise*lowcaldiet) 
  /EMMEANS=TABLES(exercise) 
  /EMMEANS=TABLES(lowcaldiet) 
  /PRINT=ETASQ PARAMETER HOMOGENEITY 
  /CRITERIA=ALPHA(.05) 
  /DESIGN=exercise lowcaldiet exercise*lowcaldiet.

