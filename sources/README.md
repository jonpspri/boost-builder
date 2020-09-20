To create a new sha256 checksum file, run the following in this directory.

```
jq -srf create_sha256_checksum_file.jq *.json > ../context/boost.sha256
```
