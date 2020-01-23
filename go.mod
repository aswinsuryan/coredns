module github.com/coredns/coredns

go 1.12

require (
	github.com/Shopify/sarama v1.24.1 // indirect
	github.com/apache/thrift v0.13.0 // indirect
	github.com/aws/aws-sdk-go v1.20.5
	github.com/caddyserver/caddy v1.0.1
	github.com/coreos/etcd v3.3.13+incompatible
	github.com/dnstap/golang-dnstap v0.0.0-20170829151710-2cf77a2b5e11
	github.com/farsightsec/golang-framestream v0.0.0-20181102145529-8a0cb8ba8710
	github.com/golang/protobuf v1.3.1
	github.com/gophercloud/gophercloud v0.6.0 // indirect
	github.com/grpc-ecosystem/grpc-opentracing v0.0.0-20180507213350-8e809c8a8645
	github.com/matttproud/golang_protobuf_extensions v1.0.1
	github.com/miekg/dns v1.1.15
	github.com/opentracing/opentracing-go v1.1.0
	github.com/openzipkin/zipkin-go-opentracing v0.3.5
	github.com/prometheus/client_golang v1.0.0
	github.com/prometheus/client_model v0.0.0-20190129233127-fd36f4220a90
	github.com/prometheus/common v0.6.0
	github.com/submariner-io/lighthouse v0.0.0-20191016045327-fba110c45ce7
	github.com/tinylib/msgp v1.1.1 // indirect
	golang.org/x/sys v0.0.0-20190618155005-516e3c20635f
	google.golang.org/grpc v1.21.1
	gopkg.in/DataDog/dd-trace-go.v1 v1.15.0
	k8s.io/api v0.0.0-20190313235455-40a48860b5ab
	k8s.io/apimachinery v0.0.0-20190629003722-e20a3a656cff
	k8s.io/client-go v11.0.0+incompatible
	k8s.io/klog v0.3.3
	k8s.io/utils v0.0.0-20191030222137-2b95a09bc58d // indirect
)

replace k8s.io/apimachinery => k8s.io/apimachinery v0.0.0-20190313205120-d7deff9243b1

replace github.com/openzipkin-contrib/zipkin-go-opentracing => github.com/openzipkin-contrib/zipkin-go-opentracing v0.3.5

replace github.com/bronze1man/goStrongswanVici => github.com/mangelajo/goStrongswanVici v0.0.0-20190223031456-9a5ae4453bd
