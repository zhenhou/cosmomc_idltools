pro plot_prior, ave, err, position, xrange, yrange, color, thick, xthick, ythick, $
xtitle, ytitle, charsize, charthick, xprior=xprior, yprior=yprior, over=over, $
setaxis=setaxis, noxtickname=noxtickname, noytickname=noytickname, xy_ytitle=xy_ytitle

    if (keyword_set(yprior)) then begin
        ypoly = [ave+err, ave+err, ave-err, ave-err]
        xpoly = [xrange[0],xrange[1],xrange[1],xrange[0]]
    endif   

    if (keyword_set(xprior)) then begin
        xpoly = [ave-err, ave+err, ave+err, ave-err]
        ypoly = [yrange[1],yrange[1],yrange[0],yrange[0]]
    endif

    nc = n_elements(color)
    
    if (not keyword_set(over)) then begin
        plot, xrange, yrange, xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, $
        xtickformat='(A1)', ytickformat='(A1)', position=position, /nodata
    endif

    polyfill, xpoly, ypoly, color=color[0]
    
    if (keyword_set(xprior)) then begin
        oplot, [ave, ave], yrange, thick=thick
    endif

    if (keyword_set(yprior)) then begin
        oplot, xrange, [ave, ave], thick=thick
    endif
    
    if (keyword_set(setaxis)) then begin
        if (keyword_set(noxtickname)) then begin
            axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
            charthick=charthick, xtickformat='(A1)'
        endif else begin
            axis, xaxis=0, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
            charthick=charthick, xtitle=xtitle
        endelse

        axis, xaxis=1, xstyle=1, xrange=xrange, xthick=xthick, charsize=charsize, $
        charthick=charthick, xtickformat='(A1)'
        
        if (keyword_set(noytickname)) then begin
            axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
            charthick=charthick, ytickformat='(A1)'
        endif else begin
            if (keyword_set(xy_ytitle)) then begin
                axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
                charthick=charthick

                xyouts, position[0]-0.1, 0.5*(position[3]+position[1]), ytitle, orientation=90, /normal, $
                alignment=0.5, charsize=charsize, charthick=charthick
            endif else begin
                axis, yaxis=0, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
                charthick=charthick, ytitle=ytitle
            endelse
        endelse

        axis, yaxis=1, ystyle=1, yrange=yrange, ythick=ythick, charsize=charsize, $
        charthick=charthick, ytickformat='(A1)'
    endif

end
