---
layout: post
title: "Emberjs and Highcharts"
date: 2014-03-16 15:13
comments: true
categories: [EmberJs, Highcharts]
---

Let's write a reusable ember view for rendering graphs and charts powered by [highcharts](http://highcharts.com).


```coffeescript
  App.HighChartsView = Ember.View.extend
    tagName: 'div'
    classNames: [ 'highcharts' ]
    chartConfig = {}

    setConfig: (type)->
      config = {
        chart:
          type: type
        title:
          text: @title || 'Highcharts'
        xAxis:
          categories: @dataset.categories || []
        yAxis:
            title:
              text: @yAxisTitle
        series: @series()
      }
      # Merge highcharts config if it is present
      Ember.merge(config, @highChartConfig) if @highChartConfig
      @set('chartConfig', config)

    series: ->
      @dataset.data

    prepareConfig: ->
      # if custom config is present then directly set it to chartConfig
      if @customHighChartConfig
        @set('chartConfig', @customHighChartConfig)
      else
        type = @type || 'line'
        @setConfig(type)

    didInsertElement: ->
      @prepareConfig()
      @renderHighchart()

    renderHighchart: ->
      @$().highcharts(@chartConfig)
```

Usage:

{% raw %}
```
  {{ view App.HighChartsView dataset=dataset title="Sample Analytics" type="line" yAxisTitle="Temperature C" }}
```
{% endraw %}

The dataset can be set at controller or may be at route.

```coffeescript
  App.IndexController = Ember.ArrayController.extend
    dataset: {
      categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun','Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      data: [{
                name: 'Tokyo',
                data: [7.0, 6.9, 9.5, 14.5, 18.2, 21.5, 25.2, 26.5, 23.3, 18.3, 13.9, 9.6]
            }, {
                name: 'New York',
                data: [-0.2, 0.8, 5.7, 11.3, 17.0, 22.0, 24.8, 24.1, 20.1, 14.1, 8.6, 2.5]
            }, {
                name: 'Berlin',
                data: [-0.9, 0.6, 3.5, 8.4, 13.5, 17.0, 18.6, 17.9, 14.3, 9.0, 3.9, 1.0]
            }, {
                name: 'London',
                data: [3.9, 4.2, 5.7, 8.5, 11.9, 15.2, 17.0, 16.6, 14.2, 10.3, 6.6, 4.8]
            }]
      }
```

Usage with control over config

{% raw %}
```
  {{ view App.HighChartsView dataset=dataset highChartConfig=highChartConfig title="Sample Analytics" type="line" }}
```
{% endraw %}

```coffeescript
  App.IndexController = Ember.ArrayController.extend
    highChartConfig: {
      yAxis: {
        title: {
            text: 'Temperature (°C)'
        },
        plotLines: [{
            value: 0,
            width: 1,
            color: '#808080'
        }]
      },
      tooltip: {
          valueSuffix: '°C'
        }
      }
```
