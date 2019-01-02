import os
import psycopg2
from dotenv import find_dotenv, load_dotenv


def calc_batting_stats_basic(conn, raw_tbl, batting_tbl):
    query = f"""
        select
            batter as player_id,
            substring(game_id, 4, 4) as year,

        into {batting_tbl}
        from {raw_tbl}
        group by
            player_id,
            year
    """

    with conn.cursor() as cursor:
        cursor.execute(query)
        conn.commit()


def main():

    # Connect to Retrosheet database
    load_dotenv(find_dotenv())
    retro_db = os.getenv('RETRO_DB')
    retro_user = os.getenv('RETRO_USER')
    retro_pass = os.getenv('RETRO_PASS')
    conn = psycopg2.connect(database=retro_db, user=retro_user, password=retro_pass)

    # Build hitting stats
    calc_batting_stats_basic(conn=conn, raw_tbl='raw_events', batting_tbl='stats_batting')


if __name__ == '__main__':
    main()
