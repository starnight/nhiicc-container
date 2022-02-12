# nhiicc-container

Use NHIICC (健保卡憑證元件) in Container.  Podman for example.

## The Knowledge of the Certificate Tool

* The tool runs as a secured web server to accept queries from frontend.  The web server listens on `https://127.0.0.1:7777`.  However, the web server uses self signed certificates for TLS tunnel.
* The tool will read the information from the smart card reader with [PC/SC Smart Card Daemon (pcscd)](https://pcsclite.apdu.fr/) and check the data from requests with the information.

## Build Container Image

### Here is the steps in the Dockerfile:
1. Use [Debian stable-slim](https://hub.docker.com/_/debian) as the base image.
2. Install dependencies.
3. Get certificate tool's tarball from official website.
3. Unpack the tarball and deploy the files.
4. Remove the residues.

### Build the container image

`podman build --tag nhiicc-tool -f Dockerfile`

## Run the Container with the Built Image as the Tool

* Pass the USB smart card into the container.  Get the USB device's location first.  For example, Alcor Micro smart card reader:
  ```sh
  $ lsusb | grep Alcor
  Bus 001 Device 007: ID 058f:9520 Alcor Micro Corp. Watchdata W 1981
  ```
  The device **007** locates on the USB bus **001**.
* Make the container [share the same network stack](https://hackmd.io/@starnight/share-hosts-network-stack-with-container) with host.
* Run the container as a deamon:
  ```sh
  podman run -dt --rm --network=host --device=/dev/bus/usb/001/007 --name nhiicc-container localhost/nhiicc-tool
  ```

## Browse the Web Site with NHIICC Verification Service

1. **Add the DNS mapping on host locally**: Add `127.0.0.1 iccert.nhi.gov.tw` into `/etc/hosts`.
2. Browse https://localhost:7777 and force **trust the web server's _self signed_ certificate on the host**.
3. Insert the Health Insurance Card into the smart card reader.  Then, check that the container/tool works as expect by reading the card with the web page https://cloudicweb.nhi.gov.tw/cloudic/system/webtesting/SampleY.aspx
4. Go to the web site with NHIICC verification service and use it!
5. Stop the container/tool by `podman stop nhiicc-container` when finish work.

PS. The Smart Card reader can be accessed by only one application each time.  Others will be failed to get the Smart Card reader at the same time.

## Reference:

* [健保卡網路服務註冊](https://cloudicweb.nhi.gov.tw/cloudic/system/SMC/mEventesting.htm)
* [nhiicc AUR package script](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=nhiicc)
