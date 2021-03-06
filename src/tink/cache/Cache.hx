package tink.cache;
import tink.cache.serializer.JsonSerializer;
import tink.cache.store.MemoryStore;
import tink.cache.store.TTLStore;
import tink.cache.store.MasterSlaveStore;
#if js
import tink.cache.store.LocalStore;
import tink.cache.store.LocalTTLStore;
#end
import tink.cache.store.CacheStore;
import tink.core.*;

class Cache
{

	#if js
	public static function memoryAndLocalCache<In,Out>( f:In->Promise<Out>, memoryTtl:Int, localTtl:Int, localStorePrefix:String, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):In->Promise<Out>
	{
		return cache( memoryAndLocalStore( memoryTtl, localTtl, localStorePrefix, memoryInvalidateInterval, localInvalidateInterval ),
					  f );
	}


	public static function memoryAndLocalStore<In,Out>( memoryTtl:Int, localTtl:Int, localStorePrefix:String, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):MasterSlaveStore<In,Out>
	{
		return new MasterSlaveStore( new TTLStore( new MemoryStore(), memoryTtl, memoryInvalidateInterval ),
									 new LocalTTLStore( new LocalStore( new JsonSerializer(), localStorePrefix ), localTtl, localStorePrefix, localInvalidateInterval, new JsonSerializer() ) );
	}
	#end

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
			return store.get(i)
			.next( function (v)
			{
				return v;
			})
			.tryRecover( function(_)
			{
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