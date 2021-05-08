---
layout: post
title: Getting started with gRPC
date: 2021-04-19 16:05
comments: true
categories: [Golang, gRPC]
---

A very basic introduction of [gRPC](https://grpc.io/) could be - a modern RPC framework built on HTTP/2 that uses [Protofbuf](https://developers.google.com/protocol-buffers) serialization instead of commonly used text based formats such as Json or XML.

RPC stands for "Remote Procedure Call", bascially means "invoking a function on another system". SOAP(Simple Object Access Protocol) is one of the popular example of RPC and was very popular in the 90s. Remote Procedure Call techniques are thus not new and the concept has been around for decades.

There are issues with SOAP and traditional RPC frameworks like usage of heavy XML formats and payloads, tight coupling, schema maintenance issues, poort performance and steep learning curve. REST architecture style emerged as new cool framework that solved many shortcomings of SOAP. REST has become one of the default and widely used framework for designing and developing APIs.

The question arises why again RPC instead of REST? There are already good amount of articles on this subject of gRPC vs REST. Instead of debating on this subject, I'll be focusing on salient features and development of gRPC services.

gRPC is a modern RPC framework built at Google (thus 'g' in gRPC) and the protocol itself is built on HTTP/2. Using HTTP 2 under the hood, gRPC is able to optimize the network layer; unlike REST, SOAP or GraphQL, which must to use text-based data formats, gRPC uses the Protocol Buffers (Protobuf) binary format. This gives us certain pros like:
- Protobuf is extremely efficient on wire and gives high-performance, low-overhead messaging
- HTTP/2 supports any number of requests and responses over a single connection. Connections can also be bi-directional.
- Streaming requests and responses are first class

In addition, gRPC supports and introduces modern tools and ecosystems to support code generation, load balancing, tracing, health checking, and authentication and seamless interoperability between clients and services written in different languages.

Full gRPC Inroduciton & History: [https://grpc.io/about/](https://grpc.io/about/)

gRPC can be a great performant option for multi-language microservice communications.

### Getting started with gRPC in Go

Before we do anything, we need to get dependencies installed:

```bash
  # Instructions for Mac OS
  # You can find similar package for your OS
  $ brew install protobuf # protocol buffer compiler; protoc
  $ brew install protoc-gen-grpc-web # protoc plugin that generates code for gRPC-Web clients
  $ brew install grpcurl # curl for gRPC servers
```

An example definiton for sample Echo service with method called `Hello` that echoes back the text param passed to it. The code is heavily commented so the code self explains what it is doing.

```proto
  // use proto3 version of the protocol buffers language
  syntax = "proto3";

  // go package for generated go files
  option go_package = "protos/";

  // define a message type named Msg with field named Text of type string
  // each field/attribute should be assigned a unique number
  // These field numbers are used to identify fields in the message binary format, and should not be changed deployed
  message Msg {
    string Text = 1;
  }

  // define a RPC service named Echo
  service Echo {
    // defined a method for RPC service named Hello that takes a Msg and return a Msg
    rpc Hello(Msg) returns(Msg);
  }
```

Full Proto Language Guide: [https://developers.google.com/protocol-buffers/docs/proto3](https://developers.google.com/protocol-buffers/docs/proto3)

We can run `protoc -I ./ *.proto --go_out=. --go-grpc_out=.` to compile this proto file,
which will output two files `echo.pb.go` and `echo_grpc.pb.go` in `protos` folder. I am using Go as my primary language but single proto file works for over 12 programming languages.

Magically those file incorporates all the protobuf and grpc stuff into it. The files can be
intimidating to look at; but we don't need to understand all of it at this moment.

According to our service definition, we can look out for 3 things that will be of our interest:
Definition of `Msg`, server defintion for `EchoServer` and client definition for `EchoClient`:

```go
  package protos
  // ...

  type Msg struct {
    state         protoimpl.MessageState
    sizeCache     protoimpl.SizeCache
    unknownFields protoimpl.UnknownFields

    Text string `protobuf:"bytes,1,opt,name=Text,proto3" json:"Text,omitempty"`
  }
```

```go
  package protos
  // ...

  type EchoClient interface {
    Hello(ctx context.Context, in *Msg, opts ...grpc.CallOption) (*Msg, error)
  }

  // ...

  type EchoServer interface {
    Hello(context.Context, *Msg) (*Msg, error)
  }
```

It might be unbelievable but all we need to do to create our gRPC service is to implement these interfaces. That means we can focus on only and only on our business logic.

<!-- more -->

A sample `EchoServer` implementation:

`Note: *protos.Msg is used because my generated protos are in protos package`

```go
  type EchoServer struct {
  }

  func (es *EchoServer) Hello(c context.Context, m *protos.Msg) (respMsg *protos.Msg, err error) {
    txt := fmt.Sprintf("Echo: %s", m.Text)
    respMsg = &protos.Msg{
      Text: txt,
    }
    return
  }

```

All we need to do now is to init a new grpc server and register an instance of our EchoServer.

```go
  func main() {
    grpcServer := grpc.NewServer()
    echoServer := &EchoServer{
    }

    protos.RegisterEchoServer(grpcServer, echoServer)
    reflection.Register(grpcServer)

    lis, err := net.Listen("tcp", ":9000")
    if err != nil {
      log.Fatalf("failed to listen: %v", err)
    }
    
    log.Println("gRPC server starting at :9000")

    if err := grpcServer.Serve(lis); err != nil {
      log.Fatalf("failed to serve: %s", err)
    }
  }
```

We make use of `RegisterEchoServer` provided in generated code to register our instance of EchoServer into an instance of grpc server. 

As we can see we really don't need to code or worry about all the grpc inetrnals.

Next we can run our grpc server with `go run .`

Now, we can make use og `grpcurl ` to test our service.

Note that we need one extra line for grpcurl to work `reflection.Register(grpcServer)`
```shell

  $ grpcurl --plaintext -d '{"Text": "Hellp Grpc"}' localhost:9000 Echo.Hello
  # {
  #   "Text": "Echo: Hellp Grpc"
  # }
```
**grpcurl** allow us to do other useful things like;

listing all available services:

```shell
  grpcurl --plaintext localhost:9000 list
```

Or, decribe a service: 

```shell
  grpcurl --plaintext localhost:9000 describe Echo
```

Full doc: [https://github.com/fullstorydev/grpcurl](https://github.com/fullstorydev/grpcurl)


Next, we can make a proper client which can consume this service:

```go
  func main() {
    // setup grpc connection
    conn, err := grpc.Dial("localhost:9000", grpc.WithInsecure())
    if err != nil {
      log.Fatalf("did not connect: %v", err)
    }
    defer conn.Close()

    // create EchoClient using NewEchoClient, which is auto generated from proto file
    client := protos.NewEchoClient(conn)
    // create a Msg to send
    msg := &protos.Msg{
      Text: "Pinging",
    }
    // call Hello method on client, also auto generated
    resp, err := client.Hello(context.Background(), msg)

    if err != nil {
      log.Fatalf("could not greet: %v", err)
    }

    // Note that resp is of type Msg, as defined in proto file
    // All the grpc and protobuf is handled internally 
    log.Printf("Received: %v", resp)
    // prints: Received: Text:"Echo: Pinging"
  }	
```

Overall grpc services communication could be illustrated as:

![grpc communication](/images/grpc.png)

Full Code for this post: [https://gist.github.com/RohitRox/146fb015bcdf2d5a5a61d77241f4efa6](https://gist.github.com/RohitRox/146fb015bcdf2d5a5a61d77241f4efa6)

Over the next series of posts on this topic, I will be writing about `gRPC-web` and production readiness of grpc services.

As stated, gRPC works on top of HTTP/2, browsers which primarily uses HTTP/1, there is no way to force the use of HTTP/2, and there is no browser API to allow control over request packets to implement Protobuf format. gRPC-Web exists solely in a browser and acts as a translation layer between gRPC and applications in a browser which allows to develop end-to-end gRPC applications.

For production readiness, I will be exporing tools and techniques available for production usage like interceptors(kind of middlewares), logging, tracing, authentication and deployment strategies on AWS.  

Be sure to check back soon again.
