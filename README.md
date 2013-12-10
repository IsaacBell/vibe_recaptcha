<h1>Vibe reCAPTCHA</h1>
<!-- <p>===============================</p> -->
<p>Implement Google's reCaptcha service in Vibe.d.</p>

<h1>Before You Get Started</h1>
<!-- <p>===============================</p> -->
<p>You'll need to sign up for <a href="https://www.google.com/recaptcha/admin/create">API Keys</a> before you can use reCaptcha</p>

<h1>Installation</h1>
<!-- <p>===============================</p> -->
<p>To install, add vibe_recaptcha to your package.json file:</p>
<pre>
	"dependencies": {
		"vibe-d":">=0.7.18",
		"vibe_recaptcha":">=1.0"
	}
</pre>

<p>Import the module in your app.d file:</p>
<pre>
	import recaptcha;
</pre>

<h1>Displaying the CAPTCHA image</h1>
<!-- <p>===============================</p> -->
<p>The CAPTCHA image is generated in two steps</p>
<p>1. Call function recaptchaHTML(string publickey) in your app.d file, and make it visible to your view:</p>

<h2>app.d</h2>
<pre>
void index(HTTPServerRequest req, HTTPServerResponse res)
{
	string recaptcha = recaptchaHTML("your public key");
	res.renderCompat!("index.dt",
		HTTPServerRequest, "req",
		string, "recaptcha")
		(req, recaptcha);
}
</pre>
<p>2. From there, render the variable from within your view:</p>
<h2>index.dt</h2>
<pre>
form(action='/verify',method='post')
	// Your form fields here
	!= recaptcha
	input(type='submit')
</pre>

<h1>Verifying the Solution</h1>
<!-- <p>===============================</p> -->
<p>Check the response with verifyRecaptcha(string privateKey, string ip, string challenge, string response)</p>
<pre>
void verify(HTTPServerRequest req, HTTPServerResponse res)
{
	string challenge = req.form["recaptcha_challenge_field"];
	string response = req.form["recaptcha_response_field"];
	if ( verifyRecaptcha("private key", req.peer, challenge, response) )
		// Handle the success response
		res.redirect("/success");
	else
		// Handle the failure response
		res.writeBody(cast(ubyte[]) "Failure.", "text/plain");
}
</pre>

<h1>Test API Keys</h1>
<!-- <p>===============================</p> -->
<p>To check for errors during verification, call function testRecaptcha instead of verifyRecaptcha to see the response from reCAPTCHA when a response is inputted:</p>
<pre>
// import vibe.core.log
void verify(HTTPServerRequest req, HTTPServerResponse res)
{
	string challenge = req.form["recaptcha_challenge_field"];
	string response = req.form["recaptcha_response_field"];

	// Returns either "true" or an error message
	string recaptchaMessage = testRecaptcha("private key", req.peer, challenge, response);
	logInfo("Recaptcha's Response: %s", recaptchaMessage);
}
</pre>