# Sample Database Firewall with Maxscale
## Architecture
![architecture](https://raw.githubusercontent.com/tsaeki/sample_database_firewall_with_maxscale/images/20190204_sample_maxscale.png)
## Setup
### Run a mariadb server and a maxscale server
```
$ docker-compose up -d 
```

### Create a sample database
```
$ mysql -uroot -h 127.0.0.1 -p < sample.sql
```

### Check maxscale state
```
$ docker-compose exec mxs maxctrl list servers
┌─────────┬─────────┬──────┬─────────────┬─────────────────────┬──────┐ 
│ Server  │ Address │ Port │ Connections │ State               │ GTID │
├─────────┼─────────┼──────┼─────────────┼─────────────────────┼──────┤
│ server1 │ db      │ 3306 │ 0           │ Auth Error, Running │      │
└─────────┴─────────┴──────┴─────────────┴─────────────────────┴──────┘
```

### Seup dummy data
```
$ pipenv run python3 dummy_data.py
```

## Filters
### Query Log All Filter
https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Query-Log-All-Filter/

#### sample configration
```
[Read-Only-Service]
type=service
router=readconnroute
router_options=running
servers=server1
user=maxscale
password=maxscale_password
filters=SampleLogFilter

[SampleLogFilter]
type=filter
module=qlafilter
match=SELECT.*FROM.*users
filebase=/tmp/sample
log_type=unified
flush=true
```
#### sample run
```
# Run sample query
$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT * FROM users"

# Check query log
$ docker-compose exec mxs /bin/bash
root@882ee08125a4:/# tail -f /tmp/sample.unified
Date,User@Host,Query
2019-02-09 01:35:56,sample@172.18.0.1,SELECT * FROM users
2019-02-09 01:38:32,sample@172.18.0.1,select * from users
```

### Database Firewall filter
https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Database-Firewall-Filter/
- coming soon
### Masking
https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Masking/
- coming soon
### Maxrows
https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Maxrows/
- coming soon
# Reference
- https://www.slideshare.net/MariaDB/database-security-threats-mariadb-security-best-practices (P.22)
- https://hub.docker.com/r/mariadb/maxscale/
- https://maxscale.readthedocs.io/en/stable/README/
- https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Query-Log-All-Filter/