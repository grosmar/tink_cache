package tink.cache;
import tink.cache.serializer.JsonSerializer;
import tink.cache.store.MemoryStore;
import tink.cache.store.TTLStore;
import tink.cache.store.MasterSlaveStore;
#if js
import tink.cache.store.LocalStore;
#end
import tink.cache.store.CacheStore;
import tink.core.*;

class Cache
{

	#if js
	public static function memoryAndLocalCache<In,Out>( f:In->Promise<Out>, memoryTtl:Int, localTtl:Int, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):In->Promise<Out>
	{
		return cache( memoryAndLocalStore( memoryTtl, localTtl, memoryInvalidateInterval, localInvalidateInterval ),
					  f );
	}


	public static function memoryAndLocalStore<In,Out>( memoryTtl:Int, localTtl:Int, ?memoryInvalidateInterval:Int, ?localInvalidateInterval:Int ):MasterSlaveStore<In,Out>
	{
		return new MasterSlaveStore( new TTLStore( new MemoryStore(), memoryTtl, memoryInvalidateInterval ),
									 new TTLStore( new LocalStore( new JsonSerializer() ), localTtl, localInvalidateInterval ) );
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
			var storedValue:Promise<Out> = cast store.get(i);
			if (storedValue != null)
				return storedValue;

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