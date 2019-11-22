"""
Chain a series of transform, here `t1` will be called first
```
    t1 = ScaleTransform()
    t2 = LowRankTransform(rand(3,4))
    ct = ChainTransform([t1,t2]) #t1 will be called first
    ct == t2∘t1
```
"""
struct ChainTransform <: Transform
    transforms::Vector{Transform}
end

Base.length(t::ChainTransform) = length(t.transforms) #TODO Add test

function ChainTransform(v::AbstractVector{<:Transform})
    ChainTransform(v)
end

function ChainTransform(v::AbstractVector{<:Type{<:Transform}},θ::AbstractVector)
    @assert length(v) == length(θ)
    ChainTransform(v.(θ))
end

function transform(t::ChainTransform,X::T,obsdim::Int=defaultobs) where {T}
    Xtr = copy(X)
    for tr in t.transforms
        Xtr = transform(tr,Xtr,obsdim)
    end
    return Xtr
end

set!(t::ChainTransform,θ) = set!.(t.transforms,θ)
params(t::ChainTransform) = (params.(t.transforms))
opt_params(t::ChainTransform) = (opt_params.(t.transforms))

Base.:∘(t₁::Transform,t₂::Transform) = ChainTransform([t₂,t₁])
Base.:∘(t::Transform,tc::ChainTransform) = ChainTransform(vcat(tc.transforms,t)) #TODO add test
Base.:∘(tc::ChainTransform,t::Transform) = ChainTransform(vcat(t,tc.transforms))
