import os
import psycopg2
import requests
import subprocess
import zipfile
from dotenv import find_dotenv, load_dotenv
from pathlib import Path


class RetroEventFormatter():
    """ETL tools to work with Retrosheet event data.

    working_dir : string
        Directory to save data to and work out of

    year : integer
        Year to process data for

    conn : psycopg2 connection object
        Database connection for loading
    """

    def __init__(self, working_dir, year, conn):
        self.dir = working_dir
        self.year = year
        self.conn = conn

    def process(self):
        """Collects all Retrosheet event files for a
        single year, cleans them, and adds them to a new
        database table.
        """
        self.download_event_files()
        self.format_event_files()
        self.load_event_files()
        self.cleanup()

    def download_event_files(self):
        """Downloads and unzips raw Retrosheet regular
        season event level summary files into 'data/raw/retro_event'
        """
        loc = f'{self.dir}/retro_event'
        if not os.path.exists(loc):
            os.makedirs(loc, exist_ok=True)

        url = f'https://www.retrosheet.org/events/{self.year}eve.zip'
        r = requests.get(url)
        with open(f'{loc}/{self.year}eve.zip', 'wb') as f:
            f.write(r.content)

        with zipfile.ZipFile(f'{loc}/{self.year}eve.zip', 'r') as zipped:
            zipped.extractall(loc)

    def format_event_files(self):
        """Uses Chadwick to reformat raw event level data
        into a format suitable for adding to a database table.
        Deletes event files when finished.
        """
        cmd = f'cwevent -y {self.year} -f 0-96 {self.year}*.EV* > all{self.year}.csv'
        process = subprocess.Popen(cmd, shell=True, cwd=f'{self.dir}/retro_event/')
        process.communicate()

    def load_event_files(self):
        """Creates a new table and loads a single
        years worth of event data to the database.
        """
        with self.conn.cursor() as cursor:
            cursor.execute(open('src/data/sql/build_events.sql', 'r').read())
            self.conn.commit()

        with open(f'{self.dir}/retro_event/all{self.year}.csv') as f:
            copy = 'COPY raw_events FROM STDIN WITH csv'
            self.conn.cursor().copy_expert(sql=copy, file=f)
            self.conn.commit()

    def cleanup(self):
        for fname in os.listdir(f'{self.dir}/retro_event'):
            if fname.endswith('.EVA') | fname.endswith('.EVN') | fname.endswith('.ROS'):
                os.remove(f'{self.dir}/retro_event/{fname}')

            if fname.endswith(f'TEAM{self.year}'):
                os.remove(f'{self.dir}/retro_event/{fname}')


def main():
    # Set input/output locations
    project_path = Path.cwd()
    raw_path = str((project_path / 'data' / 'raw').resolve())

    # Connect to Retrosheet database
    load_dotenv(find_dotenv())
    retro_db = os.getenv('RETRO_DB')
    retro_user = os.getenv('RETRO_USER')
    retro_pass = os.getenv('RETRO_PASS')
    conn = psycopg2.connect(database=retro_db, user=retro_user, password=retro_pass)

    # Process 2017 event files
    retro = RetroEventFormatter(raw_path, 2017, conn)
    retro.process()


if __name__ == '__main__':
    main()
