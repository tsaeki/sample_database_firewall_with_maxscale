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
#### sample configration
- /etc/maxscale.cnf.d/example_maxscale.cnf
```
[Read-Only-Service]
type=service
router=readconnroute
router_options=running
servers=server1
user=maxscale
password=maxscale_password
filters=dbfw-blacklist

[dbfw-blacklist]
type=filter
module=dbfwfilter
action=block
rules=/etc/maxscale.modules.d/blacklist-rules.txt
```
#### sample run (deny select with regex)
```
# Rules file
$ cat /etc/maxscale.modules.d/blacklist-rules.txt
rule deny_select match regex '(i?).*select.*from.*users.*'
users %@% match any rules deny_select

# Run sample query
$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT * FROM users"
ERROR 1141 (HY000) at line 1: Access denied for user 'sample'@'172.18.0.1' to database 'sampledb': Permission denied, query matched regular expression.
```
#### sample run (deny select with on_queries)
```
# Rules file
$ cat /etc/maxscale.modules.d/blacklist-rules.txt
rule deny_select match on_queries select
users %@% match any rules deny_select

# Run sample query
$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT * FROM users"
ERROR 1141 (HY000) at line 1: Access denied for user 'sample'@'172.18.0.1' to database 'sampledb': Permission denied at this time.
```
#### sample run (deny select with columns)
```
# Rules file
$ cat /etc/maxscale.modules.d/blacklist-rules.txt
rule deny_select match columns name
users %@% match any rules deny_select

# Run sample query
$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT name FROM users"
ERROR 1141 (HY000) at line 1: Access denied for user 'sample'@'172.18.0.1' to database 'sampledb': Permission denied to column 'name'.

$ mysql -usample -h 127.0.0.1 -P 4008 -p sampledb -e "SELECT * FROM users"
+-----+------------------+--------------------------------+----------+---------------+---------------------+
| id  | name             | email                          | zip      | tel           | credit_card_number  |
+-----+------------------+--------------------------------+----------+---------------+---------------------+
| 101 | 杉山 結衣        | hidaka@gmail.com               | 487-6450 | 080-2450-8701 | 4114080591739765    |
| 102 | 渚 真綾          | minoru40@yahoo.com             | 269-5000 | 57-1339-7205  | 3553715906133671    |
| 103 | 井上 修平        | taichikudo@hotmail.com         | 268-3379 | 06-1226-7644  | 4414568334566054    |
..snip..
```
#### sample run (deny delete with no_where_clause)
```
# Rules file
$ cat /etc/maxscale.modules.d/blacklist-rules.txt
rule deny_delete match no_where_clause on_queries delete
users %@% match any rules deny_delete

# Run sample query
# NG
$ mysql -usample -h 127.0.0.1 -P 4008 -psample_password sampledb -e "DELETE FROM users"
ERROR 1141 (HY000) at line 1: Access denied for user 'sample'@'172.18.0.1' to database 'sampledb': Required WHERE/HAVING clause is missing.

# OK
$ mysql -usample -h 127.0.0.1 -P 4008 -psample_password sampledb -e "DELETE FROM users WHERE id = 1"
```

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