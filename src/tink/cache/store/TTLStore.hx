package tink.cache.store;
import tink.core.Promise;
import tink.util.HashMap;
import haxe.Timer;
class TTLStore<K,V>
{
	var ttl:Int;
	var timer:Timer;
	var store:CacheStore<K,V>;

	var ttlStore:HashMap<K, Float> = new HashMap();

	public function new(store:CacheStore<K,V>, ttl:Int, ?invalidateInterval:Int)
	{
		this.ttl = ttl;
		this.store = store;
		invalidateInterval = invalidateInterval == null ? ttl : invalidateInterval;

		this.timer = new Timer(invalidateInterval);
		this.timer.run = this.invalidate;
	}

	public function get(key:K):Null<Promise<V>>
		return ttlStore.get(key) > Date.now().getTime() - ttl ? store.get(key) : null;

	public function set(key:K, value:Promise<V>):Void
	{
		store.set(key, value);
		ttlStore.set(key, Date.now().getTime() );
	}

	public function keys():Iterator<K>
		return store.keys();


	public function remove(key:K):Null<Promise<V>>
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