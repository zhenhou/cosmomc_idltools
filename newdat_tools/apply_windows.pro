pro apply_windows, cls_in, cls_out, windows, input_dls=input_dls
    
    lmax = n_elements(windows[*,0])-1
    nbands = n_elements(windows[0,*])

    il = dindgen(lmax+1)

    cls_out = dblarr(nbands)
    
    for ib=0, nbands-1 do begin
        if keyword_set(input_dls) then begin
            cls_out[ib] = total(cls_in[0:lmax]*windows[0:lmax,ib]*(il+0.50d0)/(il+1.0d0))
        endif else begin
            cls_out[ib] = total(cls_in[0:lmax]*windows[0:lmax,ib]*il*(il+0.50d0)/(2.0d0*!dpi))
        endelse
    endfor

    RETURN
end
