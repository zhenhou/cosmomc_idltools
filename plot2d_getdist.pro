pro plot2d_getdist, p2d, $
    position, xrange, yrange, c_color, c_thick, xthick, ythick, $
    xtitle, ytitle, charsize, charthick, overplot=overplot, xticks=xticks, yticks=yticks, $
    xtickv=xtickv, ytickv=ytickv, xtickname=xtickname, ytickname=ytickname

    xarr = p2d.x
    yarr = p2d.y
    dist2d = p2d.like2d
    cont2d = p2d.levels


    if (keyword_set(overplot)) then begin
        contour, dist2d, xarr, yarr, position=position, xstyle=1, ystyle=1, $
        xrange=xrange, yrange=yrange, xtickformat='(A1)', ytickformat='(A1)', $
        /nodata, /over, xthick=xthick, ythick=ythick
    endif else begin
        contour, dist2d, xarr, yarr, position=position, xstyle=1, ystyle=1, $
        xrange=xrange, yrange=yrange, xtickformat='(A1)', ytickformat='(A1)', $
        /nodata, xthick=xthick, ythick=ythick
    endelse

    contour, dist2d, xarr, yarr, levels=cont2d, c_thick=c_thick, $
    c_color=c_color, /fill, /over

    contour, dist2d, xarr, yarr, levels=cont2d[0], c_thick=c_thick[1], $
    c_color=[c_color[1]], /over

    axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, xcharsize=charsize, $
    charthick=charthick, xtitle=xtitle, xticks=xticks, $
    xtickv=xtickv, xtickname=xtickname

    axis, xaxis=1, xstyle=1, xrange=xrange, xthick=xthick, xcharsize=charsize, $
    charthick=charthick, xtickformat='(A1)', xticks=xticks, $
    xtickv=xtickv

    axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, ycharsize=charsize, $
    charthick=charthick, ytitle=ytitle, yticks=yticks, $
    ytickv=ytickv, ytickname=ytickname

    axis, yaxis=1, ystyle=1, yrange=yrange, ythick=ythick, ycharsize=charsize, $
    charthick=charthick, ytickformat='(A1)', yticks=yticks, $
    ytickv=ytickv
end
