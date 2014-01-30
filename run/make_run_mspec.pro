function read_par_run_mspec, par_file, add=add
    
    readcol, par_file, keys, tmp, var, format='(A,A,A)', comment='#', stringskip='[', /silent
    
    run = create_struct('mspec_lmin_TT', 0, $
                        'mspec_lmax_TT', 0, $
                        'mspec_lmin_EE', 0, $
                        'mspec_lmax_EE', 0, $
                        'mspec_lmin_BB', 0, $
                        'mspec_lmax_BB', 0, $
                        'mspec_lmin_TE', 0, $
                        'mspec_lmax_TE', 0, $
                        'mspec_py_file', 'mspec.py', $
                        'mspec_py_example', '/global/scratch2/sd/hou/us_pipe/cosmomc_data_files/data/mspec_example/chain_singlefreq.py', $
                        'use_mspec',   0, $
                        'use_clik_lowl', 0, $
                        'use_clik_lowlike', 0, $
                        'use_tauprior', 0, $
                        'run_cosmomc_home', '~/cosmomc/', $
                        'run_chain_output', 'chains/chain', $
                        'run_num_nodes', 4, $
                        'run_num_ppn', 1, $
                        'run_hours', 12, $
                        'run_ini', 'test.ini', $
                        'run_sh', 'test.sh', $
                        'run_name', 'test')

    tags = tag_names(run)
    ntags = n_elements(tags)

    for itag=0, ntags-1 do begin
        is_num = 0

        ikey = where(strcmp(strupcase(keys), tags[itag]) eq 1)
        if (ikey eq -1) then begin
            print, "WARNING: the key ", tags[itag], " does NOT found in the par file, using the default value ", strcompress(string(run.(itag)),/remove)
        endif

        byt_tmp = byte(strmid(var[ikey],0, 1))
        if (byt_tmp ge byte('0') and byt_tmp le byte('9')) then begin
            is_num = 1
        endif else begin
            if (strcompress(var[ikey],/remove) eq 'T') then begin
                is_num = 1
                var[ikey] = '1'
            endif

            if (strcompress(var[ikey],/remove) eq 'F') then begin
                is_num = 1
                var[ikey] = '0'
            endif
        endelse
        
        if is_num then run.(itag) = long(var[ikey]) else run.(itag) = strcompress(var[ikey],/remove)
    endfor
    
    if (keyword_set(add)) then begin
        add = ['#additional settings']

        a = ' '
        is_add = 0
        get_lun, unit
        openr, unit, par_file
        while ~eof(unit) do begin
            readf, unit, a
            if (strmid(a,0,4) eq '#add') then begin
                is_add = 1
                break
            endif
        endwhile
        
        if (is_add) then begin
            while ~eof(unit) do begin
                readf, unit, a
                add = [add, a]
            endwhile
        endif


        free_lun, unit
    endif
    
    return, run    
end


pro gen_mspec_ini, run, add=add 

    get_lun, unit
    openw, unit, run.run_ini
    if run.use_clik_lowl then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/batch1/lowl.ini)'
    if run.use_clik_lowlike then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/batch1/lowlike.ini)'
    if run.use_tauprior then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/batch1/tauprior.ini)'
    printf, unit, ' '
    printf, unit, '#general settings'
    printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/batch1/common_batch1_nersc.ini)'
    printf, unit, ' '
    printf, unit, 'cmb_numdatasets = 1'
    printf, unit, 'cmb_dataset1 = '+run.mspec_py_file
    printf, unit, 'file_root = '+run.run_chain_output
    printf, unit, ' '
    printf, unit, '#high for new runs'
    printf, unit, 'MPI_Max_R_ProposeUpdate = 30'
    printf, unit, ' '
    printf, unit, 'start_at_bestfit = F'
    printf, unit, 'use_clik = F'
    printf, unit, 'get_sigma8 = T'

    if (keyword_set(add)) then begin
        nadd = n_elements(add)
        for i=0, nadd-1 do begin
            printf, unit, add[i]
        endfor
    endif

    free_lun, unit

end


pro gen_mspec_py, run
    get_lun, unit
    openw, unit, run.mspec_py_file

end


pro gen_sh_run, run, bundle=bundle
    
    get_lun, unit

    res = file_info(run.run_sh)
    if (res.exists and keyword_set(bundle)) then begin
        a = ' '
        openu, unit, run.run_sh
        while ~eof(unit) do begin
            readf, unit, a
        endwhile
    endif else begin
        openw, unit, run.run_sh
        printf, unit, '#!/bin/sh'
        printf, unit, '#PBS -q usplanck'
        printf, unit, '#PBS -l nodes='+strcompress(string(run.run_num_nodes),/remove)+ $
                      ':ppn='+strcompress(string(run.run_num_ppn),/remove)
        printf, unit, '#PBS -l pvmem=20GB'
        printf, unit, '#PBS -l walltime='+strcompress(string(run.run_hours),/remove)+':00:00'
        printf, unit, '#PBS -N '+run.run_name
        printf, unit, '#PBS -e $PBS_JOBID.err'
        printf, unit, '#PBS -o $PBS_JOBID.out'
        printf, unit, '#PBS -m bea'
        printf, unit, ' '
        printf, unit, 'module load intel'
        printf, unit, 'module load openmpi-intel'
        printf, unit, ' '
        printf, unit, 'cd $PBS_O_WORKDIR'
        printf, unit, 'export OMP_NUM_THREADS=8'
        printf, unit, ' '
    endelse
    printf, unit, 'mpirun -np '+strcompress(string(run.run_num_nodes),/remove)+' -bynode '+run.run_cosmomc_home+'/cosmomc '+run.run_ini
    printf, unit, ' '
    free_lun, unit
end


pro make_run_mspec, par_file, add=add, sh_bundle=sh_bundle

    ;run = read_par_run(par_file, add=add)
    run = read_par_run(par_file)

    run.mspec_lmin_TT = min([run.mspec_lmin_TT, run.mspec_lmax_TT])
    run.mspec_lmin_EE = min([run.mspec_lmin_EE, run.mspec_lmax_EE])
    run.mspec_lmin_BB = min([run.mspec_lmin_BB, run.mspec_lmax_BB])
    run.mspec_lmin_TE = min([run.mspec_lmin_TE, run.mspec_lmax_TE])
    
    lrange_TT = [run.mspec_lmin_TT, run.mspec_lmax_TT]
    lrange_EE = [run.mspec_lmin_EE, run.mspec_lmax_EE]
    lrange_BB = [run.mspec_lmin_BB, run.mspec_lmax_BB]
    lrange_TE = [run.mspec_lmin_TE, run.mspec_lmax_TE]

    if (run.use_mspec) then begin
        print, "use mspec"
        run_class = 'mspec'
    endif else begin
        print, "unknown high-ell likelihood.  stop"
        stop
    endelse
    
    if (run_class eq 'xfaster') then begin
        info = file_info(run.xft_newdat_original)
        if (not info.exists) then begin
            
            p = strpos(run.xft_newdat_original, '/', /reverse_search)

            if (keyword_set(ndf_original_path)) then begin
                tmp_path = ndf_original_path
            endif else begin
                tmp_path = '/global/homes/h/hou/Projects/projects/planck_like/xfaster_cosmomc/scripts/data/xfaster_tp/davide_outputs/'
            endelse

            tmp_newdat = strmid(run.xft_newdat_original, p+1, strlen(run.xft_newdat_original))
            tmp_newdat = tmp_path + tmp_newdat
            
            tmp_info = file_info(tmp_newdat)

            if tmp_info.exists then begin
                spawn, ['cp',tmp_newdat,run.xft_newdat_original], /noshell
            endif else begin
                if (keyword_set(ndf_original_path)) then begin
                    tmp_path = ndf_original_path
                endif else begin
                    tmp_path = '/global/homes/h/hou/Projects/projects/planck_like/xfaster_cosmomc/scripts/data/xfaster_tp/davide_outputs/'
                endelse

                tmp_newdat = strmid(run.xft_newdat_original, p+1, strlen(run.xft_newdat_original))
                tmp_newdat = tmp_path + tmp_newdat

                ;print,'scp hou@carver.nersc.gov:'+tmp_newdat+' '+run.xft_newdat_original
                ;stop

                spawn, 'scp hou@carver.nersc.gov:'+tmp_newdat+' '+run.xft_newdat_original
            endelse
        endif
        
        fix_newdat, run.xft_newdat_original, run.xft_newdat_run, lrange_TT, lrange_EE, lrange_BB, lrange_TE
        gen_xft_ini_run, run, add=add

        ;spawn, 'rm -rf /tmp/xfaster_newdat_original_tmp*'
    endif else if (run_class eq 'mspec') then begin
        print, "mspec not ready yet"
        stop
    endif

    gen_sh_run, run, bundle=sh_bundle

end
