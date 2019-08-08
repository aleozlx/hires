import json, psycopg2, psycopg2.extras
from pathlib import Path
from imeta import metadata
from global_vars import DATABASE, DATASET

def init(conn):
    print('test')
    # import pandas as pd
    # import psycopg2.extras
    # print("Initializing metadata...")
    # cur = conn.cursor()
    # csv_active = Path(DATASET) / 'index.csv'
    # df_meta = pd.read_csv(str(csv_active), index_col=0)
    # active_idx = 0
    # sql = 'INSERT INTO frame (image, ptr, partitions) values %s'
    # labels = {
    #     'part1': 'library',
    #     'part2': 'book_shelves',
    #     'part3': 'conference_room',
    #     'part4': 'cafe',
    #     'part5': 'study_area',
    #     'part6': 'hallway',
    # }
    # values = []
    # for _i, row in df_meta.iterrows():
    #     label = labels[str(Path(row['image']).parent)]
    #     partitions = dict()
    #     if row.active:
    #         partitions['active'] = 1
    #     partitions[label] = 1
    #     partitions['part'] = label
    #     values.append(( ','.join((row['image'], row.depth)), active_idx, json.dumps(partitions)))
    #     if row.active:
    #         active_idx += 1
    # psycopg2.extras.execute_values(cur, sql, values)
    # sql = """INSERT INTO partition_ns (name, labels, created_on, summary) values
    #     ('active', array['active'], now(), true),
    #     ('part', array['library', 'book_shelves', 'conference_room', 'cafe', 'study_area', 'hallway'], now(), true);"""
    # cur.execute(sql)
    # conn.commit()

if __name__ == "__main__":
    metadata(DATABASE, init)