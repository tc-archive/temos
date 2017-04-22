
# Main Components

##### Modules

##### Componenets

-----

## SystemJS

### System.import()

The System.import() method immediately returns a Promise object.  The promise is resolved with a 
module object, The then() callback is invoked when the module is loaded. If the promise is
rejected, the errors are handled in the catch() method.

```
System.import('./module.js')        // import by file path
System.import('@angular2/core');    // import by logical name
```

```
System.config()
```

SystemJS uses tsc internally to transpile TypeScript to JavaScript on the fly as it loads a script file.


## Package Manager

npm, Bower, jspm, Jam, and Duo


