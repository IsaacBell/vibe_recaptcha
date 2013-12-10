import std.string;
import vibe.d;
import recaptcha;

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	string recaptcha = recaptchaHTML("public key here");
	res.renderCompat!("index.dt",
		HTTPServerRequest, "req",
		string, "recaptcha")
		(req, recaptcha);
}

void success(HTTPServerRequest req, HTTPServerResponse res)
{
	res.renderCompat!("success.dt",
		HTTPServerRequest, "req")
		(req);
}

void verify(HTTPServerRequest req, HTTPServerResponse res)
{
	string challenge = req.form["recaptcha_challenge_field"];
	string response = req.form["recaptcha_response_field"];
	if ( verifyRecaptcha("private key here", req.peer, challenge, response) )
		res.redirect("/success");
	else
		// Return to URL submitted in form
		res.redirect(req.form["referer"]);
}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", &index)
				.post("/verify", &verify)
				.get("/success", &success);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["127.0.0.1"];

	listenHTTP(settings, router);
}