/*

Builds table for storing calculated batting metrics
of a given player across a given year. Written for
a Postgres database.

*/


DROP TABLE IF EXISTS stats_batting;

CREATE TABLE stats_batting (
	player_id VARCHAR(8) NOT NULL,
	year SMALLINT NOT NULL,
	G SMALLINT,
	AB SMALLINT,
	R SMALLINT,
	H SMALLINT,
	2B SMALLINT,
	3B SMALLINT,
	HR SMALLINT,
	RBI SMALLINT,
	BB SMALLINT,
	IBB SMALLINT,
	SO SMALLINT,
	AVG NUMERIC(1, 3),
	OBP NUMERIC(1, 3),
	SLG NUMERIC(1, 3),
	PRIMARY KEY (player_id, year)
);
