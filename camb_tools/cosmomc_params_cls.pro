pro get_params, cmb_params=cmb_params, cos_params=cos_params
    
    cmb_params.Omegabh2  = cos_params.params_set[name2id('omegabh2',paramnames=cos_params.paramnames)]
    cmb_params.Omegach2  = cos_params.params_set[name2id('omegach2',paramnames=cos_params.paramnames)]
    cmb_params.Omeganuh2 = cos_params.params_set[name2id('omeganuh2*',paramnames=cos_params.paramnames)]
    cmb_params.H0        = cos_params.params_set[name2id('H0*',paramnames=cos_params.paramnames)]
    cmb_params.yp        = cos_params.params_set[name2id('yheused*',paramnames=cos_params.paramnames)]
    cmb_params.As        = cos_params.params_set[name2id('A*',paramnames=cos_params.paramnames)]
    cmb_params.ns        = cos_params.params_set[name2id('ns',paramnames=cos_params.paramnames)]
    cmb_params.tau       = cos_params.params_set[name2id('tau',paramnames=cos_params.paramnames)]
    
    cmb_params.Omegak = 0.00d0
    id = name2id('omegak',paramnames=cos_params.paramnames)
    if (id ne 0) then cmb_params.Omegak = cos_params.params_set[id]
    
    cmb_params.w = -1.00d0
    id = name2id('w',paramnames=cos_params.paramnames)
    if (id ne 0) then cmb_params.w = cos_params.params_set[id]

    cmb_params.neff = 3.04600d0
    id = name2id('nnu',paramnames=cos_params.paramnames)
    if (id ne 0) then cmb_params.neff = cos_params.params_set[id]

    ;print, cmb_params.Omegabh2
    ;print, cmb_params.Omegach2
    ;print, cmb_params.Omeganuh2
    ;print, cmb_params.H0
    ;print, cmb_params.yp
    ;print, cmb_params.As
    ;print, cmb_params.ns
    ;print, cmb_params.tau
    ;print, cmb_params.Omegak
    ;print, cmb_params.w
    ;print, cmb_params.neff

    return
end

function cosmomc_params_cls, lmax=lmax, cos_params=cos_params, old_camb=old_camb, camb_path=camb_path, pivot_k=pivot_k
    
    lmax = 3300
    cmb_params = create_struct('lmax',lmax, 'Omegabh2',0.0d0, 'Omegach2',0.0d0, 'Omeganuh2',0.0d0, $
            'Omegak',0.0d0, 'H0',0.0d0, 'w',-1.00d0, 'yp',0.0d0, 'neff',3.046d0, 'As',0.0d0, $
            'ns',0.0d0, 'tau',0.0d0)

    get_params, cmb_params=cmb_params, cos_params=cos_params
    cmb_params.lmax = lmax

    rand = randomu(seed,/long)

    output_root = 'idlcamb_'+strcompress(string(rand),/remove)

    exe_camb, cmb_params, output_root, cls, old_camb=old_camb, camb_path=camb_path, pivot_k=pivot_k
    
    return, cls
end
