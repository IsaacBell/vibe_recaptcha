module recaptcha.connection;

import std.string;
import std.exception;
import vibe.http.client;
import vibe.data.json;
import vibe.stream.operations;

const string API_URL         = "http://www.google.com/recaptcha/api";
const string API_SECURE_URL  = "https://www.google.com/recaptcha/api";
const string VERIFY_URL      = "http://www.google.com/recaptcha/api/verify";

/**
 * An exception type to distinguish exceptions thrown by this module.
 */
class RecaptchaException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) pure{
    super(msg, file, line);
  }
}
alias RecaptchaException RCX;

/**
 * Generate HTML for reCAPTCHA
 */
string recaptchaHTML(string publicKey, bool useSSL = false){
	string html;
	string server;

	enforceEx!RCX(publicKey, "Tried to use a null publicKey parameter.");
	enforceEx!RCX(publicKey != "", "Tried to enter an empty publicKey parameter.");

	if (useSSL == true)
		server = API_SECURE_URL;
	else
		server = API_URL;
	html = r"<script type='text/javascript' src='" ~ server ~ r"/challenge?k=" ~ publicKey ~ "'></script>";
	html ~= r"<noscript><iframe src='" ~ server ~ r"/noscript?k=" ~ publicKey ~ r"' height='300' width='500' frameborder='0'></iframe><br/>";
  html ~= r"<textarea name='recaptcha_challenge_field' rows='3' cols='40'></textarea>";
  html ~= r"<input type='hidden' name='recaptcha_response_field' value='manual_challenge'/>";
	html ~= r"</noscript>";
	return html;
}

/**
 * Check whether the answers entered by the users are correct
 */
string verifyRecaptcha(string privateKey, string ip, string challenge, string response, bool test = false) {
	bool successful;
	string[] apiResponse;
	string error;
	
	enforceEx!RCX(privateKey, "Tried to use a null private key parameter.");
	enforceEx!RCX(privateKey != "", "Tried to enter an empty privateKey parameter.");
	enforceEx!RCX(ip, "Tried to use a null remote IP parameter.");
	enforceEx!RCX(ip != "", "Tried to enter an empty remote IP parameter.");
	enforceEx!RCX(challenge, "Tried to use a null challenge parameter.");
	enforceEx!RCX(challenge != "", "Entered an empty challenge parameter.");
	enforceEx!RCX(response, "Tried to use a null response parameter.");
	enforceEx!RCX(response != "", "Entered an empty response parameter.");

	successful = false;

	requestHTTP(VERIFY_URL, 
		(scope req) {
			string requestBody = "privatekey=%s&remoteip=%s&challenge=%s&response=%s",
				privateKey, ip, challenge, response;
			req.method = HTTPMethod.POST;
			//req.port = 80;
			req.headers["Content Type"] = "application/x-www-form-urlencoded";
			req.contentType = "application/x-www-form-urlencoded";
			req.headers["Content-Length"] = to!string(requestBody.length);
			req.headers["Host"] = "www.google.com:80";
			req.headers["Accept-Charset"] = "utf-8";
			//req.headers["User-agent"] = "reCAPTCHA ";
			req.writeBody(cast(ubyte[]) requestBody, "utf-8");
		},

		(scope res) {
			apiResponse = splitLines( res.bodyReader.readAllUTF8() );
			if ( cast(string) apiResponse[0] == cast(string) "true" )
				successful = true;
			else
				error = apiResponse[1];
		}
	);

	if (successful)
		return "true";
	else
		return error;
}
