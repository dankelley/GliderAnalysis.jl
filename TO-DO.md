julia> xy = transect_xy(traj.longitude, traj.latitude);
ERROR: Must specify at least the source referencing system.
Stacktrace:
 [1] error(s::String)
   @ Base ./error.jl:44
 [2] xy2lonlat(xy::Matrix{Float64}, s_srs_::String; s_srs::String, t_srs::String)
   @ GMT ~/.julia/packages/GMT/HbHpw/src/gdal_utils.jl:1218
 [3] xy2lonlat
   @ ~/.julia/packages/GMT/HbHpw/src/gdal_utils.jl:1214 [inlined]
 [4] transect_xy(longitude::Vector{Float64}, latitude::Vector{Float64}; inverse::Bool, case::Symbol)
   @ GliderAnalysis ~/git/GliderAnalysis.jl/src/coordinates.jl:83
 [5] transect_xy(longitude::Vector{Float64}, latitude::Vector{Float64})
   @ GliderAnalysis ~/git/GliderAnalysis.jl/src/coordinates.jl:59
 [6] top-level scope
   @ REPL[10]:1
