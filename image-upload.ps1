
for ( $i = 0; $i -lt $args.count; $i++ ) {
    rclone copy $args[ $i ] rahim-li:rahim-li
    "https://cdn.rahim.li/{0}" -f (Split-Path $args[ $i ] -leaf)
}
