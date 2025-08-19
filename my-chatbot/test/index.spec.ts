// test/index.spec.ts
import { describe, it, expect } from 'vitest';
import worker from '../src/index';

// Mock environment for testing
const mockEnv = {
	OPENAI_API_KEY: 'test-api-key'
};

describe('Hello World worker', () => {
	it('responds with Hello World! (unit style)', async () => {
		const request = new Request('http://example.com');
		const response = await worker.fetch(request, mockEnv);
		expect(await response.text()).toMatchInlineSnapshot(`"Hello World!"`);
	});

	it('responds with Hello World! (integration style)', async () => {
		const request = new Request('https://example.com');
		const response = await worker.fetch(request, mockEnv);
		expect(await response.text()).toMatchInlineSnapshot(`"Hello World!"`);
	});
});
