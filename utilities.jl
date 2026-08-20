using Interpolations

"""
    increment_debug(debug::Integer=0)::Integer

Increment an integer (if it is positive). This is used in conjunction with
[`gad`](@ref) in many functions in this library.
"""
function increment_debug(debug::Integer=0)::Integer
    debug > 0 ? debug + 1 : 0
end

"""
    gad(debug::Integer=0, args...)

Print debugging information, if `debug`>0. Leading spaces are added in groups
of 4, for each integer by which `debug` exceeds 1. This is called by most
functions in this library.
"""
function gad(debug::Integer=0, args...)
    if debug > 0
        print(repeat("    ", debug - 1))
        for arg in args
            print(arg)
        end
        print("\n")
    end
end
export gad

"""
    depth_at_location(longitude, latitude, topo)

Use interpolation to find the depth at the stated locations, based
on a Topography object as read by `OceanAnalysis.read_topography()`.

# Arguments

- `longitude` vector of longitudes.

- `latitude` vector of latitudes.

- `topo` a `Topography` object, as read by `OceanAnalysis.read_topography()`.
"""
function depth_at_location(longitude, latitude, topo)
    length(longitude) == length(latitude) || error("lengths of 'longitude' and 'latitude' do not match")
    typeof(topo) != "Topography" || error("'topo' must be a Topography object, as read by OceanAnalysis.read_topography()")
    println("FIXME: code depth_at_location")
    lon = topo["longitude"]
    lat = topo["latitude"]
    z = topo.data
    itp = LinearInterpolation((lat, lon), z)
    return -itp(lats, lons)
end
export depth_at_location
