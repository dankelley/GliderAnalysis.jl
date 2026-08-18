#<R> transect <- list(
#<R>     landfall = list(longitude = -63.507773, latitude = 44.623249),
#<R>     centre = list(longitude = -62.75171, latitude = 43.70328),
#<R>     angle = -59.1879
#<R> )

using DataFrames, CSV, Plots
using GMT: lonlat2xy, xy2lonlat

"""
    transect_xy(longitude, latitude; case)

Convert `longitude` and `latitude` vectors to x and y vectors (in km).
The transformation is governed by the `case` keyword (which
has a default value that is useful along the Halifax Line
on the Scotian Shelf, off Nova Scotia).

# Arguments

- `longitude` vector of longitudes
- `latitude` vector of longitudes

# Keywords

- `case` either the symbol `:halifax_line` (which is the default) or a
  NamedTuple containing the elements `longitude0` (the zero of new coordinate
  system), `latitude0` (the zero of new coordinate system), `angle` (the
  counterclockwise angle of new coordinate system to an east-north system
  and `srs` (the coordinate transformation code). In the default case, the tuple
  defaults to `(longitude0=-63.507773, latitude0=44.623249, angle=-59.1879,
  srs="EPSG:32620")`.  See Ref 1 for information on this default
  `srs` value.

# References

1. https://epsg.io/32620 states the scope of EPSG:32620 to be navigation at
   medium accuracy, with application to latitudes from 0N to 84N and longitudes
   from 66W to 60W.

# Examples

```julia
using GliderAnalysis, Plots, DataFrames, CSV

file = joinpath(dirname(dirname(pathof(GliderAnalysis))), "data", "sbloom_2023_traj.csv.gz")
traj = CSV.read(file, DataFrame);

xy = transect_xy(traj.longitude, traj.latitude);

fs = 7
KW = (framestyle=:box, tickdirection=:out, label=false, ms=1, guidefontsize=fs, tickfontsize=fs, titlefontsize=fs)
a = Plots.scatter(traj.longitude, traj.latitude, aspect_ratio=1.4, xlab="Longitude", ylab="Latitude", title=file; KW...)
b = Plots.scatter(xy[:, 1], xy[:, 2], aspect_ratio=1.0, xlab="Easting [km]", ylab="Northing [km]", title="Using transect_xy()"; KW...)
Plots.vline!([0], lwd=3, color=:red, label=false)
Plots.plot(a, b, layout=(1, 2), size=(800, 500))
```

"""
function transect_xy(longitude, latitude; inverse=false, case=:halifax_line, debug=0)
    indent = repeat("  ", debug)
    debug == 0 || println("$indent transect_xy() START")
    isa(inverse, Bool) || error("'inverse' must be a Bool value")
    # set up parameters
    if case == :halifax_line
        case = (longitude0=-63.507773, latitude0=44.623249, angle=59.1879, srs="EPSG:32620")
    elseif !isa(case, NamedTuple)
        error("if case is not a Symbol, then it must be a NamedTuple")
    end
    length(case) == 4 || error("case must be a NamedTuple with 4 elements")
    if (:angle, :latitude0, :longitude0, :srs) != sort(collect(keys(case)))
        error("case elements must be named 'longitude0`, `latitude0`, `angle` and `srs`")
    end
    xy0 = 0.001 * lonlat2xy([case.longitude0 case.latitude0], t_srs=case.srs)
    debug == 0 || println("$indent   case=$case")
    if inverse
        debug == 0 || println("$indent   processing inverse=true case")
        θ = -case.angle * pi / 180.0
        R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
        debug == 0 || println("$indent   computed rotation matrix $(round.(R,digits=3))")
        xy = hcat(longitude, latitude) # lon and lat are actually x and y in inverse case
        xy = xy * R' .+ xy0
        debug == 0 || println("$indent   about to call xy2lonlat() to compute lonlat")
        lonlat = xy2lonlat(1000.0 * xy, s_srs=case.srs, t_srs="+proj=longlat +datum=WGS84")
        debug == 0 || println("$indent END transect_xy()")
        return lonlat
    else
        debug == 0 || println("$indent   processing inverse=false (i.e. default) case")
        θ = case.angle * pi / 180.0
        R = [cos(θ) -sin(θ); sin(θ) cos(θ)]
        debug == 0 || println("$indent   computed rotation matrix $(round.(R,digits=3))")
        ll = hcat(longitude, latitude)
        debug == 0 || println("$indent   about to call lonlat2xy2() to compute xy")
        xy = 0.001 * lonlat2xy(ll, t_srs=case.srs) .- xy0
        debug == 0 || println("$indent   about to rotate xy matrix")
        rval = xy * R'
        debug == 0 || println("$indent END transect_xy()")
        return rval
    end
end
export transect_xy

#```julia
#using GMT
#D = 0.1 # degrees offset
#lons = -63.507773 .+ [0, 0, D]
#lats = 44.623249 .+ [0, D, 0]
#t = transect_xy(lons, lats)
#err_x = round(100 * t[2, 1] / t[2, 2], digits=2)
#err_y = round(100 * t[3, 2] / t[3, 1], digits=2)
#println("for D: $D deg, errors err_x: $err_x%, err_y: $err_y%")
#```

