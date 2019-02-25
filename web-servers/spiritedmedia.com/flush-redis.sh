#!/bin/bash
# Simple script to flush everything in Redis.
# Since we use Redis mainly as a cache this is no big deal to kill everything.
# Usually when you need to use this you're in a panic,
# hence it's setup as a script like this.

# Flush Redis Cache
redis-cli -h redis.spiritedmedia.com flushall
