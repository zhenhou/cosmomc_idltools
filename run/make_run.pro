function read_par_run, par_file
    
    readcol, par_file, keys, tmp, var, format='(A,A,A)', comment='#', stringskip='[', /silent
    
    run = create_struct('xft_lmin_TT', 0, $
                        'xft_lmax_TT', 0, $
                        'xft_lmin_EE', 0, $
                        'xft_lmax_EE', 0, $
                        'xft_lmin_BB', 0, $
                        'xft_lmax_BB', 0, $
                        'xft_lmin_TE', 0, $
                        'xft_lmax_TE', 0, $
                        'xft_EE_template', 0, $
                        'xft_newdat_original', 'test_original.newdat', $
                        'xft_newdat_run', 'test.newdat', $
                        'use_xfaster', 0, $
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
    
    return, run    
end


pro gen_xft_ini_run, run 

    get_lun, unit
    openw, unit, run.run_ini
    printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/gen_scripts/batch1_run/xfaster_newdat_batch1.ini)'
    if run.use_clik_lowl then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/gen_scripts/batch1_run/lowl.ini)'
    if run.use_clik_lowlike then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/gen_scripts/batch1_run/lowlike.ini)'
    if run.use_tauprior then printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/gen_scripts/batch1_run/tauprior.ini)'
    printf, unit, ' '
    printf, unit, '#general settings'
    printf, unit, 'DEFAULT('+run.run_cosmomc_home+'/gen_scripts/batch1_run/common_batch1.ini)'
    printf, unit, ' '
    printf, unit, 'cmb_dataset1 = '+run.xft_newdat_run
    printf, unit, 'file_root = '+run.run_chain_output
    printf, unit, ' '
    printf, unit, '#high for new runs'
    printf, unit, 'MPI_Max_R_ProposeUpdate = 30'
    printf, unit, ' '
    ;printf, unit, 'propose_matrix = '+run.run_cosmomc_home+'/planck_covmats/base_planck_lowl_lowLike.covmat'
    printf, unit, 'propose_matrix = planck_covmats/base_planck_lowl_lowLike.covmat'
    printf, unit, ' '
    printf, unit, 'start_at_bestfit = F'
    printf, unit, 'feedback = 2'
    printf, unit, 'use_fast_slow = F'
    printf, unit, 'sampling_method = 1'
    printf, unit, 'indep_sample = 0'
    printf, unit, ' '

    if ((not run.xft_EE_template) or (run.xft_lmax_EE eq 0)) then begin
        printf, unit, '# turn off the l(l+1) template fitting for EE'
        printf, unit, 'has_ell2_EE1 = F'
        printf, unit, 'param[aee] =  0 0 0 0 0'
        printf, unit, ' '
    endif

    if (run.xft_lmax_TT eq 0) then begin
        printf, unit, '# turn off the egfg for TT'
        printf, unit, 'param[asz] = 0 0 0 0 0'
        printf, unit, 'param[aps] = 0 0 0 0 0'
        printf, unit, 'param[acl] = 0 0 0 0 0'
        printf, unit, ' '
    endif

    free_lun, unit

end


pro gen_sh_run, run
    
    get_lun, unit
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
    printf, unit, 'cd $PBS_O_WORKDIR'
    printf, unit, 'export OMP_NUM_THREADS=8'
    printf, unit, ' '
    printf, unit, 'mpirun -np '+strcompress(string(run.run_num_nodes),/remove)+' -bynode '+run.run_cosmomc_home+'/cosmomc '+run.run_ini
    printf, unit, ' '

    free_lun, unit
end


pro make_run, par_file

    run = read_par_run(par_file)

    run.xft_lmin_TT = min([run.xft_lmin_TT, run.xft_lmax_TT])
    run.xft_lmin_EE = min([run.xft_lmin_EE, run.xft_lmax_EE])
    run.xft_lmin_BB = min([run.xft_lmin_BB, run.xft_lmax_BB])
    run.xft_lmin_TE = min([run.xft_lmin_TE, run.xft_lmax_TE])
    
    lrange_TT = [run.xft_lmin_TT, run.xft_lmax_TT]
    lrange_EE = [run.xft_lmin_EE, run.xft_lmax_EE]
    lrange_BB = [run.xft_lmin_BB, run.xft_lmax_BB]
    lrange_TE = [run.xft_lmin_TE, run.xft_lmax_TE]

    if (run.use_xfaster) then begin
        print, "use xfaster"
        if (run.use_mspec) then begin
            print, "Either xfaster or mspec is for high-ell analysis, not both simultaneously.  stop"
            stop
        endif
        run_class = 'xfaster'
    endif else if (run.use_mspec) then begin
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
            
            tmp_path = '/global/homes/h/hou/Projects/projects/planck_like/xfaster_cosmomc/scripts/data/xfaster_tp/davide_outputs/'
            tmp_newdat = strmid(run.xft_newdat_original, p+1, strlen(run.xft_newdat_original))
            tmp_newdat = tmp_path + tmp_newdat
            
            tmp_info = file_info(tmp_newdat)

            if tmp_info.exists then begin
                spawn, ['cp',tmp_newdat,run.xft_newdat_original], /noshell
            endif else begin
                tmp_path = '/global/homes/h/hou/Projects/projects/planck_like/xfaster_cosmomc/scripts/data/xfaster_tp/davide_outputs/'
                tmp_newdat = strmid(run.xft_newdat_original, p+1, strlen(run.xft_newdat_original))
                tmp_newdat = tmp_path + tmp_newdat

                ;print,'scp hou@carver.nersc.gov:'+tmp_newdat+' '+run.xft_newdat_original
                ;stop

                spawn, 'scp hou@carver.nersc.gov:'+tmp_newdat+' '+run.xft_newdat_original
            endelse
        endif
        
        fix_newdat, run.xft_newdat_original, run.xft_newdat_run, lrange_TT, lrange_EE, lrange_BB, lrange_TE
        gen_xft_ini_run, run

        ;spawn, 'rm -rf /tmp/xfaster_newdat_original_tmp*'
    endif else if (run_class eq 'mspec') then begin
        print, "mspec not ready yet"
        stop
    endif

    gen_sh_run, run

end
