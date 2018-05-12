# hibiki-recorder
響ラジオステーションで配信中のラジオの.tsファイルを保存するスクリプト

## Installation

```
git clone git@github.com:soko-no-otaku/hibiki-recorder.git
cd hibiki-recorder/
docker build -t rec_hibiki .
```

## Usage

```
docker run -v $PWD:/output -it rec_hibiki llss
docker run -v $PWD:/output -it rec_hibiki tsunradi
```
