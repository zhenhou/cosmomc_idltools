function get_homedir
    
    res = file_info('~/HOME')
    if res.exists then begin
        home = ' '
        openr, 5, '~/HOME'
        readf, 5, home
        close, 5
    endif else begin
        home = '/home/hou/'
    endelse

    return, home
end
