function get_weight, echain, rozo_prior=rozo_prior, $
                     vihk_prior=vihk_prior, $
                     poisson_prior=poisson_prior, $
                     sz_prior=sz_prior, $
                     dusty_prior=dusty_prior, $
                     h0_prior=h0_prior, $
                     relax=relax, $
                     inverse_prior=inverse_prior, $
                     alens_power=alens_power

npts = n_elements(echain[2,*])
output = dblarr(npts) + 1.0
if n_elements(relax) eq 0 then relax=1.0

if keyword_set(rozo_prior) then begin
   sigma8 = echain[40,*]
   omm = echain[39,*]
   rozo_combo = sigma8*((omm/0.25)^0.41)
   output *= exp(-0.5*((rozo_combo-0.832)/(0.033*relax))^2.)
endif

if keyword_set(vihk_prior) then begin
   sigma8 = echain[40,*]
   omm = echain[39,*]
   vihk_combo = sigma8*((omm/0.25)^0.47)
   output *= exp(-0.5*((vihk_combo-0.813)/(0.027*relax))^2.)
endif


if keyword_set(poisson_prior) then begin
   poisson = echain[19,*]
   output *= exp(-0.5*((poisson-19.3)/(3.0*relax))^2.)
;   output *= exp(-0.5*((poisson-17.9)/(3.8*relax))^2.)
endif

if keyword_set(sz_prior) then begin
   sz = echain[17,*]
   output *= exp(-0.5*((sz-5.5)/(3.*relax))^2.)
endif

if keyword_set(dusty_prior) then begin
   dusty = echain[20,*]
   output *= exp(-0.5*((dusty-5.0)/(2.5*relax))^2.)
;   output *= exp(-0.5*((dusty-6.1)/(3.*relax))^2.)
endif


if keyword_set(h0_prior) then begin

   h0 = echain[43,*]

; first UNDO the original H0 prior
;   output /= exp(-0.5*((h0-74.2)/(3.6*relax))^2.)

; then APPLY the new H0 prior
   output *= exp(-0.5*((h0-73.8)/(2.4*relax))^2.)

endif

if keyword_set(alens_power) then begin
   alens = echain[11,*]
; the MCMC was run with an implicit prior that is uniform on A_LENS.
; We might want to look at the constraint on ALENS^POWER, and we might
; also want to transform the prior such that it's uniform in
; ALENS^POWER rather than ALENS.  I believe this does that.

; you can run this IDL code to see how i guessed at this form:
; for i=0,9 do begin & p=1.*(i+1.)/10. & x=randomu(seed,1e5) &
; h=histogram(x^p,binsize=0.01,loc=hx) & plot,hx,h &
; oplot,hx,hx^(1./p-1.)*max(h),color=!red & pause

;   output /= (alens^(1./alens_power-1.))
endif

if keyword_set(inverse_prior) then output = 1./output
return,output
end

