pro cons_chain, name, nskip=nskip, chain=chain, echain=echain, doall=doall, $
                stopit=stopit, ntot=ntot, didwrite=didwrite, $
                rubin_gelman=rubin_gelman, $
                nrows_vec=nrows_vec,maxrm1_vec=maxrm1_vec, $
                min_n_txtrow=min_n_txtrow, do_rubin=do_rubin, $
                out_nskip=out_nskip, half=half

; NB: NSKIP is in units of the number of rows in a chain text file,
; i.e. *not* the number of expanded points.  
; 

half=0

if n_elements(rubin_gelman) eq 0 then rubin_gelman=0.01

didwrite=0
filename='cons_chain_'+name+'.sav'


if n_elements(min_n_txtrow) eq 0 then min_n_txtrow=1000


if keyword_set(doall) then begin  
   spawn,'rm '+filename,sout
   spawn,'ls uberchains/chain_k10_'+name+'_[0-9].txt uberchains/chain_k10_'+name+'_[1-3][0-9].txt',list
   nlist = n_elements(list)
  
; let's only use txt files which have at least some minimum
; number of rows
   n_txtrows = fltarr(nlist)
   for i=0,nlist-1 do begin
      spawn,'wc -l '+list[i],output
      n_txtrows[i] = output
   endfor
   whok = where(n_txtrows ge min_n_txtrow,nok)
   if nok eq 0 then return

   list = list[whok]
   nlist = nok


   print,'=== ',name,' ==='
;   print,list
   print,' '

   if keyword_set(do_rubin) then begin
      print,'...measuring burn-in period using Rubin-Gelman statistic...'
      
      if strmatch(name,'*wmaponly*') then begin
         nskip=2e3
         goto, done_rubin
      endif

; load all chains
      
      n_txtrows = fltarr(nlist)
      n_pts = fltarr(nlist)
      for i=0,nlist-1 do begin
         print,list[i]
         si = strtrim(floor(i),2)
         a=read_ascii(list[i])
         ex=execute('y'+si+' = (a.field01)[*,*]') 
         n_txtrows[i] = n_elements(a.field01[0,*])
         n_pts[i] = total(a.field01[0,*])
      endfor
      
; in incremenets of DELTA_ROWS "chain rows", find the first chain size for
; which our chains satisify the R-G statistic.
      keep_going = 1
      delta_rows = 20
      nrows = 0.
      nparams = n_elements((a.field01)[*,0])
      nparamso = nparams
      
      nrows_vec = -1.
      maxrm1_vec = -1.
      if nlist eq 1 then return
      
      while keep_going do begin
         nrows += delta_rows
         
         if 2.*nrows ge min(n_txtrows) then begin
            keep_going=0
            print,'MAXED OUT AND HAD TO USE HALF THE TOTAL ROWS'
            magic_nrows = round(0.5*min(n_txtrows))
            half=1
            continue
         endif
         
         nparams = nparamso
         tmp = fltarr(nlist,nparams,2.*nrows)
         for i=0,nlist-1 do ex=execute('tmp[i,*,*] = y'+strtrim(floor(i),2)+'[*,0:2.*nrows-1]')
         
; if this is wmaponly, let's not use the spt-centric parameters
; to calculate convergence stats.
         if strmatch(name,'*wmaponly*') then begin
            tmp1 = tmp[*,0:16,*]
            tmp2 = tmp[*,37:*,*]
            tmp = [[tmp1],[tmp2]]
            nparams = n_elements(tmp[0,*,0])
         endif
         
         
; only take second half of points
         tmp = tmp[*,*,nrows:2.*nrows-1]
         wt_chain_row = reform(tmp[*,0,*])
         
; loop over params and calculate R-G stat for each, being sure to take
; into account the weight of each row.     
; check out
; http://www.people.fas.harvard.edu/~plam/teaching/methods/convergence/convergence_print.pdf
         rm1 = fltarr(nparams-2)
         for i=2,nparams-1 do begin
            n = nrows
            m = nlist
            tmp_chain_row = reform(tmp[*,i,*])
            
            frac_rms = stddev(tmp_chain_row,/double)/median(tmp_chain_row)
            if frac_rms eq 0 or ~finite(frac_rms) then continue
            chain_means = total(tmp_chain_row*wt_chain_row,2,/double)*1./total(wt_chain_row,2,/double)
            chain_var = fltarr(nlist)
            for j=0,nlist-1 do chain_var[j]=total((tmp_chain_row[j,*]-chain_means[j])^2.*wt_chain_row[j,*],/double)*1./total(wt_chain_row[j,*],/double)
            w = 1./m*total(chain_var,/double) ; mean chain variance
            
            mean_mean = mean(chain_means)
            b = 1.*n/(m-1.)*total((chain_means-mean_mean)^2.,/double) ; n*(variance of chain means)
            
            est_var = (1.-1./n)*w + 1./n*b
            r = sqrt(est_var/w)
            rm1[i-2] = r-1.
         endfor
         
         print,'nrows: ',nrows,'  , max(R-1): ',max(rm1),' (offending param=',strtrim(floor(2.+where(rm1 eq max(rm1))),2)+')'
         
         nrows_vec = [nrows_vec,nrows]
         maxrm1_vec = [maxrm1_vec, max(rm1)]
         
         if max(rm1) lt rubin_gelman then begin
            keep_going=0
            magic_nrows = nrows
         endif
      endwhile
      nskip = magic_nrows
      
; let's require a minimum nskip
      nskip = max([nskip,1e3])

      done_rubin:

      print,' ' 
      print,name,', nskip=',nskip


      nrows_vec = nrows_vec[1:*]
      maxrm1_vec = maxrm1_vec[1:*]


;      plot,nrows_vec,maxrm1_vec,ps=2,/yl,yr=[.001,2],title=name
;      oplot,[-1,1]*9e9,[1,1]*rubin_gelman,color=!red,lines=2,thick=2
;      oplot,[1,1]*500,[1e-9,1e9],color=!blue,lines=2,thick=2
;      return                   

   endif else begin
; if we're not doing rubin-gelman test, just get NSKIP here.      
      if n_elements(nskip) eq 0 then nskip = 1000
   endelse

   out_nskip = nskip
   
   print,'...consolidating...'
   
   count = 0
   for i=0,nlist-1 do begin
      print,list[i]
      a=read_ascii(list[i])
      y = (a.field01)
;     if n_elements(y[0,*]) gt (2.*nskip) then y=y[*,nskip:*] else
;     continue
      
      
      npts_cum = total(y[0,*],/cum,/double)
      wh_use = where(npts_cum ge nskip,n_use)
      
;plot,npts_cum,yr=[0,2e4],/yst,xr=[0,1e4],/xst & pause
      if n_use lt nskip then continue
      
      y = y[*,wh_use]
      
      count++
      if n_elements(chain) eq 0 then begin
         nparams = n_elements(y[*,0])
         chain = fltarr(nparams,1)
      endif
      chain = [[chain],[y]]
   endfor
   
   if count eq 0 then begin
      print,'NO VALID CHAINS.'
      return
   endif
   chain = chain[*,1:*]
   
   
   print,'...expanding...'
   w = reform(chain[0,*])
   nlines = n_elements(chain[0,*])
   nparams2 = nparams
   ntot = total(w)
   print,'      ',name,' has ',strtrim(floor(ntot),2),' samples.'
   echain = fltarr(nparams2,ntot)
   istart = 0
   for i=0L,nlines-1 do begin
;     if (i mod 1000) eq 0 then print,i,nlines-1
      this_point = chain[0:*,i]
      this_w = w[i]
      add_on = this_point # (fltarr(this_w)+1.)
      istop=istart+this_w-1
      echain[*,istart:istop] = add_on
      istart = istop+1
;     echain = [[echain],[add_on]]
;     for j=0,w[i]-1 do echain = [[echain],[this_point]]
   endfor

; between the 1.24 and 1.37 runs we introduced code into cosmomc to
; try and use the spt sz cluster likelihood.  this added 12 parameters
; which we basically never use, and, in an effort to keep all the
; plotting code, i'm going to remove those 12 parameters from
; the output chains.
   tmp1 = chain[0:36,*]
   tmp2 = chain[49:*,*]
   chain = [tmp1,tmp2]

   tmp1 = echain[0:36,*]
   tmp2 = echain[49:*,*]
   echain = [tmp1,tmp2]


   save,nskip,chain,echain,filename=filename
   didwrite=1
endif else begin
   if file_test(filename) then restore,filename else return
endelse


; let's study the accuracy of the parameter limits.  i.e. if we
; chop the data up into N subsets, how much do the upper and lower 95%
; confidence limits change among the subsets?  we'd like this
; change to be a small fraction of a sigma.  E.g. for N=4
; subsets, we'd like the standard deviation of the limit to be
; <0.2-sigma, such that the true uncertainty (obtained when all 4
; subsets are used together) will be sqrt(4) better, or <0.1-sigma.

nsub = 4.

; figure out which params to study
ind = -1
nind = 0
for i=2,n_elements(echain[*,0])-1 do begin
   y = echain[i,*]
   rms = stddev(y,/double)
   if finite(rms) and rms gt 0 then begin
      ind = [ind,i]
      nind++
   endif
endfor
if nind eq 0 then begin
   print,'uh oh'
   stop
endif
ind = ind[1:*]

npts_total = n_elements(echain[2,*])
npts = floor(npts_total*1./nsub)

plim = 0.025 ; 95%
indlim = round(npts*plim)
ul = fltarr(nsub,nind)
ll = fltarr(nsub,nind)

for i=0,nsub-1 do begin
   tmp = echain[ind,i*npts:(i+1)*npts-1]
   for j=0,nind-1 do begin
      y = reform(tmp[j,*])
      y = y[sort(y)]
      ll[i,j] = y[indlim]
      y = reverse(y)
      ul[i,j] = y[indlim]
   endfor
endfor

sig = fltarr(nind)
ll_rms = fltarr(nind)
ul_rms = fltarr(nind)
for i=0,nind-1 do begin
   sig[i] = stddev(echain[ind[i],*],/double)
   ll_rms[i] = stddev(ll[*,i])
   ul_rms[i] = stddev(ul[*,i])
endfor

ll_acc = ll_rms/sig/sqrt(nsub)
ul_acc = ul_rms/sig/sqrt(nsub)




plot,ind,ll_acc,xtitle='IND',ytitle=textoidl('95% CL accuracy (\sigma)'),chars=1.7,yr=[0,.2],/yst,title=name
oplot,ind,ll_acc,ps=2
oplot,ind,ul_acc,color=!blue
oplot,ind,ul_acc,ps=2,color=!blue



if keyword_set(stopit) then stop  
end



