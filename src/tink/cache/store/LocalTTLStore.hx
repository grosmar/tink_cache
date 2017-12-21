package tink.cache.store;
import tink.cache.serializer.Serializer;
import tink.core.Promise;
import haxe.Timer;
using tink.CoreApi;
import js.html.Storage;

class LocalTTLStore<K,V>
{
	var ttl:Int;
	var timer:Timer;
	var store:CacheStore<K,V>;
	var serializer:Serializer<K,V>;

	var ttlStore:Storage;

	public function new(store:CacheStore<K,V>, ttl:Int, ?invalidateInterval:Int, serializer:Serializer<K,V>)
	{
		this.ttl = ttl;
		this.store = store;
		this.ttlStore = js.Browser.getLocalStorage();
		this.serializer = serializer;
		invalidateInterval = invalidateInterval == null ? ttl : invalidateInterval;

		this.timer = new Timer(invalidateInterval);
		this.timer.run = this.invalidate;
	}

	//TODO: add ttl also if it's persisted data
	public function get(key:K):Null<Promise<V>>
		return Std.parseFloat(ttlStore.getItem("ttl_" + serializer.serializeKey(key))) > Date.now().getTime() - ttl ? store.get(key) : Failure(null);

	public function set(key:K, value:Promise<V>):Void
	{
		store.set(key, value);
		ttlStore.setItem("ttl_" + serializer.serializeKey(key), Date.now().getTime() + "" );
	}

	public function keys():Iterator<K>
		return store.keys();


	public function remove(key:K):Null<Promise<V>>
	{
		ttlStore.removeItem("ttl_" + serializer.serializeKey(key));
		return store.remove(key);
	}

	public function invalidate()
	{
		var nowWithDiff = Date.now().getTime() - ttl;
		var l = ttlStore.length;
		for ( i in 0...l )
		{
			var key = ttlStore.key(i);
			if ( Std.parseFloat(ttlStore.getItem(key)) < nowWithDiff )
			{
				store.remove(serializer.parseKey(key.substr(4)));
				ttlStore.removeItem(key);
			}
		}
	}
}