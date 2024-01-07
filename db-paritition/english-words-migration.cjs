const pg = require("pg");
/*
This script creates 100 partitions 
and attaches them to the main table customers
docker run --name pg -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres
*/
async function run() {
  const connectionInfo = {
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port: 5432,
    database: "postgres",
  };
  try {
    const dbClientPostgres = new pg.Client(connectionInfo);
    console.log("connecting to postgres...");
    await dbClientPostgres.connect();
    console.log("dropping database customers...");
    // await dbClientPostgres.query("drop database customers")
    // console.log ("creating database customers...")
    await dbClientPostgres.query("create database eng_words");

    console.log("closing connection");
    await dbClientPostgres.end();
    console.log("done.");
  } catch (ex) {
    console.error(`something went wrong ${JSON.stringify(ex)}`);
  }
}

run();
