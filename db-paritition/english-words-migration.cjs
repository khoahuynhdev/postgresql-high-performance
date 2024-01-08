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
    console.log("dropping database eng_words...");
    await dbClientPostgres.query("drop database eng_words");
    console.log("creating database searching...");
    await dbClientPostgres.query("create database searching");
    const searchingDBClient = new pg.Client({
      ...connectionInfo,
      database: "searching",
    });
    console.log("creating table eng_words...");
    await searchingDBClient.connect();
    await searchingDBClient.query(
      "create table eng_words(id serial primary key, value varchar(100) NOT NULL)",
    );
    console.log("closing connection");
    await dbClientPostgres.end();
    await searchingDBClient.end();
    console.log("done.");
  } catch (ex) {
    console.error(`something went wrong ${JSON.stringify(ex)}`);
  }
}

run();
