"""
# Index Page of unfakenews
"""


from time import sleep

import streamlit as st
from wallet_connect import wallet_connect

from ipfs import add_image_to_ipfs, add_nft_to_ipfs

st.title("Unfakenews 🗞️")

wallet_button = wallet_connect(label="wallet", key="wallet")
st.write(f"Wallet {wallet_button} connected.")

st.divider()

st.header("Upload news")

uploaded_file = st.file_uploader(
    "Upload some news.", type=["png", "jpg", "jpeg"], key="news_upload"
)
if uploaded_file is not None:
    st.image(uploaded_file, caption="Uploaded Image.", use_column_width="auto")

title = st.text_input("Title", help="Enter an expressive title of your news item here.")

description = st.text_area("Description", max_chars=400)

confirmation = st.checkbox(
    "I understand that once submitted, the news item will be permanently and immutably "
    "saved to the Blockchain. I also understand that after submission, "
    "my reputation is on the line!",
    key="confirmation",
)
can_submit = not (uploaded_file and title and description and confirmation and wallet_button)
if st.button(
    "Submit", disabled=can_submit, type="primary", help="Make sure to fill out everything."
):
    with st.spinner("Uploading Image to IPFS..."):
        sleep(1)
        cid = add_image_to_ipfs(uploaded_file)
    with st.spinner("Creating NFT..."):
        nft_meta = {"image_cid": cid, "title": title, "description": description}
        nft_cid = add_nft_to_ipfs(nft_meta)
    
    st.success("NFT created successfully!")
    transaction = wallet_connect(label="mint_news_nft", key="mint_news_nft", uri=nft_cid)
    st.write(f"Transaction hash: {transaction}")
    

