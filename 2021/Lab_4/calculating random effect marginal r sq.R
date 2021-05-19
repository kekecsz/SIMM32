library(lme4)
library(MuMIn)
library(insight)

data <- read.csv("https://raw.githubusercontent.com/kekecsz/SIMM32/master/2021/Lab_4/data_bully_slope.csv")

# random intercept model
random_intercept_model <- lmer(sandwich_taken ~ weight + (1|class), data = data)
summary(random_intercept_model)

# random slope model
random_slope_model <- lmer(sandwich_taken ~ weight + (weight|class), data = data)
summary(random_slope_model)


# according to Johnson's extension of Nakagawa & Schielzeth’s formula
Vf = get_variance(random_intercept_model)$var.fixed
Vr = get_variance(random_intercept_model)$var.random
Ve = get_variance(random_intercept_model)$var.residual

Rm = Vf / (Vf + Vr + Ve)
Rm
Rc = (Vf + Vr) / (Vf + Vr + Ve)
Rc
### givest the same result as:
r.squaredGLMM(random_intercept_model)



# according to Johnson's extension of Nakagawa & Schielzeth’s formula
Vf = get_variance(random_slope_model)$var.fixed
Vr = get_variance(random_slope_model)$var.random
Ve = get_variance(random_slope_model)$var.residual

Rm = Vf / (Vf + Vr + Ve)
Rm
Rc = (Vf + Vr) / (Vf + Vr + Ve)
Rc
### givest the same result as:
r.squaredGLMM(random_slope_model)


