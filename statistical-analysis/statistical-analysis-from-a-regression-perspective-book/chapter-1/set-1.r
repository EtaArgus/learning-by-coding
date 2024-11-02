# Load data
data(airquality)
help(airquality)

require(graphics)
pairs(airquality, panel = panel.smooth, main = "airquality data")

attach(airquality)
summary(airquality)
pairs(airquality)

# Compare Ozone levels by Month
boxplot(Ozone ~ Day, data=airquality,
        main="Ozone Levels by Month",
        xlab="Month",
        ylab="Ozone (ppb)")

# 3D scatterplot with ozone concentrations as the
# response and temperature and wind speed as predictors.
library(rgl)

# Create the 3D scatterplot
plot3d(x = airquality$Temp,      # Temperature on x-axis
       y = airquality$Wind,       # Wind on y-axis
       z = airquality$Ozone,      # Ozone on z-axis
       xlab = "Temperature (°F)",
       ylab = "Wind Speed (mph)",
       zlab = "Ozone (ppb)",
       col = "blue",
       type = "s",               # 's' for spheres
       size = 1)

# Add a title
title3d(main = "3D Scatterplot of Ozone vs Temperature and Wind")

# Using scatterplot3d with color gradient
library(scatterplot3d)
library(RColorBrewer)

# Create color gradient
colors <- colorRampPalette(c("blue", "red"))(100)
color_index <- cut(airquality$Ozone, breaks = 100)

# Create the enhanced 3D scatterplot
s3d <- scatterplot3d(x = airquality$Temp, 
                     y = airquality$Wind, 
                     z = airquality$Ozone,
                     main = "3D Scatterplot of Ozone vs Temperature and Wind",
                     xlab = "Temperature (°F)",
                     ylab = "Wind Speed (mph)",
                     zlab = "Ozone (ppb)",
                     color = colors[color_index],
                     pch = 16,
                     angle = 45)

# Add a regression plane (optional)
fit <- lm(Ozone ~ Temp + Wind, data = airquality)
s3d$plane3d(fit, col = "gray", alpha = 0.5)


# Conditioning plot with ozone concentrations as the response, temperature as a predictor, 
# and wind speed as # a conditioning variable # Install and load ggplot2 if needed
if (!require(ggplot2)) install.packages("ggplot2")
library(ggplot2)

# Create bins for Wind speed
airquality$Wind_bins <- cut(airquality$Wind, 
                           breaks = 6, 
                           labels = paste("Wind:", 
                                        round(seq(min(airquality$Wind, na.rm=TRUE), 
                                                max(airquality$Wind, na.rm=TRUE), 
                                                length.out=6), 1)))

# Create the plot
ggplot(airquality, aes(x = Temp, y = Ozone)) +
  geom_point(color = "darkblue", alpha = 0.6) +
  geom_smooth(method = "loess", color = "red") +
  geom_smooth(method = "lm", color = "green3", linetype = "dashed") +
  facet_wrap(~Wind_bins, ncol = 3) +
  theme_bw() +
  labs(title = "Ozone vs Temperature Conditioned on Wind Speed",
       x = "Temperature (°F)",
       y = "Ozone (ppb)") +
  theme(panel.grid.minor = element_line(color = "gray90"))


# The same using lattice
if (!require(lattice)) install.packages("lattice")
library(lattice)

# Create the plot
xyplot(Ozone ~ Temp | equal.count(Wind, number=6, overlap=0.25),
       data = airquality,
       panel = function(x, y, ...) {
           panel.grid(h = -1, v = -1, col = "gray90")
           panel.xyplot(x, y, col = "darkblue", pch = 16)
           panel.loess(x, y, col = "red", lwd = 2)
           panel.lmline(x, y, col = "green3", lty = 2)
       },
       xlab = "Temperature (°F)",
       ylab = "Ozone (ppb)",
       main = "Ozone vs Temperature Conditioned on Wind Speed",
       strip = strip.custom(bg = "lightblue"))

# 6. Construct and indicator variable for missing data for the variable Ozone.
# Cross-tabulate the indicator against month.
# Create indicator variable for missing Ozone
# Create the base table
ozone_missing <- is.na(airquality$Ozone)
ozone_table <- table(Month = airquality$Month, Ozone_Missing = ozone_missing)

# Calculate overall percentages
prop.table(ozone_table) * 100

# 7. Parametric model
# The model appears to be of the form:
# Ozone = β₀ + β₁(Temp) + β₂(Wind) + β₃(Temp × Wind) + ε

# In R code:
model <- lm(Ozone ~ Temp * Wind, data = airquality)

# Checking linearity assumptions
library(ggplot2)

# Create diagnostic plots
ggplot(airquality, aes(x = Temp, y = Ozone)) +
  geom_point() +
  geom_smooth(method = "loess") +
  facet_wrap(~cut(Wind, breaks = 6)) +
  labs(title = "Linearity Check Across Wind Levels")

# After fitting the model, check assumptions
model <- lm(Ozone ~ Temp * Wind, data = airquality)

# Diagnostic plots      
par(mfrow = c(2,2))
plot(model)
