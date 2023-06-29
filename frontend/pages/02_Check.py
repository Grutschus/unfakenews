from time import sleep

import streamlit as st
from wallet_connect import wallet_connect

from ipfs import get_image_from_ipfs

st.set_page_config(
    page_title="Unfakenews",
    initial_sidebar_state="collapsed",
    page_icon="🗞️",
)

qry = st.experimental_get_query_params()
if qry.get("tokenID"):
    st.session_state["tokenID"] = int(qry.get("tokenID")[0])
    wallet_connect(
        label="instant_check_news_nft",
        key="instant_check_news_nft",
        token_id=st.session_state["tokenID"],
        message="Verify the token",
    )
    st.session_state["check_news_nft"] = st.session_state.get(
        "instant_check_news_nft"
    )


if st.session_state.get("check_news_nft") is not None:
    result = st.session_state.get("check_news_nft")

    if result.get("status") == -1:
        st.error(
            "Something went wrong while checking the verification status. \n"
            "Did you enter the correct token id?"
        )
        st.experimental_rerun()

    uri = result.get("uri")
    metadata = get_image_from_ipfs(uri)
    st.title(metadata.get("title"))
    st.write(metadata.get("description"))
    st.image(metadata.get("img"))

    if result.get("status") == 0:
        st.warning("This token has not been verified yet!")
    elif result.get("status") == 1:
        st.success("This token is verified to be true!")
        st.balloons()
    elif result.get("status") == 2:
        st.error("This token is verified fake!")
else:
    if st.session_state.get("tokenID") is None:
        st.session_state["tokenID"] = -1

    token_id = st.session_state.get("tokenID")
    if token_id < 0:
        st.number_input(
            label="Enter a Token ID to verify",
            min_value=0,
            step=1,
            key="tokenID",
        )
    else:
        st.write(f"Token ID: {token_id}")
        wallet_connect(
            label="check_news_nft",
            key="check_news_nft",
            token_id=token_id,
            message="Verify the token",
        )
        st.session_state["tokenID"] = None
