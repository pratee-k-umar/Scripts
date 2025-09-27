#!/usr/bin/env bash
set -euo pipefail

URL="https://www.amfiindia.com/spages/NAVAll.txt"
OUT="nav_scheme_asset.tsv"
TMP="$(mktemp -t navall.XXXXXX)"

cleanup() { rm -f "$TMP"; }
trap cleanup EXIT

echo "Downloading $URL ..."
curl -sSf "$URL" -o "$TMP"

sample_line="$(grep -v '^[[:space:]]*$' "$TMP" | grep -v '^#' | head -n1 || true)"

if [[ -z "$sample_line" ]]; then
  echo "No data found in $URL" >&2
  exit 1
fi

if echo "$sample_line" | grep -qi "scheme"; then
  echo "Header detected. Parsing using header..."
  awk -F'|' '
  NR==1 {
    # build lowercase map of headers
    for(i=1;i<=NF;i++){
      h=tolower($i)
      gsub(/^[ \t]+|[ \t]+$/,"",h)
      hdr[h]=i
    }
    name_idx = (("scheme name" in hdr) ? hdr["scheme name"] : (("scheme_name" in hdr) ? hdr["scheme_name"] : (("schemename" in hdr) ? hdr["schemename"] : 0)))
    nav_idx  = (("net asset value" in hdr) ? hdr["net asset value"] : (("nav" in hdr) ? hdr["nav"] : (("asset value" in hdr) ? hdr["asset value"] : 0)))
    if(name_idx==0 || nav_idx==0){
      for(k in hdr){
        if(index(k,"scheme")) name_idx = hdr[k]
        if(index(k,"asset") || index(k,"nav") || index(k,"net")) nav_idx = hdr[k]
      }
    }
    if(name_idx==0 || nav_idx==0){
      print "ERROR: could not determine header indices (name_idx=" name_idx ", nav_idx=" nav_idx ")" > "/dev/stderr"
      exit 1
    }
    print "SchemeName\tAssetValue"
    next
  }
  NR>1 {
    if(NF>=name_idx && NF>=nav_idx){
      name = $name_idx
      value = $nav_idx
      gsub(/^[ \t]+|[ \t]+$/,"",name)
      gsub(/^[ \t]+|[ \t]+$/,"",value)
      gsub(/\t/," ",name)
      gsub(/\r/,"",name)
      gsub(/\r/,"",value)
      print name "\t" value
    }
  }' "$TMP" > "$OUT"

else
  echo "No header detected. Using default positions with heuristics..."
  awk -F'|' 'BEGIN{OFS="\t"; print "SchemeName","AssetValue"}
  {
    line = $0
    if(length(line)==0) next

    # sanitize fields
    for(i=1;i<=NF;i++){
      f[i]=$i
      gsub(/^[ \t]+|[ \t]+$/,"",f[i])
    }

    # guess nav field: prefer field 4 if numeric-ish
    nav_idx = 4
    if(!(f[nav_idx] ~ /^[0-9]+([,.][0-9]+)?$/)){
      found = 0
      for(i=1;i<=NF;i++){
        if(f[i] ~ /^[0-9]+([,.][0-9]+)?$/){
          nav_idx = i
          found = 1
          break
        }
      }
    }

    # guess scheme name: prefer field 3, else longest alpha-containing field
    name_idx = 3
    if(length(f[name_idx])<3 || f[name_idx] ~ /^[0-9]+$/){
      best_len = 0
      for(i=1;i<=NF;i++){
        if(f[i] ~ /[A-Za-z]/ && length(f[i])>best_len){
          best_len = length(f[i])
          name_idx = i
        }
      }
    }

    name = f[name_idx]
    nav  = f[nav_idx]
    gsub(/,/,"",nav)
    gsub(/\t/," ",name)
    print name, nav
  }' "$TMP" > "$OUT"
fi

echo "Saved TSV to $OUT"
