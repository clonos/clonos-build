#
PORTNAME=	myb
PORTVERSION=	24.12.3060
CATEGORIES=	sysutils
DISTFILES=

MAINTAINER=	olevole@olevole.ru
COMMENT=	MyBee Meta port
WWW=		https://myb.convectix.com

LICENSE=	BSD2CLAUSE

NO_BUILD=	yes
MYB_HOME?=	${PREFIX}/myb

NO_ARCH=	yes

.include <bsd.port.pre.mk>

do-install:
	@${ECHO} "Installing in ${MYB_HOME}"
	${MKDIR} ${STAGEDIR}${MYB_HOME}
	${CP} -a /root/myb-build/myb/ ${STAGEDIR}${MYB_HOME}/

post-install:
	${CAT} ${PKGDIR}/pkg-plist-chunk > ${TMPPLIST} ;
	@${FIND} -s ${STAGEDIR}${MYB_HOME} -not -type d | ${SORT} | \
	${SED} -e 's#^${STAGEDIR}${PREFIX}/##' >> ${TMPPLIST}

.include <bsd.port.post.mk>
