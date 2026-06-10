/**
 * Welcome to Cloudflare Workers! This is your first worker.
 *
 * - Run `npm run dev` in your terminal to start a development server
 * - Open a browser tab at http://localhost:8787/ to see your worker in action
 * - Run `npm run deploy` to publish your worker
 *
 * Bind resources to your worker in `wrangler.jsonc`. After adding bindings, a type definition for the
 * `Env` object can be regenerated with `npm run cf-typegen`.
 *
 * Learn more at https://developers.cloudflare.com/workers/
 */

/// <reference types="@cloudflare/workers-types" />

interface Env {
	OPENAI_API_KEY: string;
}

// Request limits so malformed or oversized payloads are rejected
// before they reach OpenAI
const ALLOWED_ROLES = ["system", "user", "assistant"];
const MAX_MESSAGES = 50;
const MAX_CONTENT_LENGTH = 8000;

export default {
	async fetch(request: Request, env: Env): Promise<Response> {
	  try {
		// Allow only POST requests
		if (request.method !== "POST") {
		  return new Response(
			JSON.stringify({ error: "Use a POST request." }),
			{ status: 405, headers: { "Content-Type": "application/json" } }
		  );
		}
  
	// Parse incoming request
	let requestData: any;
	try {
  		requestData = await request.json();
	} catch (error: unknown) {
  		console.error('JSON parsing error:', error);
  		return new Response(JSON.stringify({ error: "Invalid JSON format." }),
		{ status: 400, headers: { "Content-Type": "application/json" } }
  		);
	}

	// Validate request body
	if (!requestData.messages || !Array.isArray(requestData.messages)) {
		  return new Response(
			JSON.stringify({ error: "Invalid request format. 'messages' must be an array." }),
			{ status: 400, headers: { "Content-Type": "application/json" } }
		  );
		}

	// Validate message contents before forwarding anything to OpenAI
	if (requestData.messages.length === 0 || requestData.messages.length > MAX_MESSAGES) {
		  return new Response(
			JSON.stringify({ error: `'messages' must contain between 1 and ${MAX_MESSAGES} entries.` }),
			{ status: 400, headers: { "Content-Type": "application/json" } }
		  );
		}
	for (const message of requestData.messages) {
		  if (!message || typeof message !== "object" ||
			  !ALLOWED_ROLES.includes(message.role) ||
			  typeof message.content !== "string" ||
			  message.content.length === 0 ||
			  message.content.length > MAX_CONTENT_LENGTH) {
			return new Response(
			  JSON.stringify({ error: `Each message needs a role (${ALLOWED_ROLES.join(", ")}) and a non-empty string content of at most ${MAX_CONTENT_LENGTH} characters.` }),
			  { status: 400, headers: { "Content-Type": "application/json" } }
			);
		  }
		}

		// Send request to OpenAI API
		const response = await fetch("https://api.openai.com/v1/chat/completions", {
		  method: "POST",
		  headers: {
			"Content-Type": "application/json",
			"Authorization": `Bearer ${env.OPENAI_API_KEY}`
		  },
		  body: JSON.stringify({
			model: "gpt-3.5-turbo",
			messages: requestData.messages.map((message: { role: string; content: string }) => ({
			  role: message.role,
			  content: message.content
			}))
		  })
		});

		if (!response.ok) {
		  // Log the upstream detail server-side; don't echo it to the client
		  console.error('OpenAI API error:', response.status, await response.text());
		  return new Response(
			JSON.stringify({ error: "Upstream API error." }),
			{ status: 502, headers: { "Content-Type": "application/json" } }
		  );
		}
  
		// Return OpenAI's response as JSON
		const openAiData = await response.json();
		return new Response(JSON.stringify(openAiData), {
		  status: 200,
		  headers: { "Content-Type": "application/json" }
		});
	  } catch (error: unknown) {
		// Log the detail server-side; don't echo internals to the client
		console.error('Server error:', error);
		return new Response(
		  JSON.stringify({ error: "Internal Server Error" }),
		  { status: 500, headers: { "Content-Type": "application/json" } }
		);
	  }
	}
};
  
