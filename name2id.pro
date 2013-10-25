function name2id, pname, paramnames=paramnames
    
    if (strcompress(paramnames[0],/remove) eq 'logL') then begin
        name1 = paramnames[1:*]
    endif else begin
        name1 = paramnames
    endelse
    
    n = n_elements(pname)
    id = lonarr(n)

    for i=0, n-1 do begin
        name = strcompress(pname[i], /remove)
        id[i] = where(name1 eq name) + 1
        if (id[i] eq 0) then begin
            print, 'parameter name not found: '+name
            ;stop
        endif
    endfor

    return, id
end
