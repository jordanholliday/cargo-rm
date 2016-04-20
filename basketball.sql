CREATE TABLE teams (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  arena_id INTEGER,

  FOREIGN KEY(arena_id) REFERENCES arena(id)
);

CREATE TABLE players (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL,
  team_id INTEGER,

  FOREIGN KEY(team_id) REFERENCES team(id)
);

CREATE TABLE arenas (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

INSERT INTO
  arenas (id, name)
VALUES
  (1, "Quicken Loans Arena"),
  (2, "MSG"),
  (3, "Oracle Arena");

INSERT INTO
  players (id, fname, lname, team_id)
VALUES
  (1, "LeBron", "James", 1),
  (2, "Kyrie", "Irvin", 1),
  (3, "Carmelo", "Anthony", 2),
  (4, "Stephen", "Curry", 3),
  (5, "Draymond", "Green", 3),
  (6, "Charles", "Barkley", NULL);

INSERT INTO
  teams (id, name, arena_id)
VALUES
  (1, "Cleveland Cavaliers", 1),
  (2, "New York Knickerbockers", 2),
  (3, "Golden State Warriors", 3);
