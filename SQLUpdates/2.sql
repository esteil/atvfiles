-- schema 1 -> 2
-- adds a playlist table

-- ALTER TABLE media_info ADD COLUMN asset_type VARCHAR(255) NOT NULL DEFAULT 'file';
CREATE TABLE new_media_info AS SELECT *, 'file' AS asset_type FROM media_info;
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
