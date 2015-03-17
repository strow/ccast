# basic makefile

nonlin: nonlin.pdf

show: nonlin.pdf
	acroread /a "zoom=200" nonlin.pdf

nonlin.pdf: nonlin.tex crisdefs.tex figures/*.pdf Makefile
	pdflatex nonlin.tex -interaction nonstopmode || rm nonlin.pdf

clean:
	rm nonlin.log nonlin.aux nonlin.toc nonlin.vrb \
	  nonlin.snm nonlin.nav nonlin.out 2> /dev/null || true

