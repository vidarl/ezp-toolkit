-- https://doc.ezplatform.com/en/2.5/updating/4_update_2.5/#page-builder

CREATE INDEX ezpage_map_zones_pages_zone_id ON ezpage_map_zones_pages(zone_id);
CREATE INDEX ezpage_map_zones_pages_page_id ON ezpage_map_zones_pages(page_id);
CREATE INDEX ezpage_map_blocks_zones_block_id ON ezpage_map_blocks_zones(block_id);
CREATE INDEX ezpage_map_blocks_zones_zone_id ON ezpage_map_blocks_zones(zone_id);
CREATE INDEX ezpage_map_attributes_blocks_attribute_id ON ezpage_map_attributes_blocks(attribute_id);
CREATE INDEX ezpage_map_attributes_blocks_block_id ON ezpage_map_attributes_blocks(block_id);
CREATE INDEX ezpage_blocks_design_block_id ON ezpage_blocks_design(block_id);
CREATE INDEX ezpage_blocks_visibility_block_id ON ezpage_blocks_visibility(block_id);
CREATE INDEX ezpage_pages_content_id_version_no ON ezpage_pages(content_id, version_no);
