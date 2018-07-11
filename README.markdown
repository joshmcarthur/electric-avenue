Electric Avenue
====

[![Build Status](https://travis-ci.org/joshmcarthur/electric-avenue.png)](https://travis-ci.org/joshmcarthur/electric-avenue)

> Electric Avenue is a queue-based encoding web service that uses [ffmpeg](http://ffmpeg.org) to transcode and manipulate a range of video and audio formats. 

---

#### Background


There are a range of online services to encode video, mostly well-architected, easy to use and that support a range of video formats. The problem with many of these services is that they are not truly open and distributable - they require users to either run on an exacting infrastructure (for example Amazon EC2 with S3, SQS, etc.), or to use the organization's servers only.

I wanted to develop a flexible service that provided similar functionality, but could be cloned, adjusted, and deployed anywhere to encode video. It can form part of a wider system, or be used standalone. In short, it's completely free for you to use as you want.

#### Installation

There are three main components that need to be installed to run the application - [Node.js](http://nodejs.org) and the Node Package Manager ([NPM](http://npmjs.org/)), [Redis](http://redis.io), and [ffmpeg](http://ffmpeg.org).

* Node.js can be installed from [http://nodejs.org/#download](http://nodejs.org/#download) - it's available for Windows, OS X and Linux
* NPM can be installed by executing `curl http://npmjs.org/install.sh | sh` in a Terminal (I've always had to change permissions in `/usr/local/npm`, but hopefully it'll work for you)
* Redis installation is easy for OS X and Ubuntu/Debian:
  * OS X: `brew install redis`
  * Ubuntu: `sudo apt-get install redis`
  * Windows: [Unsupported native build of Redis for win32](https://github.com/dmajkic/redis/)
* ffmpeg installation varies from platform to platform. It's important to install several codec packages, and the ones you need to install depend on what video/audio formats you are planning to use.
  * OS X: The easiest way to install is via [Homebrew](https://github.com/mxcl/homebrew): `brew install ffmpeg --use-clang`. It may not install all the codecs you need, though.
  * Linux: Running `sudo apt-get install ffmpeg` should install ffmpeg and a range of common codecs, but, once again, you might need a couple more.
  * Windows: Look's like [here](http://ffmpeg.zeranoe.com/builds/) is a good place to start, but I've no idea whether it installs all you need.


Once you've got these components installed, actually running the app is pretty simple:

```
  git clone git@github.com:joshmcarthur/electric-avenue.git
```

```
  cd electric-avenue && npm install
```


You can then run `node server.js` and browse to [http://localhost:4000](http://localhost:4000) to start encoding! (Make sure you've started Redis first though!)

#### Running Tests

Tests are written using [Jasmine](https://jasmine.github.io/) and [Zombie.js](http://zombie.labnotes.org/), and can be run in one of two ways:

* `cake spec` - will run the tests, but won't output as verbosely
* `jasmine-node --coffee spec/` will run the tests, and also output a few more error messages, and the like. 



#### Caveats

I'm not supporting Internet Explorer right now. Electric Avenue uses a bunch of quite modern concepts, including Twitter Bootstrap, which looks pretty rubbish in IE anyway, XMLHTTPRequest2, etc.

I've written some automated tests using Jasmine, but test coverage is not 100%. This is something I plan to improve on in the future.

#### License

Copyright (c) 2012 Joshua McArthur

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
