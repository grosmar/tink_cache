package tink.cache.store;

typedef CacheStore<K, V> =
{
	function set(key:K, value:V):Void;

	function get(key:K):Null<V>;

	function keys():Iterator<K>;

	function exists(key:K):Bool;

	function remove(key:K):Null<V>;
}