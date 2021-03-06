"""
`MaternKernel([ρ=1.0,[ν=1.0]])`
The matern kernel is an isotropic Mercer kernel given by the formula:
```
    κ(x,y) = 2^{1-ν}/Γ(ν)*(√(2ν)‖x-y‖)^ν K_ν(√(2ν)‖x-y‖)
```
For `ν=n+1/2, n=0,1,2,...` it can be simplified and you should instead use [`ExponentialKernel`](@ref) for `n=0`, [`Matern32Kernel`](@ref), for `n=1`, [`Matern52Kernel`](@ref) for `n=2` and [`SqExponentialKernel`](@ref) for `n=∞`.
"""
struct MaternKernel{Tr<:Transform, Tν<:Real} <: Kernel{Tr}
    transform::Tr
    ν::Tν
    function MaternKernel{Tr, Tν}(t::Tr, ν::Tν) where {Tr, Tν}
        @check_args(MaternKernel, ν, ν > zero(Tν), "ν > 0")
        return new{Tr, Tν}(t, ν)
    end
end

MaternKernel(ρ::Real=1.0, ν::Real=1.5) = MaternKernel(ScaleTransform(ρ), ν)

MaternKernel(ρ::AbstractVector{<:Real},ν::Real=1.5) = MaternKernel(ARDTransform(ρ), ν)

MaternKernel(t::Tr, ν::T=1.5) where {Tr<:Transform, T<:Real} = MaternKernel{Tr, T}(t, ν)

params(k::MaternKernel) = (params(transform(k)),k.ν)
opt_params(k::MaternKernel) = (opt_params(transform(k)),k.ν)

@inline kappa(κ::MaternKernel, d::Real) = iszero(d) ? one(d) : exp((1.0-κ.ν)*logtwo-logabsgamma(κ.ν)[1] + κ.ν*log(sqrt(2κ.ν)*d)+log(besselk(κ.ν,sqrt(2κ.ν)*d)))

metric(::MaternKernel) = Euclidean()

"""
`Matern32Kernel([ρ=1.0])`
The matern 3/2 kernel is an isotropic Mercer kernel given by the formula:
```
    κ(x,y) = (1+√(3)ρ‖x-y‖)exp(-√(3)ρ‖x-y‖)
```
"""
struct Matern32Kernel{Tr} <: Kernel{Tr}
    transform::Tr
end

@inline kappa(κ::Matern32Kernel, d::Real) = (1+sqrt(3)*d)*exp(-sqrt(3)*d)

metric(::Matern32Kernel) = Euclidean()

"""
`Matern52Kernel([ρ=1.0])`
The matern 5/2 kernel is an isotropic Mercer kernel given by the formula:
```
    κ(x,y) = (1+√(5)ρ‖x-y‖ + 5ρ²‖x-y‖^2/3)exp(-√(5)ρ‖x-y‖)
```
"""
struct Matern52Kernel{Tr} <: Kernel{Tr}
    transform::Tr
end

@inline kappa(κ::Matern52Kernel, d::Real) = (1+sqrt(5)*d+5*d^2/3)*exp(-sqrt(5)*d)

metric(::Matern52Kernel) = Euclidean()
