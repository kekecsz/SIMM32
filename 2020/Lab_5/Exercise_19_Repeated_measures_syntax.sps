* Encoding: UTF-8.

RECODE location ('south_wing'=1) ('north_wing'=0) INTO south_wing.
EXECUTE.

CORRELATIONS
  /VARIABLES=day_1 day_2 day_3 day_4 day_5 day_6 day_7
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE. 
  
VARSTOCASES 
  /MAKE wound_healing FROM day_1 day_2 day_3 day_4 day_5 day_6 day_7 
  /INDEX=time(7) 
  /KEEP=ID distance_window south_wing 
  /NULL=KEEP.

MIXED wound_healing BY south_wing WITH distance_window time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=time south_wing distance_window | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.

MIXED wound_healing BY south_wing WITH distance_window time
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=time south_wing distance_window | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.


VARSTOCASES 
  /MAKE wound_healing FROM wound_healing pred_intercept pred_slope 
  /INDEX=obs_or_pred(wound_healing) 
  /KEEP=ID distance_window south_wing time 
  /NULL=KEEP.


SORT CASES  BY ID. 
SPLIT FILE SEPARATE BY ID.


GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(wound_healing)[name="MEAN_wound_healing"] 
    obs_or_pred MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: time=col(source(s), name("time"), unit.category()) 
  DATA: MEAN_wound_healing=col(source(s), name("MEAN_wound_healing")) 
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category()) 
  GUIDE: axis(dim(1), label("time")) 
  GUIDE: axis(dim(2), label("Mean wound_healing")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: line(position(time*MEAN_wound_healing), color.interior(obs_or_pred), missing.wings()) 
END GPL.

SPLIT FILE OFF.

DESCRIPTIVES VARIABLES=time 
  /STATISTICS=MEAN STDDEV MIN MAX.

COMPUTE time_centered=time-4. 
EXECUTE.

COMPUTE time_centered_sq=time_centered*time_centered.
EXECUTE.


MIXED wound_healing BY south_wing WITH time_centered time_centered_sq distance_window 
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=south_wing time_centered time_centered_sq distance_window | SSTYPE(3) 
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.


VARSTOCASES 
  /MAKE wound_healing FROM wound_healing pred_intercept pred_int_timesq 
  /INDEX=obs_or_pred(wound_healing) 
  /KEEP=ID distance_window south_wing time time_centered time_centered_sq 
  /NULL=KEEP.

SORT CASES  BY ID. 
SPLIT FILE SEPARATE BY ID.

GGRAPH 
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time MEAN(wound_healing)[name="MEAN_wound_healing"] 
    obs_or_pred MISSING=LISTWISE REPORTMISSING=NO 
  /GRAPHSPEC SOURCE=INLINE. 
BEGIN GPL 
  SOURCE: s=userSource(id("graphdataset")) 
  DATA: time=col(source(s), name("time"), unit.category()) 
  DATA: MEAN_wound_healing=col(source(s), name("MEAN_wound_healing")) 
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category()) 
  GUIDE: axis(dim(1), label("time")) 
  GUIDE: axis(dim(2), label("Mean wound_healing")) 
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred")) 
  SCALE: linear(dim(2), include(0)) 
  ELEMENT: line(position(time*MEAN_wound_healing), color.interior(obs_or_pred), missing.wings()) 
END GPL.


