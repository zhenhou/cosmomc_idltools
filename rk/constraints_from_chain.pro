pro constraints_from_chain, file, ind, nskip=nskip, $
                            meanval=meanval, sigma=sigma, $
                            ninefive=ninefive, repivot=repivot, $
                            alens_power=alens_power, dir=dir, $
                            min_chisq=min_chisq, $
                            rozo_prior=rozo_prior, vihk_prior=vihk_prior, $
                            poisson_prior=poisson_prior, $
                            sz_prior=sz_prior, $
                            dusty_prior=dusty_prior,relax=relax, $
                            h0_prior=h0_prior, $
                            start_frac=start_frac, $
                            stop_frac=stop_frac, do_scramble=do_scramble


if n_elements(dir) eq 0 then dir=''
restore,dir+file
transform_params, echain, repivot=repivot, alens_power=alens_power
numparam = n_elements(ind)
meanval = dblarr(numparam)
sigma = dblarr(numparam)
ninefive = dblarr(numparam)

npts = n_elements(echain[0,*])

; if desired, scramble the chain
if keyword_set(do_scramble) then begin
   random_ind = scramble(findgen(npts))
   for i=0,n_elements(echain[*,0])-1 do $
      echain[i,*] = echain[i,random_ind]
endif


if n_elements(start_frac) eq 0 then start_frac = 0.0
if n_elements(stop_frac) eq 0 then stop_frac = 1.0
istart = round(start_frac*npts)
istop = round(stop_frac*npts)
echain = echain[*,istart:istop-1]

weight = get_weight(echain, $
                    rozo_prior=rozo_prior, vihk_prior=vihk_prior, $
                    poisson_prior=poisson_prior, $
                    sz_prior=sz_prior, $
                    dusty_prior=dusty_prior,relax=relax,h0_prior=h0_prior,alens_power=alens_power)

chisq_from_weight = alog(weight)/(-0.5)
min_chisq = min(2.*(echain[1,*]) + chisq_from_weight)
for i=0,numparam-1 do begin
   print,ind[i]
    pp = echain[ind[i],*]
    npp = n_elements(pp)


    
; get mean
;    meanval[i] = mean(pp)
    meanval[i] = total(pp*weight,/double)/total(weight,/double)
    
; take tiny steps away from the mean until you have encompassed 68% of
; the samples.    
    frac_sigma = 0.01
    sigma_tmp = stddev(pp)
    if ~finite(sigma_tmp) or sigma_tmp le 0 then goto,no_limit
    keep_going = 1
    s = 0.
    while keep_going do begin
;        wh = where(abs(pp-mean(pp)) le s, nwh)
        wh = where(abs(pp-meanval[i]) le s, nwh)
        if nwh gt 0 then frac_w = total(weight[wh])/total(weight) $
        else frac_w=0.
;        if 1.*nwh/npp ge 0.68 then begin
        if frac_w ge 0.68 then begin
            sigma[i] = s
            keep_going=0
        endif else s += (frac_sigma*sigma_tmp)
    endwhile
    print,'done w 68%'

; take tiny steps away from the max value until you have encompassed 95% of
; the samples.    
    keep_going = 1
    s = 0.
    while keep_going do begin
        wh = where(pp le (max(pp)-s), nwh)
        if nwh gt 0 then frac_w = total(weight[wh])/total(weight) $
        else frac_w=0.
        if frac_w le 0.95 then begin
;        if 1.*nwh/npp le 0.95 then begin
            ninefive[i] = (max(pp)-s)
            keep_going=0
        endif else s += (frac_sigma*sigma_tmp)
    endwhile
    print,'done w 95%'
no_limit:

print,meanval[i],' +/- ',sigma[i]
endfor



;stop
end


    
