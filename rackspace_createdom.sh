#!/bin/bash
curl -i -d \
'<domains xmlns:ns2="https://identity.api.rackspacecloud.com/v2.0/"
xmlns="https://identity.api.rackspacecloud.com/v2.0/" xmlns:ns3="http://www.w3.
org/2005/Atom">
<domain name="bbapidom.org" ttl="32" emailAddress="bbozhev@gmail.com"
comment="Optional domain comment...">
<subdomains>
<domain name="sub1.bbapidom.org" emailAddress="bbozhev@gmail.com" comment="1st sample subdomain"/>
<domain name="sub2.bbapidom.org" emailAddress="bbozhev@gmail.com" comment="1st sample subdomain"/>
</subdomains>
</domain>
</domains>' \
-H 'X-Auth-Token: 43de63739420c15f638e89536f65ff04' \
-H 'Content-Type: application/xml' \
-H 'Accept: application/xml' \
'https://identity.api.rackspacecloud.com/v2.0/bbozhev/domains'
