function paramsta, pchain, plike
    
    nsteps = n_elements(pchain)
    nsteps = double(nsteps)

    p3s_low = nint(0.0013*nsteps)
    p2s_low = nint(0.0228*nsteps)
    p1s_low = nint(0.1587*nsteps)
    p_med   = nint(0.5000*nsteps) 
    p1s_up  = nint(0.8413*nsteps)
    p2s_up  = nint(0.9772*nsteps)
    p3s_up  = nint(0.9987*nsteps)

    p_best  = min(where(plike eq min(plike)))
    best = pchain[p_best]
    ave  = mean(pchain)

    list = sort(pchain)
    param_list = pchain(list)

    p3_low = param_list[p3s_low]
    p2_low = param_list[p2s_low]
    p1_low = param_list[p1s_low]
    med    = param_list[p_med]
    p1_up  = param_list[p1s_up]
    p2_up  = param_list[p2s_up]
    p3_up  = param_list[p3s_up]

    sta = create_struct('mean', ave, 's1range',[p1_low,p1_up], 's2range',[p2_low,p2_up], $
                        's3range',[p3_low,p3_up], 'best',best, 'median',med)
    return, sta
end
