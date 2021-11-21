#!/usr/bin/env bash
set -Eeuo pipefail

cmd="${@:1:1}"
versions=( "${@:2}" )


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
    for base in alpine{3.12,3.13,3.14} {slim-,}{stretch,buster,bullseye}; do
        dest="$version/$base"
        distr="$(basename "$base")"
        
        case "$base" in
            slim*) template="slim"; tag="$base" ;;
            alpine*) template="alpine"; tag="$base" ;;
            *) template="debian"; tag="$distr" ;;
        esac
        
        [ -d "$dest" ] || continue
        
        case "$cmd" in
            generate)
                echo "$base => FROM python:$version-$tag => $dest"
        
                template="Dockerfile-${template}.template"
                { generated_warning; cat "$template"; } > "$dest/Dockerfile"
        
                sed -ri \
                    -e 's/^(FROM python):%%PLACEHOLDER%%/\1:'"$version-$tag"'/' \
                "$dest/Dockerfile"
                ;;
            build)
                docker buildx build \
                    --platform linux/386,linux/amd64,linux/arm/v7,linux/arm64 \
                    -t "kyzimaspb/flask:$version-$tag" \
                    -f "$dest/Dockerfile" .
                ;;
            *)
              echo "Unknown command"
              ;;
        esac
    done
done