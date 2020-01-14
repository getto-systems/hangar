# getto-hangar

docker image repository : using by getto projects

status : production ready


###### Table of Contents

- [Usage](#Usage)
- [License](#License)


## Usage

### pushing `getto/hangar:HANGAR-ID`

`.gitlab-ci.yml` sample

```yaml
stages:
  - image_build
  - image_test
  - image_fix_vulnerabilities
  - image_push

image_build:
  stage: image_build
  only:
    refs:
      - merge_requests
    changes:
      - package-lock.json
      - Dockerfile
      - Dockerfile-test

  image: getto/hangar:latest

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
  services:
    - docker:dind

  cache:
    paths:
      - .cache

  script:
    - getto-hangar-build.sh

image_test:
  stage: image_test
  only:
    refs:
      - schedules
    variables:
      - $CHECK

  image: getto/hangar:latest

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
  services:
    - docker:dind

  cache:
    paths:
      - .cache

  script:
    - getto-hangar-test.sh

image_fix_vulnerabilities:
  stage: image_fix_vulnerabilities
  only:
    refs:
      - schedules
    variables:
      - $CHECK
  when: on_failure

  image: getto/hangar:latest

  before_script:
    - git config user.email COMMITER_EMAIL
    - git config user.name COMMITER_NAME
    - curl https://trellis.getto.systems/git/post/1.0.0/setup.sh | bash -s -- ./vendor/getto-systems
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
  script:
    - getto-hangar-fix-vulnerabilities.sh
    - curl https://trellis.getto.systems/ci/bump-version/1.2.2/request.sh | bash -s -- ./.fix-vulnerabilities-message.sh

image_push:
  stage: image_push
  only:
    refs:
      - master@REPOSITORY_PATH
    changes:
      - package-lock.json
      - Dockerfile
      - Dockerfile-test
  except:
    refs:
      - schedules
      - triggers

  image: getto/hangar:latest

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
  before_script:
    - git config user.email COMMITER_EMAIL
    - git config user.name COMMITER_NAME
    - curl https://trellis.getto.systems/git/post/1.0.0/setup.sh | bash -s -- ./vendor/getto-systems
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
  services:
    - docker:dind

  script:
    - getto-hangar-push.sh
    - curl https://trellis.getto.systems/ci/bump-version/1.2.2/request.sh | bash -s -- ./.fix-image-message.sh
```

replace settings

- REPOSITORY_PATH
- COMMITER_EMAIL
- COMMITER_NAME

require settings

- .getto-hangar-image : `getto/hangar:HANGAR-ID`
- DOCKER_USER
- DOCKER_PASSWORD
- DOCKER_CONTENT_TRUST_REPOSITORY_ID
- DOCKER_CONTENT_TRUST_REPOSITORY_KEY
- DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE
- DOCKER_CONTENT_TRUST_ROOT_ID
- DOCKER_CONTENT_TRUST_ROOT_KEY
- DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE


### pushing own image

```yaml
image: getto/hangar:latest

stages:
  - image_build
  - image_test
  - image_fix_vulnerabilities
  - bump_version
  - release
  - release_notify

image_build:
  stage: image_build
  only:
    refs:
      - merge_requests
    changes:
      - Dockerfile

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
  services:
    - docker:dind

  cache:
    paths:
      - .cache

  script:
    - getto-hangar-build.sh

image_test:
  stage: image_test
  only:
    refs:
      - schedules
    variables:
      - $CHECK

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
    image: IMAGE_NAME
  services:
    - docker:dind

  cache:
    paths:
      - .cache

  script:
    - getto-hangar-test.sh

image_fix_vulnerabilities:
  stage: image_fix_vulnerabilities
  only:
    refs:
      - schedules
    variables:
      - $CHECK
  when: on_failure

  before_script:
    - git config user.email COMMITER_EMAIL
    - git config user.name COMMITER_NAME
    - curl https://trellis.getto.systems/git/post/1.0.0/setup.sh | bash -s -- ./vendor/getto-systems
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
  script:
    - getto-hangar-fix-vulnerabilities.sh
    - curl https://trellis.getto.systems/ci/bump-version/1.3.0/request.sh | bash -s -- ./.fix-vulnerabilities-message.sh

bump_version:
  stage: bump_version
  only:
    refs:
      - triggers
    variables:
      - $RELEASE

  image: buildpack-deps:disco-scm

  before_script:
    - git config user.email COMMITER_EMAIL
    - git config user.name COMMITER_NAME
    - curl https://trellis.getto.systems/git/post/1.0.0/setup.sh | bash -s -- ./vendor/getto-systems
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
  script:
    - curl https://trellis.getto.systems/ci/bump-version/1.3.0/bump_version.sh | bash
    - curl https://trellis.getto.systems/ci/bump-version/1.3.0/request.sh | bash -s -- ./.bump-message.sh

release:
  stage: release
  only:
    refs:
      - master@REPOSITORY_PATH
    changes:
      - .release-version
  except:
    refs:
      - triggers
      - schedules

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1
  services:
    - docker:dind

  script:
    - curl https://trellis.getto.systems/ci/bump-version/1.3.0/push_tags.sh | bash
    - getto-hangar-push_latest.sh IMAGE_NAME
```

replace settings

- IMAGE_NAME
- REPOSITORY_PATH
- COMMITER_EMAIL
- COMMITER_NAME

require settings

- DOCKER_USER
- DOCKER_PASSWORD
- DOCKER_CONTENT_TRUST_REPOSITORY_ID
- DOCKER_CONTENT_TRUST_REPOSITORY_KEY
- DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE
- DOCKER_CONTENT_TRUST_ROOT_ID
- DOCKER_CONTENT_TRUST_ROOT_KEY
- DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE


## License

getto-hangar is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems
