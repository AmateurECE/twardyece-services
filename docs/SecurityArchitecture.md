# Security Architecture

Previously, one shortcoming of this deployment was fragmentation of the
access control and other security concerns. This deployment attempts to
address those shortcomings by providing mitigations for security risks, and
consolidating security implementations as locally as possible.

# Auth Behavior

See this post describing the [Default Django Auth Behavior](
https://docs.djangoproject.com/en/3.2/topics/auth/default/) for the currently
used release of Django.

All applications (including Nginx) authenticate to LDAP currently.

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

## Session Fixation (By compromise of Django SECRET_KEY)
* Django SECRET_KEY is generated using a shell script every time the container
  starts.
