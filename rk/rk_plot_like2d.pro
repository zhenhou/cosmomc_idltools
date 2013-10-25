pro rk_plot_like2d, pp1, pp2, colorin=colorin, colorout=colorout, thick=thick, oplot=oplot, yl=yl, chars=chars, $
 xtitle=xtitle, ytitle=ytitle, subsamp=subsamp, xr=xr, yr=yr, lines=lines, xtickinterval=xtickinterval, $
 ytickinterval=ytickinterval, weight=weight_in, special_r2d=special_r2d, xmargin=xmargin, ymargin=ymargin, $
 prob=prob, bins1=bins1, bins2=bins2, nodata=nodata, clevels=clevels, $
 sigfact = sigfact, xaxis_zero = xaxis_zero, yaxis_zero=yaxis_zero

 if n_elements(sigfact) ne 1 then sigfact = 1.1
 
if n_elements(subsamp) ne 1 then subsamp=2.5
if n_elements(scale) ne 1 then scale = 1.0
if n_elements(offset) ne 1 then offset =0.

if n_elements(pp1) ne n_elements(pp2) then begin
   print,'uh oh.  those vectors need to be the same length.'
   stop
endif

nn=n_elements(pp1)
weight = n_elements(weight_in) gt 0 ? weight_in : fltarr(nn)+1.

sig1 = stddev(pp1) / sigfact
sig2 = stddev(pp2) / sigfact
if (sig1 le 0) or (finite(sig1) eq 0) or $
   (sig2 le 0) or (finite(sig2) eq 0) then begin
   print,'data constant, no histogram possible'
   return
endif

    omn1 = min(pp1,max=omx1)
    omn2 = min(pp2,max=omx2)
    bs1=sig1/subsamp
    bs2=sig2/subsamp
    nb1 = fix((omx1-omn1)/bs1)+1
    nb2 = fix((omx2-omn2)/bs2)+1
    bins1 = (findgen(nb1)+.5)*sig1/subsamp +omn1
    bins2 = (findgen(nb2)+.5)*sig2/subsamp +omn2
;    bins1 = (findgen(nb1)+.0)*sig1/subsamp +omn1
;    bins2 = (findgen(nb2)+.0)*sig2/subsamp +omn2
    nhits = dblarr(nb1,nb2)
    for i=0l,nn-1 do begin
;        nhits[fix((pp1[i]-omn1)/bs1),fix((pp2[i]-omn2)/bs2)]++
        nhits[fix((pp1[i]-omn1)/bs1),fix((pp2[i]-omn2)/bs2)] += weight[i]
    endfor

    sigma = [1., 2.,3.]
    ptes = erf(sigma/sqrt(2.))
    ntot = double(total(nhits))
    prob = double(nhits)/ntot
    ind = reverse(sort(prob))   ; in descending order
    psort = prob(ind)
    pcum=total(psort,/cum)
    nline = n_elements(sigma)
    levels = fltarr(nline)
    for i=0,nline-1 do begin
       ii = min(where(pcum gt ptes[i],nn))
       if nn gt 0 then $
          levels[i]=psort(ii) $
       else stop
    endfor
    clevels = levels(sort(levels))
;    help,xtickinterval

; ok, if this is a very specific plot, ns on the x axis, r on the y
; axis, then we want to take care of the edge at r=0.
if keyword_set(yaxis_zero) then begin
;   new_bins2 = min(bins2) - (bins2[1]-bins2[0])
;stop
   new_bins2 = 0.
   new_prob = fltarr(n_elements(bins1))
   for i=0,n_elements(bins1)-1 do new_prob[i] = interpol(prob[i,*],bins2,new_bins2, /quad)
   bins2 = [new_bins2,bins2]
   tmp_prob = fltarr(n_elements(bins1), n_elements(bins2))
   tmp_prob(*,1:*) = prob
   tmp_prob(*,0) = new_prob
   prob = tmp_prob
endif

if keyword_set(xaxis_zero) then begin
;   new_bins2 = min(bins2) - (bins2[1]-bins2[0])
;stop
   new_bins1 = 0.
   new_prob = fltarr(n_elements(bins2))
   for i=0,n_elements(bins2)-1 do new_prob[i] = interpol(prob[*,i],bins1,new_bins1, /quad)
   bins1 = [new_bins1,bins1]
   tmp_prob = fltarr(n_elements(bins1), n_elements(bins2))
   tmp_prob(1:*,*) = prob
   tmp_prob(0,*) = new_prob
   prob = tmp_prob
endif


if keyword_set(nodata) then tmp = 0 else begin
    if (size(prob))[0] eq 2 then $
       contour,prob,bins1,bins2,levels=clevels,/fill,c_colors=[colorin,colorout],xtitle=xtitle,ytitle=ytitle,title=title,xr=xr,yr=yr,iso=iso,/xst,/yst,chars=chars,font=font,overplot=oplot,xtickinterval=xtickinterval,ytickinterval=ytickinterval, xmargin=xmargin, ymargin=ymargin
endelse

if keyword_set(stopit) then stop
end 
