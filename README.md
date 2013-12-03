<h1>Vibe reCAPTCHA</h1>
<!-- <p>===============================</p> -->

<p>Implement Google's reCaptcha service in Vibe.d.</p>
<br>

<h1>Before You Get Started</h1>
<!-- <p>===============================</p> -->
<p>You'll need to sign up for <a href="https://www.google.com/recaptcha/admin/create">API Keys</a> before you can use reCaptcha</p>

<h1>Installation</h1>
<!-- <p>===============================</p> -->
<p>To install, add vibe_recaptcha to your package.json file:</p>
<pre>
	"dependencies": {
		"vibe_d":"~master",
		"vibe_recaptcha":"~master"
	}
</pre>

<h1>Displaying the CAPTCHA image</h1>
<!-- <p>===============================</p> -->
<p>The CAPTCHA image can be generated in two ways:</p>
<p>1. Call function recaptchaHTML in your app.d file, then render in your view:</p>

<h3>app.d</h3>
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
<h3>index.dt</h3>
<pre>
form(action='/verify',method='post')
	// Your form fields here
	!= recaptcha
	input(type='submit')
</pre>

<p>2. Or, you can call the function directly within your view:</p>
<h3>index.dt</h3>
<pre>
form(action='/verify',method='post')
	// Your form fields here
	!= recaptchaHTML("your public key")
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
	if ( verifyRecaptcha("6Lf4JusSAAAAAIgeySdOHz12KfbyWicztJvyG-Yt", req.peer, challenge, response) )
		// Handle the success response
		res.redirect("/success");
	else
		// Handle the failure response
		res.writeBody(cast(ubyte[]) "Not quite.", "text/plain");
}
</pre>