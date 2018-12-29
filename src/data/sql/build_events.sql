/*

Builds table for storing output of Retrosheet event
logs, parsed out by Chadwick's `cwevent`. Written
for a Postgres database.

Adapted from https://github.com/alexreisner/baseball_data/blob/master/retrosheet/events.sql

*/

DROP TABLE IF EXISTS raw_events;

DROP TYPE IF EXISTS enum_bool;
DROP TYPE IF EXISTS enum_hand;
DROP TYPE IF EXISTS enum_batted_ball;
DROP TYPE IF EXISTS enum_error;

CREATE TYPE enum_bool AS ENUM ('T', 'F');
CREATE TYPE enum_hand AS ENUM('L', 'R');
CREATE TYPE enum_batted_ball AS ENUM('','F','L','P','G');   -- fly, line, popup, ground
CREATE TYPE enum_error AS ENUM('T','F','N','D');            -- T=throwing, F=fielding

CREATE TABLE raw_events (
  game_id VARCHAR(12) NOT NULL,
  visiting_team CHAR(3),                      -- 3-letter code
  inning SMALLINT NOT NULL,                   -- 1 or higher
  batting_team BOOLEAN NOT NULL,              -- 0=visitor, 1=home
  outs SMALLINT NOT NULL,                     -- 0, 1, or 2
  balls SMALLINT DEFAULT NULL,                -- 0-3
  strikes SMALLINT DEFAULT NULL,              -- 0-2
  pitch_sequence VARCHAR(40) DEFAULT NULL,    -- string of letter codes for each pitch
  vis_score SMALLINT NOT NULL,                -- visiting team's runs before play
  home_score SMALLINT NOT NULL,
  batter VARCHAR(8) NOT NULL,                 -- batter's player code
  batter_hand enum_hand,
  res_batter VARCHAR(8) NOT NULL,             -- responsible batter's player code
  res_batter_hand enum_hand,
  pitcher VARCHAR(8) NOT NULL,                -- pitcher's player code
  pitcher_hand enum_hand,
  res_pitcher VARCHAR(8) NOT NULL,
  res_pitcher_hand enum_hand,
  catcher VARCHAR(8) DEFAULT NULL,
  first_base VARCHAR(8) DEFAULT NULL,
  second_base VARCHAR(8) DEFAULT NULL,
  third_base VARCHAR(8) DEFAULT NULL,
  shortstop VARCHAR(8) DEFAULT NULL,
  left_field VARCHAR(8) DEFAULT NULL,
  center_field VARCHAR(8) DEFAULT NULL,
  right_field VARCHAR(8) DEFAULT NULL,
  first_runner VARCHAR(8) DEFAULT NULL,
  second_runner VARCHAR(8) DEFAULT NULL,
  third_runner VARCHAR(8) DEFAULT NULL,
  event_text VARCHAR(250) NOT NULL,           -- Project Scoresheet format (approx) play description
  leadoff_flag enum_bool NOT NULL,            -- leadoff batter?
  pinchhit_flag enum_bool NOT NULL,           -- pinch hitter?
  defensive_position SMALLINT NOT NULL,       -- 0-9
  lineup_position SMALLINT NOT NULL,          -- 1-9
  event_type SMALLINT NOT NULL,               -- 0-24 (see Retrosheet documentation format.txt for details)
  batter_event_flag enum_bool NOT NULL,       -- event terminated batter's appearance?
  ab_flag enum_bool NOT NULL,                 -- batter charged with an AB?
  hit_value SMALLINT NOT NULL,                -- 0-4
  sh_flag enum_bool NOT NULL,                 -- sac hit?
  sf_flag enum_bool NOT NULL,                 -- sac fly?
  outs_on_play SMALLINT NOT NULL,             -- 0-3
  double_play_flag enum_bool,                 -- double play occurred?
  triple_play_flag enum_bool,                 -- triple play occurred?
  rbi_on_play SMALLINT NOT NULL,              -- 0-4
  wild_pitch_flag enum_bool,                  -- was a wild pitch?
  passed_ball_flag enum_bool,                 -- was a passed ball?
  fielded_by SMALLINT,                        -- position of fielding player
  batted_ball_type enum_batted_ball,          -- fly, line, popup, ground
  bunt_flag enum_bool,
  foul_flag enum_bool,
  hit_location VARCHAR(5),                    -- Project Scoresheet field location description or 0
  num_errors SMALLINT,                        -- 0-3
  player_error_1st SMALLINT,                  -- 1-9
  error_type_1st enum_error,                  -- T=throwing, F=fielding
  player_error_2nd SMALLINT,                  -- 1-9
  error_type_2nd enum_error,                  -- T=throwing, F=fielding
  player_error_3rd SMALLINT,                  -- 1-9
  error_type_3rd enum_error,                  -- T=throwing, F=fielding
  batter_dest SMALLINT,                       -- 0-4, 5 if scores and unearned, 6 if scores team unearned
  runner_on_1st_dest SMALLINT,                -- 0-4, 5 if scores and unearned, 6 if scores team unearned
  runner_on_2nd_dest SMALLINT,                -- 0-4, 5 if scores and unearned, 6 if scores team unearned
  runner_on_3rd_dest SMALLINT,                -- 0-4, 5 if scores and unearned, 6 if scores team unearned
  play_on_batter VARCHAR(20),                 -- Project Scoresheet-style play description
  play_on_runner_on_1st VARCHAR(20),          -- Project Scoresheet-style play description
  play_on_runner_on_2nd VARCHAR(20),          -- Project Scoresheet-style play description
  play_on_runner_on_3rd VARCHAR(20),          -- Project Scoresheet-style play description
  sb_for_runner_on_1st_flag enum_bool,
  sb_for_runner_on_2nd_flag enum_bool,
  sb_for_runner_on_3rd_flag enum_bool,
  cs_for_runner_on_1st_flag enum_bool,
  cs_for_runner_on_2nd_flag enum_bool,
  cs_for_runner_on_3rd_flag enum_bool,
  po_for_runner_on_1st_flag enum_bool,
  po_for_runner_on_2nd_flag enum_bool,
  po_for_runner_on_3rd_flag enum_bool,
  res_pitcher_for_runner_on_1st VARCHAR(8) NOT NULL, -- responsible pitcher's player code ("" if none)
  res_pitcher_for_runner_on_2nd VARCHAR(8) NOT NULL, -- responsible pitcher's player code ("" if none)
  res_pitcher_for_runner_on_3rd VARCHAR(8) NOT NULL, -- responsible pitcher's player code ("" if none)
  new_game_flag enum_bool,
  end_game_flag enum_bool,
  pinch_runner_on_1st enum_bool,
  pinch_runner_on_2nd enum_bool,
  pinch_runner_on_3rd enum_bool,
  runner_removed_for_pinch_runner_on_1st VARCHAR(8) DEFAULT NULL, -- replaced player code ("" if none)
  runner_removed_for_pinch_runner_on_2nd VARCHAR(8) DEFAULT NULL, -- replaced player code ("" if none)
  runner_removed_for_pinch_runner_on_3rd VARCHAR(8) DEFAULT NULL, -- replaced player code ("" if none)
  batter_removed_for_pinch_hitter VARCHAR(8) DEFAULT NULL,        -- replaced player code ("" if none)
  position_of_batter_removed_for_pinch_hitter SMALLINT,           -- zero if no pinch hitter
  fielder_with_first_putout SMALLINT DEFAULT NULL,
  fielder_with_second_putout SMALLINT DEFAULT NULL,
  fielder_with_third_putout SMALLINT DEFAULT NULL,
  fielder_with_first_assist SMALLINT DEFAULT NULL,
  fielder_with_second_assist SMALLINT DEFAULT NULL,
  fielder_with_third_assist SMALLINT DEFAULT NULL,
  fielder_with_fourth_assist SMALLINT DEFAULT NULL,
  fielder_with_fifth_assist INT DEFAULT NULL,
  event_id SMALLINT NOT NULL,
  PRIMARY KEY (game_id, event_id, event_text, event_type)
);
