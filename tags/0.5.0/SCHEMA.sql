--==========================================================--
-- Database Schema for ATVFiles                             --
-- Version 1 (5/6/2007)                                     --
-- $Id$                                                     --
-- Copyright (C) 2007 Eric Steil III.  All rights reserved. --
-- This is for SQLite3.                                     --
--==========================================================--

-- schema version: 1

-- this just holds the schema version for convenience
CREATE TABLE schema_info (
  version INTEGER
);
INSERT INTO schema_info (version) VALUES (0);

-- contains base metadata
CREATE TABLE media_info (
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- internal id
  url VARCHAR NOT NULL,                 -- url to the media file
  filemtime VARCHAR NOT NULL,           -- mtime of the file (for invalidating the cache)
  metamtime VARCHAR NOT NULL,           -- mtime of the metadata file
  
  -- asset metadata
  duration INTEGER DEFAULT 0,            -- duration of the file, in ms
  mediaType VARCHAR DEFAULT "movie",    -- type of the media file
  
  -- BRMediaAsset info
  -- these columns match names exactly with the BRMediaAsset methods
  title VARCHAR,
  artist VARCHAR,
  mediaSummary VARCHAR,
  mediaDescription VARCHAR,
  publisher VARCHAR,
  composer VARCHAR,
  copyright VARCHAR,
  userStarRating NUMERIC,
  starRating NUMERIC,
  rating VARCHAR, -- TV-MA, PG, etc.
  seriesName VARCHAR,
  broadcaster VARCHAR,
  episodeNumber VARCHAR,
  season INTEGER,
  episode INTEGER,
  primaryGenre VARCHAR,
  dateAcquired VARCHAR,
  datePublished VARCHAR,
  
  -- other important data
  bookmark_time INTEGER DEFAULT 0,       -- last played offset in ms (bookmarkTimeInMS)
  play_count INTEGER DEFAULT 0,          -- how many times has this asset been played (performanceCount)
    
  UNIQUE (url)
);

-- contains genres
CREATE TABLE media_genres (
  media_id INTEGER,
  genre VARCHAR
);

CREATE TABLE media_cast (
  media_id INTEGER,
  name VARCHAR
);

CREATE TABLE media_producers (
  media_id INTEGER,
  name VARCHAR
);

CREATE TABLE media_directors (
  media_id INTEGER,
  name VARCHAR
);
