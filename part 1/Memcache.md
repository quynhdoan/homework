Memcache
---

**Question:**

How can Memcache improve a site’s performance? Include a description about how data is stored and retrieved in a multi-node configuration.

**Answer:**

Memcache is a high-performance, distributed in-memory data caching system. It is often used in front of or in place of a data source (such as a database). Although it is primarily intended for storing results of database queries, the cached data can be anything from data types, frequently requested HTML pages, images, files, etc.

Memcache is an attractive option when it comes to increasing site's performance for many dynamic, database-driven web applications. There are two main reasons why:

+ In terms of performance - it **reduces latency**: in Memcache, transient data is stored in key-value pairs in RAM. Therefore, writes to Memcache never touches the disk. Given the simple key-value store structure, commands (lookup, addition, etc.) have O(1) time complexity. Therefore, retrieval and serving of requested data from the cache is incredibly fast. This in turn makes sites seem more responsive.


+ In terms of cost - it **alleviates database load**: applications that utilize Memcache generally request data from the cache first before falling back on a slower backing store, such as a database. This decreases the amount of requests their servers have to handle - which is especially helpful as the number of visitors grow.
Because cached data are reused, it reduces the resources needed to handle a large volume of requests. Businesses generally have to pay for traffic (For e.g.: compute capacity by the hour). Consequently, the performance savings can lower a business cost of operations by keeping their resources requirements lower and more manageable.


As mentioned previously, data in Memcache is stored in key-value pairs. In order to store and retrieve data, a client software and a server software are needed (such as Memcached and Dalli).

+ The server software stores values along with their keys in an internal hash table.

+ The client software is responsible for selecting servers to send data to and servers to fetch data from. It does so using an algorithm that hashes the keys (in key-value pairs) among servers. You can either ask a client library to hash the keys for you, or supply your own hash values (typically in the form of User IDs).

When data is requested by key, the client's hashing mechanism will tell the application the correct node/server to fetch the data from.

It is worth mentioning that in such configuration (multi-node) all of the servers are looking into the same virtual pool of memory. This pool is essentially the combined cache of an application's entire web cluster. In the event of a crash, reboot or removal of servers, portions of data cached on the lost server(s) will be lost. This can cause the crashed host's requests to be remapped onto the remaining servers. These remaining servers can continue serving requests and filling in for the missing one. Although it is the most common backup strategy, remapping keys can cause huge sets of cache misses. Therefore, using a Consistent Hashing algorithm to distribute keys among servers is a more stable approach.


