#!/bin/bash

EXTRACT="
	CREATE TEMPORARY TABLE etl_isrc_track AS SELECT
		r.artist_credit AS artist,
		i.isrc          AS isrc,
		r.name          AS track
	FROM
		recording r,
		isrc      i
	WHERE
		r.id = i.recording
	;
	INSERT INTO etl_isrc_track SELECT
		r.artist_credit AS artist,
		i.isrc          AS isrc,
		t.name          AS track
	FROM
		recording r,
		isrc      i,
		track     t
	WHERE
		r.id    = i.recording
	AND
		r.id    = t.recording
	AND
		r.name != t.name
	;
	CREATE TEMPORARY TABLE etl_isrc_detail AS SELECT
		a.name  AS artist,
		t.track AS track,
		t.isrc  AS isrc
	FROM
		artist         a,
		etl_isrc_track t
	WHERE
		a.id = t.artist
	;
	INSERT INTO etl_isrc_detail SELECT
		a.name  AS artist,
		t.track AS track,
		t.isrc  AS isrc
	FROM
		artist_alias   a,
		etl_isrc_track t
	WHERE
		a.artist = t.artist
	;
	COPY etl_isrc_detail TO '/tmp/etl.$$' WITH BINARY;
"
RELOAD="
	TRUNCATE isrc_detail;
	COPY isrc_detail FROM '/tmp/etl.$$' WITH BINARY;
"

DATABASE=musicbrainz /usr/local/sbin/psql.sh "${EXTRACT}"
DATABASE=rsdl /usr/local/sbin/psql.sh "${RELOAD}"

rm -f /tmp/etl.$$
