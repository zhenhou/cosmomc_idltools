function read_chains, nchains, num_skip, path, prefix, savfile=savfile, single=single
    
    savlog = keyword_set(savfile)
    if (not savlog) then savfile = 'no_one_will_use_this_filename.sav'

    savinfo = file_info(savfile)

    if (savinfo.exists) then begin
        restore, savfile
    endif else begin
        pnamefile = path+'/'+prefix+'.paramnames'
        readcol, pnamefile, name1, name2, nlines=nparams, format='(A,A)', /silent

        tmp = fltarr(nparams+2)
        print, strcompress(string(nparams),/remove)+' parameters to be read'
        ct = 0L
        
        param_cache  = fltarr(nparams,400000L)
        mult_cache   = lonarr(400000L)
        like_cache   = fltarr(400000L) 
        
        for ichain=1, nchains do begin
            ct_single = 0L
            cidx = strcompress(string(ichain),/remove)
            
            if (nchains eq 1 and keyword_set(single)) then begin
                filename = path+'/'+prefix+'.txt'
            endif else begin
                filename = path+'/'+prefix+'_'+cidx+'.txt'
            endelse

            res = file_info(filename)
            if (not res.exists) then break

            ;filename = path+'/'+prefix+'_'+cidx+'.txt'
            ;print, strcompress(string(ichain),/remove)+'/'+strcompress(string(nchains),/remove)+' starts'
            openr, lun, filename, /get_lun
            for iskip=0, num_skip-1 do readf, lun, tmp

            while ~eof(lun) do begin
                readf, lun, tmp
                mult_cache[ct]  = long(tmp[0])
                like_cache[ct]  = tmp[1]
                param_cache[0:nparams-1,ct] = tmp[2:nparams+1]
                ct += 1L
            endwhile
            free_lun, lun
            print, strcompress(string(ichain),/remove)+'/'+strcompress(string(nchains),/remove)
        endfor

        print, "original chains reading finished"

        params_list = fltarr(nparams+1, ct)
        params_list[0L,0L:ct-1L] = like_cache[0L:ct-1L]
        params_list[1L:nparams,0L:ct-1L] = param_cache[0L:nparams-1L,0L:ct-1L]
        weight = mult_cache[0L:ct-1L]

        ;for i=0L, ct-1L do begin
        ;    istart = ip
        ;    iend = ip+mult_cache[i]-1L

        ;    tmp = param_cache[*,i]
        ;    for j=istart, iend do begin
        ;        params_list[1:*,j] = tmp
        ;        params_list[0,j] = like_cache[i]
        ;    endfor
        ;    ip = iend + 1L
        ;endfor

        mult_cache = 0
        like_cache = 0
        param_cache = 0
        
        mcmc = create_struct('nparams',nparams, 'nsamples',ct, 'chain_lists',params_list, 'weight',weight, 'paramnames',['logL',name1])
        if (savlog and (not savinfo.exists)) then save, mcmc, filename=savfile
    endelse
    return, mcmc 

end
