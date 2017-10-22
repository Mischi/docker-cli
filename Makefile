#$OpenBSD$
ONLY_FOR_ARCHS =	amd64
COMMENT =		client for orchestrating remote and local Docker hosts

V =			17.10.0-ce
DISTNAME =		v${V}
PKGNAME =		docker-cli-17.10.0-ce

GH_ACCOUNT =		docker
GH_PROJECT =		docker-ce
GH_TAGNAME =		v17.10.0-ce

CATEGORIES =		sysutils
HOMEPAGE =		https://docs.docker.com/edge/engine/reference/commandline
MAINTAINER =		Dave Voutila <dave@sisu.io>

# APL v2.0
PERMIT_PACKAGE_CDROM =	Yes

WANTLIB +=		c pthread

MASTER_SITES =		https://github.com/docker/docker-ce/archive/

MODULES =		lang/go
BUILD_DEPENDS =	 	devel/gmake \
			shells/bash
TEST_DEPENDS =		devel/git
MODGO_TYPE =		bin

# machine's include Makefile needs to be told to use our Go command
MAKE_FLAGS +=		GO="${MODGO_CMD}"

# docker-ce includes cli as a subproj, need to use it specifically
#WRKSRC =		${WRKDIR}/${GH_PROJECT}-${V}/components/cli

# Override and grab the cli subdirectory and make a workspace
MODGO_HACK_WORKSPACE =	echo "WRKSRC: ${WRKSRC}" && \
			mv ${WRKSRC}/components/cli ${WRKSRC}/..;

pre-build:
	${MODGO_HACK_WORKSPACE}

do-build:
	#cp ${FILESDIR}/openbsd ${WRKSRC}/components/cli/scripts/build/
	cp ${FILESDIR}/openbsd ${WRKSRC}/../cli/scripts/build/
	cp ${FILESDIR}/winsize_openbsd_cgo.go \
        	${WRKSRC}/../cli/vendor/github.com/docker/docker/pkg/term/
	cp ${FILESDIR}/diskwriter_openbsd.go \
        	${WRKSRC}/../cli/vendor/github.com/tonistiigi/fsutil/
	cp ${FILESDIR}/xattr_openbsd.go \
        	${WRKSRC}/../cli/vendor/github.com/stevvooe/continuity/sysx
	cd ${WRKSRC}/../cli && \
		make binary-openbsd \
                	DISABLE_WARN_OUTSIDE_CONTAINER=1 ${MAKE_FLAGS}

do-test:
	cd ${WRKSRC} && \
        	${MODGO_CMD} get -u "github.com/golang/lint/golint" && \
		gmake test GO="${MODGO_CMD}" GOLINT_BIN=${WRKDIR}/go/bin/golint

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/../cli/build/docker ${PREFIX}/bin

.include <bsd.port.mk>
