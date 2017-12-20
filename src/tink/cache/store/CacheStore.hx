package tink.cache.store;

import tink.core.Promise;
typedef CacheStore<K, V> =
{
	function get(key:K):Promise<V>;

	function set(key:K, value:Promise<V>):Void;

	function keys():Iterator<K>;

	function remove(key:K):Null<Promise<V>>;
}