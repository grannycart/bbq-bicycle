# Makefile
# Last modified: 2025-07-21 20:53
#
# This Makefile modified from original maintainer at:
# https://github.com/evangoer/pandoc-ebook-template
# Originally released under an MIT license
#
BUILD = built-files
# This BOOKNAME variable is the output file name, not the title:
BOOKNAME = BBQ-Bike
# Metadata contains title and other info:
METADATA = metadata.yaml
# List of chapter files, in order, separated by a space.
CHAPTERS = content/BBQbike-first_draft.md 
# Similarly the license file's relation to CONTACT changes depending on format, so it too gets its own pandoc variable:
LICENSE = LICENSE
# I think the cover pic works better if you use a .png or a .jpg -- only used in epub
COVER_IMAGE = content/blue-cog.png
# While it seems like it would make sense to use 'book' for LATEX_CLASS,
# book sets up the file for book printing -- putting end-of-book pages on the reverse of the front-of-book pages.
# (There's probably a latex option to change that, but that is the default for book.)
# 'report' puts in annoying chapter numbers that I can't figure out how to get rid of with pandoc.
# This document is fairly simple, so 'article' works well --- though see notes in README.md on compiling.
LATEX_CLASS = article
# This line uses the -M switch to override the 'rights' field in metadata.yaml and puts a version date into the compiled pandoc file. 
# (has to go here to run on the command line so it can use the 'date' command from Linux)
# The default setup puts in today's date automatically:
RIGHTS = "(Version-date: `date "+%B %e, %Y"`) © 2025 Mark Torrey, CC BY-NC-SA" 

all: book

book: epub html pdf md 

clean:
	rm -rfd $(BUILD)

epub: $(BUILD)/epub/$(BOOKNAME).epub

html: $(BUILD)/html/$(BOOKNAME).html

pdf: $(BUILD)/pdf/$(BOOKNAME).pdf

latex: $(BUILD)/latex/$(BOOKNAME).tex

txt: $(BUILD)/txt/$(BOOKNAME).txt

md: $(BUILD)/markdown/$(BOOKNAME).md

$(BUILD)/epub/$(BOOKNAME).epub: $(METADATA) $(CONTACT) $(DIAGRAMS) $(CHAPTERS) $(LICENSE)
	mkdir -p $(BUILD)/epub
#	Note: Calibre comes with a tool that can convert epub to mobi (Amazon Kindle's format): ebook-convert
# 	Note: if you look at the original source from the maintainer for this ebook compiler they have a -S in these lines. That switch is deprecated in modern pandoc. I added the --from markdown+smart instead to the pandoc compile lines. ('smart' only does anything for markdown and latex outputs though, and is enabled by default, so this isn't doing anything. See: https://www.uv.es/wikibase/doc/cas/pandoc_manual_2.7.3.wiki?33)
# 	The --css references a simple css file used for formatting the epub. It is critically important because it centers the titles and separators among other things. It vastly improves the epub output. It is not included in the original maintainer's version.
# 	After generating, use epubcheck tool (available on linux distros) to check the epub file
	pandoc --css=css/epub.css --toc-depth=2 -M rights=$(RIGHTS) --epub-cover-image=$(COVER_IMAGE) -o $@ $^

$(BUILD)/html/$(BOOKNAME).html: $(METADATA) $(CONTACT) $(DIAGRAMS) $(CHAPTERS) $(LICENSE)
	mkdir -p $(BUILD)/html
#	The html is formatted by css to be a clean web page. See file in css/
#	--embed-resources requires at least pandoc 2.19
#	"rights" is set as date for htmlso it gets printed on first page as part of title block 
# 	The --css references a simple css file used for formatting the html as a simple clean web page without being the plainest of plain html.
#	-s, --standalone is set automatically for epub and pdf/latex, but not for html:
	pandoc --css=css/clean-html.css --toc --toc-depth=2 --css=$(CSS) --embed-resources --standalone -M date=$(RIGHTS) --to=html5 -o $@ $^

$(BUILD)/pdf/$(BOOKNAME).pdf: $(METADATA) $(CONTACT) $(DIAGRAMS) $(CHAPTERS) $(LICENSE)
	mkdir -p $(BUILD)/pdf
#	Below with some latex options (-V) added.
#	"rights" metadata set as "date" latex field here so it gets printed on first page as part of title block
# 	xelatex engine is necessary to process unicode character I used for section breaks
	pandoc -s --toc --toc-depth=2 --from markdown+smart --pdf-engine=xelatex -V date=$(RIGHTS) -V documentclass=$(LATEX_CLASS) -V papersize=letter -o $@ $^

$(BUILD)/markdown/$(BOOKNAME).md: $(METADATA) $(CHAPTERS) $(LICENSE)
	mkdir -p $(BUILD)/markdown
#	General Makefile note: $@ = output file name (listed before the : on the target line); $^ = inputs files names (after the : on the target line)
# 	markdown target just turns the chapters into a single, cleaned up md file.
	pandoc -s --from markdown+smart --toc-depth=2 -M rights=$(RIGHTS) --to=markdown -o $@ $^


.PHONY: all book clean epub html pdf md
