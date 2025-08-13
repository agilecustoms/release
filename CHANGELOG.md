# Changelog

## [1.0.0-beta.12](https://github.com/agilecustoms/release/compare/v1.0.0-beta.11...v1.0.0-beta.12) (2025-08-13)

### Features

* explicit version mode now supports floating tags and release channel ([4379996](https://github.com/agilecustoms/release/commit/4379996531c9cd47e0236ab752400fb23bb21e75))


## [1.0.0-beta.11](https://github.com/agilecustoms/release/compare/v1.0.0-beta.10...v1.0.0-beta.11) (2025-08-13)

### Features

* channel supports ${name} placeholder ([94405f0](https://github.com/agilecustoms/release/commit/94405f0a4c698f4fd16a53542e86a0d96a4bcb96))


## [1.0.0-beta.10](https://github.com/agilecustoms/release/compare/v1.0.0-beta.9...v1.0.0-beta.10) (2025-08-12)

### Features

* add java-version input - pass it into setup-maven-codeartifact action ([e707ff4](https://github.com/agilecustoms/release/commit/e707ff4254776e8a6694e1021713b3122a7d2a5c))


## [1.0.0-beta.9](https://github.com/agilecustoms/release/compare/v1.0.0-beta.8...v1.0.0-beta.9) (2025-08-12)

### Miscellaneous

* pin publish-s3 to v1.0.0 ([ca6cd84](https://github.com/agilecustoms/release/commit/ca6cd8460a59b1035c073a1f1acb54b0eb0cb898))


## [1.0.0-beta.8](https://github.com/agilecustoms/release/compare/v1.0.0-beta.7...v1.0.0-beta.8) (2025-08-12)

### Documentation

* configuration.md ([f1bebe4](https://github.com/agilecustoms/release/commit/f1bebe4f03a1bd7f49c15a307eeda91df6a60b5d))


## [1.0.0-beta.7](https://github.com/agilecustoms/release/compare/v1.0.0-beta.6...v1.0.0-beta.7) (2025-08-12)

### Documentation

* cover entire lifecycle of a prerelease branch ([a99df7f](https://github.com/agilecustoms/release/commit/a99df7fdf242be4d63d3f49af56f07580c43f0e3))


## [1.0.0-beta.6](https://github.com/agilecustoms/release/compare/v1.0.0-beta.5...v1.0.0-beta.6) (2025-08-11)

### Documentation

* fix release channel support for 'version-bump' ([d7e5f97](https://github.com/agilecustoms/release/commit/d7e5f9768155b4a7ffe82fa5b82a36164581d0d0))


## [1.0.0-beta.5](https://github.com/agilecustoms/release/compare/v1.0.0-beta.4...v1.0.0-beta.5) (2025-08-11)

### Documentation

* testing document and troubleshooting updates ([ff68632](https://github.com/agilecustoms/release/commit/ff686327d3ebacebdf195dde82b2ba6ad23fbb7f))


## [1.0.0-beta.4](https://github.com/agilecustoms/release/compare/v1.0.0-beta.3...v1.0.0-beta.4) (2025-08-11)

### Features

* use new release-gen with cleaner error messages ([a7f9593](https://github.com/agilecustoms/release/commit/a7f95930dc23066982c6d7a901688aef3f86161a))


## [1.0.0-beta.3](https://github.com/agilecustoms/release/compare/v1.0.0-beta.2...v1.0.0-beta.3) (2025-08-10)

### Features

* rename NPM_PUBLIC_TOKEN to be just NPM_TOKEN, add parameter 'npm-visibility' to support private packages ([19ca27a](https://github.com/agilecustoms/release/commit/19ca27a5be1941f45f628203f0e72f4aff9aaa24))


## [1.0.0-beta.2](https://github.com/agilecustoms/release/compare/v1.0.0-beta.1...v1.0.0-beta.2) (2025-08-10)

### Documentation

* update cover image, add npmjs ([ecfc8c8](https://github.com/agilecustoms/release/commit/ecfc8c8788ac27a6b12d6d892a520305ba6cb61a))


## [1.0.0-beta.1](https://github.com/agilecustoms/release/compare/v0.17.0...v1.0.0-beta.1) (2025-08-10)

### ⚠ BREAKING CHANGES

* first beta

### Features

* first beta ([b8a248f](https://github.com/agilecustoms/release/commit/b8a248fe5ca36ca0efd8629e6476ebbd82802e8c))


## [0.17.0](https://github.com/agilecustoms/release/compare/v0.16.0...v0.17.0) (2025-08-10)

### Features

* change dev-branch-prefix default to be 'feature/' ([54c78e5](https://github.com/agilecustoms/release/commit/54c78e58b21ee91c35f33c37ac8f3e0df9fd6286))

### Bug Fixes

* update step names ([9bfbd0f](https://github.com/agilecustoms/release/commit/9bfbd0f20303056290038808d4d997a3e2fc003c))

### Documentation

* (mainly) semantic-commits update ([8d9861a](https://github.com/agilecustoms/release/commit/8d9861a8a93c3db4da16d4de2746507ad7ddb014))
* GH authorization ([c2118e6](https://github.com/agilecustoms/release/commit/c2118e6fef519cfb4f21a5788534bb09c853f6d1))
* improve semantic-commits.md ([dcd6786](https://github.com/agilecustoms/release/commit/dcd67863ff58acdecd30b743d5f52a97c014505f))
* major doc update before release ([2be24db](https://github.com/agilecustoms/release/commit/2be24db0f857c5150b81c3b8c61837a13bec6bed))
* update aws and gh authorization ([b4a8605](https://github.com/agilecustoms/release/commit/b4a8605ca5ac74f3bbf4b1639e85b42f130bf526))


## [0.16.0](https://github.com/agilecustoms/release/compare/v0.15.0...v0.16.0) (2025-08-06)

### Features

* parameter version-bump ([7c821ff](https://github.com/agilecustoms/release/commit/7c821ff20c6e9792e44ff8e0e3aa55150d461509))

### Documentation

* cover different version generation options ([5679408](https://github.com/agilecustoms/release/commit/56794080c1078b1af2e3c8dc25e581cb96bc2c90))
* fix all links ([606782a](https://github.com/agilecustoms/release/commit/606782a84b99f3cf9696a88340be833534cab625))
* great refactoring - distribute all documentation by feature and by artifact type ([0642754](https://github.com/agilecustoms/release/commit/0642754dfc6fd08677de659c87f235964d657742))
* review README.md, rename semantic-release doc ([b71e190](https://github.com/agilecustoms/release/commit/b71e1908e09bb3a1e873f27575aa16140a3436d4))


## [0.15.0](https://github.com/agilecustoms/release/compare/v0.14.0...v0.15.0) (2025-08-03)

### Features

* default-minor ([#17](https://github.com/agilecustoms/release/issues/17)) ([60382cf](https://github.com/agilecustoms/release/commit/60382cf3bac291793b002da877b10841694b6929))


## [0.14.0](https://github.com/agilecustoms/release/compare/v0.13.0...v0.14.0) (2025-08-02)

### Features

* npm release channel ([#16](https://github.com/agilecustoms/release/issues/16)) ([8dd45ea](https://github.com/agilecustoms/release/commit/8dd45ea9153f293871eb6aeb7cb54c1043353ccf))


## [0.13.0](https://github.com/agilecustoms/release/compare/v0.12.1...v0.13.0) (2025-08-02)

### Features

* floating-tags and prereleases ([#15](https://github.com/agilecustoms/release/issues/15)) ([8e1361a](https://github.com/agilecustoms/release/commit/8e1361a7c7159fa7b7f5320e5c51432cef37dc8d))


## [0.12.1](https://github.com/agilecustoms/release/compare/v0.12.0...v0.12.1) (2025-07-30)

### Miscellaneous

* add diagnostic headers to all bash steps ([#14](https://github.com/agilecustoms/release/issues/14)) ([51265b2](https://github.com/agilecustoms/release/commit/51265b2ed2995a634624b2a5ba95ca7be6efdb24))


## [0.12.0](https://github.com/agilecustoms/release/compare/v0.11.0...v0.12.0) (2025-07-30)

### Features

* use release_gen git_tags ([211bb64](https://github.com/agilecustoms/release/commit/211bb6498e3a7dd546e446dac277e7c55362ed26))

### Documentation

* update roadmap and contribution ([7de38b1](https://github.com/agilecustoms/release/commit/7de38b14cfdeac0b7c2e87f8caffecbfe6c837c4))


## [0.11.0](https://github.com/agilecustoms/release/compare/v0.10.1...v0.11.0) (2025-07-29)

### Features

* gracefully handle prerelease ([#12](https://github.com/agilecustoms/release/issues/12)) ([c31f7f7](https://github.com/agilecustoms/release/commit/c31f7f76deb82634e91a98333d1d17986f90aa1f))


## [0.10.1](https://github.com/agilecustoms/release/compare/v0.10.0...v0.10.1) (2025-07-28)

### Bug Fixes

* release-gen return new version as git_tag ([b631c23](https://github.com/agilecustoms/release/commit/b631c231f453aad612f8f9033e96b24fb7284b07))


## [0.10.0](https://github.com/agilecustoms/release/compare/v0.9.0...v0.10.0) (2025-07-27)

### Features

* document maintenance releases ([d208b8c](https://github.com/agilecustoms/release/commit/d208b8c1c50336f08a0b035f6b2231f9ad640602))


## [0.9.0](https://github.com/agilecustoms/release/compare/v0.8.1...v0.9.0) (2025-07-27)

### Features

* validate event trigger ([537bd68](https://github.com/agilecustoms/release/commit/537bd6861dd0b28225fe4c6e28078d712502f097))

### Bug Fixes

* shell script syntax ([2dd34ed](https://github.com/agilecustoms/release/commit/2dd34edd6e5119c178edf182fee92e72b6334d52))
* validate a combination of NPM_PUBLIC_TOKEN and dev-release ([f0e81cd](https://github.com/agilecustoms/release/commit/f0e81cd2d3880a1c4b3d7bfcc8fabf49d72d3763))

### Documentation

* philosophy, roadmap ([05d0ba8](https://github.com/agilecustoms/release/commit/05d0ba883f5c779d72e508c3d32d8ced2eaf4c88))
* update doc to reflect that this action does not support pull_request as trigger ([b958a80](https://github.com/agilecustoms/release/commit/b958a8022e87bcc7ee29fd7d71fb915d4d211ac1))

### Miscellaneous

* add branding ([66efee0](https://github.com/agilecustoms/release/commit/66efee0e999563f82cae4052cb1ca317c0f013fb))


## [0.8.1](https://github.com/agilecustoms/release/compare/v0.8.0...v0.8.1) (2025-07-26)

### Documentation

* add known issues ([716db57](https://github.com/agilecustoms/release/commit/716db57ff660b61b9c37cf899803f98c27db1291))
* add note that action is under development ([a5059d5](https://github.com/agilecustoms/release/commit/a5059d5c5c71c4721fb036fdb881c555f1652fac))
* minor updates ([caabd65](https://github.com/agilecustoms/release/commit/caabd65eb6f343993afc5cf5bf59e73ad0ad3add))
* swap Outputs and Env variables ([6becac2](https://github.com/agilecustoms/release/commit/6becac2ca2f14e75188289bcd1d5ae81185513c8))


## [0.8.0](https://github.com/agilecustoms/release/compare/v0.7.1...v0.8.0) (2025-07-25)

### Features

* rename agilecustoms/publish in agilecustoms/release ([64e77c0](https://github.com/agilecustoms/release/commit/64e77c022591fb7b537caf24f9c90ed379cc0147))


## [0.7.1](https://github.com/agilecustoms/release/compare/v0.7.0...v0.7.1) (2025-07-25)

### Documentation

* update documentation about pyproject.toml ([6cdc4f3](https://github.com/agilecustoms/release/commit/6cdc4f3d8602fc796f04f7050f77f6a2a0e9696e))


## [0.7.0](https://github.com/agilecustoms/release/compare/v0.6.0...v0.7.0) (2025-07-25)

### Features

* update version in pyproject.toml ([#7](https://github.com/agilecustoms/release/issues/7)) ([967fa73](https://github.com/agilecustoms/release/commit/967fa737346cb9c17e7b617cf437c446ebbdca85))


## [0.6.0](https://github.com/agilecustoms/release/compare/v0.5.0...v0.6.0) (2025-07-25)

### Features

* update version in pom.xml even if project doesn't need to be published ([834ee35](https://github.com/agilecustoms/release/commit/834ee35e59cce6971563c78ab6ae01dc8ecb8aec))


## [0.5.0](https://github.com/agilecustoms/release/compare/v0.4.5...v0.5.0) (2025-07-25)

### Features

* update package.json version even if package is NOT published in npm ([9f86465](https://github.com/agilecustoms/release/commit/9f864653528b26616ccd0bab724e94c5929eb1e4))


## [0.4.5](https://github.com/agilecustoms/release/compare/v0.4.4...v0.4.5) (2025-07-25)

### Documentation

* update inputs table ([5272d1a](https://github.com/agilecustoms/release/commit/5272d1a7ce4fbce6d785e0698d0757f647a70e79))


## [0.4.4](https://github.com/agilecustoms/release/compare/v0.4.3...v0.4.4) (2025-07-24)

### Miscellaneous

* add custom .releaserc.json for more granular release notes ([ca9325e](https://github.com/agilecustoms/release/commit/ca9325e21b3672f51283aded8bc8a3f475976f01))


## [0.4.3](https://github.com/agilecustoms/release/compare/v0.4.2...v0.4.3) (2025-07-23)

### Bug Fixes

* improve semantic-release documentation 2 ([0986c70](https://github.com/agilecustoms/release/commit/0986c70fc12bb57f0f253707ba4dc8b6afb17539))


## [0.4.2](https://github.com/agilecustoms/release/compare/v0.4.1...v0.4.2) (2025-07-23)

### Bug Fixes

* improve semantic-release documentation ([ada956b](https://github.com/agilecustoms/release/commit/ada956bba7b11dc2ea4d75cc858cfe4de3fca528))


## [0.4.1](https://github.com/agilecustoms/release/compare/v0.4.0...v0.4.1) (2025-07-23)

### Bug Fixes

* update semantic-release documentation with most robust configuration ([6739fef](https://github.com/agilecustoms/release/commit/6739fef7c0c9aa11338752623de0587c6e33733f))


# [0.4.0](https://github.com/agilecustoms/release/compare/v0.3.0...v0.4.0) (2025-07-21)

### Features

* rename $new_version into just $version ([1d1f22d](https://github.com/agilecustoms/release/commit/1d1f22d3b0173f983a9fc87fd9aec8ef5ae02b38))


# [0.3.0](https://github.com/agilecustoms/release/compare/v0.2.0...v0.3.0) (2025-07-19)

### Features

* print summary ([3151a26](https://github.com/agilecustoms/release/commit/3151a265d369923bffb01df5b1fac8ae7163f3a4))


# [0.2.0](https://github.com/agilecustoms/release/compare/v0.1.0...v0.2.0) (2025-07-19)

### Features

* remove tag-format default value. now default value comes from code, not from input. so you can redefine it in .releaserc.json ([c5acb21](https://github.com/agilecustoms/release/commit/c5acb21dfb8de24ba0e921d0a5f06509be12c19e))


# [1.4.0](https://github.com/agilecustoms/release/compare/v1.3.4...v1.4.0) (2025-07-17)

### Features

* GH_TOKEN env variable is not required any more, bcz it can be configured at checkout action ([a4d35b3](https://github.com/agilecustoms/release/commit/a4d35b39a743aec43f7f1f50ff107eaa23f26b46))
* rename input ([a72da06](https://github.com/agilecustoms/release/commit/a72da06ce946e5c786812097537f8ab588cd068e))


## [1.3.4](https://github.com/agilecustoms/release/compare/v1.3.3...v1.3.4) (2025-07-17)

### Bug Fixes

* move Git configure in front of semantic-release ([ec738e4](https://github.com/agilecustoms/release/commit/ec738e4a046a0e52c8aa4c02b8375db5dddd3f31))


## [1.3.3](https://github.com/agilecustoms/release/compare/v1.3.2...v1.3.3) (2025-07-16)

### Bug Fixes

* remove extra debug ([c0b500a](https://github.com/agilecustoms/release/commit/c0b500a3f46a8558c18afa1173d194a0627ee46a))


## [1.3.2](https://github.com/agilecustoms/release/compare/v1.3.1...v1.3.2) (2025-07-16)

### Bug Fixes

* remove debugging, add reference .git/config file (token is revoked) ([25af0a5](https://github.com/agilecustoms/release/commit/25af0a56f46cc5c1505962a924a499d7b33fde80))


## [1.3.1](https://github.com/agilecustoms/release/compare/v1.3.0...v1.3.1) (2025-07-16)

### Bug Fixes

* base64 encode the token ([fceb06e](https://github.com/agilecustoms/release/commit/fceb06e575b1fae43257854cccd32ca9f756226b))
* do not wrap line when generate base64 string ([6250798](https://github.com/agilecustoms/release/commit/62507983383ec8ae995ca822513297211142fcb4))
* instead of ([6f0bdc0](https://github.com/agilecustoms/release/commit/6f0bdc0d94f169fac89f0804ef43180baf887310))


# [1.3.0](https://github.com/agilecustoms/release/compare/v1.2.0...v1.3.0) (2025-07-15)

### Features

* add support of release-plugins ([16fb320](https://github.com/agilecustoms/release/commit/16fb320407f3eaa679e76dd658a20db523f01ffb))


# [1.2.0](https://github.com/agilecustoms/release/compare/v1.1.2...v1.2.0) (2025-07-14)

### Features

* use updated release_gen with new features ([bb1abd6](https://github.com/agilecustoms/release/commit/bb1abd6737fd52f5c6aa56fecc5aa2249b295478))


## [1.1.2](https://github.com/agilecustoms/release/compare/v1.1.1...v1.1.2) (2025-07-11)

### Bug Fixes

* remove debug step ([b7429f3](https://github.com/agilecustoms/release/commit/b7429f3b3bf7e1c4582417493183d38090f7aa3e))


## [1.1.1](https://github.com/agilecustoms/release/compare/v1.1.0...v1.1.1) (2025-07-10)


# [1.1.0](https://github.com/agilecustoms/release/compare/v1.0.0...v1.1.0) (2025-07-09)

### Features

* support git commit and push for dev-release ([96a8c72](https://github.com/agilecustoms/release/commit/96a8c720cf7f02a7cd057b999c232f2222216f8a))


# [1.0.0](https://github.com/agilecustoms/release/compare/v0.15.2...v1.0.0) (2025-07-08)

### Features

* try major release ([f028002](https://github.com/agilecustoms/release/commit/f028002f2b3579f6875e21c78030135f0a710890))


### BREAKING CHANGES

* try major release


## [0.15.2](https://github.com/agilecustoms/release/compare/v0.15.1...v0.15.2) (2025-07-08)

### Performance Improvements

* test ([ce95e55](https://github.com/agilecustoms/release/commit/ce95e55d5cbd45cf242d9803b7bc869827010d0b))


## [0.15.1](https://github.com/agilecustoms/release/compare/v0.15.0...v0.15.1) (2025-07-08)

### Bug Fixes

* test ([082d8d4](https://github.com/agilecustoms/release/commit/082d8d435ecd583632308f33ec4ffff6979c8c90))


# [0.15.0](https://github.com/agilecustoms/release/compare/v0.14.7...v0.15.0) (2025-07-06)


### Features

* switch back to default changelog title ([2518a55](https://github.com/agilecustoms/release/commit/2518a55e2da2838ce184ffc47ad2329c60233c58))



## [0.14.7](https://github.com/agilecustoms/release/compare/v0.14.6...v0.14.7) (2025-07-06)


### Bug Fixes

* try non default changelog ([dfb3c44](https://github.com/agilecustoms/release/commit/dfb3c44ab9219dabebe3640af71bee3ee3c53828))



## [0.14.6](https://github.com/agilecustoms/release/compare/v0.14.5...v0.14.6) (2025-07-06)


### Bug Fixes

* try just # Changelog ([cb8427a](https://github.com/agilecustoms/release/commit/cb8427a782409bf377a2b07f4de516a8acc84f05))



## [0.14.5](https://github.com/agilecustoms/release/compare/v0.14.4...v0.14.5) (2025-07-06)


### Bug Fixes

* try changelog title w/ no extra empty lines ([219e986](https://github.com/agilecustoms/release/commit/219e9861cc2d3d48c978d983fe4ad057099235fb))



## [0.14.4](https://github.com/agilecustoms/release/compare/v0.14.3...v0.14.4) (2025-07-06)


### Bug Fixes

* try multi-line default value ([50265a0](https://github.com/agilecustoms/release/commit/50265a0f540d4c0cc0f502582d2b201366644272))



\\n\\n

## [0.14.3](https://github.com/agilecustoms/release/compare/v0.14.2...v0.14.3) (2025-07-06)


### Bug Fixes

* default changelog title2 ([b3965ad](https://github.com/agilecustoms/release/commit/b3965ad5b44156ea2880da3b6927fd4adb8f7c3b))



# Changelog\n\n

## [0.14.2](https://github.com/agilecustoms/release/compare/v0.14.1...v0.14.2) (2025-07-06)


### Bug Fixes

* default changelog title ([b985bd3](https://github.com/agilecustoms/release/commit/b985bd3421589391121346b52ada39876ff8ad79))



## [0.14.1](https://github.com/agilecustoms/release/compare/v0.14.0...v0.14.1) (2025-07-06)


### Bug Fixes

* add changelog title ([4ff90e5](https://github.com/agilecustoms/release/commit/4ff90e50766017bcb20dfb239752f57a4aa8276b))



# [0.14.0](https://github.com/agilecustoms/release/compare/v0.13.4...v0.14.0) (2025-07-06)


### Features

* changelog file and title ([6ae1928](https://github.com/agilecustoms/release/commit/6ae19280f0e29bde0d0bf909afab29a834082bd2))