# basic makefile

ccast_intro: ccast_intro.pdf

ccast_intro.pdf: ccast_intro.tex crisdefs.tex figures/*.pdf
	pdflatex ccast_intro.tex -interaction nonstopmode || rm ccast_intro.pdf

show: ccast_intro.pdf
	acroread ccast_intro.pdf

clean:
	rm ccast_intro.log ccast_intro.aux ccast_intro.toc \
	ccast_intro.snm ccast_intro.nav ccast_intro.out 2> /dev/null || true

