# Security Architecture

Previously, one shortcoming of this deployment was fragmentation of the
access control and other security 

[Default Django Auth Behavior](
https://docs.djangoproject.com/en/3.2/topics/auth/default/)

# S.T.R.I.D.E.

# Risk Mitigations

[MDN: Cookies](https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies)
## Cross-Site Scripting Attack (XSS)
* Prevent scripts from accessing Cookie using `httponly` attribute.
* Short Cookie lifetime.

## Man-in-the-Middle Attack
* Cookie `Secure` attribute.
* TLS/HTTPS, [HTTP `Strict-Transport-Security`](
  https://developer.mozilla.org/en-US/docs/Glossary/HSTS) header

## Cross-Site Request Forgery (CSRF)
* Cookie scope, using `Domain` and `Path` attributes.
* `SameSite=Strict` to prevent a particular kind of CSRF attack.

## Denial of Service
* `fail2ban`
* Timed wait between failed login attempts (Http Server)

## Session Fixation
