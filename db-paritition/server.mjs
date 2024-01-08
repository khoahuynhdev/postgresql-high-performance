import Fastify from "fastify";
import pg from "pg";
import { generate } from "random-words";

const fastify = Fastify({
  logger: true,
});
fastify.get("/", function handler(req, reply) {
  reply.send({
    success: true,
    host: req.hostname,
  });
});

fastify.get("/words", async function handler(req, reply) {
  const connectionInfo = {
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port: 5432,
    database: "searching",
  };
  const dbClientPostgres = new pg.Client(connectionInfo);
  try {
    await dbClientPostgres.connect();
    const words = generate({
      minLength: 2,
      maxLength: 20,
    });
    req.log.info({ query: words }, "Generate");
    const qRes = await dbClientPostgres.query(
      `SELECT value from eng_words where value ilike '${words}%' OR value ilike '%${words}'`,
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
