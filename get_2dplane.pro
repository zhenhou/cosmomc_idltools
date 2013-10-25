function get_2dplane, p1_chain, p2_chain, nbins_raw, frate, $
xaxis_zero=xaxis_zero, yaxis_zero=yaxis_zero, nointerp=nointerp

    nsteps = n_elements(p1_chain)
    if (n_elements(p1_chain) ne nsteps) then begin
        print, 'p1_chain and p2_chain should have the same length.'
        stop
    endif

    xmin1 = min(p1_chain, max=xmax1)
    xmin2 = min(p2_chain, max=xmax2)

    if (keyword_set(xaxis_zero)) then xmin1 = 0.0
    if (keyword_set(yaxis_zero)) then xmin2 = 0.0
    
    nbins = nbins_raw

    x1_interval = xmax1 - xmin1
    dx1 = x1_interval / (nbins-1)
    ;x1arr_raw = dindgen(nbins)/nbins * x1_interval + xmin1 + 0.5*dx1

    x2_interval = xmax2 - xmin2
    dx2 = x2_interval / (nbins-1)
    ;x2arr_raw = dindgen(nbins)/nbins * x2_interval + xmin2 + 0.5*dx2

    plane = hist_2d(p1_chain, p2_chain, min1=xmin1, min2=xmin2, max1=xmax1, max2=xmax2, bin1=dx1, bin2=dx2)
    plane = double(plane)
    
    nm = max(plane)
    plane /= nm

    dims = size(plane, /dim) ;get dimensions of 2d histogram
    ;interpolate image to a grid 5 times smaller
    if (not keyword_set(nointerp)) then begin
        fineplane = min_curve_surf(plane, /regular, nx=(dims[0]-1)*frate+1, ny=(dims[1]-1)*frate+1, /double)
    endif else begin
        fineplane = plane
        frate = 1.0
    endelse

    sigma = [1., 2., 3.]
    ptes = erf(sigma/sqrt(2.))
    nm = total(fineplane)
    prob = fineplane/nm
    ind = reverse(sort(prob))   ; in descending order
    psort = prob(ind)
    pcum=total(psort,/cum)
    nline = n_elements(sigma)
    levels = fltarr(nline)
    for i=0,nline-1 do begin
        ii = min(where(pcum gt ptes[i],nn))
        if nn gt 0 then $
            levels[i]=psort(ii) $
        else stop
    endfor
    clevels = levels(sort(levels))
    
    dims2=size(prob, /dim)
    x1arr=dindgen(dims2[0])*dx1/frate + (xmin1+0.5d0*dx1)
    x2arr=dindgen(dims2[1])*dx2/frate + (xmin2+0.5d0*dx2)
    
    nx1 = (nbins-1)*frate+1
    nx2 = (nbins-1)*frate+1

    if keyword_set(yaxis_zero) then begin
        dy = x2arr[1]-x2arr[0]
        nadd = long(x2arr[0]/dy)+1
        n = nadd - findgen(nadd)

        new_bins2 = x2arr[0] - n*dy
        new_prob = fltarr(n_elements(x1arr),nadd)

        for i=0,n_elements(x1arr)-1 do begin
            tmp = prob[i,*]
            res = interpol(tmp,x2arr,new_bins2, /spline)
            new_prob[i,*] = res
        endfor

        x2arr = [new_bins2,x2arr]
        tmp_prob = fltarr(n_elements(x1arr), n_elements(x2arr))
        tmp_prob(*,nadd:*) = prob
        tmp_prob(*,0:nadd-1) = new_prob
        prob = tmp_prob


        ;new_bins2 = x2arr[0] - (x2arr[1]-x2arr[0])
        ;new_prob = fltarr(n_elements(x1arr))
        ;for i=0,n_elements(x1arr)-1 do new_prob[i] = interpol(prob[i,*],x2arr,new_bins2, /quad)
        ;x2arr = [new_bins2,x2arr]
        ;tmp_prob = fltarr(n_elements(x1arr), n_elements(x2arr))
        ;tmp_prob(*,1:*) = prob
        ;tmp_prob(*,0) = new_prob
        ;prob = tmp_prob
    endif

    if keyword_set(xaxis_zero) then begin
        dx = x1arr[1]-x1arr[0]
        nadd = long(x1arr[0]/dx)+1
        n = nadd - findgen(nadd)

        new_bins1 = x1arr[0] - n*dx

        new_prob = fltarr(nadd, n_elements(x2arr))

        for i=0,n_elements(x2arr)-1 do begin
            tmp = prob[*,i]
            res = interpol(tmp,x1arr,new_bins1, /spline)
            new_prob[*,i] = res
        endfor

        x1arr = [new_bins1,x1arr]
        tmp_prob = fltarr(n_elements(x1arr), n_elements(x2arr))
        tmp_prob(nadd:*,*) = prob
        tmp_prob(0:nadd-1,*) = new_prob
        prob = tmp_prob
    endif


    plane2d = create_struct('nx',nx1, 'x',x1arr, 'ny',nx2, 'y',x2arr, 'like2d',prob, 'levels',clevels)
    return, plane2d
end
