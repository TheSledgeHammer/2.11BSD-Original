#
# Copyright (c) 1986 Regents of the University of California.
# All rights reserved.  The Berkeley software License Agreement
# specifies the terms and conditions for redistribution.
#
#	@(#)Makefile	6.1 (Berkeley) 5/4/86
#
SRCS=	make.ms
MACROS=	-msU
PRINTER=Pdp
TROFF=	ditroff -${PRINTER}

paper:	paper.${PRINTER}
	lpr -${PRINTER} -n paper.${PRINTER}

paper.${PRINTER}: ${SRCS}
	${TROFF} ${MACROS} -t ${SRCS} > paper.${PRINTER}

clean:
	rm -f paper.[PT]* *.spell errs Errs make.out

spell:	${SRCS}
	@for i in ${SRCS}; do \
		echo $$i; spell $$i | sort | comm -23 - spell.ok > $$i.spell; \
	done
