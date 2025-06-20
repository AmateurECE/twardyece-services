-- LuaDNS records for the ethantwardy.com domain

a(_a, "172.234.20.52")
a("*", "172.234.20.52")
a("mail", "172.234.20.52")
mx(_a, "mail.ethantwardy.com", 10)
txt(_a, "v=spf1 ip4:172.234.20.52 ip6:fe80::f03c:95ff:fe2f:513a -all")
txt(
	"ethantwardy._domainkey",
	"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArubAqWEHD5esibM+NmRbxkFBkHdkO0ltL3gopADNu0/i/BbD3WIIMHXCZwBN3b+BdtHEbhB6wIN6bYTEQadVxmtXg7zcMv5AIe60agRIdNTTX4vscpXFSHCAm8qIRvoBC2bVEI+P8YJAcqVswWgFI3JpU3cI4luwjsNYIb7Sjy/BAJRtp9x+flad3BC6hu5PuV8owIcBg30oExVGPiDDdHFORo5fSfe3E3fmCLqvI+dydSQGeEKNH9zRYOg1nAL7tdJFmq8Gewysz/OOVwf47GMgquMpw97ql/WAj6lsSCIevMpK/s1wCl3guxRqjpGYzKVkrkdmhGOiAha7NDEI5wIDAQAB"
)
txt("_dmarc", "v=DMARC1; p=reject; rua=mailto:postmaster@ethantwardy.com;")
txt("_mta-sts.ethantwardy.com.", "v=STSv1; id=20250619;")
txt("_smtp._tls.ethantwardy.com.", "v=TLSRPTv1; rua=mailto:postmaster@ethantwardy.com;")

--- Needed to remain verified in Google Postmaster tools
txt(_a, "google-site-verification=7Gpev4O9vRdmnM4THOpEM9b50byopvngKREYLTdEHTQ")
