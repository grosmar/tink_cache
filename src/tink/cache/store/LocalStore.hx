package tink.cache.store;

import tink.core.Promise;
import tink.json.Representation;
import js.html.Storage;
class LocalStore<K,V>
{
	var store:Storage;
	var serializer:Serializer<K,V>;

	public function new(serializer:Serializer<K,V>)
	{
		this.serializer = serializer;
		store = js.Browser.getLocalStorage();
	}

	public function set(key:K, value:V):Void
	{
		store.setItem(serializer.serializeKey(key), serializer.serializeValue(value));
	}

	public function get(key:K):V
	{
		return serializer.parseValue(store.getItem(serializer.serializeKey(key)));
	}

	public function keys():Iterator<K>
	{
		return [for (i in 0...store.length) serializer.parseKey(store.getItem(store.key(i)))].iterator();
	}

	public function exists(key:K):Bool
	{
		return store.getItem(serializer.serializeKey(key)) != null;
	}

	public function remove(key:K):Null<V>
	{
		var item = serializer.parseValue(store.getItem(serializer.serializeKey(key)));

		store.removeItem(serializer.serializeKey(key));
		return item;
	}
}

abstract Serializable(String) to String from String
{
	public function new(v)
		this = v;

	@:from static function fromBool(v:Bool)
		return new Serializable(v ? "true" : "false");

	@:to function toBool()
		return this == "false" ? false : (this == null ? null : true);

	@:from static function fromFloat(v:Float)
		return new Serializable(v + "");

	@:to function toFloat()
		return Std.parseFloat(this);

	@:from static function fromObject(v:{})
		return new Serializable(Json.stringify(v));

	@:to function toObject():{}
		return haxe.Json.parse(this);

}

class PromiseHandlerStore<K,V:Promise<Dynamic>>
{
	var store:CacheStore<K, Dynamic>;

	public function new(store:CacheStore<K, Dynamic>)
	{
		this.store = store;
	}

	public function set(key:K, value:V):Void
	{
		value.handle( function (o) switch(o)
		{
			case Success(v): store.set(key, v);
			default:
		});
	}

	public function get(key:K):Null<V>
	{
		return store.get(key);
	}

	public function keys():Iterator<K>
	{
		return store.keys();
	}

	public function exists(key:K):Bool
	{
		return store.exists(key);
	}

	public function remove(key:K):Null<V>
	{
		return store.remove(key);
	}
}

//class JsonSerializer<K:Serializable, V>*/

/*
class JsonSerializer<K:{}, V:{}>
{
	public function new()
	{

	}

	public function serializeKey(key:K):String
	return "key";

	public function serializeValue(value:V):String
	return "value";

	public function parseKey(key:String):K
	return cast {};

	public function parseValue(value:String):V
	return cast {};
}
*/

class JsonSerializer<K:{}, V:{}>
{
	public function new()
	{}

	public function serializeKey(key:K):String
		return haxe.Json.stringify(key);

	public function serializeValue(value:V):String
		return haxe.Json.stringify(value);

	public function parseKey(key:String):K
		return haxe.Json.parse(key);

	public function parseValue(value:String):V
		return haxe.Json.parse(value);
}

typedef Serializer<K,V> =
{
	function serializeKey(key:K):String;

	function serializeValue(key:V):String;

	function parseKey(key:String):K;

	function parseValue(value:String):V;
}

/*class LocalStore<K:Serializable,V:Serializable>
{
	var store:Storage;
	var serializer:Serializer<K,V>;

	public function new(serializer:Serializer<K,V>)
	{
		this.serializer = serializer;
		store = js.Browser.getLocalStorage();
	}

	public function get(key:K):V
	{
		return (store.getItem(key));
	}

	public function set(key:K, value:V):Void
	{
		store.setItem((key:Serializable), (value:Serializable));
	}

	public function get(key:K):Null<V>
	{
		var a:Serializable = store.getItem(key);
		return (a);
	}

	public function keys():Iterator<K>
	{
		return [for (i in 0...store.length) (cast store.getItem(store.key(i)):K)].iterator();
	}

	public function exists(key:K):Bool
	{
		return store.getItem(key) != null;
	}

	public function remove(key:K):Null<V>
	{
		var item:Serializable = store.getItem(key);

		store.removeItem(key);
		return item;
	}
}*/