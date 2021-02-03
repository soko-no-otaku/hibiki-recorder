# hibiki-recorder
響ラジオステーションで配信中のラジオの.tsファイルを保存するスクリプト

![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/evoltaro/rec_hibiki.svg)
![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/evoltaro/rec_hibiki.svg)
![Docker Pulls](https://img.shields.io/docker/pulls/evoltaro/rec_hibiki.svg)

## Installation

```
docker pull evoltaro/rec_hibiki
```

## Usage

```
docker run --rm -v $PWD:/output -it evoltaro/rec_hibiki llss
docker run --rm -v $PWD:/output -it evoltaro/rec_hibiki tsunradi
```
