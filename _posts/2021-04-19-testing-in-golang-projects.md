---
layout: post
title: Testing in Golang Projects
date: 2021-04-19 16:05
comments: true
categories: [Golang]
---

Complete source code containting snippets in this post is available at [https://github.com/RohitRox/go-test-supporting-project](https://github.com/RohitRox/go-test-supporting-project)


### Golang Testing Level I: Unit Tests


```golang
  // sample code for Post struct
  package models

  type Post struct {
    Id    int    `json:"id"`
    Title string `json:"title"`
    Body  string `json:"body"`
  }

  var validPostTitlePatt = regexp.MustCompile(`^\w+[\w\s]+$`)

  func NewPostWithTitle(title string) (post Post, err error) {
    if !validPostTitlePatt.MatchString(title) {
      err = errors.New("title is required and only alpha-numeric characters and underscore are permitted in title")
    }
    post = Post{Title: title}

    return
  }
```
Simple unit testing with `testing` package:

```golang
  // try to separate out test package
  // it forces us to use packages as it will be used by its consumers
  package models_test 

  import (
    "testing"

    m "go-test-supporting-project/models"
  )

  func TestPost(t *testing.T) {
    // tabular structure for test data, pretty common in go world
    testData := []struct {
      title string
      error bool
    }{
      {"Hello World", false},
      {"Hello Testing 124", false},
      {"Hello_World", false},
      {"Hello World!", true},
      {"Hello World - 124", true},
      {"Hello@World", true},
    }

    for _, dat := range testData {
      // t.Run for each test data
      // func (t *T) Run(name string, f func(t *T)) bool
      // t.Run runs f as a subtest of t called name.
      t.Run(dat.title, func(t *testing.T) {
        post, err := m.NewPostWithTitle(dat.title)
        if dat.error {
          if err == nil {
            // use t.Errorf/t.Error to log and mark failed test
            // use t.Fataf/t.Fatal to log and fast fail
            // use t.Logf/t.Log to log only
            // t.Skip to skip
            // Full docs https://golang.org/pkg/testing/#pkg-index
            t.Errorf("Expected error Got nil for post: %s", post.Title)
          }
        } else {
          if err != nil {
            t.Errorf("Unexpected error: %s for post: %s", err, post.Title)
          }
        }
      })
    }
  }
```

Testable Examples:

```golang
  package models_test

  import (
    "fmt"
    m "go-test-supporting-project/models"
  )

  // use Example to run and verify example code
  // a concluding line comment that begins with "Output:" and is compared with the standard output of the function when the tests are run
  // Example snippets of Go code are also displayed as package documentation
  // More info: https://blog.golang.org/examples
  func ExamplePost() {
    title := "Hello Testing 124"
    post, err := m.NewPostWithTitle(title)

    if err != nil {
      fmt.Println("Invalid title")
      fmt.Println(err)
    }

    fmt.Printf("Post initialied with title: %s", post.Title)
    // Output:
    // Post initialied with title: Hello Testing 124
  }
```

### Golang Testing Level I: Handler/Controller Tests

A Sample handler func:

```golang
  import (
    "fmt"
    "net/http"
  )

  type Handler struct {}

  func (h Handler) Status(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    fmt.Fprintf(w, "Status OK")
  }
```

The `httptest` package provides a replacement for the ResponseWriter called ResponseRecorder. We can pass it to the handler and check how it looks like after its execution:

```golang
  import (
    "net/http"
    "net/http/httptest"
    "testing"
  )

  func TestStatusHandler(t *testing.T) {
    t.Run("status check", func(t *testing.T) {
      // initialize a new request
      req, err := http.NewRequest("GET", "/anyroute", nil)
      if err != nil {
        t.Fatal(err)
      }

      h := Handler{}

      // create a ResponseRecorder (which satisfies http.ResponseWriter) to record the response
      rec := httptest.NewRecorder()
      // call the handler
      h.Status(rec, req)

      // check status code
      // can also check rec.Body for response body
      if status := rec.Code; status != http.StatusOK {
        t.Errorf("expected sattus code: %v got: %v",
          http.StatusOK, status)
      }
    })
  }

```

<!-- more -->

### Golang Testing Level II: Mocks

Interfaces usage for better code,  mocking and testing:

```golang

  type Handler struct {
    Store StoreIface 
  }
  // create and use StoreIface to represent storage adapter
  type StoreIface interface {
    // CreatePost could be related to db or api whatever adapter we would wish but 
    // not our concern in this moment
    CreatePost(Post) (post Post, err error)
  }

  func (h Handler) Create(w http.ResponseWriter, r *http.Request) {
    // ...
    // post := Post{}

    // Create operation uses h.Store's CreatePost function
    postCreated, err := h.Store.CreatePost(post)

    if err != nil {
      w.WriteHeader(http.StatusBadRequest)
      // ...
    }

    // ...
  }

```

Then in test, substitute interface:

```golang
  // create a mock store that implements StoreIface
  type MockedStore struct {
    // make an additional attribute with CreatePost signature
    // which we can use to assign a mock func later
    HandleCreatePost func(Post) (post Post, err error)
  }

  func (m MockedStore) CreatePost(postBody Post) (post Post, err error) {
    // call set HandleCreatePost if exists
    if m.HandleCreatePost != nil {
      return m.HandleCreatePost(postBody)
    }
    return
  }

  // in test
  
  // when we are not interested in CreatePost
  mockedStore := MockedStore{}
  handlers := Handler{
    Store: mockedStore,
  }

  // when we are interested in CreatePost
  mockedStore := MockedStore{
    HandleCreatePost: func(postBody Post) (post Post, err error) {
      post = Post{
        Id:    1011,
        Title: postBody.Title,
      }
      return
    },
  }

  // Or reproduce failure
  mockedStore := MockedStore{
    HandleCreatePost: func(postBody Post) (post Post, err error) {
      err = fmt.Errorf("Network error")
      return
    },
  }
```


### Golang Testing Level II: Outbound Calls

```golang
  // A sample of complex external service dependent CreatePost 

  type ApiRequester struct {
    BaseUrl string
  }

  func (a ApiRequester) CreatePost(post Post) (postCreated Post, err error) {
    url := fmt.Sprintf(a.BaseUrl + "/posts")

    postBody, err := json.Marshal(post)

    if err != nil {
      return
    }

    resp, err := http.Post(url, "application/json", bytes.NewReader(postBody))

    if err != nil {
      return
    }

    defer resp.Body.Close()

    err = json.NewDecoder(resp.Body).Decode(&postCreated)

    return
  }
```

Go's httptest package's `httptest.NewServer` to the rescue.

```golang
  // create real web server (for test) that returns canned responses
  // then real http requests can be issued against it
  postID := 2101
  testServer := httptest.NewServer(
    http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
      switch r.URL.Path {
      case "/posts":
        switch r.Method {
        case "POST":
          body, _ := ioutil.ReadAll(r.Body)
          var post Post
          err := json.Unmarshal(body, &post)

          if err != nil {
            w.WriteHeader(http.StatusBadRequest)
            fmt.Fprintf(w, "Error")
          }

          post.Id = postID
          json.NewEncoder(w).Encode(post)
          return
        }
      }
      w.WriteHeader(http.StatusBadRequest)
      fmt.Fprintf(w, "Invalid route")
    }),
  )

  defer testServer.Close()
```

```golang
    // then

    apiRequester := a.ApiRequester{
      // use testServer's url as base url
      BaseUrl: testServer.URL,
    }

    post := models.Post{Title: "Hello 124"}

    postCreated, err := apiRequester.CreatePost(post)

    if err != nil {
      t.Fatal(err)
    }

    if postCreated.Id != postID {
      t.Fatalf("Expected post id: %d got: %d", postID, postCreated.Id)
    }
```

