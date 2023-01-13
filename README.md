# EvilGoPhish

Basic installer for [EvilGoPhish](https://github.com/Wolfandco/evilgophish) - edited for easier setup:
  * Cert_Path Set to: ```/etc/letsencrypt/live/${root_domain}/ ```
  * Included new function ```create_certs()```
    * This new function creates the certificate at the end of the script to ensure that the certs are installed.

## Credits

First and foremost, I would like to give credit where credit is due, [fin3ss3g0d](https://github.com/fin3ss3g0d) for being the god that he is and all of the work he did to make this a very successful phishing setup. Next, I want to thank both [Kuba Gretzky](https://github.com/kgretzky) and his work, and [Jordan Wright](https://github.com/jordan-wright) and his work. Last, but certainly not least, I want to thank the [DenSecure](https://www.wolfandco.com/services/densecure/) team at Wolf & Company for encouraging me to put this on my repository 
## One-Step Automated Install

Those who want to get started quickly and conveniently may install EvilGoPhish using the following command:

### `curl -sSL https://install-evilgophish.net | bash`

## Alternative Install Methods

We know that piping to `bash` is controversial, as it prevents you from reading code that is about to run on your system. Therefore, if you would like some alternative installation methods, we provided the following, including [fin3ss3g0d](https://github.com/fin3ss3g0d) `setup.sh` script

### Method 1: Clone [fin3ss3g0d](https://github.com/fin3ss3g0d/evilgophish) (Allows for manual entry of cert_path)

```bash
git clone https://github.com/fin3ss3g0d/evilgophish
cd evilgophish
./setup.sh <root domain> <subdomain(s)> <root domain bool> <redirect url> <feed bool> <rid replacement> <blacklist bool>
```

### Method 2: Clone [Wolfandco](https://github.com/Wolfandco/evilgophish) (Automated entry of cert_path to `/etc/letsencrypt/live/${root_domain}/`

```bash
git clone https://github.com/Wolfandco/evilgophish
cd evilgophish
./setup.sh <root domain> <subdomain(s)> <root domain bool> <redirect url> <feed bool> <rid replacement> <blacklist bool>
```

## Getting in touch with me

 * I am primarily on [Twitter](https://twitter.com/SteveSec128), I can also be found on [SteveSec.com](https://stevesec.com)
 
## Alternative Support 

 * To contact about EvilGoPhish, contact [fin3ss3g0d](https://github.com/fin3ss3g0d/evilgophish#contributing)
 * To contact about Evilginx2, contact [Kuba Gretzky](https://github.com/kgretzky)
 * To contact about GoPhish, contact [GoPhish](https://github.com/gophish)

## To-do

 - [ ] Support for more SMTP relays
 - [ ] DigitalOcean Support?
 - [ ] AWS, Azure, GCP Support?
 - [ ] Docker support?
 - [ ] Clean up script and integrate EvilGoPhish more
 - [ ] Make it look more cool
 

 
 
 
