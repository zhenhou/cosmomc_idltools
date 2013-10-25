pro gen_report, path, prefix, pnames, scales, report

    nparams = n_elements(pnames)
    
    report = fltarr(3,nparams)

    mcmc = read_chains(8, 1000, path, prefix)
    
    likes = get_loglikes(path, prefix, mcmc=mcmc)

    for ip=0, nparams-1 do begin
        chain = get_chain(pnames[ip], path, prefix, mcmc=mcmc)

        chain *= scales[ip]
        param_report, chain, likes, rep

        med = rep[3]
        up = rep[4] - rep[3]
        down = rep[3] - rep[2]

        report[0,ip] = med
        report[1,ip] = up
        report[2,ip] = down
        
    endfor
end


pro make_params_report, model, filename=filename

    exe = model+'_inc, path, prefix, paramname, scales, format'
    res = execute(exe)

    nparams = n_elements(paramname)
    nsets = n_elements(prefix)

    rep_all = fltarr(3, nparams, nsets)
    
    for iset=0, nsets-1 do begin
        gen_report, path, prefix[iset], paramname, scales, report
        rep_all[*,*,iset] = report
    endfor

    openw, 5, filename
    writeu, 5, rep_all
    close, 5

end
