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
functions in this library.  See also [`increment_debug`](@ref).
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

