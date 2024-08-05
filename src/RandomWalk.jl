##################################################################
# Filename  : RandomWalk.jl
# Author    : Jonathan Miller
# Date      : 2024-02-12
# Aim       : aim_script
#           : Random walk on a circle
#           : Use a state based random walk approach
##################################################################
module RandomWalk

using Reexport
@reexport using Geometries
import Geometries as gm
using Random
using Distributions
@reexport using Base: length
import GLMakie as gl





export 
    Diffusion,
    TimeSeries,
    ScaleNoise,
    CircleNoise,
    AxialNoise,
    time_series,
    Δt,
    length,
    scale_noise,
    radius,
    random_θ,
    random_θ_step,
    random_cartesian_circle_point,
    step_along_azimuthal,
    step_along_cartesian,
    cart2Point2f,
    save_single_random_walk_on_circle_video



mutable struct TimeSeries 
    end_time :: Int
    time_step :: Float64
end

mutable struct ScaleNoise <: Diffusion
    scale :: Union{Int,Float64}
end

mutable struct CircleNoise <: Diffusion
    radius :: Radius
    scale :: ScaleNoise
end

mutable struct AxialNoise <: Diffusion
    scale :: ScaleNoise
end

function time_series(ts::TimeSeries)
    range(0,ts.end_time,step = ts.time_step)
end

function Δt(ts::TimeSeries)
    ts.time_step
end

function Base.length(ts::TimeSeries)
    time_series(ts) |> length
end

scale_noise(sn::ScaleNoise) = sn.scale
scale_noise(c::CircleNoise) = scale_noise(c.scale)
scale_noise(ax::AxialNoise) = scale_noise(ax.scale)


radius(r::Radius) = r.radius
radius(c::Circle) = radius(c.radius)
radius(noise::CircleNoise) = radius(noise.radius)
radius(p::PolarCoordinates) = radius(p.radius)
radius(c::CartesianCoordinates) =  √(c.x^2 + c.y^2)


function random_cartesian_circle_point(r::Radius)
    θ =  random_θ() |> x -> Geometries.Angle(x)
    p2c(PolarCoordinates(r,θ))
end

function random_θ()
    2*π*rand() - π
end




function random_θ_step(noise::CircleNoise)
    r =  radius(noise)
    σ = scale_noise(noise)
    dist = Normal()
    σ/r * rand(dist)
end




function step_along_azimuthal(p::PolarCoordinates,noise::CircleNoise,ts::TimeSeries)
    r = p.radius
    θ̃ = Angle(random_θ_step(noise)*√(Δt(ts)))
    p + PolarCoordinates(r,θ̃)
end

function step_along_cartesian(c::CartesianCoordinates,noise::CircleNoise,ts::TimeSeries)
    p=c2p(c) |> x -> step_along_azimuthal(x,noise,ts)
    p2c(p)
end



cart2Point2f(c::CartesianCoordinates) = gl.Point2f[(Float32(c.x),Float32(c.y))]


function save_single_random_walk_on_circle_video(ts::TimeSeries,cn::CircleNoise,file_name_path,frame_rate)
    r = cn.radius
 
 
     T = time_series(ts)
     step = random_cartesian_circle_point(r)
     steps = []
     for t in T
         step = step_along_cartesian(step,cn,ts)
         push!(steps,step)
     end
 
 
     # Set up figure
     points = gl.Observable(cart2Point2f(steps[1]))
     ϕ = gl.LinRange(0, 2π, 100)
     ps = PolarCoordinates.(Ref(r),Angle.(ϕ))
     cs = p2c.(ps)
     fig = gl.Figure(size = (800, 800),fontsize = 25)
     ax = gl.Axis(fig[1, 1],aspect = 1,xlabel="x",ylabel="y")
     gl.lines!(ax, coordinates.(cs),label = "Cell",color = :orange)
     gl.scatter!(ax,points,markersize = 30,color = :red)
     gl.axislegend()
     fig
 
 
     # Save animation to file 
     gl.record(fig, file_name_path, steps;
             framerate = frame_rate) do s
         points[] = cart2Point2f(s)
     end

     isfile(file_name_path) ? println("Success! File exists") : println("Failure! File does not exist")
end


end
