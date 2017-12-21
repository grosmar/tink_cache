package tink.cache;
import tink.cache.store.LocalTTLStore;
import tink.cache.serializer.JsonSerializer;
import tink.cache.store.MemoryStore;
import tink.cache.store.TTLStore;
import tink.cache.store.MasterSlaveStore;
import tink.cache.store.LocalStore;
import tink.cache.store.CacheStore;
import tink.core.*;

class Cache
{

	public static function memoryAndLocalCache<In,Out>( f:In->Promise<Out>, memoryTtl:Int, localTtl:Int, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):In->Promise<Out>
	{
		return cache( memoryAndLocalStore( memoryTtl, localTtl, memoryInvalidateInterval, localInvalidateInterval ),
					  f );
	}

	public static function memoryAndLocalStore<In,Out>( memoryTtl:Int, localTtl:Int, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):MasterSlaveStore<In,Out>
	{
		return new MasterSlaveStore( new TTLStore( new MemoryStore(), memoryTtl, memoryInvalidateInterval ),
									 new LocalTTLStore( new LocalStore( new JsonSerializer() ), localTtl, localInvalidateInterval, new JsonSerializer() ) );
	}


	public static function ttlCache<In,Out>(?store:CacheStore<In, Out>, f:In->Promise<Out>, ttl:Int, ?invalidateInterval:Int ):In->Promise<Out>
	{
		var ttlStore = new TTLStore(store != null ? store : new MemoryStore<In,Out>(), ttl, invalidateInterval);
		return cache(ttlStore, f);
	}

	public static function infiniteCache<In,Out>(f:In->Promise<Out>):In->Promise<Out>
	{
		return cache(new MemoryStore<In,Out>(), f);
	}

	public static function cache<In,Out>(store:CacheStore<In,Out>, f:In->Promise<Out>):In->Promise<Out>
	{

		return function (i:In):Promise<Out>
		{
			trace("Request", i);
			return store.get(i)
			.next( function (v)
			{
				trace("RequestNEXT", i);
				return v;
			})
			.tryRecover( function(_)
			{
				trace("RequestTRY", i);
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
			});
		}
	}
}