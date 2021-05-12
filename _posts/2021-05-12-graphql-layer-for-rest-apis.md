---
layout: post
title: Graphql layer for REST Apis
date: 2021-05-12 23:43
comments: true
categories: [Nodejs, GraphQL]
---

Great thing about GraphQL is that we don't need to rewrite all of our existing APIs to get started.

We can easily build a GraphQL layer and use resolvers to get our data from Apis, but in Apollo Servers, [Apollo REST Data Source](https://github.com/apollographql/apollo-server/tree/main/packages/apollo-datasource-rest) is probably the cleanest way to build this layer. It also offers some desired feature like caching, deduplication, and error handling on top.

To get started, we first need to get the `apollo-datasource-rest` npm package.

In this post, I will be showing how we can build a graphql server on top of free APIs provided by [https://jsonplaceholder.typicode.com/](https://jsonplaceholder.typicode.com/)
I will be using two resources `posts` and `users`

Inspecting the apis, we can see the response data structure:

_**GET https://jsonplaceholder.typicode.com/posts**_
  ```json
  [
    {
      "userId": 1,
      "id": 1,
      "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
      "body": "quia et suscipit...ostrum rerum est autem sunt rem eveniet architecto"
    },
    {
      "userId": 1,
      "id": 2,
      "title": "qui est esse",
      "body": "est rerum tempore vita..qui aperiam non debitis possimus qui neque nisi nulla"
    },
    ...
  ]
```

_**GET https://jsonplaceholder.typicode.com/posts/1**_
```json
  {
    "userId": 1,
    "id": 1,
    "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
    "body": "quia et suscipi tno .. ostrum rerum est autem sunt rem eveniet architecto"
  }
```

_**GET https://jsonplaceholder.typicode.com/users/1**_
```json
  {
    "id": 1,
    "name": "Leanne Graham",
    "username": "Bret",
    "email": "Sincere@april.biz"
    "phone": "1-770-736-8031 x56442",
    "website": "hildegard.org"
  }
```

First, we'll create our graphql schema:

```graphql
  type Post {
    id: Int!
    userId: Int!
    title: String!
    body: String!
    user: User
  }

  type User {
    id: Int!
    name: String!
    username: String!
    email: String!
  }
```

and our query interface:

```graphql
  type Query {
    post(id: Int!): Post
    posts: [Post]
  }
```

Next we create REST data source classes:

```js
  import { RESTDataSource } from 'apollo-datasource-rest';

  export class PostsAPI extends RESTDataSource {
    constructor() {
      super();
      this.baseURL = 'https://jsonplaceholder.typicode.com/';
    }

    async find(id: number) {
      return this.get(`posts/${id}`);
    }

    async list() {
      return this.get('posts')
    }
  }

  export class UsersAPI extends RESTDataSource {
    constructor() {
      super();
      this.baseURL = 'https://jsonplaceholder.typicode.com/';
    }

    async find(id: number) {
      return this.get(`users/${id}`);
    }
  }
```

<!-- more -->

Now these data source class instances can be injects to an Apollo server:

```js
  const server = new ApolloServer({
    // ... ,
    dataSources: () => {
      return {
        postsAPI: new PostsAPI(),
        usersAPI: new UsersAPI(),
      };
    },
  });
```

Last part of the puzzle is to write up resolvers with these data sources:

```js
  const resolvers: IResolvers = {
    Query: {
      status(_: void, args: void): string {
        return 'Graphql status OK';
      },
      post: async (_source, { id }, { dataSources }) => {
        return dataSources.postsAPI.find(id)
      },
      posts: async (_source, {}, { dataSources }) => {
        return dataSources.postsAPI.list()
      },
    },
    Post: {
      user: async (_source, {}, { dataSources }) => {
        return dataSources.usersAPI.find(_source.userId)
      },
    }
  };
```

Now we can query our graphql server to get posts: 
```
{
  posts {
    id
    title
  }
}
```
and specify user attributes as well if we want:
```
{
  posts {
    id
    title
    user {
      name
    }
  }
}
```

This all maps out really well.

Now it may seem like we could have just use `axios` or `fetch` to do those REST api calls but Apollo's REST Data Source does a lot more behind the scenes.
Most importantly **Request Deduplication** and **Caching** are my favourite ones.

Request duplication occurs when we need to resolve same resource again and again. For eg in our posts query with user, if same user wrote multiple posts, the api calls to fetch user should occur only once for each unique users. The Rest Data Source package handles this via Promise memoization technique ( [How to Memoize Async Functions in JavaScript](https://bluepnume.medium.com/async-javascript-is-much-more-fun-when-you-spend-less-time-thinking-about-control-flow-8580ce9f73fc) ).

Apollo data sources by default built-in [InMemoryLRUCache](https://github.com/apollographql/apollo-server/blob/main/packages/apollo-server-caching/src/InMemoryLRUCache.ts) to store the results of past fetches.
Great thing about this is that we can swap cache stores as we like. Usage of Memcached/Redis as a cache store is effortless.

```js
  import { MemcachedCache } from 'apollo-server-cache-memcached';

  const server = new ApolloServer({
    // ...,
    cache: new MemcachedCache(
      ['memcached-server-1', 'memcached-server-2', 'memcached-server-3'],
      { retries: 10, retry: 10000 },
    ),
    dataSources: () => ({
      // ...
    }),
  });
```

### Links:

- [Apollo Data Sources Doc](https://www.apollographql.com/docs/apollo-server/data/data-sources/)

- [Apollo REST Data Source](https://github.com/apollographql/apollo-server/tree/main/packages/apollo-datasource-rest)
