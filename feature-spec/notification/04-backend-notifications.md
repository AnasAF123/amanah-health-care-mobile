# Backend Notification Architecture (Next.js)

**Document 4 of 4 — Backend, Persistence, Delivery, and Docker Topology**
Assumes the paradigm, vocabulary, and technology decisions established in `01-architecture-overview.md`. This document is the implementation-facing counterpart: internal module layout, database schema, delivery adapters, the Realtime Gateway, retry/failure handling, observability, and how all of this maps onto Docker services.

---

## 1. Role of the Backend

The backend owns everything a feature module and a client (Flutter/Next.js web) are explicitly *not* allowed to know about: event durability, recipient resolution, persistence, delivery-channel selection, retries, idempotency, and real-time fan-out. It is built as **Next.js** (API/Route Handlers for the REST surface and event-publishing entry point), paired with two additional Node.js services — a **Notification Worker** and a **Realtime Gateway** — that are architecturally part of "the backend" even though they run as separate Docker containers. This split exists specifically to satisfy the requirements around statelessness, horizontal scaling, and single responsibility discussed in Document 1 §10.

## 2. Internal Module Layout

```
src/
  modules/                          # business feature modules — own their domain only
    appointments/
      appointments.service.ts
      appointments.notifications.ts # registers event types + resolvers (Doc 1 §6.2), nothing else
    orders/
      ...

  notifications/                    # the notification subsystem — domain-agnostic
    contracts/
      domain-event.ts               # DomainEvent<T>, NotificationPublisher interfaces
      delivery-channel.ts           # DeliveryChannelAdapter interface
      notification-repository.ts    # NotificationRepository interface
    registry/
      notification-rules-registry.ts
    application/
      notification-orchestration.service.ts
      publish-domain-event.ts       # concrete NotificationPublisher: writes to Redis Streams
    infrastructure/
      redis-streams.adapter.ts
      postgres-notification.repository.ts
      channels/
        in-app.channel.ts
        push.channel.ts             # future
        email.channel.ts            # future
    api/
      route-handlers/
        notifications.list.ts
        notifications.mark-read.ts
        notifications.unread-count.ts

services/
  notification-worker/              # separate deployable — consumes Redis Streams
    index.ts
  realtime-gateway/                 # separate deployable — Socket.IO server
    index.ts
```

The `notifications/` folder never imports anything from `modules/*`. The dependency arrow points the other way: each business module imports the notification `contracts/` (the port) and, at its own bootstrap, calls into `registry/` to register itself. This is the concrete file-level expression of the dependency-inversion requirement from your brief.

## 3. Domain Event Contract and Publishing

```typescript
// notifications/contracts/domain-event.ts
export interface DomainEvent<TPayload = Record<string, unknown>> {
  eventId: string;
  type: string;
  module: string;
  occurredAt: string;
  payload: TPayload;
}

export interface NotificationPublisher {
  publish<T>(event: DomainEvent<T>): Promise<void>;
}
```

```typescript
// notifications/application/publish-domain-event.ts
export class RedisStreamsPublisher implements NotificationPublisher {
  constructor(private readonly redis: Redis) {}

  async publish<T>(event: DomainEvent<T>): Promise<void> {
    await this.redis.xadd(
      'notifications:events',
      '*', // auto-generated stream ID
      'payload', JSON.stringify(event),
    );
    // Fire-and-forget from the caller's perspective: this resolves as soon as
    // Redis acknowledges the XADD, which is durable — the caller does not wait
    // for the notification to be processed, persisted, or delivered.
  }
}
```

```typescript
// modules/appointments/appointments.service.ts
export async function confirmAppointment(appointmentId: string) {
  const appointment = await appointmentsRepo.confirm(appointmentId);

  await notificationPublisher.publish({
    eventId: crypto.randomUUID(),
    type: 'appointment.confirmed',
    module: 'appointments',
    occurredAt: new Date().toISOString(),
    payload: {
      appointmentId: appointment.id,
      patientId: appointment.patientId,
      doctorName: appointment.doctorName,
      scheduledAt: appointment.scheduledAt,
    },
  });

  return appointment; // HTTP response returns now — publish already completed the durable handoff
}
```

## 4. The Notification Rules Registry

```typescript
// notifications/registry/notification-rules-registry.ts
interface NotificationRule<T = any> {
  defaultChannels: NotificationChannel[];
  resolveRecipient: (payload: T) => string | string[];
  titleTemplate: string;
}

class NotificationRulesRegistry {
  private rules = new Map<string, NotificationRule>();

  register<T>(eventType: string, rule: NotificationRule<T>) {
    this.rules.set(eventType, rule);
  }

  get(eventType: string): NotificationRule {
    const rule = this.rules.get(eventType);
    if (!rule) throw new UnregisteredEventTypeError(eventType);
    return rule;
  }
}

export const notificationRegistry = new NotificationRulesRegistry();
```

```typescript
// modules/appointments/appointments.notifications.ts — the ONLY coupling point
notificationRegistry.register<AppointmentConfirmedPayload>('appointment.confirmed', {
  defaultChannels: ['in_app', 'push'],
  resolveRecipient: (payload) => payload.patientId,
  titleTemplate: 'Your appointment with {{doctorName}} is confirmed',
});
```

This registration call runs once, at application bootstrap, for every module that wants notifications. Feature Y, arriving six months from now, adds exactly one file like this one and zero changes anywhere in `notifications/`.

## 5. Event Production → Redis Streams

Redis Streams (`XADD`) is the durable handoff from the API process to the Notification Worker process (Document 1 §7.1). A single stream, `notifications:events`, carries every domain event regardless of originating module — the stream itself is domain-agnostic; routing to the right handler happens downstream via the registry, not via separate streams per feature (which would reintroduce coupling at the infrastructure level).

## 6. Notification Worker: Orchestration Service

Runs as its own container, consuming the stream via a **consumer group** (`notification-service`), which is what allows multiple worker replicas to safely share the workload — each stream entry is delivered to exactly one member of the group.

```typescript
// services/notification-worker/index.ts
async function runConsumerLoop() {
  await redis.xgroup('CREATE', 'notifications:events', 'notification-service', '$', 'MKSTREAM')
    .catch(() => {}); // group may already exist

  while (true) {
    const entries = await redis.xreadgroup(
      'GROUP', 'notification-service', `worker-${process.env.HOSTNAME}`,
      'COUNT', 10, 'BLOCK', 5000,
      'STREAMS', 'notifications:events', '>',
    );
    if (!entries) continue;

    for (const [, messages] of entries) {
      for (const [streamId, fields] of messages) {
        const event: DomainEvent = JSON.parse(fields[1]);
        try {
          await orchestrationService.handle(event);
          await redis.xack('notifications:events', 'notification-service', streamId);
        } catch (err) {
          logger.error({ err, eventId: event.eventId }, 'notification processing failed');
          // deliberately NOT acked — remains in the Pending Entries List for XCLAIM/retry
        }
      }
    }
  }
}
```

```typescript
// notifications/application/notification-orchestration.service.ts
export class NotificationOrchestrationService {
  constructor(
    private readonly registry: NotificationRulesRegistry,
    private readonly repo: NotificationRepository,
    private readonly channels: Map<NotificationChannel, DeliveryChannelAdapter>,
  ) {}

  async handle(event: DomainEvent): Promise<void> {
    const rule = this.registry.get(event.type);
    const recipients = [rule.resolveRecipient(event.payload)].flat();

    for (const recipientId of recipients) {
      const idempotencyKey = buildIdempotencyKey(event.eventId, recipientId, event.type);

      const notification = await this.repo.createIfNotExists({
        idempotencyKey,
        recipientId,
        type: event.type,
        module: event.module,
        referenceType: event.module,        // convention: module name doubles as reference type
        referenceId: firstIdLikeField(event.payload),
        payload: minimalDisplayPayload(event.payload, rule),
        channels: rule.defaultChannels,
      });

      if (!notification) continue; // already existed — redelivered stream message, safe no-op

      for (const channel of rule.defaultChannels) {
        await this.channels.get(channel)?.deliver(notification);
      }
    }
  }
}
```

## 7. Database Schema

PostgreSQL, generic by construction — no feature-specific columns, no feature-specific tables:

```sql
CREATE TABLE notifications (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idempotency_key   TEXT NOT NULL UNIQUE,          -- eventId + recipientId + type, hashed
    recipient_id      UUID NOT NULL,
    recipient_type    TEXT NOT NULL DEFAULT 'user',  -- future-proofs for non-user recipients (org, team...)

    type              TEXT NOT NULL,                 -- "appointment.confirmed"
    module            TEXT NOT NULL,                 -- "appointments" — provenance, not business logic

    reference_type    TEXT,                          -- "appointment" — polymorphic association
    reference_id      UUID,                          -- id of the entity in ITS OWN table, not duplicated here

    payload           JSONB NOT NULL DEFAULT '{}',   -- minimal display data only, never a full entity copy
    channels          TEXT[] NOT NULL,                -- ['in_app','push']

    status             TEXT NOT NULL DEFAULT 'created', -- created | delivered | failed
    read_at             TIMESTAMPTZ,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    delivered_at         TIMESTAMPTZ,

    retry_count       INT NOT NULL DEFAULT 0
);

-- Query patterns this indexing set is built for:
CREATE INDEX idx_notifications_recipient_unread
    ON notifications (recipient_id, created_at DESC)
    WHERE read_at IS NULL;                            -- fast "unread for user X" without a full scan

CREATE INDEX idx_notifications_recipient_all
    ON notifications (recipient_id, created_at DESC); -- paginated history, all notifications

CREATE INDEX idx_notifications_reference
    ON notifications (reference_type, reference_id);   -- "all notifications about this entity"
```

**How Feature Y adopts this with zero migrations:** `type = "order.shipped"`, `module = "orders"`, `reference_type = "order"` — all just string/UUID values inserted into the existing columns. Nothing about this schema encodes any knowledge of "orders" as a concept; it only encodes "a notification has a type, a module of origin, and an optional reference to some entity elsewhere." This is precisely the generic-identifier design your brief asked for.

### 7.1 Data lifecycle: retention, pagination, cleanup

- **Pagination**: keyset pagination on `(recipient_id, created_at DESC, id)` rather than `OFFSET`, since notification volume grows unboundedly per user and offset pagination degrades linearly with table size.
- **Retention**: a scheduled job (see §14, the `worker` service already running) archives or deletes notifications older than a configurable window (e.g., 12 months) once `read_at IS NOT NULL`, keeping the hot table small; unread notifications are exempt from automatic cleanup regardless of age.
- **Growth**: the `idx_notifications_recipient_unread` partial index specifically keeps the common "unread badge count" query cheap even as the full table grows into the tens of millions of rows, because the index only contains unread rows.

## 8. Delivery Channel Adapters

```typescript
// notifications/contracts/delivery-channel.ts
export interface DeliveryChannelAdapter {
  channel: NotificationChannel;
  deliver(notification: PersistedNotification): Promise<DeliveryResult>;
}
```

```typescript
// notifications/infrastructure/channels/in-app.channel.ts
export class InAppChannelAdapter implements DeliveryChannelAdapter {
  channel = 'in_app' as const;
  constructor(private readonly emitter: SocketIoEmitter) {}

  async deliver(notification: PersistedNotification): Promise<DeliveryResult> {
    // No external call, no failure mode beyond the emit itself —
    // if nobody is connected to the room, this is simply a no-op (Doc 1 §8.2).
    this.emitter.to(`user:${notification.recipientId}`).emit('notification:new', notification);
    return { status: 'delivered' };
  }
}
```

`push` and `email` adapters follow the same interface and, because genuine third-party failures are possible for them, route through the retry-capable job queue described in §11 rather than delivering inline during the orchestration loop — this keeps a slow/failing email provider from blocking the consumer group's throughput for every other notification.

## 9. Real-Time Gateway Service

A separate, stateless-by-design Node.js service whose only job is holding client WebSocket connections and routing room-targeted emits to them. It never talks to Postgres and never talks to Redis Streams — its only inputs are (a) incoming client connections and (b) the Socket.IO Redis adapter channel.

```typescript
// services/realtime-gateway/index.ts
import { Server } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';

const io = new Server(httpServer, { cors: corsConfig });
io.adapter(createAdapter(pubClient, subClient)); // enables cross-replica room broadcast

io.use(async (socket, next) => {
  const token = socket.handshake.auth?.token;
  try {
    const claims = await verifyJwt(token); // reject at handshake, never accept anonymously
    socket.data.userId = claims.sub;
    next();
  } catch {
    next(new Error('unauthorized'));
  }
});

io.on('connection', (socket) => {
  socket.join(`user:${socket.data.userId}`); // server-derived room, never client-specified
});
```

On the producer side, the **Notification Worker does not hold any socket connections itself** — it uses `socket.io-emitter`, an official companion library that publishes into the same Redis channel the gateway's `@socket.io/redis-adapter` listens on. This means "emit to a room" works identically whether zero, one, or twenty gateway replicas are running, and the worker has zero dependency on how many gateway instances exist or which one a given user happens to be connected to:

```typescript
// notifications/infrastructure/channels/in-app.channel.ts (emitter setup)
import { Emitter } from '@socket.io/redis-emitter';
const emitter = new Emitter(redisClient);
```

This single mechanism elegantly serves two purposes at once: it's the "real-time transport" from Document 1 §3, and it's also what makes the gateway horizontally scalable — both problems solved by one well-maintained, free/open-source library rather than custom-built coordination logic.

## 10. REST API Contract

| Method & Path | Purpose | Notes |
|---|---|---|
| `GET /api/notifications?page=&unreadOnly=&since=` | Paginated history / reconciliation fetch | `since` param supports the reconnect-reconciliation pattern (Doc 1 §8.3, Doc 2 §6, Doc 3 §3) |
| `GET /api/notifications/unread-count` | Badge count | Backed by the partial index (§7) |
| `PATCH /api/notifications/:id/read` | Mark one as read | Triggers `notification:read` sync emit to the user's room |
| `PATCH /api/notifications/read-all` | Mark all as read | Same sync mechanism, bulk |

All authenticated via the same session/JWT mechanism already used elsewhere in the application — no separate auth scheme for notifications.

## 11. Retry, Failure Handling, and Dead-Lettering

Two independent retry layers exist, at two different points in the pipeline, for two different failure modes:

1. **Stream-level (event processing itself failing)**: handled by Redis Streams' native Pending Entries List — an unacknowledged message is eligible for `XCLAIM` by another consumer after a visibility timeout. This covers worker crashes and transient DB errors during orchestration.
2. **Channel-level (an external provider call failing — push/email)**: handled by **BullMQ** (Redis-backed job queue), with exponential backoff and a bounded max-attempt count. Jobs that exhaust their attempts move to a dead-letter queue rather than vanishing, so failures are visible and inspectable rather than silent.

```typescript
// notifications/infrastructure/channels/push.channel.ts
export class PushChannelAdapter implements DeliveryChannelAdapter {
  channel = 'push' as const;
  constructor(private readonly queue: Queue) {}

  async deliver(notification: PersistedNotification): Promise<DeliveryResult> {
    await this.queue.add('deliver-push', { notificationId: notification.id }, {
      attempts: 5,
      backoff: { type: 'exponential', delay: 2000 },
    });
    return { status: 'queued' };
  }
}
```

In-app delivery (§8) deliberately has *no* retry queue of its own — there is nothing to retry, because persistence already succeeded before delivery was attempted (Document 1 §5, §8.2), and a missed real-time push is fully recovered by the client's own reconciliation fetch.

## 12. Idempotency and Duplicate Handling — Backend Mechanics

Recapping Document 1 §8.1 at the implementation level: `repo.createIfNotExists` performs `INSERT ... ON CONFLICT (idempotency_key) DO NOTHING RETURNING *`, returning `null` when the row already existed. The orchestration service treats a `null` return as "already handled" and skips delivery entirely — this single database constraint is what makes the whole pipeline safe under Redis Streams' at-least-once redelivery guarantee, without any additional deduplication logic needed elsewhere.

## 13. Observability

| Signal | Mechanism |
|---|---|
| Structured logs, correlated across services | `pino`, every log line carries `eventId` as a correlation ID from publish through delivery |
| Throughput / error metrics | Prometheus counters: `events_published_total`, `notifications_created_total`, `delivery_failures_total{channel}` |
| Live connection count | `socket_connections_gauge`, exported from the Realtime Gateway |
| Consumer backlog / lag | `XINFO GROUPS notifications:events` polled periodically — surfaces if the worker is falling behind |
| Service health | `/healthz` on each of the three services (API, worker, gateway), checked by Docker's `healthcheck` (see §14) |

## 14. Docker Architecture

### 14.1 Services

| Service | Statefulness | Exposed to host? | Responsibility |
|---|---|---|---|
| `web` | Stateless | Yes (via reverse proxy) | Next.js app: UI pages + REST API routes + event publishing (`XADD`) |
| `notification-worker` | Stateless (state lives in Redis/Postgres, not the process) | No | Consumes Redis Streams, orchestrates, persists, triggers in-app/push/email delivery |
| `realtime-gateway` | Stateless (connection state is ephemeral, coordinated via Redis adapter) | Yes (WebSocket endpoint) | Holds client WebSocket connections, emits to rooms |
| `redis` | **Stateful** | No | Streams (durable event handoff), Pub/Sub (Socket.IO adapter/emitter), BullMQ queues |
| `postgres` | **Stateful** | No | Notification persistence + rest of the application's data |

### 14.2 docker-compose sketch

```yaml
services:
  web:
    build: ./apps/web
    depends_on: [redis, postgres]
    environment:
      REDIS_URL: redis://redis:6379
      DATABASE_URL: postgres://app:app@postgres:5432/app
    ports: ["3000:3000"]

  notification-worker:
    build: ./services/notification-worker
    depends_on: [redis, postgres]
    environment:
      REDIS_URL: redis://redis:6379
      DATABASE_URL: postgres://app:app@postgres:5432/app
    # no ports exposed — internal-only service
    healthcheck:
      test: ["CMD", "node", "healthcheck.js"]

  realtime-gateway:
    build: ./services/realtime-gateway
    depends_on: [redis]
    environment:
      REDIS_URL: redis://redis:6379
      JWT_PUBLIC_KEY_PATH: /run/secrets/jwt_public_key
    ports: ["4001:4001"]

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes   # AOF persistence: protects Streams data across restarts
    volumes: ["redis_data:/data"]

  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: app
    volumes: ["postgres_data:/var/lib/postgresql/data"]

volumes:
  redis_data:
  postgres_data:
```

### 14.3 Internal networking

All five services share a single Docker Compose bridge network by default, and reach each other by **service name** (`redis:6379`, `postgres:5432`) rather than any hardcoded IP. Only `web` and `realtime-gateway` publish ports to the host (typically behind a reverse proxy such as Nginx/Traefik in front of both, terminating TLS and routing `/socket.io/*` to the gateway and everything else to `web`). `notification-worker` exposes nothing externally — it has no HTTP surface a client would ever call directly.

### 14.4 Statelessness and volumes

- **Stateless**: `web`, `notification-worker`, `realtime-gateway`. Any of these can be killed and restarted (or scaled to N replicas) without data loss, because none of them hold durable state in memory — everything durable lives in Redis or Postgres.
- **Persistent volumes required**: `postgres_data` (obviously — this is the source of truth) and `redis_data` (Redis is configured with AOF persistence specifically because Streams data must survive a Redis restart; Pub/Sub messages themselves are inherently transient and don't need persistence, but the Streams log does).

### 14.5 Behavior on container restart

| Container restarts | What happens |
|---|---|
| `web` | Stateless — restarts cleanly, in-flight HTTP requests fail over to the next request/replica, nothing lost |
| `notification-worker` | Any unacknowledged stream entries remain in the consumer group's Pending Entries List and are picked up (via `XCLAIM`) once the worker (or another replica) comes back — no events are lost |
| `realtime-gateway` | All connected sockets drop; Socket.IO's client-side reconnection logic (Documents 2 §6, 3 §3) reconnects automatically, and the client's reconciliation fetch on reconnect covers anything emitted during the gap |
| `redis` | With AOF enabled, Streams data (and BullMQ queue state) survives; Pub/Sub in-flight messages at the exact moment of restart are lost, which is acceptable because Pub/Sub is only used for the ephemeral real-time-push step, not for durability |
| `postgres` | Standard database restart semantics; volume ensures no data loss |

## 15. How a Future Feature Y Integrates — Concretely

1. Feature Y's service code calls `notificationPublisher.publish({ type: 'invoice.overdue', module: 'billing', payload: {...} })` at the point where the business event occurs. *(One line, using a contract that already exists.)*
2. Feature Y adds one bootstrap file registering `invoice.overdue` with a recipient resolver and default channels. *(One new file.)*
3. Nothing in `notifications/`, the database schema, the Notification Worker, or the Realtime Gateway changes. No migration. No new table. No new WebSocket wiring. No changes in Flutter or Next.js beyond what already renders any notification generically (title/body from `payload`, timestamp, read state).

This is the "plug-and-play" outcome your brief specified, achieved by the combination of the domain-agnostic contract (§3), the registry pattern that keeps coupling one-directional (§4), and a database schema built on generic identifiers rather than feature-specific columns (§7).
