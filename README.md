# Flatten Dependencies
Moves node dependencies up the tree to prevent long paths.  
On Windows the path limit is 260 chars, which can be a big problem for larger projects.

## Installation
``` bash
npm install -g flatten-deps
```

## Usage
``` bash
cd PROJECT_ROOT
flatten-deps
```

## TODO
 - Tests
 - Expose function programmatically
