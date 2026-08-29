import subprocess

'''
Downloads the dataset and saves it in a designated path.
'''

def download_dataset(dataset_name, path):
    subprocess.run(
        [
            "kaggle",
            "datasets",
            "download",
            "-d",
            dataset_name,
            "-p",
            path,
            "--unzip"
        ]
    )

if __name__ == "__main__":
    download_dataset(
        "olistbr/brazilian-ecommerce",
        "data/raw"
    )