# tink_cache
[![Build Status](https://travis-ci.org/grosmar/tink_cache.svg?branch=master)](https://travis-ci.org/grosmar/tink_cache.svg?branch=master)

Haxe caching based on tink_promise
It wraps the original Promise with the same signature while it implements some caching logic inside itself.

# Install
- `lix install gh:grosmar/tink_cache`
- add to your build.hxml: `-lib tink_cache`

# Usage
Simple ttl caching:
```haxe
// myPromiseFunc: your function that can provide any promise
// 5000: ttl
ttlCache(myPromiseFunc, 5000 );
```

You can compose freely any cache storege, see cache function
```haxe
cache(new MyOwnStore(), myPromiseFunc);
```
... To be continued ...