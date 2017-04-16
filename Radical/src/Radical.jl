module Radical

import Base.convert,
       Base.promote_rule,
       Base.show

export Sqrt,
       coeff,
       rad,
       rnorm,
       RatOrInt

RatOrInt = Union(Rational,Integer)

immutable Sqrt{S<:RatOrInt,T<:Integer} <: Real
    coeff::S
    rad::T
    
    function Sqrt(coeff::S,rad::T)
    if rad < 0 
        error("Negative radicand.")
    end
    if coeff == 0 || rad == 0
        new(0,0)
    end
    d = factor(rad) 
        for p in keys(d)
            coeff *= p^div(d[p],2)
            d[p] = mod(d[p],2)
        end
        new(coeff, prod([ p^d[p] for p in keys(d)]))
    end
end

Sqrt(x::FloatingPoint) = sqrt(x)
Sqrt(x::FloatingPoint,y::FloatingPoint) = x*sqrt(y)
Sqrt{T<:Real}(x::FloatingPoint,y::T) = x*sqrt(y)
Sqrt{T<:Real}(x::T,y::FloatingPoint) = x*sqrt(y)

Sqrt{S<:RatOrInt,T<:Integer}(coeff::S, rad::T) = Sqrt{S,T}(coeff,rad)
Sqrt{T<:Integer}(rad::T) = Sqrt(one(rad),rad)
Sqrt{S<:RatOrInt}(coeff::S,r::Rational) = Sqrt(coeff//den(r),num(r)*den(r))
Sqrt(r::Rational) = Sqrt(1,r)
Sqrt(x::Sqrt) = (rad(x) == 1 ? Sqrt(coeff(x)) : throw(InexactError()))

coeff(x::Sqrt) = x.coeff
rad(x::Sqrt) = x.rad

*(x::Sqrt,y::Sqrt) = Sqrt(coeff(x)*coeff(y),rad(x)*rad(y))
*(x::Bool,y::Sqrt) = Sqrt(x*coeff(y),rad(y))
*{T<:RatOrInt}(x::T,y::Sqrt) = Sqrt(x*coeff(y),rad(y))
//(x::Sqrt,y::Sqrt) = Sqrt(coeff(x)//coeff(y),rad(x)//rad(y))
//{T<:RatOrInt}(x::T,y::Sqrt) = Sqrt(x//coeff(y),1//rad(y))
//{T<:RatOrInt}(x::Sqrt,y::T) = Sqrt(coeff(x)//y,rad(x))
/(x::Sqrt,y::Sqrt) = Sqrt(coeff(x)//coeff(y),rad(x)//rad(y))
/(x::Sqrt,y::RatOrInt) = convert(typeof(float(y)),x)/float(y)
/{T<:Real}(x::Sqrt,y::T) = convert(T,x)/y
/{T<:Real}(x::T,y::Sqrt) = x/convert(T,y)
+(x::Sqrt,y::Sqrt) = rad(x) != rad(y) ? error("Cannot add radicals with different radicands") : Sqrt(coeff(x)+coeff(y),rad(x))
-(x::Sqrt,y::Sqrt) = rad(x) != rad(y) ? error("Cannot subtract radicals with different radicands") : Sqrt(coeff(x)-coeff(y),rad(x))
-(x::Sqrt) = Sqrt(-coeff(x),rad(x))

function +{T<:RatOrInt}(x::Sqrt,y::T)
    if rad(x) == 1
        return coeff(x) + y
    else
        error("Cannot add radicals to non-radicals.")
    end
end

+{T<:RatOrInt}(x::T,y::Sqrt) = y + x

convert{S<:RatOrInt,T<:Integer}(::Type{Sqrt{S,T}},n::Integer) = Sqrt(n,1)
convert{S<:RatOrInt,T<:Integer}(::Type{Sqrt{S,T}},r::Rational) = Sqrt(r,1)
convert(::Type{FloatingPoint}, x::Sqrt) = float(coeff(x))*sqrt(rad(x))

convert{S,T}(::Type{BigFloat},x::Sqrt{S,T}) = convert(BigFloat,float(coeff(x))*sqrt(rad(x)))

function convert{S<:FloatingPoint,T,U}(::Type{S},x::Sqrt{T,U})
    P = promote_type(S,T,U)
    return convert(P,coeff(x)) * sqrt(convert(P,rad(x)))
end

convert(::Type{Bool},x::Sqrt) = (coeff(x) != 0)
convert{T<:Integer}(::Type{T}, x::Sqrt) = (rad(x) == 1 ? coeff(x) : throw(InexactError()))
convert{S<:RatOrInt,T<:Integer}(::Type{Sqrt{S,T}},x::Sqrt) = Sqrt(convert(S,coeff(x)),convert(T,rad(x)))

promote_rule{S<:RatOrInt,T<:Integer,U<:Integer}(::Type{Sqrt{S,T}}, ::Type{U}) = Sqrt{S,promote_type(T,U)}

promote_rule{S<:RatOrInt,T<:Integer,U<:Integer}(::Type{Sqrt{S,T}}, ::Type{Rational{U}}) = Sqrt{promote_type(S,U),T}

promote_rule{S<:RatOrInt,T<:Integer,U<:RatOrInt,V<:Integer}(::Type{Sqrt{S,T}},::Type{Sqrt{U,V}}) = Sqrt{promote_type(S,U),promote_type(T,V)}

convert(::Type{Sqrt}, x::Sqrt) = x

rnorm(A::Array) = Sqrt(sum([x^2 for x in A]))

function show(io::IO,x::Sqrt)
    if isa(coeff(x),Rational) && den(coeff(x)) != 1
        if num(coeff(x)) == -1
            print(io,"-");
        end
        if (num(coeff(x)) != 1 && num(coeff(x)) != -1) || rad(x) == 1
            show(io,num(coeff(x))); 
        end
        if rad(x) != 1
            print(io,"√("); show(io,rad(x)); print(io,")"); 
        end
        print(io,"/"); show(io,den(coeff(x)));
    else
        if coeff(x) != 1
            show(io,coeff(x));
        end
        if rad(x) != 1
            print(io,"√("); show(io,rad(x)); print(io,")");
        end
        if rad(x) == 1 && coeff(x) == 1
            show(io,1);
        end
    end
end

end # module
