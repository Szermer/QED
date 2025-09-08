## Lessons Learned and Implementation Challenges

Building an agentic system reveals some tricky engineering problems worth calling out:

### Async Complexity

Async generators are powerful but add complexity. What worked:
	•	Explicit cancellation: Always handle abort signals clearly.
	•	Backpressure: Stream carefully to avoid memory leaks.
	•	Testing generators: Normal tools fall short; you’ll probably need specialized ones.

Example of a well-structured async generator:

```js
async function* generator(signal: AbortSignal): AsyncGenerator<Result> {
  try {
    while (moreItems()) {
      if (signal.aborted) throw new AbortError();
      yield await processNext();
    }
  } finally {
    await cleanup();
  }
}
```

### Tool System Design

Good tools need power without accidental footguns. The architecture handles this by:
	•	Having clear but not overly granular permissions.
	•	Making tools discoverable with structured definitions.

### Terminal UI Challenges

Terminals seem simple, but UI complexity sneaks up on you:
	•	Different terminals mean compatibility headaches.
	•	Keyboard input and state management require careful handling.

### Integrating with LLMs

LLMs are non-deterministic. Defensive coding helps:
	•	Robust parsing matters; don’t trust outputs blindly.
	•	Carefully manage context window limitations.

### Performance Considerations

Keeping the tool responsive is critical:
	•	Parallelize carefully; manage resource usage.
	•	Implement fast cancellation to improve responsiveness.

Hopefully, these insights save you some headaches if you’re exploring similar ideas.

