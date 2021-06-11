#!/usr/bin/env bash
set -Eeuo pipefail

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
    versions=( [0-9].[0-9]/ )
fi
versions=( "${versions[@]%/}" )


generated_warning() {
cat <<-EOH
#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#
EOH
}

for version in "${versions[@]}"; do
    for base in alpine{3.12,3.13} {stretch,buster}{/slim,}; do
        dest="$version/$base"
        distr="$(basename "$base")"
        
        case "$base" in
            *slim) template="slim"; tag="slim-$(dirname "$base")" ;;
            alpine*) template="alpine"; tag="${base}" ;;
            *) template="debian"; tag="$distr" ;;
        esac
        
        echo "$base => FROM python:$version-$tag"
        
        [ -d "$dest" ] || continue
        
        template="Dockerfile-${template}.template"
        { generated_warning; cat "$template"; } > "$dest/Dockerfile"

        sed -ri \
            -e 's/^(FROM python):.*/\1:'"$version-$tag"'/' \
    		"$dest/Dockerfile"
    done
done