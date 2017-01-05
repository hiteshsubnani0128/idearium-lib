# idearium-lib

This document covers how to use the library, for information on how to publish a new version of the library to NPM, [read PUBLISHING.md](PUBLISHING.md).

idearium-lib provides [an API via classes](#api) and [some common uses of those classes](#common).

## Installation

```
npm install -S @idearium/idearium-lib
```

## Common

`idearium-lib` provides a bunch of files located at `@idearium/idearium-lib/common` which contain pre-instantiated versions of the libraries detailed below. They follow a standard pattern that all Idearium applications use and are essentially a quick start to getting up and running with common requirements of code:

- Connecting to RabbitMQ.
- Loading files from a directory.
- Loading configuration files (following Idearium's standard configuration file convention).
- Loading message files (following Idearium's standard message file convention).

### common/config

```
var config = require('@idearium/idearium-lib/common/config');
config.get('mqUrl');
```

`common/config` will load configuration files in the `config` directory located at the root of the Node.js application.

Files in the `config` directory can be used to provide information specific to environment (for example, a URL to connect to RabbitMQ or Redis).

Directory structure should be:

```
|- config
   |- config.json
   |- config.development.js
   |- config.production.js
```

`config.json` will always be loaded and must exist. This will contain the default properties for all environments.

Then create a file for each environment that matches `process.env.NODE_ENV`. For example `config.development.js` when `process.env.NODE_ENV === 'development'`. The JavaScript can do anything it requires but should export an `Object` of properties that may or may not overwrite values in `config.json`.

### common/mq/client

`common/mq/client` will create a connection to RabbitMQ assuming a configuration property `mqUrl` exists providing the URL in which to connect to RabbitMQ.

```
var mqClient = require('@idearium/idearium-lib/common/mq/client');
```

`common/mq/client` instantiates a class `Client` which extends `mq.Client`. You can close the connection to RabbitMQ with `require('@idearium/idearium-lib/common/mq/client').disconnect();`. You should configure this to occur when you Node.js application quits:

```
process.on('SIGTERM', function () {
    require('@idearium/idearium-lib/common/mq/client').disconnect();
});
```

### common/mq/messages

`common/mq/messages` will load files in the `messages` directory located at the root of the Node.js application. Files in the `messages` directory can be used to register RabbitMQ publish and consumer processes.

```
var mqMessages = require('@idearium/idearium-lib/common/mq/messages');
```

The name of the file will be the name of the message to use, when publishing a new message:

```
|- messages
   |- bounce-email.js
   |- unsubscribe-email.js
   |- spam-email.js
```

Within each file, you can export (`modules.export`) either a `publish` and/or `consume` function.

- `publish` function is used to publish a message to RabbitMQ.
- `consume` function is used to consume a message from RabbitMQ.

In each of the functions, you are required to utilise the supplied `channel` to create your exchange and queue for publishing or consuming messages. Refer to the [example](./examples/bounce-email.js).

To publish a message to RabbitMQ:

```
require('@idearium/idearium-lib/common/mq/messages').publish(messageName, data);
```

Will publish a message to RabbitMQ.

#### messageName

Is the name of the message and should match one of the file names within the `messages` directory.

#### data

An object which will be serialized to JSON and sent through RabbitMQ.

## API

```
let ideariumLib = require('@idearium/idearium-lib');
```

This provides access to:

```
ideariumLib.Config;
ideariumLib.Loader;
ideariumLib.mq.Client;
ideariumLib.mq.Manager;
```

### ideariumLib.Config(dir)

`ideariumLib.Config` will load config files (`.json` and `config.{process.env.NODE_ENV}.js`) from a provided directory.

```
let config = new ideariumLib.Config(path.resolve(__dirname, '..', 'config'));
config.get('mqUrl');
```

#### dir

An absolute path to a directory containing (`.js` and `.json`) configuration files.

### ideariumLib.mq.Client(url)

`ideariumLib.mq.Client` will connect to a running instance of RabbitMQ.

```
let ideariumMq = new ideariumLib.mq.Client('amqp://localhost:5672');
```

#### url

`ideariumLib.mq.Client` must be provided a URL pointing to a running instance of RabbitMQ.

### ideariumLib.Loader

`ideariumLib.Loader` will load all `.js` files from a provided directory.

```
let loader = new ideariumLib.Loader();
```

#### ideariumLib.Loader.camelCase

Defaults to `true`. Will load a file named `log-exception.js` as `logException`.

#### ideariumLib.Loader.classCase

Defaults to `false`. Will load a file named `log-exception.js` as `LogException`.

#### ideariumLib.Loader.load(dir)

Will load all files in the directory and return an Object, keyed by the file name (after manipulation). Automatically ignores any file named `index.js`.

```
let loader = new ideariumLib.Loader();

loader.classCase = true;

let classes loader.load('path/to/classes');
```

## Tests

To run tests `npm test`. The first time might take a little while as it will download a Docker image to run RabbitMQ.