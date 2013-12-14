pro getdist, params, path, root, add=add

    stat_dir = path+'/stat_data/'+root
    res = file_info(stat_dir)
    if (not res.exists) then spawn, ['mkdir','-p',stat_dir], /noshell

    plot_dir = path+'/plot_data/'+root
    res = file_info(plot_dir)
    if (not res.exists) then spawn, ['mkdir','-p',plot_dir], /noshell

    file_root = path+'/chains/'+root

    getdist = '/home/hou/Projects/CMBtools/cosmologist.info/cosmomc/getdist'
    
    rand = randomu(seed,/long)
    ini_file = '/tmp/getdist_'+strcompress(string(rand),/remove)+'.ini'
    get_lun, unit

    openw, unit, ini_file
    printf, unit, 'DEFAULT(/home/hou/Projects/CMBtools/cosmologist.info/cosmomc/batch1/getdist_common_batch1.ini)'
    printf, unit, ''
    printf, unit, 'file_root     = '+file_root
    printf, unit, 'out_root      = '+root
    printf, unit, 'out_dir       = '+stat_dir
    printf, unit, 'plot_data_dir = '+plot_dir
    printf, unit, ''
    printf, unit, 'ignore_rows   = 0.1'
    printf, unit, 'num_contours  = 2'
    printf, unit, 'contour1 = 0.68'
    printf, unit, 'contour2 = 0.95'
    printf, unit, ''
    printf, unit, 'plot_2D_num = 1'
    printf, unit, 'plot1 = omegabh2 omegach2'
    printf, unit, 'triangle_params = '+strjoin(params,' ')
    printf, unit, ''
    
    n_add = n_elements(add)
    for i=0, n_add-1 do begin
        printf, unit, add[i]
    endfor

    free_lun, unit

    spawn, [getdist, ini_file], /noshell
    spawn, ['rm','-rf',ini_file], /noshell

end
