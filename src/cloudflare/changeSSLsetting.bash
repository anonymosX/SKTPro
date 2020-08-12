#!/bin/bash

# VARIABLE	VALUE
# EMAIL	       The email address associated with your Cloudflare account.
# KEY	       The global API key associated with your Cloudflare account.
# DOMAIN	   The name of the domain to create a zone record for.
# JUMP_START   If true, automatically attempts to fetch existing DNS records when creating a domain’s zone record
# ZONE_ID	   The unique ID of the domain’s zone record. Assigned by Cloudflare. Required when managing an existing zone record and its DNS records.
# DNS_ID	   The unique ID given to each of the domain’s individual DNS records. Assigned by Cloudflare. Required when updating or deleting an existing DNS record.
# TYPE	       The DNS record type including A, CNAME, MX and TCXT ecords. This equates to the Type column on the Cloudflare dashboard.
# NAME         The DNS record name. This equates to the Name column on the Cloudflare dashboard.
# CONTENT      The DNS record content. This equates to the Value column on the Cloudflare dashboard.
# PROXIED	   If true, a DNS record will pass through Cloudflare’s servers. Un-proxied records will not and are for DNS resolution only. Applicable to A and CNAME records only. This equates to the Status column on the Cloudflare dashboard.
# TTL	       Valid TTL. Must be between 120 and 2,147,483,647 seconds, or 1 for automatic
# PRIORITY	   The order in which servers should be contacted. Applicable to MX records only.
# ALL	       If true, JSON output will be pretty-printed using Python’s json.tool module. Otherwise, output will be limited to specified data.




#TURN OFF SSL
#curl -X PATCH "https://api.cloudflare.com/client/v4/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/settings/ssl" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json" \
     --data '{"value":"off"}'
#FULL SSL
curl -X PATCH "https://api.cloudflare.com/client/v4/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/settings/ssl" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json" \
     --data '{"value":"full"}'
#ALWAYS HTTPS
curl -X GET "https://api.cloudflare.com/client/v4/zones/`sed -n "3p" /etc/skt.d/data/$DOMAIN/api_cf.txt`/settings/always_use_https" \
     -H "X-Auth-Email: `sed -n "1p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "X-Auth-Key: `sed -n "2p" /etc/skt.d/data/$DOMAIN/api_cf.txt`" \
     -H "Content-Type: application/json"