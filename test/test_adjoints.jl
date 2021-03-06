using Zygote
using FiniteDifferences
using KernelFunctions
using Distances
using Test

x = rand(5)
y = rand(5)

@testset "Testing Zygote adjoints" begin
gzeucl = first(Zygote.gradient(xy->evaluate(Euclidean(),xy[1],xy[2]),[x,y]))
gzsqeucl =  first(Zygote.gradient(xy->evaluate(SqEuclidean(),xy[1],xy[2]),[x,y]))
gzdotprod = first(Zygote.gradient(xy->evaluate(KernelFunctions.DotProduct(),xy[1],xy[2]),[x,y]))

FDM = central_fdm(5,1)

gfeucl = collect(first(FiniteDifferences.grad(FDM,xy->evaluate(Euclidean(),xy[1],xy[2]),(x,y))))
gfsqeucl = collect(first(FiniteDifferences.grad(FDM,xy->evaluate(SqEuclidean(),xy[1],xy[2]),(x,y))))
gfdotprod =collect(first(FiniteDifferences.grad(FDM,xy->evaluate(KernelFunctions.DotProduct(),xy[1],xy[2]),(x,y))))

@test all(gzeucl .≈ gfeucl)
@test all(gzsqeucl .≈ gfsqeucl)
@test all(gzdotprod .≈ gfdotprod)

end
