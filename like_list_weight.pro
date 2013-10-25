function like_list_weight, list, weight, nbins, xmin=xmin, xmax=xmax

    ;list = sort(chain)
    ;param_list = chain(list)
    ct_total = n_elements(list)

    if (keyword_set(xmin)) then xmin1 = xmin else xmin1 = min(list)
    if (keyword_set(xmax)) then xmax1 = xmax else xmax1 = max(list)
    
    x_interval = xmax1 - xmin1
    dx = x_interval / nbins

    xarr = dindgen(nbins+1L)/nbins * x_interval + xmin1 + 0.5*dx

    yraw = long((list-xmin1-0.5*dx)/dx)
    ;print,max(yraw), min(yraw)
    yarr = dblarr(nbins)
    for i=0L, ct_total-1L do begin
       yarr[yraw[i]] += weight[i]
    endfor

    yarr /= max(yarr)

    plike = create_struct('nx',nbins, 'x',xarr[0:nbins-1], 'like',yarr)
    return, plike
    
    
end
