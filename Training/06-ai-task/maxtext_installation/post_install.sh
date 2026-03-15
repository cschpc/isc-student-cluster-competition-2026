export UV_CACHE_DIR=$TMPDIR/uv_cache
uv pip install "maxtext[cuda12]>=0.2.0" --resolution=lowest
install_maxtext_cuda12_github_deps
