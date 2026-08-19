using DataFrames, CSV, Plots
using GMT: lonlat2xy, xy2lonlat

const M_PER_KM = 1000.0

"""
    handle_case(case)

Internal-use function used by both `lonlat_xy()` and `xy_lonlat()`.

"""
function handle_case(case)
    if case == :halifax_line
        return (longitude0=-63.507773, latitude0=44.623249, angle=59.1879, srs="EPSG:32620")
    else
        isa(case, NamedTuple) || error("'case' must be either :halifax_line or a NamedTuple")
        issubset((:angle, :latitude0, :longitude0, :srs), keys(case)) ||
            error("case elements must be named `:angle`, `:latitude0`, `:longitude` and `:srs`, but they are named: $(sort(keys(case)))")
        return case
    end
end

"""
    lonlat_xy(longitude, latitude; case=:halifax_line, debug=0)

Convert `longitude` and `latitude` vectors to a matrix with columns equal to
`x` and `y` (in km). The transformation is governed by the `case` keyword
(which has a default value that is useful along the Halifax Line on the Scotian
Shelf, off Nova Scotia). See also [`xy_lonlat`](@ref), which handles the
reverse operation.

# Arguments

- `longitude` vector of longitudes
- `latitude` vector of longitudes

# Keywords

- `case` either the symbol `:halifax_line` (which is the default) or a
  NamedTuple containing the elements `longitude0` (the zero of new coordinate
  system), `latitude0` (the zero of new coordinate system), `angle` (the
  counterclockwise angle that rotates the lon-lat coordinate system to the x-y
  coordinate system) and `srs` (the coordinate transformation code). By default,
  `case=(longitude0=-63.507773, latitude0=44.623249, angle=-59.1879,
  srs="EPSG:32620")`.   It is important to use the same `case` for both
  [`lonlat_xy`](@ref) and [`xy_lonlat`](@ref), for calculations going
  back and forth between the two coordinate systems. See Reference 1
  for information on this default `srs` value.

- `debug` an Integer indicating the degree of printing to be done during
  processing. Use `debug=0` (the default) to work silently, or a higher value to
  indicate to print some information about the working steps.

# Return value

`lonlat_xy()` returns a NamedTuple with entries `x` and `y`, both coordinates in km.

# References

1. [https://epsg.io/32620](https://epsg.io/32620) states the scope of
   EPSG:32620 to be navigation at medium accuracy, with application to
   latitudes from the equator to 84°N and longitudes from 66°W to 60°W.

# Examples

```julia
using GliderAnalysis, Plots, DataFrames, CSV

file = joinpath(dirname(dirname(pathof(GliderAnalysis))), "data", "sbloom_2023_traj.csv.gz")
traj = CSV.read(file, DataFrame);

x, y = lonlat_xy(traj.longitude, traj.latitude);

KW = (framestyle=:box, tickdirection=:out, label=false, ms=1, guidefontsize=7, tickfontsize=7, titlefontsize=7)
a = Plots.scatter(traj.longitude, traj.latitude, aspect_ratio=1.4,
    xlab="Longitude", ylab="Latitude", title=file; KW...)
b = Plots.scatter(x, y, aspect_ratio=1.0,
    xlab="Easting [km]", ylab="Northing [km]"; KW...)
Plots.plot(a, b, layout=(1, 2), size=(800, 500))
```
"""
function lonlat_xy(longitude, latitude; case=:halifax_line, debug=0)
    gad(debug, "lonlat_xy() START")
    case = handle_case(case)
    gad(debug, "  case=$case")
    xy0 = lonlat2xy([case.longitude0 case.latitude0], t_srs=case.srs)
    θ = case.angle * pi / 180.0
    R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    gad(debug, "  computed rotation matrix $(round.(R,digits=3))")
    length(longitude) == length(latitude) || error("lengths of 'longitude' and 'latitude' differ")
    ll = hcat(longitude, latitude)
    gad(debug, "  about to call lonlat2xy2() to compute xy")
    xy = (lonlat2xy(ll, t_srs=case.srs) .- xy0) / M_PER_KM
    gad(debug, "  about to rotate xy matrix")
    rval = xy * R'
    gad(debug, "END lonlat_xy()")
    return (x=rval[:, 1], y=rval[:, 2])
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
  counterclockwise angle that rotates the lon-lat coordinate system to the x-y
  coordinate system) and `srs` (the coordinate transformation code). By default,
  `case=(longitude0=-63.507773, latitude0=44.623249, angle=-59.1879,
  srs="EPSG:32620")`. It is important to use the same `case` for both
  [`lonlat_xy`](@ref) and [`xy_lonlat`](@ref), for calculations going
  back and forth between the two coordinate systems. See Reference 1
  for information on the default `srs` value.

- `debug` an Integer indicating the degree of printing to be done during
  processing. Use `debug=0` (the default) to work silently, or a higher value to
  indicate to print some information about the working steps.

# Return value

`xy_lonlat()` returns a NamedTuple with entries `longitude` and `latitude`,
both coordinates in degrees.

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
    case = handle_case(case)
    gad(debug, "  case=$case")
    xy0 = lonlat2xy([case.longitude0 case.latitude0], t_srs=case.srs) / M_PER_KM
    # Note the negative sign, as we are rotating back to lonlat from xy here
    θ = -case.angle * pi / 180.0
    R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
    gad(debug, "  computed rotation matrix $(round.(R,digits=3))")
    xy = hcat(x, y)
    xy = xy * R' .+ xy0
    gad(debug, "  about to call xy2lonlat() to compute lonlat")
    lonlat = xy2lonlat(M_PER_KM * xy, s_srs=case.srs, t_srs="+proj=longlat +datum=WGS84")
    gad(debug, "END lonlat_xy()")
    return (longitude=lonlat[:, 1], latitude=lonlat[:, 2])
end
export xy_lonlat

