SUMMARY = "CCSP Common Library - Host scripts etc"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=19774cd4dd519f099bc404798ceeab19"

PV = "REL+git${SRCPV}"

SRC_URI = "git://github.com/lgirdk/ccsp-common-library.git;branch=ofw-2406.6;protocol=https"

SRCREV ?= "${AUTOREV}"

S = "${WORKDIR}/git"

inherit native

do_configure () {
	:
}

do_compile () {
	${CC} ${CFLAGS} -c ${S}/source/ccsp/components/CCSP_AliasMgr_hosttools/convert_alias_xml.c -o ${B}/convert_alias_xml.o
	${CC} ${LDFLAGS} ${B}/convert_alias_xml.o -o ${B}/convert_alias_xml
}

do_install () {
	install -d ${D}${bindir}
	install -m 644 ${S}/source/dm_pack/dm_pack_code_gen.py ${D}${bindir}/
	install -m 755 ${B}/convert_alias_xml ${D}${bindir}/
}
