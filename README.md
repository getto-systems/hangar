# getto-hangar

docker image repository : using by getto projects

status : production ready


###### Table of Contents

- [Usage](#Usage)
- [License](#License)


## Usage

`.gitlab-ci.yml` sample

```yaml
image: <BASE_IMAGE>

stages:
  - image_build
  - image_test
  - image_scheduled_test
  - image_fix_vulnerabilities
  - image_push

variables:
  TRELLIS_HANGAR: https://trellis.getto.systems/hangar/2.39.0
  TRELLIS_GIT_POST: https://trellis.getto.systems/git/post/1.0.0
  TRELLIS_CI_BUMP_VERSION: https://trellis.getto.systems/ci/bump-version/1.4.0

image_build:
  stage: image_build
  only:
    refs:
      - merge_requests
    changes:
      - package-lock.json
      - Dockerfile
      - Dockerfile-test

  image: docker:stable

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1

  services:
    - docker:dind

  artifacts:
    paths:
      - .build/image.tar
    expire_in: 1 day

  before_script:
    - mkdir -p .build
    - export image=image:$CI_COMMIT_SHORT_SHA
  script:
    - docker build -t $image .
    - sed -i -e "s|FROM.*|FROM $image|" Dockerfile-test
    - docker build -t $image-test -f Dockerfile-test --disable-content-trust .
    - docker run --rm --disable-content-trust $image-test
    - docker image save $image --output .build/image.tar
    - chown 1000:1000 .build/image.tar

image_test:
  stage: image_test
  only:
    refs:
      - merge_requests
    changes:
      - package-lock.json
      - Dockerfile
      - Dockerfile-test
  needs:
    - image_build

  before_script:
    - curl $TRELLIS_HANGAR/install_trivy.sh | sh -s -- vendor
    - curl $TRELLIS_HANGAR/install_dockle.sh | sh -s -- vendor
  script:
    - ./vendor/dockle --exit-code 1 --input .build/image.tar
    - ./vendor/trivy --exit-code 1 --light --no-progress --ignore-unfixed --input .build/image.tar

image_scheduled_test:
  stage: image_scheduled_test
  only:
    refs:
      - schedules
    variables:
      - $CHECK

  before_script:
    - curl $TRELLIS_HANGAR/install_trivy.sh | sh -s -- vendor
    - curl $TRELLIS_HANGAR/install_dockle.sh | sh -s -- vendor
  script:
    - ./vendor/dockle --exit-code 1 $(cat .getto-hangar-image)
    - ./vendor/trivy --exit-code 1 --light --no-progress --ignore-unfixed $(cat .getto-hangar-image)

image_fix_vulnerabilities:
  stage: image_fix_vulnerabilities
  only:
    refs:
      - schedules
    variables:
      - $CHECK
  when: on_failure

  image: buildpack-deps:buster-scm

  before_script:
    - git config user.email admin@getto.systems
    - git config user.name getto
    - curl $TRELLIS_GIT_POST/setup.sh | sh -s -- ./vendor/getto-systems
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
  script:
    - curl $TRELLIS_HANGAR/fix-vulnerabilities.sh | sh -s -- Dockerfile
    - 'git add Dockerfile && git commit -m "fix: vulnerabilities"'
    - curl $TRELLIS_CI_BUMP_VERSION/request.sh | sh -s -- ./.message/fix-vulnerabilities.sh

image_push:
  stage: image_push
  only:
    refs:
      - release@<REPOSITORY_PATH>
    changes:
      - package-lock.json
      - Dockerfile
      - Dockerfile-test
  except:
    refs:
      - schedules
      - triggers

  image: docker:stable

  variables:
    DOCKER_HOST: tcp://docker:2375/
    DOCKER_DRIVER: overlay2
    DOCKER_CONTENT_TRUST: 1

  services:
    - docker:dind

  before_script:
    - apk update && apk add bash git curl
    - git config user.email admin@getto.systems
    - git config user.name getto
    - curl $TRELLIS_GIT_POST/setup.sh | sh -s -- ./vendor/getto-systems
    - export HOME=$(pwd)
    - export PATH=$PATH:./vendor/getto-systems/git-post/bin
    - export hangar_id=$(cat .getto-hangar-image | sed 's/.*://' | sed 's/-.*//')
    - export image=getto/hangar:$hangar_id-$(date +%Y%m%d%H%M%S)
    - curl $TRELLIS_HANGAR/docker_login.sh | sh
  script:
    - docker build -t $image .
    - docker push $image
    - 'sed -i -e "s|image: getto/hangar:$hangar_id-\\?.*|image: $image|" .gitlab-ci.yml'
    - echo $image > .getto-hangar-image
    - 'git add .gitlab-ci.yml .getto-hangar-image && git commit -m "update: image"'
    - curl $TRELLIS_CI_BUMP_VERSION/request.sh | sh -s -- ./.message/fix-image.sh
```

environments

- DOCKER_USER : var
- DOCKER_PASSWORD : file
- DOCKER_CONTENT_TRUST_REPOSITORY_ID : var
- DOCKER_CONTENT_TRUST_REPOSITORY_KEY : file
- DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE : var
- DOCKER_CONTENT_TRUST_ROOT_ID : var
- DOCKER_CONTENT_TRUST_ROOT_KEY : file
- DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE : var


### install_dockle.sh

```bash
curl https://trellis.getto.systems/hangar/3.0.0/install_dockle.sh | sh -s -- <path/to/install/dir>
```

install [dockle](https://github.com/goodwithtech/dockle)

requirements

- curl
- tar
- gzip


### install_trivy.sh

```bash
curl https://trellis.getto.systems/hangar/3.0.0/install_trivy.sh | sh -s -- <path/to/install/dir>
```

install [trivy](https://github.com/aquasecurity/trivy)

requirements

- curl
- tar
- gzip


### docker_login.sh

```bash
curl https://trellis.getto.systems/hangar/3.0.0/docker_login.sh | sh
```

`docker login`

requirements

- docker cli

environments

- DOCKER_USER : var
- DOCKER_PASSWORD : file
- DOCKER_CONTENT_TRUST_REPOSITORY_ID : var
- DOCKER_CONTENT_TRUST_REPOSITORY_KEY : file
- DOCKER_CONTENT_TRUST_REPOSITORY_PASSPHRASE : var
- DOCKER_CONTENT_TRUST_ROOT_ID : var
- DOCKER_CONTENT_TRUST_ROOT_KEY : file
- DOCKER_CONTENT_TRUST_ROOT_PASSPHRASE : var


## License

getto-hangar is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2019 shun@getto.systems
