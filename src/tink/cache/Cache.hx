package tink.cache;
import tink.cache.store.MemoryStore;
import tink.cache.store.TTLStore;
import tink.cache.store.CacheStore;
import tink.core.*;

class Cache
{

	public static function ttlCache<In,Out>(?store:CacheStore<In, Promise<Out>>, f:In->Promise<Out>, ttl:Int, ?invalidateInterval:Int ):In->Promise<Out>
	{
		var ttlStore = new TTLStore(store != null ? store : new MemoryStore<In,Promise<Out>>(), ttl, invalidateInterval);
		return cache(ttlStore, f);
	}

	public static function infiniteCache<In,Out>(f:In->Promise<Out>):In->Promise<Out>
	{
		return cache(new MemoryStore<In,Promise<Out>>(), f);
	}

	public static function cache<In,Out>(store:CacheStore<In,Promise<Out>>, f:In->Promise<Out>):In->Promise<Out>
	{
		return function (i:In):Promise<Out>
		{
			if (store.exists(i))
				return store.get(i);

			var ret = f(i);

			ret.handle( function(o)
				switch (o)
				{
					case Failure(_): store.remove(i);
					default:
				}
			);

			store.set(i, ret);
			return ret;
		}
	}
}