# Participa OAuth Login Plugin

[![license](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square)](https://choosealicense.com/licenses/mit/)

This [Discourse](http://www.discourse.org/) plugin enables logging in via [Participa](https://github.com/GuanyemBarcelona/participa) platform, and uses [OmniAuth Participa](https://github.com/adab1ts/omniauth-participa) to manage authentication via [OAuth 2](https://www.oauth.com/).


## Installation

Add this repository's `git clone` url to your container's `app.yml` file, at the bottom of the `cmd` section:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - mkdir -p plugins
          - git clone https://github.com/discourse/docker_manager.git
          - git clone https://github.com/adab1ts/discourse-oauth2-participa.git
```

Then rebuild your container:

```bash
$ cd /var/discourse
$ ./launcher rebuild app
```


## Configuration

[Participa](https://github.com/GuanyemBarcelona/participa) platform supports [OAuth 2](https://www.oauth.com/) authentication, playing the [Authorization and Resource Server](https://aaronparecki.com/oauth-2-simplified/#roles) roles, and uses the _Authorization Code_ grant to authorize Client apps acting on behalf the user.

1. Contact the platform admin and ask for the following data:

    - Client ID
    - Client Secret
    - Participa URL
    - Authorization URL for Participa
    - Token URL for Participa
    - User endpoint URL for Participa

2. Provide your Redirect URI when asked: `https://your.discourse.host/auth/participa/callback`

3. Log in to Discourse as an admin user and update the plugin settings in the _Admin > Settings > Login_ area:

![](https://raw.githubusercontent.com/adab1ts/discourse-oauth2-participa/master/screenshot-admin-settings.png)


## Contact

Email:    info[@]adabits[.]org  
Twitter:  [@adab1ts](https://twitter.com/adab1ts)  
Facebook: [Adab1ts](https://www.facebook.com/Adab1ts)  
LinkedIn: [adab1ts](https://www.linkedin.com/company/adab1ts)  


## Contributors

Contributions of any kind are welcome!

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<img alt="laklau" src="https://avatars.githubusercontent.com/u/6210292?v=3&s=117" width="117"> |[<img alt="zuzust" src="https://avatars.githubusercontent.com/u/351530?v=3&s=117" width="117">](https://github.com/adab1ts/omniauth-participa/commits?author=zuzust) |
:---: |:---: |
[Klaudia Alvarez](https://github.com/laklau) |[Carles Muiños](https://github.com/zuzust)
<!-- ALL-CONTRIBUTORS-LIST:END -->


## License

This plugin is available as open source under the terms of the [MIT License](LICENSE.txt).
