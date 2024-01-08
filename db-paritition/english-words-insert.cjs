const pg = require("pg");
const fs = require("fs");

function buildSQL() {
  const data = fs
    .readFileSync("./words.txt", { encoding: "utf8" })
    .split("\n")
    .filter((d) => d)
    .map((d) => d.replaceAll("'", "''")); // escapte "'" in postgres
  const sql = `INSERT INTO eng_words (value) VALUES ${data.map(
    (d, idx) => `('${d}')${idx === data.length - 1 ? ";" : ""}`,
  )}`;
  console.log(sql);
  return sql;
}

async function run() {
  const connectionInfo = {
    user: "postgres",
    password: "postgres",
    host: "localhost",
    port: 5432,
    database: "searching",
  };
  try {
    const dbClientPostgres = new pg.Client(connectionInfo);
    console.log("connecting to postgres...");
    await dbClientPostgres.connect();
    console.log("insert eng_words data...");
    // await dbClientPostgres.query("drop database customers")
    // console.log ("creating database customers...")
    await dbClientPostgres.query(buildSQL());
    console.log("closing connection");
    await dbClientPostgres.end();
    console.log("done.");
  } catch (ex) {
    console.error(`something went wrong ${JSON.stringify(ex.message)}`);
  }
}

run();
