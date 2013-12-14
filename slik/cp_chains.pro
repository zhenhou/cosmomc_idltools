pro cp_chains, path, prefix, outpath
    
    pos = strpos(prefix, 'pico')

    if pos ne -1 then begin
        spawn,['scp','hou@carver.nersc.gov:'+path+'/'+prefix+'.paramnames','/tmp/'],/noshell
        spawn,['scp','hou@carver.nersc.gov:'+path+'/'+prefix+'_*.txt','/tmp/'],/noshell

        readcol, '/tmp/'+prefix+'.paramnames', pnames, format='A'
        logA_id = name2id('logA',paramnames=pnames)
        A_id    = name2id('A*',paramnames=pnames)
        ns_id   = name2id('ns',paramnames=pnames)

        nparams = n_elements(pnames)

        line = dblarr(nparams+2)
        
        for ichain=1, 16 do begin
            cidx = strcompress(string(ichain),/remove)
            in_file = '/tmp/'+prefix+'_'+cidx+'.txt'
            out_file = outpath+'/'+prefix+'_'+cidx+'.txt'
            info = file_info(in_file)
            if info.exists then begin
                get_lun, unit_in
                get_lun, unit_out
                
                openr, unit_in, in_file
                openw, unit_out, out_file
                while ~eof(unit_in) do begin
                    readf, unit_in, line
                    plist = line[1:*]
                    logA = plist[logA_id]
                    ns   = plist[ns_id]
                    
                    add = (1.00d0-ns)*alog(0.002/0.05)
                    logA += add

                    plist[logA_id] = logA
                    plist[A_id] = exp(logA)/10.0d0
                    line[1:*] = plist

                    printf, unit_out, format='(100E16.7)', line
                endwhile
                free_lun, unit_in
                free_lun, unit_out

                spawn, ['rm','-rf',in_file],/noshell
            endif
        endfor

        spawn, ['mv','/tmp/'+prefix+'.paramnames',outpath],/noshell
    endif else begin
        spawn,['scp','hou@carver.nersc.gov:'+path+'/'+prefix+'.paramnames',outpath],/noshell
        spawn,['scp','hou@carver.nersc.gov:'+path+'/'+prefix+'_*.txt',outpath],/noshell
    endelse
end
