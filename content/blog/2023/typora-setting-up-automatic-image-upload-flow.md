---
title: "Setting Up an Automatic Image Upload Flow in Typora"
date: "2023-09-18T04:46:00+04:00"
tags: ["guide"]
---

Hi! 

This will be a quick note / guide for setting up an automatic image upload flow in Typora. To follow along, you will need to have a S3 compatible storage. Actually, any storage system that `rclone` supports. (Note: it is a lot!) 

> Here is the [the overview of systems that rclone support](https://rclone.org/overview/). Ranging from ProtonDrive to S3. Every damn thing, lol!

I have configured a custom domain for my S3 bucket, but it is not a necessity. 

- [Linode instructions for custom domain](https://www.linode.com/docs/products/storage/object-storage/guides/custom-domain/)

- [Rclone](https://rclone.org/) website

## RClone

*Rclone is a command-line program to manage files on cloud storage. It is a feature-rich alternative to cloud vendors' web storage interfaces. [Over 70 cloud storage products](https://rclone.org/#providers) support rclone including S3 object stores, business & consumer file storage services, as well as standard transfer protocols.*

So, to start, we need to create a profile for `rclone`. Type `rclone config file` to see the location for the profiles file. By default, this file won't exist, but you can either create it manually, or use `rclone config` configuration wizard. 

For Linode S3, this is what final config looks like, based on [this guide](https://www.linode.com/docs/guides/rclone-object-storage-file-sync/)

```toml
[<rclone profile name>]
type = s3
provider = Ceph
access_key_id = <key id>
secret_access_key = <key>
endpoint = https://eu-central-1.linodeobjects.com
acl = public-read
```

Now we need a script that takes file names as arguments, and uploads them using `rclone`. 

For Windows, powershell script:

```powershell
for ( $i = 0; $i -lt $args.count; $i++ ) {
    rclone copy $args[ $i ] <rclone profile name>:<bucket name>/blog
    "https://<your s3 domain>/{0}" -f "blog/" + (Split-Path $args[ $i ] -leaf)
}
```

For Unix, bash script:

```bash
# Not implemented yet :(
```

## Typora setup

We need to tell Typora to run some script when an image is inserted (drag/dropped, inserted from menu, etc.). For this, select "**Upload image**" at "**Preferences > Image > When insert...**", and copy line below to "**Preferences > Image > Image upload setting > Command**"

```bat
powershell "<path to script>\image-upload.ps1"
```

Done!

And here you are, a quick demo, showing that we, indeed, can easily upload images!

![Screenshot, automatically uploaded, demonstrating nice image insertion flow](https://files.rahim.li/blog/image-20230918044514313.png)
