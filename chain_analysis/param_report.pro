PRO param_report, chain, loglikes, rep, oneside=oneside

    rep = fltarr(10)
    nsteps = n_elements(chain)    
     
    steps_chain = lindgen(nsteps)+1L
    list = sort(chain)

    param_list = chain(list)
    dnsteps = double(nsteps)
    
    p3s_low = (where(steps_chain ge nint(0.0013d0*dnsteps)))[0]
    p2s_low = (where(steps_chain ge nint(0.0228d0*dnsteps)))[0]
    p1s_low = (where(steps_chain ge nint(0.1587d0*dnsteps)))[0]
    p_med   = (where(steps_chain ge nint(0.5000d0*dnsteps)))[0]
    p_best  = where(loglikes eq min(loglikes))
    p1s_up  = (where(steps_chain ge nint(0.8413d0*dnsteps)))[0]
    p2s_up  = (where(steps_chain ge nint(0.9772d0*dnsteps)))[0]
    p3s_up  = (where(steps_chain ge nint(0.9987d0*dnsteps)))[0]

    p95  = (where(steps_chain ge nint(0.9544d0*dnsteps)))[0]
    p68  = (where(steps_chain ge nint(0.6826d0*dnsteps)))[0]

    rep[0] = param_list[p3s_low]
    rep[1] = param_list[p2s_low]
    rep[2] = param_list[p1s_low]
    rep[3] = param_list[p_med]
    rep[4] = param_list[p1s_up]
    rep[5] = param_list[p2s_up]
    rep[6] = param_list[p3s_up]

    rep[7] = param_list[p_best[0]]
    if (keyword_set(oneside)) then begin
        rep[8] = param_list[p95]
        rep[9] = param_list[p68]
    endif
    
    ;print, rep[7]
    ;print, mean(param_list)
    ;print, rep[3],' -',rep[3]-rep[2], ' +',rep[4]-rep[3]

    ;print, param_list[p3s_low], param_list[p3s_low]-param_list[p_med]
    ;print, param_list[p2s_low], param_list[p2s_low]-param_list[p_med]
    ;print, param_list[p1s_low], param_list[p1s_low]-param_list[p_med]
    ;print, param_list[p_med]
    ;print, param_list[p_best]
    ;print, param_list[p1s_up], param_list[p1s_up]-param_list[p_med]
    ;print, param_list[p2s_up], param_list[p2s_up]-param_list[p_med]
    ;print, param_list[p3s_up], param_list[p3s_up]-param_list[p_med]
END
