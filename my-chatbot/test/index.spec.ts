// test/index.spec.ts
import { afterEach, describe, expect, it, vi } from 'vitest';
import worker from '../src/index';

// Mock environment for testing
const mockEnv = {
	OPENAI_API_KEY: 'test-api-key'
};

function postRequest(body: unknown): Request {
	return new Request('https://example.com', {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: typeof body === 'string' ? body : JSON.stringify(body)
	});
}

afterEach(() => {
	vi.unstubAllGlobals();
});

describe('Chatbot worker', () => {
	it('rejects non-POST requests with 405', async () => {
		const request = new Request('https://example.com');
		const response = await worker.fetch(request, mockEnv);
		expect(response.status).toBe(405);
		expect(await response.json()).toEqual({ error: 'Use a POST request.' });
	});

	it('rejects invalid JSON with 400', async () => {
		const response = await worker.fetch(postRequest('not json'), mockEnv);
		expect(response.status).toBe(400);
		expect(await response.json()).toEqual({ error: 'Invalid JSON format.' });
	});

	it('rejects a body without a messages array with 400', async () => {
		const response = await worker.fetch(postRequest({ messages: 'hi' }), mockEnv);
		expect(response.status).toBe(400);
		expect(await response.json()).toEqual({
			error: "Invalid request format. 'messages' must be an array."
		});
	});

	it('rejects an empty messages array with 400', async () => {
		const response = await worker.fetch(postRequest({ messages: [] }), mockEnv);
		expect(response.status).toBe(400);
	});

	it('rejects messages with an invalid role with 400', async () => {
		const response = await worker.fetch(
			postRequest({ messages: [{ role: 'hacker', content: 'hi' }] }),
			mockEnv
		);
		expect(response.status).toBe(400);
	});

	it('forwards valid messages and returns the upstream reply', async () => {
		const upstreamReply = {
			choices: [{ message: { role: 'assistant', content: 'Hello!' } }]
		};
		const fetchSpy = vi.fn(async () =>
			new Response(JSON.stringify(upstreamReply), {
				status: 200,
				headers: { 'Content-Type': 'application/json' }
			})
		);
		vi.stubGlobal('fetch', fetchSpy);

		const response = await worker.fetch(
			postRequest({ messages: [{ role: 'user', content: 'Hi there' }] }),
			mockEnv
		);
		expect(response.status).toBe(200);
		expect(await response.json()).toEqual(upstreamReply);

		expect(fetchSpy).toHaveBeenCalledTimes(1);
		const [url, init] = fetchSpy.mock.calls[0] as unknown as [string, RequestInit];
		expect(url).toBe('https://api.openai.com/v1/chat/completions');
		expect((init.headers as Record<string, string>).Authorization).toBe(
			'Bearer test-api-key'
		);
	});

	it('returns 502 when the upstream API fails', async () => {
		vi.stubGlobal(
			'fetch',
			vi.fn(async () => new Response('upstream broke', { status: 500 }))
		);

		const response = await worker.fetch(
			postRequest({ messages: [{ role: 'user', content: 'Hi there' }] }),
			mockEnv
		);
		expect(response.status).toBe(502);
		expect(await response.json()).toEqual({ error: 'Upstream API error.' });
	});
});
