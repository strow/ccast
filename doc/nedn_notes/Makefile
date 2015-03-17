#
# makefile for nedn_notes
#

nedn_notes: nedn_notes.pdf

nedn_notes.pdf: nedn_notes.tex crisdefs.tex figures/*.pdf
	pdflatex nedn_notes.tex -interaction nonstopmode || rm nedn_notes.pdf

show: nedn_notes.pdf
	acroread nedn_notes.pdf

clean:
	rm nedn_notes.log nedn_notes.aux nedn_notes.toc \
	   nedn_notes.snm nedn_notes.nav nedn_notes.out 2> /dev/null || true

install: nedn_notes.pdf
	cp -a nedn_notes.pdf ..

