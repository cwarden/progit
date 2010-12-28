#!/bin/bash

# Generate a Mobipocket format eBook suitable for use on a Kindle, for example.

if [[ $# != 1 ]]; then
	echo "Usage: $0 <language>"
	echo "  Ex: $0 en"
	exit
fi
DOCLANG="$1"
BASEDIR=$(realpath $(dirname $0)/..)
LANGDIR="$BASEDIR/$DOCLANG"
if [ ! -d "$LANGDIR" ]; then
	exit 1;
fi

which ebook-convert markdown > /dev/null
if [ $? -ne 0 ]; then
	echo "Make sure ebook-convert (from calibre) and markdown are in your PATH"
	exit 1
fi

HTMLFILE="$BASEDIR/progit.$DOCLANG.html"
MOBIFILE="${HTMLFILE%%.html}.mobi"

HTMLHEAD='<html xmlns="http://www.w3.org/1999/xhtml"><head><title>Pro Git - professional version control</title><meta http-equiv="Content-Type" content="text/html; charset=utf-8"></head><body>'
HTMLFOOT='</body></html>'

(echo $HTMLHEAD;
for i in $LANGDIR/*/*.markdown; do
	markdown $i;
done;
echo $HTMLFOOT) |
perl -p -e 's/Insert (18333fig\d{4}).png/<img src="figures\/$1-tn.png"\/><br\/>/g;' > $HTMLFILE

ebook-convert $HTMLFILE $MOBIFILE \
  --cover "$BASEDIR/epub/title.png" \
  --authors "Scott Chacon" \
  --level1-toc "//h:h1" \
  --level2-toc "//h:h2" \
  --level3-toc "//h:h3" \
  --extra-css "$BASEDIR/epub/ProGit.css" \
  --language $DOCLANG \
  --chapter "//h:h1" \
  --comments "licensed under the Creative Commons Attribution-Non Commercial-Share Alike 3.0 license"
