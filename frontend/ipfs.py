import json
from pathlib import Path

import ipfshttpclient
from PIL import Image

IPFS_NODE = "/dns/host.docker.internal/tcp/5001/http"


def add_image_to_ipfs(uploaded_file) -> str:
    with ipfshttpclient.connect(IPFS_NODE) as client:
        file_dir = Path("tmp")
        file_dir.mkdir(exist_ok=True, parents=True)
        file_path = file_dir.joinpath(uploaded_file.name)
        try:
            with open(file_path, "wb") as f:
                f.write(uploaded_file.getbuffer())
            res = client.add(file_path.as_posix())
        finally:
            file_path.unlink()
        return res["Hash"]


def add_nft_to_ipfs(metadata: dict) -> str:
    with ipfshttpclient.connect(IPFS_NODE) as client:
        res = client.add_json(metadata)
    return res


def get_image_from_ipfs(uri: str):
    elements = uri.split("/")
    cid = elements[-1]
    download_path = Path("tmp")
    with ipfshttpclient.connect(IPFS_NODE) as client:
        client.get(cid, download_path)

    with open(download_path.joinpath(cid).as_posix(), mode="r") as f:
        metadata = json.load(f)
    download_path.joinpath(cid).unlink()
    img_cid = metadata.get("image_cid")
    with ipfshttpclient.connect(IPFS_NODE) as client:
        client.get(img_cid, download_path)

    img = Image.open(download_path.joinpath(img_cid))

    metadata["img"] = img

    download_path.joinpath(img_cid).unlink()

    return metadata
