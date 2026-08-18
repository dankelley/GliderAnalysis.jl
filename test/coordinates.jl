using GliderAnalysis, DataFrames, CSV, Test
@testset "transect_xy forward and reverse" begin
    file = joinpath(dirname(dirname(pathof(GliderAnalysis))),
        "data", "sbloom_2023_traj.csv.gz")
    traj = CSV.read(file, DataFrame)
    xy = transect_xy(traj.longitude, traj.latitude)
    lonlat = transect_xy(xy[:, 1], xy[:, 2]; inverse=true)
    @test lonlat[:, 1] ≈ traj.longitude
    @test lonlat[:, 2] ≈ traj.latitude
end
