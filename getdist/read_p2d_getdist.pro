function read_p2d_getdist, path, prefix, xparam, yparam

    is_xy = 1
    exist = 1
    file_2d = path+'/'+prefix+'_2D_'+yparam+'_'+xparam

    info = file_info(file_2d)
    if not info.exists then begin
        file_2d = path+'/'+prefix+'_2D_'+xparam+'_'+yparam

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
            p2d = create_struct('x',x_tmp,'y',y_tmp,'like2d',mat,'levels',[cont[1],cont[0]])
        endif else begin
            p2d = create_struct('x',y_tmp,'y',x_tmp,'like2d',transpose(mat),'levels',[cont[1],cont[0]])
        endelse

        return, p2d
    endif else begin
        print, file_2d
        print, "file not exist.  STOP"
        stop
    endelse

end
