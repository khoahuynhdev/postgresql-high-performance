import Fastify from "fastify";
import pg from "pg";
import { generate } from "random-words";

// PERF: test script
// npm run stress 2>&1 | tee >(sed $'s/\033[[][^A-Za-z]*m//g' > "$(date +'%Y%m%d_%H%M%S')_stress:p_sample")
// npm run stress:p 2>&1 | tee >(sed $'s/\033[[][^A-Za-z]*m//g' > "$(date +'%Y%m%d_%H%M%S')_stress:p_sample")
const fastify = Fastify({
  logger: true,
});
fastify.get("/", function handler(req, reply) {
  reply.send({
    success: true,
    host: req.hostname,
  });
});

const pool = new pg.Pool({
  user: "postgres",
  password: "postgres",
  host: "localhost",
  port: 5432,
  database: "searching",
  max: 20,
  connectionTimeoutMillis: 5000,
});

fastify.get("/pool/words", async function handler(req, reply) {
  try {
    const client = await pool.connect();
    const words = generate({
      minLength: 2,
      maxLength: 20,
    });
    req.log.info({ query: words }, "Generate");
    const qRes = await client.query(
      `SELECT value from eng_words where value ilike '${words}%' OR value ilike '%${words}'`,
    );
    client.release();
    reply.send({
      success: true,
      query: words[0],
      data: qRes.rows,
      total: qRes.rowCount,
    });
    // req.log.info({ event: "request_done" }, "request done");
  } catch (ex) {
    req.log.error(`something went wrong ${JSON.stringify(ex.message)}`);
    req.log.info(
      {
        waiting: pool.waitingCount,
        idle: pool.idleCount,
        total: pool.totalCount,
      },
      "pool statistics",
    );
    reply.code(500).send({
      success: false,
      error: ex.message,
    });
  } finally {
    // req.log.info({ event: "pool_releasing" }, "pool releasing");
    // req.log.info({ event: "pool_released" }, "pool released");
  }
});

fastify.get("/words", async function handler(req, reply) {
  const dbClientPostgres = new pg.Client({
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port: 5432,
    database: "searching",
  });
  try {
    await dbClientPostgres.connect();
    const words = generate({
      minLength: 2,
      maxLength: 20,
    });
    req.log.info({ query: words }, "Generate");
    const qRes = await dbClientPostgres.query(
      `SELECT value from eng_words where value ilike '' OR value ilike '%${words}'`,
    );
    reply.send({
      success: true,
      query: words[0],
      data: qRes.rows,
      total: qRes.rowCount,
    });
    req.log.info({ event: "request_done" }, "request done");
  } catch (ex) {
    console.error(`something went wrong ${JSON.stringify(ex.message)}`);
  } finally {
    req.log.info({ event: "connection_closing" }, "closing connection");
    await dbClientPostgres.end();
    req.log.info({ event: "connection_closed" }, "connection closed");
  }
});

fastify.listen({ port: 3000 }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
});
