select distinct on (frame_id) * from bbox;

-- list all type_id's
select distinct on (xview_type_id) * from bbox;

select count(distinct xview_type_id) from bbox;

-- bounding boxes of one image chip
select count(*) from frame join bbox on frame.id = bbox.frame_id where frame.image = 'train_images/1036.tif';

select count(distinct bbox.xview_type_id) from frame join bbox on frame.id = bbox.frame_id where frame.image = 'train_images/1036.tif';

select distinct on (bbox.xview_type_id) frame.id, image, class_label.label_name, bbox.xview_bounds_imcoords from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id where frame.image = 'train_images/1036.tif';

select image, class_label.label_name, bbox.xview_bounds_imcoords from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id where frame.image = 'train_images/1036.tif';

select class_label.label_name, count(class_label.label_name) from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id where frame.image = 'train_images/1036.tif' group by label_name order by count(class_label.label_name);

select image, class_label.label_name, bbox.xview_bounds_imcoords from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id where frame.image = 'train_images/1036.tif' and class_label.label_name in ('Truck', 'Small Car') order by class_label.label_name;

select image, class_label.label_name, bbox.xview_bounds_imcoords
from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id
where frame.image = 'train_images/1036.tif' and class_label.label_name in ('Truck', 'Small Car')
order by (bbox.xview_bounds_imcoords[3]-bbox.xview_bounds_imcoords[1])*(bbox.xview_bounds_imcoords[4]-bbox.xview_bounds_imcoords[2]);

select image, class_label.label_name, bbox.xview_bounds_imcoords
from frame join bbox on frame.id = bbox.frame_id join class_label on bbox.xview_type_id = class_label.id
where frame.image = 'train_images/1036.tif'
       and bbox.xview_bounds_imcoords[1] < 120 and bbox.xview_bounds_imcoords[2] < 1870 and bbox.xview_bounds_imcoords[3] > 120 and bbox.xview_bounds_imcoords[4] > 1870
       and class_label.label_name in ('Truck', 'Small Car')
order by (bbox.xview_bounds_imcoords[3]-bbox.xview_bounds_imcoords[1])*(bbox.xview_bounds_imcoords[4]-bbox.xview_bounds_imcoords[2]);