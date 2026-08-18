using GliderAnalysis, DataFrames, CSV, Test
@testset "lonlat_xy forward and reverse" begin
    file = joinpath(dirname(dirname(pathof(GliderAnalysis))),
        "data", "sbloom_2023_traj.csv.gz")
    traj = CSV.read(file, DataFrame)
    xy = lonlat_xy(traj.longitude, traj.latitude)
    lonlat = lonlat_xy(xy[:, 1], xy[:, 2]; inverse=true)
    @test lonlat[:, 1] ≈ traj.longitude
    @test lonlat[:, 2] ≈ traj.latitude
end
