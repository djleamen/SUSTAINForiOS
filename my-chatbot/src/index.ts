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

// export default {
// 	async fetch(request, env, ctx): Promise<Response> {
// 		return new Response('Hello World!');
// 	},
// } satisfies ExportedHandler<Env>;

export default {
	async fetch(request, env) {
	  try {
		// Allow only POST requests
		if (request.method !== "POST") {
		  return new Response(
			JSON.stringify({ error: "Use a POST request." }),
			{ status: 405, headers: { "Content-Type": "application/json" } }
		  );
		}
  
		// Parse incoming request
		let requestData;
		try {
		  requestData = await request.json();
		} catch (error) {
		  return new Response(
			JSON.stringify({ error: "Invalid JSON format." }),
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
  
		// Send request to OpenAI API
		const response = await fetch("https://api.openai.com/v1/chat/completions", {
		  method: "POST",
		  headers: {
			"Content-Type": "application/json",
			"Authorization": `Bearer ${env.OPENAI_API_KEY}`
		  },
		  body: JSON.stringify({ model: "gpt-3.5-turbo", messages: requestData.messages })
		});
  
		if (!response.ok) {
		  const errorText = await response.text();
		  return new Response(
			JSON.stringify({ error: "OpenAI API error", details: errorText }),
			{ status: response.status, headers: { "Content-Type": "application/json" } }
		  );
		}
  
		// Return OpenAI's response as JSON
		const openAiData = await response.json();
		return new Response(JSON.stringify(openAiData), {
		  status: 200,
		  headers: { "Content-Type": "application/json" }
		});
  
	  } catch (error) {
		return new Response(
		  JSON.stringify({ error: "Internal Server Error", details: error.message }),
		  { status: 500, headers: { "Content-Type": "application/json" } }
		);
	  }
	}
  };
  
