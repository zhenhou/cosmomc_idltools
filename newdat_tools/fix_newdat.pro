function preload_newdat, file_in, has_pol=has_pol

    types = ['TT','EE','BB','EB','TE','TB']
    
    a = '  ' 
    nbands = lonarr(6)
    get_lun, unit
    openr, unit, file_in
    readf, unit, a

    ;;-------------------
    readf, unit, a
    b = strcompress(a, /remove)
    if (strcmp(strmid(b,0,1),'#') eq 1) then begin
        readf, unit, a
    endif

    res = strsplit(a, ' ', /extract)
    nbands = long(res)
    if (nbands[3] ne 0 and nbands[4] eq 0) then begin
        tmp = nbands[3]
        nbands[3] = nbands[4]
        nbands[4] = tmp
    endif
    ;;-------------------
    has_pol = 1
    if (total(nbands) eq nbands[0]) then has_pol=0

    nlines = max(nbands)
    tmp = dblarr(5, nlines, 6)
    col_select = [1,2,3,5,6]

    while ~eof(unit) do begin
        readf, unit, a
        s = strcompress(a,/remove)
        itype = where(types eq s)
        if (itype ne -1) then begin
            tmp_read =dblarr(8,nbands[itype])
            readf, unit, tmp_read
            tmp[*,0:nbands[itype]-1,itype] = tmp_read[col_select,*]
        endif
    endwhile
    free_lun, unit

    ndf = {}
    for itype=5, 0, -1 do begin
        if nbands[itype] ne 0 then ndf = create_struct(types[itype],tmp[*,0:nbands[itype]-1,itype], ndf)
    endfor

    data = create_struct(['bands'], ndf)

    return, data
end

pro fix_newdat, file_in, file_out, lrange_TT, lrange_EE, lrange_BB, lrange_TE
    
    has_pol = 1
    ndf = preload_newdat(file_in, has_pol=has_pol)
    
    bmin_TT = (where(ndf.bands.TT[3,*] ge lrange_TT[0]))[0]+1
    bmax_TT = (where(ndf.bands.TT[4,*] ge lrange_TT[1]))[0]+1
    
    if (has_pol) then begin
    bmin_EE = (where(ndf.bands.EE[3,*] ge lrange_EE[0]))[0]+1
    bmax_EE = (where(ndf.bands.EE[4,*] ge lrange_EE[1]))[0]+1

    bmin_BB = (where(ndf.bands.BB[3,*] ge lrange_BB[0]))[0]+1
    bmax_BB = (where(ndf.bands.BB[4,*] ge lrange_BB[1]))[0]+1

    bmin_TE = (where(ndf.bands.TE[3,*] ge lrange_TE[0]))[0]+1
    bmax_TE = (where(ndf.bands.TE[4,*] ge lrange_TE[1]))[0]+1
    endif

    ;if (lrange_TT[0] eq 0) then bmin_TT = 0
    if (lrange_TT[1] eq 0) then begin
        bmax_TT = 0
        bmin_TT = 0
    endif

    ;if (lrange_EE[0] eq 0) then bmin_EE = 0
    if (lrange_EE[1] eq 0) then begin
        bmax_EE = 0
        bmin_EE = 0
    endif

    ;if (lrange_BB[0] eq 0) then bmin_BB = 0
    if (lrange_BB[1] eq 0) then begin
        bmax_BB = 0
        bmin_BB = 0
    endif

    ;if (lrange_TE[0] eq 0) then bmin_TE = 0
    if (lrange_TE[1] eq 0) then begin
        bmax_TE = 0
        bmin_TE = 0
    endif
    
    get_lun, unit_in
    get_lun, unit_out

    a = ' '

    openr, unit_in, file_in
    readf, unit_in, a
    readf, unit_in, a
    b = strcompress(a, /remove)
    if (strcmp(strmid(b,0,1),'#') eq 1) then begin
        readf, unit_in, a
    endif

    res = strsplit(a, ' ', /extract)
    nbands = long(res)
    num_bands = total(nbands,/integer)
    free_lun, unit_in

    get_lun, unit_in
    openr, unit_in, file_in
    openw, unit_out, file_out
    
    ;;-------------
    readf, unit_in, a
    printf, unit_out, 'windows_tophat_'+strcompress(string(num_bands),/remove)+'/window_'
    
    ;;-------------
    readf, unit_in, a
    b = strcompress(a, /remove)
    if (strcmp(strmid(b,0,1),'#') eq 1) then begin
        readf, unit_in, a
    endif

    res = strsplit(a, ' ', /extract)
    nbands = long(res)
    if (nbands[3] ne 0 and nbands[4] eq 0) then begin
        tmp = nbands[3]
        nbands[3] = nbands[4]
        nbands[4] = tmp
    endif
    printf, unit_out, format='(6I6)', nbands

    ;;-------------
    readf, unit_in, a
    if (strcompress(a, /remove) eq 'BAND_SELECTION') then begin
        printf, unit_out, a

        for i=0, 5 do begin
            readf, unit_in, a
            printf, unit_out, a
        endfor
    endif else begin
        printf, unit_out, 'BAND_SELECTION'
        printf, unit_out, format='(2I6)', bmin_TT, bmax_TT
        printf, unit_out, format='(2I6)', bmin_EE, bmax_EE
        printf, unit_out, format='(2I6)', bmin_BB, bmax_BB
        printf, unit_out, format='(2I6)', 0, 0
        printf, unit_out, format='(2I6)', bmin_TE, bmax_TE
        printf, unit_out, format='(2I6)', 0, 0
        printf, unit_out, a
    endelse

    ;;-------------
    readf, unit_in, a
    printf, unit_out, a

    readf, unit_in, a
    res = strsplit(a, ' ', /extract)
    if (n_elements(res) eq 2) then begin
        if (long(res[0]) eq 2) then begin
            res[0] = '0'
            printf, unit_out, res[0]+'   '+res[1]
        endif else begin
            print, "CHECK the original newdat file!!"
            print, "for safety, stop"
            stop
        endelse
    endif else begin
        print, "ERROR when reading original newdat file!!"
        stop
    endelse

    while ~eof(unit_in) do begin
        readf, unit_in, a
        printf, unit_out, a
    endwhile
    free_lun, unit_in
    free_lun, unit_out
    
    
end
