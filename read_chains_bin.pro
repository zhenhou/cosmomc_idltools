function read_chains_bin, path, paramnames, list2chain=list2chain

    res = file_info(path+'/weight')
    nsamples = res.size/8

    nparams = n_elements(paramnames)
    
    weight_read = dblarr(nsamples)
    param_read = dblarr(nsamples)

    openr, 5, path+'/weight'
    readu, 5, weight_read
    close, 5

    weight = weight_read

    list_arr = dblarr(nsamples, nparams)

    for ip=0, nparams-1 do begin
        openr, 5, path+'/'+strcompress(paramnames[ip], /remove)
        readu, 5, param_read
        close, 5

        list_arr[*,ip] = param_read[*]
    endfor
    
    if (keyword_set(list2chain)) then begin
        ntot = total(long(weight),/integer)
        
        chains = dblarr(ntot, nparams)

        ct = 0L
        for isample=0L, nsamples-1L do begin
            istart = ct
            iend = ct+weight[isample]-1L

            tmp = list_arr[isample,*]
            for i=istart, iend do chains[i,*] = tmp

            ct = iend + 1L
        endfor

        mcmc = create_struct('nparams',nparams, 'nsteps',ntot, 'chains',chains, 'pnames',paramnames, 'lists',list_arr, 'weight',weight, 'nsamples',nsamples)
    endif else begin
        mcmc = create_struct('nparams',nparams, 'pnames',paramnames, 'lists',list_arr, 'weight',weight, 'nsamples',nsamples)
    endelse

    return, mcmc
end
