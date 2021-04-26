# Shibboleth in a nutshell:

Shibboleth is a specific implementation of the SAML 2 standard. [^saml2]

Shibboleth authentication involves 3 parties; the user (client), the Service Provider (SP) and the Identity Provider (IDP).  Your server is the Service Provider. The name sounds more important than it is.

The IDP is the authority you trust to authenticate your users. If you ran the IDP, you would know it.

![Shibboleth/saml2 authentication flow diagram](https://upload.wikimedia.org/wikipedia/en/thumb/0/04/Saml2-browser-sso-redirect-post.png/700px-Saml2-browser-sso-redirect-post.png)


The Shibboleth authentication flow was designed around a web browser. All communication between the SP and IDP happen in the client. That would mean that the client could tamper with traffic from either the SP or IDP. To prevent that, messages are encrypted and assertions are signed.

Using encryption should prevent MITM/PITM attacks where signing should prevent forgery or tampering by the client. [^I think]

In normal use, there is no real time communication between an SP and an IDP.  The SP will fetch IDP metadata, but does not need direct communication to the IDP to authenticate a user.


# Shibboleth-sp config

https://wiki.shibboleth.net/confluence/display/SP3/ApplicationDefaults

The shib wiki is decent.  Shib sp3 is the epitome of java.  Not only is it XML, but it's strictly ordered xml.  That means that the children of an xml element are ordered, even when only one is allowed. As a concrete example of this, within the root `SPConfig` element, it is an error to have the `SecurityPolicyProvider` element before the `ApplicationDefaults` element in order.

## Cornell specific notes:

https://confluence.cornell.edu/display/SHIBBOLETH/Shibboleth+at+Cornell+Page

Cornell runs two shib IDPs for test and production.  They're very similar but the test IDP does not use encryption.  The test IDP also does not require registering your SP metadata prior to use.  I believe these are related.  The production IDP uses encryption and requires registration before your sp will function.  Registration is a manual process, so allow adequate time/planning.





##### Footnotes

[^I think]: I'm not 100% sure on this and would appreciate correction.
[^saml2]: https://en.wikipedia.org/wiki/SAML_2.0
