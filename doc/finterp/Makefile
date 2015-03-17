# basic makefile

finterp: finterp.pdf

finterp.pdf: finterp.tex figures/*.pdf
	pdflatex finterp.tex -interaction nonstopmode || rm finterp.pdf

show: finterp.pdf
	acroread finterp.pdf

clean:
	rm finterp.log finterp.aux finterp.toc \
		finterp.snm finterp.nav finterp.out 2> /dev/null || true

