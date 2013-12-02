import std.string;
import vibe.d;
import recaptcha.connection;

void index(HTTPServerRequest req, HTTPServerResponse res)
{
	string recaptcha = recaptchaHTML("6LeeAuYSAAAAALGaqWmBdksMF-BMUpjT5izJ6Fu6");
	res.renderCompat!("index.dt",
		HTTPServerRequest, "req",
		string, "recaptcha")
		(req, recaptcha);
}

void verify(HTTPServerRequest req, HTTPServerResponse res)
{
	string challenge = req.form["recaptcha_challenge_field"];
	string response = req.form["recaptcha_response_field"];
	if ( verifyRecaptcha("6LeeAuYSAAAAAKDVlne-rXCFPNdLh4GWN-GKBSYg", req.peer, challenge, response) == "true" )
		res.redirect("/");
	else
		//res.redirect(req.form["referer"]);
		res.writeBody(cast(ubyte[]) "Not quite.", "text/plain");
	logInfo("Challenge: %s", req.form["recaptcha_challenge_field"]);
	logInfo("Response: %s", req.form["recaptcha_response_field"]);
	logInfo("IP: %s", req.peer);
	logInfo("Recaptcha Response: %s", verifyRecaptcha("6LeeAuYSAAAAAKDVlne-rXCFPNdLh4GWN-GKBSYg", req.peer, challenge, response));
}

shared static this()
{
	auto router = new URLRouter;
	router.get("/", &index);
	router.post("/verify", &verify);

	auto settings = new HTTPServerSettings;
	settings.port = 8080;
	settings.bindAddresses = ["127.0.0.1"];

	listenHTTP(settings, router);
}