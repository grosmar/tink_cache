# tink_cache
Haxe caching based on tink_promise
It wraps the original Promise with the same signature while it implements some caching logic inside itself.

# Prerequirements
- [lix](https://github.com/lix-pm/lix.client)

# Install
`lix install gh:grosmar/tink_cache`

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