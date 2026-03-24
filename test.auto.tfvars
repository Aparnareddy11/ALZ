# Required ARC GitHub App inputs
github_config_url          = "https://github.com/Aparnareddy11/ALZ"
github_app_id              = "3065029"
github_app_installation_id = "115599835"

# Use a heredoc so multiline PEM content stays valid.
github_app_private_key = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAyY6k3Q+8DyiApbaGKqvjfqVvbGOMcLJLy6NVsBDx4NBjKdv3
KSqBqlWVtv+x1frQrGeB1b+SJ3Q9/435EvM+3VuI/yZuLLHQZn47BXDzO/zCAn4+
GKPTYCAnWojS7Kh6c83wfdy6F++6hTFuJdwb8d9+Z1wwwDoNwYEhGZRER1I2gsnE
KvarbTRtQ08lzsCBMpRsBSFaUqXytYpdc5mClM0vZ9DDr5g5elv2Su1nV5zxTHFh
22xK2iuKgXfOSCD9/Kb1h9tKJFr/kmjtK9dVUOmQpbR3VOH6Fs6xxAG+jnAgiGF3
LdRU6nsOFreQuioQUr2tqnbh/vM0wsXE/x3jKQIDAQABAoIBAQCfC4IoNfxNccZh
/O9NyKkRDHYp7zuoyehpXg+FiTl0DrvREhOsVjBPOo2TA51OnkX/ZQXcpvgrTdyG
RX9fZrYacdpei/KwLfemiMEGACTPFxn4YamaQ9vNpFGpbQITYLaPntfAWWY28SIb
a+/gzBj4+USDRwnpBWZJZR27U3W1WFEMNboL4xGcMp4/bZcHW5kz82tIKHEQ9LUm
5NCPDETM7DJxVPv+eOi9Ja2wnvt6gOJV8CwQebLGJNWdTLVyb3irbj4fHEojcgoV
6lt1z99D7VeBADwOgiWA2fiCPDA04IeZwiRVhJfrAwN5DqZoC5h0gSM/em7Q+HUq
Il7CvcwBAoGBAPKOfkX8V7QDg2d0f1hGFUjDqXRpDrIYkMVaEHcxe5PDMMLLCyO4
QSBYP3a0rmP7jf/4JonMmU2czq35TH6bJW5KXDWxV0ZCQ8gyMfl6fn2frYbjWcka
BhdwWtdE3Qk6Tr1CTvgqwFc9DLmB3Z66kJJ8dT6xqx69HFA2OD4SjrfBAoGBANS6
bpHJh737qjgA8v9MrY3gs9Mbs/Yv74tgHqX0WnxaGxNzKZ1LsuaH7VZwQRJrxNKV
dKTyoOBFdBbnvPcb7ykIV/L3x5m12pjjG7+Gj1cOApZ0fLvCp5cdEH6CU/Oq4DrC
TmyPGQh7IZuyeS3u6sNeVs91yu37M8KCAEfSbcVpAoGBAMxsr5vIWxpKQ7szgggh
uNqEnRKRYGNVNN4/U9VBDQex4Cyr9415QtpBxesDyF5Xqovq1oAYwbOZzs7tZzzl
ARz86s4N0qJSQtI9C8VZKbYyl4sxnYBRwISMmuMHFMssKyRy+B9L2KMtvsWx39hh
IGt1HVNjZfcYJv6rU6ds+H+BAoGBAKUnGDCXBYu5lq1kD0OlhBhiGzoKh+zZyl+q
gCDXVGi2i87N2cEExB+158zz2ZEzmdrjrWth8wQq57XgtBQk28g/cghv1cbAKLYJ
m8FV9nLfraKhTTV4KiRnrCaLiCHkx7DWqYwejJDJB46ZQPsoQZrr4vmtuZ6JJ+Ya
h507AX4BAoGAASribu4NmfF9UyUiHqDXN2MsHDKFvFw/1BIR/yLusMMlKsXSZp6f
lHxdmE/n0kusZeTSFpGxMjCHvx1UzL3VsQdss9odaFtlJCjpy9eIpm1wR8T1w0qs
T9NaSSZoDrpLnvt+HirHNdMKdpzlwBPoEoVOn3bOX8ZNKOWt0h8l17I=
-----END RSA PRIVATE KEY-----
EOT

# Optional ARC settings
arc_runner_scale_set_name    = "aks-arc-runners"
arc_min_runners              = 1
arc_max_runners              = 10
arc_controller_chart_version = "0.11.0"
arc_runner_chart_version     = "0.11.0"
