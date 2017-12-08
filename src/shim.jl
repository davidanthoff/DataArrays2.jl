using DataValueArrays

Array{T,N}(d::NTuple{N,Int}) where {T<:DataValue,N} =DataValueArray{eltype(T),N}(d)
Array{T,1}(m::Int) where {T<:DataValue} = DataValueArray{eltype(T),1}(m)
Array{T,2}(m::Int, n::Int) where {T<:DataValue} = DataValueArray{eltype(T),2}(m,n)
Array{T,3}(m::Int, n::Int, o::Int) where {T<:DataValue} = DataValueArray{eltype(T),3}(m,n,o)
Array{T,N}(d::Vararg{Int,N}) where {T<:DataValue,N} = DataValueArray{eltype(T),N}(d)
