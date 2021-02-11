# bof (ctf easy tutorial)

**이 레포지토리는 매우 쉬운 CTF 입문 문제들을 관리합니다. 서버에 설치할 수도 있고, Docker 로 편하게 시작할 수도 있습니다.**

## Docker

```shell
$ docker run -it --privileged ccss17/bof
```

Start `ccss17/bof` with `-it --privileged` option.

## Setup BOF CTF

Execute the following commands for setting bof CTF environment.

```shell
git clone https://github.com/ccss17/bof
cd bof
./setup.sh
```

To uninstall bof CTF environment, run `setup.sh` again with `--remove` option.

```shell
./setup.sh --remove
```

Check created bof users and their passwords

```shell
tail -n12 /etc/passwd
cat PASSWORDS
```

![check](https://user-images.githubusercontent.com/16812446/72774687-eaa4b580-3c4e-11ea-895e-b59762c8baf6.PNG)

First CTF stage is `bof1`. Login with ID `bof1` and password `bof1`.

![check2](https://user-images.githubusercontent.com/16812446/72774697-f3958700-3c4e-11ea-820d-2b86ab92620e.PNG)

Then exploit `bof1` to get password of `bof2` in `bof2.pw`.
