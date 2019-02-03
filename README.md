# Sample Database Firewall with Maxscale
## Setup
### Run a mariadb server and a maxscale server
```
$ docker-compose up -d 
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

### Create a sample database
```
$ mysql -uroot -h 127.0.0.1 -p < sample.sql
```

### Seup dummy data
```
$ pipenv run python3 dummy_data.py
```

## Filters
### Query Log All Filter
https://maxscale.readthedocs.io/en/stable/Documentation/Filters/Query-Log-All-Filter/

```
# Run sample query
$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT * FROM users"

# Check query log
$ docker-compose exec mxs /bin/bash
root@882ee08125a4:/# ls -l /tmp/
total 4
-rw-r--r-- 1 maxscale maxscale 79 Feb  3 11:57 sample.2
root@882ee08125a4:/# cat /tmp/sample.2
Date,User@Host,Query
2019-02-03 11:57:43,sample@172.18.0.1,SELECt * FROM users
root@882ee08125a4:/#
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