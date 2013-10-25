PRO float2char, med, up, down, char, form
    
    if (med eq 0.00 or (down eq 0.00 and up eq 0.00)) then begin
        char = '-'
        return
    endif

    if (abs(2.0*(up-down)/(up+down)) le 0.10) then begin
        openw, 10, '/tmp/tmp.txt'
        printf, 10, format=form, med
        printf, 10, format=form, 0.50*(up+down)
        close, 10

        a = '12345678'
        b = a
        openr, 10, '/tmp/tmp.txt'
        readf, 10, a
        readf, 10, b
        close, 10

        m = strcompress(a, /remove)
        e = strcompress(b, /remove)
        
        char = '$'+m+'\pm '+e+'$'
        
    endif else begin
    
        openw, 10, '/tmp/tmp.txt'
        printf, 10, format=form, med
        printf, 10, format=form, up
        printf, 10, format=form, down
        close, 10
        
        a = '12345678'
        b = a
        c = a
        openr, 10, '/tmp/tmp.txt'
        readf, 10, a
        readf, 10, b
        readf, 10, c
        close, 10

        m = strcompress(a, /remove)
        u = strcompress(b, /remove)
        d = strcompress(c, /remove)

        char = '$'+m+'^{+'+u+'}_{-'+d+'}$'
        if (u eq d) then char = '$'+m+'\pm '+u+'$'
    endelse

    return
END


pro bound2char, u95, char, form
    
    openw, 10, '/tmp/tmp.txt'
    printf, 10, format=form, u95
    close, 10
        
    a = '12345678'
    openr, 10, '/tmp/tmp.txt'
    readf, 10, a
    close, 10

    m = strcompress(a, /remove)
    char = '$<'+m+'\;(95\%\;\rm{CL})$'
end


PRO get_report, path, prefix, pnames, scales, format, char_list, oneside=oneside
    
    nparams = n_elements(pnames)
    char_list = strarr(nparams)

    mcmc = read_chains(8, 1000, path, prefix)
    params_id = name2id(pnames, path, prefix)
    
    likes = get_loglikes(path, prefix, nskip=1000, mcmc=mcmc)
    
    ;tmp_file = 'tmp/'+prefix+'.txt'
    ;openw, 5, tmp_file
    for ip=0, nparams-1 do begin
        chain = get_chain(pnames[ip], path, prefix, mcmc=mcmc)

        if (pnames[ip] eq 'Dvp35ors' or pnames[ip] eq 'Dvp57ors') then chain = 1.0/chain

        chain *= scales[ip]
        param_report, chain, likes, rep

        med = rep[3]
        up = rep[4] - rep[3]
        down = rep[3] - rep[2]

        const = 0

        print, med

        if (up eq 0.00 and down eq 0.00) then const=1

        if (keyword_set(oneside) and oneside[ip] eq 1 and const eq 0) then begin
            p1d = like_chain(chain,60)
            thd = p1d.like[0]
            like95 = INTERPOL(p1d.like, p1d.x, rep[8], /SPLINE)

            if (like95 lt thd) then $
                bound2char, rep[8], char, format[ip] $
            else $
                float2char, med, up, down, char, format[ip]
        endif else begin
            float2char, med, up, down, char, format[ip]
        endelse

        char_list[ip] = char
        
        ;printf, 5, char
    endfor
    ;close, 5

    return
END






PRO gen_table, model, filename=filename, transp=transp

    @params
    
    exe = model+'_inc, path, prefix, paramname, scales, format'
    res = execute(exe)
    
    ;path = '/home/hou/scratch/data/spt.lps12/paramfits_0828/'
    ;prefix = ['c19_lcdm_mnu_pico_w7s12', $
    ;          'c20_lcdm_mnu_pico_w7s12_BAO',$
    ;          'c21_lcdm_mnu_pico_w7s12_H0', $
    ;          'c32_lcdm_mnu_camb_w7s12_LRG', $
    ;          'c33_lcdm_mnu_camb_w7s12_SZC', $
    ;          'c99_lcdm_mnu_camb_w7s12_BAO_SZC']
    ;
    ;paramname = ['omegabh2','omegadmh2','1e-9As','ns',    'theta_s','tau',   'sum_mnu*','omegal*','H0*',  'sigma8*','z_eq']
    ;scales    = [100.0,     1.0,        1.0,     1.0,     100.0,    1.0,     1.0,       1.0,      1.0,    1.0,      1.0]
    ;format    = ['(F5.3)',  '(F6.4)',   '(F5.3)','(F5.3)','(F6.4)', '(F5.3)','(F4.2)',  '(F5.3)','(F5.2)','(F5.3)', '(F6.1)']
    
    nparams = n_elements(paramname)
    nsets = n_elements(prefix)

    oneidx = intarr(nparams)
    
    ;ipr = where(paramname eq 'r')
    ;ipm = where(paramname eq 'sum_mnu*')
    ;ipl = where(paramname eq 'omegal*')

    ;if (ipr ne -1) then oneidx[ipr] = 1
    ;if (ipm ne -1) then oneidx[ipm] = 1

    ipp = where(paramname eq 'aps')
    ipc = where(paramname eq 'acl')

    if (ipp ne -1) then oneidx[ipp] = 1
    if (ipc ne -1) then oneidx[ipc] = 1

    report = strarr(nsets, nparams)

    ;openw, 15, 'table.txt'
    for iset=0, nsets-1 do begin
        get_report, path, prefix[iset], paramname, scales, format, char_list, oneside=oneidx
        ;printf, 15, line+' \\'
        report[iset,*] = char_list[*]
    endfor
    ;close, 15

    if (not keyword_set(filename)) then filename='table_'+model+'.txt'

    openw, 15, filename
    for iset=0, nsets-1 do begin
        printf, 15, prefix[iset]
    endfor
    

    if (not keyword_set(transp)) then begin
        mult = ' '
        ;for i=0, nsets-1 do mult+='& '
        ;printf, 15, 'Baseline parameters'+mult+' \\'
        for ip=0, nparams-1 do begin
            ;id = name2id(paramname[ip], path, prefix[0])
            ;line = pname_tex[id]
            line = ' '

            ;if (ip eq ipl) then printf, 15, 'Derived parameters'+mult+' \\'
            for iset=0, nsets-1 do begin
                ;line += ' & '+report[iset,ip]
                line += '   '+report[iset,ip]
            endfor
            ;line += ' \\'
            printf, 15, line
        endfor
        close, 15
    endif else begin
        for iset=0, nsets-1 do begin
            line = ' '
            for ip=0, nparams-1 do begin
                line += ' & '+report[iset,ip]
            endfor
            line += ' \\'
            printf, 15, line
        endfor
        close, 15
    endelse
END
