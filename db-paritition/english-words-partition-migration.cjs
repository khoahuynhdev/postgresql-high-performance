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
    const searchingDBClient = new pg.Client({
      ...connectionInfo,
      database: "searching",
    });
    console.log("creating table eng_words with partitions...");
    await searchingDBClient.connect();
    // NOTE: partition by list is not good here since we have to know the pre-define values of data
    // probably better go with range partition
    // [0-9][a-z][A-Z]
    // Question: what is the impact of more partitions with less data in it?
    // this is a bad idea, for this case full-text search is better
    await searchingDBClient.query(
      `create table eng_words_pt (id serial primary key, value varchar(100) NOT NULL) partition by range (value);`,
    );

    await searchingDBClient.query(`create table eng_words_pt_09 
      (like eng_words_pt including indexes);`);
    await searchingDBClient.query(
      `alter table eng_words_pt attach partition eng_words_pt_09 for values from ('0') to ('9')`,
    );

    await searchingDBClient.query(`create table eng_words_pt_az 
      (like eng_words_pt including indexes);`);
    await searchingDBClient.query(
      `alter table eng_words_pt attach partition eng_words_pt_az for values from ('a') to ('z')`,
    );
    await searchingDBClient.query(`create table "eng_words_pt_AZ" 
      (like eng_words_pt including indexes);`);
    await searchingDBClient.query(
      `alter table eng_words_pt attach partition "eng_words_pt_AZ" for values from ('A') to ('Z')`,
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
