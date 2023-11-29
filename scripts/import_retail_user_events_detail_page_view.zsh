#!/usr/bin/env zsh

################################################################################
# Environment Variables - Retail API Project
################################################################################

local RETAIL_PROJECT_ID="winter-dataform"
local RETAIL_PROJECT_NUMBER="374294533986"
local RETAIL_LOCATION="global"
local RETAIL_CATALOG="default_catalog"
local RETAIL_IMPORT_GCS_BUCKET="gs://winter-retail/user_events"
local RETAIL_BQ_DATASET="fashion"

local RETAIL_TMP_DIR="${0:A:h}/../tmp"
RETAIL_TMP_DIR="${RETAIL_TMP_DIR:A}"


################################################################################
# Import Retail User Events - Detail Page View - From BigQuery
################################################################################

# Delete Any Files Previously Staged
gsutil -q -m rm -f "${RETAIL_IMPORT_GCS_BUCKET}/staging/*"

# Output the Import User Events - Detail Page View - JSON Request Object
cat <<EOF > "$RETAIL_TMP_DIR/import_user_events_detail_page_view_request.json"
{
  "inputConfig": {
    "bigQuerySource": {
      "projectId": "${RETAIL_PROJECT_ID}",
      "datasetId": "${RETAIL_BQ_DATASET}",
      "tableId": "retail_user_events_detail_page_view",
      "gcsStagingDir": "${RETAIL_IMPORT_GCS_BUCKET}/staging",
      "dataSchema": "user_event"
    }
  },
  "errorsConfig": {
    "gcsPrefix": "${RETAIL_IMPORT_GCS_BUCKET}/errors"
  }
}
EOF

curl -X POST \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token --project=${RETAIL_PROJECT_ID})" \
-H "x-goog-user-project: ${RETAIL_PROJECT_ID}" \
-H "Content-Type: application/json; charset=utf-8" -d @"$RETAIL_TMP_DIR/import_user_events_detail_page_view_request.json" \
"https://retail.googleapis.com/v2/projects/${RETAIL_PROJECT_NUMBER}/locations/${RETAIL_LOCATION}/catalogs/${RETAIL_CATALOG}/userEvents:import"
