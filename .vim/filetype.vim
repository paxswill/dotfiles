if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	au! BufRead,BufNewFile *.cl setfiletype opencl 
	au! BufRead,BufNewFile *.c setfiletype opencl
	au! BufRead,BufNewFile *.h setfiletype opencl
augroup END
