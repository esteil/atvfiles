--==========================================================--
-- Database Schema for ATVFiles                             --
-- Version 1 (5/6/2007)                                     --
-- $Id$                                                     --
-- Copyright (C) 2007 Eric Steil III.  All rights reserved. --
-- This is for SQLite3.                                     --
--==========================================================--

-- mark this as the schema version 1
PRAGMA user_version = 1;

-- contains base metadata
CREATE TABLE media_info (
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- internal id
  url VARCHAR NOT NULL,                 -- url to the media file
  filemtime INTEGER NOT NULL,           -- mtime of the file (for invalidating the cache)
  created INTEGER NOT NULL,             -- when was this entry created?
  updated INTEGER NOT NULL,             -- when was this entry last updated?
  
  -- asset metadata
  duration INTEGER NOT NULL,            -- duration of the file, in ms
  
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
  bookmark_time INTEGER NOT NULL,       -- last played offset in ms (bookmarkTimeInMS)
  play_count INTEGER NOT NULL,          -- how many times has this asset been played (performanceCount)
    
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
