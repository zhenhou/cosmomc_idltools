pro exe_camb, params, output_root, cls, old_camb=old_camb, camb_path=camb_path, pivot_k=pivot_k, add=add
    
    if (not keyword_set(camb_path)) then camb_path = '/home/hou/Projects/CMBtools/cosmologist.info/camb'
    camb = camb_path+'/camb'
    
    ombh2  = params.Omegabh2
    omch2  = params.Omegach2
    omnuh2 = params.Omeganuh2
    omk    = params.Omegak
    H0     = params.H0
    w      = params.w
    Yp     = params.yp
    neff   = params.neff
    As     = params.As
    ns     = params.ns
    tau    = params.tau
    lmax   = params.lmax

    ;As = exp(logA)/10.0
    
    nu_massive = 0.0d0
    nu_massless = 0.0d0

    ;if (params.Omeganuh2 le 1.00d-8) then begin
    ;    omnuh2 = 0.00d0
    ;    nu_massive  = 0.00d0
    ;    nu_massless = neff
    ;endif else begin
    ;    nu_massive  = neff
    ;    nu_massless = 0.00d0
    ;endelse

    nu_massive  = long(neff)
    nu_massless = neff - nu_massive

    if (keyword_set(pivot_k)) then pivk = pivot_k else pivk=0.0500
    
    fmt = '(A,D16.7)'
    ini_file = '/tmp/'+output_root+'.ini'
    get_lun, unit_ini
    openw, unit_ini, ini_file
    if (not keyword_set(old_camb)) then begin
        printf, unit_ini, 'DEFAULT('+camb_path+'/params.ini)'
    endif else begin
        a = '  '
        get_lun, unit_common
        openr, unit_common, camb_path+'/params_common.ini'
        while ~eof(unit_common) do begin
            readf, unit_common, a
            pos = strpos(a,'#')
            if pos ne 0 then printf, unit_ini, a
        endwhile
        free_lun, unit_common
    endelse
    printf, unit_ini, 'output_root     = /tmp/'+output_root
    printf, unit_ini, format=fmt, 'ombh2           = ', ombh2
    printf, unit_ini, format=fmt, 'omch2           = ', omch2
    printf, unit_ini, format=fmt, 'omnuh2          = ', omnuh2
    printf, unit_ini, format=fmt, 'omk             = ', omk
    printf, unit_ini, format=fmt, 'hubble          = ', H0
    printf, unit_ini, format=fmt, 'w               = ', w
    printf, unit_ini, format=fmt, 'helium_fraction = ', Yp
    printf, unit_ini, format=fmt, 'massless_neutrinos = ', nu_massless
    printf, unit_ini, format='(A,I6)', 'massive_neutrinos  = ', nu_massive
    printf, unit_ini, 'scalar_amp(1)      = '+strcompress(string(As),/remove)+'E-09'
    printf, unit_ini, format=fmt, 'scalar_spectral_index(1)  = ', ns
    printf, unit_ini, format=fmt, 're_optical_depth   = ', tau
    printf, unit_ini, ' '
    printf, unit_ini, format='(A,I6)',   'l_max_scalar      = ', lmax
    printf, unit_ini, format='(A,F5.3)', 'pivot_scalar      = ', pivk
    
    if (keyword_set(add)) then begin
        nadd = n_elements(add)
        for i=0, nadd-1 do begin
            printf, unit_ini, add[i]
        endfor
    endif
    
    free_lun, unit_ini

    print, "camb starts"
    ;print, 'output_root     = '+output_root
    ;print, format=fmt, 'ombh2           = ', ombh2
    ;print, format=fmt, 'omch2           = ', omch2
    ;print, format=fmt, 'omnuh2          = ', omnuh2
    ;print, format=fmt, 'omk             = ', omk
    ;print, format=fmt, 'hubble          = ', H0
    ;print, format=fmt, 'w               = ', w
    ;print, format=fmt, 'helium_fraction = ', Yp
    ;print, format=fmt, 'massless_neutrinos = ', nu_massless
    ;print, format='(A,I6)', 'massive_neutrinos  = ', nu_massive
    ;print, 'scalar_amp(1)      = '+strcompress(string(As),/remove)+'E-09'
    ;print, format=fmt, 'scalar_spectral_index(1)  = ', ns
    ;print, format=fmt, 're_optical_depth   = ', tau
    ;print, format='(A,I6)',    'lmax_scalar     = ', lmax

    spawn, [camb, ini_file], /noshell
    print, "camb ends"
    
    lensedcls_file = '/tmp/'+output_root+'_lensedCls.dat'
    readcol, lensedcls_file, il, cltt_tmp, clee_tmp, cltmp, clte_tmp, nlines=n, format='(L,D,D,D)', /silent

    lmax_file = n+1L
    lensedtt = dblarr(lmax_file+1)
    lensedee = dblarr(lmax_file+1)
    lensedte = dblarr(lmax_file+1)
    
    lensedtt[2:*] = cltt_tmp
    lensedee[2:*] = clee_tmp
    lensedte[2:*] = clte_tmp

    scalcls_file = '/tmp/'+output_root+'_lenspotentialCls.dat'
    readcol, scalcls_file, il, cltt_tmp, clee_tmp, clbbtmp, clte_tmp, clpp_tmp, clpt_tmp, clpe_tmp, nlines=n, format='(L,D,D,D,D,D,D,D)', /silent
    scaltt = dblarr(lmax_file+1)
    scalee = dblarr(lmax_file+1)
    scalte = dblarr(lmax_file+1)
    scalpp = dblarr(lmax_file+1)

    scaltt[2:lmax_file] = cltt_tmp[0:lmax_file-2]
    scalee[2:lmax_file] = clee_tmp[0:lmax_file-2]
    scalte[2:lmax_file] = clte_tmp[0:lmax_file-2]
    scalpp[2:lmax_file] = clpp_tmp[0:lmax_file-2]

    cls = create_struct('lmax',lmax_file, 'TT',lensedtt, 'EE',lensedee, 'TE',lensedte, $
                        'scalcls_tt',scaltt, 'scalcls_ee',scalee, 'scalcls_te',scalte, 'scalcls_pp',scalpp)

    spawn, 'rm -rf /tmp/'+output_root+'_*'

    return
end
