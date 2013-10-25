pro rk_plot_like1d, pp, color=color, thick=thick, oplot=oplot, yl=yl, chars=chars, xtitle=xtitle,subsamp=subsamp, xtickinterval=xtickinterval, xr=xr, lines=lines, weight=weight_in, stopit=stopit,yr=yr,title=title, special_r1d=special_r1d, xmargin=xmargin, ymargin=ymargin
  
;,file,nparam,nskip=nskip,xtitle=xtitle,scale=scale,title=title,ytitle=ytitle,cz=cz,oplot=oplot,color=color,linestyle=linestyle,psym=psym,stopit=stopit,subsamp=subsamp,offset=offset,results=results,gausstitle=gausstitle,yl=yl,fitoplot=fitoplot,chars=chars,ninetyfive=ninetyfive,alpha=alpha,yr=yr,xr=xr,thick=thick,massivenu=massivenu,nutest=nutest,ex=ex,temperature=temperature

if n_elements(subsamp) ne 1 then subsamp=2.5
if n_elements(scale) ne 1 then scale = 1.0
;if n_elements(xtitle) ne 1 then xtitle='param_'+strtrim(string(fix(nparam)),2)

if n_elements(ytitle) ne 1 then ytitle='Likelihood'
if n_elements(offset) ne 1 then offset =0.
weight = n_elements(weight_in) gt 0 ? weight_in : (fltarr(n_elements(pp))+1.)

print,'median: ',median(pp)
print,'mean: ',mean(pp)
sig = stddev(pp,/double)
if (sig le 0) or (finite(sig) eq 0) then begin
   print,'data constant, no histogram possible'
   return
endif
h=double(histogram(pp,binsize=sig/subsamp,omin=omn,omax=omx,reverse_ind=ri))
bins = (findgen(n_elements(h))+.5)*sig/subsamp +omn
h/=max(h)

; now weight the histogram using the WEIGHT array and the reverse
; indices, RI.
h2 = h*0.
for i=0,n_elements(bins)-1 do begin
   if ri[i] ne ri[i+1] then $
      h2[i] = total(weight[ri[ri[i] : ri[i+1]-1]],/double)
endfor
h2 /= max(h2)
h = h2

nperbin = h*total(weight)/total(h)
fracerror = 1./sqrt(nperbin)
herror = h*fracerror
res = gaussfit(bins,h,a,nterms=3,measure_errors=herror)
;oplot,bins,res,color=!red,thick=2
print,a[1]/a[2]
;stop

if keyword_set(gausstitle) then title=sigfig(a[1],3)+' +/- '+sigfig(a[2],4)
;if keyword_set(gausstitle) then title=xtitle+' = '+sigfig(a[1],3)+' +/- '+sigfig(a[2],4)

if keyword_set(temperature) then h=h^(temperature)

z = total(h,/cum)/total(h)

ind = where(z gt 0.95,ntmp)
limit95 = ntmp gt 0 ? bins[ind[0]] : !values.f_nan
print,'95% upper-limit: ',limit95
ind = where(z lt 0.05,ntmp)
lowerlimit95 = ntmp gt 0 ? bins[max(ind)] : !values.f_nan
print,'95% lower-limit: ',lowerlimit95

if keyword_set(nutest) then begin
    whle=where(bins le 3.04,compl=whgt)
    p_three_neutrinos = z[max(whle)]
    sigma_three_neutrinos = MPNORMLIM(p_three_neutrinos,/s)
    print,'p(N_EFF <= 3.04) = ',sigfig(p_three_neutrinos,5)
    print,'N_EFF <= 3.04 at ',sigfig(sigma_three_neutrinos,3),'-sigma'
endif

if keyword_set(ninetyfive) then legend,/top,/right,box=0,xtitle+' < '+sigfig(limit95,3)+' (95%)'


print,'mean ',total(bins*h)/total(h)
ind = where(z gt .5-.683/2)
ind2 = where(z gt .5+.683/2)
ind3 = where(z gt .5)
print,bins[ind[0]],bins[ind2[0]]
print,'median ',bins(ind3[0])
print,'errs ',(bins[ind2[0]]-bins[ind[0]])/2.
results={bins:bins,prob:h}

; ok, if this is r, let's take care of the edge at r=0.
if keyword_set(special_r1d) then begin
;   new_bin = -bins[1]
;   new_h = h[0] + (h[0]-h[1])

   new_bin = 0.
   new_h = interpol(h,bins,new_bin)

   bins = [new_bin,bins]
   h = [new_h,h]
   h /= max(h)
endif


if not keyword_set(oplot) then begin
    plot,bins,h,xtitle=xtitle,ytitle=ytitle,title=title,psym=psym,yl=yl,chars=chars,font=font,yr=yr,xr=xr,/xst,thick=thick,/nodata,xtickinterval=xtickinterval,lines=lines, xmargin=xmargin, ymargin=ymargin
    oplot,bins,h,color=color,thick=thick,lines=lines
endif else $
  oplot,bins,h,color=color,psym=psym,thick=thick,lines=lines

;oplot,bins,res,color=!red,thick=2

if keyword_set(fitoplot) then oplot,bins,res,color=!blue,thick=2
print,a

;stop
if keyword_set(stopit) then stop
end 
