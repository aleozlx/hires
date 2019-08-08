import json, psycopg2, psycopg2.extras
from pathlib import Path
from imeta import metadata
from global_vars import DATABASE, DATASET

def init(conn):
    print("Initializing metadata...")
    dataset = Path(DATASET)
    train_images = (dataset/'train_images').glob('*.tif')
    val_images = (dataset/'val_images').glob('*.tif')
    
    cur = conn.cursor()
    active_idx = 0
    sql = 'INSERT INTO frame (image, ptr, partitions) values %s'
    values = []
    for fname in train_images:
        partitions = dict()
        partitions['active'] = 1
        values.append(( str(fname.relative_to(dataset)), active_idx, json.dumps(partitions) ))
        if 1:
            active_idx += 1
    for fname in val_images:
        partitions = dict()
        partitions['active'] = 1
        values.append(( str(fname.relative_to(dataset)), active_idx, json.dumps(partitions) ))
        if 1:
            active_idx += 1
    psycopg2.extras.execute_values(cur, sql, values)
    sql = """INSERT INTO partition_ns (name, labels, created_on, summary) values
        ('active', array['active'], now(), true);"""
    cur.execute(sql)
    conn.commit()

def bbox():
    # dataset = Path(DATASET)
    # with open(dataset/'xView_train.geojson') as f:
    #     xview_labels = json.load(f)
    # feature_collection = xview_labels['features']
    # print(len(feature_collection))

    conn = psycopg2.connect(DATABASE)
    cur = conn.cursor()
    cur.execute("SELECT count(*) FROM bbox;")
    (r, ) = cur.fetchone()
    if r == 0:
        print("Importing xView Feature Collection")
        with open('import_bbox.sql') as f:
            sql = f.read()
        cur.execute(sql.format(XVIEW_LABELS=str(Path(DATASET)/'xView_train.geojson')))
        conn.commit()
        cur.execute("SELECT count(*) FROM bbox;")
        (r, ) = cur.fetchone()
    print('xView Feature Collection:', r)
    conn.close()

if __name__ == "__main__":
    metadata(DATABASE, init)
    bbox()