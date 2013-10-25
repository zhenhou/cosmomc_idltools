function nparam_to_xtitle, nparam, file=file,repivot=repivot, alens_power=alens_power, zeq=zeq, $
                           vikh_param=vikh_param, flip_nrun=flip_nrun

if n_elements(file) eq 0 then file='paramnames_alens.txt'
readcol,file,id,name1,name2,format='f,a,a'

nin = n_elements(nparam)
output = strarr(nin)

for i=0,nin-1 do begin
   
   wh=where(id eq nparam[i], nwh)
   if nwh eq 0 then return,'?'
   
   output[i] = name2[wh[0]]
   
   if keyword_set(repivot) and name1[wh[0]] eq 'ns' then output[i] = output[i] + ' (k_{0}=0.015 Mpc^{-1})'


   if keyword_set(alens_power) and name1[wh[0]] eq 'alens' then output[i] = output[i]+textoidl('^{'+sigfig(alens_power,2)+'}')


   if keyword_set(zeq) and name1[wh[0]] eq 'omegadmh2' then output[i] = textoidl('z_{EQ}')

   if keyword_set(vikh_param) and name1[wh[0]] eq 'sigma8*' then output[i] = textoidl('\sigma_{8}(\Omega_{M}/0.25)^{0.47}')

   if keyword_set(flip_nrun) and name1[wh[0]] eq 'nrun' then output[i] = '-'+output[i]

   output[i] = str_replace(output[i],'#',' ')
endfor
if nin eq 1 then output=output[0]

output = textoidl(output)
return,output
end



