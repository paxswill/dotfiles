if exists("did_load_filetypes")
	finish
endif
augroup filetypedetect
	" Octopress Markdown
	au! BufRead,BufNewFile *.markdown,*.textile setfiletype octopress
augroup END
