from pathlib import Path

import ipfshttpclient

IPFS_NODE = '/dns/host.docker.internal/tcp/5001/http'

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

