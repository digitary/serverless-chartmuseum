module helm.sh/serverless_chartmuseum

go 1.14

replace (
	github.com/NetEase-Object-Storage/nos-golang-sdk => github.com/karuppiah7890/nos-golang-sdk v0.0.0-20191116042345-0792ba35abcc
	go.etcd.io/etcd => github.com/eddycjy/etcd v0.5.0-alpha.5.0.20200218102753-4258cdd2efdf
)

require (
	github.com/Masterminds/semver/v3 v3.1.0
	github.com/alicebob/gopher-json v0.0.0-20200520072559-a9ecdc9d1d3a // indirect
	github.com/alicebob/miniredis v2.5.0+incompatible
	github.com/aws/aws-lambda-go v1.19.1
	github.com/chartmuseum/auth v0.4.2
	github.com/chartmuseum/storage v0.9.0
	github.com/ghodss/yaml v1.0.0
	github.com/gin-contrib/size v0.0.0-20200514145931-e0be654e00a7
	github.com/gin-gonic/gin v1.6.3
	github.com/go-redis/redis v6.15.8+incompatible
	github.com/gofrs/uuid v3.3.0+incompatible
	github.com/gomodule/redigo v2.0.0+incompatible // indirect
	github.com/prometheus/client_golang v1.0.0
	github.com/sirupsen/logrus v1.4.2
	github.com/spf13/viper v1.7.0
	github.com/stretchr/testify v1.6.1
	github.com/urfave/cli v1.20.0
	github.com/yuin/gopher-lua v0.0.0-20200603152657-dc2b0ca8b37e // indirect
	github.com/zsais/go-gin-prometheus v0.1.0
	go.uber.org/zap v1.10.0
	gonum.org/v1/netlib v0.0.0-20190331212654-76723241ea4e // indirect
	gopkg.in/go-playground/assert.v1 v1.2.1 // indirect
	gopkg.in/go-playground/validator.v9 v9.29.1 // indirect
	helm.sh/chartmuseum v0.12.0
	helm.sh/helm/v3 v3.2.4
	sigs.k8s.io/structured-merge-diff v1.0.1-0.20191108220359-b1b620dd3f06 // indirect
)
