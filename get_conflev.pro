pro get_conflev, array, weight, report, weight_accu=weight_accu

    report = fltarr(10)
    nsteps = n_elements(array)

    steps_array = dblarr(nsteps)
    if (not keyword_set(weight_accu)) then begin
        for i=0, nsteps-1 do steps_array[i] = total(double(weight(0:i)))
        weight_accu = steps_array
    endif else begin
        steps_array = double(weight_accu)
    endelse

    list = sort(array)

    param_list = array(list)
    dnsteps = total(double(weight))

    p3s_low = (where(steps_array ge nint(0.0013d0*dnsteps)))[0]
    p2s_low = (where(steps_array ge nint(0.0228d0*dnsteps)))[0]
    p1s_low = (where(steps_array ge nint(0.1587d0*dnsteps)))[0]
    p_med   = (where(steps_array ge nint(0.5000d0*dnsteps)))[0]
    p1s_up  = (where(steps_array ge nint(0.8413d0*dnsteps)))[0]
    p2s_up  = (where(steps_array ge nint(0.9772d0*dnsteps)))[0]
    p3s_up  = (where(steps_array ge nint(0.9987d0*dnsteps)))[0]

    p95  = (where(steps_array ge nint(0.9544d0*dnsteps)))[0]
    p68  = (where(steps_array ge nint(0.6826d0*dnsteps)))[0]
    
    report[0] = param_list[p_med]
    report[1] = param_list[p1s_up]
    report[2] = param_list[p1s_low]
    report[3] = param_list[p2s_up]
    report[4] = param_list[p2s_low]
    report[5] = param_list[p3s_up]
    report[6] = param_list[p3s_low]

    return
    
end
