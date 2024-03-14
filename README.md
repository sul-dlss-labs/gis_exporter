# gis_exporter

*gis_exporter* is a Ruby utility for unpacking "old-style" GIS SDR items to remediate them following changes made during the [Geo Workcycle 2024]. As part of this workcycle GIS items were changed so that accessioned data files were added directly to the item instead of being packaged into ZIP files: `data.zip`  and `data_EPSG_4326.zip`. This unpack these "old style" items, and reaccession them using Preassembly. More about the rationale can be found in [this Google Doc](https://docs.google.com/document/d/1MeImChdSwUvjNBaEQ9WNZFkwL0i2tCfsW9F0fGc-9rk/edit#heading=h.ej7ja278aomg).

Steps to using this utility:

1. Use Argo to export a list of DRUIDs for items accessioned prior to 2024-02-27.
2. Use SDR-GET to export the bags for these DRUIDs (see `druids.txt` in this repository).
3. rsync the bags to `sul-preassembly-prod:/dor/staging/gis-remediation/bags/`.
4. Run gis_exporter: `bin/gis_exporter /dor/staging/gis-remediation/bags/ /dor/staging/gis-remediation/export/`.
5. Use Preassembly to kick off a job to ingest the items.

Rather than doing this for all 20K GIS items, it will be prudent to do them in batches and observe:

1. How many make it through all the workflows.
2. Ensure that the accessioning creates no noticeable bottlenecks for other users.
3. Keep track of which DRUIDs have been processed either by regnerating the list in Argo or updating the druid list.

[Geo Workcycle 2024]: https://github.com/orgs/sul-dlss/projects/49 
