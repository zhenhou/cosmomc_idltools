pro get_post_sample_txt, path, prefix, ith_sample, sample_info, lmax=lmax, no_cls=no_cls
    
    if (not keyword_set(lmax)) then lmax = 2500L

    sidx = strcompress(string(ith_sample),/remove)
    file = path+'/'+prefix+'_'+sidx+'.cls'

    a = ' '
    b = ' '
    logL = 0.00d0
    cls = dblarr(4, lmax+1)
    tmp = dblarr(5)

    get_lun, unit
    openr, unit, file
    while ~eof(unit) do begin
        readf, unit, a
        if strcmp(strcompress(a,/remove), '#-logL') eq 1 then begin
            readf, unit, format='(A25,E18.9)', b, logL
        endif
        
        if keyword_set(no_cls) then break

        if strcmp(strcompress(a,/remove), '#Cls') eq 1 then begin
            for il=2, lmax do begin
                readf, unit, tmp
                il = long(tmp[0])
                cls[0:3,il] = tmp[1:4]
            endfor
        endif
    endwhile
    free_lun, unit

    sample_info = create_struct('logL',logL,'TT',reform(cls[0,*]),'TE',reform(cls[1,*]),'EE',reform(cls[2,*]))

    return
end
