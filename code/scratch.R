install.packages("plotly")
library(plotly)

# Create an interactive 3D scatter plot using the built-in 'iris' dataset
fig <- plot_ly(data = iris, 
               x = ~Sepal.Length, 
               y = ~Sepal.Width, 
               z = ~Petal.Length, 
               color = ~Species,          # Automatically colors by group and creates a legend
               type = "scatter3d", 
               mode = "markers",
               marker = list(size = 5))   # Adjust marker size

# Render the plot
fig
Use code with caution.Pros: Highly interactive (click and drag to rotate, scroll to zoom), easy group coloring, perfect for HTML notebooks or Shiny apps.2. Publication-Ready Static Plots: scatterplot3dIf you need a high-quality, fixed 3D figure for a PDF report, a research paper, or a print layout, scatterplot3d is the best choice.R# Install and load the package
install.packages("scatterplot3d")
library(scatterplot3d)

# Map distinct colors to groups
colors <- c("#999999", "#E69F00", "#56B4E9")
colors <- colors[as.numeric(iris$Species)]

# Generate a static 3D plot with drop lines to the floor
s3d <- scatterplot3d(x = iris$Sepal.Length, 
                     y = iris$Sepal.Width, 
                     z = iris$Petal.Length,
                     color = colors, 
                     pch = 16,             # Filled circles
                     type = "h",           # Draws vertical "high-density" drop lines
                     angle = 55,           # Adjust viewing angle
                     main = "Static 3D Scatter Plot",
                     xlab = "Sepal Length",
                     ylab = "Sepal Width",
                     zlab = "Petal Length")

###########

install.packages("rgl")
library(rgl)

# Open an RGL device window
open3d()

# Create the interactive plot
plot3d(x = iris$Sepal.Length, 
       y = iris$Sepal.Width, 
       z = iris$Petal.Length, 
       col = as.numeric(iris$Species), 
       type = "s",          # "s" renders data points as actual 3D spheres
       radius = 0.1,        # Adjust sphere radius
       size = 1)
Use code with caution.Pros: Exceptionally fast with vast amounts of data; supports advanced shapes and custom lighting.Cons: Can be difficult to configure in automated testing or headless server systems because it relies on desktop window management.Quick Comparison MatrixPackageInteractivityBest Used ForLearning Curveplotly🖱️ Fully interactive (Web)Web apps, presentations, HTML reportsGentle (similar to ggplot2)scatterplot3d❌ Static imageAcademic papers, print publicationsEasy (uses Base R graphics)rgl🖥️ Fully interactive (Desktop)Math surfaces, heavy datasets, complex 3D meshesModerate to AdvancedWhat kind of 3D chart are you looking to build?3D Scatter Plot3D Surface / Terrain Plot3D Line PlotFitting a Regression PlaneStack OverflowPlot 3D data in R - Stack OverflowPlot 3D data in R · wireframe plot. Or how about this (modification of fig 6.3 in Deepanyan Sarkar's book): · Multiple wireframe p...Datanoviascatterplot3d in R: 3D Scatter Plots Made Easy - DatanoviaAdd pch , color and angle to style and rotate it. NoteHow do I colour points by group in scatterplot3d? Build a per-point colour v...Datanovia3D Scatter Plots in R: Static with scatterplot3d and Interactive with ...Length, color = ~Species, type = "scatter3d", mode = "markers") . It renders a WebGL widget you can drag to rotate, scroll to zoom...Show allwhat about for 3D sections, like for raster dataFor raster data (such as Digital Elevation Models (DEMs), climate grids, or satellite imagery), your approach changes. Instead of plotting individual points, you are rendering a matrix or surface grid.To plot rasters in 3D and slice cross-sections (transects), the R ecosystem relies on rayshader for high-end maps and terra with plotly for analytical cross-sections.1. Photorealistic 3D Rasters: rayshaderrayshader is the absolute gold standard for mapping raster data. It converts a standard raster matrix into a 3D landscape using raytracing, shading algorithms, and textured overlays. It also automatically creates a physical "solid base" wall underneath your raster, which effectively acts as a 3D sectional block.R# Install packages
install.packages(c("terra", "rayshader"))
library(terra)
library(rayshader)

# Load a raster (we will use rayshader's built-in Monterey Bay dataset)
# If using your own raster: my_raster <- rast("path_to_file.tif")
data("montereybay")

# 1. Generate the texture and raytrace shadows
matrix_map <- montereybay
textured_map <- matrix_map %>%
  sphere_shade(texture = "desert") %>%
  add_shadow(ray_shade(matrix_map, zscale = 50), 0.5)

# 2. Render the interactive 3D scene with solid volumetric edges
plot_3d(textured_map, matrix_map, 
        zscale = 50,          # Exaggerates or shrinks vertical scale
        solid = TRUE,         # Creates the structural cross-section "walls"
        soliddepth = -200,    # Where the bottom base cuts off
        solidcolor = "grey20",
        water = TRUE,         # Renders a realistic water plane
        zwaterline = 0, 
        windowsize = c(1000, 800))