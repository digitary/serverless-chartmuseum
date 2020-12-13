module helm.sh/serverless_chartmuseum

go 1.14

replace (
	github.com/NetEase-Object-Storage/nos-golang-sdk => github.com/karuppiah7890/nos-golang-sdk v0.0.0-20191116042345-0792ba35abcc
	go.etcd.io/etcd => github.com/eddycjy/etcd v0.5.0-alpha.5.0.20200218102753-4258cdd2efdf
)

require (
	github.com/alicebob/gopher-json v0.0.0-20200520072559-a9ecdc9d1d3a // indirect
	github.com/aws/aws-lambda-go v1.19.1
	github.com/chartmuseum/auth v0.4.2 // indirect
	github.com/chartmuseum/storage v0.9.0
	github.com/gin-contrib/size v0.0.0-20200514145931-e0be654e00a7 // indirect
	github.com/go-redis/redis v6.15.8+incompatible // indirect
	github.com/gofrs/uuid v3.3.0+incompatible // indirect
	github.com/spf13/viper v1.7.0 // indirect
	github.com/urfave/cli v1.20.0
	github.com/yuin/gopher-lua v0.0.0-20200603152657-dc2b0ca8b37e // indirect
	helm.sh/chartmuseum v0.12.0
	helm.sh/helm/v3 v3.2.4 // indirect
)
