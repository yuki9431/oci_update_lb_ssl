# oci_update_lb_ssl
Automatic update of SSL certificates for OCI LB.

## Requirement
You have OCI CLI installed on your server and setup INSTANCE PRINCIPALS.
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [INSTANCE PRINCIPALS](https://docs.oracle.com/en-us/iaas/Content/Identity/Tasks/callingservicesfrominstances.htm)

## How to Use
[ブログ](https://www.grimoire.tokyo/2022/07/11/post-408/)で詳しく説明してます。

Please write oci_update_lb_ssl.conf.

```sh
mv oci_update_lb_ssl.conf.sample oci_update_lb_ssl.conf

vi oci_update_lb_ssl.conf

```

Then just run.

```sh
./oci_update_lb_ssl.sh

```

# Example
```sh
# Example use whith certbot
certbot renew --deploy-hook "/usr/local/bin/oci_update_lb_ssl/oci_update_lb_ssl.sh" &> /var/log/oci_update_lb_ssl.log

```

It can be run automatically by installing it in one of the following locations.

- /etc/crontab/
- /etc/cron.\*/*.
- systemctl list-timers



## Logs
Be sure to set logrotate.

```shell
# Example logrotate config
cat /etc/logrotate.d/oci_update_lb_ssl

/var/log/oci_update_lb_ssl.log {
    weekly
    rotate 12
    compress
    delaycompress
    missingok
    notifempty
    create 0664 root root
}

```

## Author
[Dillen H. Tomida](https://twitter.com/t0mihir0)

## License
This software is licensed under the MIT license, see [LICENSE](./LICENSE) for more information.
