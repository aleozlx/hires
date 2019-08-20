CREATE TABLE partition_ns (
    id SERIAL PRIMARY KEY,
    name VARCHAR(32) UNIQUE NOT NULL, -- name of the partition namespace
    labels VARCHAR[] NOT NULL, -- names of the partitions that exist in the namespace
    created_on TIMESTAMP NOT NULL,
    reference TEXT, -- reference to the associated data shard
    summary BOOLEAN NOT NULL, -- required to show in the summary
    impl_version INT -- data structure impl: v1: jsonb tagging {"part" => 1}, v2: jsonb enum {"namespace"=>"part"}
);

CREATE TABLE frame (
    id SERIAL PRIMARY KEY,
    image TEXT NOT NULL, -- image file name: use ";" to separate multiple associated images
    class_label INT, -- class label: may use binary one hot encoding in multi-label case
    ptr INT, -- index into associated data (perhaps in h5 files)
    partitions jsonb -- denormalized partitioning information
);

CREATE INDEX idx_frame ON frame USING GIN (partitions);

CREATE TABLE bbox (
    id SERIAL PRIMARY KEY,
    frame_id INT REFERENCES frame(id),
    xview_type_id INT,
    xview_cat_id VARCHAR(20),
    xview_bounds_imcoords INT[],
    xview_coordinates GEOMETRY
);

CREATE OR REPLACE FUNCTION merge_arrays(a1 ANYARRAY, a2 ANYARRAY) RETURNS ANYARRAY as $$
  SELECT array_agg(x ORDER BY x)
  FROM (SELECT DISTINCT UNNEST($1 || $2) AS x) s;
$$ LANGUAGE SQL STRICT;

CREATE EXTENSION postgis;

create temporary table tmp_xview_feature_collection (feature_collection json);
copy tmp_xview_feature_collection from '/tank/datasets/research/xView/xView_train.geojson';

INSERT INTO bbox (frame_id, xview_type_id, xview_cat_id, xview_bounds_imcoords, xview_coordinates)
    SELECT
        frame.id,
        xview_type_id,
        xview_cat_id,
        xview_bounds_imcoords,
        xview_coordinates
    FROM (
        SELECT
            ('train_images/' || (feat->'properties'->>'image_id')) AS fname,
            (feat->'properties'->>'type_id')::int AS xview_type_id,
            feat->'properties'->>'cat_id' AS xview_cat_id,
            string_to_array(feat->'properties'->>'bounds_imcoords', ',')::INT[] AS xview_bounds_imcoords,
            ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')) AS xview_coordinates
        FROM (
            SELECT json_array_elements(feature_collection->'features') AS feat
            FROM tmp_xview_feature_collection
        ) as xv_feature_collection
    ) xv
    INNER JOIN frame ON xv.fname = frame.image;

CREATE TABLE class_label (
    id INT PRIMARY KEY, -- label id
    label_name TEXT NOT NULL, -- name of the label
    label_name_long TEXT -- long name of the label
);

create table superpixel_inference (
    id SERIAL PRIMARY KEY,
    frame_id INT REFERENCES frame(id),
    area FLOAT,
    centroid_abs_x INT,
    centroid_abs_y INT,
    -- cov_11 FLOAT,
    -- cov_12 FLOAT,
    -- cov_22 FLOAT,
    -- eigenvector_1_x FLOAT,
    -- eigenvector_1_y FLOAT,
    -- eigenvector_2_x FLOAT,
    -- eigenvector_2_y FLOAT,
    -- eigenvalue_1 FLOAT,
    -- eigenvalue_2 FLOAT,
    -- eccentricity FLOAT,
    -- convexivity FLOAT,
    dcnn_name VARCHAR[16],
    dcnn_feature FLOAT[],
    class_label INT
);

-- create temporary table tmp_xview_labels (values text) on commit drop;
-- copy tmp_xview_labels from '/tank/datasets/research/xView/xView_train.geojson';

-- with xview_sample as (select '{
--     "crs": {
--         "properties": {
--             "name": "urn:ogc:def:crs:OGC:1.3:CRS84"
--         },
--         "type": "name"
--     },
--     "type": "FeatureCollection",
--     "features": [
--         {
--             "type": "Feature",
--             "properties": {
--                 "bounds_imcoords": "2712,1145,2746,1177",
--                 "edited_by": "wwoscarbecerril",
--                 "cat_id": "1040010028371A00",
--                 "type_id": 73,
--                 "ingest_time": "2017/07/24 12:49:09.118+00",
--                 "index_right": 2356,
--                 "image_id": "2355.tif",
--                 "point_geom": "0101000020E6100000616E4E6406A256C03BE6ADA0D6212D40",
--                 "feature_id": 374410,
--                 "grid_file": "Grid2.shp"
--             },
--             "geometry": {
--                 "type": "Polygon",
--                 "coordinates": [
--                     [
--                         [
--                             -90.53169885094464,
--                             14.56603647302396
--                         ],
--                         [
--                             -90.53169885094464,
--                             14.56614473506768
--                         ],
--                         [
--                             -90.53158140073565,
--                             14.56614473506768
--                         ],
--                         [
--                             -90.53158140073565,
--                             14.56603647302396
--                         ],
--                         [
--                             -90.53169885094464,
--                             14.56603647302396
--                         ]
--                     ]
--                 ]
--             }
--         },
--         {
--             "type": "Feature",
--             "properties": {
--                 "bounds_imcoords": "2720,2233,2760,2288",
--                 "edited_by": "wwoscarbecerril",
--                 "cat_id": "1040010028371A00",
--                 "type_id": 73,
--                 "ingest_time": "2017/07/24 17:26:05.701+00",
--                 "index_right": 2356,
--                 "image_id": "2355.tif",
--                 "point_geom": "0101000020E6100000042D0CC705A256C0004F7071E71F2D40",
--                 "feature_id": 394393,
--                 "grid_file": "Grid2.shp"
--             },
--             "geometry": {
--                 "type": "Polygon",
--                 "coordinates": [
--                     [
--                         [
--                             -90.53167232380382,
--                             14.562217332510999
--                         ],
--                         [
--                             -90.53167232380382,
--                             14.562407959236182
--                         ],
--                         [
--                             -90.53153294103244,
--                             14.562407959236182
--                         ],
--                         [
--                             -90.53153294103244,
--                             14.562217332510999
--                         ],
--                         [
--                             -90.53167232380382,
--                             14.562217332510999
--                         ]
--                     ]
--                 ]
--             }
--         }
--     ]
-- }'::json as feature_collection)
-- select
--     feat->'properties'->'image_id' as fname,
--     feat->'properties'->'type_id' as xview_type_id,
--     feat->'properties'->'cat_id' as xview_cat_id,
--     string_to_array(feat->'properties'->>'bounds_imcoords', ',')::int[] as xview_bounds_imcoords,
--     ST_AsText(ST_GeomFromGeoJSON(feat->>'geometry')) as xview_coordinates
-- from (
--     select json_array_elements(feature_collection->'features') as feat
--     from xview_sample
-- ) as f;
