# Changelog

# 1.0.0 (2025-07-18)

### Bug Fixes

* add changelog title ([4ff90e5](https://github.com/agilecustoms/publish/commit/4ff90e50766017bcb20dfb239752f57a4aa8276b))
* base64 encode the token ([fceb06e](https://github.com/agilecustoms/publish/commit/fceb06e575b1fae43257854cccd32ca9f756226b))
* default changelog title ([b985bd3](https://github.com/agilecustoms/publish/commit/b985bd3421589391121346b52ada39876ff8ad79))
* default changelog title2 ([b3965ad](https://github.com/agilecustoms/publish/commit/b3965ad5b44156ea2880da3b6927fd4adb8f7c3b))
* do not wrap line when generate base64 string ([6250798](https://github.com/agilecustoms/publish/commit/62507983383ec8ae995ca822513297211142fcb4))
* fix how release notes are taken from file ([08c1dca](https://github.com/agilecustoms/publish/commit/08c1dca4ff8badf5dcc9e153245343f98088631d))
* instead of ([6f0bdc0](https://github.com/agilecustoms/publish/commit/6f0bdc0d94f169fac89f0804ef43180baf887310))
* move Git configure in front of semantic-release ([ec738e4](https://github.com/agilecustoms/publish/commit/ec738e4a046a0e52c8aa4c02b8375db5dddd3f31))
* normal release notes ([ca68522](https://github.com/agilecustoms/publish/commit/ca685224f8e823d59176bfe2f402d5b80f205d20))
* release notes generation ([3b865bf](https://github.com/agilecustoms/publish/commit/3b865bf749b52759034381d27ac13778c25e6cad))
* remote debug step ([910182e](https://github.com/agilecustoms/publish/commit/910182ebab3c22587d20c16809f25e3b96f03eb4))
* remove debug step ([b7429f3](https://github.com/agilecustoms/publish/commit/b7429f3b3bf7e1c4582417493183d38090f7aa3e))
* remove debugging, add reference .git/config file (token is revoked) ([25af0a5](https://github.com/agilecustoms/publish/commit/25af0a56f46cc5c1505962a924a499d7b33fde80))
* remove extra debug ([c0b500a](https://github.com/agilecustoms/publish/commit/c0b500a3f46a8558c18afa1173d194a0627ee46a))
* remove obsolete parameter ([59bcc45](https://github.com/agilecustoms/publish/commit/59bcc454de378deed67f948f95b5ee23d7c1a653))
* restore env GH_TOKEN check as it is required to do GH release ([eb1663d](https://github.com/agilecustoms/publish/commit/eb1663dd397994d2cd87d6abab6be70a598a0e5e))
* test ([082d8d4](https://github.com/agilecustoms/publish/commit/082d8d435ecd583632308f33ec4ffff6979c8c90))
* try changelog title w/ no extra empty lines ([219e986](https://github.com/agilecustoms/publish/commit/219e9861cc2d3d48c978d983fe4ad057099235fb))
* try just # Changelog ([cb8427a](https://github.com/agilecustoms/publish/commit/cb8427a782409bf377a2b07f4de516a8acc84f05))
* try multi-line default value ([50265a0](https://github.com/agilecustoms/publish/commit/50265a0f540d4c0cc0f502582d2b201366644272))
* try non default changelog ([dfb3c44](https://github.com/agilecustoms/publish/commit/dfb3c44ab9219dabebe3640af71bee3ee3c53828))
* update documentation, test commit with " quotes ([5983e01](https://github.com/agilecustoms/publish/commit/5983e0113ce7eed72bf02341432b9a6869a4ccf9))
* update file ([0cc4eff](https://github.com/agilecustoms/publish/commit/0cc4effbe0d48e7c4521ea7acb9e397c8c64b895))


### Features

* add support of release-plugins ([16fb320](https://github.com/agilecustoms/publish/commit/16fb320407f3eaa679e76dd658a20db523f01ffb))
* automatically generate release notes ([ea78c7f](https://github.com/agilecustoms/publish/commit/ea78c7fad011dd82cf9a54a1161a161ec25816a6))
* changelog file and title ([6ae1928](https://github.com/agilecustoms/publish/commit/6ae19280f0e29bde0d0bf909afab29a834082bd2))
* GH_TOKEN env variable is not required any more, bcz it can be configured at checkout action ([a4d35b3](https://github.com/agilecustoms/publish/commit/a4d35b39a743aec43f7f1f50ff107eaa23f26b46))
* move login in AWS in Phase 3 ([d644fdd](https://github.com/agilecustoms/publish/commit/d644fdd0919450998d37072aba9a107ff0a05c6d))
* rename input ([a72da06](https://github.com/agilecustoms/publish/commit/a72da06ce946e5c786812097537f8ab588cd068e))
* support git commit and push for dev-release ([96a8c72](https://github.com/agilecustoms/publish/commit/96a8c720cf7f02a7cd057b999c232f2222216f8a))
* switch back to default changelog title ([2518a55](https://github.com/agilecustoms/publish/commit/2518a55e2da2838ce184ffc47ad2329c60233c58))
* try major release ([f028002](https://github.com/agilecustoms/publish/commit/f028002f2b3579f6875e21c78030135f0a710890))
* use tag-format ([21bfa71](https://github.com/agilecustoms/publish/commit/21bfa71a984f580350014a9566b414a903ffa68a))
* use updated release_gen with new features ([bb1abd6](https://github.com/agilecustoms/publish/commit/bb1abd6737fd52f5c6aa56fecc5aa2249b295478))


### Performance Improvements

* test ([ce95e55](https://github.com/agilecustoms/publish/commit/ce95e55d5cbd45cf242d9803b7bc869827010d0b))


### BREAKING CHANGES

* try major release


# [1.4.0](https://github.com/agilecustoms/publish/compare/v1.3.4...v1.4.0) (2025-07-17)

### Features

* GH_TOKEN env variable is not required any more, bcz it can be configured at checkout action ([a4d35b3](https://github.com/agilecustoms/publish/commit/a4d35b39a743aec43f7f1f50ff107eaa23f26b46))
* rename input ([a72da06](https://github.com/agilecustoms/publish/commit/a72da06ce946e5c786812097537f8ab588cd068e))


## [1.3.4](https://github.com/agilecustoms/publish/compare/v1.3.3...v1.3.4) (2025-07-17)

### Bug Fixes

* move Git configure in front of semantic-release ([ec738e4](https://github.com/agilecustoms/publish/commit/ec738e4a046a0e52c8aa4c02b8375db5dddd3f31))


## [1.3.3](https://github.com/agilecustoms/publish/compare/v1.3.2...v1.3.3) (2025-07-16)

### Bug Fixes

* remove extra debug ([c0b500a](https://github.com/agilecustoms/publish/commit/c0b500a3f46a8558c18afa1173d194a0627ee46a))


## [1.3.2](https://github.com/agilecustoms/publish/compare/v1.3.1...v1.3.2) (2025-07-16)

### Bug Fixes

* remove debugging, add reference .git/config file (token is revoked) ([25af0a5](https://github.com/agilecustoms/publish/commit/25af0a56f46cc5c1505962a924a499d7b33fde80))


## [1.3.1](https://github.com/agilecustoms/publish/compare/v1.3.0...v1.3.1) (2025-07-16)

### Bug Fixes

* base64 encode the token ([fceb06e](https://github.com/agilecustoms/publish/commit/fceb06e575b1fae43257854cccd32ca9f756226b))
* do not wrap line when generate base64 string ([6250798](https://github.com/agilecustoms/publish/commit/62507983383ec8ae995ca822513297211142fcb4))
* instead of ([6f0bdc0](https://github.com/agilecustoms/publish/commit/6f0bdc0d94f169fac89f0804ef43180baf887310))


# [1.3.0](https://github.com/agilecustoms/publish/compare/v1.2.0...v1.3.0) (2025-07-15)

### Features

* add support of release-plugins ([16fb320](https://github.com/agilecustoms/publish/commit/16fb320407f3eaa679e76dd658a20db523f01ffb))


# [1.2.0](https://github.com/agilecustoms/publish/compare/v1.1.2...v1.2.0) (2025-07-14)

### Features

* use updated release_gen with new features ([bb1abd6](https://github.com/agilecustoms/publish/commit/bb1abd6737fd52f5c6aa56fecc5aa2249b295478))


## [1.1.2](https://github.com/agilecustoms/publish/compare/v1.1.1...v1.1.2) (2025-07-11)

### Bug Fixes

* remove debug step ([b7429f3](https://github.com/agilecustoms/publish/commit/b7429f3b3bf7e1c4582417493183d38090f7aa3e))


## [1.1.1](https://github.com/agilecustoms/publish/compare/v1.1.0...v1.1.1) (2025-07-10)


# [1.1.0](https://github.com/agilecustoms/publish/compare/v1.0.0...v1.1.0) (2025-07-09)

### Features

* support git commit and push for dev-release ([96a8c72](https://github.com/agilecustoms/publish/commit/96a8c720cf7f02a7cd057b999c232f2222216f8a))


# [1.0.0](https://github.com/agilecustoms/publish/compare/v0.15.2...v1.0.0) (2025-07-08)

### Features

* try major release ([f028002](https://github.com/agilecustoms/publish/commit/f028002f2b3579f6875e21c78030135f0a710890))


### BREAKING CHANGES

* try major release


## [0.15.2](https://github.com/agilecustoms/publish/compare/v0.15.1...v0.15.2) (2025-07-08)

### Performance Improvements

* test ([ce95e55](https://github.com/agilecustoms/publish/commit/ce95e55d5cbd45cf242d9803b7bc869827010d0b))


## [0.15.1](https://github.com/agilecustoms/publish/compare/v0.15.0...v0.15.1) (2025-07-08)

### Bug Fixes

* test ([082d8d4](https://github.com/agilecustoms/publish/commit/082d8d435ecd583632308f33ec4ffff6979c8c90))


# [0.15.0](https://github.com/agilecustoms/publish/compare/v0.14.7...v0.15.0) (2025-07-06)


### Features

* switch back to default changelog title ([2518a55](https://github.com/agilecustoms/publish/commit/2518a55e2da2838ce184ffc47ad2329c60233c58))



## [0.14.7](https://github.com/agilecustoms/publish/compare/v0.14.6...v0.14.7) (2025-07-06)


### Bug Fixes

* try non default changelog ([dfb3c44](https://github.com/agilecustoms/publish/commit/dfb3c44ab9219dabebe3640af71bee3ee3c53828))



## [0.14.6](https://github.com/agilecustoms/publish/compare/v0.14.5...v0.14.6) (2025-07-06)


### Bug Fixes

* try just # Changelog ([cb8427a](https://github.com/agilecustoms/publish/commit/cb8427a782409bf377a2b07f4de516a8acc84f05))



## [0.14.5](https://github.com/agilecustoms/publish/compare/v0.14.4...v0.14.5) (2025-07-06)


### Bug Fixes

* try changelog title w/ no extra empty lines ([219e986](https://github.com/agilecustoms/publish/commit/219e9861cc2d3d48c978d983fe4ad057099235fb))



## [0.14.4](https://github.com/agilecustoms/publish/compare/v0.14.3...v0.14.4) (2025-07-06)


### Bug Fixes

* try multi-line default value ([50265a0](https://github.com/agilecustoms/publish/commit/50265a0f540d4c0cc0f502582d2b201366644272))



\\n\\n

## [0.14.3](https://github.com/agilecustoms/publish/compare/v0.14.2...v0.14.3) (2025-07-06)


### Bug Fixes

* default changelog title2 ([b3965ad](https://github.com/agilecustoms/publish/commit/b3965ad5b44156ea2880da3b6927fd4adb8f7c3b))



# Changelog\n\n

## [0.14.2](https://github.com/agilecustoms/publish/compare/v0.14.1...v0.14.2) (2025-07-06)


### Bug Fixes

* default changelog title ([b985bd3](https://github.com/agilecustoms/publish/commit/b985bd3421589391121346b52ada39876ff8ad79))



## [0.14.1](https://github.com/agilecustoms/publish/compare/v0.14.0...v0.14.1) (2025-07-06)


### Bug Fixes

* add changelog title ([4ff90e5](https://github.com/agilecustoms/publish/commit/4ff90e50766017bcb20dfb239752f57a4aa8276b))



# [0.14.0](https://github.com/agilecustoms/publish/compare/v0.13.4...v0.14.0) (2025-07-06)


### Features

* changelog file and title ([6ae1928](https://github.com/agilecustoms/publish/commit/6ae19280f0e29bde0d0bf909afab29a834082bd2))