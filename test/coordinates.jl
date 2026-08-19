using GliderAnalysis, DataFrames, CSV, Test
@testset "lonlat_xy and xy_lonlat" begin
    file = joinpath(dirname(dirname(pathof(GliderAnalysis))),
        "data", "sbloom_2023_traj.csv.gz")
    traj = CSV.read(file, DataFrame)
    xy = lonlat_xy(traj.longitude, traj.latitude)
    lonlat = xy_lonlat(xy[:, 1], xy[:, 2])
    @test lonlat[:, 1] ≈ traj.longitude
    @test lonlat[:, 2] ≈ traj.latitude
end
