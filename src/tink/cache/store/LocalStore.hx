package tink.cache.store;
#if js
import tink.cache.serializer.Serializer;
import tink.core.Promise;
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

	public function set(key:K, value:Promise<V>):Void
	{
		value.handle(function (o)
					 {
						 switch (o)
						 {
							 case Success(v): store.setItem(serializer.serializeKey(key), serializer.serializeValue(v));
							 default:
						 }
					 });
	}

	public function get(key:K):Null<Promise<V>>
	{
		return serializer.parseValue(store.getItem(serializer.serializeKey(key)));
	}

	public function keys():Iterator<K>
	{
		return [for (i in 0...store.length) serializer.parseKey(store.getItem(store.key(i)))].iterator();
	}

	public function remove(key:K):Null<Promise<V>>
	{
		var item = serializer.parseValue(store.getItem(serializer.serializeKey(key)));

		store.removeItem(serializer.serializeKey(key));
		return item;
	}
}
#end

/*

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
class PromiseHandlerStore<K,V>
{
	var store:CacheStore<K, V>;

	public function new(store:CacheStore<K, Dynamic>)
	{
		this.store = store;
	}

	public function set(key:K, value:Promise<V>):Void
	{
		value.handle( function (o) switch(o)
		{
			case Success(v): store.set(key, v);
			default:
		});
	}

	public function get(key:K):Null<Promise<V>>
	{
		return store.get(key);
	}

	public function keys():Iterator<K>
	{
		return store.keys();
	}

	public function exists(key:Promise<V>):Bool
	{
		return store.exists(key);
	}

	public function remove(key:K):Null<V>
	{
		return store.remove(key);
	}
}*/

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

/*abstract Serializable(String) to String from String
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

}*/

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