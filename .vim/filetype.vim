if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	" OpenCL
	au! BufRead,BufNewFile *.h,*.c,*.cl setfiletype opencl 
	" Octopress Markdown
	au! BufRead,BufNewFile *.markdown,*.textile setfiletype octopress
augroup END
