pro transform_params, echain, repivot=repivot, alens_power=alens_power, zeq=zeq, vikh_param=vikh_param, flip_nrun=flip_nrun

if keyword_set(zeq) then begin
; replace omch2 with zeq
; NB: we must do this before ombh2 gets rescaled by 100!
   tmp = zeq_from_chain(echain)
   echain[3,*] = reform(tmp)
endif


; rescale ombh2 to 100ombh2
echain[2,*] = echain[2,*]*100.

; convert from log amplitude to 10^9*\Delta^2_R
echain[15,*] = exp(echain[15,*])/10.

; convert from ns to ns-1
;echain[12,*] = echain[12,*] - 1.

; if desired, recalculate ns for a different pivot point
if keyword_set(repivot) then begin
   echain[12,*] = echain[12,*] + alog(0.015/0.002)*echain[14,*]
endif

; convert from fnu to sum(neutrino massses)
; output in eV, see komatsu_wmap7_1001.4538
echain[7,*] = (echain[7,*]*echain[3,*])*94. 

if keyword_set(alens_power) then begin
;   echain[11,*] = echain[11,*]^alens_power
   echain[11,*] = abs(echain[11,*])^alens_power; fractional powers of negative numbers is a problem.  luckily, very few samples are at A_L<0.
endif

if keyword_set(vikh_param) then begin
   sigma8 = echain[40,*]
   omm = echain[39,*]
   vihk_combo = sigma8*((omm/0.25)^0.47)
   echain[40,*] = vihk_combo
endif

if keyword_set(flip_nrun) then begin
   echain[14,*] *= (-1.)
endif


end


