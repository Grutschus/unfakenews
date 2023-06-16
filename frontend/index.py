"""
# Index Page of unfakenews
"""


from time import sleep

import streamlit as st
from wallet_connect import wallet_connect

from ipfs import add_image_to_ipfs, add_nft_to_ipfs

# Session handling


st.title("Unfakenews 🗞️")

st.divider()

st.header("Upload news")

st.file_uploader("Upload some news.", type=["png", "jpg", "jpeg"], key="news_nft_upload")
if st.session_state.get("news_nft_upload") is not None:
    st.image(
        st.session_state.get("news_nft_upload"), caption="Uploaded Image.", use_column_width="auto"
    )

st.text_input(
    "Title", help="Enter an expressive title of your news item here.", key="news_nft_title"
)

st.text_area("Description", max_chars=400, key="news_nft_description")

st.checkbox(
    "I understand that once submitted, the news item will be permanently and immutably "
    "saved to the Blockchain. I also understand that after submission, "
    "my reputation is on the line!",
    key="news_nft_confirmation",
)
can_submit = not (
    st.session_state.get("news_nft_upload")
    and st.session_state.get("news_nft_title")
    and st.session_state.get("news_nft_description")
    and st.session_state.get("news_nft_confirmation")
)

if not st.session_state.get("news_nft_submit"):
    st.button(
        "Create NFT",
        disabled=can_submit,
        type="primary",
        help="Make sure to fill out everything.",
        key="news_nft_submit",
    )


if st.session_state.get("news_nft_submit"):
    description = st.session_state.get("news_nft_description")
    title = st.session_state.get("news_nft_title")
    image = st.session_state.get("news_nft_upload")

    with st.spinner("Uploading Image to IPFS..."):
        sleep(1)
        cid = add_image_to_ipfs(image)
    with st.spinner("Creating NFT..."):
        sleep(1)
        nft_meta = {"image_cid": cid, "title": title, "description": description}
        nft_cid = add_nft_to_ipfs(nft_meta)
    st.session_state["news_nft_cid"] = nft_cid
    st.success("NFT created successfully!")
    st.caption("NFT CID: " + nft_cid)

if st.session_state.get("news_nft_cid") and not st.session_state.get("mint_news_nft"):
    nft_cid = st.session_state.get("news_nft_cid")
    wallet_connect(
        label="mint_news_nft", key="mint_news_nft", uri=nft_cid, message="Sign the transaction"
    )

if st.session_state.get("mint_news_nft"):
    receipt = st.session_state.get("mint_news_nft")
    if receipt.get("status") == 1:
        st.success("NFT minted successfully!")
        st.caption(
            f"Transaction Hash: {receipt.get('transactionHash')} \n"
            f"Token ID: {receipt.get('tokenId')}"
        )
    else:
        st.error("NFT minting failed!")
        st.caption(f"Receipt: {receipt}")
