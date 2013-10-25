function read_wmap_chain, path, prefix, pname, savfile=savfile

    filename = path+prefix+'/'+'weight'
    readcol, filename, iarr, weight, format='(D,D)', count=nw, /silent
    weight = long(weight)
        
    filename = path+prefix+'/'+pname
    readcol, filename, iarr, plist, format='(D,D)', count=nw, /silent

    ;filename = path+prefix+'/omegabh2'
    ;readcol, filename, iarr, p1list, format='(D,D)', count=nw, /silent
    ;filename = path+prefix+'/omegamh2'
    ;readcol, filename, iarr, p2list, format='(D,D)', count=nw, /silent
    ;filename = path+prefix+'/omeganh2'
    ;readcol, filename, iarr, p3list, format='(D,D)', count=nw, /silent

    ;plist = p3list/(p2list-p1list)

    list = sort(plist)
    param_list = plist(list)
    ct_total = n_elements(plist)
    ip = nint(0.95*float(ct_total))
    print, param_list[ip]

    xmin = min(plist)
    xmax = max(plist)
    
    x_interval = xmax - xmin
    dx = x_interval / nbins

    xarr = dindgen(nbins)/nbins * x_interval + xmin + 0.5*dx
    
    nsamples = total(weight,/int)
    plist_full = dblarr(nsamples)
    
    ip = 0L
    for i=0L, nw-1L do begin
        istart = ip
        iend = ip+weight[i]-1

        plist_full[istart:iend] = plist[i]
        ip = iend + 1L
    endfor

    yarr = double(histogram(plist_full, nbins=nbins+1, min=xmin, max=xmax))
    yarr /= max(yarr)

    plike = create_struct('nx',nbins, 'x',xarr, 'like',yarr)
    return, plike
end
