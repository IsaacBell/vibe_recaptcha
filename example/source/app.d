import std.stdio;
import recaptcha;

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	res.render!("index.dt", req);
	req.params["recaptcha_challenge_field"] = '';
	req.params["recaptcha_response_field"] = '';
}
void post(HTTPServerRequest req, HTTPServerResponse res)
{

}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", &index);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;

	listenHTTP(settings, router);
}