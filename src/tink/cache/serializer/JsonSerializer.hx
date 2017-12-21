package tink.cache.serializer;

class JsonSerializer<K, V>
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
