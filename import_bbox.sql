create temporary table tmp_xview_feature_collection (feature_collection json);
copy tmp_xview_feature_collection from '{XVIEW_LABELS}';

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
