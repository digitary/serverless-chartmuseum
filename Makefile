build-lambda:
	GOOS=linux GOARCH=amd64 go build -o bin/main src/aws_lambda.go
	zip -j - bin/main > bin/main.zip
