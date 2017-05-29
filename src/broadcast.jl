using Compat

Base.Broadcast._containertype(::Type{<:DataValueArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{DataValueArray}, ::Type{DataValueArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{AbstractArray}, ::Type{DataValueArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{DataValueArray}, ::Type{AbstractArray}) = DataValueArray
Base.Broadcast.promote_containertype(::Type{DataValueArray}, _) = error()
Base.Broadcast.promote_containertype(_, ::Type{DataValueArray}) = error()

Base.Broadcast.broadcast_indices(::Type{DataValueArray}, A::Ref) = ()
Base.Broadcast.broadcast_indices(::Type{DataValueArray}, A) = indices(A)

# broadcast methods that dispatch on the type found by inference
function broadcast_t(f, ::Type{Any}, shape, iter, As...)
    nargs = length(As)
    keeps, Idefaults = Base.Broadcast.map_newindexer(shape, As)
    st = start(iter)
    I, st = next(iter, st)
    val = f([ Base.Broadcast._broadcast_getindex(As[i], Base.Broadcast.newindex(I, keeps[i], Idefaults[i])) for i=1:nargs ]...)
    B = similar(DataValueArray{typeof(val)}, shape)
    B[I] = val
    return Base.Broadcast._broadcast!(f, B, keeps, Idefaults, As, Val{nargs}, iter, st, 1)
end
@inline function broadcast_t(f, T, shape, iter, A, Bs::Vararg{Any,N}) where N
    C = similar(DataValueArray{T}, shape)
    keeps, Idefaults = Base.Broadcast.map_newindexer(shape, A, Bs)
    Base.Broadcast._broadcast!(f, C, keeps, Idefaults, A, Bs, Val{N}, iter)
    return C
end

function Base.Broadcast.broadcast_c(f, ::Type{DataValueArray}, A, Bs...)
    T = Base.Broadcast._broadcast_eltype(f, A, Bs...)
    shape = Base.Broadcast.broadcast_indices(A, Bs...)
    iter = CartesianRange(shape)
    if isleaftype(T)
        return broadcast_t(f, T, shape, iter, A, Bs...)
    end
    if isempty(iter)
        return similar(DataValueArray{T}, shape)
    end
    return broadcast_t(f, Any, shape, iter, A, Bs...)
end
