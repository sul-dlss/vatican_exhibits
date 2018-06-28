[![Build Status](https://travis-ci.org/sul-dlss/vatican_exhibits.svg?branch=master)](https://travis-ci.org/sul-dlss/vatican_exhibits)

## Vatican Exhibits

Spotlight-based discovery application for the Vatican Library built by the Stanford Libraries. Built using:

* [Spotlight](https://github.com/projectblacklight/spotlight)
* [Mirador](https://github.com/projectmirador)


## Requirements

1. Ruby (2.3.0 or greater)
2. [bundler](http://bundler.io/) gem
3. Java (7 or greater) *for Solr*
4. ImageMagick (http://www.imagemagick.org/script/index.php) due to [carrierwave](https://github.com/carrierwaveuploader/carrierwave#adding-versions)

## Installation

```
# Clone repository
$ git clone git@github.com:sul-dlss/vatican_exhibits.git
```

Move into the app and install dependencies

    $ cd vatican_exhibits
    $ bundle install

Start the development server

    $ rails s


Additional information about [deploying the application for Centos 7](https://github.com/sul-dlss/vatican_exhibits/wiki/Installing-Spotlight-for-Centos-7) is available on the project wiki.


## Configuring

Configuration is handled through the [RailsConfig](/railsconfig/config) `settings.yml` files.

#### Local Configuration

The defaults in `config/settings.yml` should work on a locally run installation.

### Running tests

#### Running continuous integration tests
```
$ rake
```

### Running application
```
$ solr_wrapper &
$ rails s
```
