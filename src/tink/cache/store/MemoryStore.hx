package tink.cache.store;
import tink.core.Promise;
import tink.cache.util.HashMap;
using tink.CoreApi;

//typedef MemoryStore<K,V> = HashMap<K,V>;

class MemoryStore<K,V>
{
	var store:HashMap<K,Promise<V>>;

	public function new()
	{
		store = new HashMap();
	}

	public function set(key:K, value:Promise<V>):Void
	{
		store.set(key, value);
	}

	public function get(key:K):Promise<V>
	{
		return store.exists(key) ? store.get(key) : Failure(null);
	}

	public function keys():Iterator<K>
	{
		return store.keys();
	}

	public function remove(key:K):Null<Promise<V>>
	{
		return store.remove(key);
	}
}