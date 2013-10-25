pro plot2d_xy, px, py, xscale, yscale, path, prefix, $
position, xrange, yrange, c_color, c_thick, xthick, ythick, $
xtitle, ytitle, charsize, charthick, smoothing
    
    p2d = read_2d(path, prefix, px, py)

    xarr = p2d.x*xscale
    yarr = p2d.y*yscale
    dist2d = p2d.dist2d
    cont2d = p2d.cont

    if (keyword_set(smoothing)) then begin
        nm1 = max(dist2d)
        dist2d = smooth(dist2d, smoothing, /edge)
        nm2 = max(dist2d)
        dist2d *= nm1/nm2
    endif

    contour, dist2d, xarr, yarr, position=position, xstyle=1, ystyle=1, $
    xrange=xrange, yrange=yrange, xtickformat='(A3)', ytickformat='(A3)', $
    /nodata

    contour, dist2d, xarr, yarr, levels=cont2d, c_thick=c_thick, $
    c_color=c_color, /fill, /over
    contour, dist2d, xarr, yarr, levels=cont2d, c_thick=c_thick, $
    c_color=[c_color[1],c_color[1]], /over

    axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
    charthick=charthick, xtitle=xtitle
    axis, xaxis=1, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
    charthick=charthick, xtickformat='(A3)'

    axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
    charthick=charthick, ytitle=ytitle
    axis, yaxis=1, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
    charthick=charthick, ytickformat='(A3)'

end
