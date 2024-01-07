const fastify = require("fastify")({ logger: true });

fastify.get("/", function handler(req, reply) {
  reply.send({
    success: true,
    host: req.hostname,
  });
});

fastify.listen({ port: 3000 }, (err) => {
  if (err) {
    fastify.log.error(err);
    process.exit(1);
  }
});
