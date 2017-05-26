######################################################################
# Makefile for LaTeX files
# Downloaded from http://www.cs.berkeley.edu/~jaein/notes/latexhowto.html
# Modified by Heedong Goh
######################################################################
TITLE = example
ODIR = .
# DO NOT CHANGE ######################################################
LATEX = pdflatex -jobname $(ODIR)/$(TITLE)
BIBTEX = bibtex
MAKEINDEX = makeindex
RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"
MAKEIDX = "^[^%]*\\makeindex"
MPRINT = "^[^%]*print"
USETHUMBS = "^[^%]*thumbpdf"
SRC	:= $(shell egrep -l '^[^%]*\\begin\{document\}' *.tex)
BIBFILE :=  $(shell perl -ne '($$_)=/^[^%]*\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib "}' $(SRC))
PDFPICS :=  $(shell perl -ne '@foo=/^[^%]*\\(includegraphics)(\[.*?\])?\{(.*?)\}/g;if (defined($$foo[2])) { if ($$foo[2] =~ /$$/) { print "$$foo[2] "; } else { print "$$foo[2] "; }}' $(SDIR)/*.tex)
DEP	= *.tex
TRG	= $(SRC:%.tex=%.pdf)
COPY = if test -r $(<:%.tex=%.toc); then cp $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); fi 
RM = rm -f
OUTDATED = echo "EPS-file is out-of-date!" && false
all 	: $(TRG)
define run-latex
	  @$(COPY);$(LATEX) $<
	  @egrep -q $(MAKEIDX) $< && ($(MAKEINDEX) $(<:%.tex=%);$(COPY);$(LATEX) $<) ; true
	  @egrep -c $(RERUNBIB) $(<:%.tex=%.log) && ($(BIBTEX) $(<:%.tex=%);$(COPY);$(LATEX) $<) ; true
	  @egrep -q $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) ; true
	  @egrep -q $(RERUN) $(<:%.tex=%.log) && ($(COPY);$(LATEX) $<) ; true
	  @if cmp -s $(<:%.tex=%.toc) $(<:%.tex=%.toc.bak); then true ;else $(LATEX) $< ; fi
	  @$(RM) $(<:%.tex=%.toc.bak)
	  # Display relevant warnings
	  @egrep -i "(Reference|Citation).*undefined" $(<:%.tex=%.log) ; true
		# Uncomment to convert PDF file to embed fonts
		#gs -sDEVICE=pdfwrite -q -dBATCH -dNOPAUSE -dSAFER   -dPDFX   -dPDFSETTINGS=/prepress   -dAutoFilterColorImages=false -dColorImageFilter=/FlateEncode   -dAutoFilterGrayImages=false -dGrayImageFilter=/FlateEncode   -sOutputFile=$(TRG:%.pdf=%_embed.pdf)   -c '<</NeverEmbed []>> setdistillerparams'   -f $(TRG) -c quit
endef
$(TRG)	: %.pdf : %.tex $(DEP) $(PDFPICS) $(BIBFILE)
	  @mkdir -p $(ODIR)
	  @$(run-latex)
clean  :
	@rm -f	*.aux *.bbl *.blg *.dvi	*.idx *.ilg *.ind *.lof *.log *.lot *.ps *.toc
clobber :
	@rm -f	*.aux *.bbl *.blg *.dvi	*.idx *.ilg *.ind *.lof *.log *.lot *.ps *.toc *.pdf
.PHONY	: all show clean ps pdf showps clobber
# Define rules for PDF source files.
%.pdf: %.eps
	epstopdf $< > $(<:%.eps=%.pdf)
######################################################################
