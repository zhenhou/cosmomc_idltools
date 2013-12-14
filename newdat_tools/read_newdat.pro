function read_newdat, newdat_file, read_window=read_window, read_covmat=read_covmat
    
    a = ' '
    nbands = lonarr(6)
    
    types = ['TT','EE','BB','EB','TE','TB']

    lastsl = STRPOS(newdat_file, '/', /REVERSE_SEARCH)
    wf_path = STRMID(newdat_file, 0, lastsl+1)+'windows/'

    get_lun, unit
    openr, unit, newdat_file
    readf, unit, a
    wf_path += a
    readf, unit, nbands

    nlines = max(nbands)

    bid = where(nbands ne 0)
    nbs = n_elements(bid)
    last_band = bid[nbs-1]
    ndim = total(nbands)

    num_TT = nbands[0]
    num_EE = nbands[1]
    num_BB = nbands[2]
    num_TE = nbands[4]

    tmp = dblarr(5, nlines, 6)
    col_select = [1,2,3,5,6]

    while ~eof(unit) do begin
        readf, unit, a
        s = strcompress(a,/remove)
        itype = where(types eq s)
        if (itype ne -1) then begin
            tmp_read =dblarr(8,nbands[itype])
            readf, unit, tmp_read
            tmp[*,0:nbands[itype]-1,itype] = tmp_read[col_select,*]
        endif
        
        
        ;; be careful at this part for TT-only (or EE-only, etc) case
        if (keyword_set(read_covmat)) then begin
            cov = dblarr(ndim, ndim)
            line_read = dblarr(ndim)
            if (itype eq last_band) then begin
                for i=0, nbands[last_band]-1 do readf, unit, a
                
                for i=0, ndim-1 do begin
                    readf, unit, line_read
                    cov[*,i] = line_read
                endfor
            endif
        endif 
    endwhile
    free_lun, unit

    ndf = {}
    for itype=5, 0, -1 do begin
        if nbands[itype] ne 0 then ndf = create_struct(types[itype],tmp[*,0:nbands[itype]-1,itype], ndf)
    endfor
    

    ;; read window functions ;;
    if (keyword_set(read_window)) then begin 
        wf_order = ['TT','TE','EE','BB']
        tags     = TAG_NAMES(ndf)
        
        wf = {}
        ct = 1
        for itype=0, 5 do begin
            tidx = where(strcmp(tags, types[itype]) eq 1)
            if (tidx ne -1) then begin
                lmin = min(ndf.(tidx)[3,*])
                lmax = max(ndf.(tidx)[4,*])

                wf_array = dblarr(lmax+1,nbands[itype])
                wt_idx = where(strcmp(wf_order, types[itype]) eq 1)+1

                for ib=1, nbands[itype] do begin
                    wf_file = wf_path+strcompress(string(ct),/remove)
                    get_lun, unit
                
                    tmp_read = dblarr(5)
                    openr, unit, wf_file
                        while ~eof(unit) do begin
                        readf, unit, tmp_read
                        il = long(tmp_read[0])
                        if (il le lmax) then wf_array[il,ib-1] = tmp_read[wt_idx]
                    endwhile
                    free_lun, unit
                    ct += 1
                endfor

                wf = create_struct(types[itype], wf_array, wf)
            endif
        endfor

        data = create_struct(['bands','windows'],ndf, wf)
    endif else begin
        data = create_struct(['bands'], ndf)
    endelse

    if (keyword_set(read_covmat)) then begin
        data = create_struct('covmat', cov, data)
    endif

    tmp = 0

    return, data
end
