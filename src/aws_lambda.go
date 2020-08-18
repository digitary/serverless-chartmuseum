package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/chartmuseum/storage"
	"github.com/urfave/cli"
	"helm.sh/chartmuseum/pkg/chartmuseum"
	cm_logger "helm.sh/chartmuseum/pkg/chartmuseum/logger"
	cm_router "helm.sh/chartmuseum/pkg/chartmuseum/router"
	mt "helm.sh/chartmuseum/pkg/chartmuseum/server/multitenant"
	"helm.sh/chartmuseum/pkg/config"
	"net/http"
	"net/http/httptest"
	"os"
	"reflect"
	"strings"
	"time"
)

var httpServer http.Server
var logs *cm_logger.Logger
var started bool


func cliHandler(c *cli.Context) {
	logs.Debug("CLI handler called")
	conf := config.NewConfig()
	err := conf.UpdateFromCLIContext(c)

	if err != nil {
		logs.Fatal(err)
	}

	logs.Debug("Creating S3 backend")
	backend := storage.NewAmazonS3Backend(
		conf.GetString("storage.amazon.bucket"),
		conf.GetString("storage.amazon.prefix"),
		conf.GetString("storage.amazon.region"),
		conf.GetString("storage.amazon.endpoint"),
		conf.GetString("storage.amazon.sse"),
	)


	logs.Debug("Creating Server options")
	options := chartmuseum.ServerOptions{
		StorageBackend:         backend,
		ExternalCacheStore:     nil,
		TimestampTolerance:     conf.GetDuration("storage.timestamptolerance"),
		ChartURL:               conf.GetString("charturl"),
		TlsCert:                conf.GetString("tls.cert"),
		TlsKey:                 conf.GetString("tls.key"),
		TlsCACert:              conf.GetString("tls.cacert"),
		Username:               conf.GetString("basicauth.user"),
		Password:               conf.GetString("basicauth.pass"),
		ChartPostFormFieldName: conf.GetString("chartpostformfieldname"),
		ProvPostFormFieldName:  conf.GetString("provpostformfieldname"),
		ContextPath:            conf.GetString("contextpath"),
		LogJSON:                conf.GetBool("logjson"),
		LogHealth:              conf.GetBool("loghealth"),
		Debug:                  conf.GetBool("debug"),
		EnableAPI:              !conf.GetBool("disableapi"),
		DisableDelete:          conf.GetBool("disabledelete"),
		UseStatefiles:          !conf.GetBool("disablestatefiles"),
		AllowOverwrite:         conf.GetBool("allowoverwrite"),
		AllowForceOverwrite:    !conf.GetBool("disableforceoverwrite"),
		EnableMetrics:          !conf.GetBool("disablemetrics"),
		AnonymousGet:           conf.GetBool("authanonymousget"),
		GenIndex:               conf.GetBool("genindex"),
		MaxStorageObjects:      conf.GetInt("maxstorageobjects"),
		IndexLimit:             conf.GetInt("indexlimit"),
		Depth:                  conf.GetInt("depth"),
		MaxUploadSize:          conf.GetInt("maxuploadsize"),
		BearerAuth:             conf.GetBool("bearerauth"),
		AuthRealm:              conf.GetString("authrealm"),
		AuthService:            conf.GetString("authservice"),
		AuthCertPath:           conf.GetString("authcertpath"),
		DepthDynamic:           conf.GetBool("depthdynamic"),
		CORSAllowOrigin:        conf.GetString("cors.alloworigin"),
		WriteTimeout:           conf.GetInt("writetimeout"),
		ReadTimeout:            conf.GetInt("readtimeout"),
	}

	contextPath := strings.TrimSuffix(options.ContextPath, "/")
	if contextPath != "" && !strings.HasPrefix(contextPath, "/") {
		contextPath = "/" + contextPath
	}

	logs.Debug("Creating Router")
	router := cm_router.NewRouter(cm_router.RouterOptions{
		Logger:            logs,
		Username:          options.Username,
		Password:          options.Password,
		ContextPath:       contextPath,
		TlsCert:           options.TlsCert,
		TlsKey:            options.TlsKey,
		TlsCACert:         options.TlsCACert,
		LogHealth:         options.LogHealth,
		EnableMetrics:     options.EnableMetrics,
		AnonymousGet:      options.AnonymousGet,
		Depth:             options.Depth,
		MaxUploadSize:     options.MaxUploadSize,
		BearerAuth:        options.BearerAuth,
		AuthRealm:         options.AuthRealm,
		AuthService:       options.AuthService,
		AuthCertPath:      options.AuthCertPath,
		DepthDynamic:      options.DepthDynamic,
		CORSAllowOrigin:   options.CORSAllowOrigin,
		ReadTimeout:       options.ReadTimeout,
		WriteTimeout:      options.WriteTimeout,
	})

	logs.Debug("Creating Multi Tenant Server")
	multiTenantServer, _ := mt.NewMultiTenantServer(mt.MultiTenantServerOptions{
		Logger:                 logs,
		Router:                 router,
		StorageBackend:         options.StorageBackend,
		ExternalCacheStore:     options.ExternalCacheStore,
		TimestampTolerance:     options.TimestampTolerance,
		ChartURL:               strings.TrimSuffix(options.ChartURL, "/"),
		ChartPostFormFieldName: options.ChartPostFormFieldName,
		ProvPostFormFieldName:  options.ProvPostFormFieldName,
		MaxStorageObjects:      options.MaxStorageObjects,
		IndexLimit:             options.IndexLimit,
		GenIndex:               options.GenIndex,
		EnableAPI:              options.EnableAPI,
		DisableDelete:          options.DisableDelete,
		UseStatefiles:          options.UseStatefiles,
		AllowOverwrite:         options.AllowOverwrite,
		AllowForceOverwrite:    options.AllowForceOverwrite,
	})

	logs.Debug(multiTenantServer)

	httpServer = http.Server{
		Addr:         fmt.Sprintf("%s:%d", "www.example.com", conf.GetInt("port")),
		Handler:       router,
		ReadTimeout:  router.ReadTimeout,
		WriteTimeout: router.WriteTimeout,
	}

	logs.Debug("Starting Server")
	httpServer.ListenAndServe()
}
func startChartMuseum() {
	logs.Debug("startChartMuseum called")

	var args []string
	args = append(args, "--gen-index")
	app := cli.NewApp()
	app.Name = "ChartMuseum"
	app.Version = fmt.Sprintf("%s", "v0.12.0")
	app.Usage = "Helm Chart Repository with support for Amazon S3, Google Cloud Storage, Oracle Cloud Infrastructure Object Storage and Openstack"
	app.Action = cliHandler
	app.Flags = config.CLIFlags
	app.Run(args)
}

func waitForServer(){

	logs.Debug("Waiting for http server to spin up")
	for reflect.ValueOf(httpServer).IsZero() && !started {
		time.Sleep(100 * time.Millisecond)
	}
}
func handleRequest(req events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	waitForServer()

	logs.Debug(req.Path)
	path := fmt.Sprintf("%s%s", req.RequestContext.DomainName, req.Path)

	logs.Debug(path)
	logs.Debug(req.Body)

	body := req.Body

	if req.Path == "/api/charts" && req.HTTPMethod == "POST"{
		decoded, _ := base64.StdEncoding.DecodeString(body)
		body = string(decoded)
	}

	proxyRequest, _ := http.NewRequest(req.HTTPMethod, path, strings.NewReader(body))
	for key, element := range req.Headers {
		proxyRequest.Header.Add(key,element)
	}

	responseRecorder := httptest.NewRecorder()
	httpServer.Handler.ServeHTTP(responseRecorder, proxyRequest)

	chartmuseumResult := responseRecorder.Result()


	buf := new(bytes.Buffer)
	buf.ReadFrom(chartmuseumResult.Body)
	chartmuseumResponseBody := buf.String()

	logs.Debug(chartmuseumResponseBody)

	responseHeaders := make(map[string][]string)

	for key, element := range chartmuseumResult.Header {
		responseHeaders[key] = element
	}

	logs.Debug(responseHeaders)

	returnProxyResult := events.APIGatewayProxyResponse{}
	returnProxyResult.StatusCode = chartmuseumResult.StatusCode
	returnProxyResult.MultiValueHeaders = responseHeaders
	returnProxyResult.Body = chartmuseumResponseBody

	// If GET request for a chart, base64 encode the result for api gateway to serve
	if strings.Contains(req.Path, "/charts/") && req.HTTPMethod == "GET"{
		chartmuseumResponseBody = base64.StdEncoding.EncodeToString([]byte(chartmuseumResponseBody))
		returnProxyResult.Body = chartmuseumResponseBody
		returnProxyResult.IsBase64Encoded = true
	}

	return returnProxyResult, nil
}
func debugEnabled() bool{
	return os.Getenv("LOG_LEVEL") == "DEBUG"
}

func main() {

	logs, _ = cm_logger.NewLogger(cm_logger.LoggerOptions{
		Debug:   debugEnabled(),
		LogJSON: false,
	})

	logs.Debug("Lambda called")

	if reflect.ValueOf(httpServer).IsZero() && !started {
		go startChartMuseum()
	}

	lambda.Start(handleRequest)
}
