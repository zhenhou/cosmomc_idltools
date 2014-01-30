function read_wmap_chain, path, paramname_file, nsamples=nsamples, nskip=nskip
    
    readcol, paramname_file, pnames_wmap, pnames_cmc, format='(A,A)', nlines=nparams, /silent
    
    weight_file = path+'/weight'
    readcol, weight_file, i, weight, format='(I,D)', skipline=nskip, numline=nsamples, /silent

    logL_file = path+'/neglnlike'
    readcol, logL_file, i, logL, format='(I,D)', skipline=nskip, numline=nsamples, /silent
    
    chain_lists = fltarr(nparams+1, nsamples)
    chain_lists[0,*] = logL

    for ip=0, nparams-1 do begin
        if strmid(pnames_wmap[ip],0,2) ne 'NA' then begin
            readcol, path+'/'+pnames_wmap[ip], i, tmp, format='I,D', skipline=nskip, numline=nsamples, /silent
            chain_lists[ip+1,*] = tmp
        endif else begin
            len = strlen(pnames_wmap[ip])
            a = strmid(pnames_wmap[ip],2,len-2)
            chain_lists[ip+1,*] = float(a)
        endelse
    endfor

    mcmc = create_struct('nparams',nparams, 'nsamples',nsamples, 'chain_lists',chain_lists, 'weight',weight, 'paramnames',['logL',pnames_cmc])

    return, mcmc
end
