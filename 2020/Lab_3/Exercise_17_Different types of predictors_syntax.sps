* Encoding: UTF-8.
 
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

* Dummy code gender

RECODE gender ('male'=1) (ELSE=0) INTO male. 
EXECUTE.

* Dummy code treatment_type

RECODE treatment_type ('pill'=1) (ELSE=0) INTO treatment_pill. 
EXECUTE.

RECODE treatment_type ('psychotherapy'=1) (ELSE=0) INTO treatment_psychotherapy. 
EXECUTE.

RECODE treatment_type ('treatment_3'=1) (ELSE=0) INTO treatment_treatment_3. 
EXECUTE.

* Regression with categorical predictors

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER treatment_pill treatment_psychotherapy treatment_treatment_3.

* Regression with categorical and continuous predictors

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER treatment_pill treatment_psychotherapy treatment_treatment_3 motivation.

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

* Compute the quadratic term of body_acceptance

COMPUTE body_acceptance_quadratic=body_acceptance*body_acceptance. 
EXECUTE.

* Regression model with higher order term

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER body_acceptance body_acceptance_quadratic.

* Recode for interaction alaysis

RECODE treatment_type ('pill'=1) ('treatment_3'=1) (ELSE=0) INTO received_pill. 
EXECUTE.

RECODE treatment_type ('psychotherapy'=1) ('treatment_3'=1) (ELSE=0) INTO received_psychotherapy. 
EXECUTE.

* Explore interaction effect via line chart

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=received_pill 
    MEAN(BMI_post_treatment)[name="MEAN_BMI_post_treatment"] received_psychotherapy MISSING=LISTWISE 
    REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: received_pill=col(source(s), name("received_pill"), unit.category()) 
  DATA: MEAN_BMI_post_treatment=col(source(s), name("MEAN_BMI_post_treatment")) 
  DATA: received_psychotherapy=col(source(s), name("received_psychotherapy"), unit.category()) 
  GUIDE: axis(dim(1), label("received_pill")) 
  GUIDE: axis(dim(2), label("Mean BMI_post_treatment")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("received_psychotherapy")) 
  SCALE: linear(dim(2), include(30)) 
  ELEMENT: line(position(received_pill*MEAN_BMI_post_treatment), 
    color.interior(received_psychotherapy), missing.wings()) 
END GPL.


* 2 x 2 ANOVA

UNIANOVA BMI_post_treatment BY received_pill received_psychotherapy 
  /METHOD=SSTYPE(3) 
  /INTERCEPT=INCLUDE 
  /PLOT=PROFILE(received_psychotherapy*received_pill) 
  /EMMEANS=TABLES(received_pill*received_psychotherapy) 
  /EMMEANS=TABLES(received_pill) 
  /EMMEANS=TABLES(received_psychotherapy) 
  /PRINT=ETASQ PARAMETER HOMOGENEITY 
  /CRITERIA=ALPHA(.05) 
  /DESIGN=received_pill received_psychotherapy received_pill*received_psychotherapy.

* Compute the interaction term manually

COMPUTE INT_pill_x_psychotherapy=received_pill * received_psychotherapy. 
EXECUTE.

* 2x2 ANOVA with linear regression

REGRESSION 
  /MISSING LISTWISE 
  /STATISTICS COEFF OUTS CI(95) R ANOVA 
  /CRITERIA=PIN(.05) POUT(.10) 
  /NOORIGIN 
  /DEPENDENT BMI_post_treatment 
  /METHOD=ENTER received_pill received_psychotherapy INT_pill_x_psychotherapy.


