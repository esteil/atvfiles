-- schema 1 -> 2
-- adds a playlist table

-- ALTER TABLE media_info ADD COLUMN asset_type VARCHAR(255) NOT NULL DEFAULT 'file';
-- the sqlite on the atv doesn't support that, so this uglyness simulates it
-- contains base metadata
CREATE TABLE new_media_info (
  id INTEGER PRIMARY KEY AUTOINCREMENT, -- internal id
  url VARCHAR NOT NULL,                 -- url to the media file
  filemtime VARCHAR NOT NULL DEFAULT -1,           -- mtime of the file (for invalidating the cache)
  metamtime VARCHAR NOT NULL DEFAULT -1,           -- mtime of the metadata file
  
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
  asset_type VARCHAR DEFAULT 'file',     -- the asset type
    
  UNIQUE (url)
);
INSERT INTO new_media_info SELECT *, 'file' AS asset_type FROM media_info;
DROP TABLE media_info;
ALTER TABLE new_media_info RENAME TO media_info;

CREATE TABLE playlists (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  url VARCHAR(255) NOT NULL
);

-- links to the appropriate asset
CREATE TABLE playlist_contents (
  playlist_id INTEGER NOT NULL,
  asset_id INTEGER NOT NULL, 
  position INTEGER
);
