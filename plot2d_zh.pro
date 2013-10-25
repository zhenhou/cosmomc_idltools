pro plot2d_zh, p2d, xscale, yscale, $
position, xrange, yrange, c_color, c_thick, xthick, ythick, $
xtitle, ytitle, charsize, charthick, smoothing=smoothing, $
noxtickname=noxtickname, noytickname=noytickname, xy_ytitle=xy_ytitle, $
p2d_smth=p2d_smth, noplot=noplot, overplot=overplot, noclines=noclines, $
font=font

    xarr = p2d.x*xscale
    yarr = p2d.y*yscale
    dist2d = p2d.like2d
    cont2d = p2d.levels[1:2]
    
    if (keyword_set(smoothing)) then begin
        dist2d = smooth(dist2d, smoothing, /edge_mirror)

        sigma = [1., 2., 3.]
        ptes = erf(sigma/sqrt(2.))
        nm = total(dist2d)
        prob = dist2d/nm
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
        cont2d = clevels[1:2]
        dist2d = prob

        p2d_smth = create_struct('nx',n_elements(xarr), 'x',xarr, 'ny',n_elements(yarr), $
        'y',yarr, 'like2d',dist2d, 'levels',clevels)
    endif

    if (keyword_set(noplot)) then begin
        return
    endif else begin
    
    if (keyword_set(overplot)) then begin
        contour, dist2d, xarr, yarr, position=position, xstyle=1, ystyle=1, $
        xrange=xrange, yrange=yrange, xtickformat='(A1)', ytickformat='(A1)', $
        /nodata, /over
    endif else begin
        contour, dist2d, xarr, yarr, position=position, xstyle=1, ystyle=1, $
        xrange=xrange, yrange=yrange, xtickformat='(A1)', ytickformat='(A1)', $
        /nodata
    endelse

    contour, dist2d, xarr, yarr, levels=cont2d, c_thick=c_thick, $
    c_color=c_color, /fill, /over

    if (not keyword_set(noclines)) then begin
        contour, dist2d, xarr, yarr, levels=cont2d[0], c_thick=c_thick[1], $
        c_color=[c_color[1]], /over
    endif
    
    if (keyword_set(noxtickname)) then begin
        axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
        charthick=charthick, xtickformat='(A1)'
    endif else begin
        axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
        charthick=charthick, xtitle=xtitle, font=font
    endelse
    
    axis, xaxis=1, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
    charthick=charthick, xtickformat='(A1)'
    
    if (keyword_set(noytickname)) then begin
        axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
        charthick=charthick, ytickformat='(A1)'
    endif else begin
        if (keyword_set(xy_ytitle)) then begin
            axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
            charthick=charthick, font=font

            xyouts, position[0]-0.1, 0.5*(position[3]+position[1]), ytitle, orientation=90, /normal, $
            alignment=0.5, charsize=charsize, charthick=charthick, font=font
        endif else begin
            axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
            charthick=charthick, ytitle=ytitle, font=font
        endelse
    endelse
    
    axis, yaxis=1, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
    charthick=charthick, ytickformat='(A1)'

    endelse
    
end
