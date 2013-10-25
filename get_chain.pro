function get_chain, pname, path, prefix, nskip=nskip, mcmc=mcmc, listonly=listonly

    ;pid = name2id(pname, path, prefix)
    ;pidx = strcompress(string(pid), /remove)
    
    if (keyword_set(nskip)) then num_skip=nskip else num_skip=1000

    ;savfile = path+'/'+prefix+'/plot_dist/'+pidx+'.sav'
    ;savinfo = file_info(savfile)
    ;if (savinfo.exists) then begin
        ;restore, savfile
    ;endif else begin
        if (not keyword_set(mcmc)) then begin
            mcmc = read_chains(8, num_skip, path, prefix)
        endif

        pid = name2id(pname, paramnames=mcmc.paramnames)
        
        if (keyword_set(listonly)) then begin
            list = reform(mcmc.chain_lists[pid,*])
        endif else begin
            nsamples = total(mcmc.weight)
            list = fltarr(nsamples)

            nsteps = mcmc.nsteps
            ip = 0L
            for istep=0L, nsteps-1L do begin
                istart = ip
                iend = ip+mcmc.weight[istep]-1L

                tmp = mcmc.chain_lists[pid,istep]
                list[istart:iend] = tmp

                ip = iend + 1L
            endfor

            ;save, list, filename=savfile
        endelse

        if (not keyword_set(mcmc)) then mcmc = 0
    ;endelse

    return, list
end
