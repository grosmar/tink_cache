package tink.cache.store;

import tink.core.Promise;

class MasterSlaveStore<K,V>
{
	var masterStore:CacheStore<K,V>;
	var slaveStore:CacheStore<K,V>;

	public function new(masterStore:CacheStore<K,V>, slaveStore:CacheStore<K,V>)
	{
		this.masterStore = masterStore;
		this.slaveStore = slaveStore;
	}

	public function set(key:K, value:Promise<V>):Void
	{
		masterStore.set(key, value);
		slaveStore.set(key, value);
	}

	public function get(key:K):Null<Promise<V>>
	{
		var value = masterStore.get(key);
		if ( value == null )
		{
			value = slaveStore.get(key);
			if ( value != null )
				masterStore.set(key, value);
		}
		return value;
	}

	public function keys():Iterator<K>
	{
		return slaveStore.keys();
	}

	public function remove(key:K):Null<Promise<V>>
	{
		masterStore.remove(key);
		return slaveStore.remove(key);
	}
}