// Complete implementation of condition-based waiting utilities
// From: Lace test infrastructure improvements (2025-10-03)
// Context: Fixed 15 flaky tests by replacing arbitrary timeouts

import type { ThreadManager } from '~/threads/thread-manager';
import type { LaceEvent, LaceEventType } from '~/threads/types';

/**
 * Wait for a specific event type to appear in thread
 *
 * @param threadManager - The thread manager to query
 * @param threadId - Thread to check for events
 * @param eventType - Type of event to wait for
 * @param timeoutMs - Maximum time to wait (default 5000ms)
 * @param pollIntervalMs - Polling interval in milliseconds (default 10ms)
 * @returns Promise resolving to the first matching event
 * @throws Error if timeout is reached before event is found, or if inputs are invalid
 *
 * Example:
 *   await waitForEvent(threadManager, agentThreadId, 'TOOL_RESULT');
 */
export function waitForEvent(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  timeoutMs = 5000,
  pollIntervalMs = 10
): Promise<LaceEvent> {
  if (!threadManager) {
    return Promise.reject(new Error('threadManager is required'));
  }
  if (!threadId || typeof threadId !== 'string') {
    return Promise.reject(new Error('threadId must be a non-empty string'));
  }
  if (timeoutMs <= 0) {
    return Promise.reject(new Error('timeoutMs must be positive'));
  }
  if (pollIntervalMs <= 0) {
    return Promise.reject(new Error('pollIntervalMs must be positive'));
  }

  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    let timeoutId: ReturnType<typeof setTimeout> | null = null;

    const check = () => {
      try {
        const events = threadManager.getEvents(threadId);
        const event = events.find((e) => e.type === eventType);

        if (event) {
          if (timeoutId) clearTimeout(timeoutId);
          resolve(event);
        } else if (Date.now() - startTime > timeoutMs) {
          if (timeoutId) clearTimeout(timeoutId);
          reject(new Error(`Timeout waiting for ${eventType} event after ${timeoutMs}ms`));
        } else {
          timeoutId = setTimeout(check, pollIntervalMs);
        }
      } catch (e) {
        if (timeoutId) clearTimeout(timeoutId);
        reject(e);
      }
    };

    timeoutId = setTimeout(check, 0);
  });
}

/**
 * Wait for a specific number of events of a given type
 *
 * @param threadManager - The thread manager to query
 * @param threadId - Thread to check for events
 * @param eventType - Type of event to wait for
 * @param count - Number of events to wait for
 * @param timeoutMs - Maximum time to wait (default 5000ms)
 * @param pollIntervalMs - Polling interval in milliseconds (default 10ms)
 * @returns Promise resolving to all matching events once count is reached
 * @throws Error if timeout is reached before enough events are found, or if inputs are invalid
 *
 * Example:
 *   // Wait for 2 AGENT_MESSAGE events (initial response + continuation)
 *   await waitForEventCount(threadManager, agentThreadId, 'AGENT_MESSAGE', 2);
 */
export function waitForEventCount(
  threadManager: ThreadManager,
  threadId: string,
  eventType: LaceEventType,
  count: number,
  timeoutMs = 5000,
  pollIntervalMs = 10
): Promise<LaceEvent[]> {
  if (!threadManager) {
    return Promise.reject(new Error('threadManager is required'));
  }
  if (!threadId || typeof threadId !== 'string') {
    return Promise.reject(new Error('threadId must be a non-empty string'));
  }
  if (count <= 0) {
    return Promise.reject(new Error('count must be positive'));
  }
  if (timeoutMs <= 0) {
    return Promise.reject(new Error('timeoutMs must be positive'));
  }
  if (pollIntervalMs <= 0) {
    return Promise.reject(new Error('pollIntervalMs must be positive'));
  }

  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    let timeoutId: ReturnType<typeof setTimeout> | null = null;

    const check = () => {
      try {
        const events = threadManager.getEvents(threadId);
        const matchingEvents = events.filter((e) => e.type === eventType);

        if (matchingEvents.length >= count) {
          if (timeoutId) clearTimeout(timeoutId);
          resolve(matchingEvents);
        } else if (Date.now() - startTime > timeoutMs) {
          if (timeoutId) clearTimeout(timeoutId);
          reject(
            new Error(
              `Timeout waiting for ${count} ${eventType} events after ${timeoutMs}ms (got ${matchingEvents.length})`
            )
          );
        } else {
          timeoutId = setTimeout(check, pollIntervalMs);
        }
      } catch (e) {
        if (timeoutId) clearTimeout(timeoutId);
        reject(e);
      }
    };

    timeoutId = setTimeout(check, 0);
  });
}

/**
 * Wait for an event matching a custom predicate
 * Useful when you need to check event data, not just type
 *
 * @param threadManager - The thread manager to query
 * @param threadId - Thread to check for events
 * @param predicate - Function that returns true when event matches
 * @param description - Human-readable description for error messages
 * @param timeoutMs - Maximum time to wait (default 5000ms)
 * @param pollIntervalMs - Polling interval in milliseconds (default 10ms)
 * @returns Promise resolving to the first matching event
 * @throws Error if timeout is reached before matching event is found, or if inputs are invalid
 *
 * Example:
 *   // Wait for TOOL_RESULT with specific ID
 *   await waitForEventMatch(
 *     threadManager,
 *     agentThreadId,
 *     (e) => e.type === 'TOOL_RESULT' && e.data.id === 'call_123',
 *     'TOOL_RESULT with id=call_123'
 *   );
 */
export function waitForEventMatch(
  threadManager: ThreadManager,
  threadId: string,
  predicate: (event: LaceEvent) => boolean,
  description: string,
  timeoutMs = 5000,
  pollIntervalMs = 10
): Promise<LaceEvent> {
  if (!threadManager) {
    return Promise.reject(new Error('threadManager is required'));
  }
  if (!threadId || typeof threadId !== 'string') {
    return Promise.reject(new Error('threadId must be a non-empty string'));
  }
  if (typeof predicate !== 'function') {
    return Promise.reject(new Error('predicate must be a function'));
  }
  if (!description || typeof description !== 'string') {
    return Promise.reject(new Error('description must be a non-empty string'));
  }
  if (timeoutMs <= 0) {
    return Promise.reject(new Error('timeoutMs must be positive'));
  }
  if (pollIntervalMs <= 0) {
    return Promise.reject(new Error('pollIntervalMs must be positive'));
  }

  return new Promise((resolve, reject) => {
    const startTime = Date.now();
    let timeoutId: ReturnType<typeof setTimeout> | null = null;

    const check = () => {
      try {
        const events = threadManager.getEvents(threadId);
        const event = events.find(predicate);

        if (event) {
          if (timeoutId) clearTimeout(timeoutId);
          resolve(event);
        } else if (Date.now() - startTime > timeoutMs) {
          if (timeoutId) clearTimeout(timeoutId);
          reject(new Error(`Timeout waiting for ${description} after ${timeoutMs}ms`));
        } else {
          timeoutId = setTimeout(check, pollIntervalMs);
        }
      } catch (e) {
        if (timeoutId) clearTimeout(timeoutId);
        reject(e);
      }
    };

    timeoutId = setTimeout(check, 0);
  });
}

// Usage example from actual debugging session:
//
// BEFORE (flaky):
// ---------------
// const messagePromise = agent.sendMessage('Execute tools');
// await new Promise(r => setTimeout(r, 300)); // Hope tools start in 300ms
// agent.abort();
// await messagePromise;
// await new Promise(r => setTimeout(r, 50));  // Hope results arrive in 50ms
// expect(toolResults.length).toBe(2);         // Fails randomly
//
// AFTER (reliable):
// ----------------
// const messagePromise = agent.sendMessage('Execute tools');
// await waitForEventCount(threadManager, threadId, 'TOOL_CALL', 2); // Wait for tools to start
// agent.abort();
// await messagePromise;
// await waitForEventCount(threadManager, threadId, 'TOOL_RESULT', 2); // Wait for results
// expect(toolResults.length).toBe(2); // Always succeeds
//
// Result: 60% pass rate → 100%, 40% faster execution
