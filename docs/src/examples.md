# Examples

## Transect lon-lat to x-y calculation

![Transect coordinate system](lonlat_xy.png)

```julia
using GliderAnalysis, Plots, DataFrames, CSV

file = joinpath(dirname(dirname(pathof(GliderAnalysis))), "data", "sbloom_2023_traj.csv.gz")
traj = CSV.read(file, DataFrame);

xy = lonlat_xy(traj.longitude, traj.latitude)

fs = 7
KW = (framestyle=:box, tickdirection=:out, label=false, ms=1, guidefontsize=fs, tickfontsize=fs, titlefontsize=fs)
a = Plots.scatter(traj.longitude, traj.latitude, aspect_ratio=1.4, xlab="Longitude", ylab="Latitude", title=file; KW...)
b = Plots.scatter(xy[:, 1], xy[:, 2], aspect_ratio=1.0, xlab="Easting [km]", ylab="Northing [km]", title="Using lonlat_xy()"; KW...)
Plots.vline!([0], lwd=3, color=:red, label=false)
Plots.plot(a, b, layout=(1, 2), size=(800, 500))

savefig("lonlat_xy.png")
```


