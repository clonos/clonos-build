PORTNAME=	garm
PORTVERSION=	0.1.5
CATEGORIES=	sysutils

MAINTAINER=	clonos@convectix.com
COMMENT=	Simplified API for creating and destroying CBSD virtual environments

LICENSE=	APACHE20

#BUILD_DEPENDS=	go123:lang/go123

USES=		cpe go:modules
USE_GITHUB=	yes
GH_ACCOUNT=	cloudbase
GH_TAGNAME=	c4a7a59
GH_TUPLE=	\
		BurntSushi:toml:v1.3.2:burntsushi_toml/vendor/github.com/BurntSushi/toml \
		DATA-DOG:go-sqlmock:v1.3.0:data_dog_go_sqlmock/vendor/gopkg.in/DATA-DOG/go-sqlmock.v1 \
		FiloSottile:edwards25519:v1.1.0:filosottile_edwards25519/vendor/filippo.io/edwards25519 \
		asaskevich:govalidator:a9d515a09cc2:asaskevich_govalidator/vendor/github.com/asaskevich/govalidator \
		beorn7:perks:v1.0.1:beorn7_perks/vendor/github.com/beorn7/perks \
		bradleyfalzon:ghinstallation:v2.10.0:bradleyfalzon_ghinstallation_v2/vendor/github.com/bradleyfalzon/ghinstallation/v2 \
		cespare:xxhash:v2.3.0:cespare_xxhash_v2/vendor/github.com/cespare/xxhash/v2 \
		chzyer:readline:v1.5.1:chzyer_readline/vendor/github.com/chzyer/readline \
		cloudbase:garm-provider-common:dfdf8e2e4853:cloudbase_garm_provider_common/vendor/github.com/cloudbase/garm-provider-common \
		davecgh:go-spew:v1.1.1:davecgh_go_spew/vendor/github.com/davecgh/go-spew \
		felixge:httpsnoop:v1.0.4:felixge_httpsnoop/vendor/github.com/felixge/httpsnoop \
		go-gorm:datatypes:v1.2.0:go_gorm_datatypes/vendor/gorm.io/datatypes \
		go-gorm:gorm:v1.25.9:go_gorm_gorm/vendor/gorm.io/gorm \
		go-gorm:mysql:v1.5.6:go_gorm_mysql/vendor/gorm.io/driver/mysql \
		go-gorm:sqlite:v1.5.5:go_gorm_sqlite/vendor/gorm.io/driver/sqlite \
		go-logr:logr:v1.4.1:go_logr_logr/vendor/github.com/go-logr/logr \
		go-logr:stdr:v1.2.2:go_logr_stdr/vendor/github.com/go-logr/stdr \
		go-openapi:analysis:v0.23.0:go_openapi_analysis/vendor/github.com/go-openapi/analysis \
		go-openapi:errors:v0.22.0:go_openapi_errors/vendor/github.com/go-openapi/errors \
		go-openapi:jsonpointer:v0.21.0:go_openapi_jsonpointer/vendor/github.com/go-openapi/jsonpointer \
		go-openapi:jsonreference:v0.21.0:go_openapi_jsonreference/vendor/github.com/go-openapi/jsonreference \
		go-openapi:loads:v0.22.0:go_openapi_loads/vendor/github.com/go-openapi/loads \
		go-openapi:runtime:v0.28.0:go_openapi_runtime/vendor/github.com/go-openapi/runtime \
		go-openapi:spec:v0.21.0:go_openapi_spec/vendor/github.com/go-openapi/spec \
		go-openapi:strfmt:v0.23.0:go_openapi_strfmt/vendor/github.com/go-openapi/strfmt \
		go-openapi:swag:v0.23.0:go_openapi_swag/vendor/github.com/go-openapi/swag \
		go-openapi:validate:v0.24.0:go_openapi_validate/vendor/github.com/go-openapi/validate \
		go-sql-driver:mysql:v1.8.1:go_sql_driver_mysql/vendor/github.com/go-sql-driver/mysql \
		go-yaml:yaml:v3.0.1:go_yaml_yaml/vendor/gopkg.in/yaml.v3 \
		golang-jwt:jwt:v4.5.0:golang_jwt_jwt_v4/vendor/github.com/golang-jwt/jwt/v4 \
		golang-jwt:jwt:v5.2.1:golang_jwt_jwt_v5/vendor/github.com/golang-jwt/jwt/v5 \
		golang:crypto:v0.26.0:golang_crypto/vendor/golang.org/x/crypto \
		golang:net:v0.28.0:golang_net/vendor/golang.org/x/net \
		golang:oauth2:v0.19.0:golang_oauth2/vendor/golang.org/x/oauth2 \
		golang:sync:v0.7.0:golang_sync/vendor/golang.org/x/sync \
		golang:sys:v0.24.0:golang_sys/vendor/golang.org/x/sys \
		google:go-github:v57.0.0:google_go_github_v57/vendor/github.com/google/go-github/v57 \
		google:go-github:v60.0.0:google_go_github_v60/vendor/github.com/google/go-github/v60 \
		google:go-querystring:v1.1.0:google_go_querystring/vendor/github.com/google/go-querystring \
		google:uuid:v1.6.0:google_uuid/vendor/github.com/google/uuid \
		gorilla:handlers:v1.5.2:gorilla_handlers/vendor/github.com/gorilla/handlers \
		gorilla:mux:v1.8.1:gorilla_mux/vendor/github.com/gorilla/mux \
		gorilla:websocket:a62d9d2a8413:gorilla_websocket/vendor/github.com/gorilla/websocket \
		inconshreveable:mousetrap:v1.1.0:inconshreveable_mousetrap/vendor/github.com/inconshreveable/mousetrap \
		jedib0t:go-pretty:v6.5.8:jedib0t_go_pretty_v6/vendor/github.com/jedib0t/go-pretty/v6 \
		jinzhu:inflection:v1.0.0:jinzhu_inflection/vendor/github.com/jinzhu/inflection \
		jinzhu:now:v1.1.5:jinzhu_now/vendor/github.com/jinzhu/now \
		josharian:intern:v1.0.0:josharian_intern/vendor/github.com/josharian/intern \
		juju:clock:v1.0.3:juju_clock/vendor/github.com/juju/clock \
		juju:errors:v1.0.0:juju_errors/vendor/github.com/juju/errors \
		juju:loggo:v1.0.0:juju_loggo/vendor/github.com/juju/loggo \
		juju:retry:v1.0.0:juju_retry/vendor/github.com/juju/retry \
		juju:testing:v1.0.2:juju_testing/vendor/github.com/juju/testing \
		mailru:easyjson:v0.7.7:mailru_easyjson/vendor/github.com/mailru/easyjson \
		manifoldco:promptui:v0.9.0:manifoldco_promptui/vendor/github.com/manifoldco/promptui \
		mattn:go-isatty:v0.0.20:mattn_go_isatty/vendor/github.com/mattn/go-isatty \
		mattn:go-runewidth:v0.0.15:mattn_go_runewidth/vendor/github.com/mattn/go-runewidth \
		mattn:go-sqlite3:v1.14.22:mattn_go_sqlite3/vendor/github.com/mattn/go-sqlite3 \
		minio:sio:v0.4.0:minio_sio/vendor/github.com/minio/sio \
		mitchellh:mapstructure:v1.5.0:mitchellh_mapstructure/vendor/github.com/mitchellh/mapstructure \
		mongodb:mongo-go-driver:v1.15.0:mongodb_mongo_go_driver/vendor/go.mongodb.org/mongo-driver \
		natefinch:lumberjack:v2.2.1:natefinch_lumberjack/vendor/gopkg.in/natefinch/lumberjack.v2 \
		nbutton23:zxcvbn-go:fa2cb2858354:nbutton23_zxcvbn_go/vendor/github.com/nbutton23/zxcvbn-go \
		oklog:ulid:v1.3.1:oklog_ulid/vendor/github.com/oklog/ulid \
		open-telemetry:opentelemetry-go:v1.25.0:open_telemetry_opentelemetry_go/vendor/go.opentelemetry.io/otel \
		opentracing:opentracing-go:v1.2.0:opentracing_opentracing_go/vendor/github.com/opentracing/opentracing-go \
		pkg:errors:v0.9.1:pkg_errors/vendor/github.com/pkg/errors \
		pmezard:go-difflib:5d4384ee4fb2:pmezard_go_difflib/vendor/github.com/pmezard/go-difflib \
		prometheus:client_golang:v1.19.0:prometheus_client_golang/vendor/github.com/prometheus/client_golang \
		prometheus:client_model:v0.6.1:prometheus_client_model/vendor/github.com/prometheus/client_model \
		prometheus:common:v0.53.0:prometheus_common/vendor/github.com/prometheus/common \
		prometheus:procfs:v0.13.0:prometheus_procfs/vendor/github.com/prometheus/procfs \
		protocolbuffers:protobuf-go:v1.33.0:protocolbuffers_protobuf_go/vendor/google.golang.org/protobuf \
		rivo:uniseg:v0.4.7:rivo_uniseg/vendor/github.com/rivo/uniseg \
		spf13:cobra:v1.8.0:spf13_cobra/vendor/github.com/spf13/cobra \
		spf13:pflag:v1.0.5:spf13_pflag/vendor/github.com/spf13/pflag \
		stretchr:objx:v0.5.2:stretchr_objx/vendor/github.com/stretchr/objx \
		stretchr:testify:v1.9.0:stretchr_testify/vendor/github.com/stretchr/testify \
		teris-io:shortid:71ec9f2aa569:teris_io_shortid/vendor/github.com/teris-io/shortid

USE_RC_SUBR=	garm

#BINARY_ALIAS=	go=go123

GO_TARGET=	${GO_PKGNAME}/cmd/${PORTNAME} \
		${GO_PKGNAME}/cmd/${PORTNAME}-cli

PLIST_FILES=	bin/garm \
		bin/garm-cli \
		"@sample etc/garm/config.toml.sample"

# ugly hack
post-extract:
	${LN} -sf /root/clonos-build/ports/garm/work/garm-${GH_TAGNAME} /usr/local/go123/src/garm

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/garm
	${INSTALL_PROGRAM} -s ${WRKDIR}/bin/garm ${STAGEDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} -s ${WRKDIR}/bin/garm-cli ${STAGEDIR}${PREFIX}/bin
	${SED} -e "s@/etc/garm@${PREFIX}/etc/garm@" ${WRKDIR}/${PORTNAME}-${GH_TAGNAME}/testdata/config.toml > ${STAGEDIR}${PREFIX}/etc/garm/config.toml.sample

.include <bsd.port.mk>
