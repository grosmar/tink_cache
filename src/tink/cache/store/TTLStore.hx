package tink.cache.store;
import tink.cache.util.HashMap;
import haxe.Timer;
class TTLStore<K,V>
{
	var ttl:Int;
	var timer:Timer;
	var store:CacheStore<K,V>;

	var ttlStore:HashMap<K, Float> = new HashMap();

	public function new(store:CacheStore<K,V>, ttlSec:Int, invalidateInterval:Int)
	{
		this.ttl = ttlSec;
		this.store = store;

		this.timer = new Timer(invalidateInterval);
		this.timer.run = this.invalidate;
	}

	public function get(key:K):Null<V>
	return ttlStore.get(key) > Date.now().getTime() - ttl ? store.get(key) : null;

	public function set(key:K, value:V):Void
	{
		store.set(key, value);
		ttlStore.set(key, Date.now().getTime() );
	}

	public function keys():Iterator<K>
	return store.keys();

	public function exists(key:K):Bool
	{
		return store.exists(key) && ttlStore.get(key) >= Date.now().getTime() - ttl;
	}


	public function remove(key:K):Null<V>
	{
		ttlStore.remove(key);
		return store.remove(key);
	}

	public function invalidate()
	{
		var nowWithDiff = Date.now().getTime() - ttl;
		for ( key in ttlStore.keys( ) )
		{
			if ( ttlStore.get(key) < nowWithDiff )
			{
				store.remove(key);
			}
		}
	}
}