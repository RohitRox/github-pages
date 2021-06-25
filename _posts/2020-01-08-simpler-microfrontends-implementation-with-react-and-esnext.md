---
layout: post
title: Simpler Microfrontends Implementation with React and ESNext
date: 2020-01-05 19:50
comments: true
categories: [Microfrontends]
---

There has been a lot of talks and buzz around Microfrontends.

From [https://micro-frontends.org/](https://micro-frontends.org/), Microfrontend systems are

> Techniques, strategies and recipes for building a modern web app with multiple teams that can ship features independently.

The basic idea is to extend the idea of microservices to the frontend development through which a system can be divided into teams that own end to end system and independently deliver frontend applications to compose into a greater whole.

A simple illustration to explain the idea is shown as below:

### Microservices with Monolith Frontend
![microservices](/images/microfrontends-1.png)

### Microservices with Micro Frontend
![microfrontends](/images/microfrontends-2.png)

Microfrontends brings the same benefits like performance, incremental upgrades, decoupled codebases, independent deployments, autonomous teams to the frontend engineering like microservices bring to backend services.

Now the teams and the UI can be broken down smaller groups as shown in the pictures but the challenge is in integration and serving a unified experience to the users and there will always be cases where interfaces or interface components will collide as UI components can easily expand cross pages/domains.

There are already a few architectures being that are being used and proposed to achieve Microfrontend architecture. Cam Jackson's post on [Martin Fowler](https://martinfowler.com/articles/micro-frontends.html#TheExample) includes some nice approaches.

Let's see how our take on microfrontends at Cloudfactory affects page organization.

<!-- more -->

### Microfrontends in action
![microfrontends in action](/images/microfrontends-3.png)

There could be many permutations and combinations. There are even implementation of microfrontends which can run multi-framework components on the same page [Read more about this](https://ivanjov.com/micro-frontends-how-i-built-a-spa-with-angular-and-react/). The one illustrated in the picture is fairly simpler where the teams are organized under business domains and domain-specific interfaces cross the (user-facing) application interface boundaries. These domain components may appear in any user-facing interface but need to behave differently and maintained separately.

We've seen similar kind of organization on AWS Console's interface and some of the Facebook's interface.

An alternative implementation, to create a big single SPA via Run-time integration via JavaScript is documented and implemented wonderfully on [https://microfrontends.com/](https://microfrontends.com/) and [https://martinfowler.com/articles/micro-frontends.html#Run-timeIntegrationViaJavascript](https://martinfowler.com/articles/micro-frontends.html#Run-timeIntegrationViaJavascript)

Instead of relying on a runtime integration system or complicated frameworks, We have taken an approach to tweak a few configs in the build process and use some old tricks. Our goal was to enable teams to have microfrontend architectures but not burden system with yet another system for managing microfrontend itself. Technically it means we don't have a bootstrapping layer or any other service serving asset manifests.

The solution uses React with Typescript and Webpack with ESNext modules set. This combination allows us to build extremely optimized multiple applications without increasing the bundle size and leverages all the code splitting and lazy loading goodness.

There are a good number of articles on React code splitting and lazy loading already on the web, so I am skipping those details in this post.

The solution works for a scenario where we have a large application, large enough so that it cannot be contained as a Single Page App, thus are divided into multiple SPA pages or related pages. And multiple teams working together to delivers small micro-components on the page.

### Conceptual Idea

The high-level idea is to export components as ESNext modules which can be easily reused across interfaces through a CDN and lazily loaded when applicable. This kind of integration is not new and we have seen this from the days of jQuery plugins and widgets.

![microfrontends-in-play](/images/microfrontends-4.png)

For any shared components and interfaces we create node modules and with [typescript config](https://www.typescriptlang.org/docs/handbook/tsconfig-json.html) `module` set to `esnext` and with [webpack config](https://webpack.js.org/configuration) `output.library` properly set, we get modules to work at the runtime loaded via CDN. With webpack's `publicPath` set to CDN path, **Code spitting** and **React's lazy/suspense** plays nicely. We only need to know the main entry point of the main file of the module which can be made predictable if a standard company-wide convention is followed.

A sample `tsconfig`

```json
  {
    "compilerOptions": {
      "lib": ["dom", "es2015", "es2016"],
      "module": "esnext",
      "moduleResolution": "node",
      "target": "es5",
      "jsx": "react",
      ...
    }
  }
```

A sample webpack config

```js
  const version = `${require('./package.json').version}`;
  //...
  module.exports = {
    entry: [
      // ...
    ],
    output: {
      filename: 'main.js',
      path: path.resolve(__dirname, 'dist', version),
      library: ['MFE', 'SHC'],
      publicPath: `https://cdn/path/shared-components/dist/${version}/`,
      // ...
    },
  // ...
  }

```

We get the exported modules at global `MFE.SHC` object and with proper `publicPath` set with dynamically computed `version` it makes easy to generated versioned artifacts.

We follow semantic versioning, so ignore patch versions, so `1.2.1`, `1.2.2` .. `1.2.9` are all consolidated into `1.2.x`. This also gives us a way to push interface changes to live without having to re-deploy specific pages. We could also ignore minor version and just use `1.x.x`, latest major all the time. This will enable, as shown in the example in the demo, Team C to publish an update to their interface with any action from Team A who manages the page, as long as they are updating at major version.

Next we use webpacks `externals` to find the modules at runtime.

```js
  module.exports = {
    // ...
    externals: {
      "react": "MFE.GLB.React",
      "react-dom": "MFE.GLB.ReactDOM",
      "shared-components": "MFE.SHC"
    },
    // ...
  }

```

We have global dependencies exported into a single bundle which can be accessed at `MFE.GLB`

A simplified working demo is available at [https://rohitrox.github.io/microfrontend-esnext-demo/team-a-page/dist/](https://rohitrox.github.io/microfrontend-esnext-demo/team-a-page/dist/)

Now, the implementation can be enhanced to support run-time microfrontends javascript integration. Given evolving application at cloudfactory, we felt we aren't yet ready to allow all the microfrontends to update themselves automatically. The container application/page and the microfrontends are all changing all the time so best we did was to follow major version based auto-updates. If there is a major version release in the microfrontend, the container app needs to acknowledge, publish the new version of itself that will use the updated microfrontend.

Next, for the communication between the microfrontend components, we are using React props and [Custom Events](https://developer.mozilla.org/en-US/docs/Web/Guide/Events/Creating_and_triggering_events). There are also number of open-source event bus libraries available.

For the demo, I have used GitHub for everything, including team modules and as a CDN to find dependencies.

To make the demo work with GitHub pages, I have the set the `publicPath` in webpack config in a specific Github way.

The index pages are hardcoded with the links to a specific resource in CDN. While those are hardcoded for the demo, in our real system, we have added few configs in webpack config to take care of that. The logic is to scan through `package.json`'s dependencies and automatically inject applicable `script` or `link` elements into the index page with a specified version.

Source code is available at [https://github.com/RohitRox/microfrontend-esnext-demo](https://github.com/RohitRox/microfrontend-esnext-demo)

The folder has been named to mimic separate modules.

### What's not addressed in this post

  - **Stylesheets** - We export base styles as shared and use them via CDN. To prevent overriding and conflicts, we obfuscate CSS class names.
  - **Multiple React Version** - This solution does not provide a good solution for this. All of our microfrontends use compatible versions of React and ReactDOM so we use a common version. We didn't develop on top of legacy application and started from scratch so haven't run through this problem.
  - **SPA Routing** - React routing stuff is not detailed in this post or the demo. The container page is in control of the router and if microfrontends need to control page paths they do it by communicating with the container via props, callbacks or event system.

Resources and Further Researches:

  - [Micro Frontends on martinFowler.com by Cam Jackson (Article)](https://martinfowler.com/articles/micro-frontends.html)
  - [Microfrontends implementation and demo by Cam Jackson (Article)](https://microfrontends.com/)
  - [Micro Frontends - A microservice approach to the modern by Ivan Jovanovic (Video)](https://vimeo.com/372248526)
  - [Micro Frontends - How I Built An SPA With Angular And React? by Ivan Jovanovic (Article)](https://www.ivanjov.com/micro-frontends-how-i-built-a-spa-with-angular-and-react/)
  - [Micro Frontend Architecture by Luca Mezzalira, DAZN (Video)](https://www.youtube.com/watch?v=BuRB3djraeM)
  - [Micro-frontends, the future of Frontend architectures by Luca Mezzalira, DAZN (Article)](https://medium.com/dazn-tech/micro-frontends-the-future-of-frontend-architectures-5867ceded39a)
  - [Building serverless micro frontends at the edge at AWS re:Invent 2019 (Video)(Advanced)](https://youtube.com/watch?v=fT-5RHTtFNgs)
