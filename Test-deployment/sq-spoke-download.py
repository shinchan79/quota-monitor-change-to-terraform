import requests
import os

def download_file(url, filename):
    """Download a file from URL and save it with given filename"""
    print(f"Downloading {filename}...")
    response = requests.get(url)
    if response.status_code == 200:
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, 'wb') as f:
            f.write(response.content)
        print(f"Successfully downloaded {filename}")
    else:
        print(f"Failed to download {filename}: HTTP {response.status_code}")

def main():
    base_url = "https://solutions-ap-southeast-1.s3.ap-southeast-1.amazonaws.com/quota-monitor-for-aws/v6.3.0"
    
    # Define SQ Spoke assets to download with their new paths
    files = {
        # Utils layer (same as SNS spoke)
        "assete8b91b89616aa81e100a9f9ce53981ad5df4ba7439cebca83d5dc68349ed3703.zip": "spoke/service-quota/source_codes/utils-layer.zip",
        
        # SQ Spoke specific functions
        "asset3701f2abae7e46f2ca278d27abfbafbf17499950bb5782fed31eb776c07ad072.zip": "spoke/service-quota/source_codes/list-manager.zip",
        "asset7382a0addb9f34974a1ea6c6c9b063882af874828f366f5c93b2b7b64db15c94.zip": "spoke/service-quota/source_codes/framework-onEvent.zip",
        "asset4ae69af36e954d598ae25d7f2f8f5ea5ecb93bf4ba61963aa7d8d571cf71ecce.zip": "spoke/service-quota/source_codes/cw-poller.zip"
    }

    # Download each file
    for original_name, new_path in files.items():
        url = f"{base_url}/{original_name}"
        download_file(url, new_path)

if __name__ == "__main__":
    main()