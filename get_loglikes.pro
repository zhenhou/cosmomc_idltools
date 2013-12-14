pro get_loglikes, path, prefix, loglikes, nskip=nskip, mcmc=mcmc

    if (keyword_set(nskip)) then num_skip=nskip else num_skip=1000

        if (not keyword_set(mcmc)) then begin
            mcmc = read_chains(8, num_skip, path, prefix)
        endif

        nsamples = total(mcmc.weight)
        loglikes = fltarr(nsamples)

        nsteps = mcmc.nsteps
        ip = 0L
        for istep=0L, nsteps-1L do begin
            istart = ip
            iend = ip+mcmc.weight[istep]-1L

            tmp = mcmc.chain_lists[0,istep]
            loglikes[istart:iend] = tmp

            ip = iend + 1L
        endfor

        if (not keyword_set(mcmc)) then mcmc = 0

    return
end
