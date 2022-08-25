# Tuning

## MySql

 - Tune innodb_buffer_pool_size 
   - RIBPS, Recommended InnoDB Buffer Pool Size : https://dba.stackexchange.com/questions/27328/how-large-should-be-mysql-innodb-buffer-pool-size
   - IO threads : same URL as above


## Redis
 - Key distribution ( keys with/without expiry ) : `> info keyspace`
 - `> memory stats`

### Creating .rdb dump>

```
> config get dir
> save
```

 