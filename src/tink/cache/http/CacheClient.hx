package tink.cache.http;
import tink.core.Future;
import tink.core.Promise;
import tink.cache.Cache;
import tink.http.Response.IncomingResponse;
import tink.http.Request.OutgoingRequest;
import tink.cache.store.CacheStore;
import tink.http.Client;
import tink.http.Client.ClientObject;
import tink.http.Request;
import tink.http.Response;
using tink.CoreApi;


class CacheClient implements ClientObject
{
	var realClient:Client;
	var cacheStore:CacheStore<String, IncomingResponse>;

	//TODO: serialization won't work on permanent stores
	public function new(realClient:Client, cacheStore:CacheStore<String, IncomingResponse>)
	{
		this.realClient = realClient;
		this.cacheStore = cacheStore;
	}

	public function request(req:OutgoingRequest):Future<IncomingResponse>
	{
		return
			switch (req.header.method)
			{
				case GET | HEAD:
					trace( req.header.fields);
					var key = req.header.uri.toString();
					//var key = req.header.uri.toString();
					var value = cacheStore.get(key);

					switch (value)
					{
						case null:
							var res = realClient.request(req);
							cacheStore.set(key, res);

							res.handle(function (o) trace(o));
							res;
						case v:
							Future.async( function (handler)
										  {
											  v.handle( function (o)
														{
															switch (o)
															{
																case Success(result): handler(result);
																default: realClient.request(req);
															}

														});
										  });
					}
				default: realClient.request(req);
			}
	}
}

//class ResponseSerializer
