pro merge, ps_files, merged_pdf=merged_pdf
    
    n_ps = n_elements(ps_files)
    pdf_files = strarr(n_ps)

    for i=0, n_ps-1 do begin
        file = ps_files[i]
        pos = strpos(file,'.')
        pdf_tmp = '/tmp/'+strmid(file,0,pos)+'.pdf'

        pdf_files[i] = pdf_tmp

        spawn, ['ps2pdf',file,pdf_tmp],/noshell
    endfor
    
    rand = randomu(seed,/long)
    tex_file = '/tmp/merge_'+strcompress(string(rand),/remove)+'.tex'
    get_lun, unit
    openw, unit, tex_file
    printf, unit, '\documentclass{scrartcl}'
    printf, unit, '\usepackage{graphicx}'
    printf, unit, '\usepackage{tikz}'
    printf, unit, '\usetikzlibrary{calc}'
    printf, unit, ''
    printf, unit, '\begin{document}'
    printf, unit, '\pagestyle{empty}'
    printf, unit, '\begin{tikzpicture}'
    printf, unit, ''
    printf, unit, '\node (0,0) {\includegraphics[width=0.8\paperwidth, trim=4cm 10cm 4cm 4cm]{'+pdf_files[0]+'}};'
    for i=1, n_ps-1 do begin
        printf, unit, '\node [opacity=0.7] (0,0) {\includegraphics[width=0.8\paperwidth, trim=4cm 10cm 4cm 4cm]{'+pdf_files[i]+'}};'
    endfor
    printf, unit, '\end{tikzpicture}'
    printf, unit, '\end{document}'

    free_lun, unit

    spawn, ['pdflatex','-interaction=batchmode',tex_file], /noshell
        
    merged_tmp = 'merge_'+strcompress(string(rand),/remove)+'.pdf'
    if (keyword_set(merged_pdf)) then pdf_file=merged_pdf else pdf_file='merged.pdf'
    spawn, ['mv',merged_tmp,pdf_file],/noshell

    spawn, ['rm','-rf',tex_file], /noshell
    for i=0, n_ps-1 do begin
        spawn, ['rm','-rf',pdf_files[i]],/noshell
    endfor
end
