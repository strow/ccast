# basic makefile

ccast_eqns: ccast_eqns.pdf

ccast_eqns.pdf: ccast_eqns.tex crisdefs.tex figures/*.pdf
	pdflatex ccast_eqns.tex -interaction nonstopmode || rm ccast_eqns.pdf

show: ccast_eqns.pdf
	acroread ccast_eqns.pdf

clean:
	rm ccast_eqns.log ccast_eqns.aux ccast_eqns.toc \
		ccast_eqns.snm ccast_eqns.nav ccast_eqns.out 2> /dev/null || true

