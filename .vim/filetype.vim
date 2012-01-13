if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	" OpenCL
	au! BufRead,BufNewFile *.h,*.c,*.cl setfiletype opencl 
augroup END
