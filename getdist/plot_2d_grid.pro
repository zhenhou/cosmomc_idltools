function get_tickv, xytv
    nt = n_elements(xytv)
    if nt le 3 then begin
        return, xytv
    endif else begin
        if nt le 4 then return, xytv[[0,2]]
        if nt le 6 then return, xytv[[0,2,4]]
        if nt le 8 then return, xytv[[0,3,6]]
        if nt le 10 then return, xytv[[0,4,8]]
    endelse
end

function get_tickname, xytv
    nt = n_elements(xytv)

    dv = xytv[1] - xytv[0]

    xytn = strarr(nt)
    for i=0, nt-1 do begin
        v = xytv[i]
        str = strcompress(string(v),/remove)
        for ic=0, strlen(str)-1 do begin
            smid = strmid(str,ic,1,/reverse) 
            if smid ne '0' then begin
                if smid eq '.' then begin
                    ic += 1
                endif
                break
            endif
        endfor
        xytn[i] = strmid(str,0,strlen(str)-ic)
    endfor

    pos = strpos(xytn,'.')
    if total(pos) ne -1*nt then begin
        len = max(strlen(xytn))
        for i=0, nt-1 do begin
            if strlen(xytn[i]) lt len then begin
                if pos[i] eq -1 then xytn[i] += '.0'
                if strlen(xytn[i]) lt len then begin
                    for n=0, len-strlen(xytn[i])-1 do xytn[i] += '0'
                endif
            endif
        endfor
    endif
    return, xytn
end

pro plot_2d_grid, path, prefix, params, ps_file, paramnames=paramnames, colorset=colorset, params_range=params_range, params_scale=params_scale

    extend_scale = 0.00

    if keyword_set(paramnames) then pnames=paramnames else pnames=params
    
    tvlct, 120, 120, 120, 1
    tvlct, 200, 200, 200, 2

    tvlct, 224,  51,  36, 11  ;; red
    tvlct, 248, 187, 167, 12

    tvlct,   0,   0, 140, 21
    tvlct,  64, 128, 200, 22

    tvlct,   0,  70,  36, 31
    tvlct,  60, 186, 117, 32

    tvlct,   0, 110, 236, 41  ;; blue
    tvlct, 139, 210, 244, 42

    tvlct, 120,   0, 176, 51  ;; purple
    tvlct, 207, 142, 237, 52

    tvlct, 255, 255, 255, 255
    
    if (keyword_set(colorset)) then color_set=colorset else color_set=1
    nparams = n_elements(params)

    if (keyword_set(params_scale)) then begin
        scales = params_scale[0:nparams-1]
    endif else begin
        scales = dindgen(nparams)
        scales[*] = 1.00d0
    endelse

    p1d_all = {}
    for i=0, nparams-1 do begin
        file_1d = path+'/'+prefix+'_p_'+params[i]+'.dat'
        info = file_info(file_1d)
        if info.exists then begin
            readcol, file_1d, x_tmp, y_tmp, format='(D,D)', count=nlines, /silent

            p1d = create_struct('nx',nlines, 'x',x_tmp*scales[i], 'like',y_tmp)

            tag = STRJOIN(STRSPLIT(params[i],'.', /EXTRACT), '')
            p1d_all = create_struct(tag, p1d, p1d_all)
        endif
    endfor
    
    p2d_all = {}
    for iy=0, nparams-1 do begin
        for ix=0, iy-1 do begin
            is_xy = 1
            exist = 1
            file_2d = path+'/'+prefix+'_2D_'+params[iy]+'_'+params[ix]

            info = file_info(file_2d)
            if not info.exists then begin
                file_2d = path+'/'+prefix+'_2D_'+params[ix]+'_'+params[iy]

                info = file_info(file_2d)
                if info.exists then begin
                    is_xy = 0
                endif else begin
                    exist = 0
                endelse
            endif
            
            if exist then begin
                file_x = file_2d+'_x'
                file_y = file_2d+'_y'

                readcol, file_x, x_tmp, format='(D)', count=nx, /silent
                readcol, file_y, y_tmp, format='(D)', count=ny, /silent

                mat = dblarr(nx, ny)
                openr, 5, file_2d
                readf, 5, mat
                close, 5
                
                cont = dblarr(2)
                openr, 5, file_2d+'_cont'
                readf, 5, cont
                close, 5

                if (is_xy) then begin
                    p2d = create_struct('x',x_tmp*scales[ix],'y',y_tmp*scales[iy],'like2d',mat,'levels',[cont[1],cont[0]])
                endif else begin
                    p2d = create_struct('x',y_tmp*scales[ix],'y',x_tmp*scales[iy],'like2d',transpose(mat),'levels',[cont[1],cont[0]])
                endelse
                
                tag = STRJOIN(STRSPLIT(params[iy]+'_'+params[ix],'.', /EXTRACT), '')
                p2d_all = create_struct(tag, p2d, p2d_all)
            endif
        endfor
    endfor

    dy = 0.93/nparams
    dx = dy*3.00/4.00

    x0 = 0.05
    y0 = 0.05

    set_plot,'ps'
	device, filename=ps_file, /color, bit=32
	xyouts, 0.0, 0.0, '!6 '

    !P.Multi = [0, nparams, nparams]

    tags_2d = TAG_NAMES(p2d_all)
    tags_1d = TAG_NAMES(p1d_all)

    prange = dblarr(2,nparams)

    for iy=0, nparams-1 do begin
        y_exist = 1
        tag = STRJOIN(STRSPLIT(params[iy],'.', /EXTRACT), '')
        ytag_1d = where(strcmp(tags_1d, strupcase(tag)) eq 1)
        if ytag_1d eq -1 then y_exist = 0

        if y_exist then begin
            y_axis  = p1d_all.(ytag_1d).x
            if keyword_set(params_range) then begin
                if (params_range[0,iy] ne params_range[1,iy]) then begin
                    yrange = params_range[0:1,iy]
                endif else begin
                    ymin = min(y_axis, max=ymax)
                    delta_y = (ymax-ymin)*extend_scale
                    yrange = [min(y_axis)-delta_y,max(y_axis)+delta_y]
                    prange[*,iy] = yrange
                endelse
            endif else begin
                ymin = min(y_axis, max=ymax)
                delta_y = (ymax-ymin)*extend_scale
                yrange = [min(y_axis)-delta_y,max(y_axis)+delta_y]
                prange[*,iy] = yrange
            endelse
        endif
         
        for ix=0, iy do begin
            x_exist = 1
            tag = STRJOIN(STRSPLIT(params[ix],'.', /EXTRACT), '')
            xtag_1d = where(strcmp(tags_1d, strupcase(tag)) eq 1)
            if xtag_1d eq -1 then x_exist = 0

            if x_exist then begin
                x_axis  = p1d_all.(xtag_1d).x
                if keyword_set(params_range) then begin
                    if (params_range[0,ix] ne params_range[1,ix]) then begin
                        xrange = params_range[0:1,ix]
                    endif else begin
                        xmin = min(x_axis, max=xmax)
                        delta_x = (xmax-xmin)*extend_scale
                        xrange = [min(x_axis)-delta_x,max(x_axis)+delta_x]
                        prange[*,ix] = xrange
                    endelse
                endif else begin
                    xmin = min(x_axis, max=xmax)
                    delta_x = (xmax-xmin)*extend_scale
                    xrange = [min(x_axis)-delta_x,max(x_axis)+delta_x]
                endelse
            endif

            x1 = x0 + ix*dx
            x2 = x0 + (ix+1)*dx
            y1 = y0 + (nparams-iy-1)*dy
            y2 = y0 + (nparams-iy)*dy
            pos = [x1, y1, x2, y2] 
            
            if (ix ne iy) then begin
                if y_exist and x_exist then begin
                    tag = STRJOIN(STRSPLIT(params[iy]+'_'+params[ix],'.', /EXTRACT), '')
                    itag_2d = where(strcmp(tags_2d, strupcase(tag)) eq 1)
                    x_axis_2d = p2d_all.(itag_2d).x
                    y_axis_2d = p2d_all.(itag_2d).y

                    like2d = p2d_all.(itag_2d).like2d
                    levels = p2d_all.(itag_2d).levels
                endif

                plot, xrange, yrange, xstyle=1, ystyle=1, xrange=xrange, yrange=yrange, position=pos, /noerase, $
                xtickformat='(A3)', ytickformat='(A3)', /nodata, xtick_get=xtv, ytick_get=ytv, color=255

                if y_exist and x_exist then begin
                    contour, like2d, x_axis_2d, y_axis_2d, levels=levels, c_color=color_set*10+[2,1], /fill, /over
                    contour, like2d, x_axis_2d, y_axis_2d, levels=levels, c_color=color_set*10+[1,1], /over, $
                    c_thick=[2,2]

                    axis, xaxis=0, xstyle=1, xrange=xrange, xtickformat='(A3)', xticks=1
                    axis, xaxis=1, xstyle=1, xrange=xrange, xtickformat='(A3)', xticks=1
                    axis, yaxis=0, ystyle=1, yrange=yrange, ytickformat='(A3)', yticks=1
                    axis, yaxis=1, ystyle=1, yrange=yrange, ytickformat='(A3)', yticks=1
                endif
            endif else begin
                if x_exist then begin
                    yrange_diag = [0,1.05]
                    like1d = p1d_all.(xtag_1d).like
                endif

                plot, xrange, yrange_diag, xstyle=1, ystyle=1, xrange=xrange, yrange=yrange_diag, position=pos, /noerase, $
                xtickformat='(A3)', ytickformat='(A3)', /nodata, xtick_get=xtv, ytick_get=ytv, color=255, yticks=2, ytickv=[0.0,1.0]
                
                if x_exist then begin
                    oplot, x_axis, like1d, color=color_set*10+1, thick=2.0

                    axis, xaxis=0, xstyle=1, xrange=xrange, xtickformat='(A3)', xticks=1
                    axis, xaxis=1, xstyle=1, xrange=xrange, xtickformat='(A3)', xticks=1
                    axis, yaxis=0, ystyle=1, yrange=yrange, ytickformat='(A3)', yticks=2, ytickv=[0.0,1.0]
                    axis, yaxis=1, ystyle=1, yrange=yrange, ytickformat='(A3)', yticks=2, ytickv=[0.0,1.0]
                endif
            endelse

            if y_exist then begin
                ytickv = get_tickv(ytv)
                yticks = n_elements(ytickv)+1
                
                axis, yaxis=0, ystyle=1, yrange=yrange, ycharsize=0.8, yticks=yticks, ytickv=ytickv, ytickformat='(A1)'
                axis, yaxis=1, ystyle=1, yrange=yrange, ycharsize=0.8, yticks=yticks, ytickv=ytickv, ytickformat='(A1)'

                if (ix eq 0) then begin 
                    ytickn = get_tickname(ytickv)
                    axis, yaxis=0, ystyle=1, yrange=yrange, ycharsize=0.8, yticks=yticks, ytickv=ytickv, ytickname=ytickn
                endif 
            endif

            if x_exist then begin
                xtickv = get_tickv(xtv)
                xticks = n_elements(xtickv)+1

                axis, xaxis=0, xstyle=1, xrange=xrange, xcharsize=0.8, xticks=xticks, xtickv=xtickv, xtickformat='(A1)'
                axis, xaxis=1, xstyle=1, xrange=xrange, xcharsize=0.8, xticks=xticks, xtickv=xtickv, xtickformat='(A1)'

                if (iy eq nparams-1) then begin
                    xtickn = get_tickname(xtickv)
                    axis, xaxis=0, xstyle=1, xrange=xrange, xcharsize=0.8, xticks=xticks, xtickv=xtickv, xtickname=xtickn
                endif
            endif

            if (ix eq 0) then begin
                xyouts, x1-0.03, 0.5*(y1+y2), pnames[iy], charsize=6.0/nparams, alignment=0.5, orientation=90, /normal
            endif

            if (iy eq nparams-1) then begin
                xyouts, 0.5*(x1+x2), y1-0.04, pnames[ix], charsize=6.0/nparams, alignment=0.5, /normal
            endif

            plot, [0,1], [0,1], xstyle=1, ystyle=1, xrange=[0,1], yrange=[0,1], position=pos, /noerase, $
            xtickformat='(A3)', ytickformat='(A3)', /nodata, xticks=1, yticks=1
        endfor
    endfor

    if (not keyword_set(params_range)) then params_range = prange

    device,/close
	set_plot,'X'
    
end
