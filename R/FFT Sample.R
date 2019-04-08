library(plotly)

Fs = 250   # sampling rate
dt = 1 / Fs  # seconds per sample
stop = 4   # number of seconds
t = seq(0, stop - dt, dt)

x = c(t, t, t, t)

y1 = sin(2 * pi * 2 * t)
y2 = sin(2 * pi * 4 * t)
y3 = sin(2 * pi * 8 * t)
y4 = rbind(y1, y2, y3)
y4 = colMeans(y4)
y1 = 0.25 * sin(2 * pi * 2 * t)
y2 = 0.5 * sin(2 * pi * 4 * t)
y3 = 0.75 * sin(2 * pi * 8 * t)
y = c(y3, y2, y1, y4)

z1 = rep('two', 1000)
z2 = rep('four', 1000)
z3 = rep('eight', 1000)
z4 = rep('avg', 1000)
z = factor(c(z3, z2, z1, z4))

data <- data.frame(x, y, z)

x = seq(1, 12, 0.25)
y = fft(y4)
y = y / length(x)
y = y[1:500]
y = abs(y)
y = y ^ 2
y = 2 * y
y = y[-1]
y = y[1:45]

fftdata = data.frame(x, y)

{
  rm(y1,
     y2,
     y3,
     y4,
     z1,
     z2,
     z3,
     z4,
     x,
     y,
     z)
}

x1temp <- list(title = 'Time',
                font = list(
                  family = 'Arial',
                  size = 18,
                  color = c(0,0,0)
                ),
                showgrid = FALSE,
                showline = FALSE,
                showticklabels = FALSE,
                zeroline = FALSE)
x2temp <- list(title = 'Frequency',
               font = list(
                 family = 'Arial',
                 size = 18,
                 color = c(0,0,0)
               ),
               showgrid = FALSE,
               showline = FALSE,
               showticklabels = FALSE,
               zeroline = FALSE)
y1temp <- list(visible = FALSE)
y2temp <- list(visible = FALSE,
               showgrid = FALSE,
               showline = FALSE,
               showticklabels = FALSE,
               zeroline = FALSE)
z1temp <- list(
  visible = FALSE,
  type = 'catagory',
  catagoryorder = c('avg', 'two', 'four', 'eight')
)
c1temp = list(
  up = list(x = 0,
            y = 1,
            z = 0),
  center = list(x = 0,
                y = 0,
                z = 0),
  eye = list(x = 2,
             y = 1.5,
             z = -2)
)

scene1 = list(
  xaxis = x1temp,
  yaxis = y1temp,
  zaxis = z1temp,
  camera = c1temp,
  dragmode = 'orbit',
  hovermode = FALSE,
  aspectratio = list(x = 2,
                     y = 0.5,
                     z = 2)
)

{
  rm(
    x1temp,
    y1temp,
    z1temp,
    c1temp,
    dt,
    Fs,
    stop,
    t
  )
}

p1 <- plot_ly(
  data = data,
  x = ~ x,
  y = ~ y,
  z = ~ z,
  type = 'scatter3d',
  mode = 'lines',
  color = ~ z,
  showlegend = FALSE
) %>%
  layout(scene = scene1)
p1

p2 <- plot_ly(
  data = fftdata,
  x = ~ x,
  y = ~ y,
  type = 'scatter',
  mode = 'lines',
  showlegend = FALSE
) %>%
  layout(xaxis = x2temp,
         yaxis = y2temp)
p2