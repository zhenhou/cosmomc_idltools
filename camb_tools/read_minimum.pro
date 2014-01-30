function read_minimum, path, root, read_cls=read_cls

    minimum_file = path+'/'+root+'.minimum'
    cls_file     = path+'/'+root+'.bestfit_cl'
    
    paramnames = strarr(100)
    params     = dblarr(100)

    a= ' '
    b = 0.0d0
    get_lun, unit
    openr, unit, minimum_file
    readf, unit, format='(A13,D)', a, b
    logL = b

    readf, unit, format='(A13,D)', a, b
    chisq = b

    readf, unit, a

    ct = 0
    ip = 0
    num_base = 0
    num_nonused = 0
    num_derived = 0
    while ~eof(unit) do begin
        readf, unit, a
        if (strcompress(a,/remove) ne '') then begin
            str = strsplit(a, ' ', /extract)
            paramnames[ip] = str[2]
            params[ip] = double(str[1])

            ip += 1
        endif else begin
            ct += 1
            if (ct eq 1) then num_base = ip
            if (ct eq 2) then num_nonused = ip - num_base
            if (ct eq 3) then begin
                num_derived = ip - num_base - num_nonused
                break
            endif
        endelse
    endwhile
    free_lun, unit

    params_base = params[0:num_base-1]
    paramnames_base = paramnames[0:num_base-1]

    params_nonused = params[num_base:num_base+num_nonused-1]
    paramnames_nonused = paramnames[num_base:num_base+num_nonused-1]

    params_derived = params[num_base+num_nonused:num_base+num_nonused+num_derived-1]
    paramnames_nonused = paramnames[num_base+num_nonused:num_base+num_nonused+num_derived-1]

    minimum_info = create_struct('logL',logL, 'params_base',params_base, 'paramnames_base',paramnames_base)

    return, minimum_info
end
