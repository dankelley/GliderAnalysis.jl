using DataFrames, CSV, Plots
using GMT: lonlat2xy, xy2lonlat

"""
    lonlat_xy(longitude, latitude; case=:halifax_line, debug=0)

Convert `longitude` and `latitude` vectors to a matrix with columns equal to x
and y (in km). The transformation is governed by the `case` keyword (which has
a default value that is useful along the Halifax Line on the Scotian Shelf, off
Nova Scotia). See also [`xy_lonlat`](@ref), which handles the reverse
operation.

# Arguments

- `longitude` vector of longitudes
- `latitude` vector of longitudes

# Keywords

- `case` either the symbol `:halifax_line` (which is the default) or a
  NamedTuple containing the elements `longitude0` (the zero of new coordinate
  system), `latitude0` (the zero of new coordinate system), `angle` (the
  counterclockwise angle of new coordinate system to an east-north system
  and `srs` (the coordinate transformation code). By default, `case=(longitude0=-63.507773, latitude0=44.623249, angle=-59.1879,
  srs="EPSG:32620")`.  See Reference 1 for information on this default
  `srs` value.

- `debug` an Integer indicating the degree of printing to be done during
  processing. Use `debug=0` (the default) to work silently, or a higher value to
  indicate to print some information about the working steps.

# References

1. [https://epsg.io/32620](https://epsg.io/32620) states the scope of
   EPSG:32620 to be navigation at medium accuracy, with application to
   latitudes from the equator to 84°N and longitudes from 66°W to 60°W.

# Examples

```julia
using GliderAnalysis, Plots, DataFrames, CSV

file = joinpath(dirname(dirname(pathof(GliderAnalysis))), "data", "sbloom_2023_traj.csv.gz")
traj = CSV.read(file, DataFrame);

xy = lonlat_xy(traj.longitude, traj.latitude);

KW = (framestyle=:box, tickdirection=:out, label=false, ms=1, guidefontsize=7, tickfontsize=7, titlefontsize=7)
a = Plots.scatter(traj.longitude, traj.latitude, aspect_ratio=1.4,
    xlab="Longitude", ylab="Latitude", title=file; KW...)
b = Plots.scatter(xy[:, 1], xy[:, 2], aspect_ratio=1.0,
    xlab="Easting [km]", ylab="Northing [km]"; KW...)
Plots.plot(a, b, layout=(1, 2), size=(800, 500))
```
"""
function lonlat_xy(longitude, latitude; case=:halifax_line, debug=0)
    gad(debug, "lonlat_xy() START")
    # set up parameters
    if case == :halifax_line
        case = (longitude0=-63.507773, latitude0=44.623249, angle=59.1879, srs="EPSG:32620")
    elseif !isa(case, NamedTuple)
        error("if case is not a Symbol, then it must be a NamedTuple")
    end
    length(case) == 4 || error("case must be a NamedTuple with 4 elements")
    if !issubset((:angle, :latitude0, :longitude0, :srs), keys(case))
        error("case elements must be named ':angle`, `:latitude0`, `:longitude` and `:srs`, but they are named: $(sort(keys(case)))")
    end
    gad(debug, "  case=$case")
    xy0 = 0.001 * lonlat2xy([case.longitude0 case.latitude0], t_srs=case.srs)
    θ = case.angle * pi / 180.0
    R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    gad(debug, "  computed rotation matrix $(round.(R,digits=3))")
    ll = hcat(longitude, latitude)
    gad(debug, "  about to call lonlat2xy2() to compute xy")
    xy = 0.001 * lonlat2xy(ll, t_srs=case.srs) .- xy0
    gad(debug, "  about to rotate xy matrix")
    rval = xy * R'
    gad(debug, "END lonlat_xy()")
    return rval
end
export lonlat_xy


"""
    xy_lonlat(x, y; case=:halifax_line, debug=0)

Convert `x` and `y` vectors (in km) to a matrix with column 1 being `longitude`
and column 2 being `latitude`. The transformation is governed by the `case`
keyword (which has a default value that is useful along the Halifax Line on the
Scotian Shelf, off Nova Scotia). See also [`lonlat_xy`](@ref), which handles
the reverse operation.

# Arguments

- `x` vector of x values (in km)
- `y` vector of y values (in km)

# Keywords

- `case` either the symbol `:halifax_line` (which is the default) or a
  NamedTuple containing the elements `longitude0` (the zero of new coordinate
  system), `latitude0` (the zero of new coordinate system), `angle` (the
  counterclockwise angle of new coordinate system to an east-north system
  and `srs` (the coordinate transformation code). By default, `case=(longitude0=-63.507773, latitude0=44.623249, angle=-59.1879,
  srs="EPSG:32620")`.  See Reference 1 for information on this default
  `srs` value.

- `debug` an Integer indicating the degree of printing to be done during
  processing. Use `debug=0` (the default) to work silently, or a higher value to
  indicate to print some information about the working steps.

# References

1. [https://epsg.io/32620](https://epsg.io/32620) states the scope of
   EPSG:32620 to be navigation at medium accuracy, with application to
   latitudes from the equator to 84°N and longitudes from 66°W to 60°W.

# Examples

```julia
using GliderAnalysis, Plots, DataFrames, CSV

xy_lonlat(0.0, 0.0) # columns are case.longitude0 and case.latitude0
```
"""
function xy_lonlat(x, y; case=:halifax_line, debug=0)
    gad(debug, "xy_lonlat() START")
    # set up parameters
    if case == :halifax_line
        case = (longitude0=-63.507773, latitude0=44.623249, angle=59.1879, srs="EPSG:32620")
    elseif !isa(case, NamedTuple)
        error("if case is not a Symbol, then it must be a NamedTuple")
    end
    length(case) == 4 || error("case must be a NamedTuple with 4 elements")
    if !issubset((:angle, :latitude0, :longitude0, :srs), keys(case))
        error("case elements must be named ':angle`, `:latitude0`, `:longitude` and `:srs`, but they are named: $(sort(keys(case)))")
    end
    gad(debug, "  case=$case")
    xy0 = 0.001 * lonlat2xy([case.longitude0 case.latitude0], t_srs=case.srs)
    θ = -case.angle * pi / 180.0
    R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    gad(debug, "  computed rotation matrix $(round.(R,digits=3))")
    xy = hcat(x, y)
    xy = xy * R' .+ xy0
    gad(debug, "  about to call xy2lonlat() to compute lonlat")
    lonlat = xy2lonlat(1000.0 * xy, s_srs=case.srs, t_srs="+proj=longlat +datum=WGS84")
    gad(debug, "END lonlat_xy()")
    return lonlat
end
export xy_lonlat

