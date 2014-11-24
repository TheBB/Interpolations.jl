abstract ExtrapolationBehavior
type ExtrapError <: ExtrapolationBehavior end

function extrap_gen(::OnGrid, ::ExtrapError, N)
    quote
        @nexprs $N d->(1 <= x_d <= size(itp,d) || throw(BoundsError()))
    end
end
extrap_gen(::OnCell, e::ExtrapError, N) = extrap_gen(OnGrid(), e, N)

type ExtrapNaN <: ExtrapolationBehavior end

function extrap_gen(::OnGrid, ::ExtrapNaN, N)
    quote
        @nexprs $N d->(1 <= x_d <= size(itp,d) || return convert(T, NaN))
    end
end
extrap_gen(::OnCell, e::ExtrapNaN, N) = extrap_gen(OnGrid(), e, N)

type ExtrapConstant <: ExtrapolationBehavior end
function extrap_gen(::OnGrid, ::ExtrapConstant, N)
    quote
        @nexprs $N d->(x_d = clamp(x_d, 1, size(itp,d)))
    end
end
extrap_gen(::OnCell, e::ExtrapConstant, N) = extrap_gen(OnGrid(), e, N)

type ExtrapLinear <: ExtrapolationBehavior end

function extrap_gen(::OnGrid, ::ExtrapLinear, N)
    quote
        @nexprs $N d->begin
            if x_d < 1
                fx_d = x_d - convert(typeof(x_d), 1)

                k = itp[1] - itp[2]
                return itp[1] - k * fx_d
            end
            if x_d > size(itp, d)
                s_d = size(itp,d)
                fx_d = x_d - convert(typeof(x_d), s_d)

                k = itp[s_d] - itp[s_d - 1]
                return itp[s_d] + k * fx_d
            end
        end
    end
end
extrap_gen(::OnCell, e::ExtrapLinear, N) = extrap_gen(OnGrid(), e, N)
