function get_column(X,j)
    nrow,ncol = size(X)
    if j>ncol||j<0
        error("column number is wrong!")
    end
    indx = 1 + (j-1)*nrow
    ptr = pointer(X,indx)
    pointer_to_array(ptr,nrow)
end

function get_column_ref(X)
    ncol = size(X)[2]
    xArray = Array(Array{Float64,1},ncol)
    for i=1:ncol
        xArray[i] = get_column(X,i)
    end
    return xArray
end

function center!(X)
    nrow,ncol = size(X)
    colMeans = mean(X,1)
    BLAS.axpy!(-1,ones(nrow)*colMeans,X)
    return colMeans
end

function getXpRinvX(X, Rinv)
    ncol = size(X)[2]
    XpRinvX = [((X[:,i].*Rinv)'X[:,i])[1]::Float64 for i=1:ncol]
    return XpRinvX
end

function get_dom_cov(x, n)  # create dominance covariates from additive covariates
    w = zeros(n)
    for i=1:n
        if (x[i] > 1)
            w[i] = 2 - x[i]
        else
            w[i] = x[i]
        end
    end
    return w
end


