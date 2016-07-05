#
# makefile for ccast_eqns
#

ccast_eqns: ccast_eqns.pdf

ccast_eqns.pdf: ccast_eqns.tex crisdefs.tex Makefile figures/*.pdf
	pdflatex ccast_eqns.tex -interaction nonstopmode || rm ccast_eqns.pdf

show: ccast_eqns.pdf
	evince ccast_eqns.pdf

clean:
	rm *.aux *.log *.nav *.out *.snm *.toc 2> /dev/null || true

install: ccast_eqns.pdf
	cp -a ccast_eqns.pdf ..

