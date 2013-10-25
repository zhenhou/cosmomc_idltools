pro list2chain, weight, list, chain
    
    nsteps = n_elements(weight)
    nsamples = total(weight,/integer)
    chain = fltarr(nsamples)

    ip = 0L
    for istep=0L, nsteps-1L do begin
        istart = ip
        iend = ip+weight[istep]-1L

        tmp = list[istep]
        chain[istart:iend] = tmp

        ip = iend + 1L
    endfor

    return

end
