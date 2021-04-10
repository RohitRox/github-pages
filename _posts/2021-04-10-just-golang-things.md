---
layout: post
title: Just Golang Things
date: 2021-04-10 00:35
comments: true
categories: [Golang]
---

### Nil Slice Vs Empty Slice

```go
  // create a nil slice of integers
  var arr []int

  // create an empty slice of integers
  arr := make([]int, 0)

```

### Unnecessary blank identifier

```go
  // works just fine
  for range something
  {
    run()
  }
```

### Checking inerfaces and types in runtime

```go
  type BroadcastIface interface {
    Broadcast()
  }

  var temp interface{} = somevar
	_, ok := temp.(BroadcastIface)

  if !ok {
    fmt.Println("somevar does not implement BroadcastIface")
  }

```


### Json Marshall type conversion

```go
  type person struct {
    Name    string  `json:"name"`
    Balance float64 `json:"balance,string"`
  }

  p := person{Name: "Steve", Balance: 200}
	jsonData, _ := json.Marshal(p)

	fmt.Println(string(jsonData))
  // {"name":"Steve","balance":"200"}
  // Note balance of type float64 is automatically converted into string
```


### A case for empty struct

```go
  // an empty structure that occupies zero bytes of storage
  // struct{}{}

  // can be used instead of bool or int in done channel
  done := make(chan struct{})
  // ...
  done <- struct{}{}


  type CalcIface interface {
    Add(a, b int) int
    Sub(a, b int) int
  }

  // No receiver capture funcs, empty struct to group methods togetehr
  type calc struct{}

  func (calc) Add(a, b int) int { return a+b }
  func (calc) Sub(a, b int) int { return a-b }

  // only expose Calc and CalcIface
  var Calc CalcIface = calc{}
```


### Add cool funcs on types

```go
  type people []string

  func (p *people) add(name string) {
    *p = append(*p, name)
  }

  grp := people{"John", "Steve"}
	grp.add("Mike")

	fmt.Println(grp)
  // [John Steve Mike]
```


### Function implementation alternative to single method interface

```go
  type SquarerIface interface {
    DoSquare(int) int
  }

  type ProcessFunc func(int) int

  func (pf ProcessFunc) DoSquare(i int) int {
    return pf(i)
  }

  myfunc := func(i int) int { return i * i }

	var sq SquarerIface = ProcessFunc(myfunc)

	fmt.Println(sq.DoSquare(5))
  // 25
}
```


### Closures/ Higher Order functions

```go
  func StartCounterFrom(start int) func() int {
    return func() int {
      start = start + 1
      return start
    }
  }

  incr := StartCounterFrom(10)
  fmt.Println(incr()) //prints 11
  fmt.Println(incr()) //prints 12
```


#### Embedding interfaces and structs

```go
  // Example 1
  type Ball struct {
    Radius   int
    Material string
  }
  func (b Ball) Bounce() {
    fmt.Printf("Bouncing ball %+v\n", b)
  }
  type Football struct {
    Ball // embedding  struct Ball
  }

  fb := Football{Ball{Radius: 5, Material: "leather"}}
  fb.Ball.Bounce() // works
  fb.Bounce() // works

  // Example 2
  // field collisions

  type A struct {
    x int32
  }

  type B struct {
    x int32
  }

  type C struct {
    A
    B
  }

  c := C{A{1}, B{2}}
  //fmt.Println(c.x) // Error, ambiguous
  fmt.Println(c.A.x) // Ok, 1
  fmt.Println(c.B.x) // Ok, 2
```

```go
  // Example 3
  // composing interfaces
  type area interface {
    area() float64
  }
  type perimeter interface {
    perimeter() float64
  }
  // Composing Interfaces
  type geometry interface {
    area
    perimeter
  }
```

```go
  // Example 4
  // interfaces in struct
  type animal interface {
    walk()
  }

  type pet1 struct {
    name string
  }

  func (p1 pet1) walk() {
    fmt.Println("Walking...")
  }

  type pet2 struct {
    animal
    name string
  }

  var p1 animal = &pet1{name: "Peggy"}
  var p2 animal = &pet2{name: "Meggy"}

	p1.walk() // ok
  p2.walk() // finds method, but will be intialised with the zero value of the interface which is nil. As walk in not implemented, a panic will occur

```


### Better Error

```go

  var RecordError = error.New("Record not found")
  // export and use RecordError

  // usage in another file
  func New() error {
    // ...
    if false {
      return RecordError
    }
  }

  // checking
  if err ==  RecordError {
    fmt.Println("I know this is record error")
  } else {
    fmt.Println("Something werid happen")
  }
```


### Switch based on types

```go
  func (u User) Make(v interface{}) {
    switch v.(type) { // or t := v.(type) and use t in later cases
    case string:
      // ...
    case int:
      // ...
    default:
      // ...
    }
  }

  // Example usage from Dynamodb's Go SDK
  if err != nil {
    switch t := err.(type) {
    case *dynamodb.TransactionCanceledException:
        log.Fatalf("failed to write items: %s\n%v", t.Message(), t.CancellationReasons)
    default:
        log.Fatalf("failed to write items: %v", err)
    }
  }
```
