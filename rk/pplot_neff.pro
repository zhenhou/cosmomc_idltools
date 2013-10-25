pro pplot_neff, copy=copy, noplot=noplot
  
  filename = 'neff'
  filename_eps = filename+'.eps'
  size=3.0
  xsize=1.3*size
  ysize=1.0*size
  font=1
  chars=1.1

  spawn,'rm '+filename+'.eps '+filename+'.pdf '+filename+'.png'
  !p.multi = [0,1,1]
  openplotps,filen=filename_eps,xs=xsize,ys=ysize,/eps
  setcolors2,/sys
  colorin1=!orange
  colorout1=!darkorange
  colorin2=!blue
  colorout2=!darkblue
;  color1=!redorange
;  color1=!orange
  color1=!medorange
  color2=!blue
  color3=!darkgray


  thick1=6
  thick2=6
  thick3=6
  ranges = [0,10]
  ticks = [1.0]


  plot_1ds,'neff_wmaponly','neff','neff_hbao',ind=[9], $
           thick1=thick1,thick2=thick2,thick3=thick3, $
           color1=color1, color2=color2, color3=color3, $
           xrange=ranges, $
           xticki=ticks,chars=chars, pmulti=-1

if 1 then begin
  xleg = 0.61
  lchar=0.8*chars
;  xyouts,xleg,0.41,textoidl('SPT+WMAP+H_{0}+BAO'),color=!darkgray,chars=lchar,/normal,font=1,align=0.
  xyouts,xleg,0.41,textoidl('SPT+WMAP+H_{0}+BAO'),color=!black,chars=lchar,/normal,font=1,align=0.
  xyouts,xleg,0.36,'SPT+WMAP',color=color2,chars=lchar,/normal,font=1,align=0.
  xyouts,xleg,0.31,'WMAP',color=color1,chars=lchar,/normal,font=1,align=0.
endif else begin
  xleg = 0.66
  lchar=1.1*chars
  xyouts,xleg,0.36,'SPT+WMAP',color=color2,chars=lchar,/normal,font=1,align=0.
  xyouts,xleg,0.31,'WMAP',color=color1,chars=lchar,/normal,font=1,align=0.
endelse


  oplot,[1,1]*3.046,[-1,1]*99,lines=1,thick=1

  closeps
  spawn,'eps2pdf -f '+filename_eps
;  spawn,'eps2png -f '+filename_eps
if ~keyword_set(noplot) then spawn,'open '+filename+'.pdf'
  
  if keyword_set(copy) then $
     spawn,'cp '+filename+'.pdf ~/Desktop/low_ell_paper/'
end


