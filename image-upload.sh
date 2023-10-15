#!/bin/bash

for img in "$@"; do
	$HOME/.local/bin/rclone copy "$img" files.rahim.li-linode:files.rahim.li/blog && echo "https://files.rahim.li/$(basename "${img}")"
done

