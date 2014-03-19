pro make_order, a, slik_names, mc_names, params, params_id_slik
    str = strsplit(a, ' ', /extract, escape='#')
    str = strcompress(string(str) ,/remove)
    
    nparams = n_elements(str)
    ncosmos = n_elements(slik_names)

    params = strarr(nparams)
    params_id_slik = lonarr(nparams)

    for i=0, ncosmos-1 do begin
        id = where(strcmp(str, slik_names[i]) eq 1)
        params_id_slik[i] = id
        params[i] = mc_names[i]
    endfor
    
    i_egfs = 0
    for i=0, nparams-1 do begin
        if strmid(str[i], 0, 4) eq 'egfs' then begin
            params_id_slik[i_egfs+ncosmos] = i
            params[i_egfs+ncosmos] = str[i]
            i_egfs += 1
        endif
    endfor
    
end

pro slik2mc, sliktxt, output_root, num_split=num_split
    
    cosmo_paramnames = '~/Projects/CMBtools/Healpix_3.11/src/idl/cosmomc_tools/slik/cosmo.paramnames'
    readcol, cosmo_paramnames, slik_names, mc_names, format='(A,A)', /silent
    
    a = ' '
    get_lun, unit
    openr, unit, sliktxt
    readf, unit, a
    b = 1.0
    ct = 0L
    while ~eof(unit) do begin
        readf, unit, b
        ct += 1L
    endwhile
    free_lun, unit

    make_order, a, slik_names, mc_names, params, params_id_slik
    nparams = n_elements(params)

    ncosmos = n_elements(mc_names)
    
    lists = dblarr(nparams, ct)
    get_lun, unit
    openr, unit, sliktxt
    readf, unit, a
    readf, unit, lists
    free_lun, unit

    lists_new = dblarr(nparams, ct)
    for i=0, nparams-1 do begin
        scale = 1.0
        add   = 0.0
        if (i lt ncosmos) then begin
            if (mc_names[i] eq 'theta') then scale=100.0
            if (mc_names[i] eq 'logA') then begin
                id_ns = where(params eq 'ns')
                list_ns = reform(lists[params_id_slik[id_ns],*])
                add = (1.00d0-list_ns)*alog(0.002/0.05)
            endif
        endif
        lists_new[i,*] = lists[params_id_slik[i],*]*scale + add
    endfor

    if (keyword_set(num_split)) then begin
        for i_split=1, num_split do begin
            istart = (i_split-1) * long(ct/num_split)
            iend = istart + long(ct/num_split) - 1
            cidx = strcompress(string(i_split),/remove)
            get_lun, unit
            openw, unit, output_root+'_'+cidx+'.txt'
            for i=istart, iend do begin
                printf, unit, format='(200E16.7)', lists_new[*,i]
            endfor
            free_lun, unit
        endfor
    endif else begin
        get_lun, unit
        openw, unit, output_root+'_1.txt'
        for i=0L, ct-1L do begin
            printf, unit, format='(200E16.7)', lists_new[*,i]
        endfor
        free_lun, unit
    endelse

    get_lun, unit
    openw, unit, output_root+'.paramnames'
    for i=2, nparams-1 do begin
        printf, unit, params[i]+'    '+params[i]
    endfor
    free_lun, unit
end
