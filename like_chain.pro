function like_chain, chain, nbins, xmin=xmin, xmax=xmax

    list = sort(chain)
    param_list = chain(list)
    ct_total = n_elements(chain)

    if (keyword_set(xmin)) then xmin1 = xmin else xmin1 = min(chain)
    if (keyword_set(xmax)) then xmax1 = xmax else xmax1 = max(chain)
    
    x_interval = xmax1 - xmin1
    dx = x_interval / nbins

    xarr = dindgen(nbins+1L)/nbins * x_interval + xmin1 + 0.5*dx

    yarr = double(histogram(chain, nbins=nbins, min=xmin1, max=xmax1))
    yarr /= max(yarr)

    plike = create_struct('nx',nbins, 'x',xarr[0:nbins-1], 'like',yarr)
    return, plike
end
