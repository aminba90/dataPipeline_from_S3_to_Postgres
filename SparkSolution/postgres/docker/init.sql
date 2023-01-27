\c upday;    
-- Creation of article_performance table
CREATE TABLE IF NOT EXISTS article_performance (
 article_id VARCHAR(36),
 "date" DATE,
 title VARCHAR(250),
 category	VARCHAR(30),
 card_views INT,
 article_views INT
);

-- Creation of user_performance table
CREATE TABLE IF NOT EXISTS user_performance  (
  user_id VARCHAR(32),
  "date" DATE,
  ctr FLOAT
);