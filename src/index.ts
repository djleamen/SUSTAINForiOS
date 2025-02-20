export default {
    async fetch(request, env) {
      // Only allow POST requests
      if (request.method !== "POST") {
        return new Response("Use a POST request.", { status: 405 });
      }
  
      // Parse incoming JSON
      const { messages } = await request.json();
  
      // Make request to OpenAI API
      const response = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${env.OPENAI_API_KEY}`
        },
        body: JSON.stringify({ model: "gpt-3.5-turbo", messages })
      });
  
      // Return OpenAI's response
      return new Response(await response.text(), {
        headers: { "Content-Type": "application/json" }
      });
    }
  };
  