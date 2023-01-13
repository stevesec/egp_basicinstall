# EvilGoPhish

Basic installer for [EvilGoPhish](https://github.com/Wolfandco/evilgophish) - edited for easier setup:
  * Cert_Path Set to: ```/etc/letsencrypt/live/${root_domain}/ ```
  * Included new function ```create_certs()```
    * This new function creates the certificate at the end of the script to ensure that 

## Credits

First and foremost, I would like to give credit where credit is due, [fin3ss3g0d](https://github.com/fin3ss3g0d) for being the God that he is and all of the work he did to make this a very successful phishing setup. Next, I want to thank both [Kuba Gretzky](https://github.com/kgretzky) and his work and [Jordan Wright](https://github.com/jordan-wright) and his work.

## Usage

```bash
curl -sSL https://install-evilgophish.net | bash
```
