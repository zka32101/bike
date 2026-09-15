#!/usr/bin/env python3
"""Generate a minimal google-services.json for debug builds."""

import json
import os

def generate_google_services_json(output_path):
    """Create a minimal valid Firebase config for debug builds."""
    config = {
        "project_info": {
            "project_number": "0",
            "project_id": "debug-project",
            "storage_bucket": "debug-project.appspot.com"
        },
        "client": [
            {
                "client_info": {
                    "mobilesdk_app_id": "1:0:android:debug",
                    "android_client_info": {
                        "package_name": "com.yourwish.bikelicensekore"
                    }
                },
                "oauth_client": [],
                "api_key": [],
                "services": {
                    "analytics_service": {"status": 1},
                    "appinvite_service": {"status": 1},
                    "ads_service": {"status": 1}
                }
            }
        ],
        "configuration_version": "1"
    }

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w") as f:
        json.dump(config, f, indent=2)
    print(f"Generated google-services.json at {output_path}")

if __name__ == "__main__":
    generate_google_services_json("android/app/google-services.json")
