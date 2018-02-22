package tink.cache.store;

import tink.CoreApi.OutcomeTools;
import tink.core.Promise;

class MasterSlaveStore<K,V>
{
	@:isVar public var masterStore(get, never):CacheStore<K,V>;
	function get_masterStore() return _masterStore;
	var _masterStore:CacheStore<K,V>;

	@:isVar public var slaveStore(get, never):CacheStore<K,V>;
	function get_slaveStore() return _slaveStore;
	var _slaveStore:CacheStore<K,V>;

	public function new(masterStore:CacheStore<K,V>, slaveStore:CacheStore<K,V>)
	{
		this._masterStore = masterStore;
		this._slaveStore = slaveStore;
	}

	public function set(key:K, value:Promise<V>):Void
	{
		_masterStore.set(key, value);
		_slaveStore.set(key, value);
	}

	public function get(key:K):Null<Promise<V>>
	{
		return _masterStore.get(key)
		.tryRecover( function(_)
			{
				return _slaveStore.get(key)
				.next( function( value:V)
					  {
						  _masterStore.set(key, value);
						  return value;
					  });
			});
	}

	public function keys():Iterator<K>
	{
		return _slaveStore.keys();
	}

	public function remove(key:K):Null<Promise<V>>
	{
		_masterStore.remove(key);
		return _slaveStore.remove(key);
	}
}