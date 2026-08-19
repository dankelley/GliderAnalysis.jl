using GliderAnalysis, DataFrames, CSV, Test
@testset "lonlat_xy and xy_lonlat" begin
    file = joinpath(dirname(dirname(pathof(GliderAnalysis))),
        "data", "sbloom_2023_traj.csv.gz")
    traj = CSV.read(file, DataFrame)
    x, y = lonlat_xy(traj.longitude, traj.latitude)
    longitude, latitude = xy_lonlat(x, y)
    @test longitude ≈ traj.longitude
    @test latitude ≈ traj.latitude
end
