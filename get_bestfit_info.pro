function read_fg, filename, lmax=lmax, scale=scale
    
    readcol, filename, il, dat, nlines=nlines, format='(I,D)', /silent
    if not keyword_set(lmax) then lmax = max(il)
    lmax_used = min([max(il), lmax])

    if not keyword_set(scale) then scale=1.00d0

    fg_cls = dblarr(lmax_used+1)
    for i=il[0], lmax do begin
        fg_cls[i] = dat[i] * scale
    endfor

    return, fg_cls

end


pro get_bestfit_info, path, prefix, params_info, cmb_cls, cmbfg_cls, fg_templates=fg_templates, $
fg_params=fg_params, fg_types=fg_types, fg_scales=fg_scales

    mcmc = read_chains(8, 1000, path, prefix)
    ;get_loglikes, path, prefix, loglikes, mcmc=mcmc

    minval = min(mcmc.chain_lists[0,*], ML_id)

    paramnames = mcmc.paramnames
    params_set = mcmc.chain_lists[*,ML_id]

    params_info = create_struct(['paramnames','params_set'], paramnames, params_set)
    
    ;; now lmax=3300 is default setting in cosmomc_params_cls
    cmb_cls = cosmomc_params_cls(lmax=lmax, cos_params=params_info)

    if (keyword_set(fg_templates)) then begin
        cmbfg_cls = cmb_cls

        nfgs = n_elements(fg_templates)

        if (not keyword_set(fg_scales)) then begin
            fg_scales=dblarr(nfgs)
            fg_scales[*] = 1.00d0
        endif

        if (not keyword_set(fg_types)) then begin
            fg_scales=strarr(nfgs)
            fg_scales[*] = 'TT'
        endif
        
        tags = tag_names(cmb_cls)
        for i=0, nfgs-1 do begin
            lmax = cmb_cls.lmax

            nid = name2id(fg_params[i],paramnames=paramnames)

            if (nid ne 0) then begin
                pfg = params_set[nid]
            endif else begin
                pfg = 0.00d0
                if (fg_scales[i] ne 0.00d0) then pfg = 1.00d0
            endelse

            if (strcompress(fg_templates[i],/remove) eq 'l(l+1)') then begin
                il = dindgen(cmbfg_cls.lmax+1)
                fg_cls = il*(il+1.00d0)/1000.0d0/1001.0d0*fg_scales[i]
            endif else begin
                fg_cls = read_fg(fg_templates[i], lmax=cmbfg_cls.lmax, scale=fg_scales[i])
            endelse

            itype = where(strcmp(tags, fg_types[i]) eq 1)
            
            for il=0, lmax do begin
                cmbfg_cls.(itype)[il] = cmbfg_cls.(itype)[il] + fg_cls[il]*pfg
            endfor
        endfor
    endif

end
