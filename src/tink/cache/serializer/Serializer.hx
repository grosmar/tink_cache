package tink.cache.serializer;

typedef Serializer<K,V> =
{
	function serializeKey(key:K):String;

	function serializeValue(key:V):String;

	function parseKey(key:String):K;

	function parseValue(value:String):V;
}