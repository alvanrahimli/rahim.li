
for ( $i = 0; $i -lt $args.count; $i++ ) {
    rclone copy $args[ $i ] files.rahim.li-linode:files.rahim.li/blog
    "https://files.rahim.li/{0}" -f "blog/" + (Split-Path $args[ $i ] -leaf)
}
