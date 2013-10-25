pro cons_all, nskip=nskip, report_card_only=report_card_only, string=string

do_rubin = 1
rubin_gelman=0.01

if 1 then begin
if n_elements(string) eq 0 then string='' 
spawn,'ls uberchains/*'+string+'*txt',list
nlist = n_elements(list)
names = strarr(nlist)
for i=0,nlist-1 do begin
   tmp = (strsplit(list[i],'_',/extract))
   whperiod = where(strmatch(tmp,'*.*'),nperiod)
   if nperiod ne 1 then begin
      print,'uh oh'
      stop
   endif
   tmp2 = tmp[2:whperiod[0]-1]
   n2 = n_elements(tmp2)
   tmp3 = tmp2[0]
   if n2 gt 1 then begin
      for j=1,n2-1 do tmp3 = tmp3+'_'+tmp2[j]
   endif
   names[i] = tmp3
endfor

uniqnames = uniqval(names)
endif else begin 
   
uniqnames = ['baseline','nowmap','nopriors','hbao','flat','wmaponly','nolens','nolens_hbao','alens','alens_t2','alens_t4','alens_wmaponly','alens_hbao','neff','neff_hbao','neff_hbao_nowmap','neff_wmaponly','r','yhe','r_wmaponly','yhe_wmaponly','yhe_neff_wmaponly','nrun_wmaponly','neff_hbao_wmaponly']

endelse

nuniq = n_elements(uniqnames)
print,'There are ',strtrim(nuniq,2),' unique names.'
for i=0,nuniq-1 do print,i,' ',uniqnames[i]
print,' '
pause

if ~keyword_set(report_card_only) then begin
   print,'WOA: are you sure you want to delete all consolidated chains?'
   pause
   spawn,'rm cons_chain*sav',sout
endif


ntot = fltarr(nuniq)
didwrite = fltarr(nuniq)
nskips = fltarr(nuniq)
half = fltarr(nuniq)
doall = ~keyword_set(report_card_only)
nrows_vec = -1
maxrm1_vec = -1
name_vec = ''
for i=0,nuniq-1 do begin
   this_ntot = 0
   this_didwrite = 0 
   cons_chain, uniqnames[i], nskip=nskip, doall=doall, ntot=this_ntot, didwrite=this_didwrite, $
               nrows_vec=this_nrows_vec,maxrm1_vec=this_maxrm1_vec, $
               do_rubin=do_rubin, rubin_gelman=rubin_gelman, out_nskip=this_out_nskip, $
               half=this_half

   ntot[i] = this_ntot
   didwrite[i] = this_didwrite
   nskips[i] = this_out_nskip
   half[i] = this_half
   
   nreturn = n_elements(this_nrows_vec)
   if nreturn gt 0 then begin
      nrows_vec = [nrows_vec, this_nrows_vec]
      maxrm1_vec = [maxrm1_vec, this_maxrm1_vec]
      name_vec = [name_vec, strarr(nreturn)+uniqnames[i]]
   endif
   
endfor

if nreturn gt 0 then begin
   nrows_vec = nrows_vec[1:*]
   maxrm1_vec = maxrm1_vec[1:*]
   name_vec = name_vec[1:*]
endif


print,' '
print,' '
print,'=== REPORT CARD (kilosamples) ==='
for i=0,nuniq-1 do $
   print,uniqnames[i],', ',strtrim(1.*ntot[i]/1e3,2)
print,' '
print,' '

;spawn,'date +%d%h%Y_%H%M%S',nnow
;spawn,'mkdir uberchains_'+nnow,sout
;spawn,'cp cons_chain*sav uberchains_'+nnow,sout


stop
end

