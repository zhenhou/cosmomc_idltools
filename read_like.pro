function read_like, path, prefix, p
    pidx = strcompress(string(p),/remove)
    filename = path+prefix+'/plot_dist/'+prefix+'_p'+pidx+'.likes'
    readcol, filename, x, y, format='(D,D)', count=nx, /silent

    plike = create_struct('nx',nx, 'x',x, 'like',y)

    return, plike
end


