function read_2d, path, prefix, px, py
    xidx = strcompress(string(px),/remove)
    yidx = strcompress(string(py),/remove)

    px_like = read_like(path,prefix,px)
    py_like = read_like(path,prefix,py)

    nx = px_like.nx
    ny = py_like.nx

    dist2d = dblarr(nx,ny)
    like2d = dblarr(nx,ny)
    cont2d = dblarr(2)

    filename = path+prefix+'/plot_dist/'+prefix+'_2D_'+yidx+'_'+xidx
    openr, 5, filename
    readf, 5, dist2d
    close, 5

    filename = path+prefix+'/plot_dist/'+prefix+'_2D_'+yidx+'_'+xidx+'_likes'
    openr, 5, filename
    readf, 5, like2d
    close, 5

    filename = path+prefix+'/plot_dist/'+prefix+'_2D_'+yidx+'_'+xidx+'_cont'
    openr, 5, filename
    readf, 5, cont2d
    close, 5
    tmp = cont2d
    cont2d[0] = tmp[1]
    cont2d[1] = tmp[0]
    
    p2d = create_struct('nx',nx, 'ny',ny, 'x',px_like.x, 'y',py_like.x, $
                        'xlike',px_like.like, 'ylike',py_like.like, $
                        'dist2d',dist2d, 'like2d',like2d, 'cont',cont2d)

    return, p2d
end
